
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
    input signed[31:0] alu_a,
    input signed[31:0] alu_b,
    input signed[2:0] alu_op,
    output signed[31:0] alu_out,
	output overflow
    );
parameter A_NOP = 3'b000;
parameter A_ADD = 3'b001;
parameter A_SUB = 3'b010;
parameter A_AND = 3'b011;
parameter A_OR = 3'b100;
parameter A_XOR = 3'b101;
parameter A_NOR = 3'b110;


	// always @  begin case(alu_op[4:0])
	// 	A_NOP: storage = 31'b0;
	// 	A_ADD: storage = alu_a + alu_b;
	// 	A_SUB: storage = alu_a - alu_b;
	// 	A_AND: storage = alu_a & alu_b;
	// 	A_OR:  storage = alu_a | alu_b;
	// 	A_XOR: storage = alu_a ^ alu_b;
	// 	A_NOR: storage = ~(alu_a | alu_b);
	// 	default: storage = 31'b0;
	// 	endcase
	// end
assign alu_out = (alu_op == A_NOP) ? alu_out : 
				 (alu_op == A_ADD) ? alu_a + alu_b :
				 (alu_op ==A_SUB) ? alu_a - alu_b :
				 (alu_op == A_AND) ? alu_a & alu_b :
				 (alu_op == A_OR) ? alu_a | alu_b :
				 (alu_op == A_XOR) ? alu_a ^ alu_b :
				 (alu_op == A_NOP) ? ~(alu_a | alu_b) : 0;	
assign overflow = (alu_a[31]&alu_b[31] == alu_out[31]) ? 0 : 1; 
endmodule
