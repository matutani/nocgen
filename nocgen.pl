#!/usr/bin/perl

#*******************************************************************
# $Id: nocgen.pl 17 2010-02-20 17:04:09Z matutani $ 
#*******************************************************************

#*******************************************************************
# Array size
#*******************************************************************
$array_size	= 4;
#$array_size	= 16;

#*******************************************************************
# Topology type
# 	Supported	... mesh, ring, linear
#	Not supported	... torus, spidergon, fattrees, h-tree, FHT, ...
#*******************************************************************
$topology_type	= mesh;
#$topology_type	= linear;

#*******************************************************************
# Routing type
#	Supported	... mesh2d, mesh1d, torus1d
#	Not supported	... src (it's easy but noc_test isn't updated yet)
#*******************************************************************
$routing_type	= mesh2d;
#$routing_type	= mesh1d;

#*******************************************************************
# Data width
#*******************************************************************
$data_width	= 32;

#*******************************************************************
# Number of virtual channels (1: no VC, 2: two VCs, ...)
#*******************************************************************
$vch_num	= 2;

#*******************************************************************
# Input buffer size [flits] (must be larger than packet size)
#*******************************************************************
$buf_size	= 5;

#*******************************************************************
# Arbiter type (fixed, roundrobin)
#*******************************************************************
$arbiter_type	= fixed;
#$arbiter_type	= roundrobin;

#*******************************************************************
# Traffic pattern (uniform, random)
#*******************************************************************
$traffic_ptn	= random;
#$traffic_ptn	= uniform;

#*******************************************************************
# Maximum packet length (including HEAD and TAIL flits)
#*******************************************************************
$packet_len     = 5;

#*******************************************************************
# Number of packets each switch injects
#*******************************************************************
$packet_num     = 32;

#*******************************************************************
# Buffer size
#*******************************************************************
if ( $buf_size < $packet_len ) {
	printf("Error: buf_size must be equal or larger than packet_len.\n");
	die;
}

#*******************************************************************
# Number of switches and ports
#*******************************************************************
if ( $topology_type eq "mesh" ) { 
	$switch_num	= $array_size * $array_size;
	$port_num	= 4 + 1;
} elsif ( $topology_type eq "linear" ) { 
	$switch_num	= $array_size;
	$port_num	= 2 + 1;
} elsif ( $topology_type eq "ring" ) { 
	$switch_num	= $array_size;
	$port_num	= 2 + 1;
	if ( $vch_num < 2 ) {
		printf("Error: ring requires at least two virtual channels.\n");
		die;
	}
} else {
	printf("Error: unknown topology (%s). \n", $topology_type);
	die;
}

#*******************************************************************
# Print out the parameters
#*******************************************************************
printf("array_size	= %d \n", $array_size);
printf("topology_type	= %s \n", $topology_type);
printf("routing_type	= %s \n", $routing_type);
printf("data_width	= %d \n", $data_width);
printf("switch_num	= %d \n", $switch_num);
printf("port_num	= %d \n", $port_num);
printf("vch_num		= %d \n", $vch_num);
printf("buf_size	= %d \n", $buf_size);
printf("arbiter_type	= %s \n", $arbiter_type);
printf("traffic_ptn	= %s \n", $traffic_ptn);
printf("\n");

#*******************************************************************
# List of files
#*******************************************************************
$define_h	= "define.h";
$noc_test_v	= "noc_test.v";
$noc_v		= "noc.v";
$router_v	= "router.v";
$inputc_v	= "inputc.v";
$vc_v		= "vc.v";
$outputc_v	= "outputc.v";
$rtcomp_v	= "rtcomp.v";
$vcmux_v	= "vcmux.v";
$fifo_v		= "fifo.v";
$cb_v		= "cb.v";
$mux_v		= "mux.v";
$muxcont_v	= "muxcont.v";
$arb_v		= "arb.v";
$power_v	= "power.v";

#*******************************************************************
# Remove the existing files 
#*******************************************************************
unlink($define_h);
unlink($noc_test_v);
unlink($noc_v);
unlink($router_v);
unlink($inputc_v);
unlink($vc_v);
unlink($outputc_v);
unlink($rtcomp_v);
unlink($vcmux_v);
unlink($fifo_v);
unlink($cb_v);
unlink($mux_v);
unlink($muxcont_v);
unlink($arb_v);
unlink($power_v);

if ( @ARGV > 0 && $ARGV[0] eq "clean" ) {
	exit;
}

#*******************************************************************
# Generate the verilog source codes 
#*******************************************************************
#
# Parameter file
#
system("NOCGEN/define_gen.pl $data_width $array_size $switch_num $port_num $vch_num $buf_size $packet_len > $define_h");

#
# NoC
#
system("NOCGEN/noc_test_gen.pl $data_width $array_size $vch_num $topology_type $traffic_ptn $packet_len $packet_num > $noc_test_v");
system("NOCGEN/noc_gen.pl $array_size $topology_type > $noc_v");

#
# Router
#
system("NOCGEN/router_gen.pl  $port_num $vch_num               > $router_v");
system("NOCGEN/inputc_gen.pl  $port_num $vch_num $routing_type > $inputc_v");
system("NOCGEN/vc_gen.pl      $port_num                        > $vc_v");
system("NOCGEN/outputc_gen.pl $vch_num                         > $outputc_v");
system("NOCGEN/rtcomp_gen.pl  $routing_type                    > $rtcomp_v");
system("NOCGEN/vcmux_gen.pl   $vch_num                         > $vcmux_v");

#
# Buffer
#
system("NOCGEN/fifo_gen.pl > $fifo_v");

#
# Crossbar switch
#
system("NOCGEN/cb_gen.pl      $port_num $port_num     > $cb_v");
system("NOCGEN/muxcont_gen.pl $port_num               > $muxcont_v");
system("NOCGEN/mux_gen.pl     $port_num               > $mux_v");
system("NOCGEN/arb_gen.pl     $port_num $arbiter_type > $arb_v");

#
# Power estimation model
#
system("NOCGEN/power_gen.pl $port_num $data_width > $power_v");

printf("done. \n");

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
