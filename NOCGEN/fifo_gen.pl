#!/usr/bin/perl

#*******************************************************************
# $Id: fifo_gen.pl 18 2010-02-21 16:37:19Z matutani $
#*******************************************************************

#*******************************************************************
# Parameter file
#*******************************************************************
$param_file	= "define.h";

#*******************************************************************
# Include parameter file
#*******************************************************************
printf("`include \"%s\" \n", $param_file);

print << "END_OF_FIFO";
module fifo (
	idata,
	odata,

	wr_en,
	rd_en,

	empty,
	full,

	ordy,

	clk,
	rst_
);

input	[`DATAW:0]	idata;
output	[`DATAW:0]	odata;

input			wr_en;
input			rd_en; 

output			empty;
output			full;

output			ordy;

input	clk, rst_;

reg	[`DATAW:0]	ram	[0:`FIFO];

reg	[`FIFOD:0]	rd_addr, wr_addr;
reg	[`FIFOD_P1:0]	d_cnt;
wire			set;
integer	i;

/* Write address */
always @ (posedge clk) begin
	if (rst_ == `Enable_) 
		wr_addr	<= 0;
	else if (set) 
		if (wr_addr == `FIFO)
			wr_addr	<= 0;
		else
			wr_addr	<= wr_addr + 1;
end

/* Read address */
always @ (posedge clk) begin
	if (rst_ == `Enable_) 
		rd_addr	<= 0;
	else if (~empty & rd_en) 
		if (rd_addr == `FIFO)
			rd_addr	<= 0;
		else
			rd_addr	<= rd_addr + 1;
end

/* Data counter */
always @ (posedge clk) begin
	if (rst_ == `Enable_) 
		d_cnt	<= 0;
	else if (~full  & wr_en & ~(rd_en & ~empty)) 
		d_cnt	<= d_cnt + 1;
	else if (~empty & rd_en & ~wr_en) 
		d_cnt	<= d_cnt - 1;
end

/* Full, Empty, Set */
assign	full	= (d_cnt == `FIFO_P1);
assign	empty	= (d_cnt == 0);
assign	set	= (~full | rd_en) & wr_en;

/* Empty space for a single packet */
assign	ordy	= ((`FIFO_P1 - d_cnt) >= `PKTLEN_P1) ? `Enable : `Disable;

/* Memory I/O */
assign	odata	= ~empty ? ram[rd_addr] : 0;
always @ (posedge clk) begin
	if (rst_ == `Enable_) 
		for (i = 0; i < `FIFO_P1; i = i + 1)
			ram[i]	<= 0;
	else if (set) 
		ram[wr_addr]	<= idata;
end

endmodule

END_OF_FIFO

#*******************************************************************
