#!/usr/bin/perl

#*******************************************************************
# $Id: outputc_gen.pl 18 2010-02-21 16:37:19Z matutani $
#*******************************************************************

#*******************************************************************
# Argument check
#*******************************************************************
if ( @ARGV != 1 ) {
	printf("usage: ./outputc_gen.pl <vch_num> \n");
	exit;
}

#*******************************************************************
# Number of virtual channels
#*******************************************************************
$vch_num        = $ARGV[0];

#*******************************************************************
# Parameter file
#*******************************************************************
$param_file	= "define.h";

#*******************************************************************
# Include parameter file
#*******************************************************************
printf("`include \"%s\" \n", $param_file);

print << "END_OF_OUTPUTC_PORTS";
module outputc (
        idata,
        ivalid,
        ivch,

        odata,
        ovalid,
        ovch,

        iack,
        ordy,

        ilck,
        olck,

        clk,
        rst_
);
parameter       ROUTERID= 0;
parameter       PCHID   = 0;

input   [`DATAW:0]      idata;
input                   ivalid;
input   [`VCHW:0]       ivch;

output  [`DATAW:0]      odata;
output                  ovalid;
output  [`VCHW:0]       ovch;

input   [`VCH:0]        iack;
output  [`VCH:0]        ordy;

input   [`VCH:0]        ilck;
output  [`VCH:0]        olck;

input   clk, rst_;

reg     [`DATAW:0]      odata;
reg                     ovalid;
reg     [`VCHW:0]       ovch;

wire    [`TYPEW:0]      itype;
wire    [`TYPEW:0]      otype;

reg     [`VCH:0]        olck;

END_OF_OUTPUTC_PORTS

for ($i = 0; $i < $vch_num; $i++) {
	printf("reg     [`FIFOD_P1:0]   cnt%d; \n", $i);
}
printf("\n");

print << "END_OF_OUTPUTC_ODATA";
/*
 * Input/Output flit type
 */
assign  itype   = (ivalid == `Enable) ? idata[`TYPE_MSB:`TYPE_LSB] :
                                        `TYPE_NONE;
assign  otype   = (ovalid == `Enable) ? odata[`TYPE_MSB:`TYPE_LSB] :
                                        `TYPE_NONE;

/*
 * Output data
 */
always @ (posedge clk) begin
        if (rst_ == `Enable_) begin
                odata   <= `DATAW_P1'b0;
                ovalid  <= `Disable;
                ovch    <= `VCHW_P1'b0;
        end else if (ivalid) begin
                odata   <= idata;
                ovalid  <= ivalid;
                ovch    <= ivch;
        end else if (~ivalid & ovalid) begin
                odata   <= `DATAW_P1'b0;
                ovalid  <= `Disable;
                ovch    <= `VCHW_P1'b0;
        end
end

END_OF_OUTPUTC_ODATA

printf("/*  \n");
printf(" * Virtual-channel status (lock) \n");
printf(" */ \n");
for ($i = 0; $i < $vch_num; $i++) {
	printf("always @ (posedge clk) begin                      \n");
	printf("        if (rst_ == `Enable_)                     \n");
	printf("                olck[%d] <= `Disable;             \n", $i);
	printf("        else if ( (ivalid && ivch == %d) || (ovalid && ovch == %d) )\n", $i, $i);
	printf("                olck[%d] <= `Enable;              \n", $i);
	printf("        else if (olck[%d] && ~ilck[%d])           \n", $i, $i);
	printf("                olck[%d] <= `Disable;             \n", $i);
	printf("end                                               \n");
}
printf("\n");

printf("/*  \n");
printf(" * Virtual-channel status (ready) \n");
printf(" */ \n");
for ($i = 0; $i < $vch_num; $i++) {
#	printf("assign  ordy[%d] = cnt%d < `FIFO;\n", $i, $i);
	printf("assign  ordy[%d] = ((`FIFO_P1 - cnt%d) >= `PKTLEN_P1) ? `Enable : `Disable;\n", $i, $i);
}
for ($i = 0; $i < $vch_num; $i++) {
	printf("always @ (posedge clk) begin                      \n");
	printf("        if (rst_ == `Enable_)                     \n");
	printf("                cnt%d  <= 0;                      \n", $i);
	printf("        else if (iack[%d] && ~(ivalid && ivch == %d) && cnt%d != 0) \n", $i, $i, $i);
	printf("                cnt%d  <= cnt%d - 1;              \n", $i, $i);
	printf("        else if (~iack[%d] && (ivalid && ivch == %d)) \n", $i, $i);
	printf("                cnt%d  <= cnt%d + 1;              \n", $i, $i);
	printf("end                                               \n");
}
printf("\n");

printf("endmodule \n");

#*******************************************************************
