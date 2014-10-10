`timescale 1ns / 1ps
module operation	#(
			  //各画素に付加されるtagのビット幅
			  parameter TAG_WIDTH = 2,
			  //tag値：無効値
			  parameter INVALID_TAG = 2'd0,
			  //tag値：有効値
			  parameter DATA_TAG0 = 2'd1,
			  //tag値：有効値（行末）
			  parameter DATA_TAG1 = 2'd2,
			  //tag値：無効値（終了）
			  parameter DATA_END_TAG = 2'd3,
			  //Operation Window幅（正方形）
			  parameter OPE_WIDTH = 3,
			  //各画素値のbit幅（画素値（8b）＋tag（2b））
			  parameter DATA_WIDTH = 8 + TAG_WIDTH
			  )(
			    //入力データバス
			    input [DATA_WIDTH*OPE_WIDTH*OPE_WIDTH-1:0]data_bus,
			    input	clk,
			    //rst信号は動作開始時にon
			    input	rst,
			    //refresh信号は各フレームの開始時にon
			    input	refresh,
			    //出力値（tag2b+画素値8b）
			    output	[DATA_WIDTH-1:0]out
			    );


   //各画素値8bは上位2bにtagが付加された10bで与えられます．
   //tagは，DATA_TAG0,DATA_TAG1,INVALID_DATA,DATA_END_TAGの四通りで，
   //それぞれ，有効データ，有効データ（行末），無効データ，終了データ（フレーム内の全ての画素値を転送し終えたあと）を意味します．
   
   //出力データも画素値にtagを付加した10bとなります．
   //上位モジュールでtag情報に基づいて，そのフレームの処理が終了したことを判定しているので
   //outの上位2bに正確なtag値を入力してください．
   

   //2次元配列dとiはそれぞれ，tagを含んだ10b，画素値のみの8bで構成されます．

   
   //入力画素値（タグ付き）
   //ビット幅　画素値8b+tag2bの10b
   // OPE_SIZE*OPE_SIZEの2次元配列
   wire	 [DATA_WIDTH-1:0]		d[OPE_WIDTH-1:0][OPE_WIDTH-1:0];
   wire	 [TAG_WIDTH-1:0]tag_in;

   //入力画素（ダグなし）
   //ビット幅8
   // OPE_SIZE*OPE_SIZEの2次元配列
   wire [8-1:0]	i[OPE_WIDTH-1:0][OPE_WIDTH-1:0];



   //出力画素値
   reg [8-1:0] pixel_out;
   //出力画素のtag
   reg	[TAG_WIDTH-1:0]tag_out;



   //generate文   
   //data_busから各画素（配列）への対応付け（基本的には触らない）
   genvar x,y;
   generate	
      for(y = 0; y < OPE_WIDTH; y = y + 1) begin: ope_loop_y
	 for(x = 0; x < OPE_WIDTH; x = x + 1) begin: ope_loop_x
	    assign d[y][x] = data_bus[(((y*OPE_WIDTH)+x)*DATA_WIDTH)+:DATA_WIDTH];
	    assign i[y][x] = d[y][x][0+:8];
	 end
      end
   endgenerate
   //ここまで

   //中心画素のtagを入力タグとして使用
   assign tag_in = d[OPE_WIDTH/2][OPE_WIDTH/2][8+:TAG_WIDTH];

   //tag_out,pixel_outをoutに対応付け
   assign out[8+:TAG_WIDTH] = tag_out;
   assign out[0+:8] = pixel_out;



   //画素値を参照したい場合はi[y][x]を使用してください。
   //出力画素値はpixel_out，そのtag値はtag_outを使用してください．

   always @(posedge clk) begin
      if(rst|refresh) begin
	 //出力を初期化
	 pixel_out <= 0;
	 tag_out <= 0;
      end
      else begin

	 /////////////////////////////////////////////////////////
	 // 演算回路(未実装)
	 /////////////////////////////////////////////////////////

	 //例：中心画素値をそのまま出力
	 pixel_out <= i[OPE_WIDTH/2][OPE_WIDTH/2];
	 tag_out <= tag_in;
	 
      end
   end

   /////////////////////////////////////////////////////////
   // 絶対値演算ユニット 　　　　　　	  	    //
   /////////////////////////////////////////////////////////

   /* ここで課題で作成した絶対値の演算回路を
    モジュール呼び出しする */

endmodule
