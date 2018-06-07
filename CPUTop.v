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
module CPUTop #(
	parameter RAM_addr_range = 4
)
(
	input clk,
	input rst_n,
	input single_step,
	input recover,
	input seg_control_request,
	input seg_output_control_upper,
	input [RAM_addr_range : 0]input_addr,
	output [7:0]seg,
	output [3:0]an
    );
	 
wire [9 : 0] external_addr_control;
wire signal_end_of_program;
wire [31:0] spo;

reg [4:0] end_count;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		end_count <= 0;
	else if(signal_end_of_program && end_count <= 5)
		end_count <= end_count + 1;
end
assign signal_end_of_program = (Instr[31:26] == 6'b0000_10 && PC == JumpAddr + 4 && if_Jump && rst_n) ? 1 : 0;
ExternalRAMAddrControl Control(rst_n, clk, seg_control_request, input_addr, external_addr_control);
// input rst_n,
// input [31:0]spo,
// input clk,
// input seg_output_control_upper,
// output reg [7:0] y,
// output reg [3:0]l

seg segout(rst_n, spo, clk, seg_output_control_upper, seg, an);

wire [31:0] if_NextPC;
wire [31:0]JRAddr;
wire [31:0]JumpAddr;
wire [31:0]BranchAddr;

wire [16:0] ControlSignal;

wire flush;
wire stall;

wire [31:0] mem_dout;
wire [4:0] id_RsAddr;
wire [4:0] id_RtAddr;
wire [4:0] id_RdAddr;
wire [4:0] wb_RegWriteAddr;
wire [31:0] wb_RegWriteData; 
wire [31:0] id_RsData;
wire [31:0] id_RtData;
wire [4:0] ex_RegWriteAddr;

wire [31:0] alu_a;
wire [31:0] alu_b;
wire [31:0] alu_out;
wire ex_Less;
wire ex_Equal;
wire ex_Greater;
wire overflow;

wire wb_MemToReg;
wire wb_RegWrite;

wire mem_MemRead;
wire mem_MemWrite;
wire mem_RegWrite;
wire mem_MemToReg;

wire ex_RegWrite;
wire ex_MemRead;
wire [2:0] ex_ALUOp;
wire ex_ALUSrcA;
wire [1:0] ex_ALUSrcB;
wire ex_RegDst;
wire ex_BranchOnEqual;
wire ex_BranchOnGreater;
wire ex_BranchOnLess;
wire ex_BranchTrue;

wire ex_breakpoint;
wire if_Jump;
wire if_JR;
wire if_Branch;

reg [31:0] PC;

reg [offset_to_BranchOnLess + 1:0] id_ex_Control;
reg [offset_to_mem_MemRead:0] ex_mem_Control;
reg [offset_to_wb_MemToReg:0] mem_wb_Control;

parameter offset_to_wb_MemToReg = 1;

assign wb_MemToReg = mem_wb_Control[offset_to_wb_MemToReg - 1];
assign wb_RegWrite = mem_wb_Control[offset_to_wb_MemToReg];

parameter offset_to_mem_MemRead = 3;

assign mem_MemRead = ex_mem_Control[offset_to_mem_MemRead];
assign mem_MemWrite = ex_mem_Control[offset_to_mem_MemRead - 1];
assign mem_RegWrite = ex_mem_Control[offset_to_mem_MemRead - 2];
assign mem_MemToReg = ex_mem_Control[offset_to_mem_MemRead - 3];

parameter offset_to_BranchOnLess = 13;

assign ex_RegWrite = id_ex_Control[offset_to_mem_MemRead - 2];
assign ex_MemRead = id_ex_Control[offset_to_mem_MemRead];
assign ex_ALUOp = id_ex_Control[offset_to_BranchOnLess - 7 : offset_to_BranchOnLess - 9];
assign ex_ALUSrcA = id_ex_Control[offset_to_BranchOnLess - 6];
assign ex_ALUSrcB = id_ex_Control[offset_to_BranchOnLess - 4 : offset_to_BranchOnLess - 5];
assign ex_RegDst = id_ex_Control[offset_to_BranchOnLess - 3];
assign ex_BranchOnGreater = id_ex_Control[ offset_to_BranchOnLess - 2 ];
assign ex_BranchOnEqual = id_ex_Control[ offset_to_BranchOnLess - 1 ];
assign ex_BranchOnLess = id_ex_Control[ offset_to_BranchOnLess];
assign ex_breakpoint = id_ex_Control [ 14 ];


parameter offset_to_jump = 16;


assign if_JR = ControlSignal[ offset_to_jump - 1];
assign if_Jump = ControlSignal[ offset_to_jump ];
assign if_Branch = ControlSignal[offset_to_BranchOnLess - 2] | ControlSignal[offset_to_BranchOnLess - 1] | ControlSignal[offset_to_BranchOnLess];

assign flush = ex_BranchTrue;

reg [31:0] if_id_NextPC;
reg [31:0] Instr;

reg [31:0] id_ex_NextPC;
reg [4:0] id_ex_RsAddr;
reg [4:0] id_ex_RtAddr;
reg [4:0] id_ex_RdAddr;
reg [31:0] id_ex_RsData;
reg [31:0] id_ex_RtData;
reg [31:0] id_ex_SignExtended;

reg [1:0] ex_mem_ALUSrcB;
reg [31:0] ex_mem_AluOut;
reg [31:0] ex_mem_MemWriteData;
reg [4:0] ex_mem_RegWriteAddr;

reg [31:0] mem_wb_Dout;
reg [31:0] mem_wb_AluOut;
reg [4:0] mem_wb_RegWriteAddr;

    // input clk,
    // input rst_n,
    // input overflow,
    // input instr_break,
    // input single_step,
    // input recover,
    // input if_JR,
    // output reg interrupt,
    // output [31:0]interruption_service_PC,
    // output [31:0]recovery_service_PC
wire interrupt;
wire [31:0]interruption_service_PC;
wire [31:0]saved_PC;
wire [31:0]recovery_service_PC;

Interruption CheckInterruption(clk, rst_n, overflow, ex_breakpoint, single_step, if_JR, interrupt, interruption_service_PC, recovery_service_PC);

always @(posedge clk or negedge rst_n)begin
	if (!rst_n || flush || interrupt) begin
		if (flush || interrupt) begin
			id_ex_Control <= 0;
			mem_wb_Control <= ex_mem_Control[1 : 0];
			if(!interrupt)
				ex_mem_Control <= 0;
			else ex_mem_Control <= 4'b10;
		end
		else begin
			id_ex_Control <= 0;
			ex_mem_Control <= 0;
			mem_wb_Control <= 0;
		end
	end
	else begin 	
		ex_mem_Control <= id_ex_Control[offset_to_mem_MemRead:0];
		mem_wb_Control <= ex_mem_Control[offset_to_wb_MemToReg:0];
		if(!stall)
			id_ex_Control <= ControlSignal[offset_to_BranchOnLess + 1 : 0];
		else id_ex_Control <= 0;
	end
end

assign if_NextPC = PC + 4;

reg [31:0] if_PCTemp;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		PC <= 32'b0;
		Instr <= 32'b0;
		if_id_NextPC <= if_NextPC;
	end
	else if(!stall) begin
		PC <= 	
			  	ex_BranchTrue 	? if_PCTemp 				:
			  	if_JR 		   	? JRAddr    				: 
				recover			? recovery_service_PC		:
				interrupt 		? interruption_service_PC 	:
			  	if_Jump  	   	? JumpAddr  				:
							 	  if_NextPC  				;
		if_PCTemp <= (if_Branch == 1 ? BranchAddr : if_PCTemp);
		if_id_NextPC <= (ex_BranchTrue == 1) ? if_PCTemp + 4 : if_NextPC;
		if(!flush && !if_JR && !if_Jump && !interrupt)
			Instr <= InstrOut;
		else Instr <= 32'b0;
	end
end

wire Undefined;

assign JRAddr = id_RsData;
assign JumpAddr = {if_id_NextPC[31:28] , Instr[25:0], 2'b0};
assign BranchAddr = SignImm * 4 + if_id_NextPC;

wire [31:0] InstrOut;
// input [9 : 0] a;
// output [31 : 0] spo;
ROMForPersonal InstructionMemory(PC[11:2], InstrOut);

Decoder decode(
   Instr,
   ControlSignal,
	Undefined
);  

assign id_RsAddr = Instr[25:21];
assign id_RtAddr = Instr[20:16];
assign id_RdAddr = Instr[15:11];

assign wb_RegWriteAddr = mem_wb_RegWriteAddr;
assign wb_RegWriteData = (wb_MemToReg == 1) ? mem_wb_Dout : mem_wb_AluOut;
//  input clk,
// 	input rst_n,
// 	input [4:0]rAddr1,
// 	output [31:0]rDout1,
// 	input [4:0]rAddr2,
// 	output [31:0]rDout2,
// 	input [4:0]wAddr,
// 	input [31:0]wDin,
// 	input wEna
RegisterFile Reg(clk, rst_n, id_RsAddr, id_RsData, id_RtAddr, id_RtData, wb_RegWriteAddr, wb_RegWriteData, wb_RegWrite);

// module Hazard(
//     input [4:0] ex_RegWriteAddr,
//     input [4:0] id_RsAddr,
//     input [4:0] id_RtAddr,
//     input ex_MemRead,
//     input ex_RegWrite,
//     output stall
// );
Hazard HazardDetector(ex_RegWriteAddr, id_RsAddr, id_RtAddr, ex_MemRead, ex_RegWrite, stall);

wire [31:0] SignImm;
SignExtend SE(Instr[15:0], SignImm);

always @(posedge clk)begin
	// id_ex_ZeroExtended <= {16'b0, Instr[15:0]};
	if(!stall) begin
		id_ex_SignExtended <= SignImm;
		id_ex_RsData <= id_RsData;
		id_ex_RtData <= id_RtData;
		id_ex_RsAddr <= id_RsAddr;
		id_ex_RtAddr <= id_RtAddr;
		id_ex_RdAddr <= id_RdAddr;
		id_ex_NextPC <= if_id_NextPC;
	end
end

assign alu_a =  (ex_ALUSrcB == 1) ? id_ex_SignExtended[10:6]:
				(AForward == 0) ? id_ex_RsData :
			    (AForward == 1) ? ex_mem_AluOut :
			   	  				 wb_RegWriteData;
assign alu_b =  (ex_ALUSrcA == 1) ? id_ex_SignExtended : 
			    (BForward == 0) ? id_ex_RtData :
				(BForward == 1) ? ex_mem_AluOut :
								 wb_RegWriteData ;
ALU MainAlu(ex_ALUSrcB ,alu_a, alu_b, ex_ALUOp, alu_out, ex_Less, ex_Equal, ex_Greater, overflow);

assign ex_BranchTrue = (ex_BranchOnEqual & ex_Equal) | (ex_BranchOnGreater & ex_Greater) | (ex_BranchOnLess & ex_Less);

wire [1:0] AForward;
wire [1:0] BForward;

// module Forwarding(
//     input [4:0] ex_mem_RegWriteAddr,
//     input [4:0] mem_wb_RegWriteAddr,
//     input mem_MemRead,
//     input mem_RegWrite,
//     input wb_RegWrite,
//     input [4:0] id_ex_RsAddr,
//     input [4:0] id_ex_RtAddr,
//     output AForwarding,
//     output BForwarding
// );
Forwarding Forward(ex_mem_RegWriteAddr, mem_wb_RegWriteAddr, mem_MemRead, mem_RegWrite, wb_RegWrite, id_ex_RsAddr, id_ex_RtAddr, AForward, BForward );

assign ex_RegWriteAddr = (interrupt) ? 5'd31 : (ex_RegDst == 1) ? id_ex_RdAddr : id_ex_RtAddr;

always @(posedge clk)begin
	ex_mem_ALUSrcB <= ex_ALUSrcB;
	ex_mem_AluOut <= (interrupt) ? id_ex_NextPC : alu_out;
	ex_mem_MemWriteData <=  (BForward == 0) ? id_ex_RtData :
							(mem_MemToReg == 1) ? mem_dout :
								 			 ex_mem_AluOut ;
	ex_mem_RegWriteAddr <= ex_RegWriteAddr;
end

// input [9 : 0] a;
// input [31 : 0] d;
// input clk;
// input we;
// output [31 : 0] spo;

wire [9 : 0] DataMemotyAddr;

assign DataMemotyAddr = (signal_end_of_program && end_count >= 4 ) ? external_addr_control : ex_mem_AluOut[11 : 2];

RAM DataMemoty(DataMemotyAddr, ex_mem_MemWriteData, clk, mem_MemWrite, spo);

assign mem_dout = (ex_mem_ALUSrcB != 2) ? spo : 
					(ex_mem_AluOut[1:0] == 0) ? {24'b0, spo[7:0]}  :
					(ex_mem_AluOut[1:0] == 1) ? {24'b0, spo[15:8]} :
					(ex_mem_AluOut[1:0] == 2) ? {24'b0, spo[23:16]}:
												{24'b0, spo[31:24]};	

always @(posedge clk)begin
	mem_wb_Dout <= mem_dout;
	mem_wb_AluOut <= ex_mem_AluOut;
	mem_wb_RegWriteAddr <= ex_mem_RegWriteAddr;
end
endmodule


