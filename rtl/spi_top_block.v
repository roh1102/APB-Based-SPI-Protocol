
module spi_top_block(
    input        pclk,
    input        preset_n,
    input  [2:0] paddr_i,
    input        pwrite_i,
    input        psel_i,
    input        penable_i,
    input  [7:0] pwdata_i,
    output [7:0] prdata_o,
    output       pready_o,
    output       pslverr_o,
    output       sclk_o,
    output       mosi_o,
    output       ss_o,
    input        miso_i,
    output       spi_int_req_o
);

    // Internal connections
    wire mstr_w, cpol_w, cpha_w, lsbfe_w, spiswai_w;
    wire [2:0] sppr_w, spr_w;
    wire [1:0] spi_mode_w;

    wire send_data_w, rec_data_w;
    wire [7:0] mosi_data_w, miso_data_w;

    wire miso_r_sclk_w;
    wire miso_r_sclk0_w;
    wire mosi_s_sclk_w;
    wire mosi_s_sclk0_w;

    wire [11:0] brd_w;
    wire tip_w;


    spi_apb_slave u_apb_spi (
        .pclk(pclk),
        .preset_n(preset_n),
        .paddr_i(paddr_i),
        .pwrite_i(pwrite_i),
        .psel_i(psel_i),
        .penable_i(penable_i),
        .pwdata_i(pwdata_i),
        .ss_i(ss_o),
        .miso_data_i(miso_data_w),
        .rec_data_i(rec_data_w),
        .tip_i(tip_w),
        .prdata_o(prdata_o),
        .mstr_o(mstr_w),
        .cpol_o(cpol_w),
        .cpha_o(cpha_w),
        .lsbfe_o(lsbfe_w),
        .spiswai_o(spiswai_w),
        .sppr_o(sppr_w),
        .spr_o(spr_w),
        .spi_int_req_o(spi_int_req_o),
        .pready_o(pready_o),
        .pslverr_o(pslverr_o),
        .send_data_o(send_data_w),
        .mosi_data_o(mosi_data_w),
        .spi_mode_o(spi_mode_w)
    );

   
    baud_rate u_baud(
        .pclk(pclk),
        .preset_n(preset_n),
        .spi_mode_i(spi_mode_w),
        .spiswai_i(spiswai_w),
        .sppr_i(sppr_w),
        .spr_i(spr_w),
        .cpol_i(cpol_w),
        .cpha_i(cpha_w),
        .ss_i(ss_o),
        .sclk_o(sclk_o),
        .miso_r_sclk_o(miso_r_sclk_w),
        .miso_r_sclk0_o(miso_r_sclk0_w),
        .mosi_s_sclk_o(mosi_s_sclk_w),
        .mosi_s_sclk0_o(mosi_s_sclk0_w),
        .brd_o(brd_w)
    );


   shift_reg u_shift (
        .pclk(pclk),
        .preset_n(preset_n),
        .ss_i(ss_o),
        .send_data_i(send_data_w),
        .lsbfe_i(lsbfe_w),
        .cpha_i(cpha_w),
        .cpol_i(cpol_w),
        .miso_r_sclk_i(miso_r_sclk_w),
        .miso_r_sclk0_i(miso_r_sclk0_w),
        .mosi_s_sclk_i(mosi_s_sclk_w),
        .mosi_s_sclk0_i(mosi_s_sclk0_w),
        .data_mosi_i(mosi_data_w),
        .miso_i(miso_i),
        .rec_data_i(rec_data_w),
        .mosi_o(mosi_o),
        .data_miso_o(miso_data_w)
    );


   slave_select u_ss (
        .pclk(pclk),
        .preset_n(preset_n),
        .mstr_i(mstr_w),
        .spiswai_i(spiswai_w),
        .spi_mode_i(spi_mode_w),
        .send_data_i(send_data_w),
        .brd_i(brd_w),
        .r_data_o(rec_data_w),
        .ss_o(ss_o),
        .tip_o(tip_w)
    );

endmodule
