# nocgen

This package includes a Perl script that generates Verilog HDL codes of on-chip network consisting of virtual-channel routers.

RTL simulation, logic synthesis, place-and-route, post-layout simulation, and power-estimation can be performed for the generated Verilog HDL codes with standard EDA tools. These EDA scripts for Nangate Open Cell Library 45nm library are also included.

By modifying the Perl script, you can customize the network topology, routing algorithm, flit width, number of virtual channels, input buffer depth per VC, traffic pattern, packet length, etc.

## Generating Verilog HDL model

```sh
$ ./nocgen.pl
```

You can customize the network topology. Below are some examples.

2D Mesh topology (4x4 = 16 nodes):
> $array_size = 4;  
> $topology_type = mesh;  
> $routing_type = mesh2d;  

Linear topology (16 nodes):
> $array_size = 16;  
> $topology_type = linear;  
> $routing_type = mesh1d;  

You can customize various router parameters. Below are the default values.

> $data_width = 32;  
> $vch_num = 8;  
> $buf_size = 16;  
> $arbiter_type = fixed;  # fixed or roundrobin

You can customize the traffic pattern. Below are the default values.
> $traffic_ptn = random;  # random or uniform  
> $packet_len = 5;  
> $packet_num = 40;  

## RTL simulation (Icarus Verilog or Cadence NC-Verilog)

For Icarus Verilog:
```sh
$ make isim
```

For NC-Verilog:
```sh
$ make nsim
```

Below are performance results ($packet_num=32, $traffic_ptn=uniform, $packet_len=15, $buf_size=15).

> 2D Mesh (16 nodes, 1 VC)  920 cycles  
> 2D Mesh (16 nodes, 8 VCs) 693 cycles  
> Linear (16 nodes, 1 VC)   2402 cycles  
> Linear (16 nodes, 8 VCs)  1634 cycles  

2D Mesh is better than Linear. Performance improves when using more VCs.

## Design Synthesis (Synopsys Design Compiler)

```sh
$ make syn
```

## Place and Route (Cadence SoC Encounter)

```sh
$ make par
```

## Static Timing Analysis (Synopsys Design Compiler)

```sh
$ make sta
```

## Gate-level simulation with SDF file (Cadence NC-Verilog)

```sh
$ make dsim
```

## Power Estimation (Synopsys Design Compiler)

```sh
$ make power
```

Then you can estimate the energy-per-bit of a large router ($vch_num=8, $buf_size=16), as follows.

> Power with 0 stream:  45.7 mW  
> Power with 1 stream:  46.0 mW  
> Power with 2 streams: 46.4 mW  
> Power with 3 streams: 46.8 mW  
> Power with 4 streams: 47.2 mW  
> Power with 5 streams: 47.6 mW  
> --> Delta is approx 0.4 mW  

> 0.4 mJ is consumed in 1 sec  
> Frequency: 200 MHz  
> Link utilization: 4/13  
> Flit width: 32 bit  

> 0.4[mJ] / 200[MHz] * 13/4 / 32[bit]  
> = ((0.4 * 10^(-3) / (200 * 10^6)) * 13/4 / 32) * 10^12  
> = 0.203125 [pJ/bit]  

Also you can estimate the energy-per-bit of a large router ($vch_num=2, $buf_size=5), as follows.

> Power with 0 stream:  4.59 mW  
> Power with 1 stream:  4.75 mW  
> Power with 2 streams: 4.92 mW  
> Power with 3 streams: 5.08 mW  
> Power with 4 streams: 5.25 mW  
> Power with 5 streams: 5.43 mW  
> --> Delta is approx 0.17 mW  

> 0.17 mJ is consumed in 1 sec  
> Frequency: 200 MHz  
> Link utilization: 4/13  
> Flit width: 32 bit  

> 0.17[mJ] / 200[MHz] * 13/4 / 32[bit]  
> = (0.17 * 10^(-3) / (200 * 10^6)) * 13/4 / 32) * 10^12  
> = 0.08632812 [pJ/bit]  

## Remove unused files

```sh
$ make allclean
$ ./nocgen.pl clean
```
