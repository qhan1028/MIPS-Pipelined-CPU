module IDEX
(
	clk_i,
	WB_i, M_i, EX_i,
	pc_add_4_i,
	rdata1_i, rdata2_i,
	imm_extend_i,
	inst_i,

	WB_o, M_o, EX_o,
	rdata1_o, rdata2_o,
	imm_extend_o,
	inst_25_21_o, inst_20_16_o, inst_15_11_o
);

input			clk_i;
input	[1:0]	WB_i, M_i;
input	[3:0]	EX_i;
input	[31:0]	pc_add_4_i;
input	[31:0]	rdata1_i, rdata2_i;
input	[31:0]	imm_extend_i, inst_i;

output	[1:0]	WB_o, M_o;
output	[3:0]	EX_o;
output	[31:0]	pc_add_4_o;
output	[31:0]	rdata1_o, rdata2_o;
output	[31:0]	imm_extend_o;
output	[4:0]	inst_25_21_o, inst_20_16_o, inst_15_11_o;

reg		WB_o, M_o, EX_o, pc_add_4_o;
reg		rdata1_o, rdata2_o, imm_extend_o;
reg		inst_15_11_o, inst_20_16_o, inst_25_21_o;

always @(posedge clk_i) begin
	pc_add_4_o <= pc_add_4_i;
	rdata1_o <= rdata1_i;
	rdata2_o <= rdata2_i;
	imm_extend_o <= imm_extend_i;
	inst_25_21_o <= inst_i[25:21];
	inst_20_16_o <= inst_i[20:16];
	inst_15_11_o <= inst_i[15:11];
	WB_o <= WB_i;
	M_o <= M_i;
	EX_o <= EX_i;
end

endmodule
