#!/usr/bin/perl

#*******************************************************************
# $Id: vc_gen.pl 18 2010-02-21 16:37:19Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 1 ) {
	printf("usage: ./vc_gen.pl <port_num> \n");
	exit;
}

#*******************************************************************
# Number of ports
#*******************************************************************
$port_num	= $ARGV[0];

#*******************************************************************
# Routing type
#*******************************************************************
$routing_type	= $ARGV[1];

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
printf("module vc ( \n");

printf("        bdata,  \n");
printf("        send,   \n");
printf("        olck,   \n");
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
printf("        req,  \n");
printf("        port, \n");
printf("        ovch, \n");
printf("\n");
printf("        clk, \n");
printf("        rst_ \n");

printf(");\n");
printf("parameter       ROUTERID= 0;\n");
printf("parameter       PCHID   = 0;\n");
printf("parameter       VCHID   = 0;\n");
printf("\n");

#*******************************************************************
# Port definitions
#*******************************************************************
printf("input   [`DATAW:0]      bdata;  \n");
printf("output                  send;   \n");
printf("output                  olck;   \n");
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
printf("output                  req;  \n");
printf("input   [`PORTW:0]      port; \n");
printf("input   [`VCHW:0]       ovch; \n");
printf("\n");
printf("input   clk, rst_;            \n");
printf("\n");

#*******************************************************************
# Wire/Register definitions
#*******************************************************************
print << "END_OF_WIRE_REG";

reg     [1:0]           state;
wire    [`TYPEW:0]      btype;
reg                     req;     /* Request signal */
wire                    ilck;    /* 1: Next VC is locked by others */
wire                    grt;	 /* 1: Output channel is allocated */
wire                    irdy;	 /* 1: Next VC can receive a flit  */ 
reg                     send;

END_OF_WIRE_REG

#*******************************************************************
# State definitions
#*******************************************************************
print << "END_OF_STATE_DEF";

/*
 * State machine
 */
`define RC_STAGE      2'b00
`define VSA_STAGE     2'b01
`define ST_STAGE      2'b10

END_OF_STATE_DEF

#*******************************************************************
# Packet-level arbitration
#*******************************************************************
printf("/*  \n");
printf(" * Input flit type \n");
printf(" */ \n");
printf("assign  btype   = bdata[`TYPE_MSB:`TYPE_LSB]; \n");
printf("\n");
printf("/*  \n");
printf(" * Packet-level arbitration \n");
printf(" */ \n");

printf("assign  ilck    = ( \n");
for ( $i = 0; $i < $port_num - 1; $i++) {
	printf("                   (port == %d && ilck_%d[ovch]) || \n",$i,$i);
}
printf("                   (port == %d && ilck_%d[ovch]) ); \n", $i, $i);
printf("\n");

#*******************************************************************
# Flit-level arbitration
#*******************************************************************
printf("/*  \n");
printf(" * Flit-level transmission control \n");
printf(" */ \n");

printf("assign  grt     = ( \n");
for ( $i = 0; $i < $port_num - 1; $i++) {
	printf("                   (port == %d && grt_%d) || \n", $i, $i);
}
printf("                   (port == %d && grt_%d) ); \n", $i, $i);

printf("assign  irdy    = ( \n");
for ( $i = 0; $i < $port_num - 1; $i++) {
	printf("                   (port == %d && irdy_%d[ovch]) || \n",$i,$i);
}
printf("                   (port == %d && irdy_%d[ovch]) ); \n", $i, $i);
printf("\n");
printf("assign  olck    = (state != `RC_STAGE); \n");
printf("\n");

#*******************************************************************
# State transition control
#*******************************************************************
print << "END_OF_STATE_CNTL";

/*
 * State transition control
 */
always @ (posedge clk) begin
	if (rst_ == `Enable_) begin
		state	<= `RC_STAGE;
		send	<= `Disable;
		req	<= `Disable;
	end else begin
		case (state)

		/*
		 * State 1 : Routing computation
		 */
		`RC_STAGE: begin
			if (btype == `TYPE_HEAD ||
			    btype == `TYPE_HEADTAIL) begin
				state	<= `VSA_STAGE;
				send	<= `Disable;
				req	<= `Enable;
			end
		end

                /*
                 * State 2 : Virtual channel / switch allocation
                 */
                `VSA_STAGE: begin
			if (ilck == `Enable) begin
                        	/* Switch is locked (unable to start 
				   the arbitration) */
				req     <= `Disable;
			end if (grt == `Disable) begin
                        	/* Switch is not locked but it is not 
				   allocated */
				req     <= `Enable;
			end if (irdy == `Enable && grt == `Enable) begin
                        	/* Switch is allocated and it is free!  */
                                state   <= `ST_STAGE;
				send	<= `Enable;
				req     <= `Enable;
			end
                end

                /*
                 * State 3 : Switch Traversal 
                 */
		`ST_STAGE: begin
			if (btype == `TYPE_HEADTAIL || 
			    btype == `TYPE_TAIL) begin
				state	<= `RC_STAGE;
				send	<= `Disable;
				req	<= `Disable;
			end
		end
		endcase
	end
end

END_OF_STATE_CNTL

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
