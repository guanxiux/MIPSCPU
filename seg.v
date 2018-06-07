module seg #(
	parameter RAM_addr_range = 4
)
(
input rst_n,
input [31:0]spo,
input clk,
input seg_output_control_upper,
output reg [7:0] y,
output reg [3:0]l
    );


wire [15:0]data;
reg [31:0]cnt1;
reg [3:0]num;
parameter lsw3 = 4'b1110;	
parameter lsw2 = 4'b1101;
parameter lsw1 = 4'b1011;
parameter lsw0 = 4'b0111;

assign data = seg_output_control_upper ? spo[31:16] : spo[15:0];

always @(posedge clk) begin	
		case(cnt1[31:0])
     	32'h0:  begin                   //30'h0
     		num <= (rst_n) ? data[15:12] : 4'b0;
     		l <= lsw0;
     	end   
     	32'h61a80:  begin             //30'h4c4b40
     		num <= (rst_n) ? data[11:8] : 4'b0;
     		l <= lsw1;
     	end
     	32'hc3500:  begin              //30'h989680
     		num <= (rst_n) ? data[7:4] : 4'b0;
     		l <= lsw2;
     	end
     	32'h124f80:  begin              //30'he4e1c0
     		num <= (rst_n) ? data[3:0] : 4'b0;
     		l <= lsw3;
     	end
	  	default: ;
    	endcase
   		if(cnt1 == 32'h186a00 )        //30'h1312d00
			cnt1 <= 0;
		else
	    	cnt1 <= cnt1 + 1;
end
always@(*)
    begin
	     case(num[3:0])
		  4'b0000: y = ~8'b11111100;
		  4'b0001: y = ~8'b01100000;
		  4'b0010: y = ~8'b11011010;
		  4'b0011: y = ~8'b11110010;
		  4'b0100: y = ~8'b01100110;
		  4'b0101: y = ~8'b10110110;
		  4'b0110: y = ~8'b10111110;
		  4'b0111: y = ~8'b11100000;
		  4'b1000: y = ~8'b11111110;
		  4'b1001: y = ~8'b11110110;
		  4'b1010: y = ~8'b11101110;
		  4'b1011: y = ~8'b00111110;
		  4'b1100: y = ~8'b10011100;
		  4'b1101: y = ~8'b01111010;
		  4'b1110: y = ~8'b10011110;
		  4'b1111: y = ~8'b10001110;
		  default: y = ~8'b00000000;
		  endcase
	end
endmodule