`define CYCLE_TIME 50            
`define NODEBUG

module TestBench;

reg				Clk;
reg				Start;
reg				Reset;	
integer			i, outfile, counter;
integer			stall, flush;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
	.rst_i	(Reset),
    .start_i(Start)
);
  
initial begin
    counter = 0;
    stall = 0;
    flush = 0;
    
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.Data_Memory.memory[i] = 8'b0;
    end    
        
    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end
    
    // Load instructions into instruction memory
    $readmemb("instruction.txt", CPU.Instruction_Memory.memory);
    
    // Open output file
    outfile = $fopen("output.txt") | 1;
    
    // Set Input n into data memory at 0x00
    CPU.Data_Memory.memory[0] = 8'h5;       // n = 5 for example
    
    Clk = 1;
    Reset = 0;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    Reset = 1;
    Start = 1;

end
  
always@(posedge Clk) begin
    if(counter == 30)    // stop after 30 cycles
        $finish;

    // put in your own signal to count stall and flush
    if(CPU.Hazard_Unit.hazard_MUX_o == 1 && CPU.Control.Jump_o == 0 && CPU.Control.Branch_o == 0) stall = stall + 1;
    if(CPU.OR.data_o == 1) flush = flush + 1;  

    // print PC
	//$display("\n=========== Print PC ==========");	
    $fdisplay(outfile, "cycle = %d, Start = %1d, Stall = %1d, Flush = %1d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);
	
	// print modules
`ifdef	DEBUG
	$display("======== Print Modules ========\n= Cycle: %2d", counter);	
	$display("Add_4: data1_i = %5d, data2_i = %5d, data_o = %5d",
        	CPU.Add_4.data1_i, CPU.Add_4.data2_i, CPU.Add_4.data_o);

    $display("MUX_isBeq: select_i = %d, data0_i = %5d, data1_i = %5d, data_o = %5d",
        	CPU.MUX_isBeq.select_i, CPU.MUX_isBeq.data0_i, CPU.MUX_isBeq.data1_i, CPU.MUX_isBeq.data_o);
	
    $display("MUX_isJump: select_i = %d, data0_i = %5d, data1_i = %5d, data_o = %5d",
        	CPU.MUX_isJump.select_i, CPU.MUX_isJump.data0_i, CPU.MUX_isJump.data1_i, CPU.MUX_isJump.data_o);
	
	$display("AND: data1_i = %d, data2_i = %d, data_o = %d", CPU.AND.data1_i, CPU.AND.data2_i, CPU.AND.data_o);

	$display("\n= Cycle: %2d\n= IF/ID: pc_add_4_i = %d, inst_i = %b,\n\t pc_add_4_o = %d, inst_o = %b, flush_i = %d",
			counter-1,
			CPU.IFID.pc_add_4_i, CPU.IFID.inst_i, CPU.IFID.pc_add_4_o, CPU.IFID.pc_add_4_o, CPU.IFID.flush_i);

    $display("Control: Op_i = %b,\n\t RegDst = %b, Jump = %b, Branch = %b, MemRead = %b, MemtoReg = %b,\n\t ALUOp = %b, MemWrite = %b, ALUSrc = %b, RegWrite = %b",
			CPU.Control.Op_i, CPU.Control.RegDst, CPU.Control.Jump_o, CPU.Control.Branch_o, CPU.Control.MemRead,
			CPU.Control.MemtoReg, CPU.Control.ALUOp, CPU.Control.MemWrite, CPU.Control.ALUSrc, CPU.Control.RegWrite);
	
	$display("Add_Branch: data1_i = %d, data2_i = %d, data_o = %d",
        	CPU.Add_Branch.data1_i, CPU.Add_Branch.data2_i, CPU.Add_Branch.data_o);
	
    $display("MUX_RegDst: select_i = %d, data0_i = %d, data1_i = %d, data_o = %d",
        	CPU.MUX_RegDst.select_i, CPU.MUX_RegDst.data0_i, CPU.MUX_RegDst.data1_i, CPU.MUX_RegDst.data_o);

    $display("Registers: RSaddr_i = %5d, RTaddr_i = %5d, RDaddr_i = %5d, RSdata_o = %5d, RTdata_o = %5d, RDdata_i = %5d", 
        	CPU.Registers.RSaddr_i, CPU.Registers.RTaddr_i, CPU.Registers.RDaddr_i, CPU.Registers.RSdata_o, CPU.Registers.RTdata_o,
			CPU.Registers.RDdata_i);
    
	$display("\n= Cycle: %2d\n= ID/EX: WB_i = %b, M_i = %b, EX_i = %b, pc_add_4_i = %5d, rdata1_i = %5d, rdata2_i = %5d,\n\t imm_extend_i = %b, inst_i = %b\n\t WB_o = %b, M_o = %b, EX_o = %b, pc_add_4_o =    XX, rdata1_o = %5d, rdata2_o = %5d,\n\t imm_extend_o = %b, 25_21 = %b, 20_16 = %b, 15_11 = %b",
			counter-2,
			CPU.IDEX.WB_i, CPU.IDEX.M_i, CPU.IDEX.EX_i, CPU.IDEX.pc_add_4_i, CPU.IDEX.rdata1_i, CPU.IDEX.rdata2_i,
			CPU.IDEX.imm_extend_i, CPU.IDEX.inst_i,
			CPU.IDEX.WB_o, CPU.IDEX.M_o, CPU.IDEX.EX_o, CPU.IDEX.rdata1_o, CPU.IDEX.rdata2_o,
			CPU.IDEX.imm_extend_o, CPU.IDEX.inst_25_21_o, CPU.IDEX.inst_20_16_o, CPU.IDEX.inst_15_11_o);

	$display("Forward_Unit: EX_RSaddr_i = %5d, EX_RTaddr_i = %5d, MEM_RDaddr_i = %5d, WB_RDaddr_i = %5d,\n\t      MEM_RegWr_i = %d, WB_RegWr_i = %d, fw1_ctrl_o = %b, fw2_ctrl_o = %b", 
			CPU.Forward_Unit.EX_RSaddr_i, CPU.Forward_Unit.EX_RTaddr_i, CPU.Forward_Unit.MEM_RDaddr_i, CPU.Forward_Unit.WB_RDaddr_i,
			CPU.Forward_Unit.MEM_RegWr_i, CPU.Forward_Unit.WB_RegWr_i, CPU.Forward_Unit.fw1_ctrl_o, CPU.Forward_Unit.fw2_ctrl_o);

    $display("MUX_Forward1: select_i = %b, data0_i = %5d, data1_i = %5d, data2_i = %5d, data_o = %5d",
        	CPU.MUX_Forward1.select_i, CPU.MUX_Forward1.data0_i, CPU.MUX_Forward1.data1_i,CPU.MUX_Forward1.data2_i, CPU.MUX_Forward1.data_o);

    $display("MUX_Forward2: select_i = %b, data0_i = %5d, data1_i = %5d, data2_i = %5d, data_o = %5d",
        	CPU.MUX_Forward2.select_i, CPU.MUX_Forward2.data0_i, CPU.MUX_Forward2.data1_i, CPU.MUX_Forward2.data2_i, CPU.MUX_Forward2.data_o);

    $display("MUX_ALUSrc:   select_i = %2b, data0_i = %5d, data1_i = %5d, data_o = %5d",
        	CPU.MUX_ALUSrc.select_i, CPU.MUX_ALUSrc.data0_i, CPU.MUX_ALUSrc.data1_i,  CPU.MUX_ALUSrc.data_o);

    $display("ALU_Control:  funct_i = %b, ALUOp_i = %b, ALUCtrl_o = %b",
        	CPU.ALU_Control.funct_i, CPU.ALU_Control.ALUOp_i, CPU.ALU_Control.ALUCtrl_o);

    $display("ALU: ALUCtrl_i = %b, data1_i = %d, data2_i = %d, data_o = %d\n",
        	CPU.ALU.ALUCtrl_i, CPU.ALU.data1_i, CPU.ALU.data2_i, CPU.ALU.data_o);

	$display("= Cycle: %2d\n= EX/MEM: reg_dst_i = %5d, reg_dst_o = %5d",
			counter-3,
			CPU.EXMEM.reg_dst_i, CPU.EXMEM.reg_dst_o);

    $display("Data_Memory: addr_i = %5d, wdata_i = %5d, MemRead_i = %d, MemWrite_i = %d, rdata_o = %5d",
        	CPU.Data_Memory.addr_i, CPU.Data_Memory.wdata_i, CPU.Data_Memory.MemRead_i, CPU.Data_Memory.MemWrite_i, 
			CPU.Data_Memory.rdata_o);

	$display("\n= Cycle: %2d\n= MEM/WB: reg_dst_i = %5d, reg_dst_o = %5d",
			counter-4, CPU.MEMWB.reg_dst_i, CPU.MEMWB.reg_dst_o);
 
    $display("MUX_WrDataSrc: select_i = %5d, data0_i = %d, data1_i = %5d, data_o = %5d\n",
        	CPU.MUX_WrDataSrc.select_i, CPU.MUX_WrDataSrc.data0_i, CPU.MUX_WrDataSrc.data1_i, CPU.MUX_WrDataSrc.data_o);
`endif
	/* Print Registers */
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "R0(r0) = %d, R8 (t0) = %d, R16(s0) = %d, R24(t8) = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "R1(at) = %d, R9 (t1) = %d, R17(s1) = %d, R25(t9) = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "R2(v0) = %d, R10(t2) = %d, R18(s2) = %d, R26(k0) = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "R3(v1) = %d, R11(t3) = %d, R19(s3) = %d, R27(k1) = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "R4(a0) = %d, R12(t4) = %d, R20(s4) = %d, R28(gp) = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "R5(a1) = %d, R13(t5) = %d, R21(s5) = %d, R29(sp) = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "R6(a2) = %d, R14(t6) = %d, R22(s6) = %d, R30(s8) = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "R7(a3) = %d, R15(t7) = %d, R23(s7) = %d, R31(ra) = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);
 
    // print Data Memory
    $fdisplay(outfile, "Data Memory: 0x00 = %d", {CPU.Data_Memory.memory[3] , CPU.Data_Memory.memory[2] , CPU.Data_Memory.memory[1] , CPU.Data_Memory.memory[0] });
    $fdisplay(outfile, "Data Memory: 0x04 = %d", {CPU.Data_Memory.memory[7] , CPU.Data_Memory.memory[6] , CPU.Data_Memory.memory[5] , CPU.Data_Memory.memory[4] });
    $fdisplay(outfile, "Data Memory: 0x08 = %d", {CPU.Data_Memory.memory[11], CPU.Data_Memory.memory[10], CPU.Data_Memory.memory[9] , CPU.Data_Memory.memory[8] });
    $fdisplay(outfile, "Data Memory: 0x0c = %d", {CPU.Data_Memory.memory[15], CPU.Data_Memory.memory[14], CPU.Data_Memory.memory[13], CPU.Data_Memory.memory[12]});
    $fdisplay(outfile, "Data Memory: 0x10 = %d", {CPU.Data_Memory.memory[19], CPU.Data_Memory.memory[18], CPU.Data_Memory.memory[17], CPU.Data_Memory.memory[16]});
    $fdisplay(outfile, "Data Memory: 0x14 = %d", {CPU.Data_Memory.memory[23], CPU.Data_Memory.memory[22], CPU.Data_Memory.memory[21], CPU.Data_Memory.memory[20]});
    $fdisplay(outfile, "Data Memory: 0x18 = %d", {CPU.Data_Memory.memory[27], CPU.Data_Memory.memory[26], CPU.Data_Memory.memory[25], CPU.Data_Memory.memory[24]});
    $fdisplay(outfile, "Data Memory: 0x1c = %d", {CPU.Data_Memory.memory[31], CPU.Data_Memory.memory[30], CPU.Data_Memory.memory[29], CPU.Data_Memory.memory[28]});
	
    $fdisplay(outfile, "\n");
  
    counter = counter + 1;
    
end

endmodule
