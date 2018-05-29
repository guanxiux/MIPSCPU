`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:23:34 04/26/2018 
// Design Name: 
// Module Name:    CPUTop 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CPUTop(
	input clk,
	input rst_n
    );
wire [31:0] PC;
wire [31:0] NextPC;

wire [31:0] WD;
wire [31:0] RD;
wire [31:0] PCTemp;
wire [31:0] ALUOutTemp;
wire [31:0] Adr;
wire [4:0] A1;
wire [4:0] A2;
wire [4:0] A3;
wire [31:0] WD3; 
wire [31:0] RD1;
wire [31:0] RD2;
reg [31:0] A;
reg [31:0] B;
wire [15:0]ControlSignal;
wire PCEn;

wire Jump;
wire IorD;
wire [3:0]MEMWrite;
wire IRWrite;
wire PCWrite;
wire Branch;
wire PCSrc;
wire [2:0]alu_op_main;
wire [1:0]ALUSrcB;
wire ALUSrcA;
wire RegWrite;
wire MEMtoReg;
wire RegDst;
wire [31:0]alu_a_main;
wire [31:0]alu_b_main;
wire [31:0]alu_out_main;
wire Zero;
wire overflow;


PCounter pc(clk, rst_n, PCEn, NextPC, PC, Jump, Instr[25:0]);

wire [31:0]SignImm;
SignExtend SE(Instr[15:0], SignImm);

assign Adr = (IorD == 0) ? PC : ALUOut;
// input clka;
// input [3 : 0] wea;
// input [31 : 0] addra;
// input [31 : 0] dina;
// output [31 : 0] douta;
RAM InstructionMemory(clk, MEMWrite, Adr, WD, RD);
reg [31:0] Instr;
wire [31:0] Data;
always @(posedge clk)begin
	if (IRWrite) begin
		Instr <= RD;
	end
end
assign Data = RD;
assign WD = B;


always@(posedge clk)begin
	A <= RD1;
	B <= RD2;
end
assign WD3 = (MEMtoReg == 1) ? Data : ALUOut; 
assign A1 = Instr[25:21];
assign A2 = Instr[20:16];
assign A3 = (RegDst == 1) ? Instr[15:11] : Instr[20:16];
//  input clk,
// 	input rst_n,
// 	input [4:0]rAddr1,
// 	output [31:0]rDout1,
// 	input [4:0]rAddr2,
// 	output [31:0]rDout2,
// 	input [4:0]wAddr,
// 	input [31:0]wDin,
// 	input wEna
RegisterFile Reg(clk, rst_n, A1, RD1, A2, RD2, A3, WD3, RegWrite);



assign PCEn = (PCWrite == 1 || (Branch&Zero) == 1) ? 1 : 0;

assign Jump = ControlSignal[15];
assign IorD = ControlSignal[14];
assign MEMWrite = ControlSignal[13] ? 4'b1111 : 4'b0;
assign IRWrite = ControlSignal[12];
assign PCWrite = ControlSignal[11];
assign Branch = ControlSignal[10];
assign PCSrc = ControlSignal[9];
assign alu_op_main = ControlSignal[8:6];
assign ALUSrcB = ControlSignal[5:4];
assign ALUSrcA = ControlSignal[3];
assign RegWrite = ControlSignal[2];
assign MEMtoReg = ControlSignal[1];
assign RegDst = ControlSignal[0];
Control ControlUnit(clk, rst_n, Instr[31:26], Instr[5:0], ControlSignal, Zero);



assign alu_a_main = (ALUSrcA == 0) ? PC : A;
assign alu_b_main = (ALUSrcB == 2'b0) ? 	    B :
					(ALUSrcB == 2'b1) ? 	    4 :
					(ALUSrcB == 2'b10) ? SignImm :
					(ALUSrcB == 2'b11) ? SignImm << 2 : 0;
assign Zero = (alu_out_main == 0) ? 1'b1 : 1'b0;
ALU MainAlu(alu_a_main, alu_b_main, alu_op_main, alu_out_main, overflow);

reg [31:0]ALUOut;
always @(posedge clk)begin
	ALUOut <= alu_out_main;
end


assign NextPC = (PCSrc == 0) ? alu_out_main : ALUOut;

endmodule


