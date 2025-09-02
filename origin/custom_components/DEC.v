module DEC (clk, rst, opcode, imme, condition, cal, copy);
  parameter UUID = 0;
  parameter NAME = "";
  input wire clk;
  input wire rst;

  input  wire [7:0] opcode;
  output  wire [0:0] imme;
  output  wire [0:0] condition;
  output  wire [0:0] cal;
  output  wire [0:0] copy;

  TC_Splitter8 # (.UUID(64'd827310526666029203 ^ UUID)) Splitter8_0 (.in(wire_7), .out0(), .out1(), .out2(), .out3(), .out4(), .out5(), .out6(wire_1), .out7(wire_0));
  TC_Nor # (.UUID(64'd906105695261242525 ^ UUID), .BIT_WIDTH(64'd1)) Nor_1 (.in0(wire_1), .in1(wire_0), .out(wire_2));
  TC_And # (.UUID(64'd3789704926614815027 ^ UUID), .BIT_WIDTH(64'd1)) And_2 (.in0(wire_0), .in1(wire_1), .out(wire_3));
  TC_Xor # (.UUID(64'd856303867671499959 ^ UUID), .BIT_WIDTH(64'd1)) Xor_3 (.in0(wire_0), .in1(wire_1), .out(wire_4));
  TC_Xor # (.UUID(64'd3369899527930689728 ^ UUID), .BIT_WIDTH(64'd1)) Xor_4 (.in0(wire_0), .in1(wire_1), .out(wire_8));
  TC_And # (.UUID(64'd755252315778961311 ^ UUID), .BIT_WIDTH(64'd1)) And_5 (.in0(wire_1), .in1(wire_4), .out(wire_5));
  TC_And # (.UUID(64'd2053104498862861711 ^ UUID), .BIT_WIDTH(64'd1)) And_6 (.in0(wire_0), .in1(wire_8), .out(wire_6));

  wire [0:0] wire_0;
  wire [0:0] wire_1;
  wire [0:0] wire_2;
  assign imme = wire_2;
  wire [0:0] wire_3;
  assign condition = wire_3;
  wire [0:0] wire_4;
  wire [0:0] wire_5;
  assign cal = wire_5;
  wire [0:0] wire_6;
  assign copy = wire_6;
  wire [7:0] wire_7;
  assign wire_7 = opcode;
  wire [0:0] wire_8;

endmodule
