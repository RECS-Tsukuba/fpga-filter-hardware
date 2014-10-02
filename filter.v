`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:26:07 09/22/2014 
// Design Name: 
// Module Name:    filter 
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
module filter #(
  parameter ADDRESS_WIDTH = 32,
  parameter DATA_WIDTH = 32,
  parameter TAG_WIDTH = 4
) (
  output reg request0, request1,
  output reg command_entry0, command_entry1,
  output reg write_enable1,
  output [ADDRESS_WIDTH - 1: 0] address0, address1,
  output reg [TAG_WIDTH - 1: 0] tag0,
  output reg [DATA_WIDTH - 1: 0] data_out1,
  output reg is_end,
  input valid0, valid1,
  input [DATA_WIDTH - 1: 0] query0,
  input [TAG_WIDTH - 1: 0] qtag0,
  input ready0, ready1,

  input [DATA_WIDTH - 1: 0] image_size,
  input [DATA_WIDTH - 1: 0] image_width,
  input reflesh,
  input reset,
  input clock
);
//! Constants
parameter INVALID_TAG = 2'd0;
parameter DATA_TAG = 2'd1;
parameter DATA_END_TAG = 2'd2;
//parameter SRAM_DELAY = 3;

integer i;


//! Implement
wire	is_valid_in;
wire	is_valid_out;

wire [7:0]	pixel_in;
wire [7:0]	pixel_out;

wire [8:0]	data_in;
wire [8:0]	data_out;

reg	[1:0]	count0;
reg	[1:0]	count1;

reg	[31:0]	ptr0;
reg	[31:0]	ptr1;

reg valid_in;
reg valid_out;

//reg	[TAG_WIDTH-1:0]	tag_queue[SRAM_DELAY-1:0];

reg start;

reg [DATA_WIDTH-1:0] word_in;


assign is_valid_in = ((qtag0 == DATA_TAG) & valid0)&(is_end==1'b0);

assign pixel_in= word_in[7:0];
assign data_in[8] = valid_in;
assign data_in[7:0] = pixel_in;

assign pixel_out	=	data_out[7:0];
assign is_valid_out = data_out[8];
//assign is_out_valid = is_in_valid;

assign address0 = (ptr0>>2);
assign address1 = ((ptr1)>>2);


always @(posedge clock) begin
	//word_in<=query0;
/*
	if(reset|reflesh)begin
		for(i = 0; i < SRAM_DELAY; i = i + 1) begin // i++, ++iとは記述できない
			tag_queue[i] <= 0;
		end
	end
	else begin
		tag_queue[0]	<=	qtag0;
		for(i = 0; i < SRAM_DELAY-1; i = i + 1) begin // i++, ++iとは記述できない
			tag_queue[i+1] <= tag_queue[i];
		end
	end
	*/
	start		<=
		(reset|reflesh)?	1'b1:	(
		(is_valid_in)?	1'b0	:	(
			start));
	valid_in <=
		(reset|reflesh)? 1'b0:
			(is_valid_in);
	valid_out <=
		(reset|reflesh)? 1'b0:
			(is_valid_out);

	
  request0 <=
    (reset)? 1'b0: (
    (reflesh)? 1'b1: (
    (is_end)? 1'b0: (
      request0)));
  request1 <=
    (reset)? 1'b0: (
    (reflesh)? 1'b1: (
    (is_end)? 1'b0: (
      request1)));
  command_entry0 <=  
    (reset | reflesh)? 0: (
      ready0);
		
  command_entry1 <=  
    (reset | reflesh)? 0: (
      (ready1&(count1==2'b10)&(start==1'b0))? 1 : (
		0));
		
  write_enable1 <=
    (reset | reflesh)? 0: (
      ready1 & is_valid_out);
  ptr0 <=
    (reset)? 32'hFFFFFFFF: (
    (reflesh)? 32'h0: (
    (ptr0 >= image_size)? image_size: (
    (ready0)? ptr0 + 1: (
      ptr0))));
  ptr1 <=
    (reset)? 32'hFFFFFFFF: (
    (reflesh|start)? 32'h0: (
    ((ptr1 >= image_size))? image_size: (
    (ready1 & valid_out)? ptr1 + 1: (
      ptr1))));
  tag0 <=
    (reset | reflesh)? INVALID_TAG: (
    (ptr0 >= image_size)? DATA_END_TAG: (
    (ready0)? DATA_TAG: (
      INVALID_TAG)));
		
	count0 <=
		(reset|reflesh)? 2'b00 : (
		(ready0 &(valid_in)&(start==1'b0))? count0+2'b01: (
			count0));
	count1 <=
		(reset|reflesh)? 2'b00 : (
		(ready1 & valid_out)? count1+2'b01: (
			count1));
			
	word_in <= 
		(is_end)? 32'h0:(
		(reset|reflesh|start)? query0 : (
		(count0==2'b11)? query0:(word_in >>	8)));
		
		
/*  data_out1[31:24] <= 8'd255 - query0[31:24];
  data_out1[23:16] <= 8'd255 - query0[23:16];
  data_out1[15: 8] <= 8'd255 - query0[15: 8];
  data_out1[ 7: 0] <= 8'd255 - query0[ 7: 0];*/
  
	data_out1[23: 0]<= (data_out1[31:8]);
   
	data_out1[31:24]<=pixel_out;

  is_end <=
		(reset)? 0: (
		(reflesh)? 0: (
		(ptr1 >= (image_size) )? 1: (
			is_end)));

end

//Ope_Size
filter_unit #(
		.Ope_Size(5)
	)fil_uni (
		.data_in(data_in),
		.image_width(image_width),
		.clk(clock),
		.rst(reset),
		.reflesh(reflesh),
		.data_out(data_out)
		);

endmodule

