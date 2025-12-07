module slave_select(pclk, preset_n, mstr_i, spiswai_i, spi_mode_i, send_data_i, brd_i, r_data_o, ss_o, tip_o);
	input pclk, preset_n, mstr_i, spiswai_i, send_data_i;
	input [1:0]spi_mode_i;
	input [11:0]brd_i;
	output reg r_data_o, ss_o;
	output tip_o;

	reg rcv_s;
	reg [15:0]count_s;
	wire [15:0]target_s;

	assign tip_o=~ss_o;
	assign target_s=16*(brd_i/2);

	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				r_data_o<=1'b0;
			else
				r_data_o<=rcv_s;	
		end
	

	always@(posedge pclk or negedge preset_n)
		begin
		if(!preset_n)
			rcv_s <=1'b0;
		else if(mstr_i && !spiswai_i &&(spi_mode_i==2'b00 || spi_mode_i==2'b01))
			begin
				if(send_data_i)
					rcv_s<=1'b0;
				else
					begin
						if(count_s==target_s-1'b1)
							rcv_s<=1'b1;
						else
							rcv_s<=1'b0;
					end
			end
		else
			rcv_s<=1'b0;
		end


	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				ss_o<=1'b1;
			else if((mstr_i && (spi_mode_i==2'b00 || (spi_mode_i==2'b01 && !spiswai_i))))
				begin
					if(send_data_i)
						ss_o<=1'b0;
					else
						begin
							if(count_s<=target_s-1'b1)
								ss_o<=1'b0;
							else
								ss_o<=1'b1;
						end
				end
			else
					ss_o<=1'b1;
		end
	
	always@(posedge pclk or negedge preset_n)
		begin
			if(!preset_n)
				count_s<=16'hffff;
			else if((mstr_i && !spiswai_i && (spi_mode_i==2'b00 || spi_mode_i==2'b01)))
				begin
					if(send_data_i)
						count_s<=1'b0;
					else
						begin
							if(count_s<=target_s-1'b1)
								count_s<=count_s+1'b1;
							else
								count_s<=16'hffff;
						end
				end
			else
				count_s<=16'hffff;
		end

endmodule






