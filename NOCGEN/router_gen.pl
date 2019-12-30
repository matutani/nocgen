#!/usr/bin/perl

#*******************************************************************
# $Id: router_gen.pl 16 2010-02-20 15:09:25Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 2 ) {
	printf("usage: ./router_gen.pl <port_num> <vch_num> \n");
	exit;
}

#*******************************************************************
# Number of ports
#*******************************************************************
$port_num	= $ARGV[0];

#*******************************************************************
# Number of virtual channels
#*******************************************************************
$vch_num	= $ARGV[1];

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
printf("module router ( \n");

for ( $i = 0; $i < $port_num; $i++ ) {
	printf("        idata_%d,  \n", $i);
	printf("        ivalid_%d, \n", $i);
	printf("        ivch_%d,   \n", $i);
	printf("        oack_%d,   \n", $i);
	printf("        ordy_%d,   \n", $i);
	printf("        olck_%d,   \n", $i);
	printf("\n");
}
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("        odata_%d,  \n", $i);
	printf("        ovalid_%d, \n", $i);
	printf("        ovch_%d,   \n", $i);
	printf("        iack_%d,   \n", $i);
	printf("        ilck_%d,   \n", $i);
	printf("\n");
}
printf("        my_xpos, \n");
printf("        my_ypos, \n");
printf("\n");
printf("        clk, \n");
printf("        rst_ \n");

printf(");\n");
printf("parameter       ROUTERID = 0;\n");

printf("\n");

#*******************************************************************
# Port definitions
#*******************************************************************
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("input   [`DATAW:0] idata_%d;  \n", $i);
	printf("input              ivalid_%d; \n", $i);
	printf("input   [`VCHW:0]  ivch_%d;   \n", $i);
	printf("output  [`VCH:0]   oack_%d;   \n", $i);
	printf("output  [`VCH:0]   ordy_%d;   \n", $i);
	printf("output  [`VCH:0]   olck_%d;   \n", $i);
	printf("\n");
}
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("output  [`DATAW:0] odata_%d;  \n", $i);
	printf("output             ovalid_%d; \n", $i);
	printf("output  [`VCHW:0]  ovch_%d;   \n", $i);
	printf("input   [`VCH:0]   iack_%d;   \n", $i);
	printf("input   [`VCH:0]   ilck_%d;   \n", $i);
	printf("\n");
}
printf("input [`ARRAYW:0]  my_xpos; \n");
printf("input [`ARRAYW:0]  my_ypos; \n");
printf("\n");
printf("input    clk;  \n");
printf("input    rst_; \n");
printf("\n");

#*******************************************************************
# Wire/Register definitions
#*******************************************************************
printf("/* \n");
printf(" * Wires from input channels (ic_) \n");
printf(" */ \n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire [`DATAW:0] ic_odata_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire            ic_ovalid_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire [`VCHW:0]  ic_ovch_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire [`PORTW:0] ic_port_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire            ic_req_%d; \n", $i);
}
printf("\n");

printf("/* \n");
printf(" * Wires from crossbar (cb_) \n");
printf(" */ \n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire [`DATAW:0] cb_odata_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire            cb_ovalid_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire [`VCHW:0]  cb_ovch_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire [`PORT:0]  cb_grt_%d; \n", $i);
}
printf("\n");

printf("/* \n");
printf(" * Wires from output channels (oc_) \n");
printf(" */ \n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire [`VCH:0]   oc_ordy_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("wire [`VCH:0]   oc_olck_%d; \n", $i);
}
printf("\n");

#*******************************************************************
# Module instances
#*******************************************************************
printf("/* \n");
printf(" * Input physical channels \n");
printf(" */ \n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("inputc #( ROUTERID, %d ) ic_%d ( \n", $i, $i);
	printf("       .idata ( idata_%d     ), \n", $i);
	printf("       .ivalid( ivalid_%d    ), \n", $i);
	printf("       .ivch  ( ivch_%d      ), \n", $i);
	printf("       .oack  ( oack_%d      ), \n", $i);
	printf("       .ordy  ( ordy_%d      ), \n", $i);
	printf("       .olck  ( olck_%d      ), \n", $i);
	printf("\n");
	printf("       .odata ( ic_odata_%d  ), \n", $i);
	printf("       .ovalid( ic_ovalid_%d ), \n", $i);
	printf("       .ovch  ( ic_ovch_%d   ), \n", $i);
	printf("\n");
	for ( $j = 0; $j < $port_num; $j++ ) {
		printf("       .irdy_%d( oc_ordy_%d   ), \n", $j, $j);
	}
	for ( $j = 0; $j < $port_num; $j++ ) {
		printf("       .ilck_%d( oc_olck_%d   ), \n", $j, $j);
	}
	printf("\n");
	for ( $j = 0; $j < $port_num; $j++ ) {
		printf("       .grt_%d ( cb_grt_%d[%d] ), \n", $j, $i, $j);
	}
	printf("\n");
	printf("       .port  ( ic_port_%d   ), \n", $i);
	printf("       .req   ( ic_req_%d    ), \n", $i);
	printf("\n");
	printf("       .my_xpos( my_xpos    ),  \n");
	printf("       .my_ypos( my_ypos    ),  \n");
	printf("\n");
	printf("       .clk ( clk  ),          \n");
	printf("       .rst_( rst_ )           \n", $i);
	printf(");                             \n");
	printf("\n");
}
printf("\n");

printf("/* \n");
printf(" * Crossbar switch \n");
printf(" */ \n");
printf("cb cb ( \n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("        .idata_%d ( ic_odata_%d  ), \n", $i, $i);
	printf("        .ivalid_%d( ic_ovalid_%d ), \n", $i, $i);
	printf("        .ivch_%d  ( ic_ovch_%d   ), \n", $i, $i);
	printf("        .port_%d  ( ic_port_%d   ), \n", $i, $i);
	printf("        .req_%d   ( ic_req_%d    ), \n", $i, $i);
	printf("        .grt_%d   ( cb_grt_%d    ), \n", $i, $i);
	printf("\n");
}
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("        .odata_%d ( cb_odata_%d  ), \n", $i, $i);
	printf("        .ovalid_%d( cb_ovalid_%d ), \n", $i, $i);
	printf("        .ovch_%d  ( cb_ovch_%d   ), \n", $i, $i);
	printf("\n");
}
printf("        .clk ( clk  ),\n");
printf("        .rst_( rst_ ) \n");
printf(");                    \n");
printf("\n");

printf("/* \n");
printf(" * Output channels \n");
printf(" */ \n");
for ( $i = 0; $i < $port_num; $i++ ) {
	printf("outputc #( ROUTERID, %d ) oc_%d ( \n", $i, $i);
	printf("       .idata ( cb_odata_%d  ), \n", $i);
	printf("       .ivalid( cb_ovalid_%d ), \n", $i);
	printf("       .ivch  ( cb_ovch_%d   ), \n", $i);
	printf("\n");
	printf("       .odata ( odata_%d     ), \n", $i);
	printf("       .ovalid( ovalid_%d    ), \n", $i);
	printf("       .ovch  ( ovch_%d      ), \n", $i);
	printf("\n");
	printf("       .iack  ( iack_%d      ), \n", $i);
	printf("       .ordy  ( oc_ordy_%d   ), \n", $i);
	printf("\n");
	printf("       .ilck  ( ilck_%d      ), \n", $i);
	printf("       .olck  ( oc_olck_%d   ), \n", $i);
	printf("\n");
	printf("       .clk ( clk  ),\n");
	printf("       .rst_( rst_ ) \n");
	printf(");                  \n");
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
