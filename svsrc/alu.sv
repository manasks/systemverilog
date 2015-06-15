/*Last Change: 06/10/2013
 *Last User: Manas
 *Changes Made:
 *	DATE: 06/08/2013
 *	always_comb used
 *	unique case statement used
 * 	default condition removed in earlier case statement
 *	input and output ports changed to logic types
 *	Type of variables b2, sum, slt changed to logic
 *	parameter DATALENGTH used to reference width of input/output ports and variables
 *	---------------------------------------------------------------------------------------------
 *	DATE: 06/09/2013
 *	overflow logic modified to reflect accurate value in case of positve values addition overflow
 *	--------------------------------------------------------------------------------------------
 *	DATE: 06/10/2013
 *	Chages made to LESS THAN operation. Adde own code to ensure proper working
 *	FUTURE WORK:
 *	Modify the "sum" to include separate chunks of code for addition and subtraction
 */

`include "mipspkg.sv"
`timescale 1ns/1ps
`define DEBUG
module alu(
	input logic [(mipspkg::DATAWIDTH-1):0] a,		// operand 1
	input logic [(mipspkg::DATAWIDTH-1):0] b,     		// operand 2
        input logic [5:0]  alucont,  				// control code from decoder
        output logic [(mipspkg::DATAWIDTH-1):0] result,   	// result
        output logic overflow  					// overflow
          );

  logic [DATAWIDTH-1:0] b2, sum, slt;

`ifdef DEBUG
  initial begin
    $dumpvars(0, a, b, alucont, result, overflow, b2, sum, slt);
  end
`endif

  /*change sign for subtraction*/
  //assign #1 b2 = alucont[5] ? ~b : b;

  /*sum operands (if subtraction - add one)*/
  //assign #1 {overflow, sum} = a + b2 + alucont[5];
  
  /*check sign bit (MSB) - (comparison)*/
  //assign #1 slt = sum[DATAWIDTH-1];

  always_comb
  begin
    b2 = alucont[5] ? ~b : b;
    {overflow,sum} = a + b2 + alucont[5];
    slt = sum[DATAWIDTH-1];

    //$display("\n alucont = %b",alucont);
    /*ASSERTION: To verify the validity of the alucont[4:0] signal*/
    //InvalidALUControl_a: assert((alucont[4:0] inside {[5'b00000:5'b00110]})) else $error("\n InvalidALUControl Signal in alu module \n");

    unique case(alucont[4:0])
      5'b00000: result = a & b;  	// AND, ANDI
      5'b00001: result = a | b;  	// OR, ORI
      5'b00010: result = sum;    	// sum: ADD, ADDI, ADDU, ADDUI, SUB, SUBI, SUBU, SUBUI
      5'b00011: 			// set if less than: SLT, SLTI
      		begin
		if(!a[DATAWIDTH-1] && !b[DATAWIDTH-1])
				result = (a < b) ? 1 : 0;
		else if(!a[DATAWIDTH-1] && b[DATAWIDTH-1])
				result = 0;
		else if(a[DATAWIDTH-1] && !b[DATAWIDTH-1])
				result = 1;
		else
				result = (a[DATAWIDTH-2:0] > b[DATAWIDTH-2:0]) ? 1 : 0;
		end
      5'b00100: result = a ^ b;  	// XOR, XORI
      5'b00101: result = ~(a | b);  	// NOR, NORI
      5'b00110: result = {b, 16'b0};  	// LUI
    endcase
    if((!a[DATAWIDTH-1] && !b[DATAWIDTH-1]) && result[DATAWIDTH-1])
	overflow = 1;

    //$display("\n a = %h b = %h  operation = %b Result = %h",a,b,alucont,result);

end
endmodule
