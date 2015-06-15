`include "mips.sv"
`timescale 1ns/1ps

module dmem(
		input logic clk,
		proc_memory.dmem_if dmem_mem
	   );

logic [31:0] RAM[1023:0];

assign dmem_mem.readdata = RAM[dmem_mem.dataadr[11:2]];

initial
begin
	foreach(RAM[i])
	begin
		RAM[i] = i;
	end
end

always_ff @(posedge clk)
begin

	if(dmem_mem.memwrite)
		RAM[dmem_mem.dataadr[11:2]] <= dmem_mem.writedata;
end
endmodule
