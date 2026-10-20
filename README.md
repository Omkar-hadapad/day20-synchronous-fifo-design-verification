# Synchronous FIFO Design and Verification — Verilog RTL & Cadence Genus

<p align="center">
  <b>Digital VLSI • Verilog RTL • FIFO Architecture • Functional Verification • ASIC Synthesis</b>
</p>

<p align="center">
  <code>Specification → RTL → Testbench → Simulation → Synthesis → Technology Mapping → Area → Power → Timing → PPA Review</code>
</p>

<p align="center">
  <img alt="Project" src="https://img.shields.io/badge/Project-Synchronous%20FIFO-blue">
  <img alt="HDL" src="https://img.shields.io/badge/HDL-Verilog-8A2BE2">
  <img alt="Synthesis" src="https://img.shields.io/badge/Synthesis-Cadence%20Genus-orange">
  <img alt="Verification" src="https://img.shields.io/badge/Verification-148%20Pass%20%7C%200%20Fail-success">
</p>

---

## 1. Project Information

| Parameter | Details |
|---|---|
| **Project** | Synchronous FIFO Design and Verification |
| **Author** | Omkar Kalmesh Hadapad |
| **Domain** | Digital VLSI / RTL Design / Functional Verification |
| **Design Type** | Synchronous First-In, First-Out (FIFO) |
| **HDL** | Verilog HDL |
| **FIFO Configuration** | 8 words × 8 bits |
| **Simulation Tool** | Cadence NCSim |
| **Synthesis Tool** | Cadence Genus 21.14-s082_1 |
| **Technology Library** | `tsmc18` |
| **Top Module** | `synchronous_fifo_top` |
| **Verification Result** | 148 reported passes, 0 reported failures |
| **Synthesis Cell Count** | 338 standard-cell instances |
| **Reported Cell Area** | 7773.797 area units |
| **Reported Power** | 0.794121 mW |
| **Displayed Timing Slack** | +6.154 ns |
| **Physical Design Status** | Post-route PPA closure not established by the available reports |

> **Measurement note:** The synthesis report does not explicitly establish the physical unit of the reported area. Therefore, `7773.797` is presented as reported area units, not assumed to be µm². The power and timing values are synthesis-report results and should not be presented as final post-layout measurements.

---

## 2. Project Overview

A synchronous FIFO is a storage structure that preserves the order of data written into it. Data is written at the write pointer and read from the read pointer, with operations controlled by a clock and status signals.

This project implements and verifies an 8-word × 8-bit FIFO. The reported hierarchy includes memory, read and write pointers, count control, and status logic.

The project covers:

- FIFO architecture and data flow.
- Read/write pointer operation and rollover.
- Memory storage and readback.
- Occupancy tracking.
- Full and empty status.
- Overflow and underflow protection.
- Functional simulation using NCSim.
- Standard-cell synthesis using Cadence Genus.
- Area, power, and timing report interpretation.

### FIFO concept

```text
             Write Interface
          write_en, write_data
                   |
                   v
          +-------------------+
          |                   |
          |   FIFO MEMORY     |
          |     8 × 8         |
          |                   |
          +-------------------+
                   |
                   v
              Read Interface
             read_en, read_data

        Write Pointer  → Write address
        Read Pointer   → Read address
        Count Control  → Occupancy
        Status Logic   → Full / Empty
```

A FIFO is commonly used when data must be transferred in order between two parts of a digital system.

---

## 3. Objectives

1. Understand synchronous FIFO architecture.
2. Implement memory and pointer control.
3. Verify pointer increment and rollover.
4. Verify memory write and read operations.
5. Track FIFO occupancy.
6. Check full and empty conditions.
7. Verify overflow and underflow protection.
8. Check FIFO data ordering.
9. Compare structural and RTL behavior for tested scenarios.
10. Synthesize the design using Cadence Genus.
11. Analyze mapped standard cells and area distribution.
12. Interpret synthesis power and timing reports.
13. Identify the limitations of simulation and synthesis-stage evidence.

---

## 4. FIFO Architecture

The reported hierarchy contains the following main blocks:

```text
synchronous_fifo_top
└── FIFO
    ├── COUNT_CONTROL
    ├── MEMORY
    ├── READ_POINTER
    │   └── POINTER_INCREMENTER
    ├── STATUS
    └── WRITE_POINTER
        └── POINTER_INCREMENTER
```

### Block responsibilities

| Block | Function |
|---|---|
| `COUNT_CONTROL` | Maintains FIFO occupancy |
| `MEMORY` | Stores FIFO data |
| `READ_POINTER` | Tracks the read position |
| `WRITE_POINTER` | Tracks the write position |
| `POINTER_INCREMENTER` | Generates incremented pointer values |
| `STATUS` | Implements FIFO status logic |
| `FIFO` | Integrates the FIFO submodules |
| `synchronous_fifo_top` | Top-level design |

The hierarchy identifies these modules, but their exact behavior must be confirmed from the RTL and connectivity.

---

## 5. FIFO Operation

### Write operation

When a valid write is accepted, the FIFO stores the input data at the write address and advances the write pointer.

```text
Write Request
     |
     v
Check FIFO Full
     |
     v
Write Data to Memory
     |
     v
Increment Write Pointer
     |
     v
Update Occupancy
```

A write attempted while the FIFO is full must be handled according to the design specification.

### Read operation

When a valid read is accepted, the FIFO returns the data at the read position and advances the read pointer.

```text
Read Request
     |
     v
Check FIFO Empty
     |
     v
Read Stored Data
     |
     v
Increment Read Pointer
     |
     v
Update Occupancy
```

A read attempted while the FIFO is empty must not be treated as a valid data removal.

### Pointer rollover

The simulation log reports pointer rollover from `7` to `0` for the FIFO pointer checks.

For a three-bit pointer, the rollover sequence is:

```text
000 → 001 → 010 → 011
  ↑                 ↓
111 ← 110 ← 101 ← 100
```

The exact pointer width and any additional wrap-bit implementation should be confirmed against the RTL declarations.

---

## 6. Verification Strategy

The supplied NCSim transcript reports the following result:

| Verification metric | Reported result |
|---|---:|
| Pass checks | **148** |
| Fail checks | **0** |
| Final test result | **ALL TESTS PASSED** |
| Simulation termination | `$finish` at approximately 786 ns |

These results establish that the checks executed by the supplied testbench passed. They do not establish exhaustive verification or formal equivalence.

### Tests covered in the transcript

- Basic combinational logic blocks.
- Half-adder and full-adder checks.
- Four-bit incrementer operation and rollover.
- Pointer reset, increment, and rollover.
- Memory write and readback.
- FIFO occupancy counting.
- Full and empty status checks.
- FIFO reset.
- Filling the FIFO to capacity.
- Overflow protection.
- FIFO data-order preservation.
- Underflow protection.
- Selected simultaneous read/write scenarios.
- Structural-versus-RTL comparisons.

### Important verification observations

**Data ordering:** The transcript reports successful preservation of the sequence `10` through `17`.

**Capacity:** The occupancy test reaches 8 entries and reports the full condition.

**Overflow protection:** An additional write attempt while full is tested, and the overflow-related check passes.

**Underflow protection:** A read attempt while empty is tested, and the corresponding check passes.

**Implementation comparison:** Structural and RTL results agree for the scenarios exercised in the transcript.

> The log does not establish exhaustive simultaneous read/write coverage at full and empty boundaries. Additional directed tests should cover these cases, along with reset during activity and repeated boundary transitions.

---

## 7. Genus Synthesis Results

The supplied Cadence Genus report gives the following summary.

| Metric | Reported value |
|---|---:|
| Top module | `synchronous_fifo_top` |
| Mapped standard-cell instances | **338** |
| Total reported cell area | **7773.797 area units** |
| Total reported power | **0.794121 mW** |
| Displayed setup slack | **+6.154 ns** |
| Synthesis library | `tsmc18` |
| Synthesis tool | Cadence Genus 21.14-s082_1 |

These are synthesis-stage results. The available evidence does not establish routed interconnect timing or extracted-parasitic post-layout PPA.

---

## 8. Standard-Cell Mapping Analysis

The mapped-cell summary reports:

| Standard cell | Instances | Reported area |
|---|---:|---:|
| `DFFHQX1` | 76 | 4044.902 |
| `DFFTRX1` | 6 | 339.293 |
| `AOI22X1` | 92 | 1530.144 |
| `INVXL` | 68 | 452.390 |
| `AOI222X1` | 8 | 212.890 |
| `NAND2BX1` | 8 | 106.445 |
| `NOR2X1` | 14 | 139.709 |
| `NOR2XL` | 9 | 89.813 |
| Other mapped cells | 57 | 858.211 |
| **Total** | **338** | **7773.797** |

### Sequential versus combinational area

| Category | Instances | Reported area | Share of total |
|---|---:|---:|---:|
| Sequential cells | 82 | 4384.195 | 56.4% |
| Inverters | 74 | 492.307 | 6.3% |
| Other logic | 182 | 2897.294 | 37.3% |
| Physical cells | 0 | 0 | 0% |
| **Total** | **338** | **7773.797** | **100%** |

### Interpretation

- Sequential cells represent approximately 56.4% of the reported area.
- `DFFHQX1` contributes approximately 52.04% of the total reported area.
- `AOI22X1` is a prominent combinational cell, with 92 instances.
- The standard-cell report reconciles to 338 instances and 7773.797 area units.

The cell summary is a synthesis report, not a floorplan or core-area measurement. The presence of standard-cell storage elements also does not establish that the FIFO memory was implemented as a dedicated SRAM macro.

---

## 9. Hierarchy Area Analysis

The hierarchy report gives:

| Hierarchy block | Cell count | Reported area |
|---|---:|---:|
| `synchronous_fifo_top` | 338 | 7773.797 |
| `FIFO` | 338 | 7773.797 |
| `COUNT_CONTROL` | 20 | 479.002 |
| `MEMORY` | 286 | 6582.946 |
| `READ_POINTER` | 13 | 319.334 |
| `STATUS` | 4 | 46.570 |
| `WRITE_POINTER` | 13 | 319.334 |

### Main observation

The reported memory hierarchy accounts for approximately **84.7%** of the total area:

```text
Memory area = 6582.946
Total area  = 7773.797

Memory share ≈ 84.7%
```

This makes the memory implementation the primary area-optimization target in the reported hierarchy.

### Hierarchy report limitation

The displayed child counts and areas do not sum exactly to the parent total. The listed child counts sum to 336, while the top-level summary reports 338 instances. The listed child areas also differ from the parent total.

This discrepancy should be investigated using the complete hierarchical area report, flattened cell summary, and mapped netlist. The total should not be manually adjusted.

---

## 10. Power Analysis

The Genus power report gives the following summary.

| Category | Total power | Share |
|---|---:|---:|
| Register | 0.574835 mW | 72.39% |
| Logic | 0.156720 mW | 19.74% |
| Clock | 0.0625657 mW | 7.88% |
| Memory category | 0 mW | 0% |
| **Total** | **0.794121 mW** | **100% approximately** |

### Internal, switching, and leakage power

| Power component | Reported value | Share |
|---|---:|---:|
| Internal | 0.631439 mW | 79.51% |
| Switching | 0.162449 mW | 20.46% |
| Leakage | 0.000233602 mW | 0.03% |
| **Total** | **0.794121 mW** | **100%** |

### Interpretation

- Internal power is the largest reported component.
- Register power is the largest reported category.
- Switching power depends on signal activity and the analysis conditions.
- A zero value in the separate memory category does not prove that the storage logic consumes no power; memory-related implementation may be classified under another category.

The report uses the activity frame `/stim#0/frame#0`. Verify the clock definition, input stimulus, activity annotation, operating conditions, and parasitic assumptions before comparing this estimate with another implementation.

---

## 11. Timing Analysis

The supplied setup timing report contains:

| Timing item | Reported value |
|---|---:|
| Path status | **MET** |
| Setup slack | **+6154 ps = +6.154 ns** |
| Launch clock edge | 0 ps |
| Capture clock edge | 10,000 ps |
| Input delay | 1,000 ps |
| Setup time | 161 ps |
| Clock uncertainty | 1,000 ps |
| Required time | 8839 ps |
| Data path delay | 1685 ps |
| Data arrival time | 2685 ps |

### Reported path

```text
rd_en
  |
  v
NOR2BX1
  |
  v
NAND3X1
  |
  v
NOR2BX1
  |
  v
AOI22X1
  |
  v
NAND4X1
  |
  v
rd_data_reg[6]/D
```

The report identifies an input-to-register setup path ending at the D pin of `rd_data_reg[6]`.

### Slack calculation

The report gives:

```text
Required time = 8839 ps
Arrival time  = 2685 ps
```

Therefore:

```text
Slack = Required time − Arrival time

Slack = 8839 − 2685

Slack = 6154 ps = 6.154 ns
```

The displayed path meets its reported setup requirement.

### Timing interpretation and limitations

- Positive slack means this displayed path meets its setup requirement under the shown constraints.
- The reported 10 ns capture edge corresponds to a 100 MHz period if the SDC defines a 10 ns clock period.
- The two NOR2BX1 stages have reported delays of 544 ps and 513 ps. Their fanout and load are useful investigation points for optimization.
- One MET path does not prove that every setup and hold path meets timing.
- Review the complete timing summary, worst negative slack (WNS), total negative slack (TNS), hold paths, and SDC constraints.
- Post-route timing closure is not established by this report alone.

---

## 12. Overall PPA Summary

| Metric | Result | Qualification |
|---|---:|---|
| Functional simulation | 148 pass / 0 fail | Supplied NCSim transcript |
| Mapped cell count | 338 | Genus cell summary |
| Total reported area | 7773.797 area units | Physical area unit not confirmed |
| Total reported power | 0.794121 mW | Synthesis-stage estimate |
| Displayed timing slack | +6.154 ns | One setup path |
| Path status | MET | Applies to the displayed path |
| Post-route PPA | Not established | Routed and extracted reports not supplied |

---

## 13. Recommended Repository Structure

```text
synchronous-fifo-design-verification/
├── README.md
├── rtl/
│   ├── synchronous_fifo_top.v
│   ├── synchronous_fifo_structural.v
│   ├── fifo_memory_8x8.v
│   ├── fifo_count_control.v
│   ├── fifo_status_logic.v
│   ├── pointer_3bit.v
│   └── incrementer_4bit.v
├── tb/
│   └── synchronous_fifo_tb.v
├── sim/
│   ├── simulation.log
│   └── waveform/
├── genus/
│   ├── constraints_top.sdc
│   ├── reports/
│   │   ├── hierarchy.rpt
│   │   ├── area.rpt
│   │   ├── power.rpt
│   │   └── timing.rpt
│   ├── mapped_netlist.v
│   └── synthesis.log
├── images/
│   ├── fifo_architecture.png
│   ├── verification_summary.png
│   ├── area_distribution.png
│   ├── power_distribution.png
│   └── timing_path.png
└── docs/
    └── synthesis_analysis.md
```

> This is a suggested structure. Keep only files that actually exist in your repository, and adjust filenames to match the RTL and report files you have.

---

## 14. Industry Relevance

Synchronous FIFOs are used in digital systems to buffer data and manage transfers between modules operating within a clock domain.

This project demonstrates practical skills in:

- Synthesizable Verilog RTL.
- Memory and pointer control.
- Sequential and combinational logic.
- Self-checking testbench development.
- Boundary-condition verification.
- RTL-versus-structural comparison.
- Cadence Genus synthesis and technology mapping.
- Standard-cell area, power, and timing analysis.
- Technical documentation and verification reporting.

These concepts are relevant to RTL Design, ASIC Design, Design Verification, FPGA Design, and entry-level Digital VLSI engineering roles.

---

## 15. Interview Questions

1. What is a synchronous FIFO?
2. What is the difference between FIFO and LIFO?
3. How do read and write pointers work?
4. How is FIFO occupancy calculated?
5. How are full and empty conditions detected?
6. What happens when a write is attempted while full?
7. What happens when a read is attempted while empty?
8. How should simultaneous read and write operations be handled?
9. Why is pointer rollover important?
10. How would you verify FIFO data ordering?
11. What is the difference between RTL and structural implementation?
12. What does technology mapping do?
13. Why might sequential cells contribute significantly to area?
14. What are internal, switching, and leakage power?
15. What does positive timing slack mean?
16. Why is one MET timing path insufficient to prove timing closure?
17. What is the difference between synthesis-stage and post-route PPA?
18. How would you optimize a FIFO whose memory implementation dominates area?

---

## 16. Project Status

| Stage | Status |
|---|---|
| FIFO simulation transcript reviewed | Complete for supplied log |
| Functional checks | 148 pass / 0 fail reported |
| FIFO data ordering and boundary checks | Covered in supplied testbench scenarios |
| Hierarchy report reviewed | Complete for supplied report |
| Standard-cell area reviewed | Complete for supplied report |
| Power report reviewed | Complete for supplied report; activity assumptions need validation |
| Displayed setup timing path reviewed | Complete for supplied report |
| Hierarchy total discrepancy | Requires investigation |
| Full setup/hold timing closure | Not established |
| Post-route PPA closure | Not established |

---

## 17. Author

**Omkar Kalmesh Hadapad**

Electronics and Communication Engineering

Digital VLSI • Verilog RTL • Functional Verification • Cadence Genus

---

<p align="center">
  <b>Synchronous FIFO — RTL Design, Functional Verification and Synthesis Analysis</b>
</p>
