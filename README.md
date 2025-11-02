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

