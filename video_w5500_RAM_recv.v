`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:56:34 10/27/2018 
// Design Name: 
// Module Name:    w5500_RAM 
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
module w5500_RAM(
	input      		rst,
	input 			clk_50M,
	input			clk_125M,
	input			data_recv_nd,
	input  [7:0]  	data_recv,
	input 			send_done_feedback,		//input网口发送完成
	
	output reg 			data_send_nd 	=  1'b0,
	output reg [15:0]	data_send_byte 	= 16'd0,	//output视频字节控制
	output wire [7:0]	data_read,
	output reg [21:0]	counter_50M		= 22'd0,
	output wire[135:0]  data_ram
);

////////*****************ILA显示*******************//////// 
assign data_ram[0]= data_recv_nd;
assign data_ram[8:1]= data_recv;
assign data_ram[24:9]= addra_write;
assign data_ram[32:25]= data_read;
assign data_ram[48:33]= addrb_read;

assign data_ram[49]= data_send_nd;
assign data_ram[65:50]= data_send_byte;
//assign data_ram[73:66]= data_send;
assign data_ram[74]= wea_0;
assign data_ram[96:75]= counter_byte;
assign data_ram[118:97]= counter_50M;
assign data_ram[121:119]= data_send_state;
assign data_ram[122]= send_ready;
assign data_ram[123]= data_send_begin;
assign data_ram[134:124]= counter_send;
assign data_ram[135]= send_done_feedback;

////////*****************counter_50M*******************//////// 

always@(posedge clk_50M)
begin
	if(rst)
		counter_50M <= 22'd0;
	else
		counter_50M <= counter_50M + 1'b1;	
end
////////*************data_recv_nd_d1***************//////// 
reg data_recv_nd_d1 = 1'b0;
reg data_recv_nd_d2 = 1'b0;

always@(posedge clk_125M)
begin
	if(rst) 
	begin
		data_recv_nd_d1 <= 1'b0;
		data_recv_nd_d2 <= 1'b0;
	end
	else 
	begin 
		data_recv_nd_d1 <= data_recv_nd;	
		data_recv_nd_d2 <= data_recv_nd_d1;
	end	
end
////////*************data_send_nd_d1***************//////// 
reg data_send_nd_d1 = 1'b0;

always@(posedge clk_125M)
begin
	if(rst) 
		data_send_nd_d1 <= 1'b0;
	else 
		data_send_nd_d1 <= data_send_nd;	
end
////////*************send_done_feedback_d1***************//////// 
reg send_done_feedback_d1 = 1'b0;

always@(posedge clk_125M)
begin
	if(rst) 
		send_done_feedback_d1 <= 1'b0;
	else 
		send_done_feedback_d1 <= send_done_feedback;	
end
////////***************counter_byte  data_send_begin***************//////// 
reg	 [21:0] counter_byte 	= 22'd0;

always@(posedge clk_125M)
begin
	if(rst) 
		counter_byte 	<= 22'd0;
	else
		if(!data_recv_nd_d1 && data_recv_nd)
			counter_byte 	<= counter_byte + 1'b1;
end
////////***************data_send_begin***************//////// 
reg  		data_send_begin	=  1'b0;

always@(posedge clk_125M)
begin
	if(rst) 
		data_send_begin <= 1'b0;	
	else
		if(data_recv_nd)
			data_send_begin <= 1'b1;
end
////////*******addra_write*******//////// 
reg  [15:0]	addra_write		= 16'd0;
always@(posedge clk_125M)
begin
	if(rst)
	begin
		addra_write <=15'd0;
	end
	else
		if(data_recv_nd_d1 && !data_recv_nd) 
			addra_write <= addra_write + 1'b1; 
end
////////*******send_ready*******//////// 
reg send_ready = 1'b0;

always@(posedge clk_125M)
begin
	if(rst)
		send_ready <= 1'd0;
	else
		if(data_send_nd_d1 && !data_send_nd)
			send_ready <= 1'd1;
		else 
			if(send_done_feedback)
				send_ready <= 1'd0;
end
////////*****************data_send_nd  data_send_byte  data_send*******************//////// 
////////*****************addrb_read  data_send_state  counter_send*******************//////// 

reg  [15:0] addrb_read		= 16'd0;
reg  [2:0] 	data_send_state =  3'd0;
reg  [10:0]	counter_send 	= 11'd0;

always@(posedge clk_50M)
begin
	if(rst)
	begin
		addrb_read		<= 16'd0;
		counter_send 	<= 11'd0;
		data_send_state <= 3'd0;
		data_send_nd 	<= 1'b0;
		data_send_byte 	<=16'd0;
	end
	else
		if(send_ready == 1'b0)
				case(data_send_state)
					3'd0:if(((addra_write > addrb_read) && (addra_write - addrb_read >= 13'd1324)) || ((addra_write < addrb_read) && ((17'd65536 + addra_write - addrb_read) >= 13'd1324)))
							data_send_state <= 3'd1;
					3'd1:if(data_read == 8'hC0) begin data_send_state <= 3'd2; addrb_read <= addrb_read + 1'b1; end else addrb_read <= addrb_read + 1'b1;
					3'd2:if(data_read == 8'hA8) begin data_send_state <= 3'd3; addrb_read <= addrb_read + 1'b1; end else data_send_state <= 3'd0;
					3'd3:if(data_read == 8'h01) begin data_send_state <= 3'd4; addrb_read <= addrb_read + 1'b1; end else data_send_state <= 3'd0;
					3'd4:if(data_read == 8'h1E) begin data_send_state <= 3'd5; addrb_read <= addrb_read +16'd3; end else data_send_state <= 3'd0;

					3'd5:begin data_send_state <= 3'd6; addrb_read <= addrb_read + 1'b1; data_send_byte[15:8] <= data_read; end
					3'd6:begin data_send_state <= 3'd7; addrb_read <= addrb_read + 1'b1; data_send_byte[7:0]  <= data_read; data_send_nd <= 1'b1; counter_send <= 13'd0; end
					3'd7:
						begin 
					    	if(counter_send < (data_send_byte - 1'b1))
					    	begin 
					    		addrb_read 	 <= addrb_read   + 1'b1; 
					    		counter_send <= counter_send + 1'b1; 
					    	end
					    	else 
					    	begin 
					    		addrb_read 	 	<= addrb_read + 1'b1; 
					    		counter_send 	<= 13'd0; 
					    		data_send_nd 	<= 1'b0; 
					    		data_send_state <= 3'd0; 
					    	end
					    end
				endcase
end

////////*****************RAM*******************//////// 
wire 		wea_0;		
	
assign wea_0 = data_recv_nd;

RAM_video RAM_video_0 (
  .clka(clk_125M), 	// input clka					写时钟
  .wea(wea_0), 		// input [0 : 0] wea            写使能
  .addra(addra_write), 	// input [10 : 0] addra        	写地址
  .dina(data_recv), // input [7 : 0] dina           写数据
  .clkb(clk_125M), 	// inputnp clkb                   读时钟
  .addrb(addrb_read), 	// iut [10 : 0] addrb         读地址
  .doutb(data_read) // output [7 : 0] doutb         读数据
);
endmodule
