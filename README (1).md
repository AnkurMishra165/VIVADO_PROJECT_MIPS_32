# MIPS32_PIPE — 5‑Stage Pipelined MIPS‑like CPU (Verilog)

A compact educational 32‑bit, 5‑stage pipelined CPU core written in Verilog.  
It implements a MIPS‑style subset with integer ALU ops, immediate ops, load/store, and simple conditional branches. The design uses **two non‑overlapping clocks** to split pipeline work across edges: IF/EX/WB on `clk1`, and ID/MEM on `clk2`.

> **File:** `MIPS32_PIPE.v`  
> **Top module:** `MIPS32_PIPE`  
> **Stages:** IF → ID → EX → MEM → WB

---

## ✨ Key Features

- **5‑stage pipeline** with explicit IF/ID/EX/MEM/WB registers
- **Two‑phase clocking:**  
  - `clk1`: IF, EX, and WB  
  - `clk2`: ID and MEM
- **Word‑addressed memory** (`Mem[0:1023]`, 1K words, 32‑bit each)  
  Annotated for FPGA block RAM: `(* ram_style="block" *)`
- **Register file:** `Reg[0:31]`, 32 × 32‑bit (reads of `Reg[0]` are hardwired to 0)
- **Simple branch handling** with `BEQZ`/`BNEQZ` (PC‑relative)
- **Minimal control logic** suitable for learning and labs
- **Single‑cycle memory model** within the pipeline (for simulation/teaching)

---

## 🧠 Supported ISA (subset)

Opcodes are 6 MSBs `[31:26]`.

| Class   | Mnemonic | Opcode (bin) | Description |
|--------:|----------|--------------|-------------|
| RR_ALU  | `ADD`    | `000000`     | `rd ← rs + rt` |
| RR_ALU  | `SUB`    | `000001`     | `rd ← rs − rt` |
| RR_ALU  | `AND`    | `000010`     | `rd ← rs & rt` |
| RR_ALU  | `OR`     | `000011`     | `rd ← rs \| rt` |
| RR_ALU  | `SLT`    | `000100`     | `rd ← (rs < rt)` |
| RR_ALU  | `MUL`    | `000101`     | `rd ← rs × rt` |
| RM_ALU  | `ADDI`   | `001010`     | `rt ← rs + imm` |
| RM_ALU  | `SUBI`   | `001011`     | `rt ← rs − imm` |
| RM_ALU  | `SLTI`   | `001100`     | `rt ← (rs < imm)` |
| LOAD    | `LW`     | `001000`     | `rt ← Mem[rs + imm]` |
| STORE   | `SW`     | `001001`     | `Mem[rs + imm] ← rt` |
| BRANCH  | `BNEQZ`  | `001101`     | if `rs ≠ 0` branch |
| BRANCH  | `BEQZ`   | `001110`     | if `rs = 0` branch |
| HALT    | `HLT`    | `111111`     | Stop pipeline |

> **Notes**
> - Immediate is **sign‑extended**.
> - Memory and PC are **word‑indexed** (PC increments by 1 *word*).

---

## 🧩 Instruction Encoding (fields)

- `[31:26]` opcode  
- `[25:21]` `rs`  
- `[20:16]` `rt`  
- `[15:11]` `rd` (RR_ALU writes here)  
- `[15:0]`  `imm` (sign‑extended; used by RM_ALU/LW/SW/BRANCH)

**Branches:** target = `NPC + signext(imm)` (word‑relative).  
**LW/SW:** effective address = `rs + signext(imm)` (word address in this model).

---

## 🔌 Top‑Level I/O

```verilog
module MIPS32_PIPE(
  input  clk1,        // IF, EX, WB
  input  clk2,        // ID, MEM
  input  reset,       // global reset handled in IF block
  output reg [31:0] PC
);
```

- `PC` exposes the current fetch PC (word index).

---

## 🏗️ Microarchitecture Notes

- **Pipeline regs:** `IF_ID_*`, `ID_EX_*`, `EX_MEM_*`, `MEM_WB_*`
- **Control types:** `RR_ALU`, `RM_ALU`, `LOAD`, `STORE`, `BRANCH`, `HALT`
- **Branching:**  
  - Branch condition computed in EX (`EX_MEM_cond`)  
  - On `TAKEN_BRANCH`, IF fetches from the branch target and updates `PC`/`IF_ID_NPC`
- **Reg[0] semantics:** Reads of register 0 return 0; writes are not blocked but reads are forced to 0 in ID (as per code).

---

## ⚠️ Limitations (by design, for learning)

- No hazard detection/forwarding; **insert NOPs** between dependent instructions.
- Single unified memory model (no true Harvard timing); assumes single‑cycle RAM.
- No exceptions/interrupts/calls/returns/jumps.
- Branches only `BEQZ`/`BNEQZ` (no delay slot).

---

## ▶️ Getting Started (Simulation)

### 1) Add the core to your sim project
Works with **Icarus Verilog**, **Verilator**, **Questa/ModelSim**, etc.

### 2) Provide a testbench
Minimal skeleton:

```verilog
`timescale 1ns/1ps
module tb;

  reg clk1 = 0, clk2 = 0, reset = 1;
  wire [31:0] PC;

  // Two-phase, non-overlapping clocks (clk2 shifted by half-period)
  initial begin
    clk1 = 0;
    forever #5 clk1 = ~clk1;      // 100 MHz equiv
  end

  initial begin
    clk2 = 0;
    #2.5;                         // phase shift for non-overlap
    forever #5 clk2 = ~clk2;
  end

  MIPS32_PIPE dut (
    .clk1(clk1),
    .clk2(clk2),
    .reset(reset),
    .PC(PC)
  );

  initial begin
    // Deassert reset after some cycles
    repeat (4) @(posedge clk1);
    reset = 0;
  end

  // OPTIONAL: preload program/data memory (hierarchical backdoor)
  // Example: place words directly (word addressing)
  initial begin
    #1;
    // dut.Mem[0] = 32'hXXXXXXXX; // Encoded instruction
    // ...
    // End with an HLT (opcode 111111 in [31:26])
  end

  // Wave dump
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb);
  end

  initial begin
    #5000 $finish;
  end

endmodule
```

> **Preloading Memory**  
> Since `Mem` is inside the core, you can either:
> - Use **hierarchical backdoor writes** from the testbench (`dut.Mem[idx] = 32'h...;`), or
> - Add an `initial $readmemh("mem_init.hex", Mem);` block **inside** `MIPS32_PIPE.v` (if you prefer file‑based init).

### 3) Run
- Icarus:  
  `iverilog -g2012 -o cpu.vvp tb/tb_MIPS32_PIPE.v src/MIPS32_PIPE.v && vvp cpu.vvp`
- Verilator: create C++ sim scaffold or use `--trace` to view waves

---

## 🧪 Writing a Tiny Program

Because this is a custom MIPS‑like encoding, you’ll typically:
1. Hand‑encode instructions into 32‑bit words, or
2. Write a small assembler script, or
3. Build constants in the testbench and assign to `dut.Mem[...]`.

**Tips**
- Terminate your program with `HLT` (`opcode = 6'b111111`).
- Insert **NOPs** (e.g., `ADDI r0, r0, 0`) between producer/consumer pairs to avoid RAW hazards.
- Remember: **addresses are word indices** in this model.

---

## 🔍 Internal Signals You Might Probe

- `IF_ID_IR, ID_EX_IR, EX_MEM_IR, MEM_WB_IR` — instruction at each stage  
- `TAKEN_BRANCH` — asserted when a branch is taken  
- `EX_MEM_ALUout` — ALU result / effective address / branch target  
- `MEM_WB_LMD` — load data reaching WB

---

## 🛠️ Synthesis Notes

- `(* ram_style="block" *)` encourages BRAM inference on FPGAs (Xilinx/Intel).  
  For ASIC/other flows, you may remove or replace attributes as needed.

---

## 📚 Directory Suggestion (optional)

```
├─ src/
│  └─ MIPS32_PIPE.v
├─ tb/
│  └─ tb_MIPS32_PIPE.v
├─ programs/
│  ├─ mem_init.hex
│  └─ examples.md
├─ waves/
│  └─ (generated *.vcd)
└─ README.md
```

---

## ✅ To‑Do / Ideas

- Add a simple assembler (Python) for this encoding
- Insert a hazard detection unit and forwarding paths
- Add jumps/calls/returns
- Support byte/halfword addressing and alignment checks
- Separate instruction & data memories for Harvard timing

---

## 🙌 Acknowledgements

This project is designed for learning pipeline concepts and quick experimentation with Verilog CPU design.
