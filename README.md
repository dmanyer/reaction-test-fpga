\# FPGA Human Reaction Time Tester



复旦大学课程作业

基于 PYNQ-Z2 开发板的人体反应时间测试系统，使用 Verilog RTL 实现有限状态机控制、随机等待、计时、结果计算与四位数码管显示。



\## Project Structure



\- `src/`: RTL source files

\- `sim/`: testbench files

\- `constrs/`: Vivado XDC constraint files

\- `docs/`: experiment report figures and board photos



\## Main Modules



\- `top.v`: 顶层模块

\- `fsm.v`: 状态机控制模块

\- `timer.v`: 计时模块

\- `result\_calc.v`: 结果计算模块

\- `display.v`: 数码管显示模块



\## Hardware Platform



\- Board: PYNQ-Z2

\- Tool: Vivado

\- Language: Verilog HDL

