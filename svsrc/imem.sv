/*Last Change: 06/13/2013
 *Last User: Manas
 *Changes Made:
 *	added the interface and accordingly made changes to variables
 *----------------------------------------------------------------------
*/
`include "DLXOpCodes.sv"
`timescale 1ns/1ps
module imem(proc_memory imem_mem);
  
  logic [31:0] RAM[63:0];
  logic [5:0] pc_short;
  assign pc_short = imem_mem.pc[7:2];

  initial
  begin     
  
    end
assign  imem_mem.instr = RAM[pc_short]; // word aligned
endmodule:imem
