/* DLX Processor TestBench-ECE 510 
 *
 * Copyright (c) 2013.
 *
 * Author:Manas KS, Nagarjun Hassan Ranganath		Rakesh Vasudevan, Vignesh Kumaragurubaran
 * Date:		13th June, 2013
 *
 * 	Description:
 * 	------------
 * 	This is he testbench of the DLX processor. The testbench does both Randomized and directed Testing. The instructions are randomized based on instruction type
 *  (i.e I-Type ,R-Type , J-Type) and Directed test bench uses a python script to convert the DLX code to its equivalent binary encoded value.The script is called f
 *  from the testbench
 */
`timescale 1ns/1ps
`include "DLXOpCodes.sv"
module DLXTestBench;
localparam DELAY = 5;
//Class with random variables and scoreboard for maintaining randomly generated values
class DLXScoreBoard;
  
  // Enumerated Random types.. imported from the DLXOpCodes Pasckage
  randc  RType register;
  randc JType jump;
  randc IType instruction; 
  //The rs ,rt,rd registers, immedate and jump address values
  randc bit[4:0] rs, rt,rd;
  randc bit[15:0] imm;
  randc bit [25:0] value;
  //A variable to select between R-Type ,I-Type and J-Type after randomization
  randc int selector;
  // To maintain history of the randomized registers
  bit [4:0] oldrs,oldrt,oldrd; 
  
  //Assosicative arrays for scoreboarding and maintaining counts of instruction types
  local int scoreboard1[RType];
  local int scoreboard2[IType];
  local bit scoreboard3[JType];
  
  // Constraints for instruction type distribution
  constraint r_dist{
      register dist {[ADD:ADDU]:/20 ,SUB:/20,[SUBU:SLT]:/60};}
  constraint i_dist{
      instruction dist {[BEQZ:SLTI]:/81, SW:/19};}
   //checking history for register randomization   
  constraint regallocation{oldrs!=rs;oldrs!=rt;oldrs!=rd;
                           oldrt!=rs;oldrt!=rt;oldrt!=rd;
                           oldrd!=rs;oldrd!=rt;oldrd!=rd;}
  //constraining jump address                         
  constraint jaddress{ value%4==0;value>0;value<6;}   
  //constraining between the Three types of instruction                                               
  constraint sel{selector>0;
                        selector <4;
                       
                  }              
  function new();
    //Initialize scoreboard
    register=register.first();
    while(1)
    begin
       scoreboard1[register]=0;
       if(register==register.last())
         break;
        register=register.next();
    end
    instruction=instruction.first();
    while(1)
    begin
       scoreboard2[instruction]=0;
       if(instruction==instruction.last())
         break;
        instruction=instruction.next();
    end
    jump=jump.first();
    while(1)
    begin
       scoreboard3[jump]=0;
       if(jump==jump.last())
         break;
        jump=jump.next();
    end  
  endfunction  
  
  //Function maintains instruction type count
  function void CountInstructionType(input logic[31:0] inst);
          int iflag=0;
          //check for R-type instruction first
          if(inst[31:26]=='0)
          begin  
             register=register.first();
             while(1)
             begin
               if(inst[5:0]==register)
                    scoreboard1[register]++;
               if(register==register.last())
                   break;
              register=register.next();     
            end      
          end
          else 
          begin
             instruction=instruction.first();
             while(1)
             begin
              if(inst[31:26]==instruction)
              begin
                    scoreboard2[instruction]++;
                    iflag=1;
              end
              if(instruction==instruction.last())
                   break;
              instruction=instruction.next();     
             end
             if(iflag==0)
             begin
               jump=jump.first();
               while(1)
               begin
                 if(inst[31:26]==jump)
                      scoreboard3[jump]++;
                           
                 if(jump==jump.last())
                   break;
                 jump=jump.next();     
                end
             end
           end                                                 
  endfunction:CountInstructionType
  
  //Display the statistics
  function void DisplayInstructionCount();
    $display("Randomization Statistics\n");
    $display("R-Type Stats\n");
    foreach(scoreboard1[i])
         $display(" Number of %s instructions tested: \t %d\n",i.name,scoreboard1[i]);
    $display("I-Type Stats\n");
    foreach(scoreboard2[i])
         $display(" Number of %s instructions tested: \t %d\n",i.name,scoreboard2[i]);
    $display("J-Type Stats\n");
    foreach(scoreboard3[i])
         $display(" Number of %s instructions tested: \t %d\n",i.name,scoreboard3[i]);
                      
  endfunction:DisplayInstructionCount  
  
  
  //Form instruction based on selector variable randomized
  function logic[31:0] formInstruction();
    unique case(selector)
    1:
      return {6'b000000,rs,rt,rd,5'b00000,register};//rtype
    2:
      return{instruction,rs,rt,imm};//itype
    3:
         return {jump,value};//jtype
    endcase  
  endfunction:formInstruction
  
  function void post_randomize();
     oldrs=rs;  
     oldrt=rt;
     oldrd=rd;
  endfunction  
endclass:DLXScoreBoard

DLXScoreBoard sb;
logic clk;
logic reset = 1'b0;
logic [31:0] inst;
initial
begin
clk = 1'b0;
forever #2.5 clk = ~clk;
end

//Initialize the top module
temptop DUT(.*);
logic [31:0] RAM [63:0];

initial
begin
 sb=new();
 reset = 1'b1;
 #DELAY
 reset = 1'b0;
 #DELAY

 for(int i=0;i<300;i++)
 begin  
  assert(sb.randomize());
  inst=sb.formInstruction();
  DUT.pminst.instr = inst;
  sb.CountInstructionType(inst);
  #DELAY;
 end
 sb.DisplayInstructionCount();

 //Call the python script for directed testing
 $system("python convertor.py");

 //Read the file generated by python script
 $readmemb("mem.dat",RAM);

 foreach(RAM[i])
 begin
   DUT.pminst.instr = RAM[i];
   #DELAY;
 end
 $finish;
end

final
begin
 //Print Register and Data Memory values for verification
 foreach(DUT.mipsinst.dp.rf.rfile[i])
  	$display("Register %d = %d [%h]",i,DUT.mipsinst.dp.rf.rfile[i],DUT.mipsinst.dp.rf.rfile[i]);
   $display("\n FINAL. PC = %h",DUT.pminst.pc);
 foreach(DUT.dmeminst.RAM[i])
	$display("RAM [%d] = %d [%h]",i,DUT.dmeminst.RAM[i],DUT.dmeminst.RAM[i]);
  $display("\n END OF SIMULATION");
end

endmodule:DLXTestBench
