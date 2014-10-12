`timescale 1ns / 100ps

module line_end_checker #(
  WIDTH = 8
) (
  output wire is_line_end,
  input [WIDTH - 1: 0] width,
  input enable,
  input reset,
  input clock
);
reg [WIDTH - 1: 0] count;


assign is_line_end = count == (width - 1);


always @(posedge clock) begin
  if (reset) begin
    count <= 0;
  end else if(!enable) begin
    count <= count;
  end else begin
    if (count == width - 1) begin
      count <= 0;
    end else begin
      count <= count + 1;
    end
  end
end
endmodule

