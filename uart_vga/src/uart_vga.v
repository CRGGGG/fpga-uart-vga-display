//top
module uart_vga(
	input					sys_clk, 	//50MHZ
	input					sys_rst_n,	//negative
	input					rxd,			//recieve
	
	output	[23:0]	vga_rgb,		//RGB332***
	output				vga_hs,		//行
	output				vga_vs,		//列
	output       	VGA_BLANK_N,
	output       	VGA_SYNC_N	
   
);

/***********my_pll***********/

	wire					uart_clk;		//1.8MHZ
	wire					vga_clk;			//40MHZ
	wire					locked;			//输出时钟稳定的标志信号（1）稳定
	
/***********uart_rx***********/	
	wire					rx_data_flag;	//8bit flag
	wire			[23:0]	rx_data;			//recieve 8 bit******
	
/***********ram2_wr_ctrl***********/

	wire 					wren;				//双口RAM写使能
	wire 			[15:0]wr_addr;			//双口RAM写地址

/***********my_dpram***********/

	wire 			[23:0]	rd_data;			//双口RAM读数据
	wire 			[15:0]rd_addr;			//双口RAM读地址


//IPcore(c0 uart_clk c1 vga_clk)

	my_pll my_pll_dut (
			  .refclk(sys_clk),   //  refclk.clk
			  .rst(~sys_rst_n),      //   reset.reset
			  .outclk_0(uart_clk), // outclk0.clk
			  .outclk_1(vga_clk), // outclk1.clk
			  .locked(locked)    //  locked.export
		);

//UART_RX		
	uart_rx uart_rx_dut(
	.uart_clk(uart_clk),
	.rst_n(locked),
	.rxd(rxd),
	
	.rx_data_flag(rx_data_flag),
	.rx_data(rx_data)
	
);

//dpram_wr_ctrl
	ram2_wr_ctrl ram2_wr_ctrl_dut(
	.clk(uart_clk),				
	.rst_n(locked),			
	.rx_data_flag(rx_data_flag),	

	.wren(wren),			
	.wr_addr(wr_addr)
   );	

//IP CORE DPRAM

	my_dpram my_dpram_dut(
		.data(rx_data),
		.rdaddress(rd_addr),
		.rdclock(vga_clk),
		.wraddress(wr_addr),
		.wrclock(uart_clk),
		.wren(wren),
		.q(rd_data)
	);

	
//vga_ctrl 800*600*60
	vga_ctrl vga_ctrl_dut(
		.vga_clk(vga_clk),   
		.rst_n(locked),
		.rd_data(rd_data),		
		
		.rd_addr(rd_addr),		
		.vga_hs(vga_hs),
		.vga_vs(vga_vs),
		.vga_rgb(vga_rgb),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N)

	);
	





endmodule