# QFSK Communication System on FPGA

This project implements a Quaternary Frequency Shift Keying (QFSK) communication system on the Altera DE2 FPGA board.

The system maps each 2-bit symbol to one of four carrier frequencies:

| Symbol | Frequency |
|--------|-----------|
| `00`   | 12 kHz    |
| `01`   | 18 kHz    |
| `10`   | 24 kHz    |
| `11`   | 30 kHz    |

## System Architecture

The design consists of four main blocks:

1. Data source
2. QFSK modulator
3. Communication channel
4. QFSK demodulator

The modulator uses Direct Digital Synthesis (DDS), including a 32-bit phase accumulator and a 1024-entry, 16-bit sine lookup table.

The receiver uses the Goertzel algorithm to detect the dominant carrier frequency and recover the transmitted 2-bit symbol.

## Hardware and Tools

- Altera DE2 Development Board
- Cyclone II FPGA
- SystemVerilog
- Quartus II
- ModelSim

## Features

- QFSK modulation with four configurable frequencies
- DDS-based sine-wave generation
- Noise channel simulation using an LFSR
- Non-coherent frequency detection using the Goertzel algorithm
- Output monitoring through LEDs and seven-segment displays
- Simulation and hardware verification support

## Video:

Bit Counting:

https://github.com/user-attachments/assets/949d7341-225b-4dd8-bc00-133e88d3d693

Function checking:

https://github.com/user-attachments/assets/03dad5ab-7bf8-4685-82e4-27e933debd3e


