module spi_apb_slave_tb();
	reg pclk, preset_n, pwrite_i, psel_i, penable_i, ss_i, rec_data_i, tip_i;
	reg [2:0]paddr_i;
	reg [7:0]pwdata_i,miso_data_i;
	wire mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, pready_o, pslverr_o;
	wire spi_int_req_o;
	wire send_data_o;
	wire [7:0]mosi_data_o; 
	wire [1:0]spi_mode_o;
	wire [7:0]prdata_o;
	wire [2:0]sppr_o, spr_o;

	 spi_apb_slave DUT(pclk, preset_n, paddr_i, pwrite_i, psel_i, penable_i, pwdata_i, ss_i, miso_data_i, rec_data_i, tip_i, prdata_o, mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, sppr_o, spr_o, spi_int_req_o, pready_o, pslverr_o, send_data_o, mosi_data_o, spi_mode_o);

	initial
		begin
		 pclk=1'b0;
		 forever #5 pclk=~pclk;
		end

	task reset();
		begin
			preset_n=1'b0;
			#10;
			preset_n=1'b1;
		end
	endtask
	

	task initialize();
		begin
			@(negedge pclk)
			pwrite_i=1'b0;
			psel_i=1'b0;
			penable_i=1'b0;
			ss_i=1'b1;
			rec_data_i=1'b0;
			tip_i=1'b0;
			paddr_i=3'b000;
			pwdata_i=8'b00000000;
			miso_data_i=8'b00000000;
		end
	endtask
	
	task spi_cr1_write();
		begin
			@(negedge pclk)
			paddr_i=3'b000;
			pwrite_i=1'b1;
			psel_i=1'b1;
			penable_i=1'b0;
			pwdata_i=8'hff;
			@(negedge pclk)
			penable_i=1'b1;
			ss_i=1'b0;
			@(negedge pclk)
			psel_i=1'b0;
			penable_i=1'b0;
		end
	endtask

	task spi_cr1_read();
		begin
			@(negedge pclk)
			paddr_i=3'b000;
			pwrite_i=1'b0;
			psel_i=1'b1;
			penable_i=1'b0;
			@(negedge pclk)
			penable_i=1'b1;
			@(negedge pclk)
			penable_i=1'b0;
			psel_i=1'b0;
		end
	endtask

	task spi_cr2_write();
		begin
			paddr_i=3'b001;;
			pwrite_i=1'b1;
			psel_i=1'b1;
			penable_i=1'b0;
			pwdata_i=8'haa;
			@(negedge pclk)
			penable_i=1'b1;
			@(negedge pclk)
			penable_i=1'b0;
		end
	endtask

	task spi_br_write();
		begin
			@(negedge pclk)
			paddr_i=3'b010;
			pwrite_i=1'b1;
			psel_i=1'b1;
			penable_i=1'b0;
			pwdata_i=8'h01;
			@(negedge pclk)
			penable_i=1'b1;
			@(negedge pclk)
			penable_i=1'b0;
			psel_i=1'b0;
		end
	endtask

	task spi_sr_read();
		begin
			@(negedge pclk)
			paddr_i=3'b011;
			pwrite_i=1'b0;
			psel_i=1'b1;
			penable_i=1'b0;
			@(negedge pclk)
			penable_i=1'b1;
			@(negedge pclk)
			penable_i=1'b0;
			@(negedge pclk)
			psel_i=1'b0;
		end
	endtask
	
	task spi_dr_write();
		begin
			@(negedge pclk)
			paddr_i=3'b101;
			pwrite_i=1'b1;
			psel_i=1'b1;
			penable_i=1'b0;
			pwdata_i=8'h55;
			@(negedge pclk)
			penable_i=1'b1;
			@(negedge pclk)
			penable_i=1'b0;
			psel_i=1'b0;
		end
	endtask

	initial
		begin
			initialize();
			reset();
			#20;
			spi_br_write();
			spi_cr1_write();
			spi_cr2_write();
			spi_dr_write();
			spi_cr1_read();
			spi_sr_read();
			#100;
			$finish;
		end
		
endmodule







