module Shift_Left_Jump
(
	data_i,
	data_o,
);

/* Ports */
input	[25:0]	data_i;
output	[27:0]	data_o;

/* Shift left operation */
assign data_o = { data_i, 2'b00 };

endmodule
