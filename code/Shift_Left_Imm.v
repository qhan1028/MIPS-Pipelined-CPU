module Shift_Left_Imm
(
	data_i,
	data_o,
);

/* Ports */
input	[31:0]	data_i;
output	[31:0]	data_o;

/* Shift left operation */
assign data_o = { data_i[29:0], 2'b00 };

endmodule
