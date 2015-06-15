`include "mipspkg.sv"
`timescale 1ns/1ps

module temptop(
		input logic clk,
		input logic reset
		); 

proc_memory pminst();

mips mipsinst(clk,reset,pminst);
dmem dmeminst(clk,pminst);


endmodule
