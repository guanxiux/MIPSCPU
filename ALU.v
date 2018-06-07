
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:51:59 03/29/2018 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
	input [1:0]ALUSrcB,
    input signed[31:0] alu_a,
    input signed[31:0] alu_b,
    input signed[2:0] alu_op,
    output signed[31:0] alu_out,
	output less,
	output equal,
	output greater,
	output overflow
    );
parameter A_NOP = 3'b0000;
parameter A_ADD = 3'b0001;
parameter A_SUB = 3'b0010;
parameter A_AND = 3'b0011;
parameter A_OR = 3'b0100;
parameter A_XOR = 3'b0101;
parameter A_NOR = 3'b0110;
parameter A_SLL = 3'b0111;

assign alu_out = (alu_op == A_NOP) ? 32'b0 : 
				 (alu_op == A_ADD) ? alu_a + alu_b :
				 (alu_op ==A_SUB) ? alu_a - alu_b :
				 (alu_op == A_AND) ? alu_a & alu_b :
				 (alu_op == A_OR) ? alu_a | alu_b :
				 (alu_op == A_XOR) ? alu_a ^ alu_b :
				 (alu_op == A_NOP) ? ~(alu_a | alu_b) : 
				 (alu_op == A_SLL) ? alu_b << alu_a : 32'b0;
assign equal = alu_out == 0 & alu_op == A_SUB;
assign greater = alu_out > 0 & alu_op == A_SUB;
assign less = alu_out < 0 & alu_op == A_SUB;	
assign overflow = ((alu_a[31] != alu_b[31]) || (alu_a[31] == alu_out[31]) || ALUSrcB == 3 ) ? 1'b0 : 1'b1; 
endmodule
