module processor;

reg [31:0] pc;

reg clk;
reg [7:0] datmem[0:31];
reg [7:0] mem[0:31];

wire [31:0] dataa,datab,datab1;
wire [31:0] wtoreg,wtoreg1;
wire [31:0] newPC,newPC1,newPC2;
wire [31:0] aluOutput,extad,pcplus4,branchaddress;
wire [31:0] sextad,readdata;
wire [31:0] jaddress;

wire [5:0] inst31_26;
wire [4:0] inst25_21,inst20_16,inst15_11,wreg,wreg1;
wire [15:0] inst15_0;
wire [25:0] inst25_0;
wire [31:0] instruc,dataPack;
wire [2:0] aluControl,branchControl;

wire cout,flagz,flagn,regdest,alusrc,memtoreg,regwrite,memread,memwrite,aluop1,aluop0;
wire [1:0] immedateop;

reg isBranch, isj, isjal, isjr;

reg [31:0] registerfile [0:31];
integer i;

// datamemory connections
always @(posedge clk)
begin
	if(memwrite)
	begin 
		datmem[aluOutput[4:0]+3]=datab[7:0];
		datmem[aluOutput[4:0]+2]=datab[15:8];
		datmem[aluOutput[4:0]+1]=datab[23:16];
		datmem[aluOutput[4:0]]=datab[31:24];
	end
end

//instruction memory
assign instruc = {mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
assign inst31_26 = instruc[31:26];
assign inst25_21 = instruc[25:21];
assign inst20_16 = instruc[20:16];
assign inst15_11 = instruc[15:11];
assign inst15_0 = instruc[15:0];
assign inst25_0 = instruc[25:0];

// registers
assign dataa = registerfile[inst25_21];
assign datab = registerfile[inst20_16];

//multiplexers
assign dataPack={datmem[aluOutput[5:0]],datmem[aluOutput[5:0]+1],datmem[aluOutput[5:0]+2],datmem[aluOutput[5:0]+3]};

mult2_to_1_5  mult1(wreg, instruc[20:16],instruc[15:11],regdest);
mult2_to_1_5  multIsJal(wreg1, wreg, 5'b11111,isjal);

mult2_to_1_32 mult2(datab1, datab, extad, alusrc);

mult2_to_1_32 mult3(wtoreg, aluOutput, dataPack, memtoreg);
mult2_to_1_32 multIsJalWrite(wtoreg1, wtoreg, pcplus4, isjal);

mult2_to_1_32 multIsBranch(newPC, pcplus4,branchaddress,isBranch);
mult2_to_1_32 multIsJ(newPC1,newPC,jaddress, isj | isjal);
mult2_to_1_32 multIsJr(newPC2,newPC1,dataa, isjr);

always @(posedge clk)
begin
	registerfile[wreg1] = regwrite ? wtoreg1 : registerfile[wreg1];
end

always @(branchControl or flagz or dataa)
begin
case(branchControl)
	3'b001: isBranch = flagz; // beq 
	3'b010: isBranch = ~flagz; // bne 
	3'b011: isBranch = ~dataa[31] & (|dataa); // bgtz
	3'b100: isBranch = ~dataa[31]; // bgez
	3'b101: isBranch = dataa[31]; // bltz
	default: isBranch = 0;
endcase
end

always @(instruc)
begin
	isj=0;
	isjal=0;
	case(instruc[31:26])
		6'b000010: isj=1;
		6'b000011: isjal=1;
	endcase
	
	isjr=0;
	case(instruc[5:0])
		6'b001000: isjr=1;
	endcase
end

// load pc
always @(negedge clk)
pc = newPC2;

alu32 alu1(aluOutput, dataa, datab1, flagz, flagn, aluControl);
adder add1(pc,32'h4,pcplus4);
adder add2(pcplus4,sextad,branchaddress);
control cont(instruc[31:26],instruc[20:16],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branchControl,aluop1,aluop0,immedateop);
signext sext(instruc[15:0],extad);
alucont acont(aluop1,aluop0,instruc[3],instruc[2],instruc[1],instruc[0],aluControl,immedateop);
shift shift2(sextad,extad);
jmodule jmodul(instruc[25:0],pcplus4[31:28], jaddress);

//initialize datamemory,instruction memory and registers
initial
begin
	$readmemh("/home/mtyldz/Downloads/singlecycleMIPS-lite/initdata.dat",datmem);
	$readmemh("/home/mtyldz/Downloads/singlecycleMIPS-lite/part2.dat",mem);
	$readmemh("/home/mtyldz/Downloads/singlecycleMIPS-lite/initreg.dat",registerfile);

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
	isBranch=0;
	isj=0;
	isjal=0;
	isjr=0;
	pc=0;
	#400 $finish;
end

initial
begin
	clk=0;
forever #20  clk=~clk;
end

initial 
begin
	$monitor($time,"PC %h",pc,"  ALU output:%h",aluOutput,"   INST %h",instruc[31:0],
	"  REGISTER: \n$ra)%h ",registerfile[31], "\nr1)%d", registerfile[1],"\nr2)%d", registerfile[2], "\nr3)%d", registerfile[3],"\nr4)%d", registerfile[4], "\nr5)%d", registerfile[5], "\nr6)%d", registerfile[6]);
end

endmodule
