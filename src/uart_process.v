module uart_data_processor (
    input  wire        clk_50m,        // 50MHz时钟
    input  wire        rst_n,          // 低电平复位
    input  wire        rx,             // 串口接收
    output wire        tx,             // 串口发送
    input  wire [7:0]  mem_index,      // 8位索引端口
    output wire [7:0]  mem_data_out,   // 8位数据输出端口
    output wire        rx_done         // 接收完成标志
);

// 参数定义
parameter CLK_FREQ = 50_000_000;
parameter BAUD_RATE = 115200;
parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE; // 434时钟周期

// 报头报尾定义
parameter [7:0] HEADER = 8'hFE;
parameter [7:0] TRAILER = 8'hFF;

// 256字节内存空间
reg [7:0] memory [0:255];

// 状态机状态定义
parameter [2:0] IDLE         = 3'b000,
                WAIT_HEADER  = 3'b001,
                RX_DATA      = 3'b010,
                WAIT_TRAILER = 3'b011,
                RX_COMPLETE  = 3'b100,
                SEND_RST     = 3'b101,
                SEND_DONE    = 3'b110;

reg [2:0] current_state, next_state;

// 内部信号
wire       uart_rx_valid;
wire [7:0] uart_rx_data;
wire       uart_tx_ready;
reg        uart_tx_valid;
reg  [7:0] uart_tx_data;

reg  [7:0] data_cnt;          // 数据计数器
reg        rx_done_reg;       // 接收完成标志寄存器

//===========================================
// UART接收模块
//===========================================
reg [2:0] rx_sync;
reg [8:0] rx_bit_cnt;
reg [3:0] rx_state;
reg [7:0] rx_shift_reg;
reg [2:0] rx_data_cnt;        
reg       rx_valid_reg;


        integer i;
		                      integer j;
		                      integer k;

// 同步化处理
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n)
        rx_sync <= 3'b111;
    else
        rx_sync <= {rx_sync[1:0], rx};
end

wire rx_negedge = rx_sync[2] && !rx_sync[1];

// UART接收状态机
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        rx_bit_cnt <= 0;
        rx_state <= 0;
        rx_shift_reg <= 0;
        rx_data_cnt <= 0;
        rx_valid_reg <= 0;
    end else begin
        rx_valid_reg <= 0;
        
        case (rx_state)
            0: begin // 等待起始位
                if (rx_negedge) begin
                    rx_bit_cnt <= BIT_PERIOD / 2;
                    rx_state <= 1;
                end
            end
            
            1: begin // 采样起始位
                if (rx_bit_cnt == 0) begin
                    if (!rx_sync[1]) begin
                        rx_bit_cnt <= BIT_PERIOD - 1;
                        rx_state <= 2;
                        rx_shift_reg <= 0;
                        rx_data_cnt <= 0;
                    end else begin
                        rx_state <= 0; // 错误的起始位
                    end
                end else begin
                    rx_bit_cnt <= rx_bit_cnt - 1;
                end
            end
            
            2: begin // 接收数据位
                if (rx_bit_cnt == 0) begin
                    rx_shift_reg <= {rx_sync[1], rx_shift_reg[7:1]};
                    rx_data_cnt <= rx_data_cnt + 1;
                    if (rx_data_cnt == 7) begin // 已接收8位
                        rx_bit_cnt <= BIT_PERIOD - 1;
                        rx_state <= 3;
                    end else begin
                        rx_bit_cnt <= BIT_PERIOD - 1;
                    end
                end else begin
                    rx_bit_cnt <= rx_bit_cnt - 1;
                end
            end
            
            3: begin // 等待停止位
                if (rx_bit_cnt == 0) begin
                    if (rx_sync[1]) begin
                        rx_valid_reg <= 1;
                        rx_state <= 0;
                    end else begin
                        rx_state <= 0; // 帧错误
                    end
                end else begin
                    rx_bit_cnt <= rx_bit_cnt - 1;
                end
            end
            
            default: rx_state <= 0;
        endcase
    end
end

assign uart_rx_valid = rx_valid_reg;
assign uart_rx_data = rx_shift_reg;

//===========================================
// UART发送模块
//===========================================
reg        tx_reg;
reg        tx_ready_reg;
reg [8:0]  tx_bit_cnt;
reg [3:0]  tx_state;
reg [7:0]  tx_shift_reg;
reg [2:0]  tx_data_cnt;

always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        tx_reg <= 1;
        tx_ready_reg <= 1;
        tx_bit_cnt <= 0;
        tx_state <= 0;
        tx_shift_reg <= 0;
        tx_data_cnt <= 0;
    end else begin
        case (tx_state)
            0: begin // 空闲状态
                tx_reg <= 1;
                if (uart_tx_valid && tx_ready_reg) begin
                    tx_ready_reg <= 0;
                    tx_shift_reg <= uart_tx_data;
                    tx_bit_cnt <= BIT_PERIOD - 1;
                    tx_state <= 1;
                    tx_data_cnt <= 0;
                end
            end
            
            1: begin // 发送起始位
                tx_reg <= 0;
                if (tx_bit_cnt == 0) begin
                    tx_bit_cnt <= BIT_PERIOD - 1;
                    tx_state <= 2;
                end else begin
                    tx_bit_cnt <= tx_bit_cnt - 1;
                end
            end
            
            2: begin // 发送数据位
                tx_reg <= tx_shift_reg[0];
                if (tx_bit_cnt == 0) begin
                    tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
                    tx_data_cnt <= tx_data_cnt + 1;
                    if (tx_data_cnt == 7) begin
                        tx_bit_cnt <= BIT_PERIOD - 1;
                        tx_state <= 3;
                    end else begin
                        tx_bit_cnt <= BIT_PERIOD - 1;
                    end
                end else begin
                    tx_bit_cnt <= tx_bit_cnt - 1;
                end
            end
            
            3: begin // 发送停止位
                tx_reg <= 1;
                if (tx_bit_cnt == 0) begin
                    tx_ready_reg <= 1;
                    tx_state <= 0;
                end else begin
                    tx_bit_cnt <= tx_bit_cnt - 1;
                end
            end
            
            default: tx_state <= 0;
        endcase
    end
end

assign tx = tx_reg;
assign uart_tx_ready = tx_ready_reg;

//===========================================
// 主状态机
//===========================================
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n)
        current_state <= SEND_RST;
    else
        current_state <= next_state;
end

// 状态转换逻辑
always @(*) begin
    next_state = current_state;
    
    case (current_state)
        SEND_RST: begin
            if (uart_tx_ready && !uart_tx_valid)
                next_state = IDLE;
        end
        
        IDLE: begin
            if (uart_rx_valid && uart_rx_data == HEADER)
                next_state = RX_DATA;  // 直接跳转到数据接收状态
        end
        
        RX_DATA: begin
            if (uart_rx_valid && uart_rx_data == TRAILER)
                next_state = SEND_DONE;
            else if (data_cnt >= 255) // 内存满了，等待报尾
                next_state = WAIT_TRAILER;
        end
        
        WAIT_TRAILER: begin
            if (uart_rx_valid && uart_rx_data == TRAILER)
                next_state = SEND_DONE;
            // 如果不是报尾，继续等待（丢弃数据）
        end
        
        SEND_DONE: begin
            if (uart_tx_ready && !uart_tx_valid)
                next_state = RX_COMPLETE;
        end
        
        RX_COMPLETE: begin
            // 保持在此状态，直到复位
        end
        
        default: next_state = IDLE;
    endcase
end

// 状态机输出逻辑
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        data_cnt <= 0;
        uart_tx_valid <= 0;
        uart_tx_data <= 0;
        rx_done_reg <= 0;
        // 清空内存缓冲区

        for (i = 0; i < 256; i = i + 1) begin
            memory[i] <= 8'h00;
        end
    end else begin
        uart_tx_valid <= 0;
        
        case (current_state)
            SEND_RST: begin
                data_cnt <= 0;
                rx_done_reg <= 0;
                // 在SEND_RST状态也清空内存（额外保险）
                if (data_cnt != 0) begin

                    for (j = 0; j < 256; j = j + 1) begin
                        memory[j] <= 8'h00;
                    end
                end
                if (uart_tx_ready && !uart_tx_valid) begin
                    uart_tx_valid <= 1;
                    uart_tx_data <= 8'hFE;  // 发送0xFE作为复位标志
                end
            end
            
            IDLE: begin
                // 每次进入IDLE状态时清空计数器和内存
                if (data_cnt != 0) begin
                    data_cnt <= 0;

                    for (k = 0; k < 256; k = k + 1) begin
                        memory[k] <= 8'h00;
                    end
                end
                rx_done_reg <= 0;
                // 在IDLE状态等待报头，不需要额外处理
            end
            
            RX_DATA: begin
                if (uart_rx_valid) begin
                    if (uart_rx_data == TRAILER) begin
                        // 收到报尾，完成接收
                        rx_done_reg <= 1;
                    end else begin
                        // 存储数据到内存（排除报尾）
                        if (data_cnt < 255) begin
                            memory[data_cnt] <= uart_rx_data;
                            data_cnt <= data_cnt + 1;
                        end
                    end
                end
            end
            
            WAIT_TRAILER: begin
                if (uart_rx_valid && uart_rx_data == TRAILER) begin
                    rx_done_reg <= 1;
                end
                // 其他数据被丢弃
            end
            
            SEND_DONE: begin
                if (uart_tx_ready && !uart_tx_valid) begin
                    uart_tx_valid <= 1;
                    uart_tx_data <= 8'hAA;  // 发送0xAA确认完成
                end
            end
            
            RX_COMPLETE: begin
                // 保持接收完成状态
            end
        endcase
    end
end

//===========================================
// 输出逻辑
//===========================================
assign mem_data_out = (current_state == RX_COMPLETE) ? memory[mem_index] : 8'h00;
assign rx_done = (current_state == RX_COMPLETE);

endmodule