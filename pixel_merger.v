`timescale 1ns / 100ps

module pixel_merger #(
  parameter 
    PIXEL_WIDTH = 8,
    DATA_WIDTH = 32 
) (
  output reg [DATA_WIDTH - 1: 0] data,
  output is_data_valid,
  input [PIXEL_WIDTH - 1: 0] pixel,
  input enable,
  input reset,
  input clock
);
parameter PIXEL_NUMBER = DATA_WIDTH / PIXEL_WIDTH;
parameter COUNTER_WIDTH = 2;


reg [COUNTER_WIDTH - 1: 0] count;


assign is_data_valid = count == 2'b11;

always @(posedge clock) begin
  if (reset) begin
    data <= 0;
  end if (!enable) begin
    data <= data;
  end else begin
    data <= {pixel, data[31:8]};
  end

  if (reset) begin
    count <= 0;
  end if (!enable) begin
    count <= count;
  end else begin
    count <= count + 1;
  end
end
endmodule
