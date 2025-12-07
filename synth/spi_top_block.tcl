remove_design -all
set search_path {../lib}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog {../rtl/spi_top_block.v ../rtl/baud_rate.v ../rtl/slave_select.v ../rtl/spi_apb_slave.v ../rtl/shift_reg.v} 

elaborate spi_top_block

link 

check_design

current_design  spi_top_block

compile_ultra -no_autoungroup

write_file -f verilog -hier -output spi_top_block_netlist.v


 

