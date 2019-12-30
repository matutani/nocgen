#!/usr/bin/perl

#*******************************************************************
# $Id: vcmux_gen.pl 19 2010-02-28 22:03:12Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 1 ) {
	printf("usage: ./vcmux_gen.pl <vch_num> \n");
	exit;
}

#*******************************************************************
# Number of virtual channels
#*******************************************************************
$vch_num	= $ARGV[0];

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
printf("module vcmux ( \n");

for ( $i = 0; $i < $vch_num; $i++) {
	printf("        ovalid%d, \n", $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++) {
	printf("        odata%d, \n", $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++) {
	printf("        ovch%d, \n", $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++) {
	printf("        req%d, \n", $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++) {
	printf("        port%d, \n", $i);
}
printf("\n");
printf("        ovalid, \n");
printf("        odata,  \n");
printf("        ovch,   \n");
printf("        req,    \n");
printf("        port,   \n");
printf("        vcsel,  \n");
printf("\n");
printf("        clk,    \n");
printf("        rst_    \n");
printf(");\n");

#*******************************************************************
# Port definitions
#*******************************************************************
for ( $i = 0; $i < $vch_num; $i++) {
	printf("input                   ovalid%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++) {
	printf("input   [`DATAW:0]      odata%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++) {
	printf("input   [`VCHW:0]       ovch%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++) {
	printf("input                   req%d; \n", $i);
}
printf("\n");
for ( $i = 0; $i < $vch_num; $i++) {
	printf("input   [`PORTW:0]      port%d; \n", $i);
}
printf("\n");
printf("output                  ovalid; \n");
printf("output  [`DATAW:0]      odata;  \n");
printf("output  [`VCHW:0]       ovch;   \n");
printf("output                  req;    \n");
printf("output  [`PORTW:0]      port;   \n");
printf("output  [`VCH:0]        vcsel;  \n");
printf("\n");
printf("input   clk, rst_; \n");
printf("\n");

#*******************************************************************
# Wire/Register definitions
#*******************************************************************
printf("reg    [`VCH:0]         last;   \n");
printf("wire   [`VCH:0]         grt;    \n");
printf("wire   [`VCH:0]         hold;   \n");
printf("wire                    anyhold;\n");
printf("\n");

#*******************************************************************
# MUXs
#*******************************************************************
printf("assign  hold    = last & {");
for ( $i = $vch_num - 1; $i >= 1; $i-- ) {
	printf("req%d, ", $i);
}
printf("req0};\n");
printf("assign  anyhold = |hold; \n");
printf("assign  vcsel   = grt;  \n");
printf("\n");

printf("always @ (posedge clk) begin          \n");
printf("        if (rst_ == `Enable_)         \n");
printf("                last    <= `VCH_P1'b0;\n");
printf("        else if (last != grt)         \n");
printf("                last    <= grt;       \n");
printf("end                                   \n");
printf("\n");

for ( $i = 0; $i < $vch_num; $i++ ) {
	printf("assign  grt[%d]  = anyhold ? hold[%d] : (", $i, $i);
	for ( $j = 0; $j < $i; $j++ ) {
		printf("!req%d & ", $j);
	}
	printf(" req%d);\n", $j);
}
printf("\n");

printf("assign  ovalid  = ");
for ( $i = 0; $i < $vch_num - 1; $i++ ) {
	printf("ovalid%d | ", $i);
}
printf("ovalid%d;\n", $i);
printf("assign  req     = ");
for ( $i = 0; $i < $vch_num - 1; $i++ ) {
	printf("req%d | ", $i);
}
printf("req%d;\n", $i);
printf("\n");

printf("assign  odata   = \n");
for ( $i = 0; $i < $vch_num - 1; $i++ ) {
	printf("                  (last[%d] == `Enable) ? odata%d :\n", $i, $i);
}
printf("                  (last[%d] == `Enable) ? odata%d : `DATAW_P1'b0;\n", $i, $i);
printf("assign  ovch    = \n");
for ( $i = 0; $i < $vch_num - 1; $i++ ) {
	printf("                  (last[%d] == `Enable) ? ovch%d :\n", $i, $i);
}
printf("                  (last[%d] == `Enable) ? ovch%d : `VCHW_P1'b0;\n", $i, $i);
printf("assign  port    = \n");
for ( $i = 0; $i < $vch_num - 1; $i++ ) {
	printf("                  (vcsel[%d] == `Enable) ? port%d :\n", $i, $i);
}
printf("                  (vcsel[%d] == `Enable) ? port%d : `PORTW_P1'b0;\n", $i, $i);
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
