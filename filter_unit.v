module filter_unit	#(
			  parameter TAG_WIDTH = 2,
			  parameter INVALID_TAG = 2'd0,
			  parameter DATA_TAG0 = 2'd1,
			  parameter DATA_TAG1 = 2'd2,
			  parameter DATA_END_TAG = 2'd3,
			  parameter OPE_WIDTH = 3,
			  parameter DATA_WIDTH = 8 + TAG_WIDTH
			  )(
			    input [DATA_WIDTH-1:0]	data_in,
			    input	[31:0]	image_width,
			    input	clk,
			    input rst,
			    input reflesh,
			    output [DATA_WIDTH-1:0]	data_out
			    );
   integer i,j;



   ///////////////////////////////////////////////////////////////////////////////////////
   // ここから下のソースを必要に応じて追記、変更してください 
   reg	 [DATA_WIDTH-1:0]		d[OPE_WIDTH-1:0][OPE_WIDTH-1:0];

   reg    [9:0]		  	 raddr,waddr;		
	// アドレス生成用レジスタ



   wire	 [DATA_WIDTH-1:0] buf_out[OPE_WIDTH-1:0];
   wire [DATA_WIDTH*OPE_WIDTH*OPE_WIDTH-1:0]data_bus;

   wire [31:0]hoge = image_width - 32'h1;

   genvar x,y;
   generate
      for(y = 0; y < OPE_WIDTH; y = y + 1) begin: loop_y
	 for(x = 0; x < OPE_WIDTH; x = x + 1) begin: loop_x
	    assign data_bus[(((y*OPE_WIDTH)+x)*DATA_WIDTH)+:DATA_WIDTH]	=	d[y][x];
	 end
      end
   endgenerate

   assign buf_out[OPE_WIDTH-1] = data_in;

   always @(posedge clk) begin
      if(rst|reflesh) begin
	 raddr     <= 0;
	 waddr		 <= 0;
	 for(i = 0; i < OPE_WIDTH; i = i + 1) begin // i++, ++iとは記述できない
	    for(j = 0; j < OPE_WIDTH; j = j + 1) begin
	       d[i][j]	<= 0;
	    end
	 end
      end
      else begin

	 /////////////////////////////////////////////////////////
	 // Unit_2 : OPE_WIDTH×OPE_WIDTHシフトレジスタ								 //
	 /////////////////////////////////////////////////////////

	 for(i = 0; i < OPE_WIDTH; i = i + 1) begin // i++, ++iとは記述できない
	    for(j = 0; j < OPE_WIDTH; j = j + 1) begin
	       if(j==OPE_WIDTH-1)	begin
		  d[i][j]<=buf_out[i];
	       end
	       else begin
		  d[i][j]	<=	d[i][j+1];
	       end
	    end
	 end

	 
	 /********************************************************
	  ** Control_2 : BlockRAMのアドレス生成回路		**
	  ********************************************************/

	 waddr <= raddr;
	 if(raddr == hoge[9:0])	// 1行分のアドレス
	   raddr <= 0;
	 else
	   raddr <= raddr + 1;
      end
   end

   /////////////////////////////////////////////////////////
	   // Unit_3 : 演算回路(モジュール呼び出し)				　　//
	   /////////////////////////////////////////////////////////

   // 演算回路の呼び出し
   operation #(
  	       .TAG_WIDTH(TAG_WIDTH),
   	       .INVALID_TAG(INVALID_TAG),
   	       .DATA_TAG0(DATA_TAG0),
   	       .DATA_TAG1(DATA_TAG1),
   	       .DATA_END_TAG(DATA_END_TAG),
	       .OPE_WIDTH(OPE_WIDTH)
	       )ope(
		    .data_bus(data_bus),
		    .clk (clk),
		    .rst (rst),
		    .reflesh(reflesh),
		    .out (data_out)
		    );


   /////////////////////////////////////////////////////////
   // BlockRAMs (depth=ImageWidth width=8bit)			 			    //
   /////////////////////////////////////////////////////////


    generate
       for(y = 0; y < OPE_WIDTH-1; y = y + 1) begin: Gen_linebuffer
    	 blockram_10b1024 line_buffer_y (
    					 .addra(waddr),
    					 .addrb(raddr),
    					 .clka(clk),
    					 .clkb(clk),
    					 .dina(buf_out[y+1]),
    					 .doutb(buf_out[y]),
    					 .wea(1'b1)
    					 );
       end
    endgenerate

endmodule
