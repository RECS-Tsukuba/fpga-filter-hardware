module operation(d_00, d_01, d_02,
				 	  d_10, d_11, d_12,
				 	  d_20, d_21, d_22,
				 	   clk,  rst,	out);

parameter DELAY  = 8;

integer i;

input	 [8:0]		d_00,d_01,d_02,	// 3×3レジスタからの入力
						d_10,d_11,d_12,
						d_20,d_21,d_22;
						
input					clk,rst;



output [8:0] out;


reg [9:0] gx_0;
reg [9:0] gx_1;

reg [10:0] deff;
reg [9:0] abs;


reg queue[DELAY-1:0];

wire	 valid_in;
wire [7:0]	p_00,p_01,p_02,
					p_10,p_11,p_12,
				  	p_20,p_21,p_22;


reg [7:0] pixel_out;
reg	valid_out;							 


assign	p_00 = d_00[7:0];
assign	p_01 = d_01[7:0];
assign	p_02 = d_02[7:0];
assign	p_10 = d_10[7:0];
assign	p_11 = d_11[7:0];
assign	p_12 = d_12[7:0];
assign	p_20 = d_20[7:0];
assign	p_21 = d_21[7:0];
assign	p_22 = d_22[7:0];

assign valid_in = d_11[8];

assign out[8] = valid_out;
assign out[7:0]	=	pixel_out;



always @(posedge clk) begin
	if(rst) begin
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
	
	
		gx_0 <= (p_00 + p_20) + 2 * p_10;
		gx_1 <= (p_02 + p_22) + 2 * p_11;
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
