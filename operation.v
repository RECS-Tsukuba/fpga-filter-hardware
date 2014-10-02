module operation	#(
	parameter Ope_Size	=	3
	)(
	input [9*Ope_Size*Ope_Size-1:0]data_bus,
	input	clk,
	input	rst,
	input	reflesh,
	output	[8:0]out
	);


wire	 [8:0]		d[Ope_Size-1:0][Ope_Size-1:0];
wire	 valid_in;
wire [7:0]	p[Ope_Size-1:0][Ope_Size-1:0];


reg [7:0] pixel_out;
reg	valid_out;

		 
//
genvar x,y;
generate	
	for(y = 0; y < Ope_Size; y = y + 1) begin: ope_loop_y
		for(x = 0; x < Ope_Size; x = x + 1) begin: ope_loop_x
			assign d[y][x]	= data_bus[(((y*Ope_Size)+x)*9)+:9];
			assign p[y][x]	= d[y][x][0+:8];
		end
	end
endgenerate

assign valid_in = d[Ope_Size/2][Ope_Size/2][8];
assign out[8] = valid_out;
assign out[7:0]	=	pixel_out;





always @(posedge clk) begin
	if(rst|reflesh) begin
		pixel_out <= 0;
		valid_out	<=0;
	end
	else begin


	
		/////////////////////////////////////////////////////////
		// 演算回路(未実装)					　　　　　　			 //
		/////////////////////////////////////////////////////////
		
		/*	ここに各自フィルタ演算回路を記述 */


		
		pixel_out	<=	p[Ope_Size/2][Ope_Size/2];
		valid_out	<=		valid_in;
		
	end
end


/////////////////////////////////////////////////////////
// 絶対値演算ユニット 　　　　　　			 			    //
/////////////////////////////////////////////////////////

/* ここで課題で作成した絶対値の演算回路を
                   モジュール呼び出しする */




endmodule
