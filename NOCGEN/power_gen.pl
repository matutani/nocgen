#!/usr/bin/perl

#*******************************************************************
# $Id: power_gen.pl 16 2010-02-20 15:09:25Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 2 ) {
        printf("usage: ./power_gen.pl <port_num> <data_width> \n");
        exit;
}

#*******************************************************************
# Number of ports
#*******************************************************************
$port_num	= $ARGV[0];

#*******************************************************************
# Data width
#*******************************************************************
$data_width	= $ARGV[1];

#*******************************************************************
# Generate "router_power.v"
#*******************************************************************

#*******************************************************************
# Header
#*******************************************************************
printf("/* energy estimation module for a router */ \n"); 
printf("`timescale 1ns/10ps \n");
printf("`include \"define.h\" \n");
printf("\n");

#*******************************************************************
# Module name
#*******************************************************************
printf("module noc_test; \n");
printf("    noc noc();\n");
printf("endmodule\n");
printf("\n");
printf("module noc; \n");
printf("\n");

#*******************************************************************
# Parameters
#*******************************************************************
printf("parameter ENABLE = 1;   \n");
printf("parameter STEP   = 5.0; \n",);
printf("parameter STREAM = __NUM_STREAM__; \n");
printf("\n");

#*******************************************************************
# Integers, wires, and registers
#*******************************************************************
printf("integer i, j; \n");
printf("integer count, seed, flag; \n");
printf("reg clk, rst_; \n");
printf("\n");

for ( $i = 0; $i < $port_num; $i++ ) {
	printf("/* port%d */ \n", $i);
	#
	printf("reg     [`DATAW:0]      idata_%d;  \n", $i);
	printf("reg                     ivalid_%d; \n", $i);
	printf("reg     [`VCHW:0]       ivch_%d;   \n", $i);
	printf("wire    [`VCH:0]        ordy_%d;   \n", $i);
	printf("wire    [`VCH:0]        olck_%d;   \n", $i);
	#
	printf("wire    [`DATAW:0]      odata_%d;  \n", $i);
	printf("wire                    ovalid_%d; \n", $i);
	printf("wire    [`VCHW:0]       ovch_%d;   \n", $i);
	printf("reg     [`VCH:0]        iack_%d;   \n", $i);
	printf("reg     [`VCH:0]        ilck_%d;   \n", $i);
	#
	printf("\n");
}

#*******************************************************************
# Clock generator
#*******************************************************************
printf("always #( STEP / 2 ) begin \n");
printf("        clk <= ~clk;       \n");
printf("end                        \n");
printf("always #( STEP ) begin     \n");
printf("        count = count + 1; \n");
printf("        seed  = seed  + 1; \n");
printf("end                        \n");
printf("\n");

#***********************************************************
# Modules instances
#***********************************************************
printf("router n0 ( \n");

for ( $i = 0; $i < $port_num; $i++ ) {
	printf("        /* port%d */ \n", $i);
	printf("        .idata_%d  ( idata_%d  ), \n", $i, $i);
	printf("        .ivalid_%d ( ivalid_%d ), \n", $i, $i);
	printf("        .ivch_%d   ( ivch_%d   ), \n", $i, $i);
	printf("        .ordy_%d   ( ordy_%d   ), \n", $i, $i);
	printf("        .olck_%d   ( olck_%d   ), \n", $i, $i);
	printf("        .odata_%d  ( odata_%d  ), \n", $i, $i);
	printf("        .ovalid_%d ( ovalid_%d ), \n", $i, $i);
	printf("        .ovch_%d   ( ovch_%d   ), \n", $i, $i);
	printf("        .iack_%d   ( iack_%d   ), \n", $i, $i);
	printf("        .ilck_%d   ( ilck_%d   ), \n", $i, $i);
	printf("\n");
}
printf("        .my_xpos( 1 ),\n");
printf("        .my_ypos( 1 ),\n");
printf("        .clk  ( clk  ), \n");
printf("        .rst_ ( rst_ )  \n");
printf("); \n");
printf("\n");

#***********************************************************
# Test module
#***********************************************************
printf("initial begin                            \n");
printf("\n");
printf("        \$dumpfile(\"dump.vcd\"); \n");
printf("        \$dumpvars(0,noc_test.noc.n0);   \n");
printf("        \$dumpoff;                       \n");
printf("        `ifdef __POST_PR__               \n");
printf("        \$sdf_annotate(\"router.sdf\", noc_test.noc.n0, , \"sdf.log\", \"MAXIMUM\");\n");
printf("        `endif                           \n");

printf("\n");
printf("        /* Initialization */            \n");
printf("        #0                              \n");
printf("        clk     <= `High;               \n");
printf("        rst_    <= `Enable_;            \n");
printf("        count   = 0;                    \n");
printf("        flag    = 0;                    \n");
printf("\n");

for ( $i = 0; $i < $port_num; $i++ ) {
	printf("        /* port%d */              \n", $i);
	printf("        idata_%d <= `DATAW_P1'b0; \n", $i);
	printf("        ivalid_%d<= `Disable;     \n", $i);
	printf("        ivch_%d  <= `VCHW_P1'b0;  \n", $i);
	printf("        iack_%d  <= `VCH_P1'hf;   \n", $i);
	printf("        ilck_%d  <= `VCH_P1'h0;   \n", $i);
	printf("\n");
}

print << "END_OF_ROUTER";

        #(STEP)
        #(STEP / 2)
        rst_    <= `Disable_;
        #(STEP)

        \$write(\"Start clock %d \\n\", count);
        \$dumpon;
        flag  = 1;

        for (i = 0; i < 100; i = i + 1) begin
                forward_packet( STREAM, 4, ENABLE );
                #(STEP*7)         // Link utilization 4/13=0.30
                \$write(\"------------------------\\n\");
        end
        flag = 0;

        #(STEP)
        \$write(\"Stop clock %d \\n\", count);
        \$dumpoff;
        \$finish;
end

END_OF_ROUTER

#***********************************************************
# Forward packet
#***********************************************************
@port_list = ( 9, 4, 1, 6, 5 );

printf("task forward_packet; \n");
printf("input [31:0] n;      \n");
printf("input [31:0] len;    \n");
printf("input [31:0] enable; \n");
printf("reg   [31:0] ran0;   \n");
printf("reg   [31:0] ran1;   \n");
printf("reg   [31:0] ran2;   \n");
printf("reg   [31:0] ran3;   \n");
printf("begin                \n");

printf("        /* Initialization */ \n");
for ( $s = 0; $s < $port_num; $s++ ) {
        printf("        if ( n > %d && enable == 1 ) begin \n", $s);
        if ( $data_width == 32 ) {
                printf("                idata_%d <= {`TYPE_HEAD, 32'h0%d}; \n", $s, $port_list[$s]);
        } else {
                printf("                idata_%d <= {`TYPE_HEAD, %d'h0, 32'h0%d}; \n", $s, $data_width - 32, $port_list[$s]);
        }
        printf("                ivalid_%d<= `Enable; \n", $s);
        printf("        end \n");
}
printf("\n");

printf("        /* Packet transfer */ \n");
printf("        for (j = 0; j < len; j = j + 1) begin \n");
printf("                ran0 <= \$random(seed);       \n");
printf("                ran1 <= \$random(seed);       \n");
printf("                ran2 <= \$random(seed);       \n");
printf("                ran3 <= \$random(seed);       \n");
printf("                #(STEP)                       \n");

for ( $s = 0; $s < $port_num; $s++ ) {
        printf("                if ( n > %d && enable == 1 ) \n", $s);
        if      ( $data_width == 32 ) {
                printf("                        idata_%d <= {`TYPE_DATA, ran0}; \n", $s);
        } elsif ( $data_width == 64 ) {
                printf("                        idata_%d <= {`TYPE_DATA, ran0, ran1}; \n", $s);
        } elsif ( $data_width == 128 ) {
                printf("                        idata_%d <= {`TYPE_DATA, ran0, ran1, ran2, ran3}; \n", $s);
        } else {
                printf("Error: not supported data width (%d) \n", $data_width);
                exit;
        }
}
printf("        end                           \n");

printf("        ran0 <= \$random(seed);       \n");
printf("        ran1 <= \$random(seed);       \n");
printf("        ran2 <= \$random(seed);       \n");
printf("        ran3 <= \$random(seed);       \n");
printf("        #(STEP)                       \n");
for ( $s = 0; $s < $port_num; $s++ ) {
        printf("        if ( n > %d && enable == 1 ) \n", $s);
        if      ( $data_width == 32 ) {
                printf("                idata_%d <= {`TYPE_TAIL, ran0}; \n", $s);
        } elsif ( $data_width == 64 ) {
                printf("                idata_%d <= {`TYPE_TAIL, ran0, ran1}; \n", $s);
        } elsif ( $data_width == 128 ) {
                printf("                idata_%d <= {`TYPE_TAIL, ran0, ran1, ran2, ran3}; \n", $s);
        } else {
                printf("Error: not supported data width (%d) \n", $data_width);
                exit;
        }
}

printf("        #(STEP)                               \n");
for ( $s = 0; $s < $port_num; $s++ ) {
        printf("        idata_%d <= {`TYPE_NONE, %d'h0}; \n", $s, $data_width);
        printf("        ivalid_%d<= `Disable; \n", $s);
}

printf("end                          \n");
printf("endtask                      \n");
printf("\n");

#***********************************************************
# Output monitor
#***********************************************************
printf("always #( STEP ) begin \n");
printf("        //\$write(\"i0={%%x,%%x}\", idata_0, ivalid_0); \n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("        \$write(\"o%d={%%x,%%x}\", odata_%d, ovalid_%d); \n", $i, $i, $i);
}
printf("        \$write(\"\\n\"); \n");
printf("end \n");


printf("endmodule \n");
exit;

#*******************************************************************
