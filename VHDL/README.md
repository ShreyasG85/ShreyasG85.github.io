# VHDL

Implemented VHDL code and synthesis flow for PIC16F84A microcontroller as part of the course Digital Microelectronics 2. The final result could compile assembly and run the resulting hex code as specified in the original MCU's datasheet.

| File | Description |
|------|-------------|
| `PIC.vhd` | Top-level VHDL structural implementation of a PIC micro-controller CPU core, integrating the control decoder, ALU, dual-port RAM, and call stack |
| `alu.vhd` | An 8-bit Arithmetic Logic Unit (ALU) implementing PIC instruction operations and updating Z, DC, and C status flags |
| `alu_functions.vhd` | VHDL package defining the PIC opcode types, utility subtype definitions, and helper functions for instruction decoding and status flag calculations  |
| `alu_procedures.vhd` | VHDL package providing modular subprograms for ALU operations, including addition, subtraction, logical computations, and bit manipulation with status flag calculation |
| `dpram.vhd` | Synchronous RAM storage module for PIC data memory, featuring parametric data/address widths and direct STATUS register updating |
| `stack.vhd` | An 8-level circular call stack implementation for storing 13-bit return program counter (PC) addresses during CALL and RETURN operations |
| `state_machine.vhd` |  Finite State Machine (FSM) control unit managing the multi-cycle instruction lifecycle (fetch, read, execute, writeback), program counter, and branch/skip pipeline flushes |
