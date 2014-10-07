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
		parameter SRAMDATA_WIDTH = 32,
		parameter TAG_WIDTH = 2
		) (
		   output reg request0, request1,
		   output reg command_entry0, command_entry1,
		   output reg write_enable1,
		   output [ADDRESS_WIDTH - 1: 0] address0, address1,
		   output reg [TAG_WIDTH - 1: 0] tag0,
		   output reg [SRAMDATA_WIDTH - 1: 0] data_out1,
		   output reg is_end,

		   output reg [31:0]debug_signal0,
		   output reg [31:0]debug_signal1,
		   output reg [31:0]debug_signal2,
		   output reg [31:0]debug_signal3,


		   input valid0, valid1,
		   input [SRAMDATA_WIDTH - 1: 0] query0,
		   input [TAG_WIDTH - 1: 0] qtag0,
		   input ready0, ready1,

		   input [31: 0] image_size,
		   input [9: 0] image_width,
		   input user_flag,
		   input [9: 0] pos_x,
		   input [9: 0] pos_y,
		   input refresh,
		   input reset,
		   input clock
		   );

   //! Constants
   parameter INVALID_TAG = 2'd0;
   parameter DATA_TAG0 = 2'd1;
   parameter DATA_TAG1 = 2'd2;
   parameter DATA_END_TAG = 2'd3;





   //! Implement

   wire	[TAG_WIDTH-1:0] is_tag_in;
   wire	[TAG_WIDTH-1:0] is_tag_out;


   wire [7:0]	pixel_in;
   wire [7:0]	pixel_out;

   wire [8+TAG_WIDTH-1:0]	data_in;
   wire [8+TAG_WIDTH-1:0]	data_out;



   reg	[1:0]	count0;
   reg	[1:0]	count1;
   reg [9:0] width_count;

   reg [31:0] system_count;

   reg	[ADDRESS_WIDTH:0]	ptr0;
   reg	[ADDRESS_WIDTH:0]	ptr1;


   reg [TAG_WIDTH-1:0]tag_in;
   reg [TAG_WIDTH-1:0]tag_out;


   reg start;

   reg [SRAMDATA_WIDTH-1:0] word_in;



   assign is_tag_in = (valid0 && is_end==1'b0)?  qtag0 : INVALID_TAG;

   assign pixel_in= word_in[0+:8];

   assign data_in[8+:TAG_WIDTH] = tag_in;
   assign data_in[0+:8] = pixel_in;

   assign pixel_out	=	data_out[0+:8];
   assign is_tag_out = data_out[8+:TAG_WIDTH];


   assign address0 = (ptr0>>2);
   assign address1 = (ptr1>>2);


   always @(posedge clock) begin

      debug_signal0 <= (reset) ? 32'h0: pos_x;

      debug_signal1 <= (reset) ? 32'h0: pos_y;


      debug_signal2 <= (reset) ? 32'h0: 32'h0;

      debug_signal3 <= (reset) ? 32'h0: 32'h0;


      start <=
	      (reset|refresh)? 1'b1: (
				      (is_tag_in==DATA_TAG0||is_tag_in==DATA_TAG1)? 1'b0 : (
											    start));
      system_count <=
	     (reset|refresh)? 32'h0: (
				      (system_count == (image_size<<2))? (image_size<<2): system_count + 32'h1);


      tag_in <=
	       (reset|refresh)? INVALID_TAG:is_tag_in;

      tag_out <=
		(reset|refresh)? INVALID_TAG:is_tag_out;

      
      request0 <=
		 (reset)? 1'b0: (
				 (refresh)? 1'b1: (
						   (is_end)? 1'b0: (
								    request0)));
      request1 <=
		 (reset)? 1'b0: (
				 (refresh)? 1'b1: (
						   (is_end)? 1'b0: (
								    request1)));
      command_entry0 <=  
			 (reset | refresh)? 0: (
						ready0);
      
      command_entry1 <=  
			 (reset | refresh| is_end)? 0: (
							(ready1&(count1==2'b10)&(start==1'b0))? 1 : (
												     0));
      
      write_enable1 <=
		      (reset | refresh | is_end)? 0: (
						      ready1);


      ptr0 <=
	     (reset|refresh)? 32'h0: (
				      (ptr0 == image_size)? image_size: (
									 (ready0)? ptr0 + 1: (
											      ptr0)));
      width_count <=
		    (reset|refresh)? 10'b0 : (
					      (width_count==(image_width-10'h1))? 10'b0 :(
											  (ready0)? width_count+10'b01:width_count));

      ptr1 <=
	     (reset|refresh|start)? 32'h0: (
					    ((ptr1 == image_size))? image_size: (
										 (ready1 && (tag_out==DATA_TAG0||tag_out==DATA_TAG1))? ptr1 + 1: (
																		  ptr1)));


      tag0 <=
	     (reset | refresh| is_end | (!ready0) )? INVALID_TAG: (
								   (ptr0 == image_size)? DATA_END_TAG:(
												       (width_count==(image_width-10'h1))? DATA_TAG1: DATA_TAG0));

      count0 <=
	       (reset|refresh)? 2'b00 : (
					 (ready0 &(tag_in==DATA_TAG0||tag_in==DATA_TAG1)&(start==1'b0))? count0+2'b01: (
															count0));

      count1 <=
	       (reset|refresh)? 2'b00 : (
					 (ready1 & (tag_out==DATA_TAG0||tag_out==DATA_TAG1))? count1+2'b01: (
													     count1));
      
      word_in <= 
		 (is_end)? 32'h0:(
				  (reset|refresh|start)? query0 : (
								   (count0==2'b11)? query0:(word_in >>	8)));
      
      

      
      data_out1[23: 0]<= (data_out1[31:8]);
      
      data_out1[31:24]<=pixel_out;

      is_end <=
	       (reset|refresh)? 0: (
				    (ptr1 == (image_size) || system_count == (image_size<<2) )? 1: (
													   is_end));

   end

   //Ope_Width must be odd
   filter_unit #(
    		 .TAG_WIDTH(TAG_WIDTH),
    		 .INVALID_TAG(INVALID_TAG),
    		 .DATA_TAG0(DATA_TAG0),
    		 .DATA_TAG1(DATA_TAG1),
    		 .DATA_END_TAG(DATA_END_TAG),
    		 .OPE_WIDTH(3)

    		 )fil_uni (
    			   .data_in(data_in),
    			   .image_width(image_width),
    			   .clk(clock),
    			   .rst(reset),
    			   .refresh(refresh),
    			   .data_out(data_out)
    			   );

endmodule
