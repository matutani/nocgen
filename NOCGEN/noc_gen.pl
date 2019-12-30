#!/usr/bin/perl

#*******************************************************************
# $Id: noc_gen.pl 16 2010-02-20 15:09:25Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 2 ) {
        printf("usage: ./noc_gen.pl <array_size> <topology_type> \n");
        exit;
}

#*******************************************************************
# Array size
#*******************************************************************
$array_size	= $ARGV[0];

#*******************************************************************
# Topology type (mesh, ring, linear)
#*******************************************************************
$topology_type	= $ARGV[1];

#*******************************************************************
# Number of switches
#*******************************************************************
if ( $topology_type eq "mesh" ) {
	$switch_num     = $array_size * $array_size;
	$port_num	= 4 + 1;
} elsif ( $topology_type eq "ring" || $topology_type eq "linear" ) {
	$switch_num     = $array_size;
	$port_num	= 2 + 1;
} else {
	printf("Error: unknown topology type (%s). \n", $topology_type);
	die;
}

#*******************************************************************
# Parameter file
#*******************************************************************
$param_file       = "define.h";

#*******************************************************************
# Include parameter file
#*******************************************************************
printf("`include \"%s\" \n", $param_file);

#***********************************************************
# Module name and port list
#***********************************************************
printf("module noc ( \n");
printf("\n");

for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("        /* n%d */ \n", $i);
	printf("        n%d_idata_p0,  \n", $i);
	printf("        n%d_ivalid_p0, \n", $i);
	printf("        n%d_ivch_p0,   \n", $i);
	printf("        n%d_ordy_p0,   \n", $i);
	printf("        n%d_odata_p0,  \n", $i);
	printf("        n%d_ovalid_p0, \n", $i);
	printf("\n");
}

printf("        clk, \n");
printf("        rst_ \n");
printf(");   \n");
printf("\n");

#***********************************************************
# I/O signals
#***********************************************************
for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("/* n%d */ \n", $i);
	printf("input   [`DATAW:0]      n%d_idata_p0;  \n", $i);
	printf("input                   n%d_ivalid_p0; \n", $i);
	printf("input   [`VCHW:0]       n%d_ivch_p0;   \n", $i);
	printf("output  [`VCH:0]        n%d_ordy_p0;   \n", $i);
	printf("output  [`DATAW:0]      n%d_odata_p0;  \n", $i);
	printf("output                  n%d_ovalid_p0; \n", $i);
	printf("\n");
}
printf("input clk, rst_; \n");
printf("\n");

#***********************************************************
# Wires and registers
#***********************************************************
for ( $src = 0; $src < $switch_num; $src++ ) {
	for ( $dst = 0; $dst < $switch_num; $dst++ ) {
		$links[$src][$dst] = 0;
	}
}
if ( $topology_type eq "mesh" ) {
	for ( $src = 0; $src < $switch_num; $src++ ) {
		$src_x	= int($src % $array_size);
		$src_y	= int($src / $array_size);
		# port0 (north) 
		if ( $src_y != 0 ) {
			$dst	= $src - $array_size;
			$links[$src][$dst] = 1;
			$lport[$src][$dst] = 0;
			$rport[$src][$dst] = 2;
		}
		# port1 (east) 
		if ( $src_x != ($array_size - 1) ) {
			$dst	= $src + 1;
			$links[$src][$dst] = 1;
			$lport[$src][$dst] = 1;
			$rport[$src][$dst] = 3;
		}
		# port2 (south) 
		if ( $src_y != ($array_size - 1) ) {
			$dst	= $src + $array_size;
			$links[$src][$dst] = 1;
			$lport[$src][$dst] = 2;
			$rport[$src][$dst] = 0;
		}
		# port3 (west) 
		if ( $src_x != 0 ) {
			$dst	= $src - 1;
			$links[$src][$dst] = 1;
			$lport[$src][$dst] = 3;
			$rport[$src][$dst] = 1;
		}
	}
} 
if ( $topology_type eq "ring" || $topology_type eq "linear" ) {
	for ( $src = 0; $src < $switch_num; $src++ ) {
		# port1 (east) 
		if ( $src != ($array_size - 1) ) {
			$dst	= $src + 1;
			$links[$src][$dst] = 1;
			$lport[$src][$dst] = 0;
			$rport[$src][$dst] = 1;
		} else {
			$dst	= 0;
			$links[$src][$dst] = 1;
			$lport[$src][$dst] = 0;
			$rport[$src][$dst] = 1;
		}
		# port3 (west) 
		if ( $src != 0 ) {
			$dst	= $src - 1;
			$links[$src][$dst] = 1;
			$lport[$src][$dst] = 1;
			$rport[$src][$dst] = 0;
		} else {
			$dst	= $array_size - 1;
			$links[$src][$dst] = 1;
			$lport[$src][$dst] = 1;
			$rport[$src][$dst] = 0;
		}
	}
} 

for ( $src = 0; $src < $switch_num; $src++ ) {
	for ( $dst = 0; $dst < $switch_num; $dst++ ) {
		if ( $links[$src][$dst] == 0 ) { 
			next; 
		}
		printf("/* n%d --> n%d */ \n", $src, $dst);
		printf("wire    [`DATAW:0]      n%d_odata_%d;  \n", $src, $lport[$src][$dst]);
		printf("wire                    n%d_ovalid_%d; \n", $src, $lport[$src][$dst]);
		printf("wire    [`VCH:0]        n%d_oack_%d;   \n", $dst, $rport[$src][$dst]);
		printf("wire    [`VCH:0]        n%d_olck_%d;   \n", $dst, $rport[$src][$dst]);
		printf("wire    [`VCHW:0]       n%d_ovch_%d;   \n", $dst, $rport[$src][$dst]);
	}
}
printf("\n");

#***********************************************************
# Modules instances
#***********************************************************
for ( $i = 0; $i < $switch_num; $i++ ) {
	printf("router #( %d ) n%d ( \n", $i, $i);

	if ( $topology_type eq "mesh" ) {
		$cp = 4;	# core port 
	} elsif ( $topology_type eq "ring" || $topology_type eq "linear") {
		$cp = 2;	# core port 
	}
	printf("        .idata_%d ( n%d_idata_p0  ), \n", $cp, $i);
	printf("        .ivalid_%d( n%d_ivalid_p0 ), \n", $cp, $i);
	printf("        .ivch_%d  ( n%d_ivch_p0   ), \n", $cp, $i);
	printf("        .ordy_%d  ( n%d_ordy_p0   ), \n", $cp, $i);

	printf("        .odata_%d ( n%d_odata_p0  ), \n", $cp, $i);
	printf("        .ovalid_%d( n%d_ovalid_p0 ), \n", $cp, $i);
	printf("        .iack_%d  ( `VCH_P1'hff  ),  \n", $cp);
	printf("        .ilck_%d  ( `VCH_P1'h00  ),  \n", $cp);
	printf("\n");

	for ( $j = 0; $j < $port_num - 1; $j++ ) {
		$src = $i;
		$connection = 0;
		for ( $dst = 0; $dst < $switch_num; $dst++ ) {
			if ( $links[$src][$dst] == 0 ) { 
				next; 
			}
			$lp = $lport[$src][$dst];
			$rp = $rport[$src][$dst];
			if ( $lp == $j ) {
				$connection = 1;
				last;
			}
		}

		if ( $connection == 1) {
			printf("        .idata_%d ( n%d_odata_%d   ), \n", $j, $dst, $rp);
			printf("        .ivalid_%d( n%d_ovalid_%d  ), \n", $j, $dst, $rp);
			printf("        .ivch_%d  ( n%d_ovch_%d    ), \n", $j, $dst, $rp);
			printf("        .oack_%d  ( n%d_oack_%d    ), \n", $j, $src, $lp);
			printf("        .olck_%d  ( n%d_olck_%d    ), \n", $j, $src, $lp);

			printf("        .odata_%d ( n%d_odata_%d   ), \n", $j, $src, $lp);
			printf("        .ovalid_%d( n%d_ovalid_%d  ), \n", $j, $src, $lp);
			printf("        .ovch_%d  ( n%d_ovch_%d    ), \n", $j, $src, $lp);
			printf("        .iack_%d  ( n%d_oack_%d    ), \n", $j, $dst, $rp);
			printf("        .ilck_%d  ( n%d_olck_%d    ), \n", $j, $dst, $rp);
		} else {
			printf("        .idata_%d ( `DATAW_P1'b0 ),  \n", $j);
			printf("        .ivalid_%d( 1'b0         ),  \n", $j);
			printf("        .ivch_%d  ( `VCHW_P1'b0  ),  \n", $j);

			printf("        .iack_%d  ( `VCH_P1'b0   ),  \n", $j);
			printf("        .ilck_%d  ( `VCH_P1'b0   ),  \n", $j);
		}
		printf("\n");
	}
 	printf("        .my_xpos ( %d ), \n", $i % $array_size);
 	printf("        .my_ypos ( %d ), \n", $i / $array_size);
	printf("\n");

	printf("        .clk ( clk  ), \n");
	printf("        .rst_( rst_ )  \n");
	printf("); \n");
	printf("\n");
}

printf("endmodule \n");

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
