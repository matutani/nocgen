# nocgen

This package includes a Perl script that generates Verilog HDL codes of on-chip network consisting of virtual-channel routers.

RTL simulation, logic synthesis, place-and-route, post-layout simulation, and power-estimation can be performed for the generated Verilog HDL codes with standard EDA tools. These EDA scripts for Nangate Open Cell Library 45nm library are also included.

By modifying the Perl script, you can customize the network topology, routing algorithm, flit width, number of virtual channels, input buffer depth per VC, traffic pattern, packet length, etc.

## Generating Verilog HDL model

```sh
> ./nocgen.pl
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
> $arbiter_type = fixed; (fixed or roundrobin)

You can customize the traffic pattern. Below are the default values.
> $traffic_ptn = random; [random or uniform]  
> $packet_len = 5;  
> $packet_num = 40;  
