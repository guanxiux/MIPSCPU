module ExternalRAMAddrControl #(
    parameter RAM_addr_range = 4,
    parameter half_a_second = 26'b10111110101111000010000000,
    parameter display_range = 32,
    parameter display_addr_range = 5
)(
    input rst_n,
    input clk,
    input seg_output_request,
    input [RAM_addr_range : 0] input_addr,
    output [9:0]externel_RAM_addr_control
);

reg [31 : 0]cnt;
reg [display_addr_range - 1 : 0]addr_temp;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt <= 0;
        addr_temp <= 0;
    end
    else if(!seg_output_request) begin
            if(cnt == half_a_second)begin
                cnt <= 0;
                addr_temp <= (addr_temp + 1)%display_range;
            end
            else 
                cnt <= cnt + 1;
    end

end

assign externel_RAM_addr_control = seg_output_request ? {5'b0, input_addr[RAM_addr_range : 0]} : addr_temp ;

endmodule