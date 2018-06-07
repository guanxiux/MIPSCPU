module Forwarding(
    input [4:0] ex_mem_RegWriteAddr,
    input [4:0] mem_wb_RegWriteAddr,
    input mem_MemRead,
    input mem_RegWrite,
    input wb_RegWrite,
    input [4:0] id_ex_RsAddr,
    input [4:0] id_ex_RtAddr,
    output [1:0] AForwarding,
    output [1:0] BForwarding
);

assign AForwarding = (mem_RegWrite & !mem_MemRead & (ex_mem_RegWriteAddr == id_ex_RsAddr)) ? 2'd1 :
                     (wb_RegWrite & (mem_wb_RegWriteAddr == id_ex_RsAddr))                 ? 2'd2 :
                                                                                             2'd0 ;
                                                                                             
assign BForwarding = (mem_RegWrite & !mem_MemRead & (ex_mem_RegWriteAddr == id_ex_RtAddr)) ? 2'd1 :
                     (wb_RegWrite & (mem_wb_RegWriteAddr == id_ex_RtAddr))                 ? 2'd2 :
                                                                                             2'd0 ;

endmodule