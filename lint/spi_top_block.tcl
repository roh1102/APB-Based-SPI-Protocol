#Liberty files are needed for logical and physical netlist designs
set search_path "./"
set link_library " "

set_app_var enable_lint true

#configure_lint_tag -enable -tag "W241" -goal lint_rtl
#configure_lint_tag -enable -tag "W240" -goal lint_rtl

configure_lint_setup -goal lint_rtl

analyze -verbose -format verilog "../rtl/spi_top_block.v ../rtl/baud_rate.v ../rtl/shift_reg.v ../rtl/slave_select.v ../rtl/spi_apb_slave.v "

elaborate spi_top_block

check_lint

report_lint -verbose -file report_lint_spi_top_block.txt
