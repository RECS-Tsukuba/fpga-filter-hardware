module operation	#(
	parameter Ope_Size=3;
)(
	input [8:0]	d[Ope_Size-1:0][Ope_size-1:0],
	input	clk,
	input rst,
	input reflesh,
	output [8:0] out
	);


parameter DELAY  = 8;

integer i;




wire	 valid_in;
wire [7:0]	p[Ope_Size-1:0][Ope_size-1:0];


reg [7:0] pixel_out;
reg	valid_out;							 
reg [9:0] gx_0;
reg [9:0] gx_1;

reg [10:0] deff;
reg [9:0] abs;


reg queue[DELAY-1:0];


for(i = 0; i < Ope_Size; i = i + 1) begin // i++, ++iとは記述できない
	for(j = 0; j < Ope_Size; j = j + 1) begin
		assign p[i][j]	= d[0+:8];
	end
end
assign valid_in = d[Ope_Size/2][Ope_Size/2][8];
assign out[8] = valid_out;
assign out[7:0]	=	pixel_out;



always @(posedge clk) begin
	if(rst|reflesh) begin
		pixel_out <= 8'h0;
		valid_out	<=1'b0;

		for(i = 0; i < DELAY; i = i + 1) begin // i++, ++iとは記述できない
			queue[i] <= 1'b0;
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
		
		/*
		if(d_21[8])	begin
			pixel_out<=p_21;
		end
		else begin
			pixel_out <= 8'hff;
		end
		valid_out	<=		valid_in;
		*/
		/*
		pixel_out	<=	p_11;
		valid_out	<=	valid_in;
		*/
	end
end


/////////////////////////////////////////////////////////
// 絶対値演算ユニット 　　　　　　			 			    //
/////////////////////////////////////////////////////////

/* ここで課題で作成した絶対値の演算回路を
                   モジュール呼び出しする */




endmodule
