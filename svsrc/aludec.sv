/*Last Change	: 06/08/2013
 *Last User	: Manas
 *Changes Made:
 *	DATE: 07/08/2013
 *	Unique case added
 *	always_comb used
 *	default condition removed in earlier case statement for "aluop"
 *	default condition removed in earlier case statement for "funct"
 *	input and output ports changed to logic types
 *--------------------------------------------------------------------------
 *Last Change	: 06/10/2013
 *Last User	: Nagarjun
 * Changes Made:
 *	Converted the alu op and funct to a user-defined enum 
 */	

`include "mipspkg.sv"
`timescale 1ns/1ps
`define DEBUG

module aludec(
		input funct_t funct,
        	input alu_t aluop,
        	output alucont_t alucontrol
	     	);

/*
`ifdef DEBUG
  initial begin
    $dumpvars(0, funct, aluop, alucontrol);
  end
`endif
*/

  always_comb
  begin
    unique case(aluop)
      /*These are operations of Immediate types*/
      alu_ADD: alucontrol = alucont_ADD;  	// ADDI
      alu_SUB: alucontrol = alucont_SUB;  	// SUBI
      alu_SLT: alucontrol = alucont_SLT;  	// SLTI
      /*Provision for additional features*/
      //4'b0011: 				// SLTU
      alu_AND: alucontrol = alucont_AND;  	// ANDI
      alu_OR: alucontrol = alucont_OR;  	// ORI
      alu_XOR: alucontrol = alucont_XOR;  	// XORI
      alu_LU: alucontrol = alucont_LUI;  	// LUI
      alu_regtype: unique case(funct)         		// REGISTER TYPE INSTRUCTIONS
	/*These are operations on Register type instructions*/
        /*Provision for additional features*/
	/* 
      	  6'b000000: 				// sll - shift left logical
          6'b000010: 				// srl - shift right logical
          6'b000011: 				// sra - shift right arithmetic
          6'b000100: 				// sllv
          6'b000110: 				// srlv
          6'b000111: 				// srav
          6'b001000: 				// jr
          6'b001001: 				// jalr
          6'b001100: 				// syscall
          6'b001101: 				// break
      	*/
          ADD: alucontrol = alucont_ADD;  	// ADD
          ADDU: alucontrol = alucont_ADD;  	// ADDU
          SUB: alucontrol = alucont_SUB;  	// SUB
          SUBU: alucontrol = alucont_SUB;  	// SUBU
          AND: alucontrol = alucont_AND;  	// AND
          OR: alucontrol = alucont_OR;  	// OR
          XOR: alucontrol = alucont_XOR;  	// XOR
          NOR: alucontrol = alucont_NOR;  	// NOR
          SLT: alucontrol = alucont_SLT;  	// SLT
          //6'b101011: 				// SLTU
        endcase
    endcase
    //$display("\n aluop = %b funct = %b",aluop,funct);
  end  
endmodule
