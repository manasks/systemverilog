`include "mipspkg.sv"
`timescale 1ns/1ps

module mipsTestbench;

proc_memory p_f();
temptop temptopinst(.*);

logic clk;
logic reset = 1'b0;

localparam DELAY = 5;

initial
begin
	$monitor($time,"R3 = %h, R4 = %h, R5 = %h R6 = %h R7 = %h R20 = %h R14 = %h",temptopinst.mipsinst.dp.rf.rfile[3],temptopinst.mipsinst.dp.rf.rfile[4],temptopinst.mipsinst.dp.rf.rfile[5],temptopinst.mipsinst.dp.rf.rfile[6],temptopinst.mipsinst.dp.rf.rfile[7],temptopinst.mipsinst.dp.rf.rfile[20],temptopinst.mipsinst.dp.rf.rfile[14]);
end

initial
begin
clk = 1'b0;
forever #2.5 clk = ~clk;
end

initial
begin

reset = 1'b1;
#DELAY
reset = 1'b0;

/*
#DELAY
temptopinst.pminst.instr = 32'h8E840001;
*/

#DELAY
temptopinst.pminst.instr = 32'h8C051234;

#DELAY
temptopinst.pminst.instr = 32'h00853FE0;




/*
#DELAY
temptopinst.pminst.instr = 32'h00C357E0;

#DELAY
temptopinst.pminst.instr = 32'h014F2FE0;

#DELAY
temptopinst.pminst.instr = 32'h00CF57E0;

#DELAY
temptopinst.pminst.instr = 32'h00221FE0;
*/
#DELAY
temptopinst.pminst.instr = 32'h20642345;

#DELAY

temptopinst.pminst.instr = 32'h008537E2;
#DELAY

/*
temptopinst.pminst.instr = 32'h28C70001;

#DELAY
temptopinst.pminst.instr = 32'h00C747EA;

#DELAY
temptopinst.pminst.instr = 32'h010957E4;

#DELAY
temptopinst.pminst.instr = 32'h014B67E5;

#DELAY 
*/

temptopinst.pminst.instr = 32'h018D77E6;
#DELAY

/*
temptopinst.pminst.instr = 32'h3FEF1234;

#DELAY
temptopinst.pminst.instr = 32'h6A110009;

#DELAY
temptopinst.pminst.instr = 32'h00EFBFE7;

#DELAY
temptopinst.pminst.instr = 32'h00E647EA;

#DELAY
temptopinst.pminst.instr = 32'h00C74FEA;

#DELAY
temptopinst.pminst.instr = 32'h08000800;

#DELAY
temptopinst.pminst.instr = 32'h00E647EA;

#DELAY
temptopinst.pminst.instr = 32'h00C74FEA;

#DELAY
temptopinst.pminst.instr = 32'h00C74FEA;

#DELAY
temptopinst.pminst.instr = 32'h00C74FEA;

#DELAY
temptopinst.pminst.instr = 32'h00C74FEC;

#DELAY
temptopinst.pminst.instr = 32'h8FE51234;

#DELAY
temptopinst.pminst.instr = 32'hACFD3185;
*/
#DELAY
#DELAY
#DELAY
#DELAY
#DELAY
#DELAY
#DELAY
#DELAY
#DELAY
#DELAY
#DELAY
#DELAY

$display("BAGGU");

$finish;
end

final
begin

foreach(temptopinst.mipsinst.dp.rf.rfile[i])
	$display("Register %d = %d [%h]",i,temptopinst.mipsinst.dp.rf.rfile[i],temptopinst.mipsinst.dp.rf.rfile[i]);

foreach(temptopinst.dmeminst.RAM[i])
	$display("RAM [%d] = %d [%h]",i,temptopinst.dmeminst.RAM[i],temptopinst.dmeminst.RAM[i]);

$display("\n END OF SIMULATION");


end

endmodule
