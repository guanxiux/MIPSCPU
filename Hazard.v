module Hazard(
    input [4:0] ex_RegWriteAddr,
    input [4:0] id_RsAddr,
    input [4:0] id_RtAddr,
    input ex_MemRead,
    input ex_RegWrite,
    output stall
);
assign stall = ex_MemRead & ex_RegWrite & ((ex_RegWriteAddr == id_RsAddr) || (ex_RegWriteAddr == id_RtAddr));
    
endmodule