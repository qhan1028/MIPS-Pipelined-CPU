module AND 
(
	data1_i, data2_i,
	data_o
);

/* Ports */
input		data1_i, data2_i;
output		data_o;

/* AND operation */
assign	data_o = (data1_i && data2_i)? 1 : 0;

endmodule
