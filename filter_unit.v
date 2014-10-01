module filter_unit(data_in, image_width,	clk, rst, data_out);



input  [8:0]  data_in;
input  [31:0]	image_width;
input                 clk,rst;
output [8:0]  data_out;



///////////////////////////////////////////////////////////////////////////////////////
// ここから下のソースを必要に応じて追記、変更してください 


	





reg	 [8:0]		d_00,d_01,d_02,		// 3×3シフトレジスタ,8ビット
						d_10,d_11,d_12,
						d_20,d_21,d_22;

reg    [9:0]		  	 raddr,waddr;			// アドレス生成用レジスタ



wire	 [8:0] buf0_out,buf1_out;

always @(posedge clk) begin
	if(rst) begin
				

		raddr     <= 0;
		waddr		 <= 0;
		d_00	<=0;
		d_01	<=0;
		d_02	<=0;
		d_10	<=0;
		d_11	<=0;
		d_12	<=0;
		d_20	<=0;
		d_21	<=0;
		d_22	<=0;
	end else begin

			/////////////////////////////////////////////////////////
			// Unit_2 : 3×3シフトレジスタ								 //
			/////////////////////////////////////////////////////////
		
			d_02 <= buf0_out;		// BlockRAM #0の出力データを代入
			d_01 <= d_02;
			d_00 <= d_01;

			d_12 <= buf1_out;		// BlockRAM #1の出力データを代入
			d_11 <= d_12;
			d_10 <= d_11;

			d_22 <= data_in;		// Unit_1より代入
			d_21 <= d_22;
			d_20 <= d_21;


			
			/********************************************************
			** Control_2 : BlockRAMのアドレス生成回路			   	 **
		   ********************************************************/
		
			waddr <= raddr;
			if(raddr == image_width-32'h1)	// 1行分のアドレス
				raddr <= 0;
			else
				raddr <= raddr + 1;


	
	end
end



/////////////////////////////////////////////////////////
// Unit_3 : 演算回路(モジュール呼び出し)				　　//
/////////////////////////////////////////////////////////

// 演算回路の呼び出し
operation ope (
					.d_00(d_00),
					.d_01(d_01),
					.d_02(d_02),
					.d_10(d_10),
					.d_11(d_11),
					.d_12(d_12),
					.d_20(d_20),
					.d_21(d_21),
					.d_22(d_22),
					.clk (clk),
					.rst (rst),
					.out (data_out)
					);


/////////////////////////////////////////////////////////
// BlockRAMs (depth=640 width=8bit)			 			    //
/////////////////////////////////////////////////////////

// 画像2行分のバッファ
blockram_9b1024 line_buffer0 (
	.addra(waddr),
	.addrb(raddr),
	.clka(clk),
	.clkb(clk),
	.dina(buf1_out),
	.doutb(buf0_out),
	.wea(1'b1));

blockram_9b1024 line_buffer1 (
	.addra(waddr),
	.addrb(raddr),
	.clka(clk),
	.clkb(clk),
	.dina(data_in),
	.doutb(buf1_out),
	.wea(1'b1));



endmodule
