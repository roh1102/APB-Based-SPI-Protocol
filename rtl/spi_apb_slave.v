module spi_apb_slave(pclk, preset_n, paddr_i, pwrite_i, psel_i, penable_i, pwdata_i, ss_i, miso_data_i, rec_data_i, tip_i, prdata_o, mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, sppr_o, spr_o, spi_int_req_o, pready_o, pslverr_o, send_data_o, mosi_data_o, spi_mode_o);
	input pclk, preset_n, pwrite_i, psel_i, penable_i, ss_i, rec_data_i, tip_i;
	input [2:0]paddr_i;
	input [7:0]pwdata_i,miso_data_i;
	output mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, pready_o, pslverr_o;
	output reg spi_int_req_o;
	output reg send_data_o;
	output reg[7:0]mosi_data_o; 
	output reg [1:0]spi_mode_o;
	output reg[7:0]prdata_o;
	output[2:0]sppr_o, spr_o;

	reg [1:0]state, next_state;    //APB state
	reg [1:0]nmode;    //SPI mode state
	reg [7:0]spi_cr1, spi_cr2, spi_br, spi_dr;
	reg [7:0]spi_sr;

	wire wr_enb,rd_enb;
	wire spie, spe, sptie, ssoe_o;
	wire modfen;
	wire spif;
	wire sptef;
	wire modf;

	wire [7:0]spi_cr2_mask=8'b00011011;
	wire [7:0]spi_br_mask=8'b01110111;

	
	assign modf=~ss_i && ~ssoe_o && mstr_o && modfen;
   assign sptef=(spi_dr==8'b0)?1'b1:1'b0;
	assign spif=(spi_dr==8'b0)?1'b1:1'b0;
	assign mstr_o=spi_cr1[4];
	assign cpol_o=spi_cr1[3];
	assign cpha_o=spi_cr1[2];
	assign lsbfe_o=spi_cr1[0];
	assign spie=spi_cr1[7];
	assign spe=spi_cr1[6];
	assign sptie=spi_cr1[5];
	assign modfen=spi_cr2[4];
	assign spiswai_o=spi_cr2[1];
	assign sppr_o=spi_br[6:4];
	assign spr_o=spi_br[2:0];
	assign ssoe_o=spi_cr1[1];	

	parameter 
		idle=2'b00,
		setup=2'b01,
		enable=2'b10;

	parameter
		spi_run=2'b00,
		spi_wait=2'b01,
		spi_stop=2'b10;

	//APB FSM
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				state<=idle;
			else
				state<=next_state;
		end

	always@(*)
		begin
			case(state)
				idle: 
					begin
						if(psel_i && !penable_i) next_state=setup;
						else next_state=idle;
					end

				setup: 
					begin
						if(psel_i && penable_i) next_state=enable;
						else if(psel_i && !penable_i) next_state=setup;
						else next_state=idle;
					end

				enable: 
				begin
					if(psel_i) next_state=setup;
					else next_state=idle;
				end
					
				default: next_state=idle;
			endcase
		end
	
	//SPI FSM
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				spi_mode_o<=spi_run;
			else
				spi_mode_o<=nmode;
		end
	
	always@(*)
		begin
			case(spi_mode_o)
				spi_run:
					begin
						if(!spe) nmode=spi_wait;
						else nmode=spi_run;
					end

				spi_wait: 
					begin
						if(spiswai_o) nmode=spi_stop;
						else if(spe) nmode=spi_run;
						else nmode=spi_wait;
					end

				spi_stop:
					begin
						if(!spiswai_o) nmode=spi_wait;
						else if(spe) nmode=spi_run;
						else nmode=spi_stop;
					end
					
				default: nmode=spi_run;
					
					
			endcase
		end
		
		
		//spi sr register
		//assign spi_sr=(preset_n)?8'b00100000:{spif,1'b0,sptef,modf,4'b0};
		/*always@(*)
			begin
				if(preset_n)
					spi_sr<=8'b00100000;
				else
					spi_sr<={spif,1'b0,sptef,modf,4'b0};
			end*/
	


	//send data out

	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				send_data_o<=0;
			else
				begin
					if(wr_enb)
						send_data_o<=1'b0;
					else
						begin
							if(spi_dr==pwdata_i && spi_dr!=miso_data_i && (spi_mode_o==2'b00 || spi_mode_o==2'b01))
								send_data_o<=1'b1;
							else
								send_data_o<=1'b0;
						end
				end
		end

		
	//mosi data out
	
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				mosi_data_o<=8'b0;
			else
				begin
					if(spi_dr==pwdata_i && spi_dr!=miso_data_i && (spi_mode_o==2'b00 || spi_mode_o==2'b01))
						mosi_data_o<=spi_dr;
					else
						mosi_data_o<=mosi_data_o;
				end
		end

	
	//SPI Data Register
	
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				spi_dr<=8'b0;
			else
				begin
					if(wr_enb)
						begin
							if(paddr_i==3'b101)
								spi_dr<=pwdata_i;
							else
								spi_dr<=spi_dr;
						end
					else
						begin
							if(spi_dr==pwdata_i && spi_dr!=miso_data_i && (spi_mode_o==2'b00 || spi_mode_o==2'b01))
								spi_dr<=8'b0;
							else
								begin
									if((spi_mode_o==2'b00 || spi_mode_o==2'b01) && rec_data_i)
										spi_dr<=miso_data_i;
									else
										spi_dr<=spi_dr;
								end
						end
				end
		end
	

	//SPI Interuppt Request Signal
	
	always@(*)
		begin
			spi_int_req_o = 1'b0;
			if(!spie && !sptie)
				spi_int_req_o=0;
			else if(spie && !sptie)
				begin
					if(spif || modf)
						spi_int_req_o=1'b1;	
				end
			else if(sptie && !spie)
				spi_int_req_o=sptef;
			else
				begin
					if(spif || modf || sptef)
						spi_int_req_o=1'b1;
				end
		end
		


	//prdata_i
	
	always@(*)
		begin
			if(rd_enb)
				begin
					case(paddr_i)
						3'b000:prdata_o=spi_cr1;
						3'b001:prdata_o=spi_cr2;
						3'b010:prdata_o=spi_br;
						3'b011:prdata_o=spi_sr;
						3'b100:prdata_o=8'b0;
						3'b101:prdata_o=spi_dr;
						3'b110:prdata_o=8'b0;
						3'b111:prdata_o=8'b0;
					endcase
				end
			else
				prdata_o=8'b0;
		end

	
	//spi_cr1 register
	
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				spi_cr1<=8'h04;
			else
				begin
					if(wr_enb)
						begin
							if(paddr_i==3'b000)
								spi_cr1<=pwdata_i;
							else
								spi_cr1<=spi_cr1;
						end
					else
						spi_cr1<=spi_cr1;
				end
		end
	

	//spi_cr2 register
	
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				spi_cr2<=8'h0;
			else
				begin
					if(wr_enb)
						begin
							if(paddr_i==3'b001)
								spi_cr2<=pwdata_i & spi_cr2_mask;
							else
								spi_cr2<=spi_cr2;
						end
					else
						spi_cr2<=spi_cr2;
				end
		end

	
	//spi_br register
	
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				spi_br<=8'h00;
			else
				begin
					if(wr_enb)
						begin
							if(paddr_i==3'b010)
								spi_br<=pwdata_i & spi_br_mask;
							else
								spi_br<=spi_br;
						end
					else
						spi_br<=spi_br;
				end
		end

	
	assign pready_o=(state==enable)?1'b1:1'b0;
	assign pslverr_o=(state==enable)?(~tip_i):1'b0;
	assign wr_enb=(pwrite_i && state==enable)?1'b1:1'b0;
	assign rd_enb=(!pwrite_i && state==enable)?1'b1:1'b0;
	

	//spi_sr register
	
	always@(*)
		begin
			if(!preset_n)
				spi_sr<=8'b00100000;
			else
				spi_sr<={spif,1'b0,sptef,modf,4'b0};
		end

endmodule 
	

	
	
