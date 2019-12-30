#!/usr/bin/perl

#*******************************************************************
# $Id: arb_gen.pl 12 2009-11-09 08:33:20Z matutani $ 
#*******************************************************************

#*******************************************************************
# Number of ports
#*******************************************************************
$port_num	= $ARGV[0];

#*******************************************************************
# Arbiter type (fixed, roundrobin)
#*******************************************************************
$arbiter_type	= $ARGV[1];

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
printf("module arb ( \n");
printf("        req, \n");
printf("        grt, \n");
printf("        clk, \n");
printf("        rst_ \n");
printf(");\n");

printf("\n");

#*******************************************************************
# Port definitions
#*******************************************************************
printf("input  [`PORT:0]  req;      \n");
printf("output [`PORT:0]  grt;      \n");
printf("input             clk, rst_;\n");
printf("\n");

#*******************************************************************
# Fixed-priority arbiter
#*******************************************************************
if ( $arbiter_type eq "fixed" ) {
	printf("assign  grt[0]  =                   req[0]; \n");
	printf("assign  grt[1]  = (req[0]   == 0) & req[1]; \n");
	for ( $i = 2; $i < $port_num; $i++ ) {
		printf("assign  grt[%d]  = (req[%d:0] == 0) & req[%d]; \n", $i, $i - 1, $i);
	}
	printf("\n");
}

#*******************************************************************
# Round-robin arbiter
#*******************************************************************
if ( $arbiter_type eq "roundrobin" ) {

	#
	# Port definitions
	#
	for ( $i = 0; $i < $port_num; $i++ ) {
        	printf("wire    [`PORTW:0]  pri%did;         /* client ID of the no.%d priority */ \n", $i, $i + 1);
	}
	for ( $i = 0; $i < $port_num; $i++ ) {
        	printf("wire                    pri%dgrt;        /* enabled if pri%d is granted */ \n", $i, $i);
	}
	printf("\n");
	printf("reg     [`PORTW:0]  pri [0:`PORT]; \n");
	printf("\n");

	for ( $i = 0; $i < $port_num; $i++ ) {
        	printf("assign  pri%dgrt = ", $i);
        	for ( $j = 0; $j < $i; $j++ ) {
                	printf("~req[pri%did] & ", $j);
        	}
        	printf(" req[pri%did]; \n", $i);
	}
	printf("\n");

	for ( $i = 0; $i < $port_num; $i++ ) {
        	printf("assign  grt[%d]  = \n", $i);
        	for ( $j = 0; $j < $port_num; $j++ ) {
                	printf("\t\t(pri%did == %d) ? ", $j, $i);
                	for ( $k = 0; $k < $j; $k++ ) {
                        	printf("~pri%dgrt & ", $k);
                	}
                	printf(" pri%dgrt : \n", $j);
        	}
        	printf("\t\t`Disable; \n");
	}
	printf("\n");


	for ( $i = 0; $i < $port_num; $i++ ) {
        	printf("assign  pri%did  = ", $i);
        	for ( $j = 0; $j < $port_num - 1; $j++ ) {
                	printf("(pri[%d] == %d) ? %d : ", $j, $i, $j);
        	}
        	printf("%d;\n", $port_num - 1);
	}
	printf("\n");

	printf("always @ (posedge clk) begin \n");
	printf("\tif (rst_ == `Enable_) begin \n");
	for ( $i = 0; $i < $port_num; $i++ ) {
        	printf("\t\tpri[%d]  <= %d;           /* client%d's initial priority */ \n", $i, $i, $i);
	}
	for ( $i = 0; $i < $port_num; $i++ ) {
        	printf("\tend else if (grt[%d]) begin \n", $i);
        	for ( $j = 0; $j < $port_num; $j++ ) {
                	if ( $i == $j ) {
                        	printf("\t\tpri[%d]  <= `PORT;\n", $j);
                	} else {
                        	printf("\t\tif (pri[%d] > pri[%d]) pri[%d]     <= pri[%d] - 1; \n", $j, $i, $j, $j);
                	}
        	}
	}
	printf("\tend \n");
	printf("end \n");
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
