 /* maindectb.sv     ECE 510
 * Copyright (c) 2013.
 *
 * Author:Manas KS, Nagarjun Hassan Ranganath		Rakesh Vasudevan
 * Date:		13th June, 2013
 *
 * 	Description:
 * 	------------
 * 	This is he testbench of the maindec module. The testbench does only directed Testing. It tests the maindec module which
 *  converts opcode to control signals 
 */

`include "mipspkg.sv"
`timescale 1ns/1ps

module maindecTestbench;

op_t op;
logic memtoreg;
logic memwrite;
logic branch;
logic alusrc;
logic regdst;
logic regwrite;
logic jump;
logic zeroextend;
logic [3:0] aluop;

op_t op1;
logic [11:0] controlschk = '0;
localparam DELAY = 5;
integer incorrect = '0;

maindec maindecinst(.*);

task assignandverify(integer i);

$cast(op,i);
$display("op = %b i = %d",op,i);

#DELAY

controlschk = {regwrite,regdst,alusrc,branch,memwrite, memtoreg, jump, zeroextend, aluop};
unique case(i)
	0:
	begin
		if(controlschk != 12'b1100_0000_1111)
			incorrect = 1;
	end

	2:
	begin
		if(controlschk != 12'b0000_0010_0000)
			incorrect = 1;
	end

	4:
	begin
		if(controlschk != 12'b0001_0000_0001)
			incorrect = 1;
	end

	8:
	begin
		if(controlschk != 12'b1010_0000_0000)
			incorrect = 1;
	end

	9:
	begin
		if(controlschk != 12'b1010_0000_0000)
			incorrect = 1;
	end

	10:
	begin
		if(controlschk != 12'b1010_0000_0010)
			incorrect = 1;
	end

	12:
	begin
		if(controlschk != 12'b1010_0001_0100)
			incorrect = 1;
	end

	13:
	begin
		if(controlschk != 12'b1010_0001_0101)
			incorrect = 1;
	end

	14:
	begin
		if(controlschk != 12'b1010_0001_0110)
			incorrect = 1;
	end

	15:
	begin
		if(controlschk != 12'b1010_0001_0111)
			incorrect = 1;
	end

	35:
	begin
		if(controlschk != 12'b1010_0100_0000)
			incorrect = 1;
	end

	43:
	begin
		if(controlschk != 12'b0010_1000_0000)
			incorrect = 1;
	end
	endcase
if(incorrect)
begin
	$display("\n aluop = %b \t controls = %b",op,controlschk);
	incorrect = 0;
end
endtask

initial
begin

for(integer i=0 ; i<50 ; i++)
begin
	if(i inside {0,2,4,8,9,10,12,13,14,15,35,43})
	assignandverify(i);	
end

$display("\n End of Testbench");

$stop;
end
endmodule
