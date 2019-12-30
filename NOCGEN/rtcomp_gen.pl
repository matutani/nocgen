#!/usr/bin/perl

#*******************************************************************
# $Id: rtcomp_gen.pl 16 2010-02-20 15:09:25Z matutani $
#*******************************************************************

#*******************************************************************
# Parameter file
#*******************************************************************
$param_file	= "define.h";

#*******************************************************************
# Routing type
# 	Supported	... mesh2d, mesh1d, torus1d
# 	Not supported	... src (it's easy but noc_test isn't updated yet)
#*******************************************************************
$routing_type	= $ARGV[0];

#*******************************************************************
# Include parameter file
#*******************************************************************
printf("`include \"%s\" \n", $param_file);

#*******************************************************************
# Module and port definitions
#*******************************************************************
print << "END_OF_MOD_PORT";
module rtcomp (
	addr,
	ivch,
	en,
	port,
	ovch,

	my_xpos,
	my_ypos,

	clk,
	rst_
);
input	[`ENTRYW:0]	addr;
input	[`ENTRYW:0]	ivch;
input			en;
output	[`PORTW:0]	port;
output	[`VCHW:0]	ovch;

input	[`ARRAYW:0]	my_xpos;
input	[`ARRAYW:0]	my_ypos;

input	clk;
input	rst_;

wire	[`PORTW:0]	port0;
reg	[`PORTW:0]	port1;
wire	[`VCHW:0]	ovch0;
reg	[`VCHW:0]	ovch1;

wire	[`ARRAYW:0]	dst_xpos;
wire	[`ARRAYW:0]	dst_ypos;
wire	[`ARRAYW:0]	delta_x1;	/* For torus */
wire	[`ARRAYW:0]	delta_x3;	/* For torus */

assign	dst_xpos= addr[`DSTX_MSB:`DSTX_LSB];
assign	dst_ypos= addr[`DSTY_MSB:`DSTY_LSB];

assign	port	= en ? port0 : port1;
assign	ovch	= en ? ovch0 : ovch1;

always @ (posedge clk) begin
	if (rst_ == `Enable_) begin
		port1	<= 0;
		ovch1	<= 0;
	end else if (en) begin
		port1	<= port0;
		ovch1	<= ovch0;
	end
end
END_OF_MOD_PORT

#*******************************************************************
# Output port
#*******************************************************************
if ( $routing_type eq "mesh2d" ) {
print << "END_OF_PORT_MESH2D";
assign	port0	= ( dst_xpos == my_xpos && dst_ypos == my_ypos ) ? 4 :
                  ( dst_xpos > my_xpos ) ? 1 :
                  ( dst_xpos < my_xpos ) ? 3 :
                  ( dst_ypos > my_ypos ) ? 2 : 0;
END_OF_PORT_MESH2D
} elsif ( $routing_type eq "mesh1d" ) {
print << "END_OF_PORT_MESH1D";
assign	port0	= ( dst_xpos == my_xpos ) ? 2 :
                  ( dst_xpos > my_xpos ) ? 0 : 1;
END_OF_PORT_MESH1D
} elsif ( $routing_type eq "torus1d" ) {
print << "END_OF_PORT_TORUS1D";
assign  delta_x1        = dst_xpos - my_xpos;
assign  delta_x3        = my_xpos - dst_xpos;
assign port0	= ( dst_xpos == my_xpos )                          ? 2 :
                  ( dst_xpos > my_xpos && delta_x1 > `ARRAY_DIV2 ) ? 1 :
                  ( dst_xpos > my_xpos )                           ? 0 :
                  ( dst_xpos < my_xpos && delta_x3 > `ARRAY_DIV2 ) ? 0 :
                  ( dst_xpos < my_xpos )                           ? 1 : 0;
END_OF_PORT_TORUS1D
} elsif ( $routing_type eq "src" ) {
print << "END_OF_PORT_SRC";
assign	port0	= addr[`PORTW:0];
END_OF_PORT_SRC
}

#*******************************************************************
# Output virtual channel
#*******************************************************************
if ( $routing_type eq "mesh2d") {
print << "END_OF_VC_MESH2D";
/* The same virtual channel is used. */
assign ovch0	= ivch;
END_OF_VC_MESH2D
} elsif ( $routing_type eq "mesh1d" ) {
print << "END_OF_VC_MESH1D";
/* The same virtual channel is used. */
assign ovch0	= ivch;
END_OF_VC_MESH1D
} elsif ( $routing_type eq "torus1d" ) {
print << "END_OF_VC_TORUS1D";
/* Deadlocks can be avoided if you enable the following assign statement. */
assign ovch0	= ( dst_xpos == my_xpos && dst_ypos == my_ypos ) ? 0 :
                  ( my_xpos == 0     && port == 1 )              ? 1 :
                  ( my_xpos == `NODE && port == 0 )              ? 1 : ivch;
END_OF_VC_TORUS1D
} elsif ( $routing_type eq "src" ) {
print << "END_OF_VC_SRC";
/* The same virtual channel is used. */
assign ovch0	= ivch;
END_OF_VC_SRC
}

printf("endmodule\n");
exit;
#*******************************************************************
