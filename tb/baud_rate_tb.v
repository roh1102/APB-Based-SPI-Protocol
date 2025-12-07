
module baud_rate_tb();
	reg pclk;  //system clock
	reg preset_n;  //asynchronous active low reset
	reg spiswai_i;  //spi stop in wait mode
	reg cpol_i;  //clock polarity
   reg cpha_i;  //clock phase
   reg ss_i;  //slave select
	reg [1:0] spi_mode_i;  //spi run, wait and stop mode
	reg [2:0] sppr_i;  //baud rate preselection bit 
	reg [2:0] spr_i;  //baud rate selection bit
	
	wire sclk_o;  //serial clock
	wire miso_r_sclk_o;  
	wire miso_r_sclk0_o;
	wire mosi_s_sclk_o;
	wire mosi_s_sclk0_o;
	wire [11:0] brd_o;  //baud rate divisor


	baud_rate DUT(pclk, preset_n, spi_mode_i, spiswai_i, sppr_i, spr_i, cpol_i, cpha_i, ss_i, sclk_o, miso_r_sclk_o, miso_r_sclk0_o, mosi_s_sclk_o, mosi_s_sclk0_o, brd_o);
	
	initial
		begin
			pclk=1'b0;
			forever #10 pclk=~pclk;
		end
	
	task initialize();
		begin
			spiswai_i=1'b0;
			cpol_i=1'b0;
			cpha_i=1'b0;
			ss_i=1'b1;
		end
	endtask
	
	task reset();
		begin
			@(negedge pclk)
				preset_n=1'b0;
			@(negedge pclk)
				preset_n=1'b1;
		end
	endtask
	
	task in(input a, b);
		begin
			@(negedge pclk)
				cpol_i=a;
				cpha_i=b;
				ss_i=1'b0;
				spi_mode_i=2'b00;
				sppr_i=3'b000;
				spr_i=3'b001;
		end
	endtask
	
	initial
		begin
			reset();
			initialize();
			in(0,0);
			#500;
			in(0,1);
			#500;
			$finish;
		end


endmodule 
