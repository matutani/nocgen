#!/usr/bin/perl

#*******************************************************************
# $Id: cb_gen.pl 12 2009-11-09 08:33:20Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 2 ) {
	printf("usage: ./cb_gen.pl <iport_num> <oport_num> \n");
	exit;
}

#*******************************************************************
# Number of input ports and output ports
#*******************************************************************
$iport_num	= $ARGV[0];
$oport_num	= $ARGV[1];

#*******************************************************************
# Parameter file
#*******************************************************************
$param_file	= "define.h";

#*******************************************************************
# Include parameter file
#*******************************************************************
printf("`include \"%s\" \n", $param_file);

#*******************************************************************
# Module definitions
#*******************************************************************
printf("module cb ( \n");

for ( $i = 0; $i < $iport_num; $i++ ) {
	printf("        idata_%d,  \n", $i);
	printf("        ivalid_%d, \n", $i);
	printf("        ivch_%d,   \n", $i);
	printf("        port_%d,   \n", $i);
	printf("        req_%d,    \n", $i);
	printf("        grt_%d,    \n", $i);
	printf("\n");
}

for ( $i = 0; $i < $oport_num; $i++ ) {
	printf("        odata_%d,  \n", $i);
	printf("        ovalid_%d, \n", $i);
	printf("        ovch_%d,   \n", $i);
	printf("\n");
}

printf("        clk, \n");
printf("        rst_ \n");

printf(");\n");

printf("\n");

#*******************************************************************
# Port definitions
#*******************************************************************
for ( $i = 0; $i < $iport_num; $i++ ) {
	printf("input   [`DATAW:0]      idata_%d;  \n", $i);
	printf("input                   ivalid_%d; \n", $i);
	printf("input   [`VCHW:0]       ivch_%d;   \n", $i);
	printf("input   [`PORTW:0]      port_%d;   \n", $i);
	printf("input                   req_%d;    \n", $i);
	printf("output  [`PORT:0]       grt_%d;    \n", $i);
	printf("\n");
}

for ( $i = 0; $i < $oport_num; $i++ ) {
	printf("output  [`DATAW:0]      odata_%d;  \n", $i);
	printf("output                  ovalid_%d; \n", $i);
	printf("output  [`VCHW:0]       ovch_%d;   \n", $i);
	printf("\n");
}

printf("input                   clk; \n");
printf("input                   rst_;\n");
printf("\n");

#*******************************************************************
# Wire/Register definitions
#*******************************************************************
for ( $i = 0; $i < $oport_num; $i++ ) {
	printf("wire    [`PORT:0]     cb_sel_%d; \n", $i);
}
for ( $i = 0; $i < $oport_num; $i++ ) {
	printf("wire    [`PORT:0]     cb_grt_%d; \n", $i);
}
printf("\n");

#*******************************************************************
# Module instances
#*******************************************************************
for ( $i = 0; $i < $oport_num; $i++ ) {
	printf("muxcont #( %d ) muxcont_%d ( \n", $i, $i);
	for ( $j = 0; $j < $iport_num; $j++ ) {
		printf("        .port_%d   ( port_%d   ), \n", $j, $j);
		printf("        .req_%d    ( req_%d    ), \n", $j, $j);
		printf("\n");
	}
	printf("        .sel ( cb_sel_%d ), \n", $i);
	printf("        .grt ( cb_grt_%d ), \n", $i);
	printf("\n");

	printf("        .clk ( clk  ), \n");
	printf("        .rst_( rst_ ) \n");
	printf("); \n");
	printf("\n");
}

for ( $i = 0; $i < $oport_num; $i++) {
	printf("mux mux_%d ( \n", $i);
	for ( $j = 0; $j < $iport_num; $j++) {
		printf("        .idata_%d  ( idata_%d  ), \n", $j, $j);
		printf("        .ivalid_%d ( ivalid_%d ), \n", $j, $j);
		printf("        .ivch_%d   ( ivch_%d   ), \n", $j, $j);
		printf("\n");
	}
	printf("        .odata  ( odata_%d    ), \n", $i);
	printf("        .ovalid ( ovalid_%d   ), \n", $i);
	printf("        .ovch   ( ovch_%d     ), \n", $i);
	printf("\n");
	printf("        .sel ( cb_sel_%d ) \n", $i);
	printf("); \n");
	printf("\n");
}

for ( $i = 0; $i < $iport_num; $i++) {
	for ( $j = 0; $j < $oport_num; $j++) {
		printf("assign grt_%d[%d]  = cb_grt_%d[%d]; \n", $i, $j, $j, $i);
	}
	printf("\n");
}

printf("endmodule\n");

exit;

#*******************************************************************
# Sub function: utilities
#*******************************************************************
sub get_bitwidth {
        my($num)        = $_[0] - 1;
        my($cnt);

        $cnt = 0;
        while ( $num > 0 ) {
                $num >>= 1;
                $cnt++;
        }
        return $cnt;
}
#*******************************************************************
