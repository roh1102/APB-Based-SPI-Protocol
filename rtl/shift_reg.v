module shift_reg(pclk, preset_n, ss_i, send_data_i, lsbfe_i, cpha_i, cpol_i, miso_r_sclk_i, miso_r_sclk0_i, mosi_s_sclk_i, mosi_s_sclk0_i, data_mosi_i, miso_i, rec_data_i, mosi_o, data_miso_o);
	 
	input pclk, preset_n, ss_i, send_data_i, lsbfe_i, cpha_i, cpol_i, miso_r_sclk_i, miso_r_sclk0_i, mosi_s_sclk_i, mosi_s_sclk0_i, miso_i, rec_data_i;
	input [7:0]data_mosi_i;
	output reg mosi_o;
	output [7:0]data_miso_o;

	reg [7:0] shift_reg, temp_reg;
	reg [2:0]count, count1, count2, count3;

	assign data_miso_o=(rec_data_i)?temp_reg:8'h00;

	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
			shift_reg<=8'b0;
		else
		begin
			if(send_data_i)
				shift_reg<=data_mosi_i;
			else
				shift_reg<=shift_reg;
		end
	end

	//Recieving Data

	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
		begin
			temp_reg<=8'b0;
			count2<=3'b0;
			count3<=3'd7;
		end
		else if(!ss_i)
		begin
			if((~cpol_i&&cpha_i)||(~cpha_i&&cpol_i))
			begin
				if(lsbfe_i)
				begin
					if(count2<=3'd7)
					begin
						if(miso_r_sclk0_i)
						begin
							temp_reg[count2]<=miso_i;
							count2<=count2+1'b1;
						end
					end
					else
						count2<=3'b0;
				end
				else
				begin
					if(count3>=3'b0)
					begin
						if(miso_r_sclk0_i)
						begin
							
							temp_reg[count3]<=miso_i;
							count3<=count3-1'b1;
						end
					end
					else
						count3<=3'd7;
				end
			end
			else
			begin
				if(lsbfe_i)
				begin
					if(count2<=3'd7)
					begin
						if(miso_r_sclk_i)
						begin
							temp_reg[count2]<=miso_i;
							count2<=count2+1'b1;
						end
					end
					else
						count2<=3'b0;
				end
				else
				begin
					if(count3>=3'b0)
					begin
						if(miso_r_sclk_i)
						begin
							
							temp_reg[count3]<=miso_i;
							count3<=count3-1'b1;
						end
					end
					else
						count3<=3'd7;
				end
			end
		end
	end


	//Transmitting data
	
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
		begin
			mosi_o<=1'b0;
			count<=3'b0;
			count1<=3'd7;
		end
		else if(!ss_i)
		begin
			if((~cpol_i&&cpha_i)||(~cpha_i&&cpol_i))
			begin
				if(lsbfe_i)
				begin
					if(count<=3'd7)
					begin
						if(mosi_s_sclk0_i)
						begin
							mosi_o<=shift_reg[count];
							count<=count+1'b1;
						end
					end
					else
						count<=3'b0;
				end
				else
				begin
					if(count1>=3'b0)
					begin
						if(mosi_s_sclk0_i)
						begin
							
							mosi_o<=shift_reg[count1];
							count1<=count1-1'b1;
						end
					end
					else
						count1<=3'd7;
				end
			end
			else
			begin
				if(lsbfe_i)
				begin
					if(count<=3'd7)
					begin
						if(mosi_s_sclk_i)
						begin
							mosi_o<=shift_reg[count];
							count<=count+1'b1;
						end
					end
					else
						count<=3'b0;
				end
				else
				begin
					if(count1>=3'b0)
					begin
						if(mosi_s_sclk_i)
						begin
							
							mosi_o<=shift_reg[count1];
							count1<=count1-1'b1;
						end
					end
					else
						count1<=3'd7;
				end
			end
		end
	end

endmodule







			




