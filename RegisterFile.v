`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:54:37 04/07/2018 
// Design Name: 
// Module Name:    RegisterFile 
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
module RegisterFile(
	input clk,
	input rst_n,
	input [4:0]rAddr1,
	output [31:0]rDout1,
	input [4:0]rAddr2,
	output [31:0]rDout2,
	input [4:0]wAddr,
	input [31:0]wDin,
	input wEna
    );

reg [31:0]file[31:0];

parameter Initial = 32'b0;

integer i;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i <= 31; i = i + 1)
		begin:identifier
			file[i] = Initial;
		end
	end
	else 
		if (wEna) 
			file[wAddr] = wDin;
	end
assign rDout1 = (rAddr1 == wAddr && wEna == 1) ? wDin : file[rAddr1];
assign rDout2 = (rAddr2 == wAddr && wEna == 1) ? wDin : file[rAddr2];


endmodule
