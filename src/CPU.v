module CPU
(
    clk_i, 
    rst_i,
    start_i
);

/* Ports */
input           clk_i;
input           rst_i;
input           start_i;

/******************** IF ********************/
PC PC (                                 /* Program Counter */
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (),
    .pc_o       (pc_output),
    .hazard_i()
);

Instruction_Memory Instruction_Memory (
    .addr_i     (pc_output), 
    .instr_o    (IFID.inst_i)
);

wire    [31:0]  pc_output;              /* current PC */
wire    [31:0]  pc_add_4;               /* PC + 4 */
Adder Add_4 (
    .data1_i    (pc_output),
    .data2_i    (32'd4),
    .data_o     (pc_add_4)
);

wire    [31:0]  isBeq_output;
MUX32 MUX_isBeq (                       /* MUX 1 */
    .data0_i    (pc_add_4),
    .data1_i    (),
    .select_i   (isBeq),
    .data_o     (isBeq_output)
);

Shift_Left_Jump Shift_Left_Jump (       /* Shift Left 2 Bits */
    .data_i     (IFID_inst[25:0]),
    .data_o     (Merge.data1_i)
);

Merge Merge (                           /* Jump Address Merger */
    .data1_i    (),
    .data2_i    (isBeq_output[31:28]),
    .data_o     (MUX_isJump.data1_i)
);

MUX32 MUX_isJump (                      /* MUX 2 */
    .data0_i    (isBeq_output),
    .data1_i    (),
    .select_i   (ctrl_jump),
    .data_o     (PC.pc_i)
);

OR OR (
    .data1_i    (ctrl_jump),
    .data2_i    (isBeq),
    .data_o     (IFID.flush_i)
);  

/******************* IFID *******************/
wire    [31:0]  IFID_pc_add_4;          /* IFID pc to Add_Branch, IDEX */
wire    [31:0]  IFID_inst;              /* IFID inst to multiple unit in ID */
IFID IFID (
    .clk_i      (clk_i),
    .pc_add_4_i (pc_add_4),
    .inst_i     (),
    .flush_i    (),
    .hazard_i   (),
    .pc_add_4_o (IFID_pc_add_4),
    .inst_o     (IFID_inst)
);

/******************** ID ********************/
Hazard_Unit Hazard_Unit (
    .IDEX_MemRead_i (IDEX_M[1]),
    .IDEX_RT_i      (IDEX_inst_20_16),
    .IFID_RS_i      (IFID_inst[25:21]),
    .IFID_RT_i      (IFID_inst[20:16]),
    .IFID_hazard_o  (IFID.hazard_i),
    .hazard_pc_o    (PC.hazard_i),
    .hazard_MUX_o   (MUX_CtrlSrc.select_i)
);

wire            ctrl_jump;              /* Control to MUX 2, OR */
Control Control (
    .Op_i       (IFID_inst[31:26]),
    .Jump_o     (ctrl_jump),
    .Branch_o   (AND.data2_i),
    .Control_o  (MUX_CtrlSrc.data0_i)
);

wire    [7:0]   ctrl_mux;               /* MUX 8 to IDEX */
MUX8 MUX_CtrlSrc (                      /* MUX 8 */
    .data0_i    (),
    .data1_i    (8'd0),
    .select_i   (),
    .data_o     (ctrl_mux)
);

wire            isBeq;                  /* AND to MUX 1, OR */
AND AND (
    .data1_i    (),
    .data2_i    (),
    .data_o     (isBeq)
);

wire    [31:0]  imm_extend;             /* Sign Extend to Shift_Left_Imm, IDEX */
Sign_Extend Sign_Extend (
    .data_i     (IFID_inst[15:0]),
    .data_o     (imm_extend)
);

Shift_Left_Imm Shift_Left_Imm (         /* Shift Left 2 Bits */
    .data_i     (imm_extend),
    .data_o     (Add_Branch.data1_i)
);

Adder Add_Branch (
    .data1_i    (),
    .data2_i    (IFID_pc_add_4),
    .data_o     (MUX_isBeq.data1_i)
);

wire    [31:0]  RS_data;                /* RS data to RS_eq_RT, IDEX */
wire    [31:0]  RT_data;                /* RT data to RS_eq_RT, IDEX */
Registers Registers (
    .clk_i      (clk_i),
    .RS_addr_i  (IFID_inst[25:21]),
    .RT_addr_i  (IFID_inst[20:16]),
    .RD_addr_i  (MEMWB_RD_addr), 
    .RD_data_i  (WB_result),
    .RegWrite_i (MEMWB_WB[1]), 
    .RS_data_o  (RS_Src.data0_i), 
    .RT_data_o  (RT_Src.data0_i) 
);

/* WB, read register hazard begin */
Equal5 RS_eq_RD (
    .data1_i    (IFID_inst[25:21]),
    .data2_i    (MEMWB_RD_addr),
    .data_o     (AND_RS.data1_i)
);

Equal5 RT_eq_RD (
    .data1_i    (IFID_inst[20:16]),
    .data2_i    (MEMWB_RD_addr),
    .data_o     (AND_RT.data1_i)
);

AND AND_RS (
    .data1_i    (),
    .data2_i    (MEMWB_WB[1]),
    .data_o     (RS_Src.select_i)
);

AND AND_RT (
    .data1_i    (),
    .data2_i    (MEMWB_WB[1]),
    .data_o     (RT_Src.select_i)
);

MUX32 RS_Src (                          /* MUX 9 */
    .data0_i    (),
    .data1_i    (WB_result),
    .select_i   (),
    .data_o     (RS_data)
);

MUX32 RT_Src (                          /* MUX 10 */
    .data0_i    (),
    .data1_i    (WB_result),
    .select_i   (),
    .data_o     (RT_data)
);
/* WB, read register hazard end */

Equal32 RS_eq_RT (
    .data1_i    (RS_data),
    .data2_i    (RT_data),
    .data_o     (AND.data1_i)
);

/******************* IDEX *******************/
wire    [1:0]   IDEX_M;                 /* IDEX Memory Control to Hazard_Unit, EXMEM */
wire    [3:0]   IDEX_EX;                /* IDEX Execution Control to MUX 4, ALU_Control, MUX 3 */
wire    [31:0]  IDEX_imm_extend;        /* Imm Extend Value to MUX 4, ALU_Control */
wire    [4:0]   IDEX_inst_20_16;        /* RT to MUX 3, Forward_Unit, Hazard_Unit */
IDEX IDEX (
    .clk_i      (clk_i),
    .WB_i       (ctrl_mux[7:6]),
    .M_i        (ctrl_mux[5:4]),
    .EX_i       (ctrl_mux[3:0]),
    .pc_add_4_i (IFID_pc_add_4),
    .rdata1_i   (RS_data),
    .rdata2_i   (RT_data),
    .imm_extend_i(imm_extend),
    .inst_i     (IFID_inst),

    .WB_o       (EXMEM.WB_i),
    .M_o        (IDEX_M),
    .EX_o       (IDEX_EX),
    .rdata1_o   (MUX_Forward1.data0_i),
    .rdata2_o   (MUX_Forward2.data0_i),
    .imm_extend_o(IDEX_imm_extend),
    .inst_25_21_o(Forward_Unit.EX_RS_addr_i),
    .inst_20_16_o(IDEX_inst_20_16),
    .inst_15_11_o(MUX_RegDst.data1_i)
);

/******************* EX *********************/
Forward_Unit Forward_Unit (
    .EX_RS_addr_i   (),
    .EX_RT_addr_i   (IDEX_inst_20_16),
    .MEM_RD_addr_i  (EXMEM_RD_addr), 
    .WB_RD_addr_i   (MEMWB_RD_addr),
    .MEM_RegWr_i    (EXMEM_WB[1]),
    .WB_RegWr_i     (MEMWB_WB[1]),
    .fw1_ctrl_o     (MUX_Forward1.select_i),
    .fw2_ctrl_o     (MUX_Forward2.select_i)
);

MUX32_3 MUX_Forward1 (                  /* MUX 6 */
    .data0_i    (),
    .data1_i    (WB_result),
    .data2_i    (EXMEM_ALU_output),
    .select_i   (),
    .data_o     (ALU.data1_i)
);

wire    [31:0]  fw2_output;             /* MUX 7 to MUX 4, EXMEM */
MUX32_3 MUX_Forward2 (                  /* MUX 7 */
    .data0_i    (),
    .data1_i    (WB_result),
    .data2_i    (EXMEM_ALU_output),
    .select_i   (),
    .data_o     (fw2_output)
);

MUX32 MUX_ALUSrc(                       /* MUX 4 */
    .data0_i    (fw2_output),
    .data1_i    (IDEX_imm_extend),
    .select_i   (IDEX_EX[3]),
    .data_o     (ALU.data2_i)
);

ALU_Control ALU_Control (
    .funct_i    (IDEX_imm_extend[5:0]),
    .ALUOp_i    (IDEX_EX[2:1]),
    .ALUCtrl_o  (ALU.ALUCtrl_i)
);

ALU ALU (
    .data1_i    (),
    .data2_i    (),
    .ALUCtrl_i  (),
    .data_o     (EXMEM.ALU_output_i)
);

MUX5 MUX_RegDst (                       /* MUX 3 */
    .data0_i    (IDEX_inst_20_16),
    .data1_i    (),
    .select_i   (IDEX_EX[0]),
    .data_o     (EXMEM.reg_dst_i)
);

/******************* EXMEM ******************/
wire    [1:0]   EXMEM_WB;               /* EXMEM Write Back Control to MEMWB */
wire    [1:0]   EXMEM_M;                /* EXMEM Memory Control to Data_Memory */
wire    [31:0]  EXMEM_ALU_output;       /* ALU output to Data_Memory, MUX 6, MUX 7 */
wire    [4:0]   EXMEM_RD_addr;          /* RD address to MEMWB, Forward Unit */
EXMEM EXMEM (
    .clk_i      (clk_i),
    .WB_i       (),
    .M_i        (IDEX_M),
    .ALU_output_i(),
    .fw2_i      (fw2_output),
    .reg_dst_i  (),

    .WB_o       (EXMEM_WB),
    .M_o        (EXMEM_M),
    .ALU_output_o(EXMEM_ALU_output),
    .fw2_o      (Data_Memory.wdata_i),
    .reg_dst_o  (EXMEM_RD_addr)
);

/******************* MEM ********************/
Data_Memory Data_Memory(
    .clk_i      (clk_i),
    .addr_i     (EXMEM_ALU_output),
    .wdata_i    (),
    .MemWrite_i (EXMEM_M[0]),
    .MemRead_i  (EXMEM_M[1]),
    .rdata_o    (MEMWB.rdata_i)
);

/****************** MEMWB *******************/
wire    [1:0]   MEMWB_WB;               /* MEMWB Write Back Control to MUX 5 */
wire    [4:0]   MEMWB_RD_addr;          /* RD address to Registers, Forward_Unit, RS_eq_RD, RT_eq_ED */
MEMWB MEMWB (
    .clk_i      (clk_i),
    .WB_i       (EXMEM_WB),
    .rdata_i    (),
    .ALU_output_i(EXMEM_ALU_output),
    .reg_dst_i  (EXMEM_RD_addr),

    .WB_o       (MEMWB_WB),
    .rdata_o    (MUX_WrDataSrc.data1_i),
    .ALU_output_o(MUX_WrDataSrc.data0_i),
    .reg_dst_o  (MEMWB_RD_addr)
);

/******************** WB ********************/
wire    [31:0]  WB_result;              /* Write Back result to Registers, MUX 6, MUX 7, MUX 9, MUX 10 */
MUX32 MUX_WrDataSrc(                    /* MUX 5 */
    .data0_i    (),
    .data1_i    (),
    .select_i   (MEMWB_WB[0]),
    .data_o     (WB_result)
);

endmodule
