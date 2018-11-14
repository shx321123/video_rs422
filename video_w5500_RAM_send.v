
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
	input  [14:0]	limit_byte,
	input  [22:0]	limit_time,
	input 			clk_50M,
	input			clk_125M,
	input			data_recv_nd,
	input   [7:0]  	data_recv,
	input  [12:0] 	counter_byte_422,
	input   [3:0] 	send_state,
	input   [4:0] 	counter_125M_32,
	
	output reg 			data_send_nd 	= 1'b0,
	output reg [12:0]	data_send_byte 	= 13'd0,
	output reg  [7:0]	data_send 		= 8'd0,
	output wire[227:0]  data_ram,

	output reg 			counter_byte_limit = 1'd0,
	output reg [21:0]	counter_byte = 22'd0,
	output reg [21:0]	counter_50M  = 22'd0,
	output reg [3:0]	ram_wait     =  4'd0
);


////////*****************ILA显示*******************//////// 
assign data_ram[2:0]	= ram_write;
assign data_ram[6:3]	= ram_wait;
assign data_ram[21:7]	= addra_write;
assign data_ram[43:22]	= counter_byte;
assign data_ram[44]		= data_recv_nd;
assign data_ram[52:45]	= data_recv;

assign data_ram[55:53]	= ram_read;
assign data_ram[70:56]	= addrb_read;

assign data_ram[71]		= data_send_nd;
assign data_ram[84:72]	= data_send_byte;
assign data_ram[92:85]= data_send;

assign data_ram[93]	= wea_0;
assign data_ram[94]	= wea_1;
 
assign data_ram[102:95] = data_read_0;
assign data_ram[110:103] = data_read_1;

assign data_ram[123:111] = counter_7424B;

assign data_ram[136:124] = send_byte_0; 		
assign data_ram[149:137] = send_byte_1; 
assign data_ram[162:150] = send_byte_2; 
assign data_ram[175:163] = send_byte_3; 		
assign data_ram[188:176] = send_byte_4; 		
assign data_ram[201:189] = send_byte_5; 		
assign data_ram[214:202] = send_byte_6; 		
assign data_ram[227:215] = send_byte_7; 		
////////*****************counter_50M*******************//////// 
//reg	 [21:0]	counter_50M	= 22'd0;

always@(posedge clk_50M)
begin
	if(rst)
		counter_50M <= 22'd0;
	else
		if(counter_50M >= (limit_time - 1'b1))
			counter_50M <= 22'd0;
		else
			counter_50M <= counter_50M + 1'b1;	
end
////////*************data_recv_nd_d1***************//////// 
reg data_recv_nd_d1 = 1'b0;

always@(posedge clk_50M)
begin
	if(rst) 
		data_recv_nd_d1 <= 1'b0;
	else 
		data_recv_nd_d1 <= data_recv_nd;	
end
////////*************data_send_nd_d1***************//////// 
reg data_send_nd_d1 = 1'b0;

always@(posedge clk_50M)
begin
	if(rst) 
		data_send_nd_d1 <= 1'b0;
	else 
		data_send_nd_d1 <= data_send_nd;	
end
////////***************counter_byte  data_send_begin***************//////// 
//reg	 [21:0] counter_byte 	= 22'd0;
reg  		data_send_begin	=  1'b0;

always@(posedge clk_50M)
begin
	if(rst) 
	begin
		counter_byte 	<= 22'd0;
		data_send_begin <= 1'b0;	
	end
	else
		if(counter_50M >= (limit_time - 1'b1))
			counter_byte <= 22'd0;
		else 
			if(!data_recv_nd_d1 && data_recv_nd)
			begin 
				counter_byte 	<= counter_byte + 1'b1;
				data_send_begin <= 1'b1;
			end
end
////////************counter_byte_limit**********//////// 
//reg  counter_byte_limit	= 1'd0;

always@(posedge clk_50M)
begin
	if(rst)
		counter_byte_limit <= 1'b0;
	else
		if(counter_50M >= (limit_time - 1'b1) && counter_byte >= limit_byte) 
			counter_byte_limit <= 1'b1;
		else
			counter_byte_limit <= 1'b0;
end
////////*******ram_write  ram_wait  addra_write  addra_store*******//////// 
reg  [2:0]	ram_write 		=  3'd0;
reg  [12:0] counter_7424B   = 13'd0; 

reg  [14:0]	addra_write		= 15'd0;
//reg  [14:0]	addra_store_0	= 15'd0;
//reg  [14:0]	addra_store_1	= 15'd0;

reg  [12:0] send_byte_0 	= 13'd0;
reg  [12:0] send_byte_1 	= 13'd0;
reg  [12:0] send_byte_2 	= 13'd0;
reg  [12:0] send_byte_3 	= 13'd0;
reg  [12:0] send_byte_4 	= 13'd0;
reg  [12:0] send_byte_5 	= 13'd0;
reg  [12:0] send_byte_6 	= 13'd0;
reg  [12:0] send_byte_7 	= 13'd0;

//reg  [2:0]  ram_wait  = 3'd0;
always@(posedge clk_50M)
begin
	if(rst)
	begin
		ram_write 		<= 3'd0;
		ram_wait		<= 4'd0;
		addra_write 	<=15'd0;
		counter_7424B   <=13'd0;
		send_byte_0 	<=13'd0;
		send_byte_1 	<=13'd0;
		send_byte_2 	<=13'd0;
		send_byte_3 	<=13'd0;
		send_byte_4 	<=13'd0;
		send_byte_5 	<=13'd0;
		send_byte_6 	<=13'd0;
		send_byte_7 	<=13'd0;
	end
	else
		if(counter_50M >= 22'd1249999)											//如果25ms结束
			if(ram_wait == 4'd0)												//如果无缓存发送字节，则准备换片
			begin 
				if(data_recv_nd_d1 && !data_recv_nd)
					case(ram_write)
						3'd0:begin send_byte_0 <= addra_write + 13'd1; 	   addra_write <= 15'd0; ram_write <= 3'd4; counter_7424B <= 13'd0; end 
						3'd1:begin send_byte_1 <= addra_write - 13'd7423;  addra_write <= 15'd0; ram_write <= 3'd4; counter_7424B <= 13'd0; end 
						3'd2:begin send_byte_2 <= addra_write - 13'd14847; addra_write <= 15'd0; ram_write <= 3'd4; counter_7424B <= 13'd0; end 
						3'd3:begin send_byte_3 <= addra_write - 13'd22271; addra_write <= 15'd0; ram_write <= 3'd4; counter_7424B <= 13'd0; end 
						3'd4:begin send_byte_4 <= addra_write + 13'd1; 	   addra_write <= 15'd0; ram_write <= 3'd0; counter_7424B <= 13'd0; end 
						3'd5:begin send_byte_5 <= addra_write - 13'd7423;  addra_write <= 15'd0; ram_write <= 3'd0; counter_7424B <= 13'd0; end 
						3'd6:begin send_byte_6 <= addra_write - 13'd14847; addra_write <= 15'd0; ram_write <= 3'd0; counter_7424B <= 13'd0; end 
						3'd7:begin send_byte_7 <= addra_write - 13'd22271; addra_write <= 15'd0; ram_write <= 3'd0; counter_7424B <= 13'd0; end 
					endcase                                                     								
				else 
					if(data_send_begin == 1'b1)
						case(ram_write[2])                                              
							1'b0:begin addra_write <= 15'd0; ram_write <= 3'd4; counter_7424B <= 13'd0; end     
							1'b1:begin addra_write <= 15'd0; ram_write <= 3'd0; counter_7424B <= 13'd0; end     
						endcase   
			end
			else
				if(data_recv_nd_d1 && !data_recv_nd)                        //收到一个字节
					if(counter_7424B >= 13'd7415)                    		//如果已经存满7424 - 8 = 7415byte
						case(ram_write)										//换片
							3'd0:begin send_byte_0 <= 13'd7416; addra_write <= 15'd7424;  ram_write <= 3'd1; counter_7424B <= 13'd0; end 
							3'd1:begin send_byte_1 <= 13'd7416; addra_write <= 15'd14848; ram_write <= 3'd2; counter_7424B <= 13'd0; end 
							3'd2:begin send_byte_2 <= 13'd7416; addra_write <= 15'd22272; ram_write <= 3'd3; counter_7424B <= 13'd0; end 
							3'd3:begin send_byte_3 <= 13'd7416; addra_write <= 15'd0;	   ram_write <= 3'd4; counter_7424B <= 13'd0; end 
							3'd4:begin send_byte_4 <= 13'd7416; addra_write <= 15'd7424;  ram_write <= 3'd5; counter_7424B <= 13'd0; end 
							3'd5:begin send_byte_5 <= 13'd7416; addra_write <= 15'd14848; ram_write <= 3'd6; counter_7424B <= 13'd0; end 
							3'd6:begin send_byte_6 <= 13'd7416; addra_write <= 15'd22272; ram_write <= 3'd7; counter_7424B <= 13'd0; end 
							3'd7:begin send_byte_7 <= 13'd7416; addra_write <= 15'd0; 	   ram_write <= 3'd0; counter_7424B <= 13'd0; end 
						endcase 
					else													//如果没有存满7424byte，则接着存
						case(ram_write)										//换片
							3'd0:begin ram_wait <= ram_wait - 1'b1; send_byte_0 <= addra_write + 13'd1; 	addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
							3'd1:begin ram_wait <= ram_wait - 1'b1; send_byte_1 <= addra_write - 13'd7423;  addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
							3'd2:begin ram_wait <= ram_wait - 1'b1; send_byte_2 <= addra_write - 13'd14847; addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
							3'd3:begin ram_wait <= ram_wait - 1'b1; send_byte_3 <= addra_write - 13'd22271; addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
							3'd4:begin ram_wait <= ram_wait - 1'b1; send_byte_4 <= addra_write + 13'd1; 	addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
							3'd5:begin ram_wait <= ram_wait - 1'b1; send_byte_5 <= addra_write - 13'd7423;  addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
							3'd6:begin ram_wait <= ram_wait - 1'b1; send_byte_6 <= addra_write - 13'd14847; addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
							3'd7:begin ram_wait <= ram_wait - 1'b1; send_byte_7 <= addra_write - 13'd22271; addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
						endcase 			
				else 	
					ram_wait <= ram_wait - 1'b1;
		else                                                                //
			if(data_recv_nd_d1 && !data_recv_nd)                            //收到一个字节
				if(counter_7424B >= 13'd7415)                    			//如果已经存满7424 - 8 = 7415byte
					case(ram_write)											//换片
						3'd0:begin send_byte_0 <= 13'd7416; addra_write <= 15'd7424;  ram_write <= 3'd1; ram_wait <= ram_wait + 1'b1; counter_7424B <= 13'd0; end 
						3'd1:begin send_byte_1 <= 13'd7416; addra_write <= 15'd14848; ram_write <= 3'd2; ram_wait <= ram_wait + 1'b1; counter_7424B <= 13'd0; end 
						3'd2:begin send_byte_2 <= 13'd7416; addra_write <= 15'd22272; ram_write <= 3'd3; ram_wait <= ram_wait + 1'b1; counter_7424B <= 13'd0; end 
						3'd3:begin send_byte_3 <= 13'd7416; addra_write <= 15'd0;	  ram_write <= 3'd4; ram_wait <= ram_wait + 1'b1; counter_7424B <= 13'd0; end 
						3'd4:begin send_byte_4 <= 13'd7416; addra_write <= 15'd7424;  ram_write <= 3'd5; ram_wait <= ram_wait + 1'b1; counter_7424B <= 13'd0; end 
						3'd5:begin send_byte_5 <= 13'd7416; addra_write <= 15'd14848; ram_write <= 3'd6; ram_wait <= ram_wait + 1'b1; counter_7424B <= 13'd0; end 
						3'd6:begin send_byte_6 <= 13'd7416; addra_write <= 15'd22272; ram_write <= 3'd7; ram_wait <= ram_wait + 1'b1; counter_7424B <= 13'd0; end 
						3'd7:begin send_byte_7 <= 13'd7416; addra_write <= 15'd0; 	  ram_write <= 3'd0; ram_wait <= ram_wait + 1'b1; counter_7424B <= 13'd0; end 
					endcase 
				else														//如果没有存满7424byte，则接着存
					case(ram_write)											//换片
						3'd0:begin send_byte_0 <= addra_write + 13'd1; 	   addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
						3'd1:begin send_byte_1 <= addra_write - 13'd7423;  addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
						3'd2:begin send_byte_2 <= addra_write - 13'd14847; addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
						3'd3:begin send_byte_3 <= addra_write - 13'd22271; addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
						3'd4:begin send_byte_4 <= addra_write + 13'd1; 	   addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
						3'd5:begin send_byte_5 <= addra_write - 13'd7423;  addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
						3'd6:begin send_byte_6 <= addra_write - 13'd14847; addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
						3'd7:begin send_byte_7 <= addra_write - 13'd22271; addra_write <= addra_write + 1'b1; counter_7424B <= counter_7424B + 1'b1; end
					endcase 				
end	
////////*****************addra_0 addra_1*******************//////// 
reg  [14:0] addra_0;
reg	 [14:0] addra_1;

always@(posedge clk_50M)
begin 
	if(rst)
	begin
		addra_0 <= 15'd0;
		addra_1 <= 15'd0;
	end
	else
		case(ram_write[2])
			1'b0:begin addra_0 <= addra_write; addra_1 <= 15'd0; end 
			1'b1:begin addra_1 <= addra_write; addra_0 <= 15'd0; end 
		endcase 
end
////////*****************ram_read  ram_read_next *******************//////// 
reg  [2:0]	ram_read_next 	=  3'd0;

always@(posedge clk_50M)
begin
	if(rst)
		ram_read_next <= 3'd0;
	else
		if(counter_50M >= 22'd1249999 && data_send_begin)
			if(ram_wait == 1'b0)
				case(ram_read[2])
					1'b0:ram_read_next <= 3'd4;
					1'b1:ram_read_next <= 3'd0;
				endcase 
			else
				ram_read_next <= ram_read_next + 1'b1;
end

reg  [2:0] ram_read	= 3'd0;

always@(posedge clk_50M)
begin
	if(rst)
		ram_read <= 3'd0;
	else
		if(data_send_nd_d1 && !data_send_nd)
			ram_read <= ram_read_next;
end
////////*****************data_send_nd  data_send_byte  *******************//////// 
reg  [21:0]	addra_write_d1 	=  22'd0;

always@(posedge clk_50M)
begin
	if(rst)
		addra_write_d1 <= 22'd0;
	else
		if(data_send_begin)
			addra_write_d1 <= addra_write;
end

always@(posedge clk_125M)
begin
	if(rst)
	begin
		data_send_byte 	<=13'd0;	
		data_send_nd 	<= 1'b0;
	end
	else
		if(data_send_begin && counter_50M == 22'd0)
			case(ram_read)
				3'd0:begin data_send_nd <= 1'b1; if(addra_write_d1 == 15'd0)     data_send_byte <= 13'd0; else data_send_byte <= send_byte_0; end
				3'd1:begin data_send_nd <= 1'b1; if(addra_write_d1 == 15'd7424)  data_send_byte <= 13'd0; else data_send_byte <= send_byte_1; end
				3'd2:begin data_send_nd <= 1'b1; if(addra_write_d1 == 15'd14848) data_send_byte <= 13'd0; else data_send_byte <= send_byte_2; end
				3'd3:begin data_send_nd <= 1'b1; if(addra_write_d1 == 15'd22272) data_send_byte <= 13'd0; else data_send_byte <= send_byte_3; end
				3'd4:begin data_send_nd <= 1'b1; if(addra_write_d1 == 15'd0)	 data_send_byte <= 13'd0; else data_send_byte <= send_byte_4; end
				3'd5:begin data_send_nd <= 1'b1; if(addra_write_d1 == 15'd7424)  data_send_byte <= 13'd0; else data_send_byte <= send_byte_5; end
				3'd6:begin data_send_nd <= 1'b1; if(addra_write_d1 == 15'd14848) data_send_byte <= 13'd0; else data_send_byte <= send_byte_6; end
				3'd7:begin data_send_nd <= 1'b1; if(addra_write_d1 == 15'd22272) data_send_byte <= 13'd0; else data_send_byte <= send_byte_7; end
			endcase
		else 
			if(((addrb_read >= (data_send_byte - 1'b1)) && counter_125M_32 == 5'd31 && send_state == 4'd9) || data_send_byte == 13'd0)
				data_send_nd <= 1'b0;
end
////////*****************addrb_read*******************////////
reg  [14:0] addrb_read = 15'd0;

always@(posedge clk_125M)
begin
	if(rst)
		addrb_read <= 15'd0;
	else
		if(data_send_nd)
		begin
			if(counter_125M == 9'd319 && counter_byte_422 < data_send_byte) 
				addrb_read <= addrb_read + 1'b1;
		end
		else	
			addrb_read <= 15'd0;
end
////////*****************counter_125M*******************//////// 
reg  [8:0]	counter_125M	= 9'd0;

always@(posedge clk_125M)
begin
	if(data_send_nd)
		if(counter_125M >= 9'd319)
			counter_125M <= 3'd0;
		else
			counter_125M <= counter_125M + 1'b1;
	else
		counter_125M <= 9'd0;
		
end

////////*****************addrb_0 addra_1*******************////////
reg  [14:0] addrb_0 = 15'd0;
reg  [14:0] addrb_1 = 15'd0;

always@(posedge clk_125M)
begin
	if(rst)
	begin 
		addrb_0 <= 15'd0;
		addrb_1 <= 15'd0;
	end
	else
		case(ram_read)
			3'd0:begin addrb_0 <= 15'd0 	+ addrb_read; addrb_1 <= 15'd0; end
			3'd1:begin addrb_0 <= 15'd7424 	+ addrb_read; addrb_1 <= 15'd0; end
			3'd2:begin addrb_0 <= 15'd14848 + addrb_read; addrb_1 <= 15'd0; end
			3'd3:begin addrb_0 <= 15'd22272 + addrb_read; addrb_1 <= 15'd0; end
			3'd4:begin addrb_1 <= 15'd0 	+ addrb_read; addrb_0 <= 15'd0; end
			3'd5:begin addrb_1 <= 15'd7424 	+ addrb_read; addrb_0 <= 15'd0; end
			3'd6:begin addrb_1 <= 15'd14848 + addrb_read; addrb_0 <= 15'd0; end
			3'd7:begin addrb_1 <= 15'd22272 + addrb_read; addrb_0 <= 15'd0; end
		endcase
end
////////*****************data_send*******************////////
always@(posedge clk_125M)
begin
	if(rst)
		data_send <= 8'd0;
	else
		case(ram_read[2])
			1'b0:data_send <= data_read_0;
			1'b1:data_send <= data_read_1;
		endcase		
end
////////*****************RAM*******************//////// 
wire 		wea_0;			
wire 		wea_1;

assign wea_0 = ~ram_write[2] & data_recv_nd;
assign wea_1 =  ram_write[2] & data_recv_nd;

wire [7:0]	data_read_0;
wire [7:0]	data_read_1;

RAM_video RAM_video_0 (
  .clka(clk_50M), 	// input clka					写时钟
  .wea(wea_0), 		// input [0 : 0] wea            写使能
  .addra(addra_0), 	// input [10 : 0] addra        	写地址
  .dina(data_recv), // input [7 : 0] dina           写数据
  .clkb(clk_125M), 	// inputnp clkb                   读时钟
  .addrb(addrb_0), 	// iut [10 : 0] addrb         读地址
  .doutb(data_read_0) // output [7 : 0] doutb         读数据
);

RAM_video RAM_video_1 (
  .clka(clk_50M), 	// input clka					写时钟
  .wea(wea_1),  	// input [0 : 0] wea            写使能
  .addra(addra_1), 	// input [10 : 0] addra        	写地址
  .dina(data_recv), // input [7 : 0] dina           写数据
  .clkb(clk_125M), 	// input clkb                   读时钟
  .addrb(addrb_1), 	// input [10 : 0] addrb        	读地址
  .doutb(data_read_1) // output [7 : 0] doutb         读数据
);

endmodule
