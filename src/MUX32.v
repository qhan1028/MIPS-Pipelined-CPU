module MUX32
(
    data0_i, data1_i,
    select_i,
    data_o
);

/* Ports */
input       [31:0]  data0_i, data1_i;
input               select_i;
output  reg [31:0]  data_o;

/* Multiplexer */
always @(*) begin
    if (select_i == 1'b1)
        data_o <= data1_i;
    else
        data_o <= data0_i;
end

endmodule
