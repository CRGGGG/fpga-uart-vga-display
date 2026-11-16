module ram2_wr_ctrl(
	input							clk,				//uart_clk
	input							rst_n,			//rst
	input							rx_data_flag,	//received 8 bit finished flag
	
	
	output						wren,			//使能双口RAM
	output	reg	[15:0]	wr_addr		//根据图片大小******  双口RAM地址
	
);

	assign 		wren 	=	rx_data_flag;		//双口RAM写使能控制
	
	always	@	(posedge	clk,	negedge	rst_n)begin
	
		if(rst_n==1'b0)
			wr_addr <= 16'd0;
		else	if(rx_data_flag	==	1'b1 &&	wr_addr  == 16'd35999)  //接收最后一个数据
			wr_addr <= 16'd0;
	   else	if(rx_data_flag	==	1'b1 )									//每接受一字节数据且地址在有效地址区域（0~35999）
			wr_addr <= wr_addr + 1'd1;											//写地址自加一
		else 
			wr_addr <= wr_addr;													//写地址保持
	end

	
endmodule