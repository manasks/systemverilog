/*Last Change	: 06/10/2013
 *Last User	: Nagarjun
 *Changes Made:
 *	DATE: 06/10/2013
 *	Unique case added
 *	always_ff used
 *	input and output ports changed to logic types
 *	Parameterized the size of the registers and the size of the address bus for the registers
 */

// Register file:
// three ported register file
// read two ports combinationally
// write third port on falling edge of clock
// register 0 hardwired to 0

`include "mipspkg.sv"
`timescale 1ns/1ps

module regfile (clk, w_enable, r_addr1, r_addr2, w_addr1, w_data1, r_data1, r_data2);
input logic clk;			// clock
input logic w_enable;			// write enable
input logic [REGADDRSIZE-1:0] r_addr1;	// address lines
input logic [REGADDRSIZE-1:0] r_addr2;	// address lines
input logic [REGADDRSIZE-1:0] w_addr1;	// address lines
input logic [REGSIZE-1:0] w_data1;	// data input
output logic [REGSIZE-1:0] r_data1;
output logic [REGSIZE-1:0] r_data2;	// data output(s)

    logic [31:0] rfile[31:0];     // actual register file

`ifdef DEBUG
    initial begin
      $dumpvars(0, clk, w_enable, r_addr1, r_addr2,
                w_addr1, w_data1, r_data1, r_data2);
    end
`endif

	initial
	begin
		foreach(rfile[i])
		begin
			rfile[i] = i;
		end
	end

    // write on rising clock edge
    always_ff @(negedge clk)
    begin
      if(w_enable)
	rfile[w_addr1] <= w_data1;
    end

    assign r_data1 = (r_addr1 != 0) ? rfile[r_addr1] : 0;
    assign r_data2 = (r_addr2 != 0) ? rfile[r_addr2] : 0;

endmodule
