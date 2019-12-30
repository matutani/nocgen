#
# Your design
#
set base_name "router"
set rtl_file  "router.v cb.v mux.v muxcont.v arb.v inputc.v vc.v vcmux.v outputc.v rtcomp.v fifo.v"
set clock_name "clk"
set clock_period 5.0

#
# Libraries
#
set target_library "/home/cad/lib/NANGATE45/fast.db /home/cad/lib/NANGATE45/typical.db /home/cad/lib/NANGATE45/slow.db"
set synthetic_library "dw_foundation.sldb"
set link_library [concat "*" $target_library $synthetic_library]
set symbol_library "generic.sldb"
define_design_lib WORK -path ./WORK

#
# Read RTL file(s)
#
analyze -format verilog $rtl_file
elaborate $base_name
current_design $base_name
link
uniquify

#
# Timing
#
create_clock -name $clock_name -period $clock_period [find port $clock_name]
set_clock_uncertainty 0.02 [get_clocks $clock_name]
set_input_delay 0.1 -clock clk [remove_from_collection [all_inputs] {clk rst}]
set_output_delay 0.1 -clock clk [all_outputs]

#
# Design synthesis
#
compile -map_effort high
compile -incremental_mapping -map_effort high

#
# Output
#
write -format verilog -hierarchy -output ${base_name}.vnet
write_sdc ${base_name}.sdc

#
# Reports
#
report_reference -hier
report_timing
#quit
