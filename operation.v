module operation	#(
	parameter Ope_Size	=	3
	)(
	input [9*Ope_Size*Ope_Size-1:0]data_bus,
	input	clk,
	input	rst,
	input	reflesh,
	output	[8:0]out
	);

parameter DELAY  = 8;

integer i;







wire	 [8:0]		d[Ope_Size-1:0][Ope_Size-1:0];
wire	 valid_in;
wire [7:0]	p[Ope_Size-1:0][Ope_Size-1:0];

reg queue[DELAY-1:0];
reg [7:0] pixel_out;
reg	valid_out;


reg [9:0] gx_0;
reg [9:0] gx_1;

reg [10:0] deff;
reg [9:0] abs;
					 

genvar x,y;
generate	
	for(y = 0; y < Ope_Size; y = y + 1) begin: loop_y
		for(x = 0; x < Ope_Size; x = x + 1) begin: loop_x
			assign d[y][x]	= data_bus[(((y*Ope_Size)+x)*9)+:9];
			assign p[y][x]	= d[y][x][0+:8];
		end
	end
endgenerate

assign valid_in = d[Ope_Size/2][Ope_Size/2][8];
assign out[8] = valid_out;
assign out[7:0]	=	pixel_out;

/*
assign d[0][0]	=	data_bus[ 0+:9];
assign d[0][1]	=	data_bus[ 9+:9];
assign d[0][2]	=	data_bus[18+:9];
assign d[1][0]	=	data_bus[27+:9];
assign d[1][1]	=	data_bus[36+:9];
assign d[1][2]	=	data_bus[45+:9];
assign d[2][0]	=	data_bus[54+:9];
assign d[2][1]	=	data_bus[63+:9];
assign d[2][2]	=	data_bus[72+:9];
*/

/*
assign	p_00 = d[0][0][7:0];
assign	p_01 = d[0][1][7:0];
assign	p_02 = d[0][2][7:0];
assign	p_10 = d[1][0][7:0];
assign	p_11 = d[1][1][7:0];
assign	p_12 = d[1][2][7:0];
assign	p_20 = d[2][0][7:0];
assign	p_21 = d[2][1][7:0];
assign	p_22 = d[2][2][7:0];
*/




always @(posedge clk) begin
	if(rst|reflesh) begin
		pixel_out <= 0;
		valid_out	<=0;

		for(i = 0; i < DELAY; i = i + 1) begin // i++, ++iとは記述できない
			queue[i] <= 0;
		end
	end
	else begin

		/*
		queue[0]<=valid_in;
		for(i = 0; i < DELAY-1; i = i + 1) begin // i++, ++iとは記述できない
			queue[i+1] <= queue[i];
		end
		*/
		
		//queue[delay]=valid
	
			/////////////////////////////////////////////////////////
			// 演算回路(未実装)					　　　　　　			 //
			/////////////////////////////////////////////////////////
			
			/*	ここに各自フィルタ演算回路を記述 */
	
		/*
		gx_0 <= (p[0][0] + p[2][0]) + 2 * p[1][0];
		gx_1 <= (p[0][2] + p[2][2]) + 2 * p[1][1];
		deff	<= gx_0 - gx_1;
		abs<=
			(deff[10]==0)? deff:-deff;
		pixel_out <= (abs>>2);
		
		queue[0]<=valid_in;
		queue[1]<=queue[0];
		queue[2]<=queue[1];
		valid_out<=queue[2];
		*/
		/*
		if(d_21[8])	begin
			pixel_out<=d_21[7:0];
		end
		else begin
			pixel_out <= 8'hff;
		end
		*/
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
