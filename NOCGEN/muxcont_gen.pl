#!/usr/bin/perl

#*******************************************************************
# $Id: muxcont_gen.pl 12 2009-11-09 08:33:20Z matutani $ 
#*******************************************************************

#*******************************************************************
# Number of ports
#*******************************************************************
$port_num	= $ARGV[0];
$port_width	= &get_bitwidth($port_num) - 1;
$port_width_p1	= $port_width + 1;

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
printf("module muxcont ( \n");

for ( $i = 0; $i < $port_num; $i++) {
	printf("        port_%d,   \n", $i);
	printf("        req_%d,    \n", $i);
	printf("\n");
}
printf("        sel, \n");
printf("        grt, \n");
printf("\n");
printf("        clk, \n");
printf("        rst_ \n");

printf(");\n");
printf("parameter       PORTID = 0; \n");

printf("\n");

#*******************************************************************
# Port definitions
#*******************************************************************
for ( $i = 0; $i < $port_num; $i++) {
	printf("input  [`PORTW:0] port_%d;   \n", $i);
	printf("input             req_%d;    \n", $i);
	printf("\n");
}
printf("output [`PORT:0]  sel; \n");
printf("output [`PORT:0]  grt; \n");
printf("\n");
printf("input             clk, rst_; \n");
printf("\n");

#*******************************************************************
# Wire/Register definitions
#*******************************************************************
printf("reg    [`PORT:0]  last; \n");
printf("wire   [`PORT:0]  req;  \n");
printf("wire   [`PORT:0]  grt0; \n");
printf("wire   [`PORT:0]  hold; \n");
printf("wire              anyhold;\n");
printf("\n");

for ( $i = 0; $i < $port_num; $i++ ) {
	printf("assign  req[%d]  = req_%d & (port_%d == PORTID); \n", $i, $i, $i);
}
printf("\n");

printf("assign  hold    = last & req; \n");
printf("assign  anyhold = |hold;      \n");
printf("assign  sel     = last;       \n");
printf("\n");

printf("always @ (posedge clk) begin \n");
printf("        if (rst_ == `Enable_) \n");
printf("                last    <= `PORT_P1'b0; \n");
printf("        else if (last != grt)               \n");
printf("                last    <= grt;             \n");
printf("end \n");
printf("\n");


for ( $i = 0; $i < $port_num; $i++ ) {
	printf("assign  grt[%d]  = anyhold ? hold[%d] : grt0[%d]; \n", $i, $i, $i);
}
printf("\n");

printf("/*                     \n");
printf(" * Arbiter             \n");
printf(" */                    \n");
printf("arb a0 (               \n");
printf("        .req ( req  ), \n");
printf("        .grt ( grt0 ), \n");
printf("        .clk ( clk  ), \n");
printf("        .rst_( rst_ )  \n");
printf(");                     \n");

printf("\n");

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
