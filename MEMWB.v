module MEMWB
(
	clk_i,
	WB_i,
	rdata_i, ALU_output_i,
	reg_dst_i,

	WB_o,
	rdata_o, ALU_output_o,
	reg_dst_o
);

input			clk_i;
input	[1:0]	WB_i;
input	[31:0]	rdata_i, ALU_output_i;
input	[4:0]	reg_dst_i;
output			clk_o;
output	[1:0]	WB_o;
output	[31:0]	rdata_o, ALU_output_o;
output	[4:0]	reg_dst_o;

reg		WB_o, rdata_o, ALU_output_o, reg_dst_o;
always @(posedge clk_i) begin
	WB_o <= WB_i;
	rdata_o <= rdata_i;
	ALU_output_o <= ALU_output_i;
	reg_dst_o <= reg_dst_i;
end

endmodule
