MODEL = /home/cad/lib/NANGATE45/cells.v
BASE = router

#
# Step 1: RTL simulation
#
isim:
	iverilog noc_test.v noc.v router.v cb.v mux.v muxcont.v arb.v inputc.v outputc.v vc.v rtcomp.v vcmux.v fifo.v
	./a.out | tee sim.log
nsim:
	ncverilog +delay_mode_zero +access+r noc_test.v noc.v router.v cb.v mux.v muxcont.v arb.v inputc.v outputc.v vc.v rtcomp.v vcmux.v fifo.v | tee sim.log

#
# Step 2: Synthesis
#
syn:
	dc_shell-xg-t -f NANGATE45/syn.tcl | tee syn.log

#
# Step 3: Place-and-route
#
par:
	innovus -init NANGATE45/par.tcl | tee par.log

#
# Step 4: Static timing analysis
#
sta:
	dc_shell-xg-t -f NANGATE45/sta.tcl | tee sta.log

#
# Step 5: Delay simulation 
#
dsim:
	# Removing the parameter values from "noc.v"
	sed -e "s/#( .* )//" noc.v > tmp.v; mv tmp.v noc.v
	ncverilog +define+__POST_PR__ +access+r +nowarn+CUVWSP +nowarn+SDFNCAP -v ${MODEL} noc_test.v noc.v ${BASE}_final.vnet | tee dsim.log

#
# Step 6: Power estimation 
#
power:
	# Activate 0 ports
	sed -e "s/__NUM_STREAM__/0/" power.v > power.tmp.v
	ncverilog +define+__POST_PR__ +access+r +nowarn+CUVWSP +nowarn+SDFNCAP -v ${MODEL} power.tmp.v ${BASE}_final.vnet | tee psim.log
	vcd2saif -input dump.vcd -output ${BASE}.saif
	dc_shell-xg-t -f NANGATE45/power.tcl | tee power.log
	mv power.log power.0.log
	# Activate 1 ports
	sed -e "s/__NUM_STREAM__/1/" power.v > power.tmp.v
	ncverilog +define+__POST_PR__ +access+r +nowarn+CUVWSP +nowarn+SDFNCAP -v ${MODEL} power.tmp.v ${BASE}_final.vnet | tee psim.log
	vcd2saif -input dump.vcd -output ${BASE}.saif
	dc_shell-xg-t -f NANGATE45/power.tcl | tee power.log
	mv power.log power.1.log
	# Activate 2 ports
	sed -e "s/__NUM_STREAM__/2/" power.v > power.tmp.v
	ncverilog +define+__POST_PR__ +access+r +nowarn+CUVWSP +nowarn+SDFNCAP -v ${MODEL} power.tmp.v ${BASE}_final.vnet | tee psim.log
	vcd2saif -input dump.vcd -output ${BASE}.saif
	dc_shell-xg-t -f NANGATE45/power.tcl | tee power.log
	mv power.log power.2.log
	# Activate 3 ports
	sed -e "s/__NUM_STREAM__/3/" power.v > power.tmp.v
	ncverilog +define+__POST_PR__ +access+r +nowarn+CUVWSP +nowarn+SDFNCAP -v ${MODEL} power.tmp.v ${BASE}_final.vnet | tee psim.log
	vcd2saif -input dump.vcd -output ${BASE}.saif
	dc_shell-xg-t -f NANGATE45/power.tcl | tee power.log
	mv power.log power.3.log
	# Activate 4 ports
	sed -e "s/__NUM_STREAM__/4/" power.v > power.tmp.v
	ncverilog +define+__POST_PR__ +access+r +nowarn+CUVWSP +nowarn+SDFNCAP -v ${MODEL} power.tmp.v ${BASE}_final.vnet | tee psim.log
	vcd2saif -input dump.vcd -output ${BASE}.saif
	dc_shell-xg-t -f NANGATE45/power.tcl | tee power.log
	mv power.log power.4.log
	# Activate 5 ports
	sed -e "s/__NUM_STREAM__/5/" power.v > power.tmp.v
	ncverilog +define+__POST_PR__ +access+r +nowarn+CUVWSP +nowarn+SDFNCAP -v ${MODEL} power.tmp.v ${BASE}_final.vnet | tee psim.log
	vcd2saif -input dump.vcd -output ${BASE}.saif
	dc_shell-xg-t -f NANGATE45/power.tcl | tee power.log
	mv power.log power.5.log
	rm -f power.tmp.v

#
# Remove unnecessary files
#
clean:
	rm -rf a.out INCA_libs ncverilog.* dump.trn dump.dsn sdf.log ${BASE}.saif
	rm -rf command.log default.svf WORK *.enc.dat *.enc
	rm -rf innovus.* *.old *.rpt *.rguide *.cts_trace .cadence .tdrlog clock_report appOption.dat Clock.ctstch timingReports
	rm -rf Default.view CTS_RP_MOVE.txt ${BASE}.ctsrpt

allclean:
	make clean
	rm -f sim.log syn.log par.log sta.log power.*log dsim.log psim.log dump.vcd
	rm -f ${BASE}.vnet ${BASE}_final.vnet ${BASE}.sdc ${BASE}.sdf ${BASE}.spef ${BASE}.sdf*.X
	rm -rf .qrc.leflist .qx.cmd .qx.def .routing_guide.rgf .timing_file.tif .simvision
