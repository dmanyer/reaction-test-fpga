# PYNQ-Z2 constraint file for seg_digit_test_top

# Clock: 125 MHz
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]

# Reset: SW0, active-low in HDL. Put SW0 HIGH to run.
set_property PACKAGE_PIN M20 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# Buttons
set_property PACKAGE_PIN D19 [get_ports btn_start] ;# BTN0
set_property PACKAGE_PIN D20 [get_ports btn_react] ;# BTN1, unused in this test
set_property IOSTANDARD LVCMOS33 [get_ports btn_start]
set_property IOSTANDARD LVCMOS33 [get_ports btn_react]

# On-board LEDs
set_property PACKAGE_PIN R14 [get_ports {led[0]}]
set_property PACKAGE_PIN P14 [get_ports {led[1]}]
set_property PACKAGE_PIN N16 [get_ports {led[2]}]
set_property PACKAGE_PIN M14 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# PMODA: 7-segment segment pins, common-anode, low-active segment
# seg[0]=A, seg[1]=B, seg[2]=C, seg[3]=D, seg[4]=E, seg[5]=F, seg[6]=G
set_property PACKAGE_PIN Y18 [get_ports {seg[0]}] ;# PMODA pin 1  -> display pin 11, A
set_property PACKAGE_PIN Y19 [get_ports {seg[1]}] ;# PMODA pin 2  -> display pin 7,  B
set_property PACKAGE_PIN Y16 [get_ports {seg[2]}] ;# PMODA pin 3  -> display pin 4,  C
set_property PACKAGE_PIN Y17 [get_ports {seg[3]}] ;# PMODA pin 4  -> display pin 2,  D
set_property PACKAGE_PIN U18 [get_ports {seg[4]}] ;# PMODA pin 7  -> display pin 1,  E
set_property PACKAGE_PIN U19 [get_ports {seg[5]}] ;# PMODA pin 8  -> display pin 10, F
set_property PACKAGE_PIN W18 [get_ports {seg[6]}] ;# PMODA pin 9  -> display pin 5,  G
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]
set_property DRIVE 4 [get_ports {seg[*]}]
set_property SLEW SLOW [get_ports {seg[*]}]

# DP: PMODA pin 10
set_property PACKAGE_PIN W19 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]
set_property DRIVE 4 [get_ports dp]
set_property SLEW SLOW [get_ports dp]

# PMODB: digit select pins, common-anode, high-active digit select
# an[0]=rightmost/unit DIG4, an[1]=tens DIG3, an[2]=hundreds DIG2, an[3]=leftmost/thousands DIG1
set_property PACKAGE_PIN W14 [get_ports {an[0]}] ;# PMODB pin 1 -> display pin 6,  DIG4
set_property PACKAGE_PIN Y14 [get_ports {an[1]}] ;# PMODB pin 2 -> display pin 8,  DIG3
set_property PACKAGE_PIN T11 [get_ports {an[2]}] ;# PMODB pin 3 -> display pin 9,  DIG2
set_property PACKAGE_PIN T10 [get_ports {an[3]}] ;# PMODB pin 4 -> display pin 12, DIG1
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]
set_property DRIVE 4 [get_ports {an[*]}]
set_property SLEW SLOW [get_ports {an[*]}]