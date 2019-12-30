#!/usr/bin/perl

#*******************************************************************
# $Id: define_gen.pl 12 2009-11-09 08:33:20Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 7 ) {
	printf("usage: ./define_gen.pl <data_width> <array_size> <node_num> <port_num> <vch_num> <buf_size> <packet_len> \n");
	exit;
}

#*******************************************************************
# Data width
#*******************************************************************
$data_width	= $ARGV[0];

#*******************************************************************
# Array size
#*******************************************************************
$array_size	= $ARGV[1];

#*******************************************************************
# Number of nodes
#*******************************************************************
$node_num	= $ARGV[2];

#*******************************************************************
# Number of ports
#*******************************************************************
$port_num	= $ARGV[3];

#*******************************************************************
# Number of virtual channels
#*******************************************************************
$vch_num	= $ARGV[4];

#*******************************************************************
# Input buffer size [flits]
#*******************************************************************
$buf_size	= $ARGV[5];

#*******************************************************************
# Packet length [flits]
#*******************************************************************
$packet_len	= $ARGV[6];

#*******************************************************************
# Common definitions
#*******************************************************************
printf("/* Common definitions */           \n");
printf("`define Enable          1'b1       \n");
printf("`define Disable         1'b0       \n");
printf("`define Enable_         1'b0       \n");
printf("`define Disable_        1'b1       \n");
printf("`define High            1'b1       \n");
printf("`define Low             1'b0       \n");
printf("`define Write           1'b1       \n");
printf("`define Read            1'b0       \n");
printf("`define NULL            0          \n");
printf("\n");

#*******************************************************************
# Data width
#*******************************************************************
printf("/* Data width (%d-bit data + 3-bit type) */ \n", $data_width);
printf("`define DATAW           %d                  \n", $data_width + 3 - 1);
printf("`define DATAW_P1        %d                  \n", $data_width + 3);
printf("`define DST_LSB         0                   \n");
printf("`define DST_MSB         %d                  \n", &get_bitwidth($node_num) * 1 - 1);
printf("`define SRC_LSB         %d                  \n", &get_bitwidth($node_num) * 1);
printf("`define SRC_MSB         %d                  \n", &get_bitwidth($node_num) * 2 - 1);
printf("`define VCH_LSB         %d                  \n", &get_bitwidth($node_num) * 2);
printf("`define VCH_MSB         %d                  \n", &get_bitwidth($node_num) * 3 - 1);
printf("`define TYPE_LSB        %d                  \n", $data_width);
printf("`define TYPE_MSB        %d                  \n", $data_width + 3 - 1);
printf("\n");

#*******************************************************************
# Flit type
#*******************************************************************
printf("/* Flit type */                 \n");
printf("`define TYPEW           2       \n");
printf("`define TYPEW_P1        3       \n");
printf("`define TYPE_NONE       3'b000  \n");
printf("`define TYPE_HEAD       3'b001  \n");
printf("`define TYPE_TAIL       3'b010  \n");
printf("`define TYPE_HEADTAIL   3'b011  \n");
printf("`define TYPE_DATA       3'b100  \n");
printf("\n");

#*******************************************************************
# Input FIFO
#*******************************************************************
printf("/* Input FIFO (4-element) */ \n");
printf("`define FIFO            %d \n", $buf_size - 1);
printf("`define FIFO_P1         %d \n", $buf_size);
printf("`define FIFOD           %d \n", &get_bitwidth($buf_size) - 1);
printf("`define FIFOD_P1        %d \n", &get_bitwidth($buf_size));
printf("`define PKTLEN          %d \n", $packet_len - 1);
printf("`define PKTLEN_P1       %d \n", $packet_len);
printf("\n");

#*******************************************************************
# Port number
#*******************************************************************
printf("/* Port number (%d-port) */        \n", $port_num);
printf("`define PORT            %d         \n", $port_num - 1);
printf("`define PORT_P1         %d         \n", $port_num);
printf("`define PORTW           %d         \n", &get_bitwidth($port_num) - 1);
printf("`define PORTW_P1        %d         \n", &get_bitwidth($port_num));
printf("\n");

#*******************************************************************
# Vch number
#*******************************************************************
printf("/* Vch number (%d-VC) */   \n", $vch_num);
if ( $vch_num > 1 ) {
	printf("`define VCH             %d \n", $vch_num - 1);
	printf("`define VCH_P1          %d \n", $vch_num);
	printf("`define VCHW            %d \n", &get_bitwidth($vch_num) - 1);
	printf("`define VCHW_P1         %d \n", &get_bitwidth($vch_num));
} else {
	printf("`define VCH             %d \n", 0);
	printf("`define VCH_P1          %d \n", 1);
	printf("`define VCHW            %d \n", 0);
	printf("`define VCHW_P1         %d \n", 1);
}
printf("\n");

#*******************************************************************
# Node number
#*******************************************************************
printf("/* Node number (%d-node) */        \n", $node_num);
printf("`define NODE            %d         \n", $node_num - 1);
printf("`define NODE_P1         %d         \n", $node_num);
printf("`define NODEW           %d         \n", &get_bitwidth($node_num) - 1);
printf("`define NODEW_P1        %d         \n", &get_bitwidth($node_num));
printf("\n");

#*******************************************************************
# Dimenion-order routing
#*******************************************************************
printf("/* Dimenion-order routing */\n");
printf("`define ENTRYW          %d         \n", &get_bitwidth($node_num) * 1 - 1);
printf("`define ENTRYW_P1       %d         \n", &get_bitwidth($node_num) * 1);
printf("`define ARRAYW          %d         \n", &get_bitwidth($array_size) - 1);
printf("`define ARRAYW_P1       %d         \n", &get_bitwidth($array_size));
printf("`define DSTX_LSB        0          \n");
printf("`define DSTX_MSB        %d         \n", &get_bitwidth($array_size) - 1);
printf("`define DSTY_LSB        %d         \n", &get_bitwidth($array_size));
printf("`define DSTY_MSB        %d         \n", &get_bitwidth($array_size) * 2 - 1);
printf("`define ARRAY_DIV2      %d         \n", int($array_size / 2));
printf("\n");

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
