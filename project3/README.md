In kern/pmap.c, I: 
modified the mem_init() function and wrote user_mem_check()

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


