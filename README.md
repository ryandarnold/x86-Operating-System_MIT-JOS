# JOS Operating System (x86 Kernel Development)
My implementation of the JOS operating system

Low-level x86 operating system development focused on bootloading, virtual memory, kernel memory management, and user environment execution.

This repository contains my implementation of core operating system functionality in C and x86 Assembly, including protected mode booting, paging, memory allocation.


## Technical Overview

Implemented foundational operating system components including:

### Memory Management
- Physical page allocator
- Page tracking and reference counting
- Virtual memory system setup
- Two-level page tables
- Kernel memory mapping
- Address translation mechanisms
- Memory permissions and protection
- Page insertion/removal logic

### Kernel Memory System
- Physical ↔ virtual address mappings
- Kernel page directory setup
- Memory layout implementation
- Page table walking
- Dynamic page allocation

### User Environments
- User environment creation and loading
- Environment management
- Context switching
- Protected user address spaces
- User/kernel privilege separation
- Environment execution flow

### Exception & Trap Foundations
- Trap handling infrastructure
- Protected execution boundaries
- Fault isolation mechanisms

---

## Key Files

### Memory Management
```text
kern/pmap.c
inc/mmu.h
inc/memlayout.h
