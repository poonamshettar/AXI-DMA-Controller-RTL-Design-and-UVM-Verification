# AXI-Based DMA Controller

## Overview

This project implements a **Direct Memory Access (DMA) Controller** integrated with an **AXI Memory-Mapped Slave**. It is designed to facilitate high-throughput memory-to-memory data transfers with minimal CPU intervention using AXI-Lite interfaces. The design is fully parameterized and compatible with standard SoC bus architectures.

---


## Architecture
```
Control Inputs:
[dma_start, src_addr, dst_addr, transfer_size]
           |
           v
  +------------------+     AXI Read     +---------------------+
  |   dma_axi_fsm    | <--------------> |  axi_memory_slave   |
  |  (State Machine) |     AXI Write    |  (Simulated RAM)    |
  +--------+---------+ ---------------> +---------------------+
           |
        [dma_done, dma_error]

```
## Modules

### 1. `dma_axi_top`

- **Top-level integration** of the DMA controller and the AXI memory slave.  
- Handles signal routing between the DMA FSM and the memory interface.

### 2. `dma_axi_fsm`

- A **Finite State Machine (FSM)** that orchestrates:
  - AXI read from `src_addr`
  - AXI write to `dst_addr`
  - Burst alignment and transfer size tracking  
- Supports AXI handshaking using `valid`/`ready` signals.

### 3. `axi_memory_slave`

- A lightweight **AXI memory model** for simulation purposes.  
- Implements AXI4 read/write transactions.  
- Parameterized to simulate scalable memory depth and data width.

---

## Key Parameters

| Parameter     | Description                | Default |
|---------------|----------------------------|---------|
| `ADDR_WIDTH`  | Address width              | 32      |
| `DATA_WIDTH`  | Data bus width             | 64      |
| `MEM_DEPTH`   | Depth of internal memory   | 1024    |

---

## How It Works

1. **Initialization:**
   - CPU sets `dma_start = 1` with `src_addr`, `dst_addr`, and `transfer_size`.

2. **FSM transitions** through these stages:
   - Read Setup → Read Transfer → Write Setup → Write Transfer

3. **AXI handshakes** ensure protocol-compliant communication.

4. **DMA completion** is signaled by `dma_done = 1`.

---

## AXI Handshake Signals

| Signal        | Description                |
|---------------|----------------------------|
| `awvalid`     | Write address valid        |
| `awready`     | Write address ready        |
| `wvalid`      | Write data valid           |
| `wready`      | Write data ready           |
| `bvalid`      | Write response valid       |
| `arvalid`     | Read address valid         |
| `arready`     | Read address ready         |
| `rvalid`      | Read data valid            |
| `rready`      | Read data ready            |

---