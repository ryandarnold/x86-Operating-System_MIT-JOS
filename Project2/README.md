I wrote these functions in the kern/pmap.c file: 

➜ boot_alloc()
This function takes in ‘n’ bytes of memory to allocate, and returns the location of the next free page. To do this, you simply keep track of the total number of pages available (which is initially determined by a non-volatile CMOS RAM chip), and then move a pointer once you allocate enough pages to hold ‘n’ number of bytes

➜ mem_init()
This function initializes all the memory. I initialized the struct PageInfo ‘pages’ variable to allocate enough space using the above boot_alloc(), and then initialized all memory locations to zero using the memset() function.

➜ page_init()
This function is meant to be a more generalized form of boot_alloc(), so its easier to deal with in the future, as well as keep track of all the physical pages using a linked list. To do this, you need to know the locations of the IO hole start and end addresses, how much base memory is allocated, and whether you’re below the physical address of the start of boot_alloc(0). I then mark these pages as either having or not having a physical page reference.

➜ page_alloc()
This function allocates a single page in memory and returns a PageInfo struct pointer back to the caller, and has the option to zero-out all the memory at the allocated locations. To do this, I simply return the pointer to the head of the free page linked list.

➜ page_free()
This function is supposed to free a currently-allocated page. To do this, I set the current physical page’s reference count back to zero (from 1), and then add its pointer back to the top of the free list.

➜ pgdir_walk()
The purpose of this function is to return a pointer to a page table entry (PTE), which is different from a page directory entry (PDE). If the PTE doesn’t exist, and the user doesn’t want to create a new one, then it returns NULL. Otherwise, if the user wants to create a new PTE, then this function allocates a new PTE and returns a pointer to it to the caller function. To do this, I: 
1) Made sure to see if the PTE had a ‘present’ bit ==0, and that create ==0, then return NULL
2) If PTE == 0 and the user wants to create a new PTE, then allocate a new page, check that its not NULL, increase its page reference count by 1, convert the newly allocated page to a physical address and tack on the ‘present’, ‘writable’ and ‘user’ flag bits, cast this as a page directory entry in the given page directory entry, and finally return the last 12 bits of the PDE as a virtual address while indexing it to return it as a PTE.
3) If the page table entry already exists, then return the corresponding PTE

➜ boot_map_region()
This function maps a range of virtual addresses to a range of corresponding physical addresses. To do this, I loop over the range of virtual addresses and the range of physical addresses, and I walk through the page directory and attach all given permission bits to the new PTE and then store it as a physical page. 

➜ page_lookup()
This function tries to find a page mapped at the given virtual address and returns it. To do this, I walk the page directory and make sure the given PTE is not NULL and is present. Then I convert the given PTE into a physical address, and then I essentially return both the metadata of the page as a PageInfo struct, and return the pointer to the actual PTE.

➜ page_remove()
This function removes an already-allocated page. To do this, I call the page_lookup function and make sure it doesn’t return NULL. Then I set the PTE = 0 to deallocate it, call page_decref (which decreases the reference count of the page and deallocates it if there aren’t any references), and then call tlb_invalidate, which invalidates a translation lookaside buffer (TLB) entry.

➜ page_insert()
The purpose of this function is to map a physical page at a virtual address. If there is already a page there, I remove it and replace it with the new page, and also increase the reference count. If there wasn’t a page there, then I just add it in.

➜ mem_init()
I finished the rest of this function by using boot_map_region() to map all the ‘pages’ variable into memory at address UPAGES, set up the kernel stack, and map all physical memory at KERNBASE memory location as kernel read/write.
