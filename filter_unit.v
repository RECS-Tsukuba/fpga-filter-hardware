module filter_unit	#(
	parameter Ope_Size = 3
	)(
	input [8:0]	data_in,
	input	[31:0]	image_width,
	input	clk,
	input rst,
	input reflesh,
	output [8:0]	data_out
	);
integer i,j;
	
///////////////////////////////////////////////////////////////////////////////////////
// ここから下のソースを必要に応じて追記、変更してください 
reg	 [8:0]		d[Ope_Size-1:0][Ope_Size-1:0];
reg    [9:0]		  	 raddr,waddr;			// アドレス生成用レジスタ



wire	 [8:0] buf_out[Ope_Size-1:0];
wire [9*Ope_Size*Ope_Size-1:0]data_bus;


genvar x,y;
generate
	for(y = 0; y < Ope_Size; y = y + 1) begin: loop_y
		for(x = 0; x < Ope_Size; x = x + 1) begin: loop_x
			assign data_bus[(((y*Ope_Size)+x)*9)+:9]	=	d[y][x];
		end
	end
endgenerate

assign buf_out[0] = data_in;

always @(posedge clk) begin
	if(rst|reflesh) begin
				

		raddr     <= 0;
		waddr		 <= 0;
		for(i = 0; i < Ope_Size; i = i + 1) begin // i++, ++iとは記述できない
			for(j = 0; j < Ope_Size; j = j + 1) begin
				d[i][j]	<= 9'h0;
			end
		end	
	end
	else begin

		/////////////////////////////////////////////////////////
		// Unit_2 : 3×3シフトレジスタ								 //
		/////////////////////////////////////////////////////////
		/*
		d[0][0]	<= data_in;
		for(i = 0; i < Ope_Size-1; i = i + 1) begin // i++, ++iとは記述できない
			d[i+1][0]	<=	buf_out[i];
		end	
		for(i = 0; i < Ope_Size; i = i + 1) begin // i++, ++iとは記述できない
			for(j = 0; j < Ope_Size-1; j = j + 1) begin
				d[i][j+1]	<=	d[i][j];
			end
		end
		*/

		for(i = 0; i < Ope_Size; i = i + 1) begin // i++, ++iとは記述できない
			for(j = 0; j < Ope_Size; j = j + 1) begin
				if(j==0)	begin
					d[i][j]<=buf_out[i];
				end
				else begin
					d[i][j]	<=	d[i][j-1];
				end
			end
		end

		/*
		d[2][0] <= buf_out[1];		// BlockRAM #0の出力データを代入
		d[2][1] <= d[2][0];
		d[2][2] <= d[2][1];

		d[1][0] <= buf_out[0];		// BlockRAM #1の出力データを代入
		d[1][1] <= d[1][0];
		d[1][2] <= d[1][1];

		d[0][0] <= data_in;		// Unit_1より代入
		*/

		
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
operation #(
	.Ope_Size(Ope_Size)
	)ope(
	.data_bus(data_bus),
	.clk (clk),
	.rst (rst),
	.reflesh(reflesh),
	.out (data_out)
	);


/////////////////////////////////////////////////////////
// BlockRAMs (depth=640 width=8bit)			 			    //
/////////////////////////////////////////////////////////

// 画像2行分のバッファ
/*
blockram_9b1024 line_buffer0 (
	.addra(waddr),
	.addrb(raddr),
	.clka(clk),
	.clkb(clk),
	.dina(data_in),
	.doutb(buf_out[0]),
	.wea(1'b1));
blockram_9b1024 line_buffer1 (
	.addra(waddr),
	.addrb(raddr),
	.clka(clk),
	.clkb(clk),
	.dina(buf_out[0]),
	.doutb(buf_out[1]),
	.wea(1'b1));
*/

generate
	for(y = 0; y < Ope_Size-1; y = y + 1) begin: Gen_linebuffer
		blockram_10b1024 line_buffer_y (
			.addra(waddr),
			.addrb(raddr),
			.clka(clk),
			.clkb(clk),
			.dina(buf_out[y]),
			.doutb(buf_out[y+1]),
			.wea(1'b1)
			);
	end
endgenerate

endmodule
