`include "mipspkg.sv"
 /* alutb.sv    ECE 510
 * Copyright (c) 2013.
 *
 * Author:Manas KS, Nagarjun Hassan Ranganath		Rakesh Vasudevan
 * Date:		13th June, 2013
 *
 * 	Description:
 * 	------------
 * 	This is the testbench of the alu module. The testbench does only directed Testing. The various alu operations
 *  executed by the alu module are tested using this test bench
 */


`timescale 1ns/1ps
module aluTestbench;

`define DEBUG 0
`define ALUDECFILE "aludecvector.txt"
`define ALUHEXFILE "aluhexvector.txt"

logic [DATAWIDTH-1:0] a = '0;
logic [DATAWIDTH-1:0] b = '0;
logic [5:0] alucont = 6'b000010;
logic [5:0] alucontchk = 6'b000010;
logic [DATAWIDTH-1:0] result;
logic overflow;
logic sum;

alu aluinst(.*);

task alusum(integer signed InA, InB, logic [5:0] alucontchk);

integer signed intResult;
integer signed aluResult;
logic [DATAWIDTH-1:0] ActualResult;

if(alucontchk[4:0] == 5'b00000)
	intResult	= InA & InB;
else if (alucontchk[4:0] == 5'b00001)
	intResult	= InA | InB;
else if (alucontchk == 6'b000010)
	intResult	= InA + InB;
else if (alucontchk == 6'b100010)
	intResult	= InA - InB;
else if (alucontchk[4:0] == 5'b00011)
	intResult	= InA < InB ? 1 : 0;
else if (alucontchk[4:0] == 5'b00100)
	intResult	= InA ^ InB;
else if (alucontchk[4:0] == 5'b00101)
	intResult	= ~(InA | InB);
else if (alucontchk[4:0] == 5'b00110)
	intResult	= (InB & 65535) << 16;
else
	$display("\n INVALID ALUCONT SIGNAL \n");

a		= InA;
b		= InB;
alucont		= alucontchk;

#5
ActualResult	= intResult;
aluResult	= result;

if(result != ActualResult)
	$display("a = %d b = %d alucont = %b aluResult = %h ActualResult = %h overflow = %b",InA,InB,alucont,result,ActualResult,overflow);

endtask

initial
begin

integer infile;
integer signed ain,bin;

/*Read the operand from a file*/
infile	= $fopen(`ALUDECFILE,"r");
while(!$feof(infile))
begin: decreadfile

	if($fscanf(infile,"%d %d %b\n",ain,bin,alucontchk) != 3)
	begin
		$display("Error Reading Operands From Alutestfile \n");
		$finish();
	end
	#5 alusum(ain,bin,alucontchk);
end: decreadfile
$fclose(infile);

infile	= $fopen(`ALUHEXFILE,"r");
while(!$feof(infile))
begin: hexreadfile

	if($fscanf(infile,"%h %h %b\n",ain,bin,alucontchk) != 3)
	begin
		$display("Error Reading Operands From Alutestfile \n");
		$finish();
	end
	#5 alusum(ain,bin,alucontchk);
end: hexreadfile
$fclose(infile);


/*The below statement checks the validity of the assertion in alu.sv. InvalidALUControl_a*/
alucont = 6'b111111;


#5
$stop;
end
endmodule
