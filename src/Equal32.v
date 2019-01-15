module Equal32
(
    data1_i, data2_i,
    data_o
);

input   [31:0]  data1_i, data2_i;
output  reg     data_o;

always@(data1_i or data2_i) begin
    if(data1_i==data2_i)
        data_o = 1;
    else
        data_o = 0;
end

endmodule
