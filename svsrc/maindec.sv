/*Last Change	: 06/10/2013
 *Last User	: Manas
 *Changes Made:
 * 	DATE: 06/09/2013		
 *	always@ block to always_comb
 *	case to unique case
 *	Removed the default statement
 *	Converted opcode to an enum type. enum is defined in the package "mipspkg.sv"
 *	-----------------------------------------------------------------------------
 *	DATE: 06/10/2013
 *	Changed datatype of controls from reg to logic
 *	-----------------------------------------------------------------------------
 *	Future Work:
 *	Parameters for bus width
*/

`timescale 1ns/1ps
`define DEBUG 1
`include "mipspkg.sv"
module maindec(input 	op_t	    op,
               output 	logic  	    memtoreg, memwrite,
               output	logic       branch, alusrc,
               output	logic       regdst, regwrite,
               output	logic       jump,
               output	logic       zeroextend,
               output 	logic [3:0] aluopout);

logic [11:0] controls;

`ifdef DEBUG
  initial begin
    $dumpvars(0, op,
              regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump,
              zeroextend, aluopout, controls);
  end
`endif

  assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, zeroextend,
          aluopout} = controls;

  always_comb
  begin

//  `ifndef DEBUG
//  	$display("\n OP = %s",op);
//  `endif


   // InvalidOpSignal_a: assert(op inside {Rtyp,J,BEQZ,ADDI,ADDIU,SLTI,ANDI,ORI,XORI,LUI,LW,SW}) else $error("ASSERTION FAIL: Invalid OP 					signal encountered. Check input to maindec module \n");

    unique case(op)
      Rtyp: 
      	controls = 12'b11000000_1111; 			// Rtyp
      //6'b000001: 					// BLTZ (rt = 0) or BGEZ (rt = 1)
      J: 
      	controls = 12'b00000010_0000; 			// J  9'b0XXX0X1_XX
      //6'b000011: 					// JAL
      BEQZ: 
      	controls = 12'b00010000_0001; 			// BEQZ
      //6'b000101: 					// BNE
      //6'b000110: 					// BLEZ
      //6'b000111: 					// BGTZ
      ADDI: 
      	controls = 12'b10100000_0000; 			// ADDI
      ADDIU: 
      	controls = 12'b10100000_0000; 			// ADDIU
      SUBI:
      	controls = 12'b10100000_0001;			// SUBI
      SLTI: 
      	controls = 12'b10100000_0010; 			// SLTI
      //6'b001011: controls = 12'b10100000_0011; 	// SLTIU
      ANDI: 
      	controls = 12'b10100001_0100; 			// ANDI
      ORI: 
      	controls = 12'b10100001_0101; 			// ORI
      XORI: 
      	controls = 12'b10100001_0110; 			// XORI
      LUI: 
      	controls = 12'b10100001_0111; 			// LUI
      //6'b100000: 					// LB
      //6'b100001: 					// LH
      LW: 
      	controls = 12'b10100100_0000; 			// LW
      //6'b100100: 					// LBU
      //6'b100101: 					// LHU
      //6'b101000: 					// SB
      //6'b101001: 					// SH
      SW: 
      	controls = 12'b00101000_0000; 			// SW
    endcase
    //$display("\n aluopout = %b",controls[3:0]);
   end
endmodule
