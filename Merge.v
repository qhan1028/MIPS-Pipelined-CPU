module Merge
(
	data1_i,
	data2_i,
	data_o
);

/* Ports */
input	[27:0]	data1_i;
input	[3:0]	data2_i;
output	[31:0]	data_o;

/* Merge Operation */
assign	data_o = { data2_i, data1_i };

endmodule
