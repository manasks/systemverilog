`include "mipspkg.sv"
`timescale 1ns/1ps
module aludecTestbench;

`define DEBUG
`define ALUDECTESTFILE "aludectestvector.txt"

funct_t funct = ADD;
alu_t aluop = alu_ADD;
alucont_t alucontrol;

localparam DELAY = 5;
integer correct = 0;
integer total = 0;

aludec aludecinst(.*);

task assignandcheck(integer intFunct, intAluop);

integer incorrect;

$cast(funct,intFunct);
$cast(aluop,intAluop);

#DELAY

unique case(intAluop)
	0:
	begin
		if(alucontrol != alucont_ADD)
		incorrect = 1;
	end

	1:
	begin
		if(alucontrol != alucont_SUB)
		incorrect = 1;
	end

	2:
	begin
		if(alucontrol != alucont_SLT)
		incorrect = 1;
	end

	4:
	begin
		if(alucontrol != alucont_AND)
		incorrect = 1;
	end

	5:
	begin
		if(alucontrol != alucont_OR)
		incorrect = 1;
	end

	6:
	begin
		if(alucontrol != alucont_XOR)
		incorrect = 1;
	end

	7:
	begin
		if(alucontrol != alucont_LUI)
		incorrect = 1;
	end

	15:
	begin
		unique case(intFunct)
		32:
		begin
			if(alucontrol != alucont_ADD)
			incorrect = 1;
		end

		33:
		begin
			if(alucontrol != alucont_ADD)
			incorrect = 1;
		end

		34:
		begin
			if(alucontrol != alucont_SUB)
			incorrect = 1;
		end

		35:
		begin
			if(alucontrol != alucont_SUB)
			incorrect = 1;
		end

		36:
		begin
			if(alucontrol != alucont_AND)
			incorrect = 1;
		end

		37:
		begin
			if(alucontrol != alucont_OR)
			incorrect = 1;
		end

		38:
		begin
			if(alucontrol != alucont_XOR)
			incorrect = 1;
		end

		39:
		begin
			if(alucontrol != alucont_NOR)
			incorrect = 1;
		end

		42:
		begin
			if(alucontrol != alucont_SLT)
			incorrect = 1;
		end
		endcase
		
	end
	endcase

total++;
correct++;

if(incorrect)
begin
	$display("aluop = %b funct = %b alucontrol = %b",aluop,funct,alucontrol);
	correct--;
	incorrect = 0;
end
endtask

initial
begin

integer intFunct, intAluop;
integer i,j;

#DELAY assignandcheck(32,15);


for(j=0 ; j <= 7 ; j++)
begin
	for(i=32; i<=39; i++)
	begin
		if(j != 3)
		#DELAY assignandcheck(i,j);
	end
end


j = 15;
for(i=32; i<=39 ; i++)
begin
	#DELAY assignandcheck(i,j);
end

i = 42;
#DELAY assignandcheck(i,j);

$display("\n \n Total = %d \t Correct = %d",total,correct);
$display("\n End of Testbench\n");


#DELAY
$stop;
end
endmodule
