`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:31:55 04/26/2018 
// Design Name: 
// Module Name:    Control 
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
module Control(
	input clk,
	input rst_n,
	input [5:0]Op,
	input [5:0]Funct,
	output reg[15:0]ControlSignal,
	input Zero
    );
// addi
// add
// lw
// sw
// bgtz
// j
//addu  
//sub 
//subu 
//and 
//andi 
//or 
//nor 
//xor 
//bne  
//jr

reg [2:0]ContolState;
parameter ReadInstr = 3'b0;
parameter SaveInstr = 3'b1;
parameter Decode = 3'b10;
parameter Exec = 3'b11;
parameter AccessMem = 3'b100;
parameter WriteBack = 3'b101;
parameter Idle = 3'b111;
// parameter SavePC = 3'b101;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		ContolState <= Idle;
	end
	else begin if (ContolState >= WriteBack) 
		ContolState <= 3'b0;
		else ContolState <= ContolState + 1;
	end
end
//{Jump,IorD,MEMWrite,IRWrite,PCWrite,Branch,PCSrc,[2:0]alu_op_main,
//[1:0]ALUSrcB,ALUSrcA,RegWrite,MEMtoReg,RegDst};
always @(posedge clk) begin
	case(ContolState)
	Idle:begin
		ControlSignal <= 16'b0;
	end
	ReadInstr:begin   // save RAM , save PCPluse4, 000
		ControlSignal <= 16'b0001100001010000;
	end
	SaveInstr:begin  //001
		ControlSignal <= 16'b0;
	end
	Decode:begin   // read registerfile and save it, 010
		ControlSignal <= (Op == 0 && Funct == 32) ? 16'b0000000001001001 : //add !!!!!!!!!should check overflow
						 (Op == 8) 				  ? 16'b0000000001101000 : //addi
						 (Op == 35)				  ? 16'b0000000001101000 : //lw
						 (Op == 43)				  ? 16'b0000000001101000 : //sw
						 (Op == 7) 				  ? 16'b0000000010001000 : //bgtz
						 (Op == 2)				  ? 16'b0 				 : //j
						 (Op == 0 && Funct == 8)  ? 16'b0000001001001000 : //jr
						 (Op == 0 && Funct == 33) ? 16'b0000000001001001 : //addu  
						 (Op == 0 && Funct == 34) ? 16'b0000000010001001 ://sub 
						 (Op == 0 && Funct == 35) ? 16'b0000000010001001 ://subu 
						 (Op == 0 && Funct == 36) ? 16'b0000000011001001 ://and 
						 (Op == 12) 			  ? 16'b0000000011101000 ://andi 
						 (Op == 0 && Funct == 37) ? 16'b0000000100001001 ://or 
						 (Op == 0 && Funct == 39) ? 16'b0000000110001001 ://nor 
						 (Op == 0 && Funct == 38) ? 16'b0000000101001001 ://xor 
						 (Op == 5) 				  ? 16'b0000000010001001 : 16'b0;//bne 
	end
	Exec:begin    // save ALUout, 011
		ControlSignal <= (Op == 0 && Funct == 32) ? 16'b0000000001001001 :
						 (Op == 8) 				  ? 16'b0000000001101000 :
						 (Op == 35)				  ? 16'b0100000001101000 :
						 (Op == 43)				  ? 16'b0100000001101000 :
						 (Op == 7) 				  ? 16'b0000000010001000 :
						 (Op == 2)				  ? 16'b0 				 :
						 (Op == 0 && Funct == 8)  ? 16'b0000001001001000 ://jr
						 (Op == 0 && Funct == 33) ? 16'b0000000001001001 ://addu 
						 (Op == 0 && Funct == 34) ? 16'b0000000010001001 ://sub 
						 (Op == 0 && Funct == 35) ? 16'b0000000010001001 ://subu 
						 (Op == 0 && Funct == 36) ? 16'b0000000011001001 ://and 
						 (Op == 12) 			  ? 16'b0000000011101000 ://andi 
						 (Op == 0 && Funct == 37) ? 16'b0000000100001001 ://or 
						 (Op == 0 && Funct == 39) ? 16'b0000000110001001 ://nor 
						 (Op == 0 && Funct == 38) ? 16'b0000000101001001 ://xor 
						 (Op == 5) 				  ? 16'b0000000010001001 : 16'b0;//bne 
	end
	AccessMem:begin     // save alu_out, get ready to write back, 100
		ControlSignal <= (Op == 0 && Funct == 32) ? 16'b0000001001001101 :
						 (Op == 8) 				  ? 16'b0000001001101100 :
						 (Op == 35)				  ? 16'b0100001001101110 :
						 (Op == 43)				  ? 16'b0110001001101000 :
						 (Op == 7) 				  ? (Zero == 1 ? 16'b0 : 16'b0000110001110000) :
						 (Op == 2)				  ? 16'b1000000000000000 : 
						 (Op == 0 && Funct == 8)  ? 16'b0000101001001000 ://jr
						 (Op == 0 && Funct == 33) ? 16'b0000001001001101 ://addu
						 (Op == 0 && Funct == 34) ? 16'b0000001010001101 ://sub 
						 (Op == 0 && Funct == 35) ? 16'b0000001010001101 ://subu 
						 (Op == 0 && Funct == 36) ? 16'b0000001011001101 ://and 
						 (Op == 12) 			  ? 16'b0000001011101100 ://andi 
						 (Op == 0 && Funct == 37) ? 16'b0000001100001101 ://or 
						 (Op == 0 && Funct == 39) ? 16'b0000001110001101 ://nor 
						 (Op == 0 && Funct == 38) ? 16'b0000001101001101 ://xor 
						 (Op == 5) 				  ? (Zero == 1 ? 16'b0 : 16'b0000110001110000) : 16'b0;//bne 
	end
	WriteBack:begin // write back , get ready to read instr, 101
		ControlSignal <= 16'b0;
	end
	default:;
	endcase
end

endmodule
