module Adder
(
	data1_i,
	data2_i,
	data_o
);

/* Ports */
input	[31:0]	data1_i, data2_i;
output	[31:0]	data_o;

/* Output */
assign	data_o = data1_i + data2_i;

endmodule
