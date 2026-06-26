# UART Communication System in Verilog

## Overview

A parameterized UART (Universal Asynchronous Receiver/Transmitter) communication system designed in Verilog HDL.

The project includes a configurable baud generator, UART transmitter, UART receiver, top-level integration, and a comprehensive verification testbench.

---

## Features

- Parameterized Clock Frequency
- Parameterized Baud Rate
- Baud Tick Generator
- UART Transmitter (TX)
- UART Receiver (RX)
- Top-Level UART Integration
- Busy Signal
- Done Signal
- Framing Error Detection
- Parity Error Detection
- Self-checking Testbench
- Multiple Verification Scenarios

---

## Project Structure

---

# Project Structure

```text
UART-Communication-System-Verilog
│
├── rtl/
│   ├── baud_generator.v
│   ├── uart_tx.v
│   ├── uart_rx.v
│   └── uart_top.v
│
├── testbench/
│   └── uart_tb.v
│
├── docs/
│   ├── architecture/
│   │   ├── baud_generator.png
│   │   ├── uart_top_architecture.png
│   │   ├── uart_tx_architecture.png
│   │   ├── uart_rx_architecture.png
│   │   ├── uart_tx_fsm.png
│   │   └── uart_rx_fsm.png
│   │
│   ├── simulation/
│   │   ├── basic_communication.png
│   │   ├── busy_signal.png
│   │   ├── back_to_back.png
│   │   ├── random_stress_test.png
│   │   ├── uart_waveform_full.png
│   │   ├── uart_waveform_zoom.png
│   │   └── verification_summary.png
│   │
│   └── reports/
│       └── verification_results.txt
│
├── README.md
└── LICENSE
```

---

# System Architecture

## Top-Level Architecture

![UART Top](docs/architecture/uart_top_architecture.png)

---

## Baud Generator

![Baud Generator](docs/architecture/baud_generator.png)

---

## UART Transmitter

![UART TX](docs/architecture/uart_tx_architecture.png)

---

## UART Receiver

![UART RX](docs/architecture/uart_rx_architecture.png)

---

## UART Transmitter FSM

![UART TX FSM](docs/architecture/uart_tx_fsm.png)

---

## UART Receiver FSM

![UART RX FSM](docs/architecture/uart_rx_fsm.png)

---

# Verification

The UART system is verified using a self-checking Verilog testbench that automatically validates transmitted and received data.

## Verification Scenarios

### 1. Basic Communication

Verifies successful transmission and reception of multiple data patterns.

Supported test vectors:

* 0x41
* 0x42
* 0x43
* 0x00
* 0xFF
* 0x55
* 0xAA

![Basic Communication](docs/simulation/basic_communication.png)

---

### 2. Busy Signal Validation

Verifies correct assertion and deassertion of the transmitter busy signal during frame transmission.

![Busy Signal](docs/simulation/busy_signal.png)

---

### 3. Back-to-Back Frame Transmission

Verifies continuous UART communication without idle gaps between frames.

Tested sequence:

* 0x10
* 0x20
* 0x30
* 0x40
* 0x50
* 0x60
* 0x70

![Back-to-Back Frames](docs/simulation/back_to_back.png)

---

### 4. Random Stress Test

Randomized data transmission used to validate long-duration operation.

Ten random frames are transmitted and verified automatically.

![Random Stress Test](docs/simulation/random_stress_test.png)

---

# Simulation Waveforms

## Complete UART Communication

![UART Waveform](docs/simulation/uart_waveform_full.png)

---

## Zoomed View

![Zoomed Waveform](docs/simulation/uart_waveform_zoom.png)

---

# Verification Summary

* Tests Run: **24**
* Tests Passed: **24**
* Tests Failed: **0**

**Overall Result: PASS**

![Verification Summary](docs/simulation/verification_summary.png)

The complete simulator log is available in:

```text
docs/reports/verification_results.txt
```

---

# Tools Used

* Verilog HDL
* Icarus Verilog
* EDA Playground
* EPWave

---

# Future Improvements

* Hardware synthesis on FPGA
* Configurable oversampling ratio
* FIFO buffers
* UART interrupt support
* Flow control (RTS/CTS)
* Extended verification using SystemVerilog/UVM
* Support for configurable frame formats

---

## License

This project is released under the MIT License.
