`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:25:18 04/26/2018 
// Design Name: 
// Module Name:    PCounter 
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
module PCounter(
	input clk,
	input rst_n,
	input EN,
	input [31:0]NextPC,
	output reg[31:0]PC,
	input Jump,
	input [25:0]Instr
    );

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		// reset
		PC <= 32'b0;
	end
	else begin
		if (Jump == 1) begin
			PC[27:2] <= Instr;
			PC[1:0] <= 2'b0;
		end
		else if (EN) begin
			PC <= NextPC;
		end
	end
end


endmodule
