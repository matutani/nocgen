#!/usr/bin/perl

#*******************************************************************
# $Id: inputc_gen.pl 19 2010-02-28 22:03:12Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 3 ) {
	printf("usage: ./inputc_gen.pl <port_num> <vch_num> <routing_type> \n");
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
# Routing type
#*******************************************************************
$routing_type	= $ARGV[2];

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
printf("module inputc ( \n");

printf("        idata,  \n");
printf("        ivalid, \n");
printf("        ivch,   \n");
printf("        oack,   \n");
printf("        ordy,   \n");
printf("        olck,   \n");
printf("\n");
printf("        odata,  \n");
printf("        ovalid, \n");
printf("        ovch,   \n");
printf("\n");
for ( $i = 0; $i < $port_num; $i++) {
	printf("        irdy_%d, \n", $i);
}
for ( $i = 0; $i < $port_num; $i++) {
	printf("        ilck_%d, \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++) {
	printf("        grt_%d, \n", $i);
}
printf("\n");
printf("        port,  \n");
printf("        req,   \n");
printf("\n");
printf("        my_xpos, \n");
printf("        my_ypos, \n");
printf("\n");
printf("        clk, \n");
printf("        rst_ \n");

printf(");\n");
printf("parameter       ROUTERID= 0;\n");
printf("parameter       PCHID   = 0;\n");
printf("\n");

#*******************************************************************
# Port definitions
#*******************************************************************
printf("input   [`DATAW:0]      idata;  \n");
printf("input                   ivalid; \n");
printf("input   [`VCHW:0]       ivch;   \n");
printf("output  [`VCH:0]        oack;   \n");
printf("output  [`VCH:0]        ordy;   \n");
printf("output  [`VCH:0]        olck;   \n");
printf("\n");
printf("output  [`DATAW:0]      odata;  \n");
printf("output                  ovalid; \n");
printf("output  [`VCHW:0]       ovch;   \n");
printf("\n");
for ( $i = 0; $i < $port_num; $i++) {
	printf("input   [`VCH:0]        irdy_%d; \n", $i);
}
for ( $i = 0; $i < $port_num; $i++) {
	printf("input   [`VCH:0]        ilck_%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $port_num; $i++) {
	printf("input                   grt_%d; \n", $i);
}
printf("\n");
printf("output  [`PORTW:0]      port;   \n");
printf("output                  req;    \n");
printf("\n");
printf("input   [`ARRAYW:0]     my_xpos;\n");
printf("input   [`ARRAYW:0]     my_ypos;\n");
printf("\n");
printf("input   clk, rst_;              \n");
printf("\n");

#*******************************************************************
# Wires
#*******************************************************************
for ( $i = 0; $i < $vch_num; $i++) {
	printf("wire    [`DATAW:0]      odata%d; \n", $i);
	printf("wire                    ovalid%d;\n", $i);
	printf("wire    [`VCHW:0]       ovch%d;  \n", $i);
	printf("wire    [`PORTW:0]      port%d;  \n", $i);
	printf("wire                    req%d;   \n", $i);
	printf("wire                    send%d;  \n", $i);
	printf("wire    [`DATAW:0]      bdata%d; \n", $i);
	printf("wire    [`TYPEW:0]      btype%d; \n", $i);
	printf("\n");
}
printf("wire    [`VCH:0]        vcsel;\n");
printf("\n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("assign  oack[%d]        = send%d;\n", $i, $i);
}
printf("\n");

#*******************************************************************
# Module instances
#*******************************************************************
printf("/* \n");
printf(" * VC mux \n");
printf(" */ \n");
printf("vcmux vcmux ( \n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("        .ovalid%d ( ovalid%d ),\n", $i, $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("        .odata%d  ( odata%d ),\n", $i, $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("        .ovch%d   ( ovch%d ),\n", $i, $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("        .req%d    ( req%d ),\n", $i, $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("        .port%d   ( port%d ),\n", $i, $i);
}
printf("\n");
printf("        .ovalid  ( ovalid ),\n");
printf("        .odata   ( odata  ),\n");
printf("        .ovch    ( ovch   ),\n");
printf("        .req     ( req    ),\n");
printf("        .port    ( port   ),\n");
printf("        .vcsel   ( vcsel  ),\n");
printf("\n");
printf("        .clk     ( clk    ),\n");
printf("        .rst_    ( rst_   ) \n");
printf(");\n");
printf("\n");

printf("/* \n");
printf(" * Input virtual channels \n");
printf(" */ \n");
for ( $i = 0; $i < $vch_num; $i++ ) {
        printf("vc #( ROUTERID, PCHID, %d ) vc_%d ( \n", $i, $i);
        printf("       .bdata ( bdata%d  ), \n", $i);
        printf("       .send  ( send%d   ), \n", $i);
        printf("       .olck  ( olck[%d] ), \n", $i);
        printf("\n");
        for ( $j = 0; $j < $port_num; $j++ ) {
                printf("       .irdy_%d( irdy_%d  ), \n", $j, $j);
        }
        for ( $j = 0; $j < $port_num; $j++ ) {
                printf("       .ilck_%d( ilck_%d  ), \n", $j, $j);
        }
        printf("\n");
        for ( $j = 0; $j < $port_num; $j++ ) {
		printf("       .grt_%d ( vcsel[%d] ? grt_%d : `Disable ), \n", $j, $i, $j);
	}
        printf("\n");
	printf("       .req   ( req%d    ),\n", $i);
        printf("       .port  ( port%d   ),\n", $i);
        printf("       .ovch  ( ovch%d   ),\n", $i);
        printf("\n");
        printf("       .clk ( clk  ), \n");
        printf("       .rst_( rst_ )  \n");
        printf(");                  \n");
}
printf("\n");

#*******************************************************************
# Data transmission
#*******************************************************************
printf("/*  \n");
printf(" * Data transmission \n");
printf(" */ \n");
#if ( $routing_type eq "src" ) {
#        printf("`define __RT_TYPE_SRC__ \n");
#}
#printf("`ifdef  __RT_TYPE_SRC__ \n");
#for ( $i = 0; $i < $vch_num; $i++ ) {
#	printf("assign  odata%d   = (send%d && btype%d == `TYPE_HEAD) ? {`TYPE_HEAD, `PORTW_P1'b0, bdata%d[(`DATAW-`TYPEW_P1):(`PORTW_P1)]} : \n", $i, $i, $i, $i);
#	printf("                    (send%d && btype%d == `TYPE_HEADTAIL) ? {`TYPE_HEADTAIL, `PORTW_P1'b0, bdata%d[(`DATAW-`TYPEW_P1):(`PORTW_P1)]} : \n", $i, $i, $i, $i);
#	printf("                    (send%d && btype%d != `TYPE_NONE) ? bdata%d : `DATAW_P1'b0; \n", $i, $i, $i);
#}
#printf("`else \n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("assign  odata%d   = send%d && btype%d != `TYPE_NONE ? bdata%d : `DATAW_P1'b0; \n", $i, $i, $i, $i);
}
#printf("`endif \n");
printf("\n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("assign  ovalid%d  = send%d && btype%d != `TYPE_NONE; \n", $i, $i, $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("assign  btype%d  = bdata%d[`TYPE_MSB:`TYPE_LSB]; \n", $i, $i);
}
printf("\n");

printf("/* \n");
printf(" * Routing computation logic \n");
printf(" */ \n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("rtcomp rc%d ( \n", $i);
	printf("        .addr   ( bdata%d[`DST_MSB:`DST_LSB] ),\n", $i);
	printf("        .ivch   ( bdata%d[`VCH_MSB:`VCH_LSB] ),\n", $i);
	printf("        .en     ( btype%d == `TYPE_HEAD || btype%d == `TYPE_HEADTAIL ),\n", $i, $i);
	printf("        .port   ( port%d  ),\n", $i);
	printf("        .ovch   ( ovch%d  ),\n", $i);
	printf("\n");
	printf("        .my_xpos( my_xpos ),\n");
	printf("        .my_ypos( my_ypos ),\n");
	printf("\n");
	printf("        .clk    ( clk  ),\n");
	printf("        .rst_   ( rst_ ) \n");
	printf(");\n");
}
printf("\n");

printf("/* \n");
printf(" * Input buffers \n");
printf(" */ \n");
for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("fifo    ibuf%d ( \n", $i);
	printf("        .idata  ( ivch == %d ? idata  : `DATAW_P1'b0 ), \n", $i);
	printf("        .odata  ( bdata%d ), \n", $i);
	printf("\n");
	printf("        .wr_en  ( ivch == %d ? ivalid : `Disable ), \n", $i);
	printf("        .rd_en  ( send%d ), \n", $i);
	printf("        .empty  ( /* not used */ ), \n");
	printf("        .full   ( /* not used */ ), \n");
	printf("        .ordy   ( ordy[%d]        ), \n", $i);
	printf("\n");
	printf("        .clk    ( clk  ), \n");
	printf("        .rst_   ( rst_ )  \n");
	printf("); \n");
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
