module Registers
(
	clk_i,
	RS_addr_i,
	RT_addr_i,
	RD_addr_i, 
	RD_data_i,
	RegWrite_i, 
	RS_data_o, 
 	RT_data_o 
);

/* Ports */
input			clk_i;
input	[4:0]	RS_addr_i;
input	[4:0]	RT_addr_i;
input	[4:0]	RD_addr_i;
input	[31:0]	RD_data_i;
input			RegWrite_i;
output	[31:0]	RS_data_o; 
output	[31:0]	RT_data_o;

/* Register File */
reg		[31:0]	register	[0:31];

/* Read Data */
assign	RS_data_o = register[RS_addr_i];
assign	RT_data_o = register[RT_addr_i];

/* Write Data */
always @(posedge clk_i) begin
	if(RegWrite_i)
		register[RD_addr_i] <= RD_data_i;
end

endmodule 
