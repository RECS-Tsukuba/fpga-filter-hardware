module operation	#(
			  parameter TAG_WIDTH = 2,
			  parameter INVALID_TAG = 2'd0,
			  parameter DATA_TAG0 = 2'd1,
			  parameter DATA_TAG1 = 2'd2,
			  parameter DATA_END_TAG = 2'd3,
			  parameter OPE_WIDTH = 3,
			  parameter DATA_WIDTH = 8 + TAG_WIDTH
			  )(
			    input [DATA_WIDTH*OPE_WIDTH*OPE_WIDTH-1:0]data_bus,
			    input	clk,
			    input	rst,
			    input	reflesh,
			    output	[DATA_WIDTH-1:0]out
			    );

   

   wire	 [DATA_WIDTH-1:0]		d[OPE_WIDTH-1:0][OPE_WIDTH-1:0];
   wire	 [TAG_WIDTH-1:0]tag_in;

   wire [7:0]	p[OPE_WIDTH-1:0][OPE_WIDTH-1:0];


   reg [7:0] pixel_out;
   reg	[TAG_WIDTH-1:0]tag_out;

   
   //
   genvar x,y;
   generate	
      for(y = 0; y < OPE_WIDTH; y = y + 1) begin: ope_loop_y
	 for(x = 0; x < OPE_WIDTH; x = x + 1) begin: ope_loop_x
	    assign d[y][x]	= data_bus[(((y*OPE_WIDTH)+x)*DATA_WIDTH)+:DATA_WIDTH];
	    assign p[y][x]	= d[y][x][0+:8];
	 end
      end
   endgenerate

   assign tag_in = d[OPE_WIDTH/2][OPE_WIDTH/2][8+:TAG_WIDTH];
   assign out[8+:TAG_WIDTH] = tag_out;
   assign out[0+:8]	=	pixel_out;





   always @(posedge clk) begin
      if(rst|reflesh) begin
	 pixel_out <= 0;
	 tag_out <= 0;
      end
      else begin



	 /////////////////////////////////////////////////////////
	 // 演算回路(未実装)					　　　　　　			 //
	 /////////////////////////////////////////////////////////
	 
	 /*	ここに各自フィルタ演算回路を記述 */


	 if(tag_in==DATA_TAG0) begin
	 	 pixel_out	<=	p[OPE_WIDTH/2][OPE_WIDTH/2];
		 tag_out	<=		tag_in;
	 end

	 else begin
		pixel_out	<=	8'hff;
		tag_out	<=		tag_in;
	 end

	 
      end
   end

   /////////////////////////////////////////////////////////
   // 絶対値演算ユニット 　　　　　　	  	    //
   /////////////////////////////////////////////////////////

   /* ここで課題で作成した絶対値の演算回路を
    モジュール呼び出しする */

endmodule
