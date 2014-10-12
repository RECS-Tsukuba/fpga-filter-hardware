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
  parameter
    ADDRESS_WIDTH = 32,
    SRAMDATA_WIDTH = 32,
    TAG_WIDTH = 2,
    USER_REGISTER_WIDTH = 32,
    IMAGE_WIDTH_WIDTH = 10
) (
  output reg request0, request1,
  output reg command_entry0, command_entry1,
  output wire write_enable1,
  output [ADDRESS_WIDTH - 1: 0] address0, address1,
  output reg [TAG_WIDTH - 1: 0] tag0,
  output wire [SRAMDATA_WIDTH - 1: 0] data_out1,
  output reg is_end,

  output reg [USER_REGISTER_WIDTH - 1: 0]
    debug_signal0, debug_signal1, debug_signal2, debug_signal3,

  input valid0,// valid1,
  input [SRAMDATA_WIDTH - 1: 0] queue0,
  input [TAG_WIDTH - 1: 0] qtag0,
  input ready0, ready1,

  input [USER_REGISTER_WIDTH - 1: 0] image_size,
  input [IMAGE_WIDTH_WIDTH - 1: 0] image_width,
  input [USER_REGISTER_WIDTH - 1: 0] pos_x,
  input [USER_REGISTER_WIDTH - 1: 0] pos_y,
  input refresh,
  input reset,
  input clock
);
//! Constants
parameter PIXEL_WIDTH = 8;

parameter INVALID_TAG = 2'd0;
parameter DATA_TAG = 2'd1;
parameter LINE_END_TAG = 2'd2;
parameter DATA_END_TAG = 2'd3;


//! Signals
wire [ADDRESS_WIDTH - 1: 0] red_pixel_pointer;
reg [SRAMDATA_WIDTH-1:0] word_in;
reg [TAG_WIDTH-1:0]tag_in;

wire is_line_end;
wire [ADDRESS_WIDTH - 1: 0] written_pixel_pointer;
wire [PIXEL_WIDTH + TAG_WIDTH - 1: 0] filtered_data;
wire is_data_out1_valid;

reg  [1:0]  count_in;


//! Implement
// read command
assign address0 = red_pixel_pointer >> 2;

// pass sram data as a pixel and a tag
wire [PIXEL_WIDTH - 1: 0] pixel_in = word_in[0 +: PIXEL_WIDTH];
wire [PIXEL_WIDTH + TAG_WIDTH - 1: 0] data_in = {tag_in, pixel_in};
wire is_queue0_valid = qtag0 ==DATA_TAG || qtag0 == LINE_END_TAG;

// write command
assign address1 = written_pixel_pointer>> 2;
assign write_enable1 = !reset & !refresh & !is_end & ready1 & is_data_out1_valid;

wire [PIXEL_WIDTH - 1: 0] filtered_pixel = filtered_data[0+:8];
wire [TAG_WIDTH - 1: 0] filtered_tag = filtered_data[8+:TAG_WIDTH];

wire is_filtered_data_valid = filtered_tag== DATA_TAG | filtered_tag == LINE_END_TAG;

always @(posedge clock) begin
  // generate read commands
  request0 <=
    (reset)? 1'b0:(
    (refresh)? 1'b1: (
    (is_end)? 1'b0: (
      request0)));
  command_entry0 <=  (reset | refresh)? 1'b0: ready0;
  tag0 <=
    (reset | refresh | is_end | !ready0)? INVALID_TAG: (
    (red_pixel_pointer == image_size)? DATA_END_TAG:(
    (is_line_end)? LINE_END_TAG:
      DATA_TAG));

  // pass sram data as a pixel and a tag
  tag_in <=
     (reset | refresh | is_end | !valid0)? INVALID_TAG: qtag0;
  word_in <= 
    (is_end)? 32'h0: (
    (reset | refresh)? queue0 : (
    (!is_queue0_valid)? word_in: (
    (count_in == 2'b11)? queue0: (
      word_in >> 8))));
  count_in <=
    (reset|refresh)? 2'b00 : (
    (is_queue0_valid)? count_in + 2'b01:
      count_in);

  // generate write commands
  request1 <=
    (reset)? 1'b0: (
    (refresh)? 1'b1: (
    (is_end)? 1'b0: (
      request1)));
  command_entry1 <=  (reset | refresh| is_end)? 1'b0: ready1;
  is_end <=
    (reset | refresh)? 1'b0: (
    (written_pixel_pointer == image_size || filtered_tag == DATA_END_TAG)? 1'b1: (
      is_end));

  // User registers
  debug_signal0 <= (reset) ? 32'h0: pos_x;
  debug_signal1 <= (reset) ? 32'h0: pos_y;
  debug_signal2 <= (reset) ? 32'h0: 32'h0;
  debug_signal3 <= (reset) ? 32'h0: 32'h0;

  filtered_data <= data_in;
end

//! Modules
counter #(
  .WIDTH(USER_REGISTER_WIDTH),
  .INIT(0)
) red_pixel_pointer_generator (
  .count(red_pixel_pointer),
  .limit(image_size),
  .enable(is_queue0_valid),
  .reset(reset | refresh),
  .clock(clock)
);

counter #(
  .WIDTH(USER_REGISTER_WIDTH),
  .INIT(0)
) written_pixel_pointer_generator (
  .count(written_pixel_pointer),
  .limit(image_size),
  .enable(is_filtered_data_valid),
  .reset(reset | refresh),
  .clock(clock)
);

line_end_checker #(
  .WIDTH(IMAGE_WIDTH_WIDTH)
) line_end_checker0 (
  .is_line_end(is_line_end),
  .width(image_width),
  .enable(is_queue0_valid),
  .reset(reset | refresh),
  .clock(clock)
);

pixel_merger #(
  .PIXEL_WIDTH(PIXEL_WIDTH),
  .DATA_WIDTH(SRAMDATA_WIDTH)
) pixel_merger0 (
  .data(data_out1),
  .is_data_valid(is_data_out1_valid),
  .pixel(filtered_pixel),
  .enable(ready1 & is_filtered_data_valid),
  .reset(reset | refresh),
  .clock(clock)
);
   //Ope_Width must be odd
   filter_unit #(
         .TAG_WIDTH(TAG_WIDTH),
         .INVALID_TAG(INVALID_TAG),
         .DATA_TAG0(DATA_TAG),
         .DATA_TAG1(LINE_END_TAG),
         .DATA_END_TAG(DATA_END_TAG),
         .OPE_WIDTH(3)

         )fil_uni (
             .data_in(data_in),
             .image_width(image_width),
             .clk(clock),
             .rst(reset),
             .refresh(refresh),
             .data_out(filtered_data)
             );

endmodule

