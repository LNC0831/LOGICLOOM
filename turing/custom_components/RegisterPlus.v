module RegisterPlus (clk, rst, rd_en, \input , wr_en, output_always, Output);
  parameter UUID = 0;
  parameter NAME = "";
  input wire clk;
  input wire rst;

  input  wire [0:0] rd_en;
  input  wire [7:0] \input ;
  input  wire [0:0] wr_en;
  output  wire [7:0] output_always;
  output  wire [7:0] Output;
  
    wire [7:0] wire_0;
  assign wire_0 = \input ;
  wire [7:0] wire_1;
  assign output_always = wire_1;
  wire [0:0] wire_2;
  assign wire_2 = rd_en;
  wire [0:0] wire_3;
  wire [0:0] wire_4;
  assign wire_4 = wr_en;

  TC_Register # (.UUID(64'd1 ^ UUID), .BIT_WIDTH(64'd8)) Register8_0 (.clk(clk), .rst(rst), .load(wire_3), .save(wire_4), .in(wire_0), .out(wire_1));
  TC_Constant # (.UUID(64'd2 ^ UUID), .BIT_WIDTH(64'd1), .value(1'd1)) On_1 (.out(wire_3));
  TC_Switch # (.UUID(64'd3587491547824661070 ^ UUID), .BIT_WIDTH(64'd8)) Output8z_2 (.en(wire_2), .in(wire_1), .out(Output));



endmodule
