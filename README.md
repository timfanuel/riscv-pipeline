# RV32IM 5-Stage Pipelined Processor — RTL to GDS on SkyWater 130nm

> **Status:** in progress — environment and flow bring-up.

A 5-stage in-order RISC-V (RV32IM) core written in SystemVerilog, verified with cocotb against the Spike ISA simulator, and implemented through OpenLane 2 on the open-source Sky130 process.

## Results

| Metric | Value |
|---|---|
| ISA | RV32IM (planned) |
| riscv-tests passing | — |
| Target clock / achieved Fmax | — |
| Core area | — |
| CoreMark/MHz, CPI | — |

*(Block diagram and GDS render go here.)*

## Repo layout

```
rtl/core/        the processor (your RTL)
rtl/flow_test/   throwaway block used to bring up the tool flows
tb/              cocotb testbenches (one folder per DUT)
openlane/        OpenLane 2 configs (one folder per hardened design)
sw/              test programs, linker script, riscv-tests (break week 2)
docs/            diagrams, design notes, results
scripts/         setup and environment
```

## Quick start

```bash
bash scripts/setup.sh        # once
source scripts/env.sh        # every new terminal
make test-flow               # simulation (Icarus by default; SIM=verilator also works)
make harden-flow             # RTL-to-GDS; results in openlane/mul_shift_add/runs/<timestamp>/
```

View the layout: open `runs/<timestamp>/final/gds/*.gds` in [KLayout](https://www.klayout.de/).
Key reports live under `runs/<timestamp>/final/metrics.json` (area, timing slack, power).

## Roadmap

- [ ] **Setup:** tools installed, `make test-flow` and `make harden-flow` both succeed
- [ ] **Flow test:** replace `mul_shift_add` with my own block; record area/timing
- [ ] **Week 1:** 5-stage RV32I with forwarding, load-use stall, branch flush; pass riscv-tests (rv32ui)
- [ ] **Week 2:** M extension; cocotb random-instruction testbench vs. Spike; C programs via RISC-V GCC
- [ ] **Week 3:** OpenLane on the full core; close timing; report Fmax/area/power; GDS render
- [ ] **Stretch:** branch predictor (with CPI before/after), caches

## Design notes

Register file and memories are flip-flop based (no SRAM macros) to keep the physical flow simple.
