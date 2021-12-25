module jmodule(inst25_0,pcplus4_31_28, jaddress);
input [25:0] inst25_0;
input [3:0] pcplus4_31_28;
output [31:0] jaddress;

wire [27:0] last_28;
assign last_28 = {inst25_0, 2'b00};
assign jaddress = {pcplus4_31_28, last_28};
endmodule
