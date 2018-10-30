## Generated SDC file "OscilloscopeBoom.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

## DATE    "Wed Oct 24 02:16:18 2018"

##
## DEVICE  "EP4CE22F17C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {DAClk} -period 5.000 -waveform { 0.000 2.500 } [get_ports { DAClk }]
create_clock -name {LLC} -period 5.000 -waveform { 0.000 2.500 } [get_ports { LLC }]
create_clock -name {SClk} -period 20.000 -waveform { 0.000 10.000 } [get_ports { SClk }]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {DAClk}] -rise_to [get_clocks {DAClk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {DAClk}] -fall_to [get_clocks {DAClk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {DAClk}] -rise_to [get_clocks {DAClk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {DAClk}] -fall_to [get_clocks {DAClk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {LLC}] -rise_to [get_clocks {LLC}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {LLC}] -fall_to [get_clocks {LLC}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {LLC}] -rise_to [get_clocks {LLC}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {LLC}] -fall_to [get_clocks {LLC}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {DE}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {HSync}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[0]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[1]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[2]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[3]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[4]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[5]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[6]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[7]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[8]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[9]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[10]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[11]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[12]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[13]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[14]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {PixelData[15]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {LLC}]  0.000 [get_ports {VSync}]


#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_id9:dffpipe15|dffe16a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_gd9:dffpipe12|dffe13a*}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

