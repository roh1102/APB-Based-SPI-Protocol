`timescale 1ns/1ps

module spi_top_block_tb();
    reg         pclk;
    reg         preset_n;
    reg  [2:0]  paddr_i;
    reg         pwrite_i;
    reg         psel_i;
    reg         penable_i;
    reg  [7:0]  pwdata_i;
    wire [7:0]  prdata_o;
    wire        pready_o;
    wire        pslverr_o;
    wire        sclk_o;
    wire        mosi_o;
    wire        ss_o;
    reg         miso_i;
    wire        spi_int_req_o;

    spi_top_block DUT(
        .pclk(pclk),
        .preset_n(preset_n),
        .paddr_i(paddr_i),
        .pwrite_i(pwrite_i),
        .psel_i(psel_i),
        .penable_i(penable_i),
        .pwdata_i(pwdata_i),
        .prdata_o(prdata_o),
        .pready_o(pready_o),
        .pslverr_o(pslverr_o),
        .sclk_o(sclk_o),
        .mosi_o(mosi_o),
        .ss_o(ss_o),
        .miso_i(miso_i),
        .spi_int_req_o(spi_int_req_o)
    );
	 
	 integer i;

    	initial begin
        	pclk = 0;
        	forever #5 pclk = ~pclk;  
    		end

    	task initialize();
		begin
			@(negedge pclk)
			psel_i    = 0;
        		penable_i = 0;
        		pwrite_i  = 0;
        		miso_i    = 0;
        		paddr_i   = 0;
        		pwdata_i  = 0;
		end
	endtask


    	task reset();
			begin
		//	@(negedge pclk)
        	preset_n  = 0;
        	@(negedge pclk)
        	preset_n = 1;
			end
		endtask



    task apb_write(input [2:0] addr, input [7:0] data);
    	begin
        paddr_i   = addr;
        pwdata_i  = data;
        pwrite_i  = 1;
        psel_i    = 1;
        penable_i = 0;

        @(negedge pclk);
        penable_i = 1;

        @(negedge pclk);
	wait(pready_o);
      //  psel_i    = 0;
        penable_i = 0;
      //  pwrite_i  = 0;
	 @(negedge pclk);

    end
    endtask


    task apb_read(input [2:0] addr);
    	begin
        paddr_i   = addr;
        pwrite_i  = 0;
        psel_i    = 1;
        penable_i = 0;

        @(negedge pclk);
        penable_i = 1;

        @(negedge pclk);
	wait(pready_o);
        $display("READ @ %0d = %0h", addr, prdata_o);
        psel_i    = 0;
        penable_i = 0;
	 @(negedge pclk);

    end
    endtask
	 
	 task in_0(input [7:0]a);
		begin
			wait(!ss_o)
		       //	@(negedge sclk_o)
				for(i=0; i<8; i=i+1)
					begin
						@(negedge sclk_o);
						miso_i=a[i];
						 
					end
		end
	endtask

	task in_1(input [7:0]a);
		begin
			wait(!ss_o)
		//	miso_i=a[0];
		   //    	@(posedge sclk_o);
				for(i=0; i<8; i=i+1)
					begin
					@(posedge sclk_o);	
						miso_i<=a[i];
												 
					end
		end
	endtask




      initial 
		 begin
		 initialize();
		 reset();
        
        apb_write(3'b000, 8'b01010000);  // CR1
        apb_write(3'b010, 8'b00000001);  // BR step
        apb_write(3'b101, 8'b10100101);        // Write data A5
		  
		  in_1(8'b01010101);


        /*#50 miso_i = 1;
        #40 miso_i = 0;
        #40 miso_i = 1;
        #40 miso_i = 1;
        #40 miso_i = 0;
        #40 miso_i = 0;
        #40 miso_i = 1;
        #40 miso_i = 0;*/

        #100 apb_read(3'b101);   // Should read received byte

        #200 $finish;
    end

endmodule
