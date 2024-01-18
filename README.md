# Simple Processor

## Table of Content
1. [Design Description](#Design-Description)
2. [Design Inputs and Outputs](#Design-Inputs-and-Outputs)
3. [Project Execution Steps](#Project-Execution-Steps)

## Design Description
A processor executes operations specified in the form of instructions. In this project, a string of instructions will be given. Your job is to decode these instructions and execute.


![Instruction Format](https://github.com/Lewis-panda/Simple-CPU-Simulaor/assets/116704255/52f0ca80-b0c3-45c2-ad98-1a9bfa9567c6)
![image](https://github.com/Lewis-panda/Simple-CPU-Simulaor/assets/116704255/c0a0f9fe-e1f6-49bd-b352-a27f4575cfdc)
![image](https://github.com/Lewis-panda/Simple-CPU-Simulaor/assets/116704255/0bb25966-dbcc-4f2e-af5a-76df5e2eca92)

## Design Inputs and Outputs
### Input
![image](https://github.com/Lewis-panda/Simple-CPU-Simulaor/assets/116704255/7f866af2-ecea-42b7-acd1-c790c3facdae)
### Output
![image](https://github.com/Lewis-panda/Simple-CPU-Simulaor/assets/116704255/102de729-6cbf-4345-8dde-5db0073cd126)


## Project Execution Steps
1. Install iverilog
   - [iverilog](https://bleyer.org/icarus/)
2. Download
  ``` shellscript=
  git clone https://github.com/Lewis-panda/Simple-CPU-Simulaor.git
  ```
3. Run
  ``` shellscript=
  cd Simple-CPU-Simulaor
  ```
  ``` shellscript=
  iverilog -o test TESTBED.v
  ```
  ``` shellscript=
  vvp test
  ```
  ``` shellscript=
  gtkwave SP.vcd &
  ```



