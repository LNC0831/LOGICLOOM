module CPU (clk, input_8bit, output_8bit ,cmd_addr, cmd_8bit, rst);
  parameter UUID = 0;
  parameter NAME = "";
  input wire 		clk;
  input wire 		rst;
  
  input wire [7:0] 	input_8bit;
  input wire [7:0] 	cmd_8bit  ;
  
  output wire [7:0] output_8bit;
  output reg  [7:0] cmd_addr   ;
  
  assign wire_0_4 = rst ? 8'b0 : (wire_8 ? input_8bit : 8'b0);  //user input
  assign output_8bit = rst ? 8'b0 : (wire_25 ? wire_0 : 8'b0);  //user output
  assign wire_16 = cmd_8bit;									//command in 

  wire [7:0] wire_0;
  wire [7:0] wire_0_0;
  wire [7:0] wire_0_1;
  wire [7:0] wire_0_2;
  wire [7:0] wire_0_3;
  wire [7:0] wire_0_4;
  wire [7:0] wire_0_5;
  wire [7:0] wire_0_6;
  wire [7:0] wire_0_7;
  wire [7:0] wire_0_8;
  assign wire_0 = wire_0_0|wire_0_1|wire_0_2|wire_0_3|wire_0_4|wire_0_5|wire_0_6|wire_0_7|wire_0_8;
  wire [0:0] wire_1;
  wire [0:0] wire_2;
  wire [0:0] wire_3;
  wire [0:0] wire_4;
  wire [7:0] wire_5;
  wire [7:0] wire_6;
  wire [7:0] wire_7;
  wire [0:0] wire_8;
  wire [0:0] wire_9;
  wire [0:0] wire_10;
  wire [0:0] wire_11;
  wire [7:0] wire_12;
  wire [0:0] wire_13;
  wire [0:0] wire_14;
  wire [0:0] wire_15;
  wire [7:0] wire_16;
  wire [0:0] wire_17;
  wire [0:0] wire_18;
  wire [7:0] wire_19;
  wire [0:0] wire_20;
  wire [7:0] wire_21;
  wire [7:0] wire_22;
  wire [0:0] wire_23;
  wire [0:0] wire_24;
  wire [0:0] wire_25;
  wire [7:0] wire_26;
  wire [7:0] wire_27;
  wire [0:0] wire_28;
  wire [0:0] wire_29;
  wire [0:0] wire_30;
  wire [0:0] wire_31;
  wire [0:0] wire_32;
  wire [0:0] wire_33;
  wire [0:0] wire_34;
  wire [0:0] wire_35;
  wire [0:0] wire_36;
  wire [7:0] wire_37;

















  TC_Splitter8 # (.UUID(64'd1740909036157118627 ^ UUID)) Splitter8_0 (.in(wire_16), .out0(wire_24), .out1(wire_10), .out2(wire_33), .out3(wire_29), .out4(wire_35), .out5(wire_2), .out6(), .out7());
  TC_Decoder3 # (.UUID(64'd3285532197686644414 ^ UUID)) Decoder3_1 (.dis(wire_20), .sel0(wire_24), .sel1(wire_10), .sel2(wire_33), .out0(wire_18), .out1(wire_9), .out2(wire_15), .out3(wire_13), .out4(wire_32), .out5(wire_31), .out6(wire_25), .out7());
  TC_Decoder3 # (.UUID(64'd2068417560946943622 ^ UUID)) Decoder3_2 (.dis(wire_20), .sel0(wire_29), .sel1(wire_35), .sel2(wire_2), .out0(wire_30), .out1(wire_36), .out2(wire_14), .out3(wire_23), .out4(wire_11), .out5(wire_34), .out6(wire_8), .out7());
  TC_Switch # (.UUID(64'd325150327384652478 ^ UUID), .BIT_WIDTH(64'd8)) Switch8_3 (.en(wire_4), .in(wire_22), .out(wire_0_7));
  TC_Mux # (.UUID(64'd723863209402855404 ^ UUID), .BIT_WIDTH(64'd8)) Mux8_4 (.sel(wire_4), .in0({{7{1'b0}}, wire_13 }), .in1({{7{1'b0}}, wire_4 }), .out(wire_37));
  TC_Counter # (.UUID(64'd2647770476147775263 ^ UUID), .BIT_WIDTH(64'd8), .count(8'd1)) Counter8_5 (.clk(clk), .rst(rst), .save(wire_1), .in(wire_5), .out(wire_6));
  TC_Mux # (.UUID(64'd4158782181600309462 ^ UUID), .BIT_WIDTH(64'd8)) Mux8_6 (.sel(wire_3), .in0({{7{1'b0}}, wire_18 }), .in1({{7{1'b0}}, wire_3 }), .out(wire_27));
  TC_Switch # (.UUID(64'd3888359016934678901 ^ UUID), .BIT_WIDTH(64'd8)) Switch8_7 (.en(wire_3), .in(wire_16), .out(wire_0_8));
  TC_Not # (.UUID(64'd3155310201563455113 ^ UUID), .BIT_WIDTH(64'd1)) Not_8 (.in(wire_17), .out(wire_20));
  TC_Switch # (.UUID(64'd347437319060339452 ^ UUID), .BIT_WIDTH(64'd8)) Switch8_9 (.en(wire_28), .in(wire_16), .out(wire_7));
  TC_Program8_1 # (.UUID(64'd857501675760812171 ^ UUID), .DEFAULT_FILE_NAME("Program8_1_BE6753B1A06808B.w8.bin"), .ARG_SIG("Program8_1_BE6753B1A06808B=%s")) Program8_1_10 (.clk(clk), .rst(rst), .address(wire_6), .out(wire_16));
  DEC # (.UUID(64'd561234129375555341 ^ UUID)) DEC_11 (.clk(clk), .rst(rst), .opcode(wire_16), .imme(wire_3), .condition(wire_28), .cal(wire_4), .copy(wire_17));
  ALU # (.UUID(64'd3203376692861713137 ^ UUID)) ALU_12 (.clk(clk), .rst(rst), .cmd(wire_16), .input1(wire_26), .input2(wire_12), .\output (wire_22));
  COND # (.UUID(64'd3319144537462594360 ^ UUID)) COND_13 (.clk(clk), .rst(rst), .condition(wire_7), .\input (wire_21), .\output (wire_1));
  RegisterPlus # (.UUID(64'd2013824320296903733 ^ UUID)) RegisterPlus_14 (.clk(clk), .rst(rst), .rd_en(wire_30), .\input (wire_0), .wr_en(wire_27[0:0]), .output_always(wire_5), .Output(wire_0_5));
  RegisterPlus # (.UUID(64'd4393917700000120423 ^ UUID)) RegisterPlus_15 (.clk(clk), .rst(rst), .rd_en(wire_36), .\input (wire_0), .wr_en(wire_9), .output_always(wire_26), .Output(wire_0_6));
  RegisterPlus # (.UUID(64'd898038243217137729 ^ UUID)) RegisterPlus_16 (.clk(clk), .rst(rst), .rd_en(wire_14), .\input (wire_0), .wr_en(wire_15), .output_always(wire_12), .Output(wire_0_3));
  RegisterPlus # (.UUID(64'd2922266585936576169 ^ UUID)) RegisterPlus_17 (.clk(clk), .rst(rst), .rd_en(wire_23), .\input (wire_0), .wr_en(wire_37[0:0]), .output_always(wire_21), .Output(wire_0_2));
  RegisterPlus # (.UUID(64'd2122138527428093258 ^ UUID)) RegisterPlus_18 (.clk(clk), .rst(rst), .rd_en(wire_11), .\input (wire_0), .wr_en(wire_32), .output_always(), .Output(wire_0_1));
  RegisterPlus # (.UUID(64'd4446153895860665334 ^ UUID)) RegisterPlus_19 (.clk(clk), .rst(rst), .rd_en(wire_34), .\input (wire_0), .wr_en(wire_31), .output_always(), .Output(wire_0_0));
  TC_Switch # (.UUID(64'd1502156430737279918 ^ UUID), .BIT_WIDTH(64'd8)) Switch8_20 (.en(wire_8), .in(wire_19), .out(wire_0_4));
  TC_Constant # (.UUID(64'd1643049279126162415 ^ UUID), .BIT_WIDTH(64'd8), .value(8'h5)) Constant8_21 (.out(wire_19));
  TC_SegmentDisplay # (.UUID(64'd4193781903170062915 ^ UUID)) SegmentDisplay_22 (.clk(clk), .rst(rst), .enable(wire_25), .value(wire_0));
















  always@(posedge clk) begin //程序计数输出（程序存储器索引）
	if(rst)
		cmd_addr <= 'b0;
	else
		cmd_addr <= wire_6;
  end
		
	
endmodule
