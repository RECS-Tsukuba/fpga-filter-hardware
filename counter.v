`timescale 1ns / 100ps

module counter #(
  parameter WIDTH = 4,
  parameter INIT = 4'b0
) (
  output [WIDTH - 1: 0] count,
  input [WIDTH - 1: 0] limit,
  input enable,
  input reset,
  input clock
);

always @(posedge clock) begin
  if (reset) begin
    count <= INIT;
  end else if(!enable) begin
    count <= count;
  end else begin
    count <= (count == limit)? limit: (count + 1);
  end
end
endmodule

