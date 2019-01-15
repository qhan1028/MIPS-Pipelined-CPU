module IFID
(
    clk_i,
    flush_i, hazard_i,
    pc_add_4_i, pc_add_4_o,
    inst_i, inst_o
);

/* Ports */
input           clk_i;
input           flush_i, hazard_i;
input   [31:0]  pc_add_4_i, inst_i;
output  [31:0]  pc_add_4_o, inst_o;

reg             pc_add_4_o, inst_o;

always @(posedge clk_i) begin
    if(flush_i) begin
        pc_add_4_o <= 0;
        inst_o <= 0;
    end
    else if(hazard_i == 1)begin
        pc_add_4_o <= pc_add_4_o;
        inst_o <= inst_o;
    end
    else begin
        pc_add_4_o <= pc_add_4_i;
        inst_o <= inst_i;
    end
end

endmodule
