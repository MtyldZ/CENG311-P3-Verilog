module control(opcode, rt, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2, immedateop);
input [5:0] opcode;
input [4:0] rt;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, aluop1, aluop2;
output reg [2:0] branch;
output reg [1:0] immedateop;

wire rtype, isimmedate;
reg lw,sw,beq,isjal;

always @(opcode or rt)
begin
lw = 0;
sw = 0;
branch = 3'b000;
immedateop = 2'b00;
isjal = 0;

// beq 000100, bne 000101, bgez 000001, bgtz 000111, bltz

// addi 001000, andi 001101
// jr nor 
// jal 000011, j 000010

case(opcode)
	6'b000100: branch = 3'b001; // beq 
	6'b000101: branch = 3'b010; // bne 
	6'b000111: case(rt)
			5'b00000: branch = 3'b011; // bgtz
	   	   endcase
	6'b000001: case(rt)
			5'b00000: branch = 3'b101; // bltz
			5'b00001: branch = 3'b100; // bgez
	   	   endcase
	6'b001000: immedateop = 2'b01; // addi
	6'b001100: immedateop = 2'b10; // andi
	6'b100011: lw = 1;
	6'b101011: sw = 1;
	6'b000011: isjal = 1;
endcase
end

assign isimmedate = |immedateop;

assign rtype = ~|opcode;
assign regdest = rtype;
assign alusrc = lw|sw|isimmedate;
assign memtoreg = lw & ~isimmedate;
assign regwrite = rtype|lw|isjal|isimmedate;
assign memread = lw;
assign memwrite = sw;
assign aluop1 = rtype;
assign aluop2 = |branch;

endmodule
