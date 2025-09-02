module clock_divider_50m_to_2 (
    input wire clk_50m,     // 50MHz输入时钟
    input wire rst_n,       // 低电平有效复位信号
    output reg clk_2hz      // 2Hz输出时钟
);

    parameter COUNTER_MAX = 12499999;  // 12,499,999
    
    reg [23:0] counter;
    
    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            // 复位时清零计数器和输出时钟
            counter <= 24'b0;
            clk_2hz <= 1'b0;
        end else begin
            if (counter >= COUNTER_MAX) begin
                // 计数达到最大值时翻转输出时钟并清零计数器
                counter <= 24'b0;
                clk_2hz <= ~clk_2hz;
            end else begin
                // 否则计数器递增
                counter <= counter + 1'b1;
            end
        end
    end

endmodule