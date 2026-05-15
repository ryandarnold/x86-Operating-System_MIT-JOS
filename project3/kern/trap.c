#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>

static struct Taskstate ts;

/* For debugging, so print_trapframe can distinguish between printing
 * a saved trapframe and printing the current trapframe and print some
 * additional information in the latter case.
 */
static struct Trapframe *last_tf;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = { { 0 } }; //RYAN: array of ALL interrupt descriptors, which must be set by SETGATE
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};

void NAME(); //RYAN: not sure if this is correct



static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
}



//modify trap_init() to initialize the idt to point to each of these entry points defined in trapentry.S;
// the SETGATE macro will be helpful here
void
trap_init(void)
{
	extern struct Segdesc gdt[];
	

	// LAB 3: Your code here.

	//cprintf("\n!!!!RYAN: TRAP_INIT() STILL ISN'T GUCCI WITH THE TRUE/FALSE FOR ISTRAP DEFINITION!!!!\n\n");
	SETGATE(idt[T_DIVIDE], true, GD_KT,label__t_divide_NOEC, 0);
	SETGATE(idt[T_DEBUG], true, GD_KT, label__t_debug_NOEC, 0);
	SETGATE(idt[T_NMI], false, GD_KT, label__t_nmi_NOEC, 0); //assuming this is false because osdev says its an interrupt
	SETGATE(idt[T_BRKPT], true, GD_KT, label__t_brkpt_NOEC, 3); //TRUE
	SETGATE(idt[T_OFLOW], true, GD_KT, label__t_oflow_NOEC, 0);
	SETGATE(idt[T_BOUND], true, GD_KT, label__t_bound_NOEC, 0);
	SETGATE(idt[T_ILLOP], true, GD_KT, label__t_illop_NOEC, 0);
	SETGATE(idt[T_DEVICE], true, GD_KT, label__t_device_NOEC, 0);
	SETGATE(idt[T_DBLFLT], false, GD_KT, label__t_dblflt, 0);
	SETGATE(idt[T_TSS], true, GD_KT, label__t_tss, 0);
	SETGATE(idt[T_SEGNP], true, GD_KT, label__t_segnp, 0);
	SETGATE(idt[T_STACK], true, GD_KT, label__t_stack, 0);
	SETGATE(idt[T_GPFLT], true, GD_KT, label__t_gpflt, 0);
	SETGATE(idt[T_PGFLT], true, GD_KT, label__t_pgflt, 0);
	SETGATE(idt[T_FPERR], true, GD_KT, label__t_fperr_NOEC, 0);
	SETGATE(idt[T_ALIGN], true, GD_KT, label__t_align, 0);
	SETGATE(idt[T_MCHK], false, GD_KT, label__t_mchk_NOEC, 0);
	SETGATE(idt[T_SIMDERR], true, GD_KT, label__t_simderr_NOEC, 0);

	SETGATE(idt[T_SYSCALL], true, GD_KT, label__t_syscall_NOEC, 3);




	/*bool istrap = true;
	bool isNOTtrap = false;
	//NOTE: I think SETGATE tries to setup the descriptor tables for the traps/exceptions
	//NOTE: idt[] has been initialized to all zeros so i think i can just index into any of them and set them up here!
	
	//Need to tell the CPU what to do once a user creates an exception:
	//-GD_KT for kernel text/code data to execute because you need to switch to kernel mode once exception occurs
	//-offset is the offset within the global descriptor table, which apparently is defined by the symbol made in TRAPHANDLER
	SETGATE(idt[T_DIVIDE], , GD_KT, label__t_divide_NOEC, 0); //0
	SETGATE(idt[T_DEBUG], , GD_KT, label__t_debug_NOEC, 0); //1
	SETGATE(idt[T_NMI], , GD_KT, label__t_nmi_NOEC, 0); //2
	
	SETGATE(idt[T_BRKPT], , GD_KT, label__t_brkpt_NOEC, 3); //3 -page 3294 of Intel® 64 and IA-32 Architectures Software Developer’s Manual 
	
	SETGATE(idt[T_OFLOW], , GD_KT, label__t_oflow_NOEC, 0); //4
	SETGATE(idt[T_BOUND], , GD_KT, label__t_bound_NOEC, 0); //5
	SETGATE(idt[T_ILLOP], , GD_KT, label__t_illop_NOEC, 0); //6
	SETGATE(idt[T_DEVICE], , GD_KT, label__t_device_NOEC, 0); //7
	SETGATE(idt[T_DBLFLT], , GD_KT, label__t_dblflt, 0); //8
	//9 reserved
	SETGATE(idt[T_TSS], , GD_KT, label__t_tss, 0); //10
	SETGATE(idt[T_SEGNP], , GD_KT, label__t_segnp, 0); //11
	SETGATE(idt[T_STACK], , GD_KT, label__t_stack, 0); //12
	SETGATE(idt[T_GPFLT], , GD_KT, label__t_gpflt, 0); //13
	SETGATE(idt[T_PGFLT], , GD_KT, label__t_pgflt, 0); //14
	//15 reserved
	SETGATE(idt[T_FPERR], , GD_KT, label__t_fperr_NOEC, 0); //16
	SETGATE(idt[T_ALIGN], , GD_KT, label__t_align, 0); //17
	SETGATE(idt[T_MCHK], , GD_KT, label__t_mchk_NOEC, 0); //18
	SETGATE(idt[T_SIMDERR], , GD_KT, label__t_simderr_NOEC, 0); //19
	
	SETGATE(idt[T_SYSCALL], , GD_KT, label__t_syscall_NOEC, 3); //48 -> user must be able to do a SYSCALL exception!!!!
	//SETGATE(idt[T_DEFAULT], , GD_KT, label__t_default_NOEC, 0); //500 -> this should NEVER be called because idt[] is size 256 max!
	*/
	// Per-CPU setup 
	trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
	ts.ts_ss0 = GD_KD;
	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0) {
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void
print_regs(struct PushRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	if (tf->tf_trapno == 14)
	{
		page_fault_handler(tf);
		return;
	}
	else if (tf->tf_trapno == 3)
	{
		monitor(tf);
		return;
	}
	else if (tf->tf_trapno == 48)
	{
		//user inputs their own syscall value into register %eax
		//BUT the kernel interprets the SYSCALL function as vector 48, which is different than a syscall user input value
		uint32_t user_syscall_val = tf->tf_regs.reg_eax;
		uint32_t edx = tf->tf_regs.reg_edx;
		uint32_t ecx = tf->tf_regs.reg_ecx;
		uint32_t ebx = tf->tf_regs.reg_ebx;
		uint32_t edi = tf->tf_regs.reg_edi;
		uint32_t esi = tf->tf_regs.reg_esi;
		int32_t val = syscall(user_syscall_val, edx, ecx, ebx, edi, esi);
		
		//now to return the value 'val' to %eax
		//tf->tf_regs.reg_eax;
		
		//lab 3 doc says to for the return value to be passed back to the user process in %eax and not the current input *tf 
		//because I THINK THINK THINK that the input parameter 'tf' is the KERNEL trapframe, which is different than user trapframe
		curenv->env_tf.tf_regs.reg_eax = val;
		return;
	}

	//I think above here, the kernel shold expect to properly handle the exception that came in because these are recoverable exceptions


	//i think if you get below here, then you delete the current enviornment because there are faults in the user program
	//that SHOULD cause a non-recoverble exception

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		env_destroy(curenv);
		return;
	}
}

void
trap(struct Trapframe *tf)
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

	cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		assert(curenv);

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
	env_run(curenv);
}


void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	
	//RYAN: the tf->tf_cs is the code segment. a value of 0 means its in kernel mode, and value of 3 means in user mode according to 
	//Intel docs page 3160 out of 5198
	if (tf->tf_cs == 3)
	{
		panic("page fault happened in kernel mode!! in page_fault_handler() function in kern/trap.c");
	}


	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

