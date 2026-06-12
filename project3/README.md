In kern/pmap.c, I: 
modified the mem_init() function and wrote user_mem_check():

➜ mem_init()
This function is meant to allocate enough space for all the environments by calling boot_alloc() and then zeroing-out all the allocated memory by calling the memset() function. I also used boot_map_region to map the just-allocated environment's space as ‘read-only’ by the user.
➜ user_mem_check()
This function verifies that a user’s environment is allowed to access a block of memory with certain permissions. To do this, I go through the range of pages that were specified. If the current virtual address/current page is above ULIM, then I set user_mem_check_addr to the current virtual address and return a fault value. I then call pgdir_walk() to start checking for the permission bits. If this returns a NULL value, then I again set the user_mem_check_addr to the current virtual address and return an error code. Then I check the permission bits, and if they’re incorrect, I again set user_mem_check_addr and return an error code. Otherwise, I return 0 for success.

In kern/env.c, I wrote these functions: 
env_init(), env_setup_vm(), region_alloc(), load_icode(), env_create(), env_run()

I modified: kern/trapentry.S

In kern/trap.c, I wrote:
trap_init(), trap_dispatch()

In kern/syscall.c, I wrote: 
sys_cputs(), syscall(), sys_cputs()

in kern/kdebug.c, I modified:
debuginfo_eip()

in lib/libmain.c, I modified:
libmain()


