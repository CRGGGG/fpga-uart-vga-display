`timescale 1ns/1ps
module uart_vga_tb;
	
	reg					sys_clk; 	//50MHZ
	reg					sys_rst_n;	//negative
	reg					rxd;			//recieve
	
	wire	[23:0]			vga_rgb;		//RGB332***
	wire					vga_hs;		//行
	wire					vga_vs;		//列

	reg	[8:0]			temp_data;
	
	`define				BPS		115200
	`define				TBPS		(1000_000_000	/	`BPS)

	uart_vga uart_vga_inst(
	.sys_clk(sys_clk), 	
	.sys_rst_n(sys_rst_n),	
	.rxd(rxd),			
	
	.vga_rgb(vga_rgb),	
	.vga_hs(vga_hs),		
	.vga_vs(vga_vs)		
);

	initial sys_clk = 1'b0;
	always #10 sys_clk = ~sys_clk;		//50MHZ
	
	initial	begin
		sys_rst_n = 1'b0;
		rxd = 1'b1;
		temp_data = 8'd0;
		
		#2000
		sys_rst_n = 1'b1;
		
		#2000
		rxd = 1'b0;	
		temp_data = 8'h55;					//0101_0101
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;
		
		#100000
		rxd = 1'b0;	
		temp_data = 8'h66;  					//8'b0110_0110
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;
		
		#100000
		rxd = 1'b0;	
		temp_data = 8'h77;  					//8'b0111_0111
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;

//第二次
		
		#100000
		rxd = 1'b0;	
		temp_data = 8'h88;					//1000_1000
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;
		
		#100000
		rxd = 1'b0;	
		temp_data = 8'h99;  					//8'b1001_1001
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;
		
		#100000
		rxd = 1'b0;	
		temp_data = 8'h22;  					//8'b0010_0010
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;
				
//第三次
		
		#100000
		rxd = 1'b0;	
		temp_data = 8'h33;					//0011_0011
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;
		
		#100000
		rxd = 1'b0;	
		temp_data = 8'h44;  					//8'b0100_0100
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;
		
		#100000
		rxd = 1'b0;	
		temp_data = 8'h55;  					//8'b0101_0101
		
		#`TBPS
		rxd = temp_data[0];
		#`TBPS
		rxd = temp_data[1];
		#`TBPS
		rxd = temp_data[2];
		#`TBPS
		rxd = temp_data[3];
		#`TBPS
		rxd = temp_data[4];
		#`TBPS
		rxd = temp_data[5];
		#`TBPS
		rxd = temp_data[6];
		#`TBPS
		rxd = temp_data[7];
		#`TBPS
		rxd = 1'b1;
				
				
		
		
		
		
		
end





endmodule