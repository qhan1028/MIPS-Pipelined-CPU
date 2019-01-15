module EXMEM
(
    clk_i,
    WB_i, M_i,
    ALU_output_i,
    fw2_i,
    reg_dst_i,

    WB_o, M_o,
    ALU_output_o,
    fw2_o,
    reg_dst_o
);

input           clk_i;
input   [1:0]   WB_i, M_i;
input   [31:0]  ALU_output_i, fw2_i;
input   [4:0]   reg_dst_i;

output  [1:0]   WB_o, M_o;
output  [31:0]  ALU_output_o, fw2_o;
output  [4:0]   reg_dst_o;

reg     WB_o, M_o, ALU_output_o, fw2_o, reg_dst_o;

always @(posedge clk_i) begin
    WB_o <= WB_i;
    M_o <= M_i;
    ALU_output_o <= ALU_output_i;
    fw2_o <= fw2_i;
    reg_dst_o <= reg_dst_i;
end

endmodule
