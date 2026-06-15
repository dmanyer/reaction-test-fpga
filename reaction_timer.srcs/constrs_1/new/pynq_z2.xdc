# 时钟
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]

# 复位：SW0 拨码开关，拨上为高电平，取反作为低有效复位
set_property PACKAGE_PIN M20 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# 按键：BTN0 = START，BTN1 = 反应键
#PYNQ-Z2 按键按下为高电平，与设计一致
set_property PACKAGE_PIN D19 [get_ports btn_start]
set_property IOSTANDARD LVCMOS33 [get_ports btn_start]
set_property PACKAGE_PIN D20 [get_ports btn_react]
set_property IOSTANDARD LVCMOS33 [get_ports btn_react]

# LED 状态指示：板载 LED
set_property PACKAGE_PIN R14 [get_ports {led[0]}]
set_property PACKAGE_PIN P14 [get_ports {led[1]}]
set_property PACKAGE_PIN N16 [get_ports {led[2]}]
set_property PACKAGE_PIN M14 [get_ports {led[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

# 七段数码管段选：PMODA
set_property PACKAGE_PIN Y18 [get_ports {seg[0]}] ;# PMODA pin 1  -> 数码管 pin 11, A
set_property PACKAGE_PIN Y19 [get_ports {seg[1]}] ;# PMODA pin 2  -> 数码管 pin 7,  B
set_property PACKAGE_PIN Y16 [get_ports {seg[2]}] ;# PMODA pin 3  -> 数码管 pin 4,  C
set_property PACKAGE_PIN Y17 [get_ports {seg[3]}] ;# PMODA pin 4  -> 数码管 pin 2,  D
set_property PACKAGE_PIN U18 [get_ports {seg[4]}] ;# PMODA pin 7  -> 数码管 pin 1,  E
set_property PACKAGE_PIN U19 [get_ports {seg[5]}] ;# PMODA pin 8  -> 数码管 pin 10, F
set_property PACKAGE_PIN W18 [get_ports {seg[6]}] ;# PMODA pin 9  -> 数码管 pin 5,  G

set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]
set_property DRIVE 4 [get_ports {seg[*]}]
set_property SLEW SLOW [get_ports {seg[*]}]

# 小数点 DP：PMODA pin 10
set_property PACKAGE_PIN W19 [get_ports dp]       ;# PMODA pin 10 -> 数码管 pin 3, DP
set_property IOSTANDARD LVCMOS33 [get_ports dp]
set_property DRIVE 4 [get_ports dp]
set_property SLEW SLOW [get_ports dp]

# 七段数码管位选：PMODB
set_property PACKAGE_PIN W14 [get_ports {an[0]}] ;# PMODB pin 1 -> 数码管 pin 6,  DIG4 个位
set_property PACKAGE_PIN Y14 [get_ports {an[1]}] ;# PMODB pin 2 -> 数码管 pin 8,  DIG3 十位
set_property PACKAGE_PIN T11 [get_ports {an[2]}] ;# PMODB pin 3 -> 数码管 pin 9,  DIG2 百位
set_property PACKAGE_PIN T10 [get_ports {an[3]}] ;# PMODB pin 4 -> 数码管 pin 12, DIG1 千位

set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]
set_property DRIVE 4 [get_ports {an[*]}]
set_property SLEW SLOW [get_ports {an[*]}]