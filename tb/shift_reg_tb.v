module shift_reg_tb();
	reg pclk, preset_n, ss_i, send_data_i, lsbfe_i, cpha_i, cpol_i, miso_r_sclk_i, miso_r_sclk0_i, mosi_s_sclk_i, mosi_s_sclk0_i, miso_i, rec_data_i;
	reg [7:0]data_mosi_i;
	wire mosi_o;
	wire [7:0]data_miso_o;
	
	shift_reg DUT(pclk, preset_n, ss_i, send_data_i, lsbfe_i, cpha_i, cpol_i, miso_r_sclk_i, miso_r_sclk0_i, mosi_s_sclk_i, mosi_s_sclk0_i, data_mosi_i, miso_i, rec_data_i, mosi_o, data_miso_o);

	initial
	begin
		pclk=1'b0;
		forever #5 pclk=~pclk;
	end

	task reset();
		begin
			@(negedge pclk)
				preset_n=1'b0;
			@(negedge pclk)
				preset_n=1'b1;

		end
	endtask

	task initialization();
		begin
			@(negedge pclk)
			ss_i=1'b1;
			{send_data_i, lsbfe_i, cpha_i, cpol_i, miso_r_sclk_i, miso_r_sclk0_i, mosi_s_sclk_i, mosi_s_sclk0_i, data_mosi_i, miso_i, rec_data_i}=0;
		end
	endtask

	task trans(input x, y);
		begin
			@(negedge pclk)
			send_data_i=x;
			rec_data_i=y;
		end
	endtask

	task in(input a, b);
		begin
			@(negedge pclk)
			ss_i=1'b0;
			cpol_i=a;
			cpha_i=b;
		end
	endtask

	task flags();
		begin
			@(negedge pclk)
			{miso_r_sclk_i, miso_r_sclk0_i, mosi_s_sclk_i, mosi_s_sclk0_i}=4'b1111;
		end
	endtask

	task stimulus(input p,input [7:0]q);
		begin
			@(negedge pclk)
			miso_i=p;
			data_mosi_i=q;
		end
	endtask

	initial
		begin
			initialization();
			reset();
			#10;
			flags();
			stimulus(1'b1, 8'b01100110);
			in(0,1);
			trans(1'b1, 1'b1);
			
			#500;
			$finish;
		end
endmodule 








