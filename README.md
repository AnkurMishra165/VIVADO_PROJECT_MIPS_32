MIPS32_PIPE: A Pipelined MIPS Processor
This project implements a basic 32-bit MIPS processor with a 5-stage pipeline. The processor supports various operations, including arithmetic, memory access, and control flow instructions. It also features a halt instruction to stop the processor execution.

1.Features
Pipelined Architecture: The processor uses a 5-stage pipeline:
IF (Instruction Fetch)
ID (Instruction Decode)
EX (Execute)
MEM (Memory Access)
WB (Write Back)
Supported Instructions:
Arithmetic: ADD, SUB, AND, OR, SLT, MUL
Memory: LW (Load Word), SW (Store Word)
Immediate: ADDI, SUBI, SLTI
Branching: BEQZ (Branch if Equal to Zero), BNEQZ (Branch if Not Equal to Zero)
Control: HLT (Halt)
Pipelined Control: The design uses two clocks (clk1, clk2) for different pipeline stages to simulate simultaneous execution of instructions across multiple stages.
Memory: The processor uses two types of memory:
Register File: A 32-entry register file (Reg[0:31])
Data Memory: A 1024-entry memory array (Mem[0:1023]) for storing data.
Architecture Overview
The processor is implemented in Verilog and uses a pipelined approach to execute instructions. Here's a breakdown of the main components:
Instruction Fetch (IF): The processor fetches an instruction from memory using the PC (Program Counter). The PC is incremented after each instruction fetch, unless a branch is taken.
Instruction Decode (ID): The instruction is decoded, and the operands are read from the register file. Immediate values are also sign-extended.
Execution (EX): The ALU performs the operation (arithmetic, logic, or address calculation) based on the instruction type. Branches are also evaluated at this stage.
Memory Access (MEM): For load and store operations, memory is accessed. If the instruction is a load, the data is fetched from memory, otherwise, the result is stored.

Write Back (WB): The result of the operation (ALU or memory load) is written back to the register file.

Clocking
The processor operates with two clocks:

clk1: Controls the stages for instruction fetch (IF), execution (EX), and write-back (WB).

clk2: Controls the instruction decode (ID) and memory access (MEM) stages.

Example Workflow:
The first clock cycle fetches an instruction.

The second clock cycle decodes the instruction and performs the necessary memory operations.

Results are written back after executing the necessary logic in subsequent cycles.

Parameters and Instructions
Instruction Op-Codes
ADD: 6'b000000

SUB: 6'b000001

AND: 6'b000010

OR: 6'b000011

SLT: 6'b000100

MUL: 6'b000101

HLT: 6'b111111

LW: 6'b001000

SW: 6'b001001

ADDI: 6'b001010

SUBI: 6'b001011

SLTI: 6'b001100

BNEQZ: 6'b001101

BEQZ: 6'b001110

Operation Types
RR_ALU: Register-Register ALU operations (ADD, SUB, AND, OR, SLT, MUL)

RM_ALU: Register-Immediate ALU operations (ADDI, SUBI, SLTI)

LOAD: Load data from memory (LW)

STORE: Store data to memory (SW)

BRANCH: Branch operations (BEQZ, BNEQZ)

HALT: Stop execution (HLT)

Simulation and Testing
To simulate the MIPS32 pipeline processor, you'll need a Verilog simulator such as ModelSim or Vivado. The processor's behavior can be tested by loading a test program into memory and running the simulation.
