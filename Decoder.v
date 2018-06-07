module Decoder(
    input [31:0] Instr,
    output [16:0] ControlSignal,
    output Undefined
);
// add addi addu  sub subu 
// and andi or nor xor
// bgtz bne j jr
// lw sw


parameter add_A  =32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx10_0000;
parameter addi_A =32'b0010_00xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter addu_A =32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx10_0001;  
parameter sub_A  =32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx10_0010; 
parameter subu_A =32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx10_0011; 
parameter and_A  =32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx10_0100;
parameter andi_A =32'b0011_00xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx; 
parameter or_A   =32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx10_0101;
parameter nor_A  =32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx10_0111;
parameter xor_A  =32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx10_0110;
parameter bgtz_A =32'b0001_11xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;

parameter addiu_A=32'b0010_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter bne_A  =32'b0001_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter j_A    =32'b0000_10xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter jr_A   =32'b0000_00xx_xxx0_0000_0000_0000_0000_1000;
parameter lw_A   =32'b1000_11xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter sw_A   =32'b1010_11xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter blez_A =32'b0001_10xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter beq_A  =32'b0001_00xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter bgez_A =32'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter bltz_A = 32'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx; 
parameter lb_A = 32'b1000_00xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter ori_A = 32'b0011_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter sll_A = 32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx00_0000;
parameter sllv_A = 32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx00_0100;
parameter xori_A = 32'b0011_10xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
parameter break_A = 32'b0000_00xx_xxxx_xxxx_xxxx_xxxx_xx00_1101;

reg MemToReg;
reg RegWrite;
reg MemWrite;
reg MemRead;
reg [2:0]ALUOp;
reg ALUSrcA;
reg [1:0]ALUSrcB;
reg RegDst;
reg BranchOnEqual;
reg BranchOnGreater;
reg BranchOnLess;
reg breakpoint;
reg Jump;
reg Jr;

assign ControlSignal = {
    Jump,
    Jr,
    breakpoint,
    BranchOnLess,
    BranchOnEqual,
    BranchOnGreater,
    RegDst,
    ALUSrcB[1:0],
    ALUSrcA,
    ALUOp[2:0],
    MemRead,
    MemWrite,
    RegWrite,
    MemToReg
};
//Jump
always @(*)begin
    casex(Instr)
    j_A     : Jump <= 1;
    default : Jump <= 0;
    endcase
end
//Jr
always @(*)begin
    casex(Instr)
    jr_A    : Jr <= 1;
    default : Jr <= 0;
    endcase
end

// BranchOnLess
always @(*)begin
    casex(Instr)
    bltz_A  : BranchOnLess <= 1;
    blez_A  : BranchOnLess <= 1;
    bne_A   : BranchOnLess <= 1;
    default:
        BranchOnLess <= 0;
    endcase
end

// BranchOnEqual
always @(*)begin
    casex(Instr)
    beq_A   : BranchOnEqual <= 1;
    bgez_A  : BranchOnEqual <= 1;
    default:
        BranchOnEqual <= 0;
    endcase
end

// BranchOnGreater
always @(*)begin
    casex(Instr)
    bgtz_A  : BranchOnGreater <= 1;
    bne_A   : BranchOnGreater <= 1;
    bgez_A  : BranchOnGreater <= 1;
    default:
        BranchOnGreater <= 0;
    endcase
end

//breakpoint
always @(*)begin
    casex(Instr)
    break_A : breakpoint <= 1;
    default : breakpoint <= 0;
    endcase
end

// RegDst
always @(*)begin
    casex(Instr)
    add_A   : RegDst <= 1;
    addu_A  : RegDst <= 1;
    sub_A   : RegDst <= 1;
    subu_A  : RegDst <= 1;
    and_A   : RegDst <= 1;
    xor_A   : RegDst <= 1;
    
    or_A    : RegDst <= 1;
    nor_A   : RegDst <= 1;
    sllv_A  : RegDst <= 1;
    sll_A   : RegDst <= 1;
    default:
        RegDst <= 0;
    endcase
end

// ALUSrcB
always @(*)begin
    casex(Instr)
    sll_A   : ALUSrcB <= 1;
    lb_A    : ALUSrcB <= 2;
    
    addiu_A : ALUSrcB <= 3;
    addu_A  : ALUSrcB <= 3;
    subu_A  : ALUSrcB <= 3;
    default:
        ALUSrcB <= 2'b0;
    endcase
end

// ALUSrcA
always @(*)begin
    casex(Instr)
    addi_A  : ALUSrcA <= 1;
    addiu_A : ALUSrcA <= 1;
    andi_A  : ALUSrcA <= 1;
    ori_A   : ALUSrcA <= 1;
    xori_A  : ALUSrcA <= 1;
    lb_A    : ALUSrcA <= 1;
    lw_A    : ALUSrcA <= 1;
    sw_A    : ALUSrcA <= 1;
    default:
        ALUSrcA <= 0;
    endcase
end


parameter A_NOP = 3'b000;
parameter A_ADD = 3'b001;
parameter A_SUB = 3'b010;
parameter A_AND = 3'b011;
parameter A_OR = 3'b100;
parameter A_XOR = 3'b101;
parameter A_NOR = 3'b110;
parameter A_SLL = 3'b111;
// ALUOp
always @(*)begin
    casex(Instr)
    sub_A   : ALUOp <= A_SUB;
    subu_A  : ALUOp <= A_SUB;
    bne_A   : ALUOp <= A_SUB;
    bgez_A  : ALUOp <= A_SUB;
    bgtz_A  : ALUOp <= A_SUB;
    beq_A   : ALUOp <= A_SUB;
    blez_A  : ALUOp <= A_SUB;
    bltz_A  : ALUOp <= A_SUB;

    and_A   : ALUOp <= A_AND;
    andi_A  : ALUOp <= A_AND;
    or_A    : ALUOp <= A_OR;
    ori_A   : ALUOp <= A_OR;
    xori_A  : ALUOp <= A_XOR;
    xor_A   : ALUOp <= A_XOR;
    nor_A   : ALUOp <= A_NOR;
    sllv_A  : ALUOp <= A_SLL;
    sll_A   : ALUOp <= A_SLL;
    default:
        ALUOp <= 3'b001;
    endcase
end

// MemRead
always @(*)begin
    casex(Instr)
    lw_A    : MemRead <= 1;
    lb_A    : MemRead <= 1;
    default:
        MemRead <= 0;
    endcase
end

// MemWrite
always @(*)begin
    casex(Instr)
    sw_A : MemWrite <= 1;
    default:
        MemWrite <= 0;
    endcase
end

// RegWrite
always @(*)begin
    casex(Instr)
    add_A   : RegWrite <= 1;   
    addu_A  : RegWrite <= 1;       
    sub_A   : RegWrite <= 1;    
    subu_A  : RegWrite <= 1;      
    and_A   : RegWrite <= 1;   
    or_A    : RegWrite <= 1;     
    nor_A   : RegWrite <= 1;   
    xor_A   : RegWrite <= 1;   
    xori_A  : RegWrite <= 1;
    addi_A  : RegWrite <= 1;  
    addiu_A : RegWrite <= 1;   
    andi_A  : RegWrite <= 1;      
    lw_A    : RegWrite <= 1;    
    ori_A   : RegWrite <= 1;
    lb_A    : RegWrite <= 1;
    sllv_A  : RegWrite <= 1;
    sll_A   : RegWrite <= 1;
    default:
        RegWrite <= 0;
    endcase
end

// MemToRg
always @(*)begin
    casex(Instr)
    lb_A    : MemToReg <= 1;
    lw_A    : MemToReg <= 1;
    default:
        MemToReg <= 0;
    endcase
end


endmodule
