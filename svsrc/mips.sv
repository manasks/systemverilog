/*Last Change: 06/12/2013
 *Last User: Manas
 *Changes Made:
 *	tried to get it to work but error with the interface. i think it will be rectified once
 *	the test bench is written n the mips is instantiated in it...
 *-----------------------------------------------------------------------------------------------
 *Changes Made:
 *	added the interface and accordingly made changes to variables
 *----------------------------------------------------------------------
 *Date : 06/10/2013
 *Changes Made:
 *	Changed to always_comb and always_ff blocks
 *	Used the .* operator wherever necessary and possible
 * 	Converted all signals to logic
 *----------------------------------------------------------------------
 *Date: 06/12/2012	
 *	Made modifications to ensure proper type matches between module ports
 *
*/

//------------------------------------------------
// RiscyMIPS
// Pipelined MIPS processor
//------------------------------------------------

`include "mipspkg.sv"
`timescale 1ns/1ps
`define DEBUG 1
module mips(input logic clk, reset,
            proc_memory.proc_if proc_mem);

  op_t op; 
  funct_t funct;
  logic regdstE, alusrcE, pcsrcD, memtoregE, memtoregM, memtoregW, regwriteE, regwriteM, regwriteW;
  logic [5:0]  alucontrolE;
  logic flushE, equalD, branchD, jumpD, zeroextendD;

/*
`ifdef DEBUG
  initial begin
    $display("%h",proc_mem.instr);
  end
`endif
*/

  controller c(.memwriteM(proc_mem.memwrite), .*);
  datapath dp(.pc(proc_mem.pc), .instr(proc_mem.instr), .dataadr(proc_mem.dataadr), 
	      .writedata(proc_mem.writedata), .readdata(proc_mem.readdata), .*);
endmodule

module controller(input  logic       clk, reset,
                  input  op_t        op,
		  input  funct_t     funct,
                  input  logic       flushE, equalD,
                  output logic       memtoregE, memtoregM, memtoregW, memwriteM,
                  output logic       pcsrcD, branch, alusrcE,
                  output logic       regdstE, regwriteE, regwriteM, regwriteW,
                  output logic       jumpD,
                  output logic       zeroextendD,
                  output logic [5:0] alucontrolE);

  alu_t aluop;

  logic       memtoreg, memwrite, alusrc,
              regdst, regwrite;
  logic [5:0] alucontrol;
  logic       memwriteE;
  logic [10:0] d_11,q_11;
  logic [2:0] d_3,q_3;
  logic [1:0] d_2,q_2;
  logic [3:0] aluopout;


`ifdef DEBUG
  initial begin
    $dumpvars(0, aluop, memtoreg, memwrite, alusrc, regdst, regwrite,
              alucontrol, alucontrolE, alusrcE, regdstE, memwriteE);
  end
`endif

  // main decoder
  maindec md( .*,.branch(branchD),.jump(jumpD),.zeroextend(zeroextendD));

  assign aluop = alu_t'(aluopout);
  // alu decoder
  aludec  ad( .*);

  // check for branch
  assign pcsrcD = branch & equalD;
  // d_11 and q_11 are the input and the output of the floprc regE
  assign d_11 = {memtoreg, memwrite, alusrc, regdst, regwrite, alucontrol};
  //assign q_11 = {memtoregE, memwriteE, alusrcE, regdstE, regwriteE,  alucontrolE};

  // d_3 and q_3 are the input and the output of the flopr regM
  assign d_3 = {memtoregE, memwriteE, regwriteE};
 // assign q_3 = {memtoregM, memwriteM, regwriteM};

  // d_2 and q_2 are the input and the output of the flopr regW
  assign d_2 = {memtoregM, regwriteM};
  //assign q_2 = {memtoregW, regwriteW};


  // pipeline registers - control path
  // register between Decode and Execute stages
  floprc #(11) regE( .*, .clear(flushE),
                  .d(d_11),
                  .q({memtoregE, memwriteE, alusrcE, regdstE, regwriteE,  alucontrolE}));
  // register between Execute and Memory stages
  flopr #(3) regM( .*,
                  .d(d_3),
                  .q({memtoregM, memwriteM, regwriteM}));
  // register between Memory and Writeback stages
  flopr #(2) regW( .*,
                  .d(d_2),
                  .q({memtoregW, regwriteW}));
endmodule

module datapath(input  logic        clk, reset,
                input  logic        memtoregE, memtoregM, memtoregW,
                input  logic        pcsrcD, branchD,
                input  logic        alusrcE, regdstE,
                input  logic        regwriteE, regwriteM, regwriteW,
                input  logic        jumpD,
                input  logic        zeroextendD,
                input  logic [5:0]  alucontrolE,
                output logic        equalD,
                output logic [31:0] pc,
                input  logic [31:0] instr,
                output logic [31:0] dataadr, writedata,
                input  logic [31:0] readdata,
                output op_t  	    op,
		output funct_t	    funct,
                output logic        flushE);

  logic        forwardaD, forwardbD;
  logic [1:0]  forwardaE, forwardbE;
  logic        stallF,stallD;
  logic [4:0]  rsD, rtD, rdD, rsE, rtE, rdE;
  logic [4:0]  writeregE, writeregM, writeregW;
  logic        flushD;
  logic [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD;
  logic [31:0] signimmD, signimmE, signimmshD;
  logic [31:0] srcaD, srca2D, srcaE, srca2E;
  logic [31:0] srcbD, srcb2D, srcbE, srcb2E, srcb3E;
  logic [31:0] pcplus4D, instrD;
  logic [31:0] aluoutE, aluoutW;
  logic        aluoverflowE;
  logic [31:0] readdataW, resultW;
<<<<<<< .mine
  logic jumpintermediate;
=======
  logic [31:0] intermediate;
>>>>>>> .r76

`ifdef DEBUG
  initial begin
    $dumpvars(0, stallF,
              rsD, rtD, rdD, instrD, pcplus4D,
              stallD, pcsrcD, branchD, op, funct,  equalD, jumpD, zeroextendD,
              signimmD, signimmshD, flushD,`
              rsE, rtE, rdE, signimmE,
              alucontrolE, alusrcE, regdstE, regwriteE, aluoutE,
              regwriteM, dataadr, writedata, readdata,
              regwriteW, aluoutW, readdataW, resultW);
  end
`endif

  // Hazard Detection Unit
  hazard    h( .*);

  // next PC logic (operates in fetch and decode)
  mux2 #(32)  pcbrmux(.d0(pcplus4F), .d1(pcbranchD), .s(pcsrcD), .y(pcnextbrFD));
  mux2 #(32)  pcmux(.d0(pcnextbrFD),.d1(intermediate),
                    .s(jumpintermediate), .y(pcnextFD));

  assign intermediate = pcplus4D + {6'b0,instrD[25:0]}; 
  
  // register file (operates in decode and writeback)
  regfile     rf( .w_enable(regwriteW), .r_addr1(rsD), .r_addr2(rtD), .w_addr1(writeregW),
                 .w_data1(resultW), .r_data1(srcaD), .r_data2(srcbD), .*);
	
  //-- Fetch stage logic ---
  // F latch / PC register
  flopenr #(32) pcreg( .*, .en(~stallF), .d(pcnextFD), .q(pc));
  // PC adder/incrementer, add 4 to PC
  adder       pcadd1(.a(pc), .b(32'h00000004), .y(pc:wplus4F));

  //-- Decode stage ---
  // D latch / decode stage register (upper part)
  flopenrc #(32) r2D( .*, .en(~stallD), .clear(flushD), .d(instr), .q(instrD));
  // D latch / decode stage register (lower part)
  flopenr #(32) r1D( .*, .en(~stallD), .d(pcplus4F), .q(pcplus4D));
  // sign extend immediate value
  signext     se(.a(instrD[15:0]), .zero(zeroextendD), .y(signimmD));
  // shift left immediate value by 2
  sl2         immsh(.a(signimmD), .y(signimmshD));
  // add to to PC sign extended and shifted immediate value (branch)
  adder       pcadd2(.a(pcplus4D), .b(signimmshD), .y(pcbranchD));
  // forwarding multiplexers
  mux2 #(32)  forwardadmux(.d0(srcaD), .d1(dataadr), .s(forwardaD), .y(srca2D));
  mux2 #(32)  forwardbdmux(.d0(srcbD), .d1(dataadr), .s(forwardbD), .y(srcb2D));
  // branch prediction comparator
  eqcmp       comp(.a(srca2D), .b(srcb2D), .eq(equalD));
  
  assign jumpintermediate = jumpD ? 1'b0 : (equalD ? 1'b1 : 1'b0);

  // get operation code (6 bit) from instruction
  assign op = op_t'(instrD[31:26]);
  // get function code (6 bit) from instruction
  assign funct = funct_t'(instrD[5:0]);
  // get source register (5 bit) from instruction
  assign rsD = instrD[25:21];
  // get target register (5 bit) from instruction
  assign rtD = instrD[20:16];
  // get destination register (5 bit) from instruction
  assign rdD = instrD[15:11];

  // flush D latch if branch or jump
  assign flushD = pcsrcD | jumpD;
  //---

  //-- Execute stage ---
  // latch E
  floprc #(32) r1E( .*, .clear(flushE), .d(srcaD), .q(srcaE));
  floprc #(32) r2E( .*, .clear(flushE), .d(srcbD), .q(srcbE));
  floprc #(32) r3E( .*, .clear(flushE), .d(signimmD), .q(signimmE));
  floprc #(5)  r4E( .*, .clear(flushE), .d(rsD), .q(rsE));
  floprc #(5)  r5E( .*, .clear(flushE), .d(rtD), .q(rtE));
  floprc #(5)  r6E( .*, .clear(flushE), .d(rdD), .q(rdE));
  // forwarding multiplexers
  mux3 #(32)  forwardaemux(.d0(srcaE), .d1(resultW), .d2(dataadr), .s(forwardaE), .y(srca2E));
  mux3 #(32)  forwardbemux(.d0(srcbE), .d1(resultW), .d2(dataadr), .s(forwardbE), .y(srcb2E));
  // ALU B operand source selector
  mux2 #(32)  srcbmux(.d0(srcb2E), .d1(signimmE), .s(alusrcE), .y(srcb3E));
  // ALU Unit
  alu         alu(srca2E, srcb3E, alucontrolE, aluoutE, aluoverflowE);
  // Write register selector (rt or td)
  mux2 #(5)   wrmux(.d0(rtE), .d1(rdE), .s(regdstE), .y(writeregE));
  // ---

  //-- Memory stage ---
  // latch M
  flopr #(32) r1M( .*, .d(srcb2E), .q(writedata));
  flopr #(32) r2M( .*, .d(aluoutE), .q(dataadr));
  flopr #(5)  r3M( .*, .d(writeregE), .q(writeregM));

  //-- Writeback stage ---
  // latch W
  flopr #(32) r1W( .*, .d(dataadr), .q(aluoutW));
  flopr #(32) r2W( .*, .d(readdata), .q(readdataW));
  flopr #(5)  r3W( .*, .d(writeregM), .q(writeregW));
  // result selector (from ALU or Memory)
  mux2 #(32)  resmux(.d0(aluoutW), .d1(readdataW), .s(memtoregW), .y(resultW));

endmodule

// Hazard Unit
module hazard(input  logic [4:0] rsD, rtD, rsE, rtE,
              input  logic [4:0] writeregE, writeregM, writeregW,
              input  logic       regwriteE, regwriteM, regwriteW,
              input  logic       memtoregE, memtoregM, branchD,
              output logic       forwardaD, forwardbD,
              output logic [1:0] forwardaE, forwardbE,
              output logic       stallF, stallD, flushE);

  logic lwstallD, branchstallD;

  // forwarding sources to D stage (branch equality)`
  assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
  assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);

  // forwarding sources to E stage (ALU)
  always_comb
    begin
      forwardaE = '0; forwardbE = '0;
      if (rsE != 0)
        if (rsE == writeregM & regwriteM) forwardaE = 2'b10;
        else if (rsE == writeregW & regwriteW) forwardaE = 2'b01;
      if (rtE != 0)
        if (rtE == writeregM & regwriteM) forwardbE = 2'b10;
        else if (rtE == writeregW & regwriteW) forwardbE = 2'b01;
    end

  // stalls
  assign #1 lwstallD = memtoregE & (rtE === rsD | rtE === rtD);
  assign #1 branchstallD = branchD &
             (regwriteE & (writeregE === rsD | writeregE === rtD) |
              memtoregM & (writeregM === rsD | writeregM === rtD));

  assign #1 stallD = lwstallD | branchstallD;
  assign #1 stallF = stallD; // stalling D stalls all previous stages
  assign #1 flushE = stallD; // stalling D flushes next stage

  // *** not necessary to stall D stage on store if source comes from load;
  // *** instead, another bypass network could be added from W to M
endmodule

// simple adder
module adder(input  logic [31:0] a, b,
             output logic [31:0] y);

  assign #1 y = a + b;
endmodule

// branch prediction comparator
module eqcmp(input  logic [31:0] a, b,
             output logic        eq);

  assign #1 eq = (a == b);
endmodule

// shift left by 2
module sl2(input  logic [31:0] a,
           output logic [31:0] y);

  // shift left by 2
  assign #1 y = {a[29:0], 2'b00};
endmodule

// extend sign of immediate value to 32 bits
module signext(input  logic [15:0] a,
               input  logic        zero,
               output logic [31:0] y);

  //assign #1 y = {{16{a[15]}}, a};
  // version with selection between zero and sign extetion
  assign #1 y = zero ? {16'b0, a} : {{16{a[15]}}, a};
endmodule

module flopr #(parameter WIDTH = 8)
              (input      logic             clk, reset,
               input      logic [WIDTH-1:0] d,
               output 	  logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= #1 0;
    else       q <= #1 d;
endmodule

// latch with clear
module floprc #(parameter WIDTH = 8)
              (input     logic             clk, reset, clear,
               input     logic [WIDTH-1:0] d,
               output	 logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset)      q <= #1 0;
    else if (clear) q <= #1 0;
    else            q <= #1 d;
endmodule

// latch with enable
module flopenr #(parameter WIDTH = 8)
                (input     logic             clk, reset,
                 input     logic             en,
                 input     logic [WIDTH-1:0] d,
                 output    logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if      (reset) q <= #1 0;
    else if (en)    q <= #1 d;
endmodule

// latch with enable and clear
module flopenrc #(parameter WIDTH = 8)
                 (input      logic             clk, reset,
                  input      logic             en, clear,
                  input      logic [WIDTH-1:0] d,
                  output     logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if      (reset) q <= #1 0;
    else if (clear) q <= #1 0;
    else if (en)    q <= #1 d;
endmodule

// 2 input multiplexer
module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1,
              input  logic             s,
              output logic [WIDTH-1:0] y);

  assign #1 y = s ? d1 : d0;
endmodule

// 3 input multiplexer
module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s,
              output logic [WIDTH-1:0] y);

  assign #1 y = s[1] ? d2 : (s[0] ? d1 : d0);
/*  always_comb
  begin
	$display("\n d0 = %h d1 = %h d2 = %h s = %b y = %");
  end*/
endmodule

/*
// 4 input multiplexer
module mux4 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2, d3,
              input  logic [2:0]       s,
              output logic [WIDTH-1:0] y);

  assign #1 y = s[2] ? d3 : (s[1] ? d2 : (s[0] ? d1 : d0));

  
endmodule

*/
