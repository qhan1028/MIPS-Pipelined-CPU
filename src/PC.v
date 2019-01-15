module PC
(
    clk_i,
    rst_i,
    start_i,
    pc_i,
    hazard_i,
    pc_o
);

/* Ports */
input               clk_i;
input               rst_i;
input               start_i;
input   [31:0]      pc_i;
input               hazard_i;
output  [31:0]      pc_o;

/* Wires & Registers */
reg     [31:0]      pc_o;

always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i)
        pc_o <= 32'b0;
    else if (hazard_i)
        pc_o <= pc_o;
    else begin
        if(start_i)
            pc_o <= pc_i;
        else
            pc_o <= pc_o;
    end
end

endmodule
