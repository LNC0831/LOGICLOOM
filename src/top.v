`timescale 1ns / 1ps

module top(
    input wire clk_50m,          
    input wire rst_n, 

	input wire uart_rx,
	output wire uart_tx,
	 
	output wire uart1_tx, 
	output wire led
    );


wire test_clk;
wire [7:0] cmd;
wire [7:0] addr;

clock_divider_50m_to_2 tclk(
    .clk_50m(clk_50m),     
    .rst_n(rst_n),       
    .clk_2hz(test_clk)      
);

wire done;
wire [7:0] out8;

assign led = ~done;

uart_packet_transmitter u_uart_transmitter (
    .clk_50m        (clk_50m),
    .rst_n          (rst_n),
    
    .data_00        (cmd),
    .data_01        (out8),
    .data_02        (addr),
    .data_03        (done),
    .data_04        (),
    .data_05        (),
    .data_06        (),
    .data_07        (),
    .data_08        (),
    .data_09        (),
    .data_10        (),
    .data_11        (),
    .data_12        (),
    .data_13        (),
    .data_14        (),
    .data_15        (),
    .data_16        (),
    .data_17        (),
    .data_18        (),
    .data_19        (),
    .data_20        (),
    .data_21        (),
    .data_22        (),
    .data_23        (),
    
    .uart_tx        (uart1_tx),
    .tx_busy        ()
);

CPU CPU_inst0(
		.clk(test_clk), 
		.rst(~done), 
		.cmd_8bit(cmd), 
		.cmd_addr(addr), 
		.output_8bit(out8)
);

uart_data_processor u_uart_processor (
    .clk_50m        (clk_50m),
    .rst_n          (rst_n),
    .rx             (uart_rx),
    .tx             (uart_tx),
    .mem_index      (addr),
    .mem_data_out   (cmd),
    .rx_done        (done)
);

endmodule
