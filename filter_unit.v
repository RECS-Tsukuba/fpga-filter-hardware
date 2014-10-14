`timescale 1ns / 1ps
module filter_unit	#(
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
											//各画素値のbit幅（tag（2b）+画素値（8b））
											parameter DATA_WIDTH = 8 + TAG_WIDTH
											)(
												//入力画素10b（tag[2b]+pixel[8b]）
												input [DATA_WIDTH-1:0]	data_in,
												//画像幅
												input [9:0]							image_width,
												input										clk,
												//rst信号は動作開始時にon
												input										rst,
												//refresh信号は各フレームの開始時にon
												input										refresh,
												//出力画素10b（tag[2b]+pixel[8b]）
												output [DATA_WIDTH-1:0] data_out
												);
		//for文用の変数宣言
		integer																			i,j;


		//画素データ用レジスタ(pixel(8b)+tag(2b))
		reg [DATA_WIDTH-1:0]												d[OPE_WIDTH-1:0][OPE_WIDTH-1:0];

		// アドレス生成用レジスタ
		reg [9:0]																		raddr,waddr;		



		//line_buffer用wire
		wire [DATA_WIDTH-1:0]												buf_out[OPE_WIDTH-1:0];

		//下位モジュール接続用bus
		//OPE_SIZE^2のdata(10b)
		wire [DATA_WIDTH*OPE_WIDTH*OPE_WIDTH-1:0]		data_bus;

		
		//generate文用変数の宣言
		genvar																			x,y;
		//databusとdataの対応付け
		generate
				for(y = 0; y < OPE_WIDTH; y = y + 1) begin: loop_y
						for(x = 0; x < OPE_WIDTH; x = x + 1) begin: loop_x
								assign data_bus[(((y*OPE_WIDTH)+x)*DATA_WIDTH)+:DATA_WIDTH]	= d[y][x];
						end
				end
		endgenerate

		assign buf_out[OPE_WIDTH-1] = data_in;


		always @(posedge clk) begin
				if(rst|refresh) begin
						raddr <= 0;
						waddr <= 0;
						//dataレジスタの初期化
						for(i = 0; i < OPE_WIDTH; i = i + 1) begin // i++, ++iとは記述できない
								for(j = 0; j < OPE_WIDTH; j = j + 1) begin
										d[i][j]	<= 0;
								end
						end
				end
				else begin

						/////////////////////////////////////////////////////////
						//OPE_WIDTH×OPE_WIDTHシフトレジスタ
						//特に用がなければ触らない
						///////////////////////////////////////////////////////////

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

						/////////////////////////////////////////////////////////
						//OPE_WIDTH×OPE_WIDTHシフトレジスタ　終わり
						///////////////////////////////////////////////////////////


						//Control : BlockRAMのアドレス生成回路（触らない）

						waddr <= raddr;
						if(raddr == image_width-9'h1)	// 1行分のアドレス
							raddr <= 0;
						else
							raddr <= raddr + 1;
				end
		end

		///////////////////////////////////////////////////////////
							// Unit_3 : 演算回路(モジュール呼び出し)
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
										 .refresh(refresh),
										 .out (data_out)
										 );


		/////////////////////////////////////////////////////////
		// BlockRAMs (depth=ImageWidth width=8bit)	の呼び出し
		/////////////////////////////////////////////////////////

		//OPE_WIDTHに応じてline_bufferの生成
		generate
				for(y = 0; y < OPE_WIDTH-1; y = y + 1) begin: Gen_linebuffer
						blockram_10b1024 line_buffer (
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
