module slave_select_tb();
	reg pclk, preset_n, mstr_i, spiswai_i, send_data_i;
	reg [1:0]spi_mode_i;
	reg [11:0]brd_i;
	wire r_data_o, ss_o;
	wire tip_o;
	
	slave_select DUT(pclk, preset_n, mstr_i, spiswai_i, spi_mode_i, send_data_i, brd_i, r_data_o, ss_o, tip_o);
	
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
	
	task initialize();
		begin
			{mstr_i, spiswai_i, spi_mode_i, send_data_i, brd_i}=0;
		end
	endtask

	task in();
		begin
			@(negedge pclk)
			mstr_i=1'b1;
			spiswai_i=1'b0;
			spi_mode_i=1'b00;
			send_data_i=1'b1;
			brd_i=4;
			@(negedge pclk)
			send_data_i=1'b0;

		end
	endtask
	
	initial
		begin
			initialize();
			reset();
			in();
			#500;
			$finish;
		end
endmodule

	