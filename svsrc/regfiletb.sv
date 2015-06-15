`include "mipspkg.sv"
`timescale 1ns/1ps

module regfileTestbench;

logic clk;
logic w_enable;
logic [REGADDRSIZE-1:0] r_addr1;
logic [REGADDRSIZE-1:0] r_addr2;
logic [REGADDRSIZE-1:0] w_addr1;
logic [REGSIZE-1:0] w_data1;
logic [REGSIZE-1:0] r_data1;
logic [REGSIZE-1:0] r_data2;

integer intregfile[31:0];
localparam DELAY = 5;

regfile regfileinst(.*);

class Registers;

rand integer intraddr1;
rand integer intraddr2;
rand integer intwaddr1;
rand integer intwdata1;
rand logic clk;
`
constraint c_range {
	intraddr1 inside {[0:31]};
	intraddr2 inside {[0:31]};
	intwaddr1 inside {[0:31]};
	intwdata1 inside {[0:426400]};
	}

function void  loadaddrdata();
	r_addr1 = intraddr1;
	r_addr2 = intraddr2;
	w_addr1 = intwaddr1;
	w_data1 = intwdata1;
endfunction

function void regupdate();
	intregfile[intwaddr1] = intwdata1;
endfunction

function void readandverify();
	for(integer i=0 ; i < 32 ; i++)
	begin
		if(intregfile[i] != regfileinst.rfile[i])
		$display("\n intreg = %h Actual Register Value = %h",intregfile[i],regfileinst.rfile[i]);
	end
endfunction

endclass

initial
begin
clk = 1'b0;
forever #2.5 clk = ~clk;
end

initial
begin

Registers r;
r = new();
for(int i=0 ; i<640 ; i++)
begin
w_enable = 1'b1;
assert(r.randomize());
r.loadaddrdata();
r.regupdate();
#DELAY
r.readandverify();
end

$display("\End of Testbench");

$stop;
end

endmodule
