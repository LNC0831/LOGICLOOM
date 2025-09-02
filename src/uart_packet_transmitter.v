module uart_packet_transmitter (
    input wire clk_50m,           // 50MHz输入时钟
    input wire rst_n,             // 异步复位，低电平有效
    
    input wire [7:0] data_00,
    input wire [7:0] data_01,
    input wire [7:0] data_02,
    input wire [7:0] data_03,
    input wire [7:0] data_04,
    input wire [7:0] data_05,
    input wire [7:0] data_06,
    input wire [7:0] data_07,
    input wire [7:0] data_08,
    input wire [7:0] data_09,
    input wire [7:0] data_10,
    input wire [7:0] data_11,
    input wire [7:0] data_12,
    input wire [7:0] data_13,
    input wire [7:0] data_14,
    input wire [7:0] data_15,
    input wire [7:0] data_16,
    input wire [7:0] data_17,
    input wire [7:0] data_18,
    input wire [7:0] data_19,
    input wire [7:0] data_20,
    input wire [7:0] data_21,
    input wire [7:0] data_22,
    input wire [7:0] data_23,
    
    output reg uart_tx,           // 串口发送信号
    output wire tx_busy           // 发送忙信号
);

// 参数定义
parameter CLK_FREQ = 50_000_000;    // 50MHz时钟频率
parameter BAUD_RATE = 115200;       // 波特率115200
parameter PACKET_INTERVAL_MS = 20;  // 20ms发送间隔

// 计算分频系数
localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;           // 波特率分频系数 = 434
localparam TIMER_20MS = CLK_FREQ / 1000 * PACKET_INTERVAL_MS; // 20ms计数值 = 1,000,000

// 状态机定义
localparam IDLE         = 3'b000;
localparam WAIT_TIMER   = 3'b001;
localparam LOAD_DATA    = 3'b010;
localparam START_BIT    = 3'b011;
localparam DATA_BITS    = 3'b100;
localparam STOP_BIT     = 3'b101;
localparam NEXT_BYTE    = 3'b110;

// 信号定义
reg [2:0] state, next_state;
reg [19:0] timer_20ms;              // 20ms定时器，20位足够计数到1,000,000
reg [8:0] baud_counter;             // 波特率分频计数器
reg [255:0] packet_data;            // 32字节报文数据 (32*8=256位)
reg [4:0] byte_index;               // 字节索引 (0-31)
reg [2:0] bit_index;                // 数据位索引 (0-7)
reg [7:0] current_byte;             // 当前发送的字节
reg baud_tick;                      // 波特率时钟标志
reg timer_overflow;                 // 20ms定时器溢出标志

// 报文头和尾定义
localparam [7:0] HEADER_0 = 8'hAA;
localparam [7:0] HEADER_1 = 8'h55;
localparam [7:0] HEADER_2 = 8'hA5;
localparam [7:0] HEADER_3 = 8'h5A;
localparam [7:0] TAIL_0   = 8'h0D;
localparam [7:0] TAIL_1   = 8'h0A;
localparam [7:0] TAIL_2   = 8'h5A;
localparam [7:0] TAIL_3   = 8'hA5;

// 20ms定时器
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        timer_20ms <= 20'd0;
        timer_overflow <= 1'b0;
    end else begin
        if (timer_20ms >= TIMER_20MS - 1) begin
            timer_20ms <= 20'd0;
            timer_overflow <= 1'b1;
        end else begin
            timer_20ms <= timer_20ms + 1'b1;
            timer_overflow <= 1'b0;
        end
    end
end

// 波特率分频器
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        baud_counter <= 9'd0;
        baud_tick <= 1'b0;
    end else begin
        if (baud_counter >= BAUD_DIV - 1) begin
            baud_counter <= 9'd0;
            baud_tick <= 1'b1;
        end else begin
            baud_counter <= baud_counter + 1'b1;
            baud_tick <= 1'b0;
        end
    end
end

// 数据包组装 - 使用拼接操作符，更简洁高效
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        packet_data <= 256'd0;
    end else begin
        // 一次性组装32字节报文：报文尾 + 24字节数据 + 报文头
        // 注意：高位在前，低位在后，所以报文尾在最高位
        packet_data <= {TAIL_3, TAIL_2, TAIL_1, TAIL_0,           // 报文尾 [255:224]
                       data_23, data_22, data_21, data_20,         // 数据20-23 [223:192]
                       data_19, data_18, data_17, data_16,         // 数据16-19 [191:160]
                       data_15, data_14, data_13, data_12,         // 数据12-15 [159:128]
                       data_11, data_10, data_09, data_08,         // 数据8-11 [127:96]
                       data_07, data_06, data_05, data_04,         // 数据4-7 [95:64]
                       data_03, data_02, data_01, data_00,         // 数据0-3 [63:32]
                       HEADER_3, HEADER_2, HEADER_1, HEADER_0};    // 报文头 [31:0]
    end
end

// 主状态机 - 时序逻辑
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// 主状态机 - 组合逻辑
always @(*) begin
    next_state = state;
    case (state)
        IDLE: begin
            if (timer_overflow)
                next_state = LOAD_DATA;
        end
        
        WAIT_TIMER: begin
            if (timer_overflow)
                next_state = LOAD_DATA;
        end
        
        LOAD_DATA: begin
            next_state = START_BIT;
        end
        
        START_BIT: begin
            if (baud_tick)
                next_state = DATA_BITS;
        end
        
        DATA_BITS: begin
            if (baud_tick && bit_index == 3'd7)
                next_state = STOP_BIT;
        end
        
        STOP_BIT: begin
            if (baud_tick)
                next_state = NEXT_BYTE;
        end
        
        NEXT_BYTE: begin
            if (byte_index == 5'd31)
                next_state = WAIT_TIMER;
            else
                next_state = START_BIT;
        end
        
        default: next_state = IDLE;
    endcase
end

// 状态机输出和控制逻辑
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        uart_tx <= 1'b1;           // 空闲时为高电平
        byte_index <= 5'd0;
        bit_index <= 3'd0;
        current_byte <= 8'd0;
    end else begin
        case (state)
            IDLE: begin
                uart_tx <= 1'b1;
                byte_index <= 5'd0;
                bit_index <= 3'd0;
            end
            
            WAIT_TIMER: begin
                uart_tx <= 1'b1;
                byte_index <= 5'd0;
                bit_index <= 3'd0;
            end
            
            LOAD_DATA: begin
                // 获取第一个字节（报文头的第一个字节）
                current_byte <= packet_data[7:0];  // HEADER_0
                byte_index <= 5'd0;
                bit_index <= 3'd0;
            end
            
            START_BIT: begin
                uart_tx <= 1'b0;      // 起始位为0
                if (baud_tick) begin
                    bit_index <= 3'd0;
                end
            end
            
            DATA_BITS: begin
                uart_tx <= current_byte[bit_index];  // 发送数据位，LSB优先
                if (baud_tick) begin
                    bit_index <= bit_index + 1'b1;
                end
            end
            
            STOP_BIT: begin
                uart_tx <= 1'b1;      // 停止位为1
            end
            
            NEXT_BYTE: begin
                uart_tx <= 1'b1;
                if (byte_index == 5'd31) begin
                    byte_index <= 5'd0;
                end else begin
                    byte_index <= byte_index + 1'b1;
                    // 从256位数据中提取下一个字节
                    current_byte <= packet_data[(byte_index + 1'b1) * 8 +: 8];
                    bit_index <= 3'd0;
                end
            end
            
            default: begin
                uart_tx <= 1'b1;
            end
        endcase
    end
end

// 输出忙信号
assign tx_busy = (state != IDLE && state != WAIT_TIMER);

endmodule