module clock_divider_50m_to_2 (
    input wire clk_50m,     // 50MHz����ʱ��
    input wire rst_n,       // �͵�ƽ��Ч��λ�ź�
    output reg clk_2hz      // 2Hz���ʱ��
);

    parameter COUNTER_MAX = 12499999;  // 12,499,999
    
    reg [23:0] counter;
    
    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            // ��λʱ��������������ʱ��
            counter <= 24'b0;
            clk_2hz <= 1'b0;
        end else begin
            if (counter >= COUNTER_MAX) begin
                // �����ﵽ���ֵʱ��ת���ʱ�Ӳ����������
                counter <= 24'b0;
                clk_2hz <= ~clk_2hz;
            end else begin
                // �������������
                counter <= counter + 1'b1;
            end
        end
    end

endmodule