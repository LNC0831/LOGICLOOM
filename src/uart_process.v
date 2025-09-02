module uart_data_processor (
    input  wire        clk_50m,        // 50MHzʱ��
    input  wire        rst_n,          // �͵�ƽ��λ
    input  wire        rx,             // ���ڽ���
    output wire        tx,             // ���ڷ���
    input  wire [7:0]  mem_index,      // 8λ�����˿�
    output wire [7:0]  mem_data_out,   // 8λ��������˿�
    output wire        rx_done         // ������ɱ�־
);

// ��������
parameter CLK_FREQ = 50_000_000;
parameter BAUD_RATE = 115200;
parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE; // 434ʱ������

// ��ͷ��β����
parameter [7:0] HEADER = 8'hFE;
parameter [7:0] TRAILER = 8'hFF;

// 256�ֽ��ڴ�ռ�
reg [7:0] memory [0:255];

// ״̬��״̬����
parameter [2:0] IDLE         = 3'b000,
                WAIT_HEADER  = 3'b001,
                RX_DATA      = 3'b010,
                WAIT_TRAILER = 3'b011,
                RX_COMPLETE  = 3'b100,
                SEND_RST     = 3'b101,
                SEND_DONE    = 3'b110;

reg [2:0] current_state, next_state;

// �ڲ��ź�
wire       uart_rx_valid;
wire [7:0] uart_rx_data;
wire       uart_tx_ready;
reg        uart_tx_valid;
reg  [7:0] uart_tx_data;

reg  [7:0] data_cnt;          // ���ݼ�����
reg        rx_done_reg;       // ������ɱ�־�Ĵ���

//===========================================
// UART����ģ��
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

// ͬ��������
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n)
        rx_sync <= 3'b111;
    else
        rx_sync <= {rx_sync[1:0], rx};
end

wire rx_negedge = rx_sync[2] && !rx_sync[1];

// UART����״̬��
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
            0: begin // �ȴ���ʼλ
                if (rx_negedge) begin
                    rx_bit_cnt <= BIT_PERIOD / 2;
                    rx_state <= 1;
                end
            end
            
            1: begin // ������ʼλ
                if (rx_bit_cnt == 0) begin
                    if (!rx_sync[1]) begin
                        rx_bit_cnt <= BIT_PERIOD - 1;
                        rx_state <= 2;
                        rx_shift_reg <= 0;
                        rx_data_cnt <= 0;
                    end else begin
                        rx_state <= 0; // �������ʼλ
                    end
                end else begin
                    rx_bit_cnt <= rx_bit_cnt - 1;
                end
            end
            
            2: begin // ��������λ
                if (rx_bit_cnt == 0) begin
                    rx_shift_reg <= {rx_sync[1], rx_shift_reg[7:1]};
                    rx_data_cnt <= rx_data_cnt + 1;
                    if (rx_data_cnt == 7) begin // �ѽ���8λ
                        rx_bit_cnt <= BIT_PERIOD - 1;
                        rx_state <= 3;
                    end else begin
                        rx_bit_cnt <= BIT_PERIOD - 1;
                    end
                end else begin
                    rx_bit_cnt <= rx_bit_cnt - 1;
                end
            end
            
            3: begin // �ȴ�ֹͣλ
                if (rx_bit_cnt == 0) begin
                    if (rx_sync[1]) begin
                        rx_valid_reg <= 1;
                        rx_state <= 0;
                    end else begin
                        rx_state <= 0; // ֡����
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
// UART����ģ��
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
            0: begin // ����״̬
                tx_reg <= 1;
                if (uart_tx_valid && tx_ready_reg) begin
                    tx_ready_reg <= 0;
                    tx_shift_reg <= uart_tx_data;
                    tx_bit_cnt <= BIT_PERIOD - 1;
                    tx_state <= 1;
                    tx_data_cnt <= 0;
                end
            end
            
            1: begin // ������ʼλ
                tx_reg <= 0;
                if (tx_bit_cnt == 0) begin
                    tx_bit_cnt <= BIT_PERIOD - 1;
                    tx_state <= 2;
                end else begin
                    tx_bit_cnt <= tx_bit_cnt - 1;
                end
            end
            
            2: begin // ��������λ
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
            
            3: begin // ����ֹͣλ
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
// ��״̬��
//===========================================
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n)
        current_state <= SEND_RST;
    else
        current_state <= next_state;
end

// ״̬ת���߼�
always @(*) begin
    next_state = current_state;
    
    case (current_state)
        SEND_RST: begin
            if (uart_tx_ready && !uart_tx_valid)
                next_state = IDLE;
        end
        
        IDLE: begin
            if (uart_rx_valid && uart_rx_data == HEADER)
                next_state = RX_DATA;  // ֱ����ת�����ݽ���״̬
        end
        
        RX_DATA: begin
            if (uart_rx_valid && uart_rx_data == TRAILER)
                next_state = SEND_DONE;
            else if (data_cnt >= 255) // �ڴ����ˣ��ȴ���β
                next_state = WAIT_TRAILER;
        end
        
        WAIT_TRAILER: begin
            if (uart_rx_valid && uart_rx_data == TRAILER)
                next_state = SEND_DONE;
            // ������Ǳ�β�������ȴ����������ݣ�
        end
        
        SEND_DONE: begin
            if (uart_tx_ready && !uart_tx_valid)
                next_state = RX_COMPLETE;
        end
        
        RX_COMPLETE: begin
            // �����ڴ�״̬��ֱ����λ
        end
        
        default: next_state = IDLE;
    endcase
end

// ״̬������߼�
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        data_cnt <= 0;
        uart_tx_valid <= 0;
        uart_tx_data <= 0;
        rx_done_reg <= 0;
        // ����ڴ滺����

        for (i = 0; i < 256; i = i + 1) begin
            memory[i] <= 8'h00;
        end
    end else begin
        uart_tx_valid <= 0;
        
        case (current_state)
            SEND_RST: begin
                data_cnt <= 0;
                rx_done_reg <= 0;
                // ��SEND_RST״̬Ҳ����ڴ棨���Ᵽ�գ�
                if (data_cnt != 0) begin

                    for (j = 0; j < 256; j = j + 1) begin
                        memory[j] <= 8'h00;
                    end
                end
                if (uart_tx_ready && !uart_tx_valid) begin
                    uart_tx_valid <= 1;
                    uart_tx_data <= 8'hFE;  // ����0xFE��Ϊ��λ��־
                end
            end
            
            IDLE: begin
                // ÿ�ν���IDLE״̬ʱ��ռ��������ڴ�
                if (data_cnt != 0) begin
                    data_cnt <= 0;

                    for (k = 0; k < 256; k = k + 1) begin
                        memory[k] <= 8'h00;
                    end
                end
                rx_done_reg <= 0;
                // ��IDLE״̬�ȴ���ͷ������Ҫ���⴦��
            end
            
            RX_DATA: begin
                if (uart_rx_valid) begin
                    if (uart_rx_data == TRAILER) begin
                        // �յ���β����ɽ���
                        rx_done_reg <= 1;
                    end else begin
                        // �洢���ݵ��ڴ棨�ų���β��
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
                // �������ݱ�����
            end
            
            SEND_DONE: begin
                if (uart_tx_ready && !uart_tx_valid) begin
                    uart_tx_valid <= 1;
                    uart_tx_data <= 8'hAA;  // ����0xAAȷ�����
                end
            end
            
            RX_COMPLETE: begin
                // ���ֽ������״̬
            end
        endcase
    end
end

//===========================================
// ����߼�
//===========================================
assign mem_data_out = (current_state == RX_COMPLETE) ? memory[mem_index] : 8'h00;
assign rx_done = (current_state == RX_COMPLETE);

endmodule