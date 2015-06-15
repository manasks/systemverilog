/* DLX Opcode package used with test bench-ECE 510 
 *
 * Copyright (c) 2013.
 *
 * Author:Manas KS, Nagarjun Hassan Ranganath		Rakesh Vasudevan, Vignesh Kumaragurubaran
 * Date:		13th June, 2013
 *
 * 	Description:
 * 	------------
 * 	Contains enums for classifying R-Type,I-Type,J-Type Instructions
 */
`ifndef DLX_HEADER
`define DLX_HEADER
package DLXOpCodes;
  typedef enum bit [5:0] {ADD=6'b100000,ADDU=6'b100001,SUB=6'b100010,SUBU=6'b100011,AND=6'b100100,OR=6'b100101,XOR=6'b100110,NOR=6'b100111,SLT=6'b101010} RType;
  typedef enum bit [5:0] {ADDI=6'b001000,SUBI=6'b001010,SLTI=6'b011010,ANDI=6'b001100,ORI=6'b001101,XORI=6'b001110,LUI=6'b001111,BEQZ=6'b000100,LW=6'b100011,SW=6'b101011} IType; 
  typedef enum bit [5:0] {J=6'b000010}JType;
endpackage: DLXOpCodes  
import DLXOpCodes::*;
`endif
