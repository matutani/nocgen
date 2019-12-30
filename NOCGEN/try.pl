#!/usr/bin/perl

$total_sent = 1792;
for($i = 0; $i < 100; $i++) {
	$result = `./nocgen.pl > /dev/null; make | grep total_sent | awk '{print \$4}'`;
	chomp($result);
	if ($result != $total_sent) {
		printf("VIOLATE (%d)\n", $result);
		last;
	} else {
		printf("MET (%d)\n", $result);
	}
}
