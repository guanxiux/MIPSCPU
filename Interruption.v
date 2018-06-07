module Interruption #(
    parameter basic_interruption_service_PC = 32'd76,
    parameter basic_recovery_service_PC = 32'd208
)
(
    input clk,
    input rst_n,
    input overflow,
    input instr_break,
    input single_step,
    input if_JR,
    output reg interrupt,
    output [31:0]interruption_service_PC,
    output [31:0]recovery_service_PC
);
reg EINT;
reg [2:0] interruption_code;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        EINT <= 1;
    end
    else if (if_JR) begin
        EINT <= 1;
    end
    else if (interrupt) begin
        EINT <= 0;
    end
end

always @(*)begin
        interruption_code <= {instr_break, single_step, overflow};
            if(interruption_code > 0 && EINT)begin
                interrupt <= 1;
            end
            else interrupt <= 0;
end

assign recovery_service_PC = basic_recovery_service_PC;
assign interruption_service_PC = basic_interruption_service_PC;
endmodule