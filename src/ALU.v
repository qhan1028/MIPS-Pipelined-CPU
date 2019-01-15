module ALU
(
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o
);

/* Ports */
input   [31:0]  data1_i, data2_i;
input   [2:0]   ALUCtrl_i;
output  [31:0]  data_o;

reg     [31:0]  result;

/* Calculations */
always @(*) begin
    case (ALUCtrl_i)
        3'b000: result = data1_i & data2_i;
        3'b001: result = data1_i | data2_i;
        3'b010: result = data1_i + data2_i;
        3'b110: result = data1_i - data2_i;
        3'b011: result = data1_i * data2_i;
        default: result = 32'd0;
    endcase
end

assign  data_o = result;

endmodule
