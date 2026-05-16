# JOS Operating System (x86 Kernel Development)
My implementation of the JOS operating system

Low-level x86 operating system development focused on bootloading, virtual memory, kernel memory management, and user environment execution.

This repository contains my implementation of core operating system functionality in C and x86 Assembly, including protected mode booting, paging, and memory allocation.


## Technical Overview

Implemented parts of the JOS operating system including:

### Memory Management
- Physical page allocator
- Page tracking and reference counting
- Virtual memory system setup
- Two-level page tables
- Page insertion and removal logic

### Kernel Memory System
- Kernel page directory setup
- Page table walking
- Dynamic page allocation

### User Environments
- User environment creation and loading
- Environment management
- User/kernel privilege separation

### Exception & Trap Foundations
- Trap handling core

## Technologies Used
- C
- x86 assembly
- GDB
- Vim
- Linux CLI
