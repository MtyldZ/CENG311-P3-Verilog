module alucont(aluop1,aluop0,f3,f2,f1,f0,gout,immedateop);

input aluop1,aluop0,f3,f2,f1,f0;
input [1:0] immedateop;
output reg [2:0] gout;

always @(aluop1 or aluop0 or f3 or f2 or f1 or f0 or immedateop)
begin
	if(~(aluop1|aluop0))		// 00 xxxx
		gout=3'b010; 		// sum
	if(aluop0)			// x1 xxxx
		gout=3'b110; 		// sub
	if(aluop1)
	begin
		if (~(f3|f2|f1|f0)) 	// 1x 0000
			gout=3'b010; 	// sum
		if (f1 & f3)		// 1x 1x1x
			gout=3'b111; 	// slt // set on less than
		if (f1 &~(f3))		// 1x 0x1x
			gout=3'b110; 	// sub
		if (f2 & f0)		// 1x x1x1
			gout=3'b001; 	// or
		if (~f3 & f2 & f1 & f0)	// 1x 0111
			gout=3'b100; 	// nor
		if (f2 &~(f0))		// 1x x1x0
			gout=3'b000; 	// and
		if (f2 & f1 & f3 & f0)	// 1x 1111
			gout = 3'b011;	// mul
	end
	if (|immedateop)
	begin
		//$monitor("immedateop %B ", immedateop);
		gout = 3'b111;
		if (~immedateop[1] & immedateop[0])
		//$monitor("passed to 01");
			gout=3'b010;
		if (immedateop[1] & ~immedateop[0])
			//$monitor("passed to 10");
			gout=3'b000;
		
		//case(immedateop)
			//2'b01: gout=3'b010; 	// sum
			//2'b10: gout=3'b000; 	// and
		//endcase
	end
end
endmodule
