interface proc_memory;

//inputs and outputs
logic memwrite;
logic [31:0] writedata, dataadr, pc, instr, readdata;

//the processor side of the interface
modport proc_if ( output memwrite,
		  output writedata,
		  output dataadr,
		  output pc,
		  input instr,
		  input readdata );

//the instruction memory side of the interface
modport imem_if ( input pc,
		  output instr );

//the data memory side of the interface
modport dmem_if ( input memwrite,
		  input writedata,
		  input dataadr,
		  output readdata );

endinterface
