In kern/pmap.c, I: 
modified the mem_init() function and wrote user_mem_check():

➜ mem_init()

This function is meant to allocate enough space for all the environments by calling boot_alloc() and then zeroing-out all the allocated memory by calling the memset() function. I also used boot_map_region to map the just-allocated environment's space as ‘read-only’ by the user.
➜ user_mem_check()

This function verifies that a user’s environment is allowed to access a block of memory with certain permissions. To do this, I go through the range of pages that were specified. If the current virtual address/current page is above ULIM, then I set user_mem_check_addr to the current virtual address and return a fault value. I then call pgdir_walk() to start checking for the permission bits. If this returns a NULL value, then I again set the user_mem_check_addr to the current virtual address and return an error code. Then I check the permission bits, and if they’re incorrect, I again set user_mem_check_addr and return an error code. Otherwise, I return 0 for success.

---

In kern/env.c, I wrote these functions: 
env_init(), env_setup_vm(), region_alloc(), load_icode(), env_create(), env_run()

➜ env_init()

This function marks all allocated environments as free and attaches each enviornment to the env_free_list, which is a linked list of free environments that the kernel keeps track of. To do this, I loop through all the enviornments, set each environment’s struct to be free, set the ID to zero, and set their initial link to NULL. I then link all environment structs together in a linked list. 

➜ env_setup_vm()

This function initializes the kernel’s virtual memory layout for the given environment. To do this, I incremented the physical page reference count, set the environment’s page directory, and copy the kernel’s page directory to the user’s environment’s page directory. 


➜ region_alloc()

This function allocates a certain amount of physical memory and maps it to the virtual addresses in the environment. To do this, I loop through the upper and lower bounds of the given memory address and its length, allocate a new page, check if this page isn’t NULL and then insert this new page into the environment’s page directory without initializing it


➜ load_icode()

This function initializes the user program to run from the kernel’s scheduler. To do this, I first check to make sure the incoming binary file isn’t NULL. Then I load in the user’s page directory into control register 3 (LCR3) to switch to it, cast the input binary file into an ELF file format structure, check that the ELF magic number (used for error checking) is correct, load in the main program header and the end of the program header, and loop through all the program headers. In this loop, if the program header type is ELF_PROG_LOAD, then I allocate enough space for a segment using region_alloc(), initialize all the allocated region to zeros, and finally copy the user’s binary data into this allocated region.

➜ env_create()

This function is supposed to allocate a new user environment and load the ELF binary file. To do this, I called env_alloc(), checked that the value it returns isn’t less than zero (an error), set the new environment’s type, and then call load_icode() to load in the user’s program into memory.

➜ env_run()

This function switches environments from the environment currently being run to the new environment that the scheduler wants to run. To do this, I check that the current environment isn’t NULL, and if it isn’t, then I set the current environment’s status as runnable, meaning that it's ready to be executed again, but currently is not. Then I change the current environment to be the one the schedule input, set this new environment’s status as running, increase the counter of the number of times this environment has been run, switch the page directory to the new environment’s and load in the old registers. 


I modified: kern/trapentry.S

➜ trapentry.S

This assembly file is meant to generate entry points for the different types of traps/exceptions that may be caused. To do this, I called the TRAPHANDLER_NOEC() assembly function on trap numbers 0-19, 48, and 500, while skipping 9 and 15 because they are reserved. Trap 500 is just a default trap handler for debugging and isn’t actually used. I also implemented _alltraps, which pushes values onto the stack to mimic the TrapFrame struct in C.

In kern/trap.c, I wrote:
trap_init(), trap_dispatch()

➜ trap_init()

This function initializes all the interrupt descriptor tables. To do this, I call the SETGATE function/macro for each exception number given in trapentry.S which is dependent on whether each exception is a trap or interrupt, and whether each exception is a user or kernel type.

➜ trap_dispatch()

Given a trapframe, this function calls the different functions that are to execute, depending on what trapframe number the trap was. If the incoming trap number, specified by the trapframe’s tf_trapno struct variable, was 14 (for a page fault exception), then I call the page_fault_handler() function. If the trap number was 3 (for breakpoint exception), then I call the monitor() function. If the trap number was 48 (for syscall exception), then I call the kernel’s syscall() function with the input trapframe’s eax, edx, ecx, ebx, edi, and esi register values. Finally, I changed the current environment’s trapframe’s eax register value to the one input in this function.  

In kern/syscall.c, I wrote: 
sys_cputs(), syscall(), sys_cputs()

➜ sys_cputs()

This function prints a string to the system console, and all I do is call user_mem_check() to make sure the user has permission to read the given memory block. 

➜ syscall()

This very important function takes in parameters that the user gave it, including the first five parameters of the system call, as well as the syscall number, and executes 4 different operations depending on the input system call number. If the user syscall was 0, then using a switch statement, I call sys_cputs() function to print a string to the system console; if the syscall was 1, I call the sys_cgetc() function to read a character from the console; if the syscall was 2, SYS_envid() is invoked which returns the current environment’s ID; if the syscall was 3, then I invoke the sys_env_destroy() function, which destroys a given environment. 

➜ sys_cputs()

This function prints a string to the system console, and all I do is call user_mem_check() to make sure the user has permission to read the given memory block. 

in kern/kdebug.c, I modified:
debuginfo_eip()

➜ debuginfo_eip()

This function finds relevant debugging information to return to the caller function. The parts I did were to make sure the parts of the memory were valid by calling user_mem_check() and making sure that an error didn’t occur; also I called user_mem_check() to make sure the symbol table (STAB) and symbol table string regions were relevant. Finally, I called the STAB binary search function to find the correct ‘type’ and address, and if I found it, then I set the eip_line value to the stab value’s description value at location right_line. 


in lib/libmain.c, I modified:
libmain()

➜ libmain()

This function initializes a global environment pointer to point to the user’s environment structure. To do this, I set thisenv variable to zero, get the current system ID by calling the sys_getenvid() function, and then set ‘thisenv’ variable to  point to the current user’s environment structure. 
