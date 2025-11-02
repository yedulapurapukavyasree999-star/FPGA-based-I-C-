# FPGA-based-I-C-
# FPGA-Based I²C Address Translator

**Author:** Kavya Sree  
**Date:** November 2025  
**Platform:** Xilinx Vivado / EDA Playground  
**Company Task:** Vicharak LLP FPGA Internship Assignment  

---

## 🎯 Objective

To design an **FPGA-based I²C Address Translator** that allows a device with a fixed I²C address to coexist with others that share the same default address.  
The translator acts as an **I²C slave** to the main master and as an **I²C master** to the target device.  
It dynamically remaps the visible address to a different one, while keeping all data intact.

---

## ⚙️ Design Overview

### **Top-Level Behavior**
- The module monitors the I²C bus and detects START and STOP conditions.  
- When it recognizes the master accessing the *visible address*, it replaces that address with the *actual address* of the device.  
- All read/write data transactions are transparently forwarded between the master and device.

---

## 🧩 Architecture

### **Main Blocks**
1. **Start/Stop Detector**  
   - Detects when an I²C transaction begins or ends based on SDA and SCL transitions.

2. **Shift Register + Bit Counter**  
   - Captures the address bits serially as they arrive.  
   - After receiving all 7 address bits, the FSM compares them to the “visible” address.

3. **Finite State Machine (FSM)**  
   - Controls how the translator reacts to different bus phases.  
   - FSM States:
     - `IDLE` – Waiting for start condition  
     - `ADDR` – Capturing address bits  
     - `CHECK` – Compare and translate  
     - `PASS_WRITE` – Forward master → device data  
     - `PASS_READ` – Forward device → master data  
     - `WAIT_STOP` – Wait for stop condition  

4. **Forwarding Logic**  
   - Controls the SDA/SCL direction depending on whether the master is writing or reading.  
   - Always forwards clock (`scl_in → scl_to_dev`).

---

## 🧠 FSM Flow (Simplified)
   +-------+
   | IDLE  |
   +-------+
        |
    (Start)
        v
   +-------+
   | ADDR  |
   +-------+
        |
    (7 bits)
        v
   +-------+
   | CHECK |
   +-------+
    /       \

---

## 🧾 Address Translation

| Parameter | Description | Example |
|------------|-------------|----------|
| `VISIBLE_ADDR` | The address seen by the main I²C master | `0x54` |
| `ACTUAL_ADDR` | The true hardware address of the device | `0x60` |

During an address match (`0x54`), the module replaces those bits with `0x60` before sending them to the target device.

---

## 🔬 Simulation Details

- **Simulator:** Icarus Verilog (via [EDA Playground](https://edaplayground.com/))  
- **Testbench:** `tb_i2c_addr_translator.v`  
- **Waveform File:** `i2c_wave.vcd`  
- **How to View:** Open EPWave after simulation to view SDA/SCL transitions.  

**Observed Behavior:**  
- Start/Stop correctly detected.  
- Shift register captures 7 address bits.  
- Address translation verified at bit level.  
- Data passed transparently between master and device.

---

## 💡 Design Challenges Faced

- **I²C Timing Emulation:** Real I²C lines are open-drain and rely on pull-ups. Simulating that behavior in Verilog required simplified logic.  
- **Start/Stop Detection:** Needed to be done carefully to avoid false triggers during bit changes.  
- **FSM Synchronization:** Ensuring correct state transitions under asynchronous I²C edges while keeping design synchronous to FPGA clock.  
- **Vivado Compatibility:** Converted SystemVerilog constructs to Verilog (no `logic`, `typedef enum`).

---


## 🧾 Deliverables Checklist

| Deliverable | Status |
|--------------|:------:|
| Verilog module (`i2c_addr_translator.v`) | ✅ |
| Testbench (`tb_i2c_addr_translator.v`) | ✅ |
| Simulation (EDA Playground link) | ✅ |
| Resource report (Vivado) | ✅ |
| Documentation (`README.md`) | ✅ |

---

## 🔗 Useful Links

- [EDA Playground – Public Simulation](https://edaplayground.com/)
- [I²C Bus Specification by NXP](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)

---

**End of Document**


