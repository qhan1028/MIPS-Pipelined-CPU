module ALU_Control
(
	funct_i,
	ALUOp_i,
	ALUCtrl_o
);

/* Ports */
input	[5:0]	funct_i;
input	[1:0]	ALUOp_i;	/* L/S add: 00, beq sub: 01, r-type: 11, ori: 10 */
output	[2:0]	ALUCtrl_o;	/* 000: and, 001: or, 010: add, 011: mul, 110: sub, 111: slt */

/* Output control */
assign	ALUCtrl_o =	(ALUOp_i == 2'b00)?		3'b010 :	/* add */
					(ALUOp_i == 2'b01)?		3'b110 :	/* sub */
					(ALUOp_i == 2'b10)?		3'b001 :	/* or  */
					(funct_i == 6'b100000)? 3'b010 :	/* add */
					(funct_i == 6'b100010)?	3'b110 :	/* sub */
					(funct_i == 6'b100100)?	3'b000 :	/* and */
					(funct_i == 6'b100101)?	3'b001 :	/* or  */
					(funct_i == 6'b011000)?	3'b011 :	/* mul */
					(funct_i == 6'b101010)?	3'b111 :	/* slt */
											3'b010 ;	/* default: add */

endmodule

