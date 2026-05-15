/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_TRAP_H
#define JOS_KERN_TRAP_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

#include <inc/trap.h>
#include <inc/mmu.h>

/* The kernel's interrupt descriptor table */
extern struct Gatedesc idt[];
extern struct Pseudodesc idt_pd;

void trap_init(void);
void trap_init_percpu(void);
void print_regs(struct PushRegs *regs);
void print_trapframe(struct Trapframe *tf);
void page_fault_handler(struct Trapframe *);
void backtrace(struct Trapframe *);


/*
void t_divide();
void t_debug();
void t_nmi();
void t_brkpt();
void t_oflow();
void t_bound();
void t_illop();
void t_device();
void t_dblflt();
void t_tss();
void t_segnp();
void t_stack();
void t_gpflt();
void t_pgflt();
void t_fperr();
void t_align();
void t_mchk();
void t_simderr();

void t_syscall();
void t_default();
*/


//RYAN: the 'name' functions we had to do from trapentry.S hints
void label__t_divide_NOEC();
void label__t_debug_NOEC();
void label__t_nmi_NOEC();
void label__t_brkpt_NOEC();
void label__t_oflow_NOEC();
void label__t_bound_NOEC();
void label__t_illop_NOEC();
void label__t_device_NOEC();
void label__t_dblflt();
void label__t_tss();
void label__t_segnp();
void label__t_stack();
void label__t_gpflt();
void label__t_pgflt();
void label__t_fperr_NOEC();
void label__t_align();
void label__t_mchk_NOEC();
void label__t_simderr_NOEC();
void label__t_syscall_NOEC();
void label__t_default_NOEC();






#endif /* JOS_KERN_TRAP_H */
