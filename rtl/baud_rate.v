
module baud_rate(pclk, preset_n, spi_mode_i, spiswai_i, sppr_i, spr_i, cpol_i, cpha_i, ss_i, sclk_o, miso_r_sclk_o, miso_r_sclk0_o, mosi_s_sclk_o, mosi_s_sclk0_o, brd_o);
	input pclk;  //system clock
	input preset_n;  //asynchronous active low reset
	input spiswai_i;  //spi stop in wait mode
	input cpol_i;  //clock polarity
   	input cpha_i;  //clock phase
   	input ss_i;  //slave select
	input [1:0] spi_mode_i;  //spi run, wait and stop mode
	input [2:0] sppr_i;  //baud rate preselection bit 
	input [2:0] spr_i;  //baud rate selection bit
	
	output reg sclk_o;  //serial clock
	output reg miso_r_sclk_o;  
	output reg miso_r_sclk0_o;
	output reg mosi_s_sclk_o;
	output reg mosi_s_sclk0_o;
	output [11:0] brd_o;  //baud rate divisor

	wire pre_sclk_s;
	reg [11:0]count_s;

	assign brd_o=(sppr_i + 1) * (2**(spr_i + 1));
	assign pre_sclk_s=(cpol_i) ? 1'b1:1'b0;     

	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				begin
					//count_s<=12'b0;
					sclk_o<=pre_sclk_s;
				end
				
			else if((!ss_i) && (!spiswai_i) && (spi_mode_i==2'b00 || spi_mode_i==2'b01))
				begin
					if(count_s==((brd_o/2)-1'b1))
						sclk_o<=~sclk_o;
					else
						sclk_o<=sclk_o;
				end
				
			else
				sclk_o<=pre_sclk_s;
		end
	
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				count_s<=12'b0;
			
			else if((!ss_i) && (!spiswai_i) && ((spi_mode_i==2'b00) || (spi_mode_i==2'b01)))
				begin
					if(count_s == ((brd_o/2)-1'b1))
						count_s<=12'b0;
					else
						count_s<=count_s+1'b1;
				end
			
			else 
				count_s<=12'b0;
		end
		
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				begin
					miso_r_sclk_o<=1'b0;
					miso_r_sclk0_o <= 1'b0;
				end
			else if(!ss_i &&((cpha_i && !cpol_i) || (cpol_i &&!cpha_i)))
				begin
					if(!sclk_o)
						miso_r_sclk0_o <= 1'b0;
					else
						begin
							if(count_s==(brd_o/2)-1'b1)
								miso_r_sclk0_o <= 1'b1;
							else
								miso_r_sclk0_o <= 1'b0;
						end
				end
			
			else if(!ss_i &&((!cpha_i && !cpol_i) || (cpol_i &&cpha_i)))

				begin
					if(sclk_o)
						miso_r_sclk_o <= 1'b0;
					else
						begin
							if(count_s==(brd_o/2)-1'b1)
								miso_r_sclk_o <= 1'b1;
							else
								miso_r_sclk_o <= 1'b0;
						end
				end
		end
		
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
			begin
				mosi_s_sclk_o<=1'b0;
				mosi_s_sclk0_o <= 1'b0;
			end
			
			else if(!ss_i &&((cpha_i && !cpol_i) || (cpol_i &&!cpha_i)))
				begin
					if(!sclk_o)
						mosi_s_sclk0_o <= 1'b0;
					else
						begin
							if(count_s==(brd_o/2)-2'b10)
								mosi_s_sclk0_o <= 1'b1;
							else
								mosi_s_sclk0_o <= 1'b0;
						end
				end
			
			else if(!ss_i &&((!cpha_i && !cpol_i) || (cpol_i && cpha_i)))

				begin
					if(sclk_o)
						mosi_s_sclk_o <= 1'b0;
					else
						begin
							if(count_s==(brd_o/2)-2'b10)
								mosi_s_sclk_o <= 1'b1;
							else
								mosi_s_sclk_o <= 1'b0;
						end
				end
		end
		
		


endmodule 
