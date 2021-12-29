module jmodule(inst25_0,pcplus4_31_28, jaddress);
input [25:0] inst25_0;
input [3:0] pcplus4_31_28;
output [31:0] jaddress;
assign jaddress = {pcplus4_31_28, inst25_0, 2'b00};
endmodule
