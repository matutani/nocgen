#!/usr/bin/perl

#*******************************************************************
# $Id: mux_gen.pl 12 2009-11-09 08:33:20Z matutani $
#*******************************************************************

#*******************************************************************
# Number of ports
#*******************************************************************
$port_num	= $ARGV[0];

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
printf("module mux ( \n");

for ( $i = 0; $i < $port_num; $i++) {
	printf("        idata_%d,  \n", $i);
	printf("        ivalid_%d, \n", $i);
	printf("        ivch_%d,   \n", $i);
	printf("\n");
}
printf("        sel, \n");
printf("\n");
printf("        odata,  \n");
printf("        ovalid, \n");
printf("        ovch    \n");

printf(");\n");

printf("\n");

#*******************************************************************
# Port definitions
#*******************************************************************
for ( $i = 0; $i < $port_num; $i++) {
	printf("input    [`DATAW:0]    idata_%d;  \n", $i);
	printf("input                  ivalid_%d; \n", $i);
	printf("input    [`VCHW:0]     ivch_%d;   \n", $i);
}
printf("\n");
printf("input    [`PORT:0]     sel;  \n");
printf("\n");
printf("output   [`DATAW:0]    odata;  \n");
printf("output                 ovalid; \n");
printf("output   [`VCHW:0]     ovch;   \n");
printf("\n");

printf("assign odata = \n");
for ( $i = 0; $i < $port_num; $i++) {
	printf("                (sel == `PORT_P1'b");
	for ( $j = $port_num - 1; $j >= 0; $j--) {
		printf("%d", ($i == $j) ? 1 : 0);
	}
	printf(") ? idata_%d : \n", $i);
}
printf("                `DATAW_P1'b0;");
printf("\n");

printf("\n");

printf("assign ovalid = \n");
for ( $i = 0; $i < $port_num; $i++) {
	printf("                (sel == `PORT_P1'b");
	for ( $j = $port_num - 1; $j >= 0; $j--) {
		printf("%d", ($i == $j) ? 1 : 0);
	}
	printf(") ? ivalid_%d : \n", $i);
}
printf("                1'b0;");
printf("\n");

printf("assign ovch = \n");
for ( $i = 0; $i < $port_num; $i++) {
	printf("                (sel == `PORT_P1'b");
	for ( $j = $port_num - 1; $j >= 0; $j--) {
		printf("%d", ($i == $j) ? 1 : 0);
	}
	printf(") ? ivch_%d : \n", $i);
}
printf("                `VCHW_P1'b0;");
printf("\n");

printf("endmodule\n");

#*******************************************************************
