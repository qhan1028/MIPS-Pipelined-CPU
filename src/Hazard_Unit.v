module Hazard_Unit
(
    IDEX_MemRead_i,
    IDEX_RT_i,
    IFID_RS_i,
    IFID_RT_i,
    IFID_hazard_o,
    hazard_pc_o,
    hazard_MUX_o
);

/* Ports */
input               IDEX_MemRead_i;
input       [4:0]   IDEX_RT_i, IFID_RS_i, IFID_RT_i;
output  reg         IFID_hazard_o, hazard_pc_o, hazard_MUX_o;

always @(*) begin
    if (IDEX_MemRead_i && (IDEX_RT_i == IFID_RT_i || IDEX_RT_i == IFID_RS_i)) begin
        IFID_hazard_o <= 1;
        hazard_pc_o <= 1;
        hazard_MUX_o <= 1;
    end
    else begin
        IFID_hazard_o <= 0;
        hazard_pc_o <= 0;
        hazard_MUX_o <= 0;
    end
end

endmodule
