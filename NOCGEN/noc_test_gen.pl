#!/usr/bin/perl

#*******************************************************************
# $Id: noc_test_gen.pl 18 2010-02-21 16:37:19Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 7 ) {
        printf("usage: ./noc_test_gen.pl <data_width> <array_size> <vch_num> <topology_type> <traffic> <pkt_len> <pkt_num>\n");
        exit;
}

#*******************************************************************
# Data width
#*******************************************************************
$data_width     = $ARGV[0];

#*******************************************************************
# Array size
#*******************************************************************
$array_size     = $ARGV[1];

#*******************************************************************
# Number of virtual channels
#*******************************************************************
$vch_num        = $ARGV[2];

#*******************************************************************
# Topology type (mesh, ring, linear)
#*******************************************************************
$topology_type  = $ARGV[3];

#*******************************************************************
# Traffic pattern (uniform, random)
#*******************************************************************
$traffic_ptn	= $ARGV[4];

#*******************************************************************
# Maximum packet length (including HEAD and TAIL flits)
#*******************************************************************
$packet_len	= $ARGV[5];

#*******************************************************************
# Number of packets each switch injects
#*******************************************************************
$packet_num	= $ARGV[6];

#*******************************************************************
# Numbers of switches and ports
#*******************************************************************
if ( $topology_type eq "mesh" ) {
	$switch_num     = $array_size * $array_size;
        $port_num       = 4 + 1;
} elsif ( $topology_type eq "ring" || $topology_type eq "linear" ) {
	$switch_num     = $array_size;
        $port_num       = 2 + 1;
} else {
	printf("Error: unknown topology (%s). \n", $topology_type);
	die;
}

#*******************************************************************
# Parameter file
#*******************************************************************
$param_file	= "define.h";

#***********************************************************
# Header 
#***********************************************************
printf("/* test module for noc.v */ \n");
printf("`include \"%s\"     \n", $param_file);
printf("`timescale 1ns/10ps \n");
printf("\n");

#***********************************************************
# Module name 
#***********************************************************
printf("module noc_test; \n");
printf("\n");

#***********************************************************
# Wires and registers 
#***********************************************************
printf("parameter STEP  = 5.0; \n");
printf("parameter ARRAY = %d; \n", $array_size);
printf("\n");
printf("integer counter, stop, total_sent, total_recv; \n");
printf("reg clk, rst_, ready; \n");
printf("\n");

for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("/* n%d */ \n", $i);

	printf("reg     [`DATAW:0]      n%d_idata_p0;  \n", $i);
	printf("reg                     n%d_ivalid_p0; \n", $i);
	printf("reg     [`VCHW:0]       n%d_ivch_p0;   \n", $i);
	printf("wire    [`VCH:0]        n%d_ordy_p0;   \n", $i);
	printf("wire    [`DATAW:0]      n%d_odata_p0;  \n", $i);
	printf("wire                    n%d_ovalid_p0; \n", $i);
	printf("integer                 n%d_sent, n%d_recv;\n", $i, $i);
	printf("\n");
}

#***********************************************************
# Modules instances
#***********************************************************
printf("noc noc ( \n");

for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("        /* n%d */ \n", $i);

	printf("        .n%d_idata_p0 ( n%d_idata_p0  ), \n", $i, $i);
	printf("        .n%d_ivalid_p0( n%d_ivalid_p0 ), \n", $i, $i);
	printf("        .n%d_ivch_p0  ( n%d_ivch_p0   ), \n", $i, $i);
	printf("        .n%d_ordy_p0  ( n%d_ordy_p0   ), \n", $i, $i);

	printf("        .n%d_odata_p0 ( n%d_odata_p0  ), \n", $i, $i);
	printf("        .n%d_ovalid_p0( n%d_ovalid_p0 ), \n", $i, $i);

	printf("\n");
}
printf("        .clk ( clk  ), \n");
printf("        .rst_( rst_ )  \n");
printf("); \n");
printf("\n");

#***********************************************************
# Clock generator
#***********************************************************
printf("always #( STEP / 2) begin      \n");
printf("        clk <= ~clk;           \n");
printf("end                            \n");
printf("always #(STEP) begin           \n");
printf("        counter = counter + 1; \n");
printf("end                            \n");
printf("\n");

#***********************************************************
# Main thread
#***********************************************************
printf("initial begin                   \n");
printf("        /* Initialization */    \n");
printf("        #0                      \n");
printf("        counter = 0;            \n");
printf("        stop    = 200;          \n");
printf("        clk     <= `High;       \n");
printf("        ready   <= `Disable;    \n");
printf("        /* Send/recv counters */\n");
for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("        n%d_sent = 0; n%d_recv = 0; \n", $i, $i);
}
printf("        #(STEP / 2)             \n");
printf("        noc_reset;              \n");

printf("        /* Now we can start simulation! */\n");
printf("        ready   <= `Enable;     \n");
printf("\n");

# printf("`ifdef  __TOGGLE_ON__                             \n");
# printf("        #(STEP)                                   \n");
# printf("        \$read_lib_saif(\"lib.saif\");            \n");
# printf("        \$set_toggle_region(\"noc_test.noc.n0\"); \n");
# printf("        \$toggle_start(); \n");
# printf("`endif \n");
# printf("\n");

printf("        /* Waiting for the end of the simulation */ \n");
printf("        while (counter < stop) begin\n");
printf("                #(STEP);        \n");
printf("        end                     \n");
printf("\n");

# printf("`ifdef  __TOGGLE_ON__    \n");
# printf("        #(STEP)          \n");
# printf("        \$toggle_stop(); \n");
# printf("        \$toggle_report(\"backward.saif\", 1.0e-9, \"noc_test.noc.n0\"); \n");
# printf("`endif \n");
# printf("\n");

printf("        /* Statistics */ \n");

printf("        total_sent = ");
for ( $i = 0; $i < $switch_num - 1; $i++ ) {
	printf("n%d_sent + ", $i);
}
printf("n%d_sent;\n", $switch_num - 1);
printf("        total_recv = ");
for ( $i = 0; $i < $switch_num - 1; $i++ ) {
	printf("n%d_recv + ", $i);
}
printf("n%d_recv;\n", $switch_num - 1);

printf("        \$write(\"\\n\\n\");    \n");
printf("        \$write(\"*** statistics (%%d) *** \\n\", counter); \n");
for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("        \$write(\"n%d_sent %%d \\t n%d_recv %%d \\n\", n%d_sent, n%d_recv);\n", $i, $i, $i, $i);
}
printf("        \$write(\"total_sent %%d \\t total_recv %%d \\n\", total_sent, total_recv);\n");
printf("        \$write(\"\\n\\n\");    \n");
printf("        \$finish;               \n");
printf("end                             \n");
printf("\n");

#***********************************************************
# Packet generators
#***********************************************************
for ( $i = 0; $i < $switch_num; $i++ ) {

	printf("/* packet generator for n%d */ \n", $i);
	printf("initial begin \n");
	printf("        #(STEP / 2); \n");
	printf("        #(STEP * 10); \n");
	printf("        while (~ready) begin \n");
	printf("                #(STEP); \n");
	printf("        end \n");
	printf("\n");

	for ( $j = 0; $j < $packet_num; $j++ ) {

		if      ( $traffic_ptn eq "uniform" ) {
			$dst = $j % $switch_num;
			$vch = $j % $vch_num;
			$len = $packet_len;
		} elsif ( $traffic_ptn eq "random" ) {
			while ( ($dst = int(rand($switch_num))) == $i ) { ; }
			$vch = rand($vch_num);
			$len = rand($packet_len) + 1;
		} else {
			printf("Error: unknown traffic pattern (%s). \n", 
				$traffic_ptn);
			die;
		}

		if ( $i != $dst ) {
			printf("        \$write(\"*** send (src: %d dst: %d vch: %d len: %d) *** \\n\");\n", $i, $dst, $vch, $len);
			printf("        send_packet_%d(%d, %d, %d);\n", $i, $dst, $vch, $len);
		}
	}
	printf("end \n\n");
}
printf("\n\n");

#***********************************************************
# Send/Recv event monitor
#***********************************************************
printf("/* Send/recv event monitor */ \n");
printf("always @ (posedge clk) begin \n");
for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("        if ( n%d_ivalid_p0 == `Enable ) begin \n", $i);
	printf("                \$write(\"%%d n%d send %%x \\n\", counter, n%d_idata_p0); \n", $i, $i);
	printf("                n%d_sent = n%d_sent + 1;\n", $i, $i);
	printf("        end \n");
}
printf("end \n");
printf("\n");
printf("always @ (posedge clk) begin \n");
for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("        if ( n%d_ovalid_p0 == `Enable ) begin \n", $i);
	printf("                \$write(\"        %%d n%d recv %%x \\n\", counter, n%d_odata_p0); \n", $i, $i);
	printf("                n%d_recv = n%d_recv + 1; \n", $i, $i);
	printf("                stop     = counter + 200;\n");
	printf("        end \n");
}
printf("end \n");
printf("\n");
for ( $i = 0; $i < $port_num - 1; $i++ ) {
       	printf("/* Port %d */ \n", $i);
       	printf("always @ (posedge clk) begin    \n");

       	for ( $j = 0; $j < $switch_num; $j++ ) {
               	printf("\tif ( noc.n%d.ovalid_%d == `Enable ) \$write(\"                %%d n%d(%d %%d) go thru %%x \\n\", counter, noc.n%d.ovch_%d, noc.n%d.odata_%d); \n", $j, $i, $j, $i, $j, $i, $j, $i);
       	}
       	printf("end \n");
}
printf("\n");

#***********************************************************
# Trace output file
#***********************************************************
printf("initial begin                     \n");
printf("        \$dumpfile(\"dump.vcd\"); \n");
printf("        \$dumpvars(0,noc_test);   \n");
printf("        `ifdef __POST_PR__        \n");
for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("        \$sdf_annotate(\"router.sdf\", noc_test.noc.n%d, , \"sdf.log\", \"MAXIMUM\");\n", $i);
}
printf("        `endif                    \n");
printf("end                               \n");
printf("\n");

#***********************************************************
# Task: send_packet_n?(dst, len)
#***********************************************************
for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("/* send_packet_%d(dst, vch, len): send a packet from n%d to destination. */ \n", $i, $i);
	printf("task send_packet_%d; \n", $i);
	printf("input [31:0] dst; \n");
	printf("input [31:0] vch; \n");
	printf("input [31:0] len; \n");
	printf("reg [`DATAW:0]  packet [0:63]; \n");
	printf("integer id; \n");
	printf("begin      \n");
	printf("        n%d_ivalid_p0 <= `Disable;\n", $i);
	printf("        for ( id = 0; id < len; id = id + 1 ) \n");
	printf("                packet[id] <= 0; \n");
	printf("        #(STEP) \n");
	printf("        if (len == 1) \n");
	printf("                packet[0][`TYPE_MSB:`TYPE_LSB] <= `TYPE_HEADTAIL; \n");
	printf("        else \n");
	printf("                packet[0][`TYPE_MSB:`TYPE_LSB] <= `TYPE_HEAD; \n");
	printf("        packet[0][`DST_MSB:`DST_LSB] <= dst;    /* Dest ID (4-bit)   */ \n");
	printf("        packet[0][`SRC_MSB:`SRC_LSB] <= %d;     /* Source ID (4-bit) */ \n", $i);
	printf("        packet[0][`VCH_MSB:`VCH_LSB] <= vch;    /* Vch ID (4-bit)    */ \n");
	printf("        for ( id = 1; id < len; id = id + 1 ) begin \n");
	printf("                if ( id == len - 1 )\n");
	printf("                        packet[id][`TYPE_MSB:`TYPE_LSB] <= `TYPE_TAIL; \n");
	printf("                else \n");
	printf("                        packet[id][`TYPE_MSB:`TYPE_LSB] <= `TYPE_DATA; \n");
	printf("                packet[id][15:12] <= id;	/* Flit ID   (4-bit) */ \n");
	printf("                packet[id][31:16] <= counter;	/* Enqueue time (16-bit) */ \n");
	printf("        end \n");
	printf("        id = 0;                                 \n");
	printf("        while ( id < len ) begin                \n");
	printf("                #(STEP)                         \n");
	printf("                /* Packet level flow control */ \n");
	printf("                if ( (id == 0 && n%d_ordy_p0[vch]) || id > 0 ) begin \n", $i);
	printf("                        n%d_idata_p0 <= packet[id]; n%d_ivalid_p0 <= `Enable; n%d_ivch_p0 <= vch; id = id + 1; \n", $i, $i, $i);
	printf("                end else begin    \n");
	printf("                        n%d_idata_p0 <= `DATAW_P1'b0; n%d_ivalid_p0 <= `Disable;  \n", $i, $i);
	printf("                end \n");
	printf("        end \n");
	printf("        #(STEP) \n");
	printf("        n%d_ivalid_p0 <= `Disable;   \n", $i);
	printf("end             \n");
	printf("endtask         \n");
	printf("\n");
}

#***********************************************************
# Task: noc_reset()
#***********************************************************
printf("/* noc_reset(): Reset all routers. */ \n");
printf("task noc_reset; \n");
printf("begin           \n");

printf("        rst_    <= `Enable_;   \n");

printf("        #(STEP)                \n");
for ( $i = 0; $i < $switch_num; $i++ ) {
       	printf("        n%d_idata_p0 <= `DATAW_P1'h0; n%d_ivalid_p0 <= `Disable; n%d_ivch_p0 <= `VCHW_P1'h0;\n", $i, $i, $i);
}

printf("        #(STEP)                \n");
printf("        rst_    <= `Disable_;  \n");
printf("\n");
printf("end             \n");
printf("endtask         \n");
printf("\n");

printf("endmodule \n");

exit;

#*******************************************************************
# Sub function: utilities 
#*******************************************************************
sub get_bitwidth {
	my($num)	= $_[0] - 1;
	my($cnt);

	$cnt = 0;
	while ( $num > 0 ) {
		$num >>= 1;
		$cnt++;
	}
	return $cnt;
}
#*******************************************************************
