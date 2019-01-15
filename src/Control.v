module Control
(
    Op_i, 
    Jump_o,
    Branch_o,
    Control_o
);

/* Ports */
input   [5:0]   Op_i;
output          Jump_o;     /* j-type: 1, other: 0 */
output          Branch_o;   /* beq: 1, other: 0 */
output  [7:0]   Control_o;

wire            ALUSrc;     /* r-type beq: 0, other: 1 */
wire    [1:0]   ALUOp;      /* L/S add: 00, beq sub: 01, r-type: 11, ori: 10 */
wire            RegDst;     /* r-type: 1, other: 0 */
wire            MemRead;    /* lw: 1, other: 0 */
wire            MemtoReg;   /* lw: 1, other: 0 */
wire            MemWrite;   /* sw: 1, other: 0 */
wire            RegWrite;   /* r-type ori lw: 1, other: 0 */

/* Output Control */
assign  Jump_o      =   (Op_i == 6'b000010)? 1 : 0;
assign  Branch_o    =   (Op_i == 6'b000100)? 1 : 0;

// WB
assign  RegWrite    =   (Op_i == 6'b000000)? 1 :
                        (Op_i == 6'b001101)? 1 :
                        (Op_i == 6'b001000)? 1 :
                        (Op_i == 6'b100011)? 1 : 0;
assign  MemtoReg    =   (Op_i == 6'b100011)? 1 : 0;

// MEM
assign  MemRead     =   (Op_i == 6'b100011)? 1 : 0;
assign  MemWrite    =   (Op_i == 6'b101011)? 1 : 0;

// EX
assign  ALUSrc      =   (Op_i == 6'b000000)? 0 :
                        (Op_i == 6'b000100)? 0 : 1;
assign  ALUOp       =   (Op_i == 6'b000000)? 2'b11 :
                        (Op_i == 6'b001101)? 2'b10 :
                        (Op_i == 6'b000100)? 2'b01 : 2'b00;
assign  RegDst      =   (Op_i == 6'b000000)? 1 : 0;

/* Final output */
assign  Control_o   =   {RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, ALUOp, RegDst};

endmodule
