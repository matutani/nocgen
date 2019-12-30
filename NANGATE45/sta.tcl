#
# Your design
#
set base_name "router"
set vnet_file "router_final.vnet"
set sdc_file  "router.sdc"
set sdf_file  "router.sdf"
set spef_file "router.spef"

#
# Libraries
#
#set target_library "/home/cad/lib/NANGATE45/fast.db /home/cad/lib/NANGATE45/typical.db /home/cad/lib/NANGATE45/slow.db"
set target_library "/home/cad/lib/NANGATE45/typical.db"
set synthetic_library "dw_foundation.sldb"
set link_library [concat "*" $target_library $synthetic_library]
set symbol_library "generic.sldb"
define_design_lib WORK -path ./WORK

#
# Read post-layout netlist
#
read_file -format verilog $vnet_file
current_design $base_name
link

#
# Delay and RC information
#
read_sdc $sdc_file
read_sdf $sdf_file
read_parasitics $spef_file

#
# Reports
#
report_reference -hier
report_timing
#quit
