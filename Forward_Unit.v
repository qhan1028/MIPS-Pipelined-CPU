module Forward_Unit
(
	EX_RS_addr_i, EX_RT_addr_i,
	MEM_RD_addr_i, WB_RD_addr_i,
	MEM_RegWr_i, WB_RegWr_i,
	fw1_ctrl_o, fw2_ctrl_o
);

/* Ports */
input	[4:0]	EX_RS_addr_i, EX_RT_addr_i;
input	[4:0]	MEM_RD_addr_i, WB_RD_addr_i;
input			MEM_RegWr_i, WB_RegWr_i;
output	[1:0]	fw1_ctrl_o, fw2_ctrl_o;

reg				fw1_ctrl_o, fw2_ctrl_o;

always @(*) begin
	if (MEM_RegWr_i && MEM_RD_addr_i != 5'd0 && MEM_RD_addr_i == EX_RS_addr_i)
		fw1_ctrl_o <= 2'b10;
	else if (WB_RegWr_i && WB_RD_addr_i != 5'd0 && WB_RD_addr_i == EX_RS_addr_i)
		fw1_ctrl_o <= 2'b01;
	else
		fw1_ctrl_o <= 2'b00;

	if (WB_RegWr_i && WB_RD_addr_i != 5'd0 && WB_RD_addr_i == EX_RT_addr_i)
		fw2_ctrl_o <= 2'b01;
	else if (MEM_RegWr_i && MEM_RD_addr_i != 5'd0 && MEM_RD_addr_i == EX_RT_addr_i)
		fw2_ctrl_o <= 2'b10;
	else
		fw2_ctrl_o <= 2'b00;
end

endmodule
