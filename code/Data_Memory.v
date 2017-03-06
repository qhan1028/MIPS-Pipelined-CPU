module Data_Memory
(
	clk_i,
	addr_i,
	wdata_i,
	MemWrite_i,
	MemRead_i,
	rdata_o
);

/* Ports */
input			clk_i;
input	[31:0]	addr_i;
input	[31:0]	wdata_i;
input			MemWrite_i, MemRead_i;
output	[31:0]	rdata_o;

/* Data Memory */
reg		[7:0]	memory	[0:31];
assign	rdata_o = (MemRead_i)? memory[addr_i] : 0;

always @(posedge clk_i) begin
	if (MemWrite_i)
		memory[addr_i] <= wdata_i[7:0];
end

endmodule
