module vga_ctrl(
   input        			vga_clk,   //驱动时钟：40MHZ
	input        			rst_n,
	input    [23:0]   	 	rd_data,		//存储于双口RAM的图片
	
	output   reg[15:0]    	rd_addr,		//双口RAM读地址
	output        			   vga_hs,
	output        			   vga_vs,
	output   reg[23:0]     	vga_rgb,
	output       	VGA_BLANK_N,
	output       	VGA_SYNC_N
);

/********************************
800*600*60显示模式：
行：628（a:4 b:23 c:600 d:1）
列：1056（a:128 b:88 c:800 d:40）
*********************************/

assign VGA_BLANK_N = 1'b1;
assign VGA_SYNC_N  = 1'b0;

reg      [10:0]      cnt1;       //列计数器：1056
reg      [10:0]      cnt2;       //行计数器：628

//列计数
always @ (posedge vga_clk, negedge rst_n) begin
	if (rst_n == 1'b0)
		cnt1 <= 11'd0;
	else if (cnt1 < 11'd1055)
		cnt1 <= cnt1 + 1'd1 ;
	else
		cnt1 <= 11'd0 ;
end
//行计数
always @ (posedge vga_clk,negedge rst_n) begin
if (rst_n == 1'b0)
	cnt2 <= 11'd0 ;
else if(cnt2 == 11'd628 && cnt1 == 11'd1055)  //最后一行最后一列
	cnt2 <= 11'd0;		//行计数器清零
else if (cnt1 == 11 'd1055)  //有效显示行且最后一列
	cnt2 <=cnt2 + 1'd1;//行加一
else			//不在最后一列
	cnt2 <= cnt2;      //行保持不变
end

//行同步时序
assign  vga_hs = (cnt1<128)?1'b0 : 1'b1;
//列同步时序
assign  vga_vs = (cnt2<4)?1'b0 : 1'b1;

//圈中图片显示区域(200*180):且在显示区域中心位置
	reg				valid;										//显示区域标志信号
	
	always @ (*)	begin
		if(rst_n == 1'b0)
			valid = 1'b0;
		else	if((cnt1 >= 11'd516 && cnt1 < 11'd716) && (cnt2 >= 11'd237 && cnt2 < 11'd417))//*****		
			valid = 1'b1;
		else	
			valid = 1'b0;
	end

//assign vga_rgb = (valid == 1'b1) ? 8'b111_000_00 : 8'h0;
	
//控制读地址在图片显示区域变化
	always @ (posedge vga_clk, negedge rst_n)	begin
		if(rst_n == 1'b0)	begin
			rd_addr <= 16'd0;
			vga_rgb <= 24'h0;
		end
		else	if(valid == 1'b1)									//在图片显示区域内
			begin
				if(rd_addr < 16'd35999)		begin				//读地址在有效区间************
					rd_addr <= rd_addr + 1'd1;					//读地址自加一
					vga_rgb <= rd_data;							//对应地址上的数据给RGB
				end		
				else	begin											//不在地址区间内
					rd_addr <= 16'd0;								//地址清零
					vga_rgb <= 24'h0;								//不显示数据
				end
			end
		else															//不在图片显示区域内
			vga_rgb <= 24'h0;										//不显示数据
	end

endmodule