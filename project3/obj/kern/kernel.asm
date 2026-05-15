
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010004a:	b8 00 cb 18 f0       	mov    $0xf018cb00,%eax
f010004f:	2d 00 bc 18 f0       	sub    $0xf018bc00,%eax
f0100054:	50                   	push   %eax
f0100055:	6a 00                	push   $0x0
f0100057:	68 00 bc 18 f0       	push   $0xf018bc00
f010005c:	e8 ed 47 00 00       	call   f010484e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100061:	e8 bd 04 00 00       	call   f0100523 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100066:	83 c4 08             	add    $0x8,%esp
f0100069:	68 ac 1a 00 00       	push   $0x1aac
f010006e:	68 c0 4c 10 f0       	push   $0xf0104cc0
f0100073:	e8 be 32 00 00       	call   f0103336 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100078:	e8 2d 11 00 00       	call   f01011aa <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f010007d:	e8 bb 2b 00 00       	call   f0102c3d <env_init>
	trap_init();
f0100082:	e8 2d 33 00 00       	call   f01033b4 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100087:	83 c4 08             	add    $0x8,%esp
f010008a:	6a 00                	push   $0x0
f010008c:	68 7e 6b 13 f0       	push   $0xf0136b7e
f0100091:	e8 a1 2d 00 00       	call   f0102e37 <env_create>
	//ENV_CREATE(user_hello, ENV_TYPE_USER); // ORIGINAL
	ENV_CREATE(user_breakpoint, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100096:	83 c4 04             	add    $0x4,%esp
f0100099:	ff 35 50 be 18 f0    	pushl  0xf018be50
f010009f:	e8 bb 31 00 00       	call   f010325f <env_run>

f01000a4 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a4:	f3 0f 1e fb          	endbr32 
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	56                   	push   %esi
f01000ac:	53                   	push   %ebx
f01000ad:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000b0:	83 3d 04 cb 18 f0 00 	cmpl   $0x0,0xf018cb04
f01000b7:	74 0f                	je     f01000c8 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b9:	83 ec 0c             	sub    $0xc,%esp
f01000bc:	6a 00                	push   $0x0
f01000be:	e8 e8 06 00 00       	call   f01007ab <monitor>
f01000c3:	83 c4 10             	add    $0x10,%esp
f01000c6:	eb f1                	jmp    f01000b9 <_panic+0x15>
	panicstr = fmt;
f01000c8:	89 35 04 cb 18 f0    	mov    %esi,0xf018cb04
	asm volatile("cli; cld");
f01000ce:	fa                   	cli    
f01000cf:	fc                   	cld    
	va_start(ap, fmt);
f01000d0:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d3:	83 ec 04             	sub    $0x4,%esp
f01000d6:	ff 75 0c             	pushl  0xc(%ebp)
f01000d9:	ff 75 08             	pushl  0x8(%ebp)
f01000dc:	68 db 4c 10 f0       	push   $0xf0104cdb
f01000e1:	e8 50 32 00 00       	call   f0103336 <cprintf>
	vcprintf(fmt, ap);
f01000e6:	83 c4 08             	add    $0x8,%esp
f01000e9:	53                   	push   %ebx
f01000ea:	56                   	push   %esi
f01000eb:	e8 1c 32 00 00       	call   f010330c <vcprintf>
	cprintf("\n");
f01000f0:	c7 04 24 38 5d 10 f0 	movl   $0xf0105d38,(%esp)
f01000f7:	e8 3a 32 00 00       	call   f0103336 <cprintf>
f01000fc:	83 c4 10             	add    $0x10,%esp
f01000ff:	eb b8                	jmp    f01000b9 <_panic+0x15>

f0100101 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100101:	f3 0f 1e fb          	endbr32 
f0100105:	55                   	push   %ebp
f0100106:	89 e5                	mov    %esp,%ebp
f0100108:	53                   	push   %ebx
f0100109:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010010c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010010f:	ff 75 0c             	pushl  0xc(%ebp)
f0100112:	ff 75 08             	pushl  0x8(%ebp)
f0100115:	68 f3 4c 10 f0       	push   $0xf0104cf3
f010011a:	e8 17 32 00 00       	call   f0103336 <cprintf>
	vcprintf(fmt, ap);
f010011f:	83 c4 08             	add    $0x8,%esp
f0100122:	53                   	push   %ebx
f0100123:	ff 75 10             	pushl  0x10(%ebp)
f0100126:	e8 e1 31 00 00       	call   f010330c <vcprintf>
	cprintf("\n");
f010012b:	c7 04 24 38 5d 10 f0 	movl   $0xf0105d38,(%esp)
f0100132:	e8 ff 31 00 00       	call   f0103336 <cprintf>
	va_end(ap);
}
f0100137:	83 c4 10             	add    $0x10,%esp
f010013a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010013d:	c9                   	leave  
f010013e:	c3                   	ret    

f010013f <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010013f:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100143:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100148:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100149:	a8 01                	test   $0x1,%al
f010014b:	74 0a                	je     f0100157 <serial_proc_data+0x18>
f010014d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100152:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100153:	0f b6 c0             	movzbl %al,%eax
f0100156:	c3                   	ret    
		return -1;
f0100157:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010015c:	c3                   	ret    

f010015d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010015d:	55                   	push   %ebp
f010015e:	89 e5                	mov    %esp,%ebp
f0100160:	53                   	push   %ebx
f0100161:	83 ec 04             	sub    $0x4,%esp
f0100164:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100166:	ff d3                	call   *%ebx
f0100168:	83 f8 ff             	cmp    $0xffffffff,%eax
f010016b:	74 29                	je     f0100196 <cons_intr+0x39>
		if (c == 0)
f010016d:	85 c0                	test   %eax,%eax
f010016f:	74 f5                	je     f0100166 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100171:	8b 0d 24 be 18 f0    	mov    0xf018be24,%ecx
f0100177:	8d 51 01             	lea    0x1(%ecx),%edx
f010017a:	88 81 20 bc 18 f0    	mov    %al,-0xfe743e0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100180:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100186:	b8 00 00 00 00       	mov    $0x0,%eax
f010018b:	0f 44 d0             	cmove  %eax,%edx
f010018e:	89 15 24 be 18 f0    	mov    %edx,0xf018be24
f0100194:	eb d0                	jmp    f0100166 <cons_intr+0x9>
	}
}
f0100196:	83 c4 04             	add    $0x4,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    

f010019c <kbd_proc_data>:
{
f010019c:	f3 0f 1e fb          	endbr32 
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp
f01001a3:	53                   	push   %ebx
f01001a4:	83 ec 04             	sub    $0x4,%esp
f01001a7:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ac:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001ad:	a8 01                	test   $0x1,%al
f01001af:	0f 84 f2 00 00 00    	je     f01002a7 <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f01001b5:	a8 20                	test   $0x20,%al
f01001b7:	0f 85 f1 00 00 00    	jne    f01002ae <kbd_proc_data+0x112>
f01001bd:	ba 60 00 00 00       	mov    $0x60,%edx
f01001c2:	ec                   	in     (%dx),%al
f01001c3:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01001c5:	3c e0                	cmp    $0xe0,%al
f01001c7:	74 61                	je     f010022a <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f01001c9:	84 c0                	test   %al,%al
f01001cb:	78 70                	js     f010023d <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f01001cd:	8b 0d 00 bc 18 f0    	mov    0xf018bc00,%ecx
f01001d3:	f6 c1 40             	test   $0x40,%cl
f01001d6:	74 0e                	je     f01001e6 <kbd_proc_data+0x4a>
		data |= 0x80;
f01001d8:	83 c8 80             	or     $0xffffff80,%eax
f01001db:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001dd:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001e0:	89 0d 00 bc 18 f0    	mov    %ecx,0xf018bc00
	shift |= shiftcode[data];
f01001e6:	0f b6 d2             	movzbl %dl,%edx
f01001e9:	0f b6 82 60 4e 10 f0 	movzbl -0xfefb1a0(%edx),%eax
f01001f0:	0b 05 00 bc 18 f0    	or     0xf018bc00,%eax
	shift ^= togglecode[data];
f01001f6:	0f b6 8a 60 4d 10 f0 	movzbl -0xfefb2a0(%edx),%ecx
f01001fd:	31 c8                	xor    %ecx,%eax
f01001ff:	a3 00 bc 18 f0       	mov    %eax,0xf018bc00
	c = charcode[shift & (CTL | SHIFT)][data];
f0100204:	89 c1                	mov    %eax,%ecx
f0100206:	83 e1 03             	and    $0x3,%ecx
f0100209:	8b 0c 8d 40 4d 10 f0 	mov    -0xfefb2c0(,%ecx,4),%ecx
f0100210:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100214:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100217:	a8 08                	test   $0x8,%al
f0100219:	74 61                	je     f010027c <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f010021b:	89 da                	mov    %ebx,%edx
f010021d:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100220:	83 f9 19             	cmp    $0x19,%ecx
f0100223:	77 4b                	ja     f0100270 <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f0100225:	83 eb 20             	sub    $0x20,%ebx
f0100228:	eb 0c                	jmp    f0100236 <kbd_proc_data+0x9a>
		shift |= E0ESC;
f010022a:	83 0d 00 bc 18 f0 40 	orl    $0x40,0xf018bc00
		return 0;
f0100231:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100236:	89 d8                	mov    %ebx,%eax
f0100238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010023b:	c9                   	leave  
f010023c:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010023d:	8b 0d 00 bc 18 f0    	mov    0xf018bc00,%ecx
f0100243:	89 cb                	mov    %ecx,%ebx
f0100245:	83 e3 40             	and    $0x40,%ebx
f0100248:	83 e0 7f             	and    $0x7f,%eax
f010024b:	85 db                	test   %ebx,%ebx
f010024d:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100250:	0f b6 d2             	movzbl %dl,%edx
f0100253:	0f b6 82 60 4e 10 f0 	movzbl -0xfefb1a0(%edx),%eax
f010025a:	83 c8 40             	or     $0x40,%eax
f010025d:	0f b6 c0             	movzbl %al,%eax
f0100260:	f7 d0                	not    %eax
f0100262:	21 c8                	and    %ecx,%eax
f0100264:	a3 00 bc 18 f0       	mov    %eax,0xf018bc00
		return 0;
f0100269:	bb 00 00 00 00       	mov    $0x0,%ebx
f010026e:	eb c6                	jmp    f0100236 <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f0100270:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100273:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100276:	83 fa 1a             	cmp    $0x1a,%edx
f0100279:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010027c:	f7 d0                	not    %eax
f010027e:	a8 06                	test   $0x6,%al
f0100280:	75 b4                	jne    f0100236 <kbd_proc_data+0x9a>
f0100282:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100288:	75 ac                	jne    f0100236 <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f010028a:	83 ec 0c             	sub    $0xc,%esp
f010028d:	68 0d 4d 10 f0       	push   $0xf0104d0d
f0100292:	e8 9f 30 00 00       	call   f0103336 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100297:	b8 03 00 00 00       	mov    $0x3,%eax
f010029c:	ba 92 00 00 00       	mov    $0x92,%edx
f01002a1:	ee                   	out    %al,(%dx)
}
f01002a2:	83 c4 10             	add    $0x10,%esp
f01002a5:	eb 8f                	jmp    f0100236 <kbd_proc_data+0x9a>
		return -1;
f01002a7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002ac:	eb 88                	jmp    f0100236 <kbd_proc_data+0x9a>
		return -1;
f01002ae:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002b3:	eb 81                	jmp    f0100236 <kbd_proc_data+0x9a>

f01002b5 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002b5:	55                   	push   %ebp
f01002b6:	89 e5                	mov    %esp,%ebp
f01002b8:	57                   	push   %edi
f01002b9:	56                   	push   %esi
f01002ba:	53                   	push   %ebx
f01002bb:	83 ec 1c             	sub    $0x1c,%esp
f01002be:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f01002c0:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c5:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01002ca:	bb 84 00 00 00       	mov    $0x84,%ebx
f01002cf:	89 fa                	mov    %edi,%edx
f01002d1:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d2:	a8 20                	test   $0x20,%al
f01002d4:	75 13                	jne    f01002e9 <cons_putc+0x34>
f01002d6:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01002dc:	7f 0b                	jg     f01002e9 <cons_putc+0x34>
f01002de:	89 da                	mov    %ebx,%edx
f01002e0:	ec                   	in     (%dx),%al
f01002e1:	ec                   	in     (%dx),%al
f01002e2:	ec                   	in     (%dx),%al
f01002e3:	ec                   	in     (%dx),%al
	     i++)
f01002e4:	83 c6 01             	add    $0x1,%esi
f01002e7:	eb e6                	jmp    f01002cf <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f01002e9:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ec:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002f1:	89 c8                	mov    %ecx,%eax
f01002f3:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002f4:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f9:	bf 79 03 00 00       	mov    $0x379,%edi
f01002fe:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100303:	89 fa                	mov    %edi,%edx
f0100305:	ec                   	in     (%dx),%al
f0100306:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010030c:	7f 0f                	jg     f010031d <cons_putc+0x68>
f010030e:	84 c0                	test   %al,%al
f0100310:	78 0b                	js     f010031d <cons_putc+0x68>
f0100312:	89 da                	mov    %ebx,%edx
f0100314:	ec                   	in     (%dx),%al
f0100315:	ec                   	in     (%dx),%al
f0100316:	ec                   	in     (%dx),%al
f0100317:	ec                   	in     (%dx),%al
f0100318:	83 c6 01             	add    $0x1,%esi
f010031b:	eb e6                	jmp    f0100303 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100322:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100326:	ee                   	out    %al,(%dx)
f0100327:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010032c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100331:	ee                   	out    %al,(%dx)
f0100332:	b8 08 00 00 00       	mov    $0x8,%eax
f0100337:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100338:	89 c8                	mov    %ecx,%eax
f010033a:	80 cc 07             	or     $0x7,%ah
f010033d:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f0100343:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100346:	0f b6 c1             	movzbl %cl,%eax
f0100349:	80 f9 0a             	cmp    $0xa,%cl
f010034c:	0f 84 dd 00 00 00    	je     f010042f <cons_putc+0x17a>
f0100352:	83 f8 0a             	cmp    $0xa,%eax
f0100355:	7f 46                	jg     f010039d <cons_putc+0xe8>
f0100357:	83 f8 08             	cmp    $0x8,%eax
f010035a:	0f 84 a7 00 00 00    	je     f0100407 <cons_putc+0x152>
f0100360:	83 f8 09             	cmp    $0x9,%eax
f0100363:	0f 85 d3 00 00 00    	jne    f010043c <cons_putc+0x187>
		cons_putc(' ');
f0100369:	b8 20 00 00 00       	mov    $0x20,%eax
f010036e:	e8 42 ff ff ff       	call   f01002b5 <cons_putc>
		cons_putc(' ');
f0100373:	b8 20 00 00 00       	mov    $0x20,%eax
f0100378:	e8 38 ff ff ff       	call   f01002b5 <cons_putc>
		cons_putc(' ');
f010037d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100382:	e8 2e ff ff ff       	call   f01002b5 <cons_putc>
		cons_putc(' ');
f0100387:	b8 20 00 00 00       	mov    $0x20,%eax
f010038c:	e8 24 ff ff ff       	call   f01002b5 <cons_putc>
		cons_putc(' ');
f0100391:	b8 20 00 00 00       	mov    $0x20,%eax
f0100396:	e8 1a ff ff ff       	call   f01002b5 <cons_putc>
		break;
f010039b:	eb 25                	jmp    f01003c2 <cons_putc+0x10d>
	switch (c & 0xff) {
f010039d:	83 f8 0d             	cmp    $0xd,%eax
f01003a0:	0f 85 96 00 00 00    	jne    f010043c <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f01003a6:	0f b7 05 28 be 18 f0 	movzwl 0xf018be28,%eax
f01003ad:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003b3:	c1 e8 16             	shr    $0x16,%eax
f01003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003b9:	c1 e0 04             	shl    $0x4,%eax
f01003bc:	66 a3 28 be 18 f0    	mov    %ax,0xf018be28
	if (crt_pos >= CRT_SIZE) {
f01003c2:	66 81 3d 28 be 18 f0 	cmpw   $0x7cf,0xf018be28
f01003c9:	cf 07 
f01003cb:	0f 87 8e 00 00 00    	ja     f010045f <cons_putc+0x1aa>
	outb(addr_6845, 14);
f01003d1:	8b 0d 30 be 18 f0    	mov    0xf018be30,%ecx
f01003d7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003dc:	89 ca                	mov    %ecx,%edx
f01003de:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003df:	0f b7 1d 28 be 18 f0 	movzwl 0xf018be28,%ebx
f01003e6:	8d 71 01             	lea    0x1(%ecx),%esi
f01003e9:	89 d8                	mov    %ebx,%eax
f01003eb:	66 c1 e8 08          	shr    $0x8,%ax
f01003ef:	89 f2                	mov    %esi,%edx
f01003f1:	ee                   	out    %al,(%dx)
f01003f2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003f7:	89 ca                	mov    %ecx,%edx
f01003f9:	ee                   	out    %al,(%dx)
f01003fa:	89 d8                	mov    %ebx,%eax
f01003fc:	89 f2                	mov    %esi,%edx
f01003fe:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100402:	5b                   	pop    %ebx
f0100403:	5e                   	pop    %esi
f0100404:	5f                   	pop    %edi
f0100405:	5d                   	pop    %ebp
f0100406:	c3                   	ret    
		if (crt_pos > 0) {
f0100407:	0f b7 05 28 be 18 f0 	movzwl 0xf018be28,%eax
f010040e:	66 85 c0             	test   %ax,%ax
f0100411:	74 be                	je     f01003d1 <cons_putc+0x11c>
			crt_pos--;
f0100413:	83 e8 01             	sub    $0x1,%eax
f0100416:	66 a3 28 be 18 f0    	mov    %ax,0xf018be28
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010041c:	0f b7 d0             	movzwl %ax,%edx
f010041f:	b1 00                	mov    $0x0,%cl
f0100421:	83 c9 20             	or     $0x20,%ecx
f0100424:	a1 2c be 18 f0       	mov    0xf018be2c,%eax
f0100429:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f010042d:	eb 93                	jmp    f01003c2 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f010042f:	66 83 05 28 be 18 f0 	addw   $0x50,0xf018be28
f0100436:	50 
f0100437:	e9 6a ff ff ff       	jmp    f01003a6 <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f010043c:	0f b7 05 28 be 18 f0 	movzwl 0xf018be28,%eax
f0100443:	8d 50 01             	lea    0x1(%eax),%edx
f0100446:	66 89 15 28 be 18 f0 	mov    %dx,0xf018be28
f010044d:	0f b7 c0             	movzwl %ax,%eax
f0100450:	8b 15 2c be 18 f0    	mov    0xf018be2c,%edx
f0100456:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f010045a:	e9 63 ff ff ff       	jmp    f01003c2 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010045f:	a1 2c be 18 f0       	mov    0xf018be2c,%eax
f0100464:	83 ec 04             	sub    $0x4,%esp
f0100467:	68 00 0f 00 00       	push   $0xf00
f010046c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100472:	52                   	push   %edx
f0100473:	50                   	push   %eax
f0100474:	e8 21 44 00 00       	call   f010489a <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100479:	8b 15 2c be 18 f0    	mov    0xf018be2c,%edx
f010047f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100485:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048b:	83 c4 10             	add    $0x10,%esp
f010048e:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100493:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100496:	39 d0                	cmp    %edx,%eax
f0100498:	75 f4                	jne    f010048e <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f010049a:	66 83 2d 28 be 18 f0 	subw   $0x50,0xf018be28
f01004a1:	50 
f01004a2:	e9 2a ff ff ff       	jmp    f01003d1 <cons_putc+0x11c>

f01004a7 <serial_intr>:
{
f01004a7:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01004ab:	80 3d 34 be 18 f0 00 	cmpb   $0x0,0xf018be34
f01004b2:	75 01                	jne    f01004b5 <serial_intr+0xe>
f01004b4:	c3                   	ret    
{
f01004b5:	55                   	push   %ebp
f01004b6:	89 e5                	mov    %esp,%ebp
f01004b8:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01004bb:	b8 3f 01 10 f0       	mov    $0xf010013f,%eax
f01004c0:	e8 98 fc ff ff       	call   f010015d <cons_intr>
}
f01004c5:	c9                   	leave  
f01004c6:	c3                   	ret    

f01004c7 <kbd_intr>:
{
f01004c7:	f3 0f 1e fb          	endbr32 
f01004cb:	55                   	push   %ebp
f01004cc:	89 e5                	mov    %esp,%ebp
f01004ce:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004d1:	b8 9c 01 10 f0       	mov    $0xf010019c,%eax
f01004d6:	e8 82 fc ff ff       	call   f010015d <cons_intr>
}
f01004db:	c9                   	leave  
f01004dc:	c3                   	ret    

f01004dd <cons_getc>:
{
f01004dd:	f3 0f 1e fb          	endbr32 
f01004e1:	55                   	push   %ebp
f01004e2:	89 e5                	mov    %esp,%ebp
f01004e4:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01004e7:	e8 bb ff ff ff       	call   f01004a7 <serial_intr>
	kbd_intr();
f01004ec:	e8 d6 ff ff ff       	call   f01004c7 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01004f1:	a1 20 be 18 f0       	mov    0xf018be20,%eax
	return 0;
f01004f6:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01004fb:	3b 05 24 be 18 f0    	cmp    0xf018be24,%eax
f0100501:	74 1c                	je     f010051f <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100503:	8d 48 01             	lea    0x1(%eax),%ecx
f0100506:	0f b6 90 20 bc 18 f0 	movzbl -0xfe743e0(%eax),%edx
			cons.rpos = 0;
f010050d:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100512:	b8 00 00 00 00       	mov    $0x0,%eax
f0100517:	0f 45 c1             	cmovne %ecx,%eax
f010051a:	a3 20 be 18 f0       	mov    %eax,0xf018be20
}
f010051f:	89 d0                	mov    %edx,%eax
f0100521:	c9                   	leave  
f0100522:	c3                   	ret    

f0100523 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100523:	f3 0f 1e fb          	endbr32 
f0100527:	55                   	push   %ebp
f0100528:	89 e5                	mov    %esp,%ebp
f010052a:	57                   	push   %edi
f010052b:	56                   	push   %esi
f010052c:	53                   	push   %ebx
f010052d:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100530:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100537:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010053e:	5a a5 
	if (*cp != 0xA55A) {
f0100540:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100547:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010054b:	0f 84 b7 00 00 00    	je     f0100608 <cons_init+0xe5>
		addr_6845 = MONO_BASE;
f0100551:	c7 05 30 be 18 f0 b4 	movl   $0x3b4,0xf018be30
f0100558:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010055b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100560:	8b 3d 30 be 18 f0    	mov    0xf018be30,%edi
f0100566:	b8 0e 00 00 00       	mov    $0xe,%eax
f010056b:	89 fa                	mov    %edi,%edx
f010056d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010056e:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100571:	89 ca                	mov    %ecx,%edx
f0100573:	ec                   	in     (%dx),%al
f0100574:	0f b6 c0             	movzbl %al,%eax
f0100577:	c1 e0 08             	shl    $0x8,%eax
f010057a:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100581:	89 fa                	mov    %edi,%edx
f0100583:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100584:	89 ca                	mov    %ecx,%edx
f0100586:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100587:	89 35 2c be 18 f0    	mov    %esi,0xf018be2c
	pos |= inb(addr_6845 + 1);
f010058d:	0f b6 c0             	movzbl %al,%eax
f0100590:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100592:	66 a3 28 be 18 f0    	mov    %ax,0xf018be28
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100598:	bb 00 00 00 00       	mov    $0x0,%ebx
f010059d:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01005a2:	89 d8                	mov    %ebx,%eax
f01005a4:	89 ca                	mov    %ecx,%edx
f01005a6:	ee                   	out    %al,(%dx)
f01005a7:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01005ac:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005b1:	89 fa                	mov    %edi,%edx
f01005b3:	ee                   	out    %al,(%dx)
f01005b4:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005b9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005be:	ee                   	out    %al,(%dx)
f01005bf:	be f9 03 00 00       	mov    $0x3f9,%esi
f01005c4:	89 d8                	mov    %ebx,%eax
f01005c6:	89 f2                	mov    %esi,%edx
f01005c8:	ee                   	out    %al,(%dx)
f01005c9:	b8 03 00 00 00       	mov    $0x3,%eax
f01005ce:	89 fa                	mov    %edi,%edx
f01005d0:	ee                   	out    %al,(%dx)
f01005d1:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005d6:	89 d8                	mov    %ebx,%eax
f01005d8:	ee                   	out    %al,(%dx)
f01005d9:	b8 01 00 00 00       	mov    $0x1,%eax
f01005de:	89 f2                	mov    %esi,%edx
f01005e0:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005e6:	ec                   	in     (%dx),%al
f01005e7:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005e9:	3c ff                	cmp    $0xff,%al
f01005eb:	0f 95 05 34 be 18 f0 	setne  0xf018be34
f01005f2:	89 ca                	mov    %ecx,%edx
f01005f4:	ec                   	in     (%dx),%al
f01005f5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005fa:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005fb:	80 fb ff             	cmp    $0xff,%bl
f01005fe:	74 23                	je     f0100623 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
}
f0100600:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100603:	5b                   	pop    %ebx
f0100604:	5e                   	pop    %esi
f0100605:	5f                   	pop    %edi
f0100606:	5d                   	pop    %ebp
f0100607:	c3                   	ret    
		*cp = was;
f0100608:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010060f:	c7 05 30 be 18 f0 d4 	movl   $0x3d4,0xf018be30
f0100616:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100619:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010061e:	e9 3d ff ff ff       	jmp    f0100560 <cons_init+0x3d>
		cprintf("Serial port does not exist!\n");
f0100623:	83 ec 0c             	sub    $0xc,%esp
f0100626:	68 19 4d 10 f0       	push   $0xf0104d19
f010062b:	e8 06 2d 00 00       	call   f0103336 <cprintf>
f0100630:	83 c4 10             	add    $0x10,%esp
}
f0100633:	eb cb                	jmp    f0100600 <cons_init+0xdd>

f0100635 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100635:	f3 0f 1e fb          	endbr32 
f0100639:	55                   	push   %ebp
f010063a:	89 e5                	mov    %esp,%ebp
f010063c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010063f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100642:	e8 6e fc ff ff       	call   f01002b5 <cons_putc>
}
f0100647:	c9                   	leave  
f0100648:	c3                   	ret    

f0100649 <getchar>:

int
getchar(void)
{
f0100649:	f3 0f 1e fb          	endbr32 
f010064d:	55                   	push   %ebp
f010064e:	89 e5                	mov    %esp,%ebp
f0100650:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100653:	e8 85 fe ff ff       	call   f01004dd <cons_getc>
f0100658:	85 c0                	test   %eax,%eax
f010065a:	74 f7                	je     f0100653 <getchar+0xa>
		/* do nothing */;
	return c;
}
f010065c:	c9                   	leave  
f010065d:	c3                   	ret    

f010065e <iscons>:

int
iscons(int fdnum)
{
f010065e:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f0100662:	b8 01 00 00 00       	mov    $0x1,%eax
f0100667:	c3                   	ret    

f0100668 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100668:	f3 0f 1e fb          	endbr32 
f010066c:	55                   	push   %ebp
f010066d:	89 e5                	mov    %esp,%ebp
f010066f:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100672:	68 60 4f 10 f0       	push   $0xf0104f60
f0100677:	68 7e 4f 10 f0       	push   $0xf0104f7e
f010067c:	68 83 4f 10 f0       	push   $0xf0104f83
f0100681:	e8 b0 2c 00 00       	call   f0103336 <cprintf>
f0100686:	83 c4 0c             	add    $0xc,%esp
f0100689:	68 10 50 10 f0       	push   $0xf0105010
f010068e:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0100693:	68 83 4f 10 f0       	push   $0xf0104f83
f0100698:	e8 99 2c 00 00       	call   f0103336 <cprintf>
f010069d:	83 c4 0c             	add    $0xc,%esp
f01006a0:	68 95 4f 10 f0       	push   $0xf0104f95
f01006a5:	68 9e 4f 10 f0       	push   $0xf0104f9e
f01006aa:	68 83 4f 10 f0       	push   $0xf0104f83
f01006af:	e8 82 2c 00 00       	call   f0103336 <cprintf>
	return 0;
}
f01006b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01006b9:	c9                   	leave  
f01006ba:	c3                   	ret    

f01006bb <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006bb:	f3 0f 1e fb          	endbr32 
f01006bf:	55                   	push   %ebp
f01006c0:	89 e5                	mov    %esp,%ebp
f01006c2:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c5:	68 a8 4f 10 f0       	push   $0xf0104fa8
f01006ca:	e8 67 2c 00 00       	call   f0103336 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006cf:	83 c4 08             	add    $0x8,%esp
f01006d2:	68 0c 00 10 00       	push   $0x10000c
f01006d7:	68 38 50 10 f0       	push   $0xf0105038
f01006dc:	e8 55 2c 00 00       	call   f0103336 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 0c 00 10 00       	push   $0x10000c
f01006e9:	68 0c 00 10 f0       	push   $0xf010000c
f01006ee:	68 60 50 10 f0       	push   $0xf0105060
f01006f3:	e8 3e 2c 00 00       	call   f0103336 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f8:	83 c4 0c             	add    $0xc,%esp
f01006fb:	68 bd 4c 10 00       	push   $0x104cbd
f0100700:	68 bd 4c 10 f0       	push   $0xf0104cbd
f0100705:	68 84 50 10 f0       	push   $0xf0105084
f010070a:	e8 27 2c 00 00       	call   f0103336 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010070f:	83 c4 0c             	add    $0xc,%esp
f0100712:	68 00 bc 18 00       	push   $0x18bc00
f0100717:	68 00 bc 18 f0       	push   $0xf018bc00
f010071c:	68 a8 50 10 f0       	push   $0xf01050a8
f0100721:	e8 10 2c 00 00       	call   f0103336 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100726:	83 c4 0c             	add    $0xc,%esp
f0100729:	68 00 cb 18 00       	push   $0x18cb00
f010072e:	68 00 cb 18 f0       	push   $0xf018cb00
f0100733:	68 cc 50 10 f0       	push   $0xf01050cc
f0100738:	e8 f9 2b 00 00       	call   f0103336 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010073d:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100740:	b8 00 cb 18 f0       	mov    $0xf018cb00,%eax
f0100745:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010074a:	c1 f8 0a             	sar    $0xa,%eax
f010074d:	50                   	push   %eax
f010074e:	68 f0 50 10 f0       	push   $0xf01050f0
f0100753:	e8 de 2b 00 00       	call   f0103336 <cprintf>
	return 0;
}
f0100758:	b8 00 00 00 00       	mov    $0x0,%eax
f010075d:	c9                   	leave  
f010075e:	c3                   	ret    

f010075f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010075f:	f3 0f 1e fb          	endbr32 
f0100763:	55                   	push   %ebp
f0100764:	89 e5                	mov    %esp,%ebp
f0100766:	53                   	push   %ebx
f0100767:	83 ec 10             	sub    $0x10,%esp
	// Your code here...
	cprintf("stack backtrace:\n");
f010076a:	68 c1 4f 10 f0       	push   $0xf0104fc1
f010076f:	e8 c2 2b 00 00       	call   f0103336 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100774:	89 eb                	mov    %ebp,%ebx
	uint32_t *ebp = (uint32_t *)read_ebp();
	while (ebp != 0) 
f0100776:	83 c4 10             	add    $0x10,%esp
f0100779:	85 db                	test   %ebx,%ebx
f010077b:	74 24                	je     f01007a1 <mon_backtrace+0x42>
        	uint32_t arg2 = ebp[3];
        	uint32_t arg3 = ebp[4];
        	uint32_t arg4 = ebp[5];
        	uint32_t arg5 = ebp[6];

        	cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",ebp, eip, arg1, arg2, arg3, arg4, arg5);
f010077d:	ff 73 18             	pushl  0x18(%ebx)
f0100780:	ff 73 14             	pushl  0x14(%ebx)
f0100783:	ff 73 10             	pushl  0x10(%ebx)
f0100786:	ff 73 0c             	pushl  0xc(%ebx)
f0100789:	ff 73 08             	pushl  0x8(%ebx)
f010078c:	ff 73 04             	pushl  0x4(%ebx)
f010078f:	53                   	push   %ebx
f0100790:	68 1c 51 10 f0       	push   $0xf010511c
f0100795:	e8 9c 2b 00 00       	call   f0103336 <cprintf>

        	ebp = (uint32_t *)*ebp;
f010079a:	8b 1b                	mov    (%ebx),%ebx
f010079c:	83 c4 20             	add    $0x20,%esp
f010079f:	eb d8                	jmp    f0100779 <mon_backtrace+0x1a>
    	}
    return 0;

}
f01007a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01007a9:	c9                   	leave  
f01007aa:	c3                   	ret    

f01007ab <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ab:	f3 0f 1e fb          	endbr32 
f01007af:	55                   	push   %ebp
f01007b0:	89 e5                	mov    %esp,%ebp
f01007b2:	57                   	push   %edi
f01007b3:	56                   	push   %esi
f01007b4:	53                   	push   %ebx
f01007b5:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007b8:	68 54 51 10 f0       	push   $0xf0105154
f01007bd:	e8 74 2b 00 00       	call   f0103336 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007c2:	c7 04 24 78 51 10 f0 	movl   $0xf0105178,(%esp)
f01007c9:	e8 68 2b 00 00       	call   f0103336 <cprintf>

	if (tf != NULL)
f01007ce:	83 c4 10             	add    $0x10,%esp
f01007d1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007d5:	0f 84 d9 00 00 00    	je     f01008b4 <monitor+0x109>
		print_trapframe(tf);
f01007db:	83 ec 0c             	sub    $0xc,%esp
f01007de:	ff 75 08             	pushl  0x8(%ebp)
f01007e1:	e8 a2 2f 00 00       	call   f0103788 <print_trapframe>
f01007e6:	83 c4 10             	add    $0x10,%esp
f01007e9:	e9 c6 00 00 00       	jmp    f01008b4 <monitor+0x109>
		while (*buf && strchr(WHITESPACE, *buf))
f01007ee:	83 ec 08             	sub    $0x8,%esp
f01007f1:	0f be c0             	movsbl %al,%eax
f01007f4:	50                   	push   %eax
f01007f5:	68 d7 4f 10 f0       	push   $0xf0104fd7
f01007fa:	e8 0a 40 00 00       	call   f0104809 <strchr>
f01007ff:	83 c4 10             	add    $0x10,%esp
f0100802:	85 c0                	test   %eax,%eax
f0100804:	74 63                	je     f0100869 <monitor+0xbe>
			*buf++ = 0;
f0100806:	c6 03 00             	movb   $0x0,(%ebx)
f0100809:	89 f7                	mov    %esi,%edi
f010080b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010080e:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100810:	0f b6 03             	movzbl (%ebx),%eax
f0100813:	84 c0                	test   %al,%al
f0100815:	75 d7                	jne    f01007ee <monitor+0x43>
	argv[argc] = 0;
f0100817:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010081e:	00 
	if (argc == 0)
f010081f:	85 f6                	test   %esi,%esi
f0100821:	0f 84 8d 00 00 00    	je     f01008b4 <monitor+0x109>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100827:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f010082c:	83 ec 08             	sub    $0x8,%esp
f010082f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100832:	ff 34 85 a0 51 10 f0 	pushl  -0xfefae60(,%eax,4)
f0100839:	ff 75 a8             	pushl  -0x58(%ebp)
f010083c:	e8 62 3f 00 00       	call   f01047a3 <strcmp>
f0100841:	83 c4 10             	add    $0x10,%esp
f0100844:	85 c0                	test   %eax,%eax
f0100846:	0f 84 8f 00 00 00    	je     f01008db <monitor+0x130>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010084c:	83 c3 01             	add    $0x1,%ebx
f010084f:	83 fb 03             	cmp    $0x3,%ebx
f0100852:	75 d8                	jne    f010082c <monitor+0x81>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100854:	83 ec 08             	sub    $0x8,%esp
f0100857:	ff 75 a8             	pushl  -0x58(%ebp)
f010085a:	68 f9 4f 10 f0       	push   $0xf0104ff9
f010085f:	e8 d2 2a 00 00       	call   f0103336 <cprintf>
	return 0;
f0100864:	83 c4 10             	add    $0x10,%esp
f0100867:	eb 4b                	jmp    f01008b4 <monitor+0x109>
		if (*buf == 0)
f0100869:	80 3b 00             	cmpb   $0x0,(%ebx)
f010086c:	74 a9                	je     f0100817 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f010086e:	83 fe 0f             	cmp    $0xf,%esi
f0100871:	74 2f                	je     f01008a2 <monitor+0xf7>
		argv[argc++] = buf;
f0100873:	8d 7e 01             	lea    0x1(%esi),%edi
f0100876:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f010087a:	0f b6 03             	movzbl (%ebx),%eax
f010087d:	84 c0                	test   %al,%al
f010087f:	74 8d                	je     f010080e <monitor+0x63>
f0100881:	83 ec 08             	sub    $0x8,%esp
f0100884:	0f be c0             	movsbl %al,%eax
f0100887:	50                   	push   %eax
f0100888:	68 d7 4f 10 f0       	push   $0xf0104fd7
f010088d:	e8 77 3f 00 00       	call   f0104809 <strchr>
f0100892:	83 c4 10             	add    $0x10,%esp
f0100895:	85 c0                	test   %eax,%eax
f0100897:	0f 85 71 ff ff ff    	jne    f010080e <monitor+0x63>
			buf++;
f010089d:	83 c3 01             	add    $0x1,%ebx
f01008a0:	eb d8                	jmp    f010087a <monitor+0xcf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008a2:	83 ec 08             	sub    $0x8,%esp
f01008a5:	6a 10                	push   $0x10
f01008a7:	68 dc 4f 10 f0       	push   $0xf0104fdc
f01008ac:	e8 85 2a 00 00       	call   f0103336 <cprintf>
			return 0;
f01008b1:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008b4:	83 ec 0c             	sub    $0xc,%esp
f01008b7:	68 d3 4f 10 f0       	push   $0xf0104fd3
f01008bc:	e8 fa 3c 00 00       	call   f01045bb <readline>
f01008c1:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008c3:	83 c4 10             	add    $0x10,%esp
f01008c6:	85 c0                	test   %eax,%eax
f01008c8:	74 ea                	je     f01008b4 <monitor+0x109>
	argv[argc] = 0;
f01008ca:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01008d1:	be 00 00 00 00       	mov    $0x0,%esi
f01008d6:	e9 35 ff ff ff       	jmp    f0100810 <monitor+0x65>
			return commands[i].func(argc, argv, tf);
f01008db:	83 ec 04             	sub    $0x4,%esp
f01008de:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008e1:	ff 75 08             	pushl  0x8(%ebp)
f01008e4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008e7:	52                   	push   %edx
f01008e8:	56                   	push   %esi
f01008e9:	ff 14 85 a8 51 10 f0 	call   *-0xfefae58(,%eax,4)
			if (runcmd(buf, tf) < 0)
f01008f0:	83 c4 10             	add    $0x10,%esp
f01008f3:	85 c0                	test   %eax,%eax
f01008f5:	79 bd                	jns    f01008b4 <monitor+0x109>
				break;
	}
}
f01008f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008fa:	5b                   	pop    %ebx
f01008fb:	5e                   	pop    %esi
f01008fc:	5f                   	pop    %edi
f01008fd:	5d                   	pop    %ebp
f01008fe:	c3                   	ret    

f01008ff <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01008ff:	55                   	push   %ebp
f0100900:	89 e5                	mov    %esp,%ebp
f0100902:	56                   	push   %esi
f0100903:	53                   	push   %ebx
f0100904:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100906:	83 ec 0c             	sub    $0xc,%esp
f0100909:	50                   	push   %eax
f010090a:	e8 b0 29 00 00       	call   f01032bf <mc146818_read>
f010090f:	89 c6                	mov    %eax,%esi
f0100911:	83 c3 01             	add    $0x1,%ebx
f0100914:	89 1c 24             	mov    %ebx,(%esp)
f0100917:	e8 a3 29 00 00       	call   f01032bf <mc146818_read>
f010091c:	c1 e0 08             	shl    $0x8,%eax
f010091f:	09 f0                	or     %esi,%eax
}
f0100921:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100924:	5b                   	pop    %ebx
f0100925:	5e                   	pop    %esi
f0100926:	5d                   	pop    %ebp
f0100927:	c3                   	ret    

f0100928 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100928:	55                   	push   %ebp
f0100929:	89 e5                	mov    %esp,%ebp
f010092b:	53                   	push   %ebx
f010092c:	83 ec 04             	sub    $0x4,%esp
        // Initialize nextfree if this is the first time.
        // 'end' is a magic symbol automatically generated by the linker,
        // which points to the end of the kernel's bss segment:
        // the first virtual address that the linker did *not* assign
        // to any kernel code or global variables.
        if (!nextfree) {
f010092f:	83 3d 3c be 18 f0 00 	cmpl   $0x0,0xf018be3c
f0100936:	74 5b                	je     f0100993 <boot_alloc+0x6b>
        // LAB 2: Your code here.

        if (n == 0)
        {
                //need to return the address of the next free page without allocating anything
                return nextfree;
f0100938:	8b 1d 3c be 18 f0    	mov    0xf018be3c,%ebx
        if (n == 0)
f010093e:	85 c0                	test   %eax,%eax
f0100940:	74 4a                	je     f010098c <boot_alloc+0x64>
        }
	else if (n > 0)
        {
                //allocates enough pages of memory to hold 'n' number of bytes
                //don't initialize the memory
                if (pages_left == 0)
f0100942:	8b 15 38 be 18 f0    	mov    0xf018be38,%edx
f0100948:	85 d2                	test   %edx,%edx
f010094a:	74 66                	je     f01009b2 <boot_alloc+0x8a>
                else if (pages_left > 0)
                {
                        //now that we have at least one page, we need to make sure there is enough space to accommodate all 'n' bytes
                        //first need to find total number of pages requested
                        //multiply the number of pages left with the size of each page, and 'n' must be <= to this value or else panic!
                        uint32_t total_bytes_left = pages_left * PGSIZE;
f010094c:	89 d1                	mov    %edx,%ecx
f010094e:	c1 e1 0c             	shl    $0xc,%ecx
                        if (n <= total_bytes_left)
f0100951:	39 c8                	cmp    %ecx,%eax
f0100953:	77 71                	ja     f01009c6 <boot_alloc+0x9e>
                        {
                                //still need to keep track of how many pages were used
                                result = nextfree;
f0100955:	8b 1d 3c be 18 f0    	mov    0xf018be3c,%ebx
                                nextfree = nextfree + ROUNDUP(n, PGSIZE);
f010095b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100960:	89 c1                	mov    %eax,%ecx
f0100962:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100968:	01 d9                	add    %ebx,%ecx
f010096a:	89 0d 3c be 18 f0    	mov    %ecx,0xf018be3c
                                uint32_t pages_used  = (nextfree - result) / PGSIZE;
f0100970:	c1 f8 0c             	sar    $0xc,%eax
                                pages_left = pages_left - pages_used;
f0100973:	29 c2                	sub    %eax,%edx
f0100975:	89 15 38 be 18 f0    	mov    %edx,0xf018be38
                                cprintf("total pages left: %u\n", pages_left);
f010097b:	83 ec 08             	sub    $0x8,%esp
f010097e:	52                   	push   %edx
f010097f:	68 7d 5a 10 f0       	push   $0xf0105a7d
f0100984:	e8 ad 29 00 00       	call   f0103336 <cprintf>
                                return result;
f0100989:	83 c4 10             	add    $0x10,%esp
                        panic("error, negative pages??");
                }
        }
	return NULL;

}
f010098c:	89 d8                	mov    %ebx,%eax
f010098e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100991:	c9                   	leave  
f0100992:	c3                   	ret    
                nextfree = ROUNDUP((char *) end, PGSIZE);
f0100993:	ba ff da 18 f0       	mov    $0xf018daff,%edx
f0100998:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010099e:	89 15 3c be 18 f0    	mov    %edx,0xf018be3c
                pages_left = npages;
f01009a4:	8b 15 08 cb 18 f0    	mov    0xf018cb08,%edx
f01009aa:	89 15 38 be 18 f0    	mov    %edx,0xf018be38
f01009b0:	eb 86                	jmp    f0100938 <boot_alloc+0x10>
                        panic("no more free pages left! n > 0");
f01009b2:	83 ec 04             	sub    $0x4,%esp
f01009b5:	68 c4 51 10 f0       	push   $0xf01051c4
f01009ba:	6a 79                	push   $0x79
f01009bc:	68 71 5a 10 f0       	push   $0xf0105a71
f01009c1:	e8 de f6 ff ff       	call   f01000a4 <_panic>
                                panic("pages left, but 'n' tried allocating too much!");
f01009c6:	83 ec 04             	sub    $0x4,%esp
f01009c9:	68 e4 51 10 f0       	push   $0xf01051e4
f01009ce:	68 8d 00 00 00       	push   $0x8d
f01009d3:	68 71 5a 10 f0       	push   $0xf0105a71
f01009d8:	e8 c7 f6 ff ff       	call   f01000a4 <_panic>

f01009dd <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009dd:	89 d1                	mov    %edx,%ecx
f01009df:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009e2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009e5:	a8 01                	test   $0x1,%al
f01009e7:	74 51                	je     f0100a3a <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009e9:	89 c1                	mov    %eax,%ecx
f01009eb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009f1:	c1 e8 0c             	shr    $0xc,%eax
f01009f4:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f01009fa:	73 23                	jae    f0100a1f <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f01009fc:	c1 ea 0c             	shr    $0xc,%edx
f01009ff:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a05:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a0c:	89 d0                	mov    %edx,%eax
f0100a0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a13:	f6 c2 01             	test   $0x1,%dl
f0100a16:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a1b:	0f 44 c2             	cmove  %edx,%eax
f0100a1e:	c3                   	ret    
{
f0100a1f:	55                   	push   %ebp
f0100a20:	89 e5                	mov    %esp,%ebp
f0100a22:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a25:	51                   	push   %ecx
f0100a26:	68 14 52 10 f0       	push   $0xf0105214
f0100a2b:	68 cf 03 00 00       	push   $0x3cf
f0100a30:	68 71 5a 10 f0       	push   $0xf0105a71
f0100a35:	e8 6a f6 ff ff       	call   f01000a4 <_panic>
		return ~0;
f0100a3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100a3f:	c3                   	ret    

f0100a40 <check_page_free_list>:
{
f0100a40:	55                   	push   %ebp
f0100a41:	89 e5                	mov    %esp,%ebp
f0100a43:	57                   	push   %edi
f0100a44:	56                   	push   %esi
f0100a45:	53                   	push   %ebx
f0100a46:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a49:	84 c0                	test   %al,%al
f0100a4b:	0f 85 52 02 00 00    	jne    f0100ca3 <check_page_free_list+0x263>
	if (!page_free_list)
f0100a51:	83 3d 44 be 18 f0 00 	cmpl   $0x0,0xf018be44
f0100a58:	74 0d                	je     f0100a67 <check_page_free_list+0x27>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a5a:	be 00 04 00 00       	mov    $0x400,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a5f:	8b 1d 44 be 18 f0    	mov    0xf018be44,%ebx
f0100a65:	eb 2b                	jmp    f0100a92 <check_page_free_list+0x52>
		panic("'page_free_list' is a null pointer!");
f0100a67:	83 ec 04             	sub    $0x4,%esp
f0100a6a:	68 38 52 10 f0       	push   $0xf0105238
f0100a6f:	68 0b 03 00 00       	push   $0x30b
f0100a74:	68 71 5a 10 f0       	push   $0xf0105a71
f0100a79:	e8 26 f6 ff ff       	call   f01000a4 <_panic>
f0100a7e:	50                   	push   %eax
f0100a7f:	68 14 52 10 f0       	push   $0xf0105214
f0100a84:	6a 56                	push   $0x56
f0100a86:	68 93 5a 10 f0       	push   $0xf0105a93
f0100a8b:	e8 14 f6 ff ff       	call   f01000a4 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a90:	8b 1b                	mov    (%ebx),%ebx
f0100a92:	85 db                	test   %ebx,%ebx
f0100a94:	74 41                	je     f0100ad7 <check_page_free_list+0x97>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a96:	89 d8                	mov    %ebx,%eax
f0100a98:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0100a9e:	c1 f8 03             	sar    $0x3,%eax
f0100aa1:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100aa4:	89 c2                	mov    %eax,%edx
f0100aa6:	c1 ea 16             	shr    $0x16,%edx
f0100aa9:	39 f2                	cmp    %esi,%edx
f0100aab:	73 e3                	jae    f0100a90 <check_page_free_list+0x50>
	if (PGNUM(pa) >= npages)
f0100aad:	89 c2                	mov    %eax,%edx
f0100aaf:	c1 ea 0c             	shr    $0xc,%edx
f0100ab2:	3b 15 08 cb 18 f0    	cmp    0xf018cb08,%edx
f0100ab8:	73 c4                	jae    f0100a7e <check_page_free_list+0x3e>
			memset(page2kva(pp), 0x97, 128);
f0100aba:	83 ec 04             	sub    $0x4,%esp
f0100abd:	68 80 00 00 00       	push   $0x80
f0100ac2:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100ac7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100acc:	50                   	push   %eax
f0100acd:	e8 7c 3d 00 00       	call   f010484e <memset>
f0100ad2:	83 c4 10             	add    $0x10,%esp
f0100ad5:	eb b9                	jmp    f0100a90 <check_page_free_list+0x50>
	first_free_page = (char *) boot_alloc(0);
f0100ad7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100adc:	e8 47 fe ff ff       	call   f0100928 <boot_alloc>
f0100ae1:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ae4:	8b 15 44 be 18 f0    	mov    0xf018be44,%edx
		assert(pp >= pages);
f0100aea:	8b 0d 10 cb 18 f0    	mov    0xf018cb10,%ecx
		assert(pp < pages + npages);
f0100af0:	a1 08 cb 18 f0       	mov    0xf018cb08,%eax
f0100af5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100af8:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100afb:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b00:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b03:	e9 c8 00 00 00       	jmp    f0100bd0 <check_page_free_list+0x190>
		assert(pp >= pages);
f0100b08:	68 a1 5a 10 f0       	push   $0xf0105aa1
f0100b0d:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100b12:	68 25 03 00 00       	push   $0x325
f0100b17:	68 71 5a 10 f0       	push   $0xf0105a71
f0100b1c:	e8 83 f5 ff ff       	call   f01000a4 <_panic>
		assert(pp < pages + npages);
f0100b21:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0100b26:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100b2b:	68 26 03 00 00       	push   $0x326
f0100b30:	68 71 5a 10 f0       	push   $0xf0105a71
f0100b35:	e8 6a f5 ff ff       	call   f01000a4 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b3a:	68 5c 52 10 f0       	push   $0xf010525c
f0100b3f:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100b44:	68 27 03 00 00       	push   $0x327
f0100b49:	68 71 5a 10 f0       	push   $0xf0105a71
f0100b4e:	e8 51 f5 ff ff       	call   f01000a4 <_panic>
		assert(page2pa(pp) != 0);
f0100b53:	68 d6 5a 10 f0       	push   $0xf0105ad6
f0100b58:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100b5d:	68 2a 03 00 00       	push   $0x32a
f0100b62:	68 71 5a 10 f0       	push   $0xf0105a71
f0100b67:	e8 38 f5 ff ff       	call   f01000a4 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b6c:	68 e7 5a 10 f0       	push   $0xf0105ae7
f0100b71:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100b76:	68 2b 03 00 00       	push   $0x32b
f0100b7b:	68 71 5a 10 f0       	push   $0xf0105a71
f0100b80:	e8 1f f5 ff ff       	call   f01000a4 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b85:	68 90 52 10 f0       	push   $0xf0105290
f0100b8a:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100b8f:	68 2c 03 00 00       	push   $0x32c
f0100b94:	68 71 5a 10 f0       	push   $0xf0105a71
f0100b99:	e8 06 f5 ff ff       	call   f01000a4 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b9e:	68 00 5b 10 f0       	push   $0xf0105b00
f0100ba3:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100ba8:	68 2d 03 00 00       	push   $0x32d
f0100bad:	68 71 5a 10 f0       	push   $0xf0105a71
f0100bb2:	e8 ed f4 ff ff       	call   f01000a4 <_panic>
	if (PGNUM(pa) >= npages)
f0100bb7:	89 c3                	mov    %eax,%ebx
f0100bb9:	c1 eb 0c             	shr    $0xc,%ebx
f0100bbc:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100bbf:	76 65                	jbe    f0100c26 <check_page_free_list+0x1e6>
	return (void *)(pa + KERNBASE);
f0100bc1:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bc6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100bc9:	77 6d                	ja     f0100c38 <check_page_free_list+0x1f8>
			++nfree_extmem;
f0100bcb:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bce:	8b 12                	mov    (%edx),%edx
f0100bd0:	85 d2                	test   %edx,%edx
f0100bd2:	74 7d                	je     f0100c51 <check_page_free_list+0x211>
		assert(pp >= pages);
f0100bd4:	39 d1                	cmp    %edx,%ecx
f0100bd6:	0f 87 2c ff ff ff    	ja     f0100b08 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100bdc:	39 d6                	cmp    %edx,%esi
f0100bde:	0f 86 3d ff ff ff    	jbe    f0100b21 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100be4:	89 d0                	mov    %edx,%eax
f0100be6:	29 c8                	sub    %ecx,%eax
f0100be8:	a8 07                	test   $0x7,%al
f0100bea:	0f 85 4a ff ff ff    	jne    f0100b3a <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100bf0:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100bf3:	c1 e0 0c             	shl    $0xc,%eax
f0100bf6:	0f 84 57 ff ff ff    	je     f0100b53 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bfc:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c01:	0f 84 65 ff ff ff    	je     f0100b6c <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c07:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c0c:	0f 84 73 ff ff ff    	je     f0100b85 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c12:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c17:	74 85                	je     f0100b9e <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c19:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c1e:	77 97                	ja     f0100bb7 <check_page_free_list+0x177>
			++nfree_basemem;
f0100c20:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f0100c24:	eb a8                	jmp    f0100bce <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c26:	50                   	push   %eax
f0100c27:	68 14 52 10 f0       	push   $0xf0105214
f0100c2c:	6a 56                	push   $0x56
f0100c2e:	68 93 5a 10 f0       	push   $0xf0105a93
f0100c33:	e8 6c f4 ff ff       	call   f01000a4 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c38:	68 b4 52 10 f0       	push   $0xf01052b4
f0100c3d:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100c42:	68 2e 03 00 00       	push   $0x32e
f0100c47:	68 71 5a 10 f0       	push   $0xf0105a71
f0100c4c:	e8 53 f4 ff ff       	call   f01000a4 <_panic>
f0100c51:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100c54:	85 db                	test   %ebx,%ebx
f0100c56:	7e 19                	jle    f0100c71 <check_page_free_list+0x231>
	assert(nfree_extmem > 0);
f0100c58:	85 ff                	test   %edi,%edi
f0100c5a:	7e 2e                	jle    f0100c8a <check_page_free_list+0x24a>
	cprintf("check_page_free_list() succeeded!\n");
f0100c5c:	83 ec 0c             	sub    $0xc,%esp
f0100c5f:	68 fc 52 10 f0       	push   $0xf01052fc
f0100c64:	e8 cd 26 00 00       	call   f0103336 <cprintf>
}
f0100c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c6c:	5b                   	pop    %ebx
f0100c6d:	5e                   	pop    %esi
f0100c6e:	5f                   	pop    %edi
f0100c6f:	5d                   	pop    %ebp
f0100c70:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100c71:	68 1a 5b 10 f0       	push   $0xf0105b1a
f0100c76:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100c7b:	68 36 03 00 00       	push   $0x336
f0100c80:	68 71 5a 10 f0       	push   $0xf0105a71
f0100c85:	e8 1a f4 ff ff       	call   f01000a4 <_panic>
	assert(nfree_extmem > 0);
f0100c8a:	68 2c 5b 10 f0       	push   $0xf0105b2c
f0100c8f:	68 ad 5a 10 f0       	push   $0xf0105aad
f0100c94:	68 37 03 00 00       	push   $0x337
f0100c99:	68 71 5a 10 f0       	push   $0xf0105a71
f0100c9e:	e8 01 f4 ff ff       	call   f01000a4 <_panic>
	if (!page_free_list)
f0100ca3:	a1 44 be 18 f0       	mov    0xf018be44,%eax
f0100ca8:	85 c0                	test   %eax,%eax
f0100caa:	0f 84 b7 fd ff ff    	je     f0100a67 <check_page_free_list+0x27>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100cb0:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100cb3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100cb6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cb9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100cbc:	89 c2                	mov    %eax,%edx
f0100cbe:	2b 15 10 cb 18 f0    	sub    0xf018cb10,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100cc4:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100cca:	0f 95 c2             	setne  %dl
f0100ccd:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100cd0:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100cd4:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100cd6:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cda:	8b 00                	mov    (%eax),%eax
f0100cdc:	85 c0                	test   %eax,%eax
f0100cde:	75 dc                	jne    f0100cbc <check_page_free_list+0x27c>
		*tp[1] = 0;
f0100ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ce3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ce9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cef:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cf1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cf4:	a3 44 be 18 f0       	mov    %eax,0xf018be44
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cf9:	be 01 00 00 00       	mov    $0x1,%esi
f0100cfe:	e9 5c fd ff ff       	jmp    f0100a5f <check_page_free_list+0x1f>

f0100d03 <page_init>:
{
f0100d03:	f3 0f 1e fb          	endbr32 
f0100d07:	55                   	push   %ebp
f0100d08:	89 e5                	mov    %esp,%ebp
f0100d0a:	56                   	push   %esi
f0100d0b:	53                   	push   %ebx
        pages[0].pp_ref = 1; //now there's at least one reference to this memory location, so we shouldn't touch it until the application frees it
f0100d0c:	a1 10 cb 18 f0       	mov    0xf018cb10,%eax
f0100d11:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
        pages[0].pp_link = NULL;
f0100d17:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        for (i = 1; i < npages; i++)
f0100d1d:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100d22:	eb 28                	jmp    f0100d4c <page_init+0x49>
f0100d24:	8d b3 60 ff 0f 00    	lea    0xfff60(%ebx),%esi
f0100d2a:	c1 e6 0c             	shl    $0xc,%esi
                else if ((IO_hole_start_address <= current_physical_address ) && (current_physical_address < IO_hole_end_address))
f0100d2d:	81 fe ff ff 05 00    	cmp    $0x5ffff,%esi
f0100d33:	77 55                	ja     f0100d8a <page_init+0x87>
                        pages[i].pp_ref = 1;
f0100d35:	a1 10 cb 18 f0       	mov    0xf018cb10,%eax
f0100d3a:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100d3d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100d43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        for (i = 1; i < npages; i++)
f0100d49:	83 c3 01             	add    $0x1,%ebx
f0100d4c:	39 1d 08 cb 18 f0    	cmp    %ebx,0xf018cb08
f0100d52:	0f 86 aa 00 00 00    	jbe    f0100e02 <page_init+0xff>
                if (i < npages_basemem)
f0100d58:	39 1d 48 be 18 f0    	cmp    %ebx,0xf018be48
f0100d5e:	76 c4                	jbe    f0100d24 <page_init+0x21>
f0100d60:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
                        pages[i].pp_ref = 0;
f0100d67:	89 c2                	mov    %eax,%edx
f0100d69:	03 15 10 cb 18 f0    	add    0xf018cb10,%edx
f0100d6f:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
                        pages[i].pp_link = page_free_list;
f0100d75:	8b 0d 44 be 18 f0    	mov    0xf018be44,%ecx
f0100d7b:	89 0a                	mov    %ecx,(%edx)
                        page_free_list = &pages[i];
f0100d7d:	03 05 10 cb 18 f0    	add    0xf018cb10,%eax
f0100d83:	a3 44 be 18 f0       	mov    %eax,0xf018be44
f0100d88:	eb bf                	jmp    f0100d49 <page_init+0x46>
                else if (current_physical_address < PADDR(boot_alloc(0)))
f0100d8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d8f:	e8 94 fb ff ff       	call   f0100928 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100d94:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d99:	76 25                	jbe    f0100dc0 <page_init+0xbd>
	return (physaddr_t)kva - KERNBASE;
f0100d9b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100da0:	81 c6 00 00 0a 00    	add    $0xa0000,%esi
f0100da6:	39 f0                	cmp    %esi,%eax
f0100da8:	76 2b                	jbe    f0100dd5 <page_init+0xd2>
                        pages[i].pp_ref = 1;
f0100daa:	a1 10 cb 18 f0       	mov    0xf018cb10,%eax
f0100daf:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100db2:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100db8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100dbe:	eb 89                	jmp    f0100d49 <page_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dc0:	50                   	push   %eax
f0100dc1:	68 20 53 10 f0       	push   $0xf0105320
f0100dc6:	68 73 01 00 00       	push   $0x173
f0100dcb:	68 71 5a 10 f0       	push   $0xf0105a71
f0100dd0:	e8 cf f2 ff ff       	call   f01000a4 <_panic>
f0100dd5:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
                        pages[i].pp_ref = 0;
f0100ddc:	89 c2                	mov    %eax,%edx
f0100dde:	03 15 10 cb 18 f0    	add    0xf018cb10,%edx
f0100de4:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
                        pages[i].pp_link = page_free_list;
f0100dea:	8b 0d 44 be 18 f0    	mov    0xf018be44,%ecx
f0100df0:	89 0a                	mov    %ecx,(%edx)
                        page_free_list = &pages[i];
f0100df2:	03 05 10 cb 18 f0    	add    0xf018cb10,%eax
f0100df8:	a3 44 be 18 f0       	mov    %eax,0xf018be44
f0100dfd:	e9 47 ff ff ff       	jmp    f0100d49 <page_init+0x46>
}
f0100e02:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e05:	5b                   	pop    %ebx
f0100e06:	5e                   	pop    %esi
f0100e07:	5d                   	pop    %ebp
f0100e08:	c3                   	ret    

f0100e09 <page_alloc>:
{
f0100e09:	f3 0f 1e fb          	endbr32 
f0100e0d:	55                   	push   %ebp
f0100e0e:	89 e5                	mov    %esp,%ebp
f0100e10:	53                   	push   %ebx
f0100e11:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list == NULL)
f0100e14:	8b 1d 44 be 18 f0    	mov    0xf018be44,%ebx
f0100e1a:	85 db                	test   %ebx,%ebx
f0100e1c:	74 13                	je     f0100e31 <page_alloc+0x28>
        page_free_list = page_free_list->pp_link;
f0100e1e:	8b 03                	mov    (%ebx),%eax
f0100e20:	a3 44 be 18 f0       	mov    %eax,0xf018be44
        returnThisPointer->pp_link = NULL;
f0100e25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        if (alloc_flags & ALLOC_ZERO)
f0100e2b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e2f:	75 07                	jne    f0100e38 <page_alloc+0x2f>
}
f0100e31:	89 d8                	mov    %ebx,%eax
f0100e33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e36:	c9                   	leave  
f0100e37:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100e38:	89 d8                	mov    %ebx,%eax
f0100e3a:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0100e40:	c1 f8 03             	sar    $0x3,%eax
f0100e43:	89 c2                	mov    %eax,%edx
f0100e45:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100e48:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100e4d:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0100e53:	73 1b                	jae    f0100e70 <page_alloc+0x67>
                memset(page2kva(returnThisPointer), '\0', PGSIZE);
f0100e55:	83 ec 04             	sub    $0x4,%esp
f0100e58:	68 00 10 00 00       	push   $0x1000
f0100e5d:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100e5f:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100e65:	52                   	push   %edx
f0100e66:	e8 e3 39 00 00       	call   f010484e <memset>
f0100e6b:	83 c4 10             	add    $0x10,%esp
f0100e6e:	eb c1                	jmp    f0100e31 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e70:	52                   	push   %edx
f0100e71:	68 14 52 10 f0       	push   $0xf0105214
f0100e76:	6a 56                	push   $0x56
f0100e78:	68 93 5a 10 f0       	push   $0xf0105a93
f0100e7d:	e8 22 f2 ff ff       	call   f01000a4 <_panic>

f0100e82 <page_free>:
{
f0100e82:	f3 0f 1e fb          	endbr32 
f0100e86:	55                   	push   %ebp
f0100e87:	89 e5                	mov    %esp,%ebp
f0100e89:	83 ec 08             	sub    $0x8,%esp
f0100e8c:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0)
f0100e8f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e94:	75 14                	jne    f0100eaa <page_free+0x28>
        if (pp->pp_link != NULL)
f0100e96:	83 38 00             	cmpl   $0x0,(%eax)
f0100e99:	75 26                	jne    f0100ec1 <page_free+0x3f>
        pp->pp_link = page_free_list; //point new free page to head of linked list that has all free pages
f0100e9b:	8b 15 44 be 18 f0    	mov    0xf018be44,%edx
f0100ea1:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f0100ea3:	a3 44 be 18 f0       	mov    %eax,0xf018be44
}
f0100ea8:	c9                   	leave  
f0100ea9:	c3                   	ret    
                panic("inside page_free() -> there are references to this page, so cannot free!!");
f0100eaa:	83 ec 04             	sub    $0x4,%esp
f0100ead:	68 44 53 10 f0       	push   $0xf0105344
f0100eb2:	68 b1 01 00 00       	push   $0x1b1
f0100eb7:	68 71 5a 10 f0       	push   $0xf0105a71
f0100ebc:	e8 e3 f1 ff ff       	call   f01000a4 <_panic>
                panic("inside page_free -> pp->pp_link is NOT NULL!");
f0100ec1:	83 ec 04             	sub    $0x4,%esp
f0100ec4:	68 90 53 10 f0       	push   $0xf0105390
f0100ec9:	68 b5 01 00 00       	push   $0x1b5
f0100ece:	68 71 5a 10 f0       	push   $0xf0105a71
f0100ed3:	e8 cc f1 ff ff       	call   f01000a4 <_panic>

f0100ed8 <page_decref>:
{
f0100ed8:	f3 0f 1e fb          	endbr32 
f0100edc:	55                   	push   %ebp
f0100edd:	89 e5                	mov    %esp,%ebp
f0100edf:	83 ec 08             	sub    $0x8,%esp
f0100ee2:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100ee5:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100ee9:	83 e8 01             	sub    $0x1,%eax
f0100eec:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100ef0:	66 85 c0             	test   %ax,%ax
f0100ef3:	74 02                	je     f0100ef7 <page_decref+0x1f>
}
f0100ef5:	c9                   	leave  
f0100ef6:	c3                   	ret    
		page_free(pp);
f0100ef7:	83 ec 0c             	sub    $0xc,%esp
f0100efa:	52                   	push   %edx
f0100efb:	e8 82 ff ff ff       	call   f0100e82 <page_free>
f0100f00:	83 c4 10             	add    $0x10,%esp
}
f0100f03:	eb f0                	jmp    f0100ef5 <page_decref+0x1d>

f0100f05 <pgdir_walk>:
{
f0100f05:	f3 0f 1e fb          	endbr32 
f0100f09:	55                   	push   %ebp
f0100f0a:	89 e5                	mov    %esp,%ebp
f0100f0c:	57                   	push   %edi
f0100f0d:	56                   	push   %esi
f0100f0e:	53                   	push   %ebx
f0100f0f:	83 ec 0c             	sub    $0xc,%esp
f0100f12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32_t page_directory_index = (uint32_t) PDX(va);
f0100f15:	89 de                	mov    %ebx,%esi
f0100f17:	c1 ee 16             	shr    $0x16,%esi
        if (((pgdir[page_directory_index] & PTE_P) == 0) && (create == 0 )) // 0 if entry can NOT be used
f0100f1a:	c1 e6 02             	shl    $0x2,%esi
f0100f1d:	03 75 08             	add    0x8(%ebp),%esi
f0100f20:	8b 06                	mov    (%esi),%eax
f0100f22:	89 c1                	mov    %eax,%ecx
f0100f24:	83 e1 01             	and    $0x1,%ecx
f0100f27:	0f 94 c2             	sete   %dl
f0100f2a:	89 d7                	mov    %edx,%edi
f0100f2c:	8b 55 10             	mov    0x10(%ebp),%edx
f0100f2f:	09 ca                	or     %ecx,%edx
f0100f31:	0f 84 ee 00 00 00    	je     f0101025 <pgdir_walk+0x120>
        else if (((pgdir[page_directory_index] & PTE_P) == 0) && (create == 1 )) //doesn't exist and you want to create it
f0100f37:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0100f3b:	75 06                	jne    f0100f43 <pgdir_walk+0x3e>
f0100f3d:	89 fa                	mov    %edi,%edx
f0100f3f:	84 d2                	test   %dl,%dl
f0100f41:	75 33                	jne    f0100f76 <pgdir_walk+0x71>
        else if (((pgdir[page_directory_index] & PTE_P) == 1))
f0100f43:	85 c9                	test   %ecx,%ecx
f0100f45:	0f 84 9d 00 00 00    	je     f0100fe8 <pgdir_walk+0xe3>
                return &(((pte_t *) KADDR(pgdir[PDX(va)] & ~0xFFF))[PTX(va)]);
f0100f4b:	89 c2                	mov    %eax,%edx
f0100f4d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0100f53:	c1 e8 0c             	shr    $0xc,%eax
f0100f56:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0100f5c:	73 75                	jae    f0100fd3 <pgdir_walk+0xce>
f0100f5e:	c1 eb 0a             	shr    $0xa,%ebx
f0100f61:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f67:	8d 84 1a 00 00 00 f0 	lea    -0x10000000(%edx,%ebx,1),%eax
}
f0100f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f71:	5b                   	pop    %ebx
f0100f72:	5e                   	pop    %esi
f0100f73:	5f                   	pop    %edi
f0100f74:	5d                   	pop    %ebp
f0100f75:	c3                   	ret    
                struct PageInfo *newPage = page_alloc(ALLOC_ZERO); //**********NOTE: ALLOC_ZERO IS NOT ZERO!!! ITS A VALUE OF 1 BECAUSE ITS A FLAG!!
f0100f76:	83 ec 0c             	sub    $0xc,%esp
f0100f79:	6a 01                	push   $0x1
f0100f7b:	e8 89 fe ff ff       	call   f0100e09 <page_alloc>
                if (newPage == NULL)
f0100f80:	83 c4 10             	add    $0x10,%esp
f0100f83:	85 c0                	test   %eax,%eax
f0100f85:	74 e7                	je     f0100f6e <pgdir_walk+0x69>
                newPage->pp_ref += 1;
f0100f87:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0100f8c:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0100f92:	c1 f8 03             	sar    $0x3,%eax
f0100f95:	c1 e0 0c             	shl    $0xc,%eax
                physaddr_t phys_addr_of_newPage_struct = page2pa(newPage) | PTE_P | PTE_W | PTE_U; //was getting asserting error so added PTE_U
f0100f98:	89 c2                	mov    %eax,%edx
f0100f9a:	83 ca 07             	or     $0x7,%edx
f0100f9d:	89 16                	mov    %edx,(%esi)
	if (PGNUM(pa) >= npages)
f0100f9f:	89 c2                	mov    %eax,%edx
f0100fa1:	c1 ea 0c             	shr    $0xc,%edx
f0100fa4:	3b 15 08 cb 18 f0    	cmp    0xf018cb08,%edx
f0100faa:	73 12                	jae    f0100fbe <pgdir_walk+0xb9>
                return &(((pte_t *) KADDR(pgdir[PDX(va)] & ~0xFFF))[PTX(va)]); //ignore the last 0xFFF(12) permission bits (figure 5-10)
f0100fac:	c1 eb 0a             	shr    $0xa,%ebx
f0100faf:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100fb5:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100fbc:	eb b0                	jmp    f0100f6e <pgdir_walk+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbe:	50                   	push   %eax
f0100fbf:	68 14 52 10 f0       	push   $0xf0105214
f0100fc4:	68 f7 01 00 00       	push   $0x1f7
f0100fc9:	68 71 5a 10 f0       	push   $0xf0105a71
f0100fce:	e8 d1 f0 ff ff       	call   f01000a4 <_panic>
f0100fd3:	52                   	push   %edx
f0100fd4:	68 14 52 10 f0       	push   $0xf0105214
f0100fd9:	68 fd 01 00 00       	push   $0x1fd
f0100fde:	68 71 5a 10 f0       	push   $0xf0105a71
f0100fe3:	e8 bc f0 ff ff       	call   f01000a4 <_panic>
        return &(((pte_t *) KADDR(pgdir[PDX(va)] & ~0xFFF))[PTX(va)]);
f0100fe8:	89 c2                	mov    %eax,%edx
f0100fea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0100ff0:	c1 e8 0c             	shr    $0xc,%eax
f0100ff3:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0100ff9:	73 15                	jae    f0101010 <pgdir_walk+0x10b>
f0100ffb:	c1 eb 0a             	shr    $0xa,%ebx
f0100ffe:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101004:	8d 84 1a 00 00 00 f0 	lea    -0x10000000(%edx,%ebx,1),%eax
f010100b:	e9 5e ff ff ff       	jmp    f0100f6e <pgdir_walk+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101010:	52                   	push   %edx
f0101011:	68 14 52 10 f0       	push   $0xf0105214
f0101016:	68 00 02 00 00       	push   $0x200
f010101b:	68 71 5a 10 f0       	push   $0xf0105a71
f0101020:	e8 7f f0 ff ff       	call   f01000a4 <_panic>
                return NULL;
f0101025:	b8 00 00 00 00       	mov    $0x0,%eax
f010102a:	e9 3f ff ff ff       	jmp    f0100f6e <pgdir_walk+0x69>

f010102f <boot_map_region>:
{
f010102f:	55                   	push   %ebp
f0101030:	89 e5                	mov    %esp,%ebp
f0101032:	57                   	push   %edi
f0101033:	56                   	push   %esi
f0101034:	53                   	push   %ebx
f0101035:	83 ec 1c             	sub    $0x1c,%esp
f0101038:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010103b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101041:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f0101044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int current_page = 0; current_page < size/PGSIZE; current_page++)
f0101047:	89 d6                	mov    %edx,%esi
f0101049:	8b 7d 08             	mov    0x8(%ebp),%edi
f010104c:	29 d7                	sub    %edx,%edi
f010104e:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101051:	74 24                	je     f0101077 <boot_map_region+0x48>
f0101053:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
                pte_t *pte_ptr = pgdir_walk(pgdir, current_virtual_address, create);
f0101056:	83 ec 04             	sub    $0x4,%esp
f0101059:	6a 01                	push   $0x1
f010105b:	56                   	push   %esi
f010105c:	ff 75 e0             	pushl  -0x20(%ebp)
f010105f:	e8 a1 fe ff ff       	call   f0100f05 <pgdir_walk>
                *pte_ptr = current_physical_address | perm | PTE_P;
f0101064:	0b 5d 0c             	or     0xc(%ebp),%ebx
f0101067:	83 cb 01             	or     $0x1,%ebx
f010106a:	89 18                	mov    %ebx,(%eax)
f010106c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101072:	83 c4 10             	add    $0x10,%esp
f0101075:	eb d7                	jmp    f010104e <boot_map_region+0x1f>
}
f0101077:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010107a:	5b                   	pop    %ebx
f010107b:	5e                   	pop    %esi
f010107c:	5f                   	pop    %edi
f010107d:	5d                   	pop    %ebp
f010107e:	c3                   	ret    

f010107f <page_lookup>:
{
f010107f:	f3 0f 1e fb          	endbr32 
f0101083:	55                   	push   %ebp
f0101084:	89 e5                	mov    %esp,%ebp
f0101086:	53                   	push   %ebx
f0101087:	83 ec 08             	sub    $0x8,%esp
f010108a:	8b 5d 10             	mov    0x10(%ebp),%ebx
        pte_t* page_table_entry_ptr = pgdir_walk(pgdir, va, create);
f010108d:	6a 00                	push   $0x0
f010108f:	ff 75 0c             	pushl  0xc(%ebp)
f0101092:	ff 75 08             	pushl  0x8(%ebp)
f0101095:	e8 6b fe ff ff       	call   f0100f05 <pgdir_walk>
        if (page_table_entry_ptr == NULL)  //NOTE: page_table_entry_ptr CAN be NULL because there was no memory left to allocate!
f010109a:	83 c4 10             	add    $0x10,%esp
f010109d:	85 c0                	test   %eax,%eax
f010109f:	74 3c                	je     f01010dd <page_lookup+0x5e>
        if (((*page_table_entry_ptr) & PTE_P) == 0)
f01010a1:	8b 10                	mov    (%eax),%edx
f01010a3:	f6 c2 01             	test   $0x1,%dl
f01010a6:	74 39                	je     f01010e1 <page_lookup+0x62>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010a8:	c1 ea 0c             	shr    $0xc,%edx
f01010ab:	3b 15 08 cb 18 f0    	cmp    0xf018cb08,%edx
f01010b1:	73 16                	jae    f01010c9 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01010b3:	8b 0d 10 cb 18 f0    	mov    0xf018cb10,%ecx
f01010b9:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
        if (pte_store != 0)
f01010bc:	85 db                	test   %ebx,%ebx
f01010be:	74 02                	je     f01010c2 <page_lookup+0x43>
                *pte_store = page_table_entry_ptr; //you want to modify the incoming pointer, not the value at the address
f01010c0:	89 03                	mov    %eax,(%ebx)
}
f01010c2:	89 d0                	mov    %edx,%eax
f01010c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010c7:	c9                   	leave  
f01010c8:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01010c9:	83 ec 04             	sub    $0x4,%esp
f01010cc:	68 c0 53 10 f0       	push   $0xf01053c0
f01010d1:	6a 4f                	push   $0x4f
f01010d3:	68 93 5a 10 f0       	push   $0xf0105a93
f01010d8:	e8 c7 ef ff ff       	call   f01000a4 <_panic>
                return NULL;
f01010dd:	89 c2                	mov    %eax,%edx
f01010df:	eb e1                	jmp    f01010c2 <page_lookup+0x43>
                return NULL;
f01010e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01010e6:	eb da                	jmp    f01010c2 <page_lookup+0x43>

f01010e8 <page_remove>:
{
f01010e8:	f3 0f 1e fb          	endbr32 
f01010ec:	55                   	push   %ebp
f01010ed:	89 e5                	mov    %esp,%ebp
f01010ef:	53                   	push   %ebx
f01010f0:	83 ec 18             	sub    $0x18,%esp
f01010f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        struct PageInfo *pagey = page_lookup(pgdir, va, &pte);
f01010f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010f9:	50                   	push   %eax
f01010fa:	53                   	push   %ebx
f01010fb:	ff 75 08             	pushl  0x8(%ebp)
f01010fe:	e8 7c ff ff ff       	call   f010107f <page_lookup>
        if (pagey == NULL)
f0101103:	83 c4 10             	add    $0x10,%esp
f0101106:	85 c0                	test   %eax,%eax
f0101108:	74 18                	je     f0101122 <page_remove+0x3a>
        *pte = 0;
f010110a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010110d:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
        page_decref(pagey);
f0101113:	83 ec 0c             	sub    $0xc,%esp
f0101116:	50                   	push   %eax
f0101117:	e8 bc fd ff ff       	call   f0100ed8 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010111c:	0f 01 3b             	invlpg (%ebx)
f010111f:	83 c4 10             	add    $0x10,%esp
}
f0101122:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101125:	c9                   	leave  
f0101126:	c3                   	ret    

f0101127 <page_insert>:
{
f0101127:	f3 0f 1e fb          	endbr32 
f010112b:	55                   	push   %ebp
f010112c:	89 e5                	mov    %esp,%ebp
f010112e:	57                   	push   %edi
f010112f:	56                   	push   %esi
f0101130:	53                   	push   %ebx
f0101131:	83 ec 10             	sub    $0x10,%esp
f0101134:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101137:	8b 7d 10             	mov    0x10(%ebp),%edi
        pte_t *pte = pgdir_walk(pgdir, va, create);
f010113a:	6a 01                	push   $0x1
f010113c:	57                   	push   %edi
f010113d:	ff 75 08             	pushl  0x8(%ebp)
f0101140:	e8 c0 fd ff ff       	call   f0100f05 <pgdir_walk>
        if (pte == NULL) //remember: pte can be NULL if a page couldn't be allocated because there wasn't enough free memory
f0101145:	83 c4 10             	add    $0x10,%esp
f0101148:	85 c0                	test   %eax,%eax
f010114a:	74 57                	je     f01011a3 <page_insert+0x7c>
f010114c:	89 c6                	mov    %eax,%esi
        pp->pp_ref += 1; //a new reference to the page table entry *pte was created, so must update the number of references to it
f010114e:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
        if (((*pte) & PTE_P) == 1) //page already mapped; i think i should use permission bits?
f0101153:	f6 00 01             	testb  $0x1,(%eax)
f0101156:	75 21                	jne    f0101179 <page_insert+0x52>
	return (pp - pages) << PGSHIFT;
f0101158:	2b 1d 10 cb 18 f0    	sub    0xf018cb10,%ebx
f010115e:	c1 fb 03             	sar    $0x3,%ebx
f0101161:	c1 e3 0c             	shl    $0xc,%ebx
                *pte = page2pa(pp) | perm | PTE_P;
f0101164:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101167:	83 cb 01             	or     $0x1,%ebx
f010116a:	89 18                	mov    %ebx,(%eax)
                return 0;
f010116c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101171:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101174:	5b                   	pop    %ebx
f0101175:	5e                   	pop    %esi
f0101176:	5f                   	pop    %edi
f0101177:	5d                   	pop    %ebp
f0101178:	c3                   	ret    
                page_remove(pgdir, va); //remove it no matter what? 'elegant solution'. Also the invalidation of the TLB happens in page_remove()
f0101179:	83 ec 08             	sub    $0x8,%esp
f010117c:	57                   	push   %edi
f010117d:	ff 75 08             	pushl  0x8(%ebp)
f0101180:	e8 63 ff ff ff       	call   f01010e8 <page_remove>
f0101185:	2b 1d 10 cb 18 f0    	sub    0xf018cb10,%ebx
f010118b:	c1 fb 03             	sar    $0x3,%ebx
f010118e:	c1 e3 0c             	shl    $0xc,%ebx
                *pte = page2pa(pp)|perm|PTE_P;
f0101191:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101194:	83 cb 01             	or     $0x1,%ebx
f0101197:	89 1e                	mov    %ebx,(%esi)
                return 0;
f0101199:	83 c4 10             	add    $0x10,%esp
f010119c:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a1:	eb ce                	jmp    f0101171 <page_insert+0x4a>
                return -E_NO_MEM;
f01011a3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01011a8:	eb c7                	jmp    f0101171 <page_insert+0x4a>

f01011aa <mem_init>:
{
f01011aa:	f3 0f 1e fb          	endbr32 
f01011ae:	55                   	push   %ebp
f01011af:	89 e5                	mov    %esp,%ebp
f01011b1:	57                   	push   %edi
f01011b2:	56                   	push   %esi
f01011b3:	53                   	push   %ebx
f01011b4:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01011b7:	b8 15 00 00 00       	mov    $0x15,%eax
f01011bc:	e8 3e f7 ff ff       	call   f01008ff <nvram_read>
f01011c1:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01011c3:	b8 17 00 00 00       	mov    $0x17,%eax
f01011c8:	e8 32 f7 ff ff       	call   f01008ff <nvram_read>
f01011cd:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01011cf:	b8 34 00 00 00       	mov    $0x34,%eax
f01011d4:	e8 26 f7 ff ff       	call   f01008ff <nvram_read>
	if (ext16mem)
f01011d9:	c1 e0 06             	shl    $0x6,%eax
f01011dc:	0f 84 ea 00 00 00    	je     f01012cc <mem_init+0x122>
		totalmem = 16 * 1024 + ext16mem;
f01011e2:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01011e7:	89 c2                	mov    %eax,%edx
f01011e9:	c1 ea 02             	shr    $0x2,%edx
f01011ec:	89 15 08 cb 18 f0    	mov    %edx,0xf018cb08
	npages_basemem = basemem / (PGSIZE / 1024);
f01011f2:	89 da                	mov    %ebx,%edx
f01011f4:	c1 ea 02             	shr    $0x2,%edx
f01011f7:	89 15 48 be 18 f0    	mov    %edx,0xf018be48
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011fd:	89 c2                	mov    %eax,%edx
f01011ff:	29 da                	sub    %ebx,%edx
f0101201:	52                   	push   %edx
f0101202:	53                   	push   %ebx
f0101203:	50                   	push   %eax
f0101204:	68 e0 53 10 f0       	push   $0xf01053e0
f0101209:	e8 28 21 00 00       	call   f0103336 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010120e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101213:	e8 10 f7 ff ff       	call   f0100928 <boot_alloc>
f0101218:	a3 0c cb 18 f0       	mov    %eax,0xf018cb0c
	memset(kern_pgdir, 0, PGSIZE);
f010121d:	83 c4 0c             	add    $0xc,%esp
f0101220:	68 00 10 00 00       	push   $0x1000
f0101225:	6a 00                	push   $0x0
f0101227:	50                   	push   %eax
f0101228:	e8 21 36 00 00       	call   f010484e <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010122d:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101232:	83 c4 10             	add    $0x10,%esp
f0101235:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010123a:	0f 86 9c 00 00 00    	jbe    f01012dc <mem_init+0x132>
	return (physaddr_t)kva - KERNBASE;
f0101240:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101246:	83 ca 05             	or     $0x5,%edx
f0101249:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo)); //also, boot_alloc() returns a void pointer so you need to cast it
f010124f:	a1 08 cb 18 f0       	mov    0xf018cb08,%eax
f0101254:	c1 e0 03             	shl    $0x3,%eax
f0101257:	e8 cc f6 ff ff       	call   f0100928 <boot_alloc>
f010125c:	a3 10 cb 18 f0       	mov    %eax,0xf018cb10
        memset(pages, 0, npages * sizeof(struct PageInfo));
f0101261:	83 ec 04             	sub    $0x4,%esp
f0101264:	8b 0d 08 cb 18 f0    	mov    0xf018cb08,%ecx
f010126a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101271:	52                   	push   %edx
f0101272:	6a 00                	push   $0x0
f0101274:	50                   	push   %eax
f0101275:	e8 d4 35 00 00       	call   f010484e <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f010127a:	b8 00 80 01 00       	mov    $0x18000,%eax
f010127f:	e8 a4 f6 ff ff       	call   f0100928 <boot_alloc>
f0101284:	a3 50 be 18 f0       	mov    %eax,0xf018be50
	memset(envs, 0, NENV * sizeof(struct Env)); //need to zero out everything in the new envs array just like the pages array thing
f0101289:	83 c4 0c             	add    $0xc,%esp
f010128c:	68 00 80 01 00       	push   $0x18000
f0101291:	6a 00                	push   $0x0
f0101293:	50                   	push   %eax
f0101294:	e8 b5 35 00 00       	call   f010484e <memset>
	page_init();
f0101299:	e8 65 fa ff ff       	call   f0100d03 <page_init>
	check_page_free_list(1);
f010129e:	b8 01 00 00 00       	mov    $0x1,%eax
f01012a3:	e8 98 f7 ff ff       	call   f0100a40 <check_page_free_list>
	if (!pages)
f01012a8:	83 c4 10             	add    $0x10,%esp
f01012ab:	83 3d 10 cb 18 f0 00 	cmpl   $0x0,0xf018cb10
f01012b2:	74 3d                	je     f01012f1 <mem_init+0x147>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012b4:	a1 44 be 18 f0       	mov    0xf018be44,%eax
f01012b9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01012c0:	85 c0                	test   %eax,%eax
f01012c2:	74 44                	je     f0101308 <mem_init+0x15e>
		++nfree;
f01012c4:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012c8:	8b 00                	mov    (%eax),%eax
f01012ca:	eb f4                	jmp    f01012c0 <mem_init+0x116>
		totalmem = 1 * 1024 + extmem;
f01012cc:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01012d2:	85 f6                	test   %esi,%esi
f01012d4:	0f 44 c3             	cmove  %ebx,%eax
f01012d7:	e9 0b ff ff ff       	jmp    f01011e7 <mem_init+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012dc:	50                   	push   %eax
f01012dd:	68 20 53 10 f0       	push   $0xf0105320
f01012e2:	68 ba 00 00 00       	push   $0xba
f01012e7:	68 71 5a 10 f0       	push   $0xf0105a71
f01012ec:	e8 b3 ed ff ff       	call   f01000a4 <_panic>
		panic("'pages' is a null pointer!");
f01012f1:	83 ec 04             	sub    $0x4,%esp
f01012f4:	68 3d 5b 10 f0       	push   $0xf0105b3d
f01012f9:	68 4a 03 00 00       	push   $0x34a
f01012fe:	68 71 5a 10 f0       	push   $0xf0105a71
f0101303:	e8 9c ed ff ff       	call   f01000a4 <_panic>
	assert((pp0 = page_alloc(0)));
f0101308:	83 ec 0c             	sub    $0xc,%esp
f010130b:	6a 00                	push   $0x0
f010130d:	e8 f7 fa ff ff       	call   f0100e09 <page_alloc>
f0101312:	89 c3                	mov    %eax,%ebx
f0101314:	83 c4 10             	add    $0x10,%esp
f0101317:	85 c0                	test   %eax,%eax
f0101319:	0f 84 11 02 00 00    	je     f0101530 <mem_init+0x386>
	assert((pp1 = page_alloc(0)));
f010131f:	83 ec 0c             	sub    $0xc,%esp
f0101322:	6a 00                	push   $0x0
f0101324:	e8 e0 fa ff ff       	call   f0100e09 <page_alloc>
f0101329:	89 c6                	mov    %eax,%esi
f010132b:	83 c4 10             	add    $0x10,%esp
f010132e:	85 c0                	test   %eax,%eax
f0101330:	0f 84 13 02 00 00    	je     f0101549 <mem_init+0x39f>
	assert((pp2 = page_alloc(0)));
f0101336:	83 ec 0c             	sub    $0xc,%esp
f0101339:	6a 00                	push   $0x0
f010133b:	e8 c9 fa ff ff       	call   f0100e09 <page_alloc>
f0101340:	89 c7                	mov    %eax,%edi
f0101342:	83 c4 10             	add    $0x10,%esp
f0101345:	85 c0                	test   %eax,%eax
f0101347:	0f 84 15 02 00 00    	je     f0101562 <mem_init+0x3b8>
	assert(pp1 && pp1 != pp0);
f010134d:	39 f3                	cmp    %esi,%ebx
f010134f:	0f 84 26 02 00 00    	je     f010157b <mem_init+0x3d1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101355:	39 c6                	cmp    %eax,%esi
f0101357:	0f 84 37 02 00 00    	je     f0101594 <mem_init+0x3ea>
f010135d:	39 c3                	cmp    %eax,%ebx
f010135f:	0f 84 2f 02 00 00    	je     f0101594 <mem_init+0x3ea>
	return (pp - pages) << PGSHIFT;
f0101365:	8b 0d 10 cb 18 f0    	mov    0xf018cb10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010136b:	8b 15 08 cb 18 f0    	mov    0xf018cb08,%edx
f0101371:	c1 e2 0c             	shl    $0xc,%edx
f0101374:	89 d8                	mov    %ebx,%eax
f0101376:	29 c8                	sub    %ecx,%eax
f0101378:	c1 f8 03             	sar    $0x3,%eax
f010137b:	c1 e0 0c             	shl    $0xc,%eax
f010137e:	39 d0                	cmp    %edx,%eax
f0101380:	0f 83 27 02 00 00    	jae    f01015ad <mem_init+0x403>
f0101386:	89 f0                	mov    %esi,%eax
f0101388:	29 c8                	sub    %ecx,%eax
f010138a:	c1 f8 03             	sar    $0x3,%eax
f010138d:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101390:	39 c2                	cmp    %eax,%edx
f0101392:	0f 86 2e 02 00 00    	jbe    f01015c6 <mem_init+0x41c>
f0101398:	89 f8                	mov    %edi,%eax
f010139a:	29 c8                	sub    %ecx,%eax
f010139c:	c1 f8 03             	sar    $0x3,%eax
f010139f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01013a2:	39 c2                	cmp    %eax,%edx
f01013a4:	0f 86 35 02 00 00    	jbe    f01015df <mem_init+0x435>
	fl = page_free_list;
f01013aa:	a1 44 be 18 f0       	mov    0xf018be44,%eax
f01013af:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013b2:	c7 05 44 be 18 f0 00 	movl   $0x0,0xf018be44
f01013b9:	00 00 00 
	assert(!page_alloc(0));
f01013bc:	83 ec 0c             	sub    $0xc,%esp
f01013bf:	6a 00                	push   $0x0
f01013c1:	e8 43 fa ff ff       	call   f0100e09 <page_alloc>
f01013c6:	83 c4 10             	add    $0x10,%esp
f01013c9:	85 c0                	test   %eax,%eax
f01013cb:	0f 85 27 02 00 00    	jne    f01015f8 <mem_init+0x44e>
	page_free(pp0);
f01013d1:	83 ec 0c             	sub    $0xc,%esp
f01013d4:	53                   	push   %ebx
f01013d5:	e8 a8 fa ff ff       	call   f0100e82 <page_free>
	page_free(pp1);
f01013da:	89 34 24             	mov    %esi,(%esp)
f01013dd:	e8 a0 fa ff ff       	call   f0100e82 <page_free>
	page_free(pp2);
f01013e2:	89 3c 24             	mov    %edi,(%esp)
f01013e5:	e8 98 fa ff ff       	call   f0100e82 <page_free>
	assert((pp0 = page_alloc(0)));
f01013ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013f1:	e8 13 fa ff ff       	call   f0100e09 <page_alloc>
f01013f6:	89 c3                	mov    %eax,%ebx
f01013f8:	83 c4 10             	add    $0x10,%esp
f01013fb:	85 c0                	test   %eax,%eax
f01013fd:	0f 84 0e 02 00 00    	je     f0101611 <mem_init+0x467>
	assert((pp1 = page_alloc(0)));
f0101403:	83 ec 0c             	sub    $0xc,%esp
f0101406:	6a 00                	push   $0x0
f0101408:	e8 fc f9 ff ff       	call   f0100e09 <page_alloc>
f010140d:	89 c6                	mov    %eax,%esi
f010140f:	83 c4 10             	add    $0x10,%esp
f0101412:	85 c0                	test   %eax,%eax
f0101414:	0f 84 10 02 00 00    	je     f010162a <mem_init+0x480>
	assert((pp2 = page_alloc(0)));
f010141a:	83 ec 0c             	sub    $0xc,%esp
f010141d:	6a 00                	push   $0x0
f010141f:	e8 e5 f9 ff ff       	call   f0100e09 <page_alloc>
f0101424:	89 c7                	mov    %eax,%edi
f0101426:	83 c4 10             	add    $0x10,%esp
f0101429:	85 c0                	test   %eax,%eax
f010142b:	0f 84 12 02 00 00    	je     f0101643 <mem_init+0x499>
	assert(pp1 && pp1 != pp0);
f0101431:	39 f3                	cmp    %esi,%ebx
f0101433:	0f 84 23 02 00 00    	je     f010165c <mem_init+0x4b2>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101439:	39 c6                	cmp    %eax,%esi
f010143b:	0f 84 34 02 00 00    	je     f0101675 <mem_init+0x4cb>
f0101441:	39 c3                	cmp    %eax,%ebx
f0101443:	0f 84 2c 02 00 00    	je     f0101675 <mem_init+0x4cb>
	assert(!page_alloc(0));
f0101449:	83 ec 0c             	sub    $0xc,%esp
f010144c:	6a 00                	push   $0x0
f010144e:	e8 b6 f9 ff ff       	call   f0100e09 <page_alloc>
f0101453:	83 c4 10             	add    $0x10,%esp
f0101456:	85 c0                	test   %eax,%eax
f0101458:	0f 85 30 02 00 00    	jne    f010168e <mem_init+0x4e4>
f010145e:	89 d8                	mov    %ebx,%eax
f0101460:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0101466:	c1 f8 03             	sar    $0x3,%eax
f0101469:	89 c2                	mov    %eax,%edx
f010146b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010146e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101473:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0101479:	0f 83 28 02 00 00    	jae    f01016a7 <mem_init+0x4fd>
	memset(page2kva(pp0), 1, PGSIZE);
f010147f:	83 ec 04             	sub    $0x4,%esp
f0101482:	68 00 10 00 00       	push   $0x1000
f0101487:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101489:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010148f:	52                   	push   %edx
f0101490:	e8 b9 33 00 00       	call   f010484e <memset>
	page_free(pp0);
f0101495:	89 1c 24             	mov    %ebx,(%esp)
f0101498:	e8 e5 f9 ff ff       	call   f0100e82 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010149d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01014a4:	e8 60 f9 ff ff       	call   f0100e09 <page_alloc>
f01014a9:	83 c4 10             	add    $0x10,%esp
f01014ac:	85 c0                	test   %eax,%eax
f01014ae:	0f 84 05 02 00 00    	je     f01016b9 <mem_init+0x50f>
	assert(pp && pp0 == pp);
f01014b4:	39 c3                	cmp    %eax,%ebx
f01014b6:	0f 85 16 02 00 00    	jne    f01016d2 <mem_init+0x528>
	return (pp - pages) << PGSHIFT;
f01014bc:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f01014c2:	c1 f8 03             	sar    $0x3,%eax
f01014c5:	89 c2                	mov    %eax,%edx
f01014c7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01014ca:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01014cf:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f01014d5:	0f 83 10 02 00 00    	jae    f01016eb <mem_init+0x541>
	return (void *)(pa + KERNBASE);
f01014db:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01014e1:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01014e7:	80 38 00             	cmpb   $0x0,(%eax)
f01014ea:	0f 85 0d 02 00 00    	jne    f01016fd <mem_init+0x553>
f01014f0:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01014f3:	39 d0                	cmp    %edx,%eax
f01014f5:	75 f0                	jne    f01014e7 <mem_init+0x33d>
	page_free_list = fl;
f01014f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014fa:	a3 44 be 18 f0       	mov    %eax,0xf018be44
	page_free(pp0);
f01014ff:	83 ec 0c             	sub    $0xc,%esp
f0101502:	53                   	push   %ebx
f0101503:	e8 7a f9 ff ff       	call   f0100e82 <page_free>
	page_free(pp1);
f0101508:	89 34 24             	mov    %esi,(%esp)
f010150b:	e8 72 f9 ff ff       	call   f0100e82 <page_free>
	page_free(pp2);
f0101510:	89 3c 24             	mov    %edi,(%esp)
f0101513:	e8 6a f9 ff ff       	call   f0100e82 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101518:	a1 44 be 18 f0       	mov    0xf018be44,%eax
f010151d:	83 c4 10             	add    $0x10,%esp
f0101520:	85 c0                	test   %eax,%eax
f0101522:	0f 84 ee 01 00 00    	je     f0101716 <mem_init+0x56c>
		--nfree;
f0101528:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010152c:	8b 00                	mov    (%eax),%eax
f010152e:	eb f0                	jmp    f0101520 <mem_init+0x376>
	assert((pp0 = page_alloc(0)));
f0101530:	68 58 5b 10 f0       	push   $0xf0105b58
f0101535:	68 ad 5a 10 f0       	push   $0xf0105aad
f010153a:	68 52 03 00 00       	push   $0x352
f010153f:	68 71 5a 10 f0       	push   $0xf0105a71
f0101544:	e8 5b eb ff ff       	call   f01000a4 <_panic>
	assert((pp1 = page_alloc(0)));
f0101549:	68 6e 5b 10 f0       	push   $0xf0105b6e
f010154e:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101553:	68 53 03 00 00       	push   $0x353
f0101558:	68 71 5a 10 f0       	push   $0xf0105a71
f010155d:	e8 42 eb ff ff       	call   f01000a4 <_panic>
	assert((pp2 = page_alloc(0)));
f0101562:	68 84 5b 10 f0       	push   $0xf0105b84
f0101567:	68 ad 5a 10 f0       	push   $0xf0105aad
f010156c:	68 54 03 00 00       	push   $0x354
f0101571:	68 71 5a 10 f0       	push   $0xf0105a71
f0101576:	e8 29 eb ff ff       	call   f01000a4 <_panic>
	assert(pp1 && pp1 != pp0);
f010157b:	68 9a 5b 10 f0       	push   $0xf0105b9a
f0101580:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101585:	68 57 03 00 00       	push   $0x357
f010158a:	68 71 5a 10 f0       	push   $0xf0105a71
f010158f:	e8 10 eb ff ff       	call   f01000a4 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101594:	68 1c 54 10 f0       	push   $0xf010541c
f0101599:	68 ad 5a 10 f0       	push   $0xf0105aad
f010159e:	68 58 03 00 00       	push   $0x358
f01015a3:	68 71 5a 10 f0       	push   $0xf0105a71
f01015a8:	e8 f7 ea ff ff       	call   f01000a4 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01015ad:	68 ac 5b 10 f0       	push   $0xf0105bac
f01015b2:	68 ad 5a 10 f0       	push   $0xf0105aad
f01015b7:	68 59 03 00 00       	push   $0x359
f01015bc:	68 71 5a 10 f0       	push   $0xf0105a71
f01015c1:	e8 de ea ff ff       	call   f01000a4 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01015c6:	68 c9 5b 10 f0       	push   $0xf0105bc9
f01015cb:	68 ad 5a 10 f0       	push   $0xf0105aad
f01015d0:	68 5a 03 00 00       	push   $0x35a
f01015d5:	68 71 5a 10 f0       	push   $0xf0105a71
f01015da:	e8 c5 ea ff ff       	call   f01000a4 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01015df:	68 e6 5b 10 f0       	push   $0xf0105be6
f01015e4:	68 ad 5a 10 f0       	push   $0xf0105aad
f01015e9:	68 5b 03 00 00       	push   $0x35b
f01015ee:	68 71 5a 10 f0       	push   $0xf0105a71
f01015f3:	e8 ac ea ff ff       	call   f01000a4 <_panic>
	assert(!page_alloc(0));
f01015f8:	68 03 5c 10 f0       	push   $0xf0105c03
f01015fd:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101602:	68 62 03 00 00       	push   $0x362
f0101607:	68 71 5a 10 f0       	push   $0xf0105a71
f010160c:	e8 93 ea ff ff       	call   f01000a4 <_panic>
	assert((pp0 = page_alloc(0)));
f0101611:	68 58 5b 10 f0       	push   $0xf0105b58
f0101616:	68 ad 5a 10 f0       	push   $0xf0105aad
f010161b:	68 69 03 00 00       	push   $0x369
f0101620:	68 71 5a 10 f0       	push   $0xf0105a71
f0101625:	e8 7a ea ff ff       	call   f01000a4 <_panic>
	assert((pp1 = page_alloc(0)));
f010162a:	68 6e 5b 10 f0       	push   $0xf0105b6e
f010162f:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101634:	68 6a 03 00 00       	push   $0x36a
f0101639:	68 71 5a 10 f0       	push   $0xf0105a71
f010163e:	e8 61 ea ff ff       	call   f01000a4 <_panic>
	assert((pp2 = page_alloc(0)));
f0101643:	68 84 5b 10 f0       	push   $0xf0105b84
f0101648:	68 ad 5a 10 f0       	push   $0xf0105aad
f010164d:	68 6b 03 00 00       	push   $0x36b
f0101652:	68 71 5a 10 f0       	push   $0xf0105a71
f0101657:	e8 48 ea ff ff       	call   f01000a4 <_panic>
	assert(pp1 && pp1 != pp0);
f010165c:	68 9a 5b 10 f0       	push   $0xf0105b9a
f0101661:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101666:	68 6d 03 00 00       	push   $0x36d
f010166b:	68 71 5a 10 f0       	push   $0xf0105a71
f0101670:	e8 2f ea ff ff       	call   f01000a4 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101675:	68 1c 54 10 f0       	push   $0xf010541c
f010167a:	68 ad 5a 10 f0       	push   $0xf0105aad
f010167f:	68 6e 03 00 00       	push   $0x36e
f0101684:	68 71 5a 10 f0       	push   $0xf0105a71
f0101689:	e8 16 ea ff ff       	call   f01000a4 <_panic>
	assert(!page_alloc(0));
f010168e:	68 03 5c 10 f0       	push   $0xf0105c03
f0101693:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101698:	68 6f 03 00 00       	push   $0x36f
f010169d:	68 71 5a 10 f0       	push   $0xf0105a71
f01016a2:	e8 fd e9 ff ff       	call   f01000a4 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016a7:	52                   	push   %edx
f01016a8:	68 14 52 10 f0       	push   $0xf0105214
f01016ad:	6a 56                	push   $0x56
f01016af:	68 93 5a 10 f0       	push   $0xf0105a93
f01016b4:	e8 eb e9 ff ff       	call   f01000a4 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016b9:	68 12 5c 10 f0       	push   $0xf0105c12
f01016be:	68 ad 5a 10 f0       	push   $0xf0105aad
f01016c3:	68 74 03 00 00       	push   $0x374
f01016c8:	68 71 5a 10 f0       	push   $0xf0105a71
f01016cd:	e8 d2 e9 ff ff       	call   f01000a4 <_panic>
	assert(pp && pp0 == pp);
f01016d2:	68 30 5c 10 f0       	push   $0xf0105c30
f01016d7:	68 ad 5a 10 f0       	push   $0xf0105aad
f01016dc:	68 75 03 00 00       	push   $0x375
f01016e1:	68 71 5a 10 f0       	push   $0xf0105a71
f01016e6:	e8 b9 e9 ff ff       	call   f01000a4 <_panic>
f01016eb:	52                   	push   %edx
f01016ec:	68 14 52 10 f0       	push   $0xf0105214
f01016f1:	6a 56                	push   $0x56
f01016f3:	68 93 5a 10 f0       	push   $0xf0105a93
f01016f8:	e8 a7 e9 ff ff       	call   f01000a4 <_panic>
		assert(c[i] == 0);
f01016fd:	68 40 5c 10 f0       	push   $0xf0105c40
f0101702:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101707:	68 78 03 00 00       	push   $0x378
f010170c:	68 71 5a 10 f0       	push   $0xf0105a71
f0101711:	e8 8e e9 ff ff       	call   f01000a4 <_panic>
	assert(nfree == 0);
f0101716:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010171a:	0f 85 d6 07 00 00    	jne    f0101ef6 <mem_init+0xd4c>
	cprintf("check_page_alloc() succeeded!\n");
f0101720:	83 ec 0c             	sub    $0xc,%esp
f0101723:	68 3c 54 10 f0       	push   $0xf010543c
f0101728:	e8 09 1c 00 00       	call   f0103336 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010172d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101734:	e8 d0 f6 ff ff       	call   f0100e09 <page_alloc>
f0101739:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010173c:	83 c4 10             	add    $0x10,%esp
f010173f:	85 c0                	test   %eax,%eax
f0101741:	0f 84 c8 07 00 00    	je     f0101f0f <mem_init+0xd65>
	assert((pp1 = page_alloc(0)));
f0101747:	83 ec 0c             	sub    $0xc,%esp
f010174a:	6a 00                	push   $0x0
f010174c:	e8 b8 f6 ff ff       	call   f0100e09 <page_alloc>
f0101751:	89 c7                	mov    %eax,%edi
f0101753:	83 c4 10             	add    $0x10,%esp
f0101756:	85 c0                	test   %eax,%eax
f0101758:	0f 84 ca 07 00 00    	je     f0101f28 <mem_init+0xd7e>
	assert((pp2 = page_alloc(0)));
f010175e:	83 ec 0c             	sub    $0xc,%esp
f0101761:	6a 00                	push   $0x0
f0101763:	e8 a1 f6 ff ff       	call   f0100e09 <page_alloc>
f0101768:	89 c3                	mov    %eax,%ebx
f010176a:	83 c4 10             	add    $0x10,%esp
f010176d:	85 c0                	test   %eax,%eax
f010176f:	0f 84 cc 07 00 00    	je     f0101f41 <mem_init+0xd97>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101775:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0101778:	0f 84 dc 07 00 00    	je     f0101f5a <mem_init+0xdb0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010177e:	39 c7                	cmp    %eax,%edi
f0101780:	0f 84 ed 07 00 00    	je     f0101f73 <mem_init+0xdc9>
f0101786:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101789:	0f 84 e4 07 00 00    	je     f0101f73 <mem_init+0xdc9>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010178f:	a1 44 be 18 f0       	mov    0xf018be44,%eax
f0101794:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101797:	c7 05 44 be 18 f0 00 	movl   $0x0,0xf018be44
f010179e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017a1:	83 ec 0c             	sub    $0xc,%esp
f01017a4:	6a 00                	push   $0x0
f01017a6:	e8 5e f6 ff ff       	call   f0100e09 <page_alloc>
f01017ab:	83 c4 10             	add    $0x10,%esp
f01017ae:	85 c0                	test   %eax,%eax
f01017b0:	0f 85 d6 07 00 00    	jne    f0101f8c <mem_init+0xde2>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01017b6:	83 ec 04             	sub    $0x4,%esp
f01017b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01017bc:	50                   	push   %eax
f01017bd:	6a 00                	push   $0x0
f01017bf:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f01017c5:	e8 b5 f8 ff ff       	call   f010107f <page_lookup>
f01017ca:	83 c4 10             	add    $0x10,%esp
f01017cd:	85 c0                	test   %eax,%eax
f01017cf:	0f 85 d0 07 00 00    	jne    f0101fa5 <mem_init+0xdfb>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01017d5:	6a 02                	push   $0x2
f01017d7:	6a 00                	push   $0x0
f01017d9:	57                   	push   %edi
f01017da:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f01017e0:	e8 42 f9 ff ff       	call   f0101127 <page_insert>
f01017e5:	83 c4 10             	add    $0x10,%esp
f01017e8:	85 c0                	test   %eax,%eax
f01017ea:	0f 89 ce 07 00 00    	jns    f0101fbe <mem_init+0xe14>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017f0:	83 ec 0c             	sub    $0xc,%esp
f01017f3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017f6:	e8 87 f6 ff ff       	call   f0100e82 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017fb:	6a 02                	push   $0x2
f01017fd:	6a 00                	push   $0x0
f01017ff:	57                   	push   %edi
f0101800:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101806:	e8 1c f9 ff ff       	call   f0101127 <page_insert>
f010180b:	83 c4 20             	add    $0x20,%esp
f010180e:	85 c0                	test   %eax,%eax
f0101810:	0f 85 c1 07 00 00    	jne    f0101fd7 <mem_init+0xe2d>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101816:	8b 35 0c cb 18 f0    	mov    0xf018cb0c,%esi
	return (pp - pages) << PGSHIFT;
f010181c:	8b 0d 10 cb 18 f0    	mov    0xf018cb10,%ecx
f0101822:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101825:	8b 16                	mov    (%esi),%edx
f0101827:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010182d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101830:	29 c8                	sub    %ecx,%eax
f0101832:	c1 f8 03             	sar    $0x3,%eax
f0101835:	c1 e0 0c             	shl    $0xc,%eax
f0101838:	39 c2                	cmp    %eax,%edx
f010183a:	0f 85 b0 07 00 00    	jne    f0101ff0 <mem_init+0xe46>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101840:	ba 00 00 00 00       	mov    $0x0,%edx
f0101845:	89 f0                	mov    %esi,%eax
f0101847:	e8 91 f1 ff ff       	call   f01009dd <check_va2pa>
f010184c:	89 c2                	mov    %eax,%edx
f010184e:	89 f8                	mov    %edi,%eax
f0101850:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101853:	c1 f8 03             	sar    $0x3,%eax
f0101856:	c1 e0 0c             	shl    $0xc,%eax
f0101859:	39 c2                	cmp    %eax,%edx
f010185b:	0f 85 a8 07 00 00    	jne    f0102009 <mem_init+0xe5f>
	assert(pp1->pp_ref == 1);
f0101861:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101866:	0f 85 b6 07 00 00    	jne    f0102022 <mem_init+0xe78>
	assert(pp0->pp_ref == 1);
f010186c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010186f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101874:	0f 85 c1 07 00 00    	jne    f010203b <mem_init+0xe91>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010187a:	6a 02                	push   $0x2
f010187c:	68 00 10 00 00       	push   $0x1000
f0101881:	53                   	push   %ebx
f0101882:	56                   	push   %esi
f0101883:	e8 9f f8 ff ff       	call   f0101127 <page_insert>
f0101888:	83 c4 10             	add    $0x10,%esp
f010188b:	85 c0                	test   %eax,%eax
f010188d:	0f 85 c1 07 00 00    	jne    f0102054 <mem_init+0xeaa>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101893:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101898:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f010189d:	e8 3b f1 ff ff       	call   f01009dd <check_va2pa>
f01018a2:	89 c2                	mov    %eax,%edx
f01018a4:	89 d8                	mov    %ebx,%eax
f01018a6:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f01018ac:	c1 f8 03             	sar    $0x3,%eax
f01018af:	c1 e0 0c             	shl    $0xc,%eax
f01018b2:	39 c2                	cmp    %eax,%edx
f01018b4:	0f 85 b3 07 00 00    	jne    f010206d <mem_init+0xec3>
	assert(pp2->pp_ref == 1);
f01018ba:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018bf:	0f 85 c1 07 00 00    	jne    f0102086 <mem_init+0xedc>

	// should be no free memory
	assert(!page_alloc(0));
f01018c5:	83 ec 0c             	sub    $0xc,%esp
f01018c8:	6a 00                	push   $0x0
f01018ca:	e8 3a f5 ff ff       	call   f0100e09 <page_alloc>
f01018cf:	83 c4 10             	add    $0x10,%esp
f01018d2:	85 c0                	test   %eax,%eax
f01018d4:	0f 85 c5 07 00 00    	jne    f010209f <mem_init+0xef5>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018da:	6a 02                	push   $0x2
f01018dc:	68 00 10 00 00       	push   $0x1000
f01018e1:	53                   	push   %ebx
f01018e2:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f01018e8:	e8 3a f8 ff ff       	call   f0101127 <page_insert>
f01018ed:	83 c4 10             	add    $0x10,%esp
f01018f0:	85 c0                	test   %eax,%eax
f01018f2:	0f 85 c0 07 00 00    	jne    f01020b8 <mem_init+0xf0e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018f8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018fd:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f0101902:	e8 d6 f0 ff ff       	call   f01009dd <check_va2pa>
f0101907:	89 c2                	mov    %eax,%edx
f0101909:	89 d8                	mov    %ebx,%eax
f010190b:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0101911:	c1 f8 03             	sar    $0x3,%eax
f0101914:	c1 e0 0c             	shl    $0xc,%eax
f0101917:	39 c2                	cmp    %eax,%edx
f0101919:	0f 85 b2 07 00 00    	jne    f01020d1 <mem_init+0xf27>
	assert(pp2->pp_ref == 1);
f010191f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101924:	0f 85 c0 07 00 00    	jne    f01020ea <mem_init+0xf40>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010192a:	83 ec 0c             	sub    $0xc,%esp
f010192d:	6a 00                	push   $0x0
f010192f:	e8 d5 f4 ff ff       	call   f0100e09 <page_alloc>
f0101934:	83 c4 10             	add    $0x10,%esp
f0101937:	85 c0                	test   %eax,%eax
f0101939:	0f 85 c4 07 00 00    	jne    f0102103 <mem_init+0xf59>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010193f:	8b 0d 0c cb 18 f0    	mov    0xf018cb0c,%ecx
f0101945:	8b 01                	mov    (%ecx),%eax
f0101947:	89 c2                	mov    %eax,%edx
f0101949:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010194f:	c1 e8 0c             	shr    $0xc,%eax
f0101952:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0101958:	0f 83 be 07 00 00    	jae    f010211c <mem_init+0xf72>
	return (void *)(pa + KERNBASE);
f010195e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101964:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101967:	83 ec 04             	sub    $0x4,%esp
f010196a:	6a 00                	push   $0x0
f010196c:	68 00 10 00 00       	push   $0x1000
f0101971:	51                   	push   %ecx
f0101972:	e8 8e f5 ff ff       	call   f0100f05 <pgdir_walk>
f0101977:	89 c2                	mov    %eax,%edx
f0101979:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010197c:	83 c0 04             	add    $0x4,%eax
f010197f:	83 c4 10             	add    $0x10,%esp
f0101982:	39 d0                	cmp    %edx,%eax
f0101984:	0f 85 a7 07 00 00    	jne    f0102131 <mem_init+0xf87>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010198a:	6a 06                	push   $0x6
f010198c:	68 00 10 00 00       	push   $0x1000
f0101991:	53                   	push   %ebx
f0101992:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101998:	e8 8a f7 ff ff       	call   f0101127 <page_insert>
f010199d:	83 c4 10             	add    $0x10,%esp
f01019a0:	85 c0                	test   %eax,%eax
f01019a2:	0f 85 a2 07 00 00    	jne    f010214a <mem_init+0xfa0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019a8:	8b 35 0c cb 18 f0    	mov    0xf018cb0c,%esi
f01019ae:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019b3:	89 f0                	mov    %esi,%eax
f01019b5:	e8 23 f0 ff ff       	call   f01009dd <check_va2pa>
f01019ba:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f01019bc:	89 d8                	mov    %ebx,%eax
f01019be:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f01019c4:	c1 f8 03             	sar    $0x3,%eax
f01019c7:	c1 e0 0c             	shl    $0xc,%eax
f01019ca:	39 c2                	cmp    %eax,%edx
f01019cc:	0f 85 91 07 00 00    	jne    f0102163 <mem_init+0xfb9>
	assert(pp2->pp_ref == 1);
f01019d2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019d7:	0f 85 9f 07 00 00    	jne    f010217c <mem_init+0xfd2>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01019dd:	83 ec 04             	sub    $0x4,%esp
f01019e0:	6a 00                	push   $0x0
f01019e2:	68 00 10 00 00       	push   $0x1000
f01019e7:	56                   	push   %esi
f01019e8:	e8 18 f5 ff ff       	call   f0100f05 <pgdir_walk>
f01019ed:	83 c4 10             	add    $0x10,%esp
f01019f0:	f6 00 04             	testb  $0x4,(%eax)
f01019f3:	0f 84 9c 07 00 00    	je     f0102195 <mem_init+0xfeb>
	assert(kern_pgdir[0] & PTE_U);
f01019f9:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f01019fe:	f6 00 04             	testb  $0x4,(%eax)
f0101a01:	0f 84 a7 07 00 00    	je     f01021ae <mem_init+0x1004>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a07:	6a 02                	push   $0x2
f0101a09:	68 00 10 00 00       	push   $0x1000
f0101a0e:	53                   	push   %ebx
f0101a0f:	50                   	push   %eax
f0101a10:	e8 12 f7 ff ff       	call   f0101127 <page_insert>
f0101a15:	83 c4 10             	add    $0x10,%esp
f0101a18:	85 c0                	test   %eax,%eax
f0101a1a:	0f 85 a7 07 00 00    	jne    f01021c7 <mem_init+0x101d>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101a20:	83 ec 04             	sub    $0x4,%esp
f0101a23:	6a 00                	push   $0x0
f0101a25:	68 00 10 00 00       	push   $0x1000
f0101a2a:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101a30:	e8 d0 f4 ff ff       	call   f0100f05 <pgdir_walk>
f0101a35:	83 c4 10             	add    $0x10,%esp
f0101a38:	f6 00 02             	testb  $0x2,(%eax)
f0101a3b:	0f 84 9f 07 00 00    	je     f01021e0 <mem_init+0x1036>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101a41:	83 ec 04             	sub    $0x4,%esp
f0101a44:	6a 00                	push   $0x0
f0101a46:	68 00 10 00 00       	push   $0x1000
f0101a4b:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101a51:	e8 af f4 ff ff       	call   f0100f05 <pgdir_walk>
f0101a56:	83 c4 10             	add    $0x10,%esp
f0101a59:	f6 00 04             	testb  $0x4,(%eax)
f0101a5c:	0f 85 97 07 00 00    	jne    f01021f9 <mem_init+0x104f>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101a62:	6a 02                	push   $0x2
f0101a64:	68 00 00 40 00       	push   $0x400000
f0101a69:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a6c:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101a72:	e8 b0 f6 ff ff       	call   f0101127 <page_insert>
f0101a77:	83 c4 10             	add    $0x10,%esp
f0101a7a:	85 c0                	test   %eax,%eax
f0101a7c:	0f 89 90 07 00 00    	jns    f0102212 <mem_init+0x1068>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101a82:	6a 02                	push   $0x2
f0101a84:	68 00 10 00 00       	push   $0x1000
f0101a89:	57                   	push   %edi
f0101a8a:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101a90:	e8 92 f6 ff ff       	call   f0101127 <page_insert>
f0101a95:	83 c4 10             	add    $0x10,%esp
f0101a98:	85 c0                	test   %eax,%eax
f0101a9a:	0f 85 8b 07 00 00    	jne    f010222b <mem_init+0x1081>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101aa0:	83 ec 04             	sub    $0x4,%esp
f0101aa3:	6a 00                	push   $0x0
f0101aa5:	68 00 10 00 00       	push   $0x1000
f0101aaa:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101ab0:	e8 50 f4 ff ff       	call   f0100f05 <pgdir_walk>
f0101ab5:	83 c4 10             	add    $0x10,%esp
f0101ab8:	f6 00 04             	testb  $0x4,(%eax)
f0101abb:	0f 85 83 07 00 00    	jne    f0102244 <mem_init+0x109a>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ac1:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f0101ac6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ac9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ace:	e8 0a ef ff ff       	call   f01009dd <check_va2pa>
f0101ad3:	89 fe                	mov    %edi,%esi
f0101ad5:	2b 35 10 cb 18 f0    	sub    0xf018cb10,%esi
f0101adb:	c1 fe 03             	sar    $0x3,%esi
f0101ade:	c1 e6 0c             	shl    $0xc,%esi
f0101ae1:	39 f0                	cmp    %esi,%eax
f0101ae3:	0f 85 74 07 00 00    	jne    f010225d <mem_init+0x10b3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ae9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aee:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101af1:	e8 e7 ee ff ff       	call   f01009dd <check_va2pa>
f0101af6:	39 c6                	cmp    %eax,%esi
f0101af8:	0f 85 78 07 00 00    	jne    f0102276 <mem_init+0x10cc>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101afe:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101b03:	0f 85 86 07 00 00    	jne    f010228f <mem_init+0x10e5>
	assert(pp2->pp_ref == 0);
f0101b09:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101b0e:	0f 85 94 07 00 00    	jne    f01022a8 <mem_init+0x10fe>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101b14:	83 ec 0c             	sub    $0xc,%esp
f0101b17:	6a 00                	push   $0x0
f0101b19:	e8 eb f2 ff ff       	call   f0100e09 <page_alloc>
f0101b1e:	83 c4 10             	add    $0x10,%esp
f0101b21:	39 c3                	cmp    %eax,%ebx
f0101b23:	0f 85 98 07 00 00    	jne    f01022c1 <mem_init+0x1117>
f0101b29:	85 c0                	test   %eax,%eax
f0101b2b:	0f 84 90 07 00 00    	je     f01022c1 <mem_init+0x1117>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101b31:	83 ec 08             	sub    $0x8,%esp
f0101b34:	6a 00                	push   $0x0
f0101b36:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101b3c:	e8 a7 f5 ff ff       	call   f01010e8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101b41:	8b 35 0c cb 18 f0    	mov    0xf018cb0c,%esi
f0101b47:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b4c:	89 f0                	mov    %esi,%eax
f0101b4e:	e8 8a ee ff ff       	call   f01009dd <check_va2pa>
f0101b53:	83 c4 10             	add    $0x10,%esp
f0101b56:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101b59:	0f 85 7b 07 00 00    	jne    f01022da <mem_init+0x1130>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b5f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b64:	89 f0                	mov    %esi,%eax
f0101b66:	e8 72 ee ff ff       	call   f01009dd <check_va2pa>
f0101b6b:	89 c2                	mov    %eax,%edx
f0101b6d:	89 f8                	mov    %edi,%eax
f0101b6f:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0101b75:	c1 f8 03             	sar    $0x3,%eax
f0101b78:	c1 e0 0c             	shl    $0xc,%eax
f0101b7b:	39 c2                	cmp    %eax,%edx
f0101b7d:	0f 85 70 07 00 00    	jne    f01022f3 <mem_init+0x1149>
	assert(pp1->pp_ref == 1);
f0101b83:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b88:	0f 85 7e 07 00 00    	jne    f010230c <mem_init+0x1162>
	assert(pp2->pp_ref == 0);
f0101b8e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101b93:	0f 85 8c 07 00 00    	jne    f0102325 <mem_init+0x117b>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101b99:	6a 00                	push   $0x0
f0101b9b:	68 00 10 00 00       	push   $0x1000
f0101ba0:	57                   	push   %edi
f0101ba1:	56                   	push   %esi
f0101ba2:	e8 80 f5 ff ff       	call   f0101127 <page_insert>
f0101ba7:	83 c4 10             	add    $0x10,%esp
f0101baa:	85 c0                	test   %eax,%eax
f0101bac:	0f 85 8c 07 00 00    	jne    f010233e <mem_init+0x1194>
	assert(pp1->pp_ref);
f0101bb2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101bb7:	0f 84 9a 07 00 00    	je     f0102357 <mem_init+0x11ad>
	assert(pp1->pp_link == NULL);
f0101bbd:	83 3f 00             	cmpl   $0x0,(%edi)
f0101bc0:	0f 85 aa 07 00 00    	jne    f0102370 <mem_init+0x11c6>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101bc6:	83 ec 08             	sub    $0x8,%esp
f0101bc9:	68 00 10 00 00       	push   $0x1000
f0101bce:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101bd4:	e8 0f f5 ff ff       	call   f01010e8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101bd9:	8b 35 0c cb 18 f0    	mov    0xf018cb0c,%esi
f0101bdf:	ba 00 00 00 00       	mov    $0x0,%edx
f0101be4:	89 f0                	mov    %esi,%eax
f0101be6:	e8 f2 ed ff ff       	call   f01009dd <check_va2pa>
f0101beb:	83 c4 10             	add    $0x10,%esp
f0101bee:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101bf1:	0f 85 92 07 00 00    	jne    f0102389 <mem_init+0x11df>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101bf7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bfc:	89 f0                	mov    %esi,%eax
f0101bfe:	e8 da ed ff ff       	call   f01009dd <check_va2pa>
f0101c03:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c06:	0f 85 96 07 00 00    	jne    f01023a2 <mem_init+0x11f8>
	assert(pp1->pp_ref == 0);
f0101c0c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101c11:	0f 85 a4 07 00 00    	jne    f01023bb <mem_init+0x1211>
	assert(pp2->pp_ref == 0);
f0101c17:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c1c:	0f 85 b2 07 00 00    	jne    f01023d4 <mem_init+0x122a>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101c22:	83 ec 0c             	sub    $0xc,%esp
f0101c25:	6a 00                	push   $0x0
f0101c27:	e8 dd f1 ff ff       	call   f0100e09 <page_alloc>
f0101c2c:	83 c4 10             	add    $0x10,%esp
f0101c2f:	85 c0                	test   %eax,%eax
f0101c31:	0f 84 b6 07 00 00    	je     f01023ed <mem_init+0x1243>
f0101c37:	39 c7                	cmp    %eax,%edi
f0101c39:	0f 85 ae 07 00 00    	jne    f01023ed <mem_init+0x1243>

	// should be no free memory
	assert(!page_alloc(0));
f0101c3f:	83 ec 0c             	sub    $0xc,%esp
f0101c42:	6a 00                	push   $0x0
f0101c44:	e8 c0 f1 ff ff       	call   f0100e09 <page_alloc>
f0101c49:	83 c4 10             	add    $0x10,%esp
f0101c4c:	85 c0                	test   %eax,%eax
f0101c4e:	0f 85 b2 07 00 00    	jne    f0102406 <mem_init+0x125c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c54:	8b 0d 0c cb 18 f0    	mov    0xf018cb0c,%ecx
f0101c5a:	8b 11                	mov    (%ecx),%edx
f0101c5c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c65:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0101c6b:	c1 f8 03             	sar    $0x3,%eax
f0101c6e:	c1 e0 0c             	shl    $0xc,%eax
f0101c71:	39 c2                	cmp    %eax,%edx
f0101c73:	0f 85 a6 07 00 00    	jne    f010241f <mem_init+0x1275>
	kern_pgdir[0] = 0;
f0101c79:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101c7f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c82:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c87:	0f 85 ab 07 00 00    	jne    f0102438 <mem_init+0x128e>
	pp0->pp_ref = 0;
f0101c8d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c90:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101c96:	83 ec 0c             	sub    $0xc,%esp
f0101c99:	50                   	push   %eax
f0101c9a:	e8 e3 f1 ff ff       	call   f0100e82 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101c9f:	83 c4 0c             	add    $0xc,%esp
f0101ca2:	6a 01                	push   $0x1
f0101ca4:	68 00 10 40 00       	push   $0x401000
f0101ca9:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101caf:	e8 51 f2 ff ff       	call   f0100f05 <pgdir_walk>
f0101cb4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101cb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101cba:	8b 0d 0c cb 18 f0    	mov    0xf018cb0c,%ecx
f0101cc0:	8b 41 04             	mov    0x4(%ecx),%eax
f0101cc3:	89 c6                	mov    %eax,%esi
f0101cc5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101ccb:	8b 15 08 cb 18 f0    	mov    0xf018cb08,%edx
f0101cd1:	c1 e8 0c             	shr    $0xc,%eax
f0101cd4:	83 c4 10             	add    $0x10,%esp
f0101cd7:	39 d0                	cmp    %edx,%eax
f0101cd9:	0f 83 72 07 00 00    	jae    f0102451 <mem_init+0x12a7>
	assert(ptep == ptep1 + PTX(va));
f0101cdf:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101ce5:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0101ce8:	0f 85 78 07 00 00    	jne    f0102466 <mem_init+0x12bc>
	kern_pgdir[PDX(va)] = 0;
f0101cee:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101cf5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cf8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101cfe:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0101d04:	c1 f8 03             	sar    $0x3,%eax
f0101d07:	89 c1                	mov    %eax,%ecx
f0101d09:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101d0c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101d11:	39 c2                	cmp    %eax,%edx
f0101d13:	0f 86 66 07 00 00    	jbe    f010247f <mem_init+0x12d5>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101d19:	83 ec 04             	sub    $0x4,%esp
f0101d1c:	68 00 10 00 00       	push   $0x1000
f0101d21:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101d26:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101d2c:	51                   	push   %ecx
f0101d2d:	e8 1c 2b 00 00       	call   f010484e <memset>
	page_free(pp0);
f0101d32:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101d35:	89 34 24             	mov    %esi,(%esp)
f0101d38:	e8 45 f1 ff ff       	call   f0100e82 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101d3d:	83 c4 0c             	add    $0xc,%esp
f0101d40:	6a 01                	push   $0x1
f0101d42:	6a 00                	push   $0x0
f0101d44:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0101d4a:	e8 b6 f1 ff ff       	call   f0100f05 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101d4f:	89 f0                	mov    %esi,%eax
f0101d51:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0101d57:	c1 f8 03             	sar    $0x3,%eax
f0101d5a:	89 c2                	mov    %eax,%edx
f0101d5c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101d5f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101d64:	83 c4 10             	add    $0x10,%esp
f0101d67:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0101d6d:	0f 83 1e 07 00 00    	jae    f0102491 <mem_init+0x12e7>
	return (void *)(pa + KERNBASE);
f0101d73:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101d79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101d7c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101d82:	8b 30                	mov    (%eax),%esi
f0101d84:	83 e6 01             	and    $0x1,%esi
f0101d87:	0f 85 16 07 00 00    	jne    f01024a3 <mem_init+0x12f9>
f0101d8d:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101d90:	39 d0                	cmp    %edx,%eax
f0101d92:	75 ee                	jne    f0101d82 <mem_init+0xbd8>
	kern_pgdir[0] = 0;
f0101d94:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f0101d99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101d9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101da8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101dab:	89 0d 44 be 18 f0    	mov    %ecx,0xf018be44

	// free the pages we took
	page_free(pp0);
f0101db1:	83 ec 0c             	sub    $0xc,%esp
f0101db4:	50                   	push   %eax
f0101db5:	e8 c8 f0 ff ff       	call   f0100e82 <page_free>
	page_free(pp1);
f0101dba:	89 3c 24             	mov    %edi,(%esp)
f0101dbd:	e8 c0 f0 ff ff       	call   f0100e82 <page_free>
	page_free(pp2);
f0101dc2:	89 1c 24             	mov    %ebx,(%esp)
f0101dc5:	e8 b8 f0 ff ff       	call   f0100e82 <page_free>

	cprintf("check_page() succeeded!\n");
f0101dca:	c7 04 24 21 5d 10 f0 	movl   $0xf0105d21,(%esp)
f0101dd1:	e8 60 15 00 00       	call   f0103336 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0101dd6:	a1 10 cb 18 f0       	mov    0xf018cb10,%eax
	if ((uint32_t)kva < KERNBASE)
f0101ddb:	83 c4 10             	add    $0x10,%esp
f0101dde:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101de3:	0f 86 d3 06 00 00    	jbe    f01024bc <mem_init+0x1312>
f0101de9:	83 ec 08             	sub    $0x8,%esp
f0101dec:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0101dee:	05 00 00 00 10       	add    $0x10000000,%eax
f0101df3:	50                   	push   %eax
f0101df4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101df9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101dfe:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f0101e03:	e8 27 f2 ff ff       	call   f010102f <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f0101e08:	a1 50 be 18 f0       	mov    0xf018be50,%eax
	if ((uint32_t)kva < KERNBASE)
f0101e0d:	83 c4 10             	add    $0x10,%esp
f0101e10:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e15:	0f 86 b6 06 00 00    	jbe    f01024d1 <mem_init+0x1327>
f0101e1b:	83 ec 08             	sub    $0x8,%esp
f0101e1e:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101e20:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e25:	50                   	push   %eax
f0101e26:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101e2b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101e30:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f0101e35:	e8 f5 f1 ff ff       	call   f010102f <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101e3a:	83 c4 10             	add    $0x10,%esp
f0101e3d:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f0101e42:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e47:	0f 86 99 06 00 00    	jbe    f01024e6 <mem_init+0x133c>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0101e4d:	83 ec 08             	sub    $0x8,%esp
f0101e50:	6a 02                	push   $0x2
f0101e52:	68 00 30 11 00       	push   $0x113000
f0101e57:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101e5c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101e61:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f0101e66:	e8 c4 f1 ff ff       	call   f010102f <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0x100000000 - KERNBASE, 0, PTE_W);
f0101e6b:	83 c4 08             	add    $0x8,%esp
f0101e6e:	6a 02                	push   $0x2
f0101e70:	6a 00                	push   $0x0
f0101e72:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101e77:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101e7c:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f0101e81:	e8 a9 f1 ff ff       	call   f010102f <boot_map_region>
	pgdir = kern_pgdir;
f0101e86:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
f0101e8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101e8e:	a1 08 cb 18 f0       	mov    0xf018cb08,%eax
f0101e93:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101e96:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101e9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101ea2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101ea5:	8b 3d 10 cb 18 f0    	mov    0xf018cb10,%edi
f0101eab:	89 7d cc             	mov    %edi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101eae:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0101eb4:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0101eb7:	83 c4 10             	add    $0x10,%esp
f0101eba:	89 f3                	mov    %esi,%ebx
f0101ebc:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0101ebf:	0f 86 64 06 00 00    	jbe    f0102529 <mem_init+0x137f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101ec5:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0101ecb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ece:	e8 0a eb ff ff       	call   f01009dd <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101ed3:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0101eda:	0f 86 1b 06 00 00    	jbe    f01024fb <mem_init+0x1351>
f0101ee0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101ee3:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0101ee6:	39 d0                	cmp    %edx,%eax
f0101ee8:	0f 85 22 06 00 00    	jne    f0102510 <mem_init+0x1366>
	for (i = 0; i < n; i += PGSIZE)
f0101eee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101ef4:	eb c6                	jmp    f0101ebc <mem_init+0xd12>
	assert(nfree == 0);
f0101ef6:	68 4a 5c 10 f0       	push   $0xf0105c4a
f0101efb:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101f00:	68 85 03 00 00       	push   $0x385
f0101f05:	68 71 5a 10 f0       	push   $0xf0105a71
f0101f0a:	e8 95 e1 ff ff       	call   f01000a4 <_panic>
	assert((pp0 = page_alloc(0)));
f0101f0f:	68 58 5b 10 f0       	push   $0xf0105b58
f0101f14:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101f19:	68 e3 03 00 00       	push   $0x3e3
f0101f1e:	68 71 5a 10 f0       	push   $0xf0105a71
f0101f23:	e8 7c e1 ff ff       	call   f01000a4 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f28:	68 6e 5b 10 f0       	push   $0xf0105b6e
f0101f2d:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101f32:	68 e4 03 00 00       	push   $0x3e4
f0101f37:	68 71 5a 10 f0       	push   $0xf0105a71
f0101f3c:	e8 63 e1 ff ff       	call   f01000a4 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f41:	68 84 5b 10 f0       	push   $0xf0105b84
f0101f46:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101f4b:	68 e5 03 00 00       	push   $0x3e5
f0101f50:	68 71 5a 10 f0       	push   $0xf0105a71
f0101f55:	e8 4a e1 ff ff       	call   f01000a4 <_panic>
	assert(pp1 && pp1 != pp0);
f0101f5a:	68 9a 5b 10 f0       	push   $0xf0105b9a
f0101f5f:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101f64:	68 e8 03 00 00       	push   $0x3e8
f0101f69:	68 71 5a 10 f0       	push   $0xf0105a71
f0101f6e:	e8 31 e1 ff ff       	call   f01000a4 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f73:	68 1c 54 10 f0       	push   $0xf010541c
f0101f78:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101f7d:	68 e9 03 00 00       	push   $0x3e9
f0101f82:	68 71 5a 10 f0       	push   $0xf0105a71
f0101f87:	e8 18 e1 ff ff       	call   f01000a4 <_panic>
	assert(!page_alloc(0));
f0101f8c:	68 03 5c 10 f0       	push   $0xf0105c03
f0101f91:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101f96:	68 f0 03 00 00       	push   $0x3f0
f0101f9b:	68 71 5a 10 f0       	push   $0xf0105a71
f0101fa0:	e8 ff e0 ff ff       	call   f01000a4 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101fa5:	68 5c 54 10 f0       	push   $0xf010545c
f0101faa:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101faf:	68 f3 03 00 00       	push   $0x3f3
f0101fb4:	68 71 5a 10 f0       	push   $0xf0105a71
f0101fb9:	e8 e6 e0 ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101fbe:	68 94 54 10 f0       	push   $0xf0105494
f0101fc3:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101fc8:	68 f6 03 00 00       	push   $0x3f6
f0101fcd:	68 71 5a 10 f0       	push   $0xf0105a71
f0101fd2:	e8 cd e0 ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101fd7:	68 c4 54 10 f0       	push   $0xf01054c4
f0101fdc:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101fe1:	68 fa 03 00 00       	push   $0x3fa
f0101fe6:	68 71 5a 10 f0       	push   $0xf0105a71
f0101feb:	e8 b4 e0 ff ff       	call   f01000a4 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ff0:	68 f4 54 10 f0       	push   $0xf01054f4
f0101ff5:	68 ad 5a 10 f0       	push   $0xf0105aad
f0101ffa:	68 fb 03 00 00       	push   $0x3fb
f0101fff:	68 71 5a 10 f0       	push   $0xf0105a71
f0102004:	e8 9b e0 ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102009:	68 1c 55 10 f0       	push   $0xf010551c
f010200e:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102013:	68 fc 03 00 00       	push   $0x3fc
f0102018:	68 71 5a 10 f0       	push   $0xf0105a71
f010201d:	e8 82 e0 ff ff       	call   f01000a4 <_panic>
	assert(pp1->pp_ref == 1);
f0102022:	68 55 5c 10 f0       	push   $0xf0105c55
f0102027:	68 ad 5a 10 f0       	push   $0xf0105aad
f010202c:	68 fd 03 00 00       	push   $0x3fd
f0102031:	68 71 5a 10 f0       	push   $0xf0105a71
f0102036:	e8 69 e0 ff ff       	call   f01000a4 <_panic>
	assert(pp0->pp_ref == 1);
f010203b:	68 66 5c 10 f0       	push   $0xf0105c66
f0102040:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102045:	68 fe 03 00 00       	push   $0x3fe
f010204a:	68 71 5a 10 f0       	push   $0xf0105a71
f010204f:	e8 50 e0 ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102054:	68 4c 55 10 f0       	push   $0xf010554c
f0102059:	68 ad 5a 10 f0       	push   $0xf0105aad
f010205e:	68 01 04 00 00       	push   $0x401
f0102063:	68 71 5a 10 f0       	push   $0xf0105a71
f0102068:	e8 37 e0 ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010206d:	68 88 55 10 f0       	push   $0xf0105588
f0102072:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102077:	68 02 04 00 00       	push   $0x402
f010207c:	68 71 5a 10 f0       	push   $0xf0105a71
f0102081:	e8 1e e0 ff ff       	call   f01000a4 <_panic>
	assert(pp2->pp_ref == 1);
f0102086:	68 77 5c 10 f0       	push   $0xf0105c77
f010208b:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102090:	68 03 04 00 00       	push   $0x403
f0102095:	68 71 5a 10 f0       	push   $0xf0105a71
f010209a:	e8 05 e0 ff ff       	call   f01000a4 <_panic>
	assert(!page_alloc(0));
f010209f:	68 03 5c 10 f0       	push   $0xf0105c03
f01020a4:	68 ad 5a 10 f0       	push   $0xf0105aad
f01020a9:	68 06 04 00 00       	push   $0x406
f01020ae:	68 71 5a 10 f0       	push   $0xf0105a71
f01020b3:	e8 ec df ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020b8:	68 4c 55 10 f0       	push   $0xf010554c
f01020bd:	68 ad 5a 10 f0       	push   $0xf0105aad
f01020c2:	68 09 04 00 00       	push   $0x409
f01020c7:	68 71 5a 10 f0       	push   $0xf0105a71
f01020cc:	e8 d3 df ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020d1:	68 88 55 10 f0       	push   $0xf0105588
f01020d6:	68 ad 5a 10 f0       	push   $0xf0105aad
f01020db:	68 0a 04 00 00       	push   $0x40a
f01020e0:	68 71 5a 10 f0       	push   $0xf0105a71
f01020e5:	e8 ba df ff ff       	call   f01000a4 <_panic>
	assert(pp2->pp_ref == 1);
f01020ea:	68 77 5c 10 f0       	push   $0xf0105c77
f01020ef:	68 ad 5a 10 f0       	push   $0xf0105aad
f01020f4:	68 0b 04 00 00       	push   $0x40b
f01020f9:	68 71 5a 10 f0       	push   $0xf0105a71
f01020fe:	e8 a1 df ff ff       	call   f01000a4 <_panic>
	assert(!page_alloc(0));
f0102103:	68 03 5c 10 f0       	push   $0xf0105c03
f0102108:	68 ad 5a 10 f0       	push   $0xf0105aad
f010210d:	68 0f 04 00 00       	push   $0x40f
f0102112:	68 71 5a 10 f0       	push   $0xf0105a71
f0102117:	e8 88 df ff ff       	call   f01000a4 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010211c:	52                   	push   %edx
f010211d:	68 14 52 10 f0       	push   $0xf0105214
f0102122:	68 12 04 00 00       	push   $0x412
f0102127:	68 71 5a 10 f0       	push   $0xf0105a71
f010212c:	e8 73 df ff ff       	call   f01000a4 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102131:	68 b8 55 10 f0       	push   $0xf01055b8
f0102136:	68 ad 5a 10 f0       	push   $0xf0105aad
f010213b:	68 13 04 00 00       	push   $0x413
f0102140:	68 71 5a 10 f0       	push   $0xf0105a71
f0102145:	e8 5a df ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010214a:	68 f8 55 10 f0       	push   $0xf01055f8
f010214f:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102154:	68 16 04 00 00       	push   $0x416
f0102159:	68 71 5a 10 f0       	push   $0xf0105a71
f010215e:	e8 41 df ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102163:	68 88 55 10 f0       	push   $0xf0105588
f0102168:	68 ad 5a 10 f0       	push   $0xf0105aad
f010216d:	68 17 04 00 00       	push   $0x417
f0102172:	68 71 5a 10 f0       	push   $0xf0105a71
f0102177:	e8 28 df ff ff       	call   f01000a4 <_panic>
	assert(pp2->pp_ref == 1);
f010217c:	68 77 5c 10 f0       	push   $0xf0105c77
f0102181:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102186:	68 18 04 00 00       	push   $0x418
f010218b:	68 71 5a 10 f0       	push   $0xf0105a71
f0102190:	e8 0f df ff ff       	call   f01000a4 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102195:	68 38 56 10 f0       	push   $0xf0105638
f010219a:	68 ad 5a 10 f0       	push   $0xf0105aad
f010219f:	68 19 04 00 00       	push   $0x419
f01021a4:	68 71 5a 10 f0       	push   $0xf0105a71
f01021a9:	e8 f6 de ff ff       	call   f01000a4 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01021ae:	68 88 5c 10 f0       	push   $0xf0105c88
f01021b3:	68 ad 5a 10 f0       	push   $0xf0105aad
f01021b8:	68 1a 04 00 00       	push   $0x41a
f01021bd:	68 71 5a 10 f0       	push   $0xf0105a71
f01021c2:	e8 dd de ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021c7:	68 4c 55 10 f0       	push   $0xf010554c
f01021cc:	68 ad 5a 10 f0       	push   $0xf0105aad
f01021d1:	68 1d 04 00 00       	push   $0x41d
f01021d6:	68 71 5a 10 f0       	push   $0xf0105a71
f01021db:	e8 c4 de ff ff       	call   f01000a4 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01021e0:	68 6c 56 10 f0       	push   $0xf010566c
f01021e5:	68 ad 5a 10 f0       	push   $0xf0105aad
f01021ea:	68 1e 04 00 00       	push   $0x41e
f01021ef:	68 71 5a 10 f0       	push   $0xf0105a71
f01021f4:	e8 ab de ff ff       	call   f01000a4 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021f9:	68 a0 56 10 f0       	push   $0xf01056a0
f01021fe:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102203:	68 1f 04 00 00       	push   $0x41f
f0102208:	68 71 5a 10 f0       	push   $0xf0105a71
f010220d:	e8 92 de ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102212:	68 d8 56 10 f0       	push   $0xf01056d8
f0102217:	68 ad 5a 10 f0       	push   $0xf0105aad
f010221c:	68 22 04 00 00       	push   $0x422
f0102221:	68 71 5a 10 f0       	push   $0xf0105a71
f0102226:	e8 79 de ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010222b:	68 10 57 10 f0       	push   $0xf0105710
f0102230:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102235:	68 25 04 00 00       	push   $0x425
f010223a:	68 71 5a 10 f0       	push   $0xf0105a71
f010223f:	e8 60 de ff ff       	call   f01000a4 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102244:	68 a0 56 10 f0       	push   $0xf01056a0
f0102249:	68 ad 5a 10 f0       	push   $0xf0105aad
f010224e:	68 26 04 00 00       	push   $0x426
f0102253:	68 71 5a 10 f0       	push   $0xf0105a71
f0102258:	e8 47 de ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010225d:	68 4c 57 10 f0       	push   $0xf010574c
f0102262:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102267:	68 29 04 00 00       	push   $0x429
f010226c:	68 71 5a 10 f0       	push   $0xf0105a71
f0102271:	e8 2e de ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102276:	68 78 57 10 f0       	push   $0xf0105778
f010227b:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102280:	68 2a 04 00 00       	push   $0x42a
f0102285:	68 71 5a 10 f0       	push   $0xf0105a71
f010228a:	e8 15 de ff ff       	call   f01000a4 <_panic>
	assert(pp1->pp_ref == 2);
f010228f:	68 9e 5c 10 f0       	push   $0xf0105c9e
f0102294:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102299:	68 2c 04 00 00       	push   $0x42c
f010229e:	68 71 5a 10 f0       	push   $0xf0105a71
f01022a3:	e8 fc dd ff ff       	call   f01000a4 <_panic>
	assert(pp2->pp_ref == 0);
f01022a8:	68 af 5c 10 f0       	push   $0xf0105caf
f01022ad:	68 ad 5a 10 f0       	push   $0xf0105aad
f01022b2:	68 2d 04 00 00       	push   $0x42d
f01022b7:	68 71 5a 10 f0       	push   $0xf0105a71
f01022bc:	e8 e3 dd ff ff       	call   f01000a4 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01022c1:	68 a8 57 10 f0       	push   $0xf01057a8
f01022c6:	68 ad 5a 10 f0       	push   $0xf0105aad
f01022cb:	68 30 04 00 00       	push   $0x430
f01022d0:	68 71 5a 10 f0       	push   $0xf0105a71
f01022d5:	e8 ca dd ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022da:	68 cc 57 10 f0       	push   $0xf01057cc
f01022df:	68 ad 5a 10 f0       	push   $0xf0105aad
f01022e4:	68 34 04 00 00       	push   $0x434
f01022e9:	68 71 5a 10 f0       	push   $0xf0105a71
f01022ee:	e8 b1 dd ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022f3:	68 78 57 10 f0       	push   $0xf0105778
f01022f8:	68 ad 5a 10 f0       	push   $0xf0105aad
f01022fd:	68 35 04 00 00       	push   $0x435
f0102302:	68 71 5a 10 f0       	push   $0xf0105a71
f0102307:	e8 98 dd ff ff       	call   f01000a4 <_panic>
	assert(pp1->pp_ref == 1);
f010230c:	68 55 5c 10 f0       	push   $0xf0105c55
f0102311:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102316:	68 36 04 00 00       	push   $0x436
f010231b:	68 71 5a 10 f0       	push   $0xf0105a71
f0102320:	e8 7f dd ff ff       	call   f01000a4 <_panic>
	assert(pp2->pp_ref == 0);
f0102325:	68 af 5c 10 f0       	push   $0xf0105caf
f010232a:	68 ad 5a 10 f0       	push   $0xf0105aad
f010232f:	68 37 04 00 00       	push   $0x437
f0102334:	68 71 5a 10 f0       	push   $0xf0105a71
f0102339:	e8 66 dd ff ff       	call   f01000a4 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010233e:	68 f0 57 10 f0       	push   $0xf01057f0
f0102343:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102348:	68 3a 04 00 00       	push   $0x43a
f010234d:	68 71 5a 10 f0       	push   $0xf0105a71
f0102352:	e8 4d dd ff ff       	call   f01000a4 <_panic>
	assert(pp1->pp_ref);
f0102357:	68 c0 5c 10 f0       	push   $0xf0105cc0
f010235c:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102361:	68 3b 04 00 00       	push   $0x43b
f0102366:	68 71 5a 10 f0       	push   $0xf0105a71
f010236b:	e8 34 dd ff ff       	call   f01000a4 <_panic>
	assert(pp1->pp_link == NULL);
f0102370:	68 cc 5c 10 f0       	push   $0xf0105ccc
f0102375:	68 ad 5a 10 f0       	push   $0xf0105aad
f010237a:	68 3c 04 00 00       	push   $0x43c
f010237f:	68 71 5a 10 f0       	push   $0xf0105a71
f0102384:	e8 1b dd ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102389:	68 cc 57 10 f0       	push   $0xf01057cc
f010238e:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102393:	68 40 04 00 00       	push   $0x440
f0102398:	68 71 5a 10 f0       	push   $0xf0105a71
f010239d:	e8 02 dd ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01023a2:	68 28 58 10 f0       	push   $0xf0105828
f01023a7:	68 ad 5a 10 f0       	push   $0xf0105aad
f01023ac:	68 41 04 00 00       	push   $0x441
f01023b1:	68 71 5a 10 f0       	push   $0xf0105a71
f01023b6:	e8 e9 dc ff ff       	call   f01000a4 <_panic>
	assert(pp1->pp_ref == 0);
f01023bb:	68 e1 5c 10 f0       	push   $0xf0105ce1
f01023c0:	68 ad 5a 10 f0       	push   $0xf0105aad
f01023c5:	68 42 04 00 00       	push   $0x442
f01023ca:	68 71 5a 10 f0       	push   $0xf0105a71
f01023cf:	e8 d0 dc ff ff       	call   f01000a4 <_panic>
	assert(pp2->pp_ref == 0);
f01023d4:	68 af 5c 10 f0       	push   $0xf0105caf
f01023d9:	68 ad 5a 10 f0       	push   $0xf0105aad
f01023de:	68 43 04 00 00       	push   $0x443
f01023e3:	68 71 5a 10 f0       	push   $0xf0105a71
f01023e8:	e8 b7 dc ff ff       	call   f01000a4 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01023ed:	68 50 58 10 f0       	push   $0xf0105850
f01023f2:	68 ad 5a 10 f0       	push   $0xf0105aad
f01023f7:	68 46 04 00 00       	push   $0x446
f01023fc:	68 71 5a 10 f0       	push   $0xf0105a71
f0102401:	e8 9e dc ff ff       	call   f01000a4 <_panic>
	assert(!page_alloc(0));
f0102406:	68 03 5c 10 f0       	push   $0xf0105c03
f010240b:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102410:	68 49 04 00 00       	push   $0x449
f0102415:	68 71 5a 10 f0       	push   $0xf0105a71
f010241a:	e8 85 dc ff ff       	call   f01000a4 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010241f:	68 f4 54 10 f0       	push   $0xf01054f4
f0102424:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102429:	68 4c 04 00 00       	push   $0x44c
f010242e:	68 71 5a 10 f0       	push   $0xf0105a71
f0102433:	e8 6c dc ff ff       	call   f01000a4 <_panic>
	assert(pp0->pp_ref == 1);
f0102438:	68 66 5c 10 f0       	push   $0xf0105c66
f010243d:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102442:	68 4e 04 00 00       	push   $0x44e
f0102447:	68 71 5a 10 f0       	push   $0xf0105a71
f010244c:	e8 53 dc ff ff       	call   f01000a4 <_panic>
f0102451:	56                   	push   %esi
f0102452:	68 14 52 10 f0       	push   $0xf0105214
f0102457:	68 55 04 00 00       	push   $0x455
f010245c:	68 71 5a 10 f0       	push   $0xf0105a71
f0102461:	e8 3e dc ff ff       	call   f01000a4 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102466:	68 f2 5c 10 f0       	push   $0xf0105cf2
f010246b:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102470:	68 56 04 00 00       	push   $0x456
f0102475:	68 71 5a 10 f0       	push   $0xf0105a71
f010247a:	e8 25 dc ff ff       	call   f01000a4 <_panic>
f010247f:	51                   	push   %ecx
f0102480:	68 14 52 10 f0       	push   $0xf0105214
f0102485:	6a 56                	push   $0x56
f0102487:	68 93 5a 10 f0       	push   $0xf0105a93
f010248c:	e8 13 dc ff ff       	call   f01000a4 <_panic>
f0102491:	52                   	push   %edx
f0102492:	68 14 52 10 f0       	push   $0xf0105214
f0102497:	6a 56                	push   $0x56
f0102499:	68 93 5a 10 f0       	push   $0xf0105a93
f010249e:	e8 01 dc ff ff       	call   f01000a4 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01024a3:	68 0a 5d 10 f0       	push   $0xf0105d0a
f01024a8:	68 ad 5a 10 f0       	push   $0xf0105aad
f01024ad:	68 60 04 00 00       	push   $0x460
f01024b2:	68 71 5a 10 f0       	push   $0xf0105a71
f01024b7:	e8 e8 db ff ff       	call   f01000a4 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024bc:	50                   	push   %eax
f01024bd:	68 20 53 10 f0       	push   $0xf0105320
f01024c2:	68 ef 00 00 00       	push   $0xef
f01024c7:	68 71 5a 10 f0       	push   $0xf0105a71
f01024cc:	e8 d3 db ff ff       	call   f01000a4 <_panic>
f01024d1:	50                   	push   %eax
f01024d2:	68 20 53 10 f0       	push   $0xf0105320
f01024d7:	68 ff 00 00 00       	push   $0xff
f01024dc:	68 71 5a 10 f0       	push   $0xf0105a71
f01024e1:	e8 be db ff ff       	call   f01000a4 <_panic>
f01024e6:	50                   	push   %eax
f01024e7:	68 20 53 10 f0       	push   $0xf0105320
f01024ec:	68 10 01 00 00       	push   $0x110
f01024f1:	68 71 5a 10 f0       	push   $0xf0105a71
f01024f6:	e8 a9 db ff ff       	call   f01000a4 <_panic>
f01024fb:	57                   	push   %edi
f01024fc:	68 20 53 10 f0       	push   $0xf0105320
f0102501:	68 9d 03 00 00       	push   $0x39d
f0102506:	68 71 5a 10 f0       	push   $0xf0105a71
f010250b:	e8 94 db ff ff       	call   f01000a4 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102510:	68 74 58 10 f0       	push   $0xf0105874
f0102515:	68 ad 5a 10 f0       	push   $0xf0105aad
f010251a:	68 9d 03 00 00       	push   $0x39d
f010251f:	68 71 5a 10 f0       	push   $0xf0105a71
f0102524:	e8 7b db ff ff       	call   f01000a4 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102529:	a1 50 be 18 f0       	mov    0xf018be50,%eax
f010252e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102531:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102534:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102539:	8d b8 00 00 40 21    	lea    0x21400000(%eax),%edi
f010253f:	89 da                	mov    %ebx,%edx
f0102541:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102544:	e8 94 e4 ff ff       	call   f01009dd <check_va2pa>
f0102549:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102550:	76 3b                	jbe    f010258d <mem_init+0x13e3>
f0102552:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102555:	39 d0                	cmp    %edx,%eax
f0102557:	75 4b                	jne    f01025a4 <mem_init+0x13fa>
f0102559:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f010255f:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f0102565:	75 d8                	jne    f010253f <mem_init+0x1395>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102567:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010256a:	c1 e7 0c             	shl    $0xc,%edi
f010256d:	89 f3                	mov    %esi,%ebx
f010256f:	39 fb                	cmp    %edi,%ebx
f0102571:	73 63                	jae    f01025d6 <mem_init+0x142c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102573:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102579:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010257c:	e8 5c e4 ff ff       	call   f01009dd <check_va2pa>
f0102581:	39 c3                	cmp    %eax,%ebx
f0102583:	75 38                	jne    f01025bd <mem_init+0x1413>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102585:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010258b:	eb e2                	jmp    f010256f <mem_init+0x13c5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010258d:	ff 75 cc             	pushl  -0x34(%ebp)
f0102590:	68 20 53 10 f0       	push   $0xf0105320
f0102595:	68 a2 03 00 00       	push   $0x3a2
f010259a:	68 71 5a 10 f0       	push   $0xf0105a71
f010259f:	e8 00 db ff ff       	call   f01000a4 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01025a4:	68 a8 58 10 f0       	push   $0xf01058a8
f01025a9:	68 ad 5a 10 f0       	push   $0xf0105aad
f01025ae:	68 a2 03 00 00       	push   $0x3a2
f01025b3:	68 71 5a 10 f0       	push   $0xf0105a71
f01025b8:	e8 e7 da ff ff       	call   f01000a4 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01025bd:	68 dc 58 10 f0       	push   $0xf01058dc
f01025c2:	68 ad 5a 10 f0       	push   $0xf0105aad
f01025c7:	68 a6 03 00 00       	push   $0x3a6
f01025cc:	68 71 5a 10 f0       	push   $0xf0105a71
f01025d1:	e8 ce da ff ff       	call   f01000a4 <_panic>
f01025d6:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01025db:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f01025e0:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f01025e6:	89 da                	mov    %ebx,%edx
f01025e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025eb:	e8 ed e3 ff ff       	call   f01009dd <check_va2pa>
f01025f0:	89 c2                	mov    %eax,%edx
f01025f2:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01025f5:	39 c2                	cmp    %eax,%edx
f01025f7:	75 25                	jne    f010261e <mem_init+0x1474>
f01025f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01025ff:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102605:	75 df                	jne    f01025e6 <mem_init+0x143c>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102607:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010260c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010260f:	e8 c9 e3 ff ff       	call   f01009dd <check_va2pa>
f0102614:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102617:	75 1e                	jne    f0102637 <mem_init+0x148d>
f0102619:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010261c:	eb 5f                	jmp    f010267d <mem_init+0x14d3>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010261e:	68 04 59 10 f0       	push   $0xf0105904
f0102623:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102628:	68 aa 03 00 00       	push   $0x3aa
f010262d:	68 71 5a 10 f0       	push   $0xf0105a71
f0102632:	e8 6d da ff ff       	call   f01000a4 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102637:	68 4c 59 10 f0       	push   $0xf010594c
f010263c:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102641:	68 ab 03 00 00       	push   $0x3ab
f0102646:	68 71 5a 10 f0       	push   $0xf0105a71
f010264b:	e8 54 da ff ff       	call   f01000a4 <_panic>
		switch (i) {
f0102650:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102656:	75 25                	jne    f010267d <mem_init+0x14d3>
			assert(pgdir[i] & PTE_P);
f0102658:	f6 04 b0 01          	testb  $0x1,(%eax,%esi,4)
f010265c:	74 46                	je     f01026a4 <mem_init+0x14fa>
	for (i = 0; i < NPDENTRIES; i++) {
f010265e:	83 c6 01             	add    $0x1,%esi
f0102661:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102667:	0f 87 8f 00 00 00    	ja     f01026fc <mem_init+0x1552>
		switch (i) {
f010266d:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102673:	77 db                	ja     f0102650 <mem_init+0x14a6>
f0102675:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f010267b:	77 db                	ja     f0102658 <mem_init+0x14ae>
			if (i >= PDX(KERNBASE)) {
f010267d:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102683:	77 38                	ja     f01026bd <mem_init+0x1513>
				assert(pgdir[i] == 0);
f0102685:	83 3c b0 00          	cmpl   $0x0,(%eax,%esi,4)
f0102689:	74 d3                	je     f010265e <mem_init+0x14b4>
f010268b:	68 5c 5d 10 f0       	push   $0xf0105d5c
f0102690:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102695:	68 bb 03 00 00       	push   $0x3bb
f010269a:	68 71 5a 10 f0       	push   $0xf0105a71
f010269f:	e8 00 da ff ff       	call   f01000a4 <_panic>
			assert(pgdir[i] & PTE_P);
f01026a4:	68 3a 5d 10 f0       	push   $0xf0105d3a
f01026a9:	68 ad 5a 10 f0       	push   $0xf0105aad
f01026ae:	68 b4 03 00 00       	push   $0x3b4
f01026b3:	68 71 5a 10 f0       	push   $0xf0105a71
f01026b8:	e8 e7 d9 ff ff       	call   f01000a4 <_panic>
				assert(pgdir[i] & PTE_P);
f01026bd:	8b 14 b0             	mov    (%eax,%esi,4),%edx
f01026c0:	f6 c2 01             	test   $0x1,%dl
f01026c3:	74 1e                	je     f01026e3 <mem_init+0x1539>
				assert(pgdir[i] & PTE_W);
f01026c5:	f6 c2 02             	test   $0x2,%dl
f01026c8:	75 94                	jne    f010265e <mem_init+0x14b4>
f01026ca:	68 4b 5d 10 f0       	push   $0xf0105d4b
f01026cf:	68 ad 5a 10 f0       	push   $0xf0105aad
f01026d4:	68 b9 03 00 00       	push   $0x3b9
f01026d9:	68 71 5a 10 f0       	push   $0xf0105a71
f01026de:	e8 c1 d9 ff ff       	call   f01000a4 <_panic>
				assert(pgdir[i] & PTE_P);
f01026e3:	68 3a 5d 10 f0       	push   $0xf0105d3a
f01026e8:	68 ad 5a 10 f0       	push   $0xf0105aad
f01026ed:	68 b8 03 00 00       	push   $0x3b8
f01026f2:	68 71 5a 10 f0       	push   $0xf0105a71
f01026f7:	e8 a8 d9 ff ff       	call   f01000a4 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01026fc:	83 ec 0c             	sub    $0xc,%esp
f01026ff:	68 7c 59 10 f0       	push   $0xf010597c
f0102704:	e8 2d 0c 00 00       	call   f0103336 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102709:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
	if ((uint32_t)kva < KERNBASE)
f010270e:	83 c4 10             	add    $0x10,%esp
f0102711:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102716:	0f 86 06 02 00 00    	jbe    f0102922 <mem_init+0x1778>
	return (physaddr_t)kva - KERNBASE;
f010271c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102721:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102724:	b8 00 00 00 00       	mov    $0x0,%eax
f0102729:	e8 12 e3 ff ff       	call   f0100a40 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010272e:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102731:	83 e0 f3             	and    $0xfffffff3,%eax
f0102734:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102739:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010273c:	83 ec 0c             	sub    $0xc,%esp
f010273f:	6a 00                	push   $0x0
f0102741:	e8 c3 e6 ff ff       	call   f0100e09 <page_alloc>
f0102746:	89 c3                	mov    %eax,%ebx
f0102748:	83 c4 10             	add    $0x10,%esp
f010274b:	85 c0                	test   %eax,%eax
f010274d:	0f 84 e4 01 00 00    	je     f0102937 <mem_init+0x178d>
	assert((pp1 = page_alloc(0)));
f0102753:	83 ec 0c             	sub    $0xc,%esp
f0102756:	6a 00                	push   $0x0
f0102758:	e8 ac e6 ff ff       	call   f0100e09 <page_alloc>
f010275d:	89 c7                	mov    %eax,%edi
f010275f:	83 c4 10             	add    $0x10,%esp
f0102762:	85 c0                	test   %eax,%eax
f0102764:	0f 84 e6 01 00 00    	je     f0102950 <mem_init+0x17a6>
	assert((pp2 = page_alloc(0)));
f010276a:	83 ec 0c             	sub    $0xc,%esp
f010276d:	6a 00                	push   $0x0
f010276f:	e8 95 e6 ff ff       	call   f0100e09 <page_alloc>
f0102774:	89 c6                	mov    %eax,%esi
f0102776:	83 c4 10             	add    $0x10,%esp
f0102779:	85 c0                	test   %eax,%eax
f010277b:	0f 84 e8 01 00 00    	je     f0102969 <mem_init+0x17bf>
	page_free(pp0);
f0102781:	83 ec 0c             	sub    $0xc,%esp
f0102784:	53                   	push   %ebx
f0102785:	e8 f8 e6 ff ff       	call   f0100e82 <page_free>
	return (pp - pages) << PGSHIFT;
f010278a:	89 f8                	mov    %edi,%eax
f010278c:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0102792:	c1 f8 03             	sar    $0x3,%eax
f0102795:	89 c2                	mov    %eax,%edx
f0102797:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010279a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010279f:	83 c4 10             	add    $0x10,%esp
f01027a2:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f01027a8:	0f 83 d4 01 00 00    	jae    f0102982 <mem_init+0x17d8>
	memset(page2kva(pp1), 1, PGSIZE);
f01027ae:	83 ec 04             	sub    $0x4,%esp
f01027b1:	68 00 10 00 00       	push   $0x1000
f01027b6:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01027b8:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01027be:	52                   	push   %edx
f01027bf:	e8 8a 20 00 00       	call   f010484e <memset>
	return (pp - pages) << PGSHIFT;
f01027c4:	89 f0                	mov    %esi,%eax
f01027c6:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f01027cc:	c1 f8 03             	sar    $0x3,%eax
f01027cf:	89 c2                	mov    %eax,%edx
f01027d1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01027d4:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01027d9:	83 c4 10             	add    $0x10,%esp
f01027dc:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f01027e2:	0f 83 ac 01 00 00    	jae    f0102994 <mem_init+0x17ea>
	memset(page2kva(pp2), 2, PGSIZE);
f01027e8:	83 ec 04             	sub    $0x4,%esp
f01027eb:	68 00 10 00 00       	push   $0x1000
f01027f0:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01027f2:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01027f8:	52                   	push   %edx
f01027f9:	e8 50 20 00 00       	call   f010484e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01027fe:	6a 02                	push   $0x2
f0102800:	68 00 10 00 00       	push   $0x1000
f0102805:	57                   	push   %edi
f0102806:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f010280c:	e8 16 e9 ff ff       	call   f0101127 <page_insert>
	assert(pp1->pp_ref == 1);
f0102811:	83 c4 20             	add    $0x20,%esp
f0102814:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102819:	0f 85 87 01 00 00    	jne    f01029a6 <mem_init+0x17fc>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010281f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102826:	01 01 01 
f0102829:	0f 85 90 01 00 00    	jne    f01029bf <mem_init+0x1815>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010282f:	6a 02                	push   $0x2
f0102831:	68 00 10 00 00       	push   $0x1000
f0102836:	56                   	push   %esi
f0102837:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f010283d:	e8 e5 e8 ff ff       	call   f0101127 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102842:	83 c4 10             	add    $0x10,%esp
f0102845:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010284c:	02 02 02 
f010284f:	0f 85 83 01 00 00    	jne    f01029d8 <mem_init+0x182e>
	assert(pp2->pp_ref == 1);
f0102855:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010285a:	0f 85 91 01 00 00    	jne    f01029f1 <mem_init+0x1847>
	assert(pp1->pp_ref == 0);
f0102860:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102865:	0f 85 9f 01 00 00    	jne    f0102a0a <mem_init+0x1860>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010286b:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102872:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102875:	89 f0                	mov    %esi,%eax
f0102877:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f010287d:	c1 f8 03             	sar    $0x3,%eax
f0102880:	89 c2                	mov    %eax,%edx
f0102882:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102885:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010288a:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0102890:	0f 83 8d 01 00 00    	jae    f0102a23 <mem_init+0x1879>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102896:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f010289d:	03 03 03 
f01028a0:	0f 85 8f 01 00 00    	jne    f0102a35 <mem_init+0x188b>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01028a6:	83 ec 08             	sub    $0x8,%esp
f01028a9:	68 00 10 00 00       	push   $0x1000
f01028ae:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f01028b4:	e8 2f e8 ff ff       	call   f01010e8 <page_remove>
	assert(pp2->pp_ref == 0);
f01028b9:	83 c4 10             	add    $0x10,%esp
f01028bc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01028c1:	0f 85 87 01 00 00    	jne    f0102a4e <mem_init+0x18a4>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028c7:	8b 0d 0c cb 18 f0    	mov    0xf018cb0c,%ecx
f01028cd:	8b 11                	mov    (%ecx),%edx
f01028cf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f01028d5:	89 d8                	mov    %ebx,%eax
f01028d7:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f01028dd:	c1 f8 03             	sar    $0x3,%eax
f01028e0:	c1 e0 0c             	shl    $0xc,%eax
f01028e3:	39 c2                	cmp    %eax,%edx
f01028e5:	0f 85 7c 01 00 00    	jne    f0102a67 <mem_init+0x18bd>
	kern_pgdir[0] = 0;
f01028eb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01028f1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01028f6:	0f 85 84 01 00 00    	jne    f0102a80 <mem_init+0x18d6>
	pp0->pp_ref = 0;
f01028fc:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102902:	83 ec 0c             	sub    $0xc,%esp
f0102905:	53                   	push   %ebx
f0102906:	e8 77 e5 ff ff       	call   f0100e82 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010290b:	c7 04 24 10 5a 10 f0 	movl   $0xf0105a10,(%esp)
f0102912:	e8 1f 0a 00 00       	call   f0103336 <cprintf>
}
f0102917:	83 c4 10             	add    $0x10,%esp
f010291a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010291d:	5b                   	pop    %ebx
f010291e:	5e                   	pop    %esi
f010291f:	5f                   	pop    %edi
f0102920:	5d                   	pop    %ebp
f0102921:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102922:	50                   	push   %eax
f0102923:	68 20 53 10 f0       	push   $0xf0105320
f0102928:	68 2b 01 00 00       	push   $0x12b
f010292d:	68 71 5a 10 f0       	push   $0xf0105a71
f0102932:	e8 6d d7 ff ff       	call   f01000a4 <_panic>
	assert((pp0 = page_alloc(0)));
f0102937:	68 58 5b 10 f0       	push   $0xf0105b58
f010293c:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102941:	68 7b 04 00 00       	push   $0x47b
f0102946:	68 71 5a 10 f0       	push   $0xf0105a71
f010294b:	e8 54 d7 ff ff       	call   f01000a4 <_panic>
	assert((pp1 = page_alloc(0)));
f0102950:	68 6e 5b 10 f0       	push   $0xf0105b6e
f0102955:	68 ad 5a 10 f0       	push   $0xf0105aad
f010295a:	68 7c 04 00 00       	push   $0x47c
f010295f:	68 71 5a 10 f0       	push   $0xf0105a71
f0102964:	e8 3b d7 ff ff       	call   f01000a4 <_panic>
	assert((pp2 = page_alloc(0)));
f0102969:	68 84 5b 10 f0       	push   $0xf0105b84
f010296e:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102973:	68 7d 04 00 00       	push   $0x47d
f0102978:	68 71 5a 10 f0       	push   $0xf0105a71
f010297d:	e8 22 d7 ff ff       	call   f01000a4 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102982:	52                   	push   %edx
f0102983:	68 14 52 10 f0       	push   $0xf0105214
f0102988:	6a 56                	push   $0x56
f010298a:	68 93 5a 10 f0       	push   $0xf0105a93
f010298f:	e8 10 d7 ff ff       	call   f01000a4 <_panic>
f0102994:	52                   	push   %edx
f0102995:	68 14 52 10 f0       	push   $0xf0105214
f010299a:	6a 56                	push   $0x56
f010299c:	68 93 5a 10 f0       	push   $0xf0105a93
f01029a1:	e8 fe d6 ff ff       	call   f01000a4 <_panic>
	assert(pp1->pp_ref == 1);
f01029a6:	68 55 5c 10 f0       	push   $0xf0105c55
f01029ab:	68 ad 5a 10 f0       	push   $0xf0105aad
f01029b0:	68 82 04 00 00       	push   $0x482
f01029b5:	68 71 5a 10 f0       	push   $0xf0105a71
f01029ba:	e8 e5 d6 ff ff       	call   f01000a4 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01029bf:	68 9c 59 10 f0       	push   $0xf010599c
f01029c4:	68 ad 5a 10 f0       	push   $0xf0105aad
f01029c9:	68 83 04 00 00       	push   $0x483
f01029ce:	68 71 5a 10 f0       	push   $0xf0105a71
f01029d3:	e8 cc d6 ff ff       	call   f01000a4 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01029d8:	68 c0 59 10 f0       	push   $0xf01059c0
f01029dd:	68 ad 5a 10 f0       	push   $0xf0105aad
f01029e2:	68 85 04 00 00       	push   $0x485
f01029e7:	68 71 5a 10 f0       	push   $0xf0105a71
f01029ec:	e8 b3 d6 ff ff       	call   f01000a4 <_panic>
	assert(pp2->pp_ref == 1);
f01029f1:	68 77 5c 10 f0       	push   $0xf0105c77
f01029f6:	68 ad 5a 10 f0       	push   $0xf0105aad
f01029fb:	68 86 04 00 00       	push   $0x486
f0102a00:	68 71 5a 10 f0       	push   $0xf0105a71
f0102a05:	e8 9a d6 ff ff       	call   f01000a4 <_panic>
	assert(pp1->pp_ref == 0);
f0102a0a:	68 e1 5c 10 f0       	push   $0xf0105ce1
f0102a0f:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102a14:	68 87 04 00 00       	push   $0x487
f0102a19:	68 71 5a 10 f0       	push   $0xf0105a71
f0102a1e:	e8 81 d6 ff ff       	call   f01000a4 <_panic>
f0102a23:	52                   	push   %edx
f0102a24:	68 14 52 10 f0       	push   $0xf0105214
f0102a29:	6a 56                	push   $0x56
f0102a2b:	68 93 5a 10 f0       	push   $0xf0105a93
f0102a30:	e8 6f d6 ff ff       	call   f01000a4 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102a35:	68 e4 59 10 f0       	push   $0xf01059e4
f0102a3a:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102a3f:	68 89 04 00 00       	push   $0x489
f0102a44:	68 71 5a 10 f0       	push   $0xf0105a71
f0102a49:	e8 56 d6 ff ff       	call   f01000a4 <_panic>
	assert(pp2->pp_ref == 0);
f0102a4e:	68 af 5c 10 f0       	push   $0xf0105caf
f0102a53:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102a58:	68 8b 04 00 00       	push   $0x48b
f0102a5d:	68 71 5a 10 f0       	push   $0xf0105a71
f0102a62:	e8 3d d6 ff ff       	call   f01000a4 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102a67:	68 f4 54 10 f0       	push   $0xf01054f4
f0102a6c:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102a71:	68 8e 04 00 00       	push   $0x48e
f0102a76:	68 71 5a 10 f0       	push   $0xf0105a71
f0102a7b:	e8 24 d6 ff ff       	call   f01000a4 <_panic>
	assert(pp0->pp_ref == 1);
f0102a80:	68 66 5c 10 f0       	push   $0xf0105c66
f0102a85:	68 ad 5a 10 f0       	push   $0xf0105aad
f0102a8a:	68 90 04 00 00       	push   $0x490
f0102a8f:	68 71 5a 10 f0       	push   $0xf0105a71
f0102a94:	e8 0b d6 ff ff       	call   f01000a4 <_panic>

f0102a99 <tlb_invalidate>:
{
f0102a99:	f3 0f 1e fb          	endbr32 
f0102a9d:	55                   	push   %ebp
f0102a9e:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102aa3:	0f 01 38             	invlpg (%eax)
}
f0102aa6:	5d                   	pop    %ebp
f0102aa7:	c3                   	ret    

f0102aa8 <user_mem_check>:
{
f0102aa8:	f3 0f 1e fb          	endbr32 
f0102aac:	55                   	push   %ebp
f0102aad:	89 e5                	mov    %esp,%ebp
f0102aaf:	57                   	push   %edi
f0102ab0:	56                   	push   %esi
f0102ab1:	53                   	push   %ebx
f0102ab2:	83 ec 0c             	sub    $0xc,%esp
f0102ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102ab8:	8b 75 14             	mov    0x14(%ebp),%esi
	uint32_t raw_range = ROUNDUP(va + len, PGSIZE) - ROUNDDOWN(va, PGSIZE);
f0102abb:	89 d3                	mov    %edx,%ebx
f0102abd:	89 d0                	mov    %edx,%eax
f0102abf:	03 45 10             	add    0x10(%ebp),%eax
f0102ac2:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102ac7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102acc:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0102ad2:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	for (int i = 0; i < num_of_pages; i++)
f0102ad5:	39 fb                	cmp    %edi,%ebx
f0102ad7:	74 59                	je     f0102b32 <user_mem_check+0x8a>
		 if ((uintptr_t)current_va >= ULIM) //check if below the correct address
f0102ad9:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102adf:	77 2a                	ja     f0102b0b <user_mem_check+0x63>
		 pte_t* page_table_entry_ptr = pgdir_walk(env->env_pgdir, current_va, create);
f0102ae1:	83 ec 04             	sub    $0x4,%esp
f0102ae4:	6a 00                	push   $0x0
f0102ae6:	53                   	push   %ebx
f0102ae7:	8b 45 08             	mov    0x8(%ebp),%eax
f0102aea:	ff 70 5c             	pushl  0x5c(%eax)
f0102aed:	e8 13 e4 ff ff       	call   f0100f05 <pgdir_walk>
		 if (page_table_entry_ptr == NULL) //forgot that the pointer can be NULL 
f0102af2:	83 c4 10             	add    $0x10,%esp
f0102af5:	85 c0                	test   %eax,%eax
f0102af7:	74 1f                	je     f0102b18 <user_mem_check+0x70>
f0102af9:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
		 if ( ((*page_table_entry_ptr) & perm) != perm)
f0102aff:	89 f1                	mov    %esi,%ecx
f0102b01:	23 08                	and    (%eax),%ecx
f0102b03:	39 ce                	cmp    %ecx,%esi
f0102b05:	75 1e                	jne    f0102b25 <user_mem_check+0x7d>
f0102b07:	89 d3                	mov    %edx,%ebx
f0102b09:	eb ca                	jmp    f0102ad5 <user_mem_check+0x2d>
			user_mem_check_addr = (uintptr_t)current_va;
f0102b0b:	89 1d 40 be 18 f0    	mov    %ebx,0xf018be40
			return -E_FAULT;
f0102b11:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102b16:	eb 1f                	jmp    f0102b37 <user_mem_check+0x8f>
			user_mem_check_addr = (uintptr_t)current_va;
f0102b18:	89 1d 40 be 18 f0    	mov    %ebx,0xf018be40
                        return -E_FAULT;
f0102b1e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102b23:	eb 12                	jmp    f0102b37 <user_mem_check+0x8f>
			 user_mem_check_addr = (uintptr_t)current_va;
f0102b25:	89 1d 40 be 18 f0    	mov    %ebx,0xf018be40
			 return -E_FAULT;
f0102b2b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102b30:	eb 05                	jmp    f0102b37 <user_mem_check+0x8f>
	return 0;
f0102b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b3a:	5b                   	pop    %ebx
f0102b3b:	5e                   	pop    %esi
f0102b3c:	5f                   	pop    %edi
f0102b3d:	5d                   	pop    %ebp
f0102b3e:	c3                   	ret    

f0102b3f <user_mem_assert>:
{
f0102b3f:	f3 0f 1e fb          	endbr32 
f0102b43:	55                   	push   %ebp
f0102b44:	89 e5                	mov    %esp,%ebp
f0102b46:	53                   	push   %ebx
f0102b47:	83 ec 04             	sub    $0x4,%esp
f0102b4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102b4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b50:	83 c8 04             	or     $0x4,%eax
f0102b53:	50                   	push   %eax
f0102b54:	ff 75 10             	pushl  0x10(%ebp)
f0102b57:	ff 75 0c             	pushl  0xc(%ebp)
f0102b5a:	53                   	push   %ebx
f0102b5b:	e8 48 ff ff ff       	call   f0102aa8 <user_mem_check>
f0102b60:	83 c4 10             	add    $0x10,%esp
f0102b63:	85 c0                	test   %eax,%eax
f0102b65:	78 05                	js     f0102b6c <user_mem_assert+0x2d>
}
f0102b67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102b6a:	c9                   	leave  
f0102b6b:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102b6c:	83 ec 04             	sub    $0x4,%esp
f0102b6f:	ff 35 40 be 18 f0    	pushl  0xf018be40
f0102b75:	ff 73 48             	pushl  0x48(%ebx)
f0102b78:	68 3c 5a 10 f0       	push   $0xf0105a3c
f0102b7d:	e8 b4 07 00 00       	call   f0103336 <cprintf>
		env_destroy(env);	// may not return
f0102b82:	89 1c 24             	mov    %ebx,(%esp)
f0102b85:	e8 7d 06 00 00       	call   f0103207 <env_destroy>
f0102b8a:	83 c4 10             	add    $0x10,%esp
}
f0102b8d:	eb d8                	jmp    f0102b67 <user_mem_assert+0x28>

f0102b8f <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102b8f:	f3 0f 1e fb          	endbr32 
f0102b93:	55                   	push   %ebp
f0102b94:	89 e5                	mov    %esp,%ebp
f0102b96:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b99:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102b9c:	85 c0                	test   %eax,%eax
f0102b9e:	74 40                	je     f0102be0 <envid2env+0x51>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102ba0:	89 c2                	mov    %eax,%edx
f0102ba2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102ba8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102bab:	c1 e2 05             	shl    $0x5,%edx
f0102bae:	03 15 50 be 18 f0    	add    0xf018be50,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102bb4:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102bb8:	74 33                	je     f0102bed <envid2env+0x5e>
f0102bba:	39 42 48             	cmp    %eax,0x48(%edx)
f0102bbd:	75 2e                	jne    f0102bed <envid2env+0x5e>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102bbf:	84 c9                	test   %cl,%cl
f0102bc1:	74 11                	je     f0102bd4 <envid2env+0x45>
f0102bc3:	a1 4c be 18 f0       	mov    0xf018be4c,%eax
f0102bc8:	39 d0                	cmp    %edx,%eax
f0102bca:	74 08                	je     f0102bd4 <envid2env+0x45>
f0102bcc:	8b 40 48             	mov    0x48(%eax),%eax
f0102bcf:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0102bd2:	75 29                	jne    f0102bfd <envid2env+0x6e>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f0102bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bd7:	89 10                	mov    %edx,(%eax)
	return 0;
f0102bd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102bde:	5d                   	pop    %ebp
f0102bdf:	c3                   	ret    
		*env_store = curenv;
f0102be0:	8b 15 4c be 18 f0    	mov    0xf018be4c,%edx
f0102be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102be9:	89 11                	mov    %edx,(%ecx)
		return 0;
f0102beb:	eb f1                	jmp    f0102bde <envid2env+0x4f>
		*env_store = 0;
f0102bed:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bf0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102bf6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102bfb:	eb e1                	jmp    f0102bde <envid2env+0x4f>
		*env_store = 0;
f0102bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102c06:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102c0b:	eb d1                	jmp    f0102bde <envid2env+0x4f>

f0102c0d <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102c0d:	f3 0f 1e fb          	endbr32 
	asm volatile("lgdt (%0)" : : "r" (p));
f0102c11:	b8 00 d3 11 f0       	mov    $0xf011d300,%eax
f0102c16:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102c19:	b8 23 00 00 00       	mov    $0x23,%eax
f0102c1e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102c20:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102c22:	b8 10 00 00 00       	mov    $0x10,%eax
f0102c27:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102c29:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102c2b:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102c2d:	ea 34 2c 10 f0 08 00 	ljmp   $0x8,$0xf0102c34
	asm volatile("lldt %0" : : "r" (sel));
f0102c34:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c39:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102c3c:	c3                   	ret    

f0102c3d <env_init>:
{
f0102c3d:	f3 0f 1e fb          	endbr32 
f0102c41:	55                   	push   %ebp
f0102c42:	89 e5                	mov    %esp,%ebp
f0102c44:	57                   	push   %edi
f0102c45:	56                   	push   %esi
f0102c46:	53                   	push   %ebx
f0102c47:	83 ec 1c             	sub    $0x1c,%esp
f0102c4a:	8b 35 54 be 18 f0    	mov    0xf018be54,%esi
f0102c50:	a1 50 be 18 f0       	mov    0xf018be50,%eax
f0102c55:	8d b8 00 80 01 00    	lea    0x18000(%eax),%edi
		envs[i].env_status = ENV_FREE;
f0102c5b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	bool firstTime = true;
f0102c5f:	ba 01 00 00 00       	mov    $0x1,%edx
f0102c64:	eb 20                	jmp    f0102c86 <env_init+0x49>
			struct Env *runner = env_free_list;
f0102c66:	89 f2                	mov    %esi,%edx
	                while (runner != NULL)
f0102c68:	85 d2                	test   %edx,%edx
f0102c6a:	74 0e                	je     f0102c7a <env_init+0x3d>
                	        if (runner->env_link == NULL)
f0102c6c:	8b 4a 44             	mov    0x44(%edx),%ecx
f0102c6f:	85 c9                	test   %ecx,%ecx
f0102c71:	74 04                	je     f0102c77 <env_init+0x3a>
                        runner = runner->env_link;
f0102c73:	89 ca                	mov    %ecx,%edx
f0102c75:	eb f1                	jmp    f0102c68 <env_init+0x2b>
                               		 runner->env_link = &envs[i];
f0102c77:	89 5a 44             	mov    %ebx,0x44(%edx)
f0102c7a:	83 c0 60             	add    $0x60,%eax
f0102c7d:	ba 00 00 00 00       	mov    $0x0,%edx
	for (int i = 0; i < NENV; i++)
f0102c82:	39 f8                	cmp    %edi,%eax
f0102c84:	74 22                	je     f0102ca8 <env_init+0x6b>
		envs[i].env_status = ENV_FREE;
f0102c86:	89 c3                	mov    %eax,%ebx
f0102c88:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102c8f:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = NULL;
f0102c96:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
		if (firstTime == true)
f0102c9d:	84 d2                	test   %dl,%dl
f0102c9f:	74 c5                	je     f0102c66 <env_init+0x29>
f0102ca1:	88 55 e7             	mov    %dl,-0x19(%ebp)
			env_free_list = &envs[i];
f0102ca4:	89 c6                	mov    %eax,%esi
f0102ca6:	eb d2                	jmp    f0102c7a <env_init+0x3d>
f0102ca8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0102cac:	74 06                	je     f0102cb4 <env_init+0x77>
f0102cae:	89 35 54 be 18 f0    	mov    %esi,0xf018be54
	env_init_percpu();
f0102cb4:	e8 54 ff ff ff       	call   f0102c0d <env_init_percpu>
}
f0102cb9:	83 c4 1c             	add    $0x1c,%esp
f0102cbc:	5b                   	pop    %ebx
f0102cbd:	5e                   	pop    %esi
f0102cbe:	5f                   	pop    %edi
f0102cbf:	5d                   	pop    %ebp
f0102cc0:	c3                   	ret    

f0102cc1 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102cc1:	f3 0f 1e fb          	endbr32 
f0102cc5:	55                   	push   %ebp
f0102cc6:	89 e5                	mov    %esp,%ebp
f0102cc8:	53                   	push   %ebx
f0102cc9:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102ccc:	8b 1d 54 be 18 f0    	mov    0xf018be54,%ebx
f0102cd2:	85 db                	test   %ebx,%ebx
f0102cd4:	0f 84 4f 01 00 00    	je     f0102e29 <env_alloc+0x168>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102cda:	83 ec 0c             	sub    $0xc,%esp
f0102cdd:	6a 01                	push   $0x1
f0102cdf:	e8 25 e1 ff ff       	call   f0100e09 <page_alloc>
f0102ce4:	83 c4 10             	add    $0x10,%esp
f0102ce7:	85 c0                	test   %eax,%eax
f0102ce9:	0f 84 41 01 00 00    	je     f0102e30 <env_alloc+0x16f>
	p->pp_ref++; //apparently env_pgdir PDE_T is the exception where we MUST increment the pp_ref value? idk why it just say so bro
f0102cef:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102cf4:	2b 05 10 cb 18 f0    	sub    0xf018cb10,%eax
f0102cfa:	c1 f8 03             	sar    $0x3,%eax
f0102cfd:	89 c2                	mov    %eax,%edx
f0102cff:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d02:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d07:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0102d0d:	0f 83 ef 00 00 00    	jae    f0102e02 <env_alloc+0x141>
	return (void *)(pa + KERNBASE);
f0102d13:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = page2kva(p); //need to point to the new page directory that was just made
f0102d19:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102d1c:	83 ec 04             	sub    $0x4,%esp
f0102d1f:	68 00 10 00 00       	push   $0x1000
f0102d24:	ff 35 0c cb 18 f0    	pushl  0xf018cb0c
f0102d2a:	50                   	push   %eax
f0102d2b:	e8 d0 1b 00 00       	call   f0104900 <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102d30:	8b 43 5c             	mov    0x5c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102d33:	83 c4 10             	add    $0x10,%esp
f0102d36:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d3b:	0f 86 d3 00 00 00    	jbe    f0102e14 <env_alloc+0x153>
	return (physaddr_t)kva - KERNBASE;
f0102d41:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102d47:	83 ca 05             	or     $0x5,%edx
f0102d4a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.g
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102d50:	8b 43 48             	mov    0x48(%ebx),%eax
f0102d53:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
f0102d58:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102d5d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102d62:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102d65:	89 da                	mov    %ebx,%edx
f0102d67:	2b 15 50 be 18 f0    	sub    0xf018be50,%edx
f0102d6d:	c1 fa 05             	sar    $0x5,%edx
f0102d70:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102d76:	09 d0                	or     %edx,%eax
f0102d78:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d7e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102d81:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102d88:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102d8f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102d96:	83 ec 04             	sub    $0x4,%esp
f0102d99:	6a 44                	push   $0x44
f0102d9b:	6a 00                	push   $0x0
f0102d9d:	53                   	push   %ebx
f0102d9e:	e8 ab 1a 00 00       	call   f010484e <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102da3:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102da9:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102daf:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102db5:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102dbc:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102dc2:	8b 43 44             	mov    0x44(%ebx),%eax
f0102dc5:	a3 54 be 18 f0       	mov    %eax,0xf018be54
	*newenv_store = e;
f0102dca:	8b 45 08             	mov    0x8(%ebp),%eax
f0102dcd:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102dcf:	8b 4b 48             	mov    0x48(%ebx),%ecx
f0102dd2:	a1 4c be 18 f0       	mov    0xf018be4c,%eax
f0102dd7:	83 c4 10             	add    $0x10,%esp
f0102dda:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ddf:	85 c0                	test   %eax,%eax
f0102de1:	74 03                	je     f0102de6 <env_alloc+0x125>
f0102de3:	8b 50 48             	mov    0x48(%eax),%edx
f0102de6:	83 ec 04             	sub    $0x4,%esp
f0102de9:	51                   	push   %ecx
f0102dea:	52                   	push   %edx
f0102deb:	68 69 5f 10 f0       	push   $0xf0105f69
f0102df0:	e8 41 05 00 00       	call   f0103336 <cprintf>
	return 0;
f0102df5:	83 c4 10             	add    $0x10,%esp
f0102df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e00:	c9                   	leave  
f0102e01:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e02:	52                   	push   %edx
f0102e03:	68 14 52 10 f0       	push   $0xf0105214
f0102e08:	6a 56                	push   $0x56
f0102e0a:	68 93 5a 10 f0       	push   $0xf0105a93
f0102e0f:	e8 90 d2 ff ff       	call   f01000a4 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e14:	50                   	push   %eax
f0102e15:	68 20 53 10 f0       	push   $0xf0105320
f0102e1a:	68 e3 00 00 00       	push   $0xe3
f0102e1f:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0102e24:	e8 7b d2 ff ff       	call   f01000a4 <_panic>
		return -E_NO_FREE_ENV;
f0102e29:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102e2e:	eb cd                	jmp    f0102dfd <env_alloc+0x13c>
		return -E_NO_MEM;
f0102e30:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102e35:	eb c6                	jmp    f0102dfd <env_alloc+0x13c>

f0102e37 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102e37:	f3 0f 1e fb          	endbr32 
f0102e3b:	55                   	push   %ebp
f0102e3c:	89 e5                	mov    %esp,%ebp
f0102e3e:	57                   	push   %edi
f0102e3f:	56                   	push   %esi
f0102e40:	53                   	push   %ebx
f0102e41:	83 ec 34             	sub    $0x34,%esp
	// LAB 3: Your code here
	
	struct Env *newEnv = NULL;
f0102e44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	envid_t parent_ID = 0;
	int pass = env_alloc(&newEnv, parent_ID);
f0102e4b:	6a 00                	push   $0x0
f0102e4d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102e50:	50                   	push   %eax
f0102e51:	e8 6b fe ff ff       	call   f0102cc1 <env_alloc>
	if (pass < 0)
f0102e56:	83 c4 10             	add    $0x10,%esp
f0102e59:	85 c0                	test   %eax,%eax
f0102e5b:	79 33                	jns    f0102e90 <env_create+0x59>
	{
		if (pass == -E_NO_FREE_ENV)
f0102e5d:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0102e60:	74 17                	je     f0102e79 <env_create+0x42>
		{
			panic("couldn't create a new enviornment in env_create(): -E_NO_FREE_ENV");
		}
		else
		{
			panic("coudln't create a new enviornment in env_create(): -E_NO_MEM");
f0102e62:	83 ec 04             	sub    $0x4,%esp
f0102e65:	68 b0 5d 10 f0       	push   $0xf0105db0
f0102e6a:	68 e3 01 00 00       	push   $0x1e3
f0102e6f:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0102e74:	e8 2b d2 ff ff       	call   f01000a4 <_panic>
			panic("couldn't create a new enviornment in env_create(): -E_NO_FREE_ENV");
f0102e79:	83 ec 04             	sub    $0x4,%esp
f0102e7c:	68 6c 5d 10 f0       	push   $0xf0105d6c
f0102e81:	68 df 01 00 00       	push   $0x1df
f0102e86:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0102e8b:	e8 14 d2 ff ff       	call   f01000a4 <_panic>
		}
	}
	newEnv->env_type = type;
f0102e90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e93:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e96:	89 47 50             	mov    %eax,0x50(%edi)
	if (binary == NULL)
f0102e99:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0102e9d:	74 36                	je     f0102ed5 <env_create+0x9e>
	lcr3(PADDR(e->env_pgdir)); //STEP 1: switch to the correct page table memory place thing before anything else!
f0102e9f:	8b 47 5c             	mov    0x5c(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0102ea2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ea7:	76 43                	jbe    f0102eec <env_create+0xb5>
	return (physaddr_t)kva - KERNBASE;
f0102ea9:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102eae:	0f 22 d8             	mov    %eax,%cr3
        if (ELFHDR->e_magic != ELF_MAGIC)
f0102eb1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102eb4:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0102eba:	75 45                	jne    f0102f01 <env_create+0xca>
	mainProgramHeader = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0102ebc:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ebf:	89 c3                	mov    %eax,%ebx
f0102ec1:	03 58 1c             	add    0x1c(%eax),%ebx
        endOfProgramHeader = mainProgramHeader + ELFHDR->e_phnum;
f0102ec4:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0102ec8:	c1 e0 05             	shl    $0x5,%eax
f0102ecb:	01 d8                	add    %ebx,%eax
f0102ecd:	89 45 d0             	mov    %eax,-0x30(%ebp)
        for (; mainProgramHeader < endOfProgramHeader; mainProgramHeader++)
f0102ed0:	e9 85 00 00 00       	jmp    f0102f5a <env_create+0x123>
		panic("incoming binary location NULL in load_icode() function");
f0102ed5:	83 ec 04             	sub    $0x4,%esp
f0102ed8:	68 f0 5d 10 f0       	push   $0xf0105df0
f0102edd:	68 92 01 00 00       	push   $0x192
f0102ee2:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0102ee7:	e8 b8 d1 ff ff       	call   f01000a4 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eec:	50                   	push   %eax
f0102eed:	68 20 53 10 f0       	push   $0xf0105320
f0102ef2:	68 94 01 00 00       	push   $0x194
f0102ef7:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0102efc:	e8 a3 d1 ff ff       	call   f01000a4 <_panic>
                panic("we done messed up homies");
f0102f01:	83 ec 04             	sub    $0x4,%esp
f0102f04:	68 7e 5f 10 f0       	push   $0xf0105f7e
f0102f09:	68 9b 01 00 00       	push   $0x19b
f0102f0e:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0102f13:	e8 8c d1 ff ff       	call   f01000a4 <_panic>
			panic("region_alloc tried to allocate space/pages, but there wasn't enough free!");
f0102f18:	83 ec 04             	sub    $0x4,%esp
f0102f1b:	68 28 5e 10 f0       	push   $0xf0105e28
f0102f20:	68 49 01 00 00       	push   $0x149
f0102f25:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0102f2a:	e8 75 d1 ff ff       	call   f01000a4 <_panic>
			void *offsetIGuess = (void *) (binary + mainProgramHeader->p_offset);
f0102f2f:	8b 75 08             	mov    0x8(%ebp),%esi
f0102f32:	03 73 04             	add    0x4(%ebx),%esi
			memset((void *)mainProgramHeader->p_va, 0, mainProgramHeader->p_memsz);
f0102f35:	83 ec 04             	sub    $0x4,%esp
f0102f38:	ff 73 14             	pushl  0x14(%ebx)
f0102f3b:	6a 00                	push   $0x0
f0102f3d:	ff 73 08             	pushl  0x8(%ebx)
f0102f40:	e8 09 19 00 00       	call   f010484e <memset>
			memcpy((void*)mainProgramHeader->p_va, offsetIGuess, mainProgramHeader->p_filesz);  
f0102f45:	83 c4 0c             	add    $0xc,%esp
f0102f48:	ff 73 10             	pushl  0x10(%ebx)
f0102f4b:	56                   	push   %esi
f0102f4c:	ff 73 08             	pushl  0x8(%ebx)
f0102f4f:	e8 ac 19 00 00       	call   f0104900 <memcpy>
f0102f54:	83 c4 10             	add    $0x10,%esp
        for (; mainProgramHeader < endOfProgramHeader; mainProgramHeader++)
f0102f57:	83 c3 20             	add    $0x20,%ebx
f0102f5a:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102f5d:	76 55                	jbe    f0102fb4 <env_create+0x17d>
	  	if (mainProgramHeader->p_type == ELF_PROG_LOAD)
f0102f5f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102f62:	75 f3                	jne    f0102f57 <env_create+0x120>
			region_alloc(e, (void*) mainProgramHeader->p_va, mainProgramHeader->p_memsz); //memsz tells you how much to reserve
f0102f64:	8b 43 14             	mov    0x14(%ebx),%eax
	if (len ==0)
f0102f67:	85 c0                	test   %eax,%eax
f0102f69:	74 c4                	je     f0102f2f <env_create+0xf8>
			region_alloc(e, (void*) mainProgramHeader->p_va, mainProgramHeader->p_memsz); //memsz tells you how much to reserve
f0102f6b:	8b 73 08             	mov    0x8(%ebx),%esi
	uint32_t rounded_up_address = ROUNDUP((uintptr_t) va  + len, PGSIZE);
f0102f6e:	8d 84 30 ff 0f 00 00 	lea    0xfff(%eax,%esi,1),%eax
f0102f75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	uint32_t rounded_down_address = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102f7d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
      	for(int i = 0; i < totalPages; i++)
f0102f83:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102f86:	74 a7                	je     f0102f2f <env_create+0xf8>
		struct PageInfo* newPage = page_alloc(0); //allocate one physical page without initializing the memory contents for some reason
f0102f88:	83 ec 0c             	sub    $0xc,%esp
f0102f8b:	6a 00                	push   $0x0
f0102f8d:	e8 77 de ff ff       	call   f0100e09 <page_alloc>
		if (newPage == NULL)
f0102f92:	83 c4 10             	add    $0x10,%esp
f0102f95:	85 c0                	test   %eax,%eax
f0102f97:	0f 84 7b ff ff ff    	je     f0102f18 <env_create+0xe1>
		uint32_t pass = page_insert(e->env_pgdir, newPage, (void*) (rounded_down_address + i * PGSIZE), PTE_P | PTE_W | PTE_U);
f0102f9d:	6a 07                	push   $0x7
f0102f9f:	56                   	push   %esi
f0102fa0:	50                   	push   %eax
f0102fa1:	ff 77 5c             	pushl  0x5c(%edi)
f0102fa4:	e8 7e e1 ff ff       	call   f0101127 <page_insert>
f0102fa9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102faf:	83 c4 10             	add    $0x10,%esp
f0102fb2:	eb cf                	jmp    f0102f83 <env_create+0x14c>
	struct PageInfo* newPage = page_alloc(ALLOC_ZERO);
f0102fb4:	83 ec 0c             	sub    $0xc,%esp
f0102fb7:	6a 01                	push   $0x1
f0102fb9:	e8 4b de ff ff       	call   f0100e09 <page_alloc>
	if (newPage == NULL)
f0102fbe:	83 c4 10             	add    $0x10,%esp
f0102fc1:	85 c0                	test   %eax,%eax
f0102fc3:	74 3c                	je     f0103001 <env_create+0x1ca>
	int pass = page_insert(e->env_pgdir, newPage,(void *) USTACKTOP - PGSIZE , PTE_P | PTE_U | PTE_W);
f0102fc5:	6a 07                	push   $0x7
f0102fc7:	68 00 d0 bf ee       	push   $0xeebfd000
f0102fcc:	50                   	push   %eax
f0102fcd:	ff 77 5c             	pushl  0x5c(%edi)
f0102fd0:	e8 52 e1 ff ff       	call   f0101127 <page_insert>
	if (pass < 0)
f0102fd5:	83 c4 10             	add    $0x10,%esp
f0102fd8:	85 c0                	test   %eax,%eax
f0102fda:	78 3c                	js     f0103018 <env_create+0x1e1>
	lcr3(PADDR(kern_pgdir)); //need to go back to the kernel's address space because we don't need to load anything else into user space!
f0102fdc:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102fe1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fe6:	76 47                	jbe    f010302f <env_create+0x1f8>
	return (physaddr_t)kva - KERNBASE;
f0102fe8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102fed:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0102ff0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ff3:	8b 40 18             	mov    0x18(%eax),%eax
f0102ff6:	89 47 30             	mov    %eax,0x30(%edi)
	load_icode(newEnv, binary);
	//newEnv->env_type = type;
	
}
f0102ff9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ffc:	5b                   	pop    %ebx
f0102ffd:	5e                   	pop    %esi
f0102ffe:	5f                   	pop    %edi
f0102fff:	5d                   	pop    %ebp
f0103000:	c3                   	ret    
		panic("allocated new page in second part of load_icode and it didn't work!");
f0103001:	83 ec 04             	sub    $0x4,%esp
f0103004:	68 74 5e 10 f0       	push   $0xf0105e74
f0103009:	68 bd 01 00 00       	push   $0x1bd
f010300e:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0103013:	e8 8c d0 ff ff       	call   f01000a4 <_panic>
		panic("page_insert() failed in load_icode() function after trying to insert a page for the program's initial stack!!");
f0103018:	83 ec 04             	sub    $0x4,%esp
f010301b:	68 b8 5e 10 f0       	push   $0xf0105eb8
f0103020:	68 c2 01 00 00       	push   $0x1c2
f0103025:	68 5e 5f 10 f0       	push   $0xf0105f5e
f010302a:	e8 75 d0 ff ff       	call   f01000a4 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010302f:	50                   	push   %eax
f0103030:	68 20 53 10 f0       	push   $0xf0105320
f0103035:	68 c7 01 00 00       	push   $0x1c7
f010303a:	68 5e 5f 10 f0       	push   $0xf0105f5e
f010303f:	e8 60 d0 ff ff       	call   f01000a4 <_panic>

f0103044 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103044:	f3 0f 1e fb          	endbr32 
f0103048:	55                   	push   %ebp
f0103049:	89 e5                	mov    %esp,%ebp
f010304b:	57                   	push   %edi
f010304c:	56                   	push   %esi
f010304d:	53                   	push   %ebx
f010304e:	83 ec 1c             	sub    $0x1c,%esp
f0103051:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103054:	8b 15 4c be 18 f0    	mov    0xf018be4c,%edx
f010305a:	39 fa                	cmp    %edi,%edx
f010305c:	74 2d                	je     f010308b <env_free+0x47>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010305e:	8b 4f 48             	mov    0x48(%edi),%ecx
f0103061:	b8 00 00 00 00       	mov    $0x0,%eax
f0103066:	85 d2                	test   %edx,%edx
f0103068:	74 03                	je     f010306d <env_free+0x29>
f010306a:	8b 42 48             	mov    0x48(%edx),%eax
f010306d:	83 ec 04             	sub    $0x4,%esp
f0103070:	51                   	push   %ecx
f0103071:	50                   	push   %eax
f0103072:	68 97 5f 10 f0       	push   $0xf0105f97
f0103077:	e8 ba 02 00 00       	call   f0103336 <cprintf>
f010307c:	83 c4 10             	add    $0x10,%esp
f010307f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103086:	e9 ac 00 00 00       	jmp    f0103137 <env_free+0xf3>
		lcr3(PADDR(kern_pgdir));
f010308b:	a1 0c cb 18 f0       	mov    0xf018cb0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103090:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103095:	76 0d                	jbe    f01030a4 <env_free+0x60>
	return (physaddr_t)kva - KERNBASE;
f0103097:	05 00 00 00 10       	add    $0x10000000,%eax
f010309c:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010309f:	8b 4f 48             	mov    0x48(%edi),%ecx
f01030a2:	eb c6                	jmp    f010306a <env_free+0x26>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030a4:	50                   	push   %eax
f01030a5:	68 20 53 10 f0       	push   $0xf0105320
f01030aa:	68 fa 01 00 00       	push   $0x1fa
f01030af:	68 5e 5f 10 f0       	push   $0xf0105f5e
f01030b4:	e8 eb cf ff ff       	call   f01000a4 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030b9:	56                   	push   %esi
f01030ba:	68 14 52 10 f0       	push   $0xf0105214
f01030bf:	68 09 02 00 00       	push   $0x209
f01030c4:	68 5e 5f 10 f0       	push   $0xf0105f5e
f01030c9:	e8 d6 cf ff ff       	call   f01000a4 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01030ce:	83 ec 08             	sub    $0x8,%esp
f01030d1:	89 d8                	mov    %ebx,%eax
f01030d3:	c1 e0 0c             	shl    $0xc,%eax
f01030d6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01030d9:	50                   	push   %eax
f01030da:	ff 77 5c             	pushl  0x5c(%edi)
f01030dd:	e8 06 e0 ff ff       	call   f01010e8 <page_remove>
f01030e2:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01030e5:	83 c3 01             	add    $0x1,%ebx
f01030e8:	83 c6 04             	add    $0x4,%esi
f01030eb:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01030f1:	74 07                	je     f01030fa <env_free+0xb6>
			if (pt[pteno] & PTE_P)
f01030f3:	f6 06 01             	testb  $0x1,(%esi)
f01030f6:	74 ed                	je     f01030e5 <env_free+0xa1>
f01030f8:	eb d4                	jmp    f01030ce <env_free+0x8a>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01030fa:	8b 47 5c             	mov    0x5c(%edi),%eax
f01030fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103100:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103107:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010310a:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f0103110:	73 65                	jae    f0103177 <env_free+0x133>
		page_decref(pa2page(pa));
f0103112:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103115:	a1 10 cb 18 f0       	mov    0xf018cb10,%eax
f010311a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010311d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103120:	50                   	push   %eax
f0103121:	e8 b2 dd ff ff       	call   f0100ed8 <page_decref>
f0103126:	83 c4 10             	add    $0x10,%esp
f0103129:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010312d:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103130:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103135:	74 54                	je     f010318b <env_free+0x147>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103137:	8b 47 5c             	mov    0x5c(%edi),%eax
f010313a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010313d:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103140:	a8 01                	test   $0x1,%al
f0103142:	74 e5                	je     f0103129 <env_free+0xe5>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103144:	89 c6                	mov    %eax,%esi
f0103146:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010314c:	c1 e8 0c             	shr    $0xc,%eax
f010314f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103152:	39 05 08 cb 18 f0    	cmp    %eax,0xf018cb08
f0103158:	0f 86 5b ff ff ff    	jbe    f01030b9 <env_free+0x75>
	return (void *)(pa + KERNBASE);
f010315e:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103164:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103167:	c1 e0 14             	shl    $0x14,%eax
f010316a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010316d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103172:	e9 7c ff ff ff       	jmp    f01030f3 <env_free+0xaf>
		panic("pa2page called with invalid pa");
f0103177:	83 ec 04             	sub    $0x4,%esp
f010317a:	68 c0 53 10 f0       	push   $0xf01053c0
f010317f:	6a 4f                	push   $0x4f
f0103181:	68 93 5a 10 f0       	push   $0xf0105a93
f0103186:	e8 19 cf ff ff       	call   f01000a4 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010318b:	8b 47 5c             	mov    0x5c(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010318e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103193:	76 49                	jbe    f01031de <env_free+0x19a>
	e->env_pgdir = 0;
f0103195:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f010319c:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01031a1:	c1 e8 0c             	shr    $0xc,%eax
f01031a4:	3b 05 08 cb 18 f0    	cmp    0xf018cb08,%eax
f01031aa:	73 47                	jae    f01031f3 <env_free+0x1af>
	page_decref(pa2page(pa));
f01031ac:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01031af:	8b 15 10 cb 18 f0    	mov    0xf018cb10,%edx
f01031b5:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01031b8:	50                   	push   %eax
f01031b9:	e8 1a dd ff ff       	call   f0100ed8 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01031be:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01031c5:	a1 54 be 18 f0       	mov    0xf018be54,%eax
f01031ca:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01031cd:	89 3d 54 be 18 f0    	mov    %edi,0xf018be54
}
f01031d3:	83 c4 10             	add    $0x10,%esp
f01031d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031d9:	5b                   	pop    %ebx
f01031da:	5e                   	pop    %esi
f01031db:	5f                   	pop    %edi
f01031dc:	5d                   	pop    %ebp
f01031dd:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031de:	50                   	push   %eax
f01031df:	68 20 53 10 f0       	push   $0xf0105320
f01031e4:	68 17 02 00 00       	push   $0x217
f01031e9:	68 5e 5f 10 f0       	push   $0xf0105f5e
f01031ee:	e8 b1 ce ff ff       	call   f01000a4 <_panic>
		panic("pa2page called with invalid pa");
f01031f3:	83 ec 04             	sub    $0x4,%esp
f01031f6:	68 c0 53 10 f0       	push   $0xf01053c0
f01031fb:	6a 4f                	push   $0x4f
f01031fd:	68 93 5a 10 f0       	push   $0xf0105a93
f0103202:	e8 9d ce ff ff       	call   f01000a4 <_panic>

f0103207 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103207:	f3 0f 1e fb          	endbr32 
f010320b:	55                   	push   %ebp
f010320c:	89 e5                	mov    %esp,%ebp
f010320e:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0103211:	ff 75 08             	pushl  0x8(%ebp)
f0103214:	e8 2b fe ff ff       	call   f0103044 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103219:	c7 04 24 28 5f 10 f0 	movl   $0xf0105f28,(%esp)
f0103220:	e8 11 01 00 00       	call   f0103336 <cprintf>
f0103225:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103228:	83 ec 0c             	sub    $0xc,%esp
f010322b:	6a 00                	push   $0x0
f010322d:	e8 79 d5 ff ff       	call   f01007ab <monitor>
f0103232:	83 c4 10             	add    $0x10,%esp
f0103235:	eb f1                	jmp    f0103228 <env_destroy+0x21>

f0103237 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103237:	f3 0f 1e fb          	endbr32 
f010323b:	55                   	push   %ebp
f010323c:	89 e5                	mov    %esp,%ebp
f010323e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f0103241:	8b 65 08             	mov    0x8(%ebp),%esp
f0103244:	61                   	popa   
f0103245:	07                   	pop    %es
f0103246:	1f                   	pop    %ds
f0103247:	83 c4 08             	add    $0x8,%esp
f010324a:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010324b:	68 ad 5f 10 f0       	push   $0xf0105fad
f0103250:	68 40 02 00 00       	push   $0x240
f0103255:	68 5e 5f 10 f0       	push   $0xf0105f5e
f010325a:	e8 45 ce ff ff       	call   f01000a4 <_panic>

f010325f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010325f:	f3 0f 1e fb          	endbr32 
f0103263:	55                   	push   %ebp
f0103264:	89 e5                	mov    %esp,%ebp
f0103266:	83 ec 08             	sub    $0x8,%esp
f0103269:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.

	//panic("env_run not yet implemented");
	//RYAN: NOTE: i think the enviornment 'e' is created before even calling 'env_run'! so don't need to make it myself
	
	if (curenv != NULL)
f010326c:	8b 15 4c be 18 f0    	mov    0xf018be4c,%edx
f0103272:	85 d2                	test   %edx,%edx
f0103274:	74 07                	je     f010327d <env_run+0x1e>
	{
		//an enviornment is already running, so need to turn the current one off and into the runnable state
		curenv->env_status = ENV_RUNNABLE;
f0103276:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	}
	curenv = e;
f010327d:	a3 4c be 18 f0       	mov    %eax,0xf018be4c
	curenv->env_status = ENV_RUNNING;
f0103282:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103289:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir)); //need to get into the address space of the new enviornment!	
f010328d:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103290:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103296:	76 12                	jbe    f01032aa <env_run+0x4b>
	return (physaddr_t)kva - KERNBASE;
f0103298:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010329e:	0f 22 da             	mov    %edx,%cr3
		
	env_pop_tf(&curenv->env_tf); //need to load in the new registers, so the new EIP and all other registers will be changed to execute user code!
f01032a1:	83 ec 0c             	sub    $0xc,%esp
f01032a4:	50                   	push   %eax
f01032a5:	e8 8d ff ff ff       	call   f0103237 <env_pop_tf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032aa:	52                   	push   %edx
f01032ab:	68 20 53 10 f0       	push   $0xf0105320
f01032b0:	68 6a 02 00 00       	push   $0x26a
f01032b5:	68 5e 5f 10 f0       	push   $0xf0105f5e
f01032ba:	e8 e5 cd ff ff       	call   f01000a4 <_panic>

f01032bf <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01032bf:	f3 0f 1e fb          	endbr32 
f01032c3:	55                   	push   %ebp
f01032c4:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01032c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032c9:	ba 70 00 00 00       	mov    $0x70,%edx
f01032ce:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01032cf:	ba 71 00 00 00       	mov    $0x71,%edx
f01032d4:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01032d5:	0f b6 c0             	movzbl %al,%eax
}
f01032d8:	5d                   	pop    %ebp
f01032d9:	c3                   	ret    

f01032da <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01032da:	f3 0f 1e fb          	endbr32 
f01032de:	55                   	push   %ebp
f01032df:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01032e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01032e4:	ba 70 00 00 00       	mov    $0x70,%edx
f01032e9:	ee                   	out    %al,(%dx)
f01032ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032ed:	ba 71 00 00 00       	mov    $0x71,%edx
f01032f2:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01032f3:	5d                   	pop    %ebp
f01032f4:	c3                   	ret    

f01032f5 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01032f5:	f3 0f 1e fb          	endbr32 
f01032f9:	55                   	push   %ebp
f01032fa:	89 e5                	mov    %esp,%ebp
f01032fc:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01032ff:	ff 75 08             	pushl  0x8(%ebp)
f0103302:	e8 2e d3 ff ff       	call   f0100635 <cputchar>
	*cnt++;
}
f0103307:	83 c4 10             	add    $0x10,%esp
f010330a:	c9                   	leave  
f010330b:	c3                   	ret    

f010330c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010330c:	f3 0f 1e fb          	endbr32 
f0103310:	55                   	push   %ebp
f0103311:	89 e5                	mov    %esp,%ebp
f0103313:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103316:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010331d:	ff 75 0c             	pushl  0xc(%ebp)
f0103320:	ff 75 08             	pushl  0x8(%ebp)
f0103323:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103326:	50                   	push   %eax
f0103327:	68 f5 32 10 f0       	push   $0xf01032f5
f010332c:	e8 c6 0d 00 00       	call   f01040f7 <vprintfmt>
	return cnt;
}
f0103331:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103334:	c9                   	leave  
f0103335:	c3                   	ret    

f0103336 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103336:	f3 0f 1e fb          	endbr32 
f010333a:	55                   	push   %ebp
f010333b:	89 e5                	mov    %esp,%ebp
f010333d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103340:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103343:	50                   	push   %eax
f0103344:	ff 75 08             	pushl  0x8(%ebp)
f0103347:	e8 c0 ff ff ff       	call   f010330c <vcprintf>
	va_end(ap);

	return cnt;
}
f010334c:	c9                   	leave  
f010334d:	c3                   	ret    

f010334e <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010334e:	f3 0f 1e fb          	endbr32 
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103352:	b8 80 c6 18 f0       	mov    $0xf018c680,%eax
f0103357:	c7 05 84 c6 18 f0 00 	movl   $0xf0000000,0xf018c684
f010335e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103361:	66 c7 05 88 c6 18 f0 	movw   $0x10,0xf018c688
f0103368:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f010336a:	66 c7 05 e6 c6 18 f0 	movw   $0x68,0xf018c6e6
f0103371:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103373:	66 c7 05 48 d3 11 f0 	movw   $0x67,0xf011d348
f010337a:	67 00 
f010337c:	66 a3 4a d3 11 f0    	mov    %ax,0xf011d34a
f0103382:	89 c2                	mov    %eax,%edx
f0103384:	c1 ea 10             	shr    $0x10,%edx
f0103387:	88 15 4c d3 11 f0    	mov    %dl,0xf011d34c
f010338d:	c6 05 4e d3 11 f0 40 	movb   $0x40,0xf011d34e
f0103394:	c1 e8 18             	shr    $0x18,%eax
f0103397:	a2 4f d3 11 f0       	mov    %al,0xf011d34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010339c:	c6 05 4d d3 11 f0 89 	movb   $0x89,0xf011d34d
	asm volatile("ltr %0" : : "r" (sel));
f01033a3:	b8 28 00 00 00       	mov    $0x28,%eax
f01033a8:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01033ab:	b8 50 d3 11 f0       	mov    $0xf011d350,%eax
f01033b0:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01033b3:	c3                   	ret    

f01033b4 <trap_init>:
{
f01033b4:	f3 0f 1e fb          	endbr32 
f01033b8:	55                   	push   %ebp
f01033b9:	89 e5                	mov    %esp,%ebp
f01033bb:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], true, GD_KT,label__t_divide_NOEC, 0);
f01033be:	b8 d8 3a 10 f0       	mov    $0xf0103ad8,%eax
f01033c3:	66 a3 60 be 18 f0    	mov    %ax,0xf018be60
f01033c9:	66 c7 05 62 be 18 f0 	movw   $0x8,0xf018be62
f01033d0:	08 00 
f01033d2:	c6 05 64 be 18 f0 00 	movb   $0x0,0xf018be64
f01033d9:	c6 05 65 be 18 f0 8f 	movb   $0x8f,0xf018be65
f01033e0:	c1 e8 10             	shr    $0x10,%eax
f01033e3:	66 a3 66 be 18 f0    	mov    %ax,0xf018be66
	SETGATE(idt[T_DEBUG], true, GD_KT, label__t_debug_NOEC, 0);
f01033e9:	b8 de 3a 10 f0       	mov    $0xf0103ade,%eax
f01033ee:	66 a3 68 be 18 f0    	mov    %ax,0xf018be68
f01033f4:	66 c7 05 6a be 18 f0 	movw   $0x8,0xf018be6a
f01033fb:	08 00 
f01033fd:	c6 05 6c be 18 f0 00 	movb   $0x0,0xf018be6c
f0103404:	c6 05 6d be 18 f0 8f 	movb   $0x8f,0xf018be6d
f010340b:	c1 e8 10             	shr    $0x10,%eax
f010340e:	66 a3 6e be 18 f0    	mov    %ax,0xf018be6e
	SETGATE(idt[T_NMI], false, GD_KT, label__t_nmi_NOEC, 0); //assuming this is false because osdev says its an interrupt
f0103414:	b8 e4 3a 10 f0       	mov    $0xf0103ae4,%eax
f0103419:	66 a3 70 be 18 f0    	mov    %ax,0xf018be70
f010341f:	66 c7 05 72 be 18 f0 	movw   $0x8,0xf018be72
f0103426:	08 00 
f0103428:	c6 05 74 be 18 f0 00 	movb   $0x0,0xf018be74
f010342f:	c6 05 75 be 18 f0 8e 	movb   $0x8e,0xf018be75
f0103436:	c1 e8 10             	shr    $0x10,%eax
f0103439:	66 a3 76 be 18 f0    	mov    %ax,0xf018be76
	SETGATE(idt[T_BRKPT], true, GD_KT, label__t_brkpt_NOEC, 3); //TRUE
f010343f:	b8 ea 3a 10 f0       	mov    $0xf0103aea,%eax
f0103444:	66 a3 78 be 18 f0    	mov    %ax,0xf018be78
f010344a:	66 c7 05 7a be 18 f0 	movw   $0x8,0xf018be7a
f0103451:	08 00 
f0103453:	c6 05 7c be 18 f0 00 	movb   $0x0,0xf018be7c
f010345a:	c6 05 7d be 18 f0 ef 	movb   $0xef,0xf018be7d
f0103461:	c1 e8 10             	shr    $0x10,%eax
f0103464:	66 a3 7e be 18 f0    	mov    %ax,0xf018be7e
	SETGATE(idt[T_OFLOW], true, GD_KT, label__t_oflow_NOEC, 0);
f010346a:	b8 f0 3a 10 f0       	mov    $0xf0103af0,%eax
f010346f:	66 a3 80 be 18 f0    	mov    %ax,0xf018be80
f0103475:	66 c7 05 82 be 18 f0 	movw   $0x8,0xf018be82
f010347c:	08 00 
f010347e:	c6 05 84 be 18 f0 00 	movb   $0x0,0xf018be84
f0103485:	c6 05 85 be 18 f0 8f 	movb   $0x8f,0xf018be85
f010348c:	c1 e8 10             	shr    $0x10,%eax
f010348f:	66 a3 86 be 18 f0    	mov    %ax,0xf018be86
	SETGATE(idt[T_BOUND], true, GD_KT, label__t_bound_NOEC, 0);
f0103495:	b8 f6 3a 10 f0       	mov    $0xf0103af6,%eax
f010349a:	66 a3 88 be 18 f0    	mov    %ax,0xf018be88
f01034a0:	66 c7 05 8a be 18 f0 	movw   $0x8,0xf018be8a
f01034a7:	08 00 
f01034a9:	c6 05 8c be 18 f0 00 	movb   $0x0,0xf018be8c
f01034b0:	c6 05 8d be 18 f0 8f 	movb   $0x8f,0xf018be8d
f01034b7:	c1 e8 10             	shr    $0x10,%eax
f01034ba:	66 a3 8e be 18 f0    	mov    %ax,0xf018be8e
	SETGATE(idt[T_ILLOP], true, GD_KT, label__t_illop_NOEC, 0);
f01034c0:	b8 fc 3a 10 f0       	mov    $0xf0103afc,%eax
f01034c5:	66 a3 90 be 18 f0    	mov    %ax,0xf018be90
f01034cb:	66 c7 05 92 be 18 f0 	movw   $0x8,0xf018be92
f01034d2:	08 00 
f01034d4:	c6 05 94 be 18 f0 00 	movb   $0x0,0xf018be94
f01034db:	c6 05 95 be 18 f0 8f 	movb   $0x8f,0xf018be95
f01034e2:	c1 e8 10             	shr    $0x10,%eax
f01034e5:	66 a3 96 be 18 f0    	mov    %ax,0xf018be96
	SETGATE(idt[T_DEVICE], true, GD_KT, label__t_device_NOEC, 0);
f01034eb:	b8 02 3b 10 f0       	mov    $0xf0103b02,%eax
f01034f0:	66 a3 98 be 18 f0    	mov    %ax,0xf018be98
f01034f6:	66 c7 05 9a be 18 f0 	movw   $0x8,0xf018be9a
f01034fd:	08 00 
f01034ff:	c6 05 9c be 18 f0 00 	movb   $0x0,0xf018be9c
f0103506:	c6 05 9d be 18 f0 8f 	movb   $0x8f,0xf018be9d
f010350d:	c1 e8 10             	shr    $0x10,%eax
f0103510:	66 a3 9e be 18 f0    	mov    %ax,0xf018be9e
	SETGATE(idt[T_DBLFLT], false, GD_KT, label__t_dblflt, 0);
f0103516:	b8 08 3b 10 f0       	mov    $0xf0103b08,%eax
f010351b:	66 a3 a0 be 18 f0    	mov    %ax,0xf018bea0
f0103521:	66 c7 05 a2 be 18 f0 	movw   $0x8,0xf018bea2
f0103528:	08 00 
f010352a:	c6 05 a4 be 18 f0 00 	movb   $0x0,0xf018bea4
f0103531:	c6 05 a5 be 18 f0 8e 	movb   $0x8e,0xf018bea5
f0103538:	c1 e8 10             	shr    $0x10,%eax
f010353b:	66 a3 a6 be 18 f0    	mov    %ax,0xf018bea6
	SETGATE(idt[T_TSS], true, GD_KT, label__t_tss, 0);
f0103541:	b8 0c 3b 10 f0       	mov    $0xf0103b0c,%eax
f0103546:	66 a3 b0 be 18 f0    	mov    %ax,0xf018beb0
f010354c:	66 c7 05 b2 be 18 f0 	movw   $0x8,0xf018beb2
f0103553:	08 00 
f0103555:	c6 05 b4 be 18 f0 00 	movb   $0x0,0xf018beb4
f010355c:	c6 05 b5 be 18 f0 8f 	movb   $0x8f,0xf018beb5
f0103563:	c1 e8 10             	shr    $0x10,%eax
f0103566:	66 a3 b6 be 18 f0    	mov    %ax,0xf018beb6
	SETGATE(idt[T_SEGNP], true, GD_KT, label__t_segnp, 0);
f010356c:	b8 10 3b 10 f0       	mov    $0xf0103b10,%eax
f0103571:	66 a3 b8 be 18 f0    	mov    %ax,0xf018beb8
f0103577:	66 c7 05 ba be 18 f0 	movw   $0x8,0xf018beba
f010357e:	08 00 
f0103580:	c6 05 bc be 18 f0 00 	movb   $0x0,0xf018bebc
f0103587:	c6 05 bd be 18 f0 8f 	movb   $0x8f,0xf018bebd
f010358e:	c1 e8 10             	shr    $0x10,%eax
f0103591:	66 a3 be be 18 f0    	mov    %ax,0xf018bebe
	SETGATE(idt[T_STACK], true, GD_KT, label__t_stack, 0);
f0103597:	b8 14 3b 10 f0       	mov    $0xf0103b14,%eax
f010359c:	66 a3 c0 be 18 f0    	mov    %ax,0xf018bec0
f01035a2:	66 c7 05 c2 be 18 f0 	movw   $0x8,0xf018bec2
f01035a9:	08 00 
f01035ab:	c6 05 c4 be 18 f0 00 	movb   $0x0,0xf018bec4
f01035b2:	c6 05 c5 be 18 f0 8f 	movb   $0x8f,0xf018bec5
f01035b9:	c1 e8 10             	shr    $0x10,%eax
f01035bc:	66 a3 c6 be 18 f0    	mov    %ax,0xf018bec6
	SETGATE(idt[T_GPFLT], true, GD_KT, label__t_gpflt, 0);
f01035c2:	b8 18 3b 10 f0       	mov    $0xf0103b18,%eax
f01035c7:	66 a3 c8 be 18 f0    	mov    %ax,0xf018bec8
f01035cd:	66 c7 05 ca be 18 f0 	movw   $0x8,0xf018beca
f01035d4:	08 00 
f01035d6:	c6 05 cc be 18 f0 00 	movb   $0x0,0xf018becc
f01035dd:	c6 05 cd be 18 f0 8f 	movb   $0x8f,0xf018becd
f01035e4:	c1 e8 10             	shr    $0x10,%eax
f01035e7:	66 a3 ce be 18 f0    	mov    %ax,0xf018bece
	SETGATE(idt[T_PGFLT], true, GD_KT, label__t_pgflt, 0);
f01035ed:	b8 1c 3b 10 f0       	mov    $0xf0103b1c,%eax
f01035f2:	66 a3 d0 be 18 f0    	mov    %ax,0xf018bed0
f01035f8:	66 c7 05 d2 be 18 f0 	movw   $0x8,0xf018bed2
f01035ff:	08 00 
f0103601:	c6 05 d4 be 18 f0 00 	movb   $0x0,0xf018bed4
f0103608:	c6 05 d5 be 18 f0 8f 	movb   $0x8f,0xf018bed5
f010360f:	c1 e8 10             	shr    $0x10,%eax
f0103612:	66 a3 d6 be 18 f0    	mov    %ax,0xf018bed6
	SETGATE(idt[T_FPERR], true, GD_KT, label__t_fperr_NOEC, 0);
f0103618:	b8 20 3b 10 f0       	mov    $0xf0103b20,%eax
f010361d:	66 a3 e0 be 18 f0    	mov    %ax,0xf018bee0
f0103623:	66 c7 05 e2 be 18 f0 	movw   $0x8,0xf018bee2
f010362a:	08 00 
f010362c:	c6 05 e4 be 18 f0 00 	movb   $0x0,0xf018bee4
f0103633:	c6 05 e5 be 18 f0 8f 	movb   $0x8f,0xf018bee5
f010363a:	c1 e8 10             	shr    $0x10,%eax
f010363d:	66 a3 e6 be 18 f0    	mov    %ax,0xf018bee6
	SETGATE(idt[T_ALIGN], true, GD_KT, label__t_align, 0);
f0103643:	b8 26 3b 10 f0       	mov    $0xf0103b26,%eax
f0103648:	66 a3 e8 be 18 f0    	mov    %ax,0xf018bee8
f010364e:	66 c7 05 ea be 18 f0 	movw   $0x8,0xf018beea
f0103655:	08 00 
f0103657:	c6 05 ec be 18 f0 00 	movb   $0x0,0xf018beec
f010365e:	c6 05 ed be 18 f0 8f 	movb   $0x8f,0xf018beed
f0103665:	c1 e8 10             	shr    $0x10,%eax
f0103668:	66 a3 ee be 18 f0    	mov    %ax,0xf018beee
	SETGATE(idt[T_MCHK], false, GD_KT, label__t_mchk_NOEC, 0);
f010366e:	b8 2a 3b 10 f0       	mov    $0xf0103b2a,%eax
f0103673:	66 a3 f0 be 18 f0    	mov    %ax,0xf018bef0
f0103679:	66 c7 05 f2 be 18 f0 	movw   $0x8,0xf018bef2
f0103680:	08 00 
f0103682:	c6 05 f4 be 18 f0 00 	movb   $0x0,0xf018bef4
f0103689:	c6 05 f5 be 18 f0 8e 	movb   $0x8e,0xf018bef5
f0103690:	c1 e8 10             	shr    $0x10,%eax
f0103693:	66 a3 f6 be 18 f0    	mov    %ax,0xf018bef6
	SETGATE(idt[T_SIMDERR], true, GD_KT, label__t_simderr_NOEC, 0);
f0103699:	b8 30 3b 10 f0       	mov    $0xf0103b30,%eax
f010369e:	66 a3 f8 be 18 f0    	mov    %ax,0xf018bef8
f01036a4:	66 c7 05 fa be 18 f0 	movw   $0x8,0xf018befa
f01036ab:	08 00 
f01036ad:	c6 05 fc be 18 f0 00 	movb   $0x0,0xf018befc
f01036b4:	c6 05 fd be 18 f0 8f 	movb   $0x8f,0xf018befd
f01036bb:	c1 e8 10             	shr    $0x10,%eax
f01036be:	66 a3 fe be 18 f0    	mov    %ax,0xf018befe
	SETGATE(idt[T_SYSCALL], true, GD_KT, label__t_syscall_NOEC, 3);
f01036c4:	b8 36 3b 10 f0       	mov    $0xf0103b36,%eax
f01036c9:	66 a3 e0 bf 18 f0    	mov    %ax,0xf018bfe0
f01036cf:	66 c7 05 e2 bf 18 f0 	movw   $0x8,0xf018bfe2
f01036d6:	08 00 
f01036d8:	c6 05 e4 bf 18 f0 00 	movb   $0x0,0xf018bfe4
f01036df:	c6 05 e5 bf 18 f0 ef 	movb   $0xef,0xf018bfe5
f01036e6:	c1 e8 10             	shr    $0x10,%eax
f01036e9:	66 a3 e6 bf 18 f0    	mov    %ax,0xf018bfe6
	trap_init_percpu();
f01036ef:	e8 5a fc ff ff       	call   f010334e <trap_init_percpu>
}
f01036f4:	c9                   	leave  
f01036f5:	c3                   	ret    

f01036f6 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01036f6:	f3 0f 1e fb          	endbr32 
f01036fa:	55                   	push   %ebp
f01036fb:	89 e5                	mov    %esp,%ebp
f01036fd:	53                   	push   %ebx
f01036fe:	83 ec 0c             	sub    $0xc,%esp
f0103701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103704:	ff 33                	pushl  (%ebx)
f0103706:	68 b9 5f 10 f0       	push   $0xf0105fb9
f010370b:	e8 26 fc ff ff       	call   f0103336 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103710:	83 c4 08             	add    $0x8,%esp
f0103713:	ff 73 04             	pushl  0x4(%ebx)
f0103716:	68 c8 5f 10 f0       	push   $0xf0105fc8
f010371b:	e8 16 fc ff ff       	call   f0103336 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103720:	83 c4 08             	add    $0x8,%esp
f0103723:	ff 73 08             	pushl  0x8(%ebx)
f0103726:	68 d7 5f 10 f0       	push   $0xf0105fd7
f010372b:	e8 06 fc ff ff       	call   f0103336 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103730:	83 c4 08             	add    $0x8,%esp
f0103733:	ff 73 0c             	pushl  0xc(%ebx)
f0103736:	68 e6 5f 10 f0       	push   $0xf0105fe6
f010373b:	e8 f6 fb ff ff       	call   f0103336 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103740:	83 c4 08             	add    $0x8,%esp
f0103743:	ff 73 10             	pushl  0x10(%ebx)
f0103746:	68 f5 5f 10 f0       	push   $0xf0105ff5
f010374b:	e8 e6 fb ff ff       	call   f0103336 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103750:	83 c4 08             	add    $0x8,%esp
f0103753:	ff 73 14             	pushl  0x14(%ebx)
f0103756:	68 04 60 10 f0       	push   $0xf0106004
f010375b:	e8 d6 fb ff ff       	call   f0103336 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103760:	83 c4 08             	add    $0x8,%esp
f0103763:	ff 73 18             	pushl  0x18(%ebx)
f0103766:	68 13 60 10 f0       	push   $0xf0106013
f010376b:	e8 c6 fb ff ff       	call   f0103336 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103770:	83 c4 08             	add    $0x8,%esp
f0103773:	ff 73 1c             	pushl  0x1c(%ebx)
f0103776:	68 22 60 10 f0       	push   $0xf0106022
f010377b:	e8 b6 fb ff ff       	call   f0103336 <cprintf>
}
f0103780:	83 c4 10             	add    $0x10,%esp
f0103783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103786:	c9                   	leave  
f0103787:	c3                   	ret    

f0103788 <print_trapframe>:
{
f0103788:	f3 0f 1e fb          	endbr32 
f010378c:	55                   	push   %ebp
f010378d:	89 e5                	mov    %esp,%ebp
f010378f:	56                   	push   %esi
f0103790:	53                   	push   %ebx
f0103791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103794:	83 ec 08             	sub    $0x8,%esp
f0103797:	53                   	push   %ebx
f0103798:	68 58 61 10 f0       	push   $0xf0106158
f010379d:	e8 94 fb ff ff       	call   f0103336 <cprintf>
	print_regs(&tf->tf_regs);
f01037a2:	89 1c 24             	mov    %ebx,(%esp)
f01037a5:	e8 4c ff ff ff       	call   f01036f6 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01037aa:	83 c4 08             	add    $0x8,%esp
f01037ad:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01037b1:	50                   	push   %eax
f01037b2:	68 73 60 10 f0       	push   $0xf0106073
f01037b7:	e8 7a fb ff ff       	call   f0103336 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01037bc:	83 c4 08             	add    $0x8,%esp
f01037bf:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01037c3:	50                   	push   %eax
f01037c4:	68 86 60 10 f0       	push   $0xf0106086
f01037c9:	e8 68 fb ff ff       	call   f0103336 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01037ce:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01037d1:	83 c4 10             	add    $0x10,%esp
f01037d4:	83 f8 13             	cmp    $0x13,%eax
f01037d7:	0f 86 d4 00 00 00    	jbe    f01038b1 <print_trapframe+0x129>
		return "System call";
f01037dd:	83 f8 30             	cmp    $0x30,%eax
f01037e0:	ba 31 60 10 f0       	mov    $0xf0106031,%edx
f01037e5:	b9 40 60 10 f0       	mov    $0xf0106040,%ecx
f01037ea:	0f 44 d1             	cmove  %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01037ed:	83 ec 04             	sub    $0x4,%esp
f01037f0:	52                   	push   %edx
f01037f1:	50                   	push   %eax
f01037f2:	68 99 60 10 f0       	push   $0xf0106099
f01037f7:	e8 3a fb ff ff       	call   f0103336 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01037fc:	83 c4 10             	add    $0x10,%esp
f01037ff:	39 1d 60 c6 18 f0    	cmp    %ebx,0xf018c660
f0103805:	0f 84 b2 00 00 00    	je     f01038bd <print_trapframe+0x135>
	cprintf("  err  0x%08x", tf->tf_err);
f010380b:	83 ec 08             	sub    $0x8,%esp
f010380e:	ff 73 2c             	pushl  0x2c(%ebx)
f0103811:	68 ba 60 10 f0       	push   $0xf01060ba
f0103816:	e8 1b fb ff ff       	call   f0103336 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010381b:	83 c4 10             	add    $0x10,%esp
f010381e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103822:	0f 85 b8 00 00 00    	jne    f01038e0 <print_trapframe+0x158>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103828:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010382b:	89 c2                	mov    %eax,%edx
f010382d:	83 e2 01             	and    $0x1,%edx
f0103830:	b9 4c 60 10 f0       	mov    $0xf010604c,%ecx
f0103835:	ba 57 60 10 f0       	mov    $0xf0106057,%edx
f010383a:	0f 44 ca             	cmove  %edx,%ecx
f010383d:	89 c2                	mov    %eax,%edx
f010383f:	83 e2 02             	and    $0x2,%edx
f0103842:	be 63 60 10 f0       	mov    $0xf0106063,%esi
f0103847:	ba 69 60 10 f0       	mov    $0xf0106069,%edx
f010384c:	0f 45 d6             	cmovne %esi,%edx
f010384f:	83 e0 04             	and    $0x4,%eax
f0103852:	b8 6e 60 10 f0       	mov    $0xf010606e,%eax
f0103857:	be 83 61 10 f0       	mov    $0xf0106183,%esi
f010385c:	0f 44 c6             	cmove  %esi,%eax
f010385f:	51                   	push   %ecx
f0103860:	52                   	push   %edx
f0103861:	50                   	push   %eax
f0103862:	68 c8 60 10 f0       	push   $0xf01060c8
f0103867:	e8 ca fa ff ff       	call   f0103336 <cprintf>
f010386c:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010386f:	83 ec 08             	sub    $0x8,%esp
f0103872:	ff 73 30             	pushl  0x30(%ebx)
f0103875:	68 d7 60 10 f0       	push   $0xf01060d7
f010387a:	e8 b7 fa ff ff       	call   f0103336 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010387f:	83 c4 08             	add    $0x8,%esp
f0103882:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103886:	50                   	push   %eax
f0103887:	68 e6 60 10 f0       	push   $0xf01060e6
f010388c:	e8 a5 fa ff ff       	call   f0103336 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103891:	83 c4 08             	add    $0x8,%esp
f0103894:	ff 73 38             	pushl  0x38(%ebx)
f0103897:	68 f9 60 10 f0       	push   $0xf01060f9
f010389c:	e8 95 fa ff ff       	call   f0103336 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01038a1:	83 c4 10             	add    $0x10,%esp
f01038a4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01038a8:	75 4b                	jne    f01038f5 <print_trapframe+0x16d>
}
f01038aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01038ad:	5b                   	pop    %ebx
f01038ae:	5e                   	pop    %esi
f01038af:	5d                   	pop    %ebp
f01038b0:	c3                   	ret    
		return excnames[trapno];
f01038b1:	8b 14 85 80 63 10 f0 	mov    -0xfef9c80(,%eax,4),%edx
f01038b8:	e9 30 ff ff ff       	jmp    f01037ed <print_trapframe+0x65>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01038bd:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01038c1:	0f 85 44 ff ff ff    	jne    f010380b <print_trapframe+0x83>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01038c7:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01038ca:	83 ec 08             	sub    $0x8,%esp
f01038cd:	50                   	push   %eax
f01038ce:	68 ab 60 10 f0       	push   $0xf01060ab
f01038d3:	e8 5e fa ff ff       	call   f0103336 <cprintf>
f01038d8:	83 c4 10             	add    $0x10,%esp
f01038db:	e9 2b ff ff ff       	jmp    f010380b <print_trapframe+0x83>
		cprintf("\n");
f01038e0:	83 ec 0c             	sub    $0xc,%esp
f01038e3:	68 38 5d 10 f0       	push   $0xf0105d38
f01038e8:	e8 49 fa ff ff       	call   f0103336 <cprintf>
f01038ed:	83 c4 10             	add    $0x10,%esp
f01038f0:	e9 7a ff ff ff       	jmp    f010386f <print_trapframe+0xe7>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01038f5:	83 ec 08             	sub    $0x8,%esp
f01038f8:	ff 73 3c             	pushl  0x3c(%ebx)
f01038fb:	68 08 61 10 f0       	push   $0xf0106108
f0103900:	e8 31 fa ff ff       	call   f0103336 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103905:	83 c4 08             	add    $0x8,%esp
f0103908:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010390c:	50                   	push   %eax
f010390d:	68 17 61 10 f0       	push   $0xf0106117
f0103912:	e8 1f fa ff ff       	call   f0103336 <cprintf>
f0103917:	83 c4 10             	add    $0x10,%esp
}
f010391a:	eb 8e                	jmp    f01038aa <print_trapframe+0x122>

f010391c <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010391c:	f3 0f 1e fb          	endbr32 
f0103920:	55                   	push   %ebp
f0103921:	89 e5                	mov    %esp,%ebp
f0103923:	53                   	push   %ebx
f0103924:	83 ec 04             	sub    $0x4,%esp
f0103927:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010392a:	0f 20 d0             	mov    %cr2,%eax

	// LAB 3: Your code here.
	
	//RYAN: the tf->tf_cs is the code segment. a value of 0 means its in kernel mode, and value of 3 means in user mode according to 
	//Intel docs page 3160 out of 5198
	if (tf->tf_cs == 3)
f010392d:	66 83 7b 34 03       	cmpw   $0x3,0x34(%ebx)
f0103932:	74 34                	je     f0103968 <page_fault_handler+0x4c>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103934:	ff 73 30             	pushl  0x30(%ebx)
f0103937:	50                   	push   %eax
f0103938:	a1 4c be 18 f0       	mov    0xf018be4c,%eax
f010393d:	ff 70 48             	pushl  0x48(%eax)
f0103940:	68 28 63 10 f0       	push   $0xf0106328
f0103945:	e8 ec f9 ff ff       	call   f0103336 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010394a:	89 1c 24             	mov    %ebx,(%esp)
f010394d:	e8 36 fe ff ff       	call   f0103788 <print_trapframe>
	env_destroy(curenv);
f0103952:	83 c4 04             	add    $0x4,%esp
f0103955:	ff 35 4c be 18 f0    	pushl  0xf018be4c
f010395b:	e8 a7 f8 ff ff       	call   f0103207 <env_destroy>
}
f0103960:	83 c4 10             	add    $0x10,%esp
f0103963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103966:	c9                   	leave  
f0103967:	c3                   	ret    
		panic("page fault happened in kernel mode!! in page_fault_handler() function in kern/trap.c");
f0103968:	83 ec 04             	sub    $0x4,%esp
f010396b:	68 d0 62 10 f0       	push   $0xf01062d0
f0103970:	68 3c 01 00 00       	push   $0x13c
f0103975:	68 2a 61 10 f0       	push   $0xf010612a
f010397a:	e8 25 c7 ff ff       	call   f01000a4 <_panic>

f010397f <trap>:
{
f010397f:	f3 0f 1e fb          	endbr32 
f0103983:	55                   	push   %ebp
f0103984:	89 e5                	mov    %esp,%ebp
f0103986:	57                   	push   %edi
f0103987:	56                   	push   %esi
f0103988:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010398b:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010398c:	9c                   	pushf  
f010398d:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f010398e:	f6 c4 02             	test   $0x2,%ah
f0103991:	74 19                	je     f01039ac <trap+0x2d>
f0103993:	68 36 61 10 f0       	push   $0xf0106136
f0103998:	68 ad 5a 10 f0       	push   $0xf0105aad
f010399d:	68 0f 01 00 00       	push   $0x10f
f01039a2:	68 2a 61 10 f0       	push   $0xf010612a
f01039a7:	e8 f8 c6 ff ff       	call   f01000a4 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f01039ac:	83 ec 08             	sub    $0x8,%esp
f01039af:	56                   	push   %esi
f01039b0:	68 4f 61 10 f0       	push   $0xf010614f
f01039b5:	e8 7c f9 ff ff       	call   f0103336 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f01039ba:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01039be:	83 e0 03             	and    $0x3,%eax
f01039c1:	83 c4 10             	add    $0x10,%esp
f01039c4:	66 83 f8 03          	cmp    $0x3,%ax
f01039c8:	75 1c                	jne    f01039e6 <trap+0x67>
		assert(curenv);
f01039ca:	a1 4c be 18 f0       	mov    0xf018be4c,%eax
f01039cf:	85 c0                	test   %eax,%eax
f01039d1:	0f 84 83 00 00 00    	je     f0103a5a <trap+0xdb>
		curenv->env_tf = *tf;
f01039d7:	b9 11 00 00 00       	mov    $0x11,%ecx
f01039dc:	89 c7                	mov    %eax,%edi
f01039de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01039e0:	8b 35 4c be 18 f0    	mov    0xf018be4c,%esi
	last_tf = tf;
f01039e6:	89 35 60 c6 18 f0    	mov    %esi,0xf018c660
	if (tf->tf_trapno == 14)
f01039ec:	8b 46 28             	mov    0x28(%esi),%eax
f01039ef:	83 f8 0e             	cmp    $0xe,%eax
f01039f2:	74 7f                	je     f0103a73 <trap+0xf4>
	else if (tf->tf_trapno == 3)
f01039f4:	83 f8 03             	cmp    $0x3,%eax
f01039f7:	0f 84 84 00 00 00    	je     f0103a81 <trap+0x102>
	else if (tf->tf_trapno == 48)
f01039fd:	83 f8 30             	cmp    $0x30,%eax
f0103a00:	0f 84 89 00 00 00    	je     f0103a8f <trap+0x110>
	print_trapframe(tf);
f0103a06:	83 ec 0c             	sub    $0xc,%esp
f0103a09:	56                   	push   %esi
f0103a0a:	e8 79 fd ff ff       	call   f0103788 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103a0f:	83 c4 10             	add    $0x10,%esp
f0103a12:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103a17:	0f 84 9a 00 00 00    	je     f0103ab7 <trap+0x138>
		env_destroy(curenv);
f0103a1d:	83 ec 0c             	sub    $0xc,%esp
f0103a20:	ff 35 4c be 18 f0    	pushl  0xf018be4c
f0103a26:	e8 dc f7 ff ff       	call   f0103207 <env_destroy>
		return;
f0103a2b:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103a2e:	a1 4c be 18 f0       	mov    0xf018be4c,%eax
f0103a33:	85 c0                	test   %eax,%eax
f0103a35:	74 0a                	je     f0103a41 <trap+0xc2>
f0103a37:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a3b:	0f 84 8d 00 00 00    	je     f0103ace <trap+0x14f>
f0103a41:	68 4c 63 10 f0       	push   $0xf010634c
f0103a46:	68 ad 5a 10 f0       	push   $0xf0105aad
f0103a4b:	68 27 01 00 00       	push   $0x127
f0103a50:	68 2a 61 10 f0       	push   $0xf010612a
f0103a55:	e8 4a c6 ff ff       	call   f01000a4 <_panic>
		assert(curenv);
f0103a5a:	68 6a 61 10 f0       	push   $0xf010616a
f0103a5f:	68 ad 5a 10 f0       	push   $0xf0105aad
f0103a64:	68 15 01 00 00       	push   $0x115
f0103a69:	68 2a 61 10 f0       	push   $0xf010612a
f0103a6e:	e8 31 c6 ff ff       	call   f01000a4 <_panic>
		page_fault_handler(tf);
f0103a73:	83 ec 0c             	sub    $0xc,%esp
f0103a76:	56                   	push   %esi
f0103a77:	e8 a0 fe ff ff       	call   f010391c <page_fault_handler>
		return;
f0103a7c:	83 c4 10             	add    $0x10,%esp
f0103a7f:	eb ad                	jmp    f0103a2e <trap+0xaf>
		monitor(tf);
f0103a81:	83 ec 0c             	sub    $0xc,%esp
f0103a84:	56                   	push   %esi
f0103a85:	e8 21 cd ff ff       	call   f01007ab <monitor>
		return;
f0103a8a:	83 c4 10             	add    $0x10,%esp
f0103a8d:	eb 9f                	jmp    f0103a2e <trap+0xaf>
		int32_t val = syscall(user_syscall_val, edx, ecx, ebx, edi, esi);
f0103a8f:	83 ec 08             	sub    $0x8,%esp
f0103a92:	ff 76 04             	pushl  0x4(%esi)
f0103a95:	ff 36                	pushl  (%esi)
f0103a97:	ff 76 10             	pushl  0x10(%esi)
f0103a9a:	ff 76 18             	pushl  0x18(%esi)
f0103a9d:	ff 76 14             	pushl  0x14(%esi)
f0103aa0:	ff 76 1c             	pushl  0x1c(%esi)
f0103aa3:	e8 b4 00 00 00       	call   f0103b5c <syscall>
f0103aa8:	89 c2                	mov    %eax,%edx
		curenv->env_tf.tf_regs.reg_eax = val;
f0103aaa:	a1 4c be 18 f0       	mov    0xf018be4c,%eax
f0103aaf:	89 50 1c             	mov    %edx,0x1c(%eax)
f0103ab2:	83 c4 20             	add    $0x20,%esp
f0103ab5:	eb 80                	jmp    f0103a37 <trap+0xb8>
		panic("unhandled trap in kernel");
f0103ab7:	83 ec 04             	sub    $0x4,%esp
f0103aba:	68 71 61 10 f0       	push   $0xf0106171
f0103abf:	68 fe 00 00 00       	push   $0xfe
f0103ac4:	68 2a 61 10 f0       	push   $0xf010612a
f0103ac9:	e8 d6 c5 ff ff       	call   f01000a4 <_panic>
	env_run(curenv);
f0103ace:	83 ec 0c             	sub    $0xc,%esp
f0103ad1:	50                   	push   %eax
f0103ad2:	e8 88 f7 ff ff       	call   f010325f <env_run>
f0103ad7:	90                   	nop

f0103ad8 <label__t_divide_NOEC>:
 */

//NOTE: 'name' is just a symbol!! it doesn't matter what you name it as long as it makes sense!

	//divide error does NOT push an error code
	TRAPHANDLER_NOEC(label__t_divide_NOEC, T_DIVIDE) //0 -divide error does NOT push an error code
f0103ad8:	6a 00                	push   $0x0
f0103ada:	6a 00                	push   $0x0
f0103adc:	eb 67                	jmp    f0103b45 <_alltraps>

f0103ade <label__t_debug_NOEC>:
	//label__t_divide_NOEC
	TRAPHANDLER_NOEC(label__t_debug_NOEC, T_DEBUG) //1 - no error code
f0103ade:	6a 00                	push   $0x0
f0103ae0:	6a 01                	push   $0x1
f0103ae2:	eb 61                	jmp    f0103b45 <_alltraps>

f0103ae4 <label__t_nmi_NOEC>:

	TRAPHANDLER_NOEC(label__t_nmi_NOEC, T_NMI) //2 - https://wiki.osdev.org/Exceptions
f0103ae4:	6a 00                	push   $0x0
f0103ae6:	6a 02                	push   $0x2
f0103ae8:	eb 5b                	jmp    f0103b45 <_alltraps>

f0103aea <label__t_brkpt_NOEC>:
	
	TRAPHANDLER_NOEC(label__t_brkpt_NOEC, T_BRKPT) //3
f0103aea:	6a 00                	push   $0x0
f0103aec:	6a 03                	push   $0x3
f0103aee:	eb 55                	jmp    f0103b45 <_alltraps>

f0103af0 <label__t_oflow_NOEC>:
	TRAPHANDLER_NOEC(label__t_oflow_NOEC, T_OFLOW) //4
f0103af0:	6a 00                	push   $0x0
f0103af2:	6a 04                	push   $0x4
f0103af4:	eb 4f                	jmp    f0103b45 <_alltraps>

f0103af6 <label__t_bound_NOEC>:
	TRAPHANDLER_NOEC(label__t_bound_NOEC, T_BOUND) //5
f0103af6:	6a 00                	push   $0x0
f0103af8:	6a 05                	push   $0x5
f0103afa:	eb 49                	jmp    f0103b45 <_alltraps>

f0103afc <label__t_illop_NOEC>:
	TRAPHANDLER_NOEC(label__t_illop_NOEC, T_ILLOP) //6
f0103afc:	6a 00                	push   $0x0
f0103afe:	6a 06                	push   $0x6
f0103b00:	eb 43                	jmp    f0103b45 <_alltraps>

f0103b02 <label__t_device_NOEC>:
	TRAPHANDLER_NOEC(label__t_device_NOEC, T_DEVICE) //7
f0103b02:	6a 00                	push   $0x0
f0103b04:	6a 07                	push   $0x7
f0103b06:	eb 3d                	jmp    f0103b45 <_alltraps>

f0103b08 <label__t_dblflt>:

	TRAPHANDLER(label__t_dblflt, T_DBLFLT) //8
f0103b08:	6a 08                	push   $0x8
f0103b0a:	eb 39                	jmp    f0103b45 <_alltraps>

f0103b0c <label__t_tss>:
				//9 - reserved (not generated by recent processors)
	TRAPHANDLER(label__t_tss, T_TSS) //10
f0103b0c:	6a 0a                	push   $0xa
f0103b0e:	eb 35                	jmp    f0103b45 <_alltraps>

f0103b10 <label__t_segnp>:
	TRAPHANDLER(label__t_segnp, T_SEGNP) //11
f0103b10:	6a 0b                	push   $0xb
f0103b12:	eb 31                	jmp    f0103b45 <_alltraps>

f0103b14 <label__t_stack>:
	TRAPHANDLER(label__t_stack, T_STACK) //12
f0103b14:	6a 0c                	push   $0xc
f0103b16:	eb 2d                	jmp    f0103b45 <_alltraps>

f0103b18 <label__t_gpflt>:
	TRAPHANDLER(label__t_gpflt, T_GPFLT) //13
f0103b18:	6a 0d                	push   $0xd
f0103b1a:	eb 29                	jmp    f0103b45 <_alltraps>

f0103b1c <label__t_pgflt>:
	TRAPHANDLER(label__t_pgflt, T_PGFLT) //14
f0103b1c:	6a 0e                	push   $0xe
f0103b1e:	eb 25                	jmp    f0103b45 <_alltraps>

f0103b20 <label__t_fperr_NOEC>:
			       //15 - reserved
	TRAPHANDLER_NOEC(label__t_fperr_NOEC, T_FPERR) //16
f0103b20:	6a 00                	push   $0x0
f0103b22:	6a 10                	push   $0x10
f0103b24:	eb 1f                	jmp    f0103b45 <_alltraps>

f0103b26 <label__t_align>:
	
	TRAPHANDLER(label__t_align, T_ALIGN) //17 - YES error code
f0103b26:	6a 11                	push   $0x11
f0103b28:	eb 1b                	jmp    f0103b45 <_alltraps>

f0103b2a <label__t_mchk_NOEC>:
	
	TRAPHANDLER_NOEC(label__t_mchk_NOEC, T_MCHK) //18
f0103b2a:	6a 00                	push   $0x0
f0103b2c:	6a 12                	push   $0x12
f0103b2e:	eb 15                	jmp    f0103b45 <_alltraps>

f0103b30 <label__t_simderr_NOEC>:
	TRAPHANDLER_NOEC(label__t_simderr_NOEC, T_SIMDERR) //19
f0103b30:	6a 00                	push   $0x0
f0103b32:	6a 13                	push   $0x13
f0103b34:	eb 0f                	jmp    f0103b45 <_alltraps>

f0103b36 <label__t_syscall_NOEC>:
	
	TRAPHANDLER_NOEC(label__t_syscall_NOEC, T_SYSCALL) //48 -only CPU can push error codes; T_SYSCALL can be ANY #, this means the CPU doesn't
f0103b36:	6a 00                	push   $0x0
f0103b38:	6a 30                	push   $0x30
f0103b3a:	eb 09                	jmp    f0103b45 <_alltraps>

f0103b3c <label__t_default_NOEC>:
	TRAPHANDLER_NOEC(label__t_default_NOEC, T_DEFAULT) //500
f0103b3c:	6a 00                	push   $0x0
f0103b3e:	68 f4 01 00 00       	push   $0x1f4
f0103b43:	eb 00                	jmp    f0103b45 <_alltraps>

f0103b45 <_alltraps>:
        #step 1: push struct PushRegs as first step to emulating the TrapFrame like the lab 3 doc says
	
	//NOTE: the trap number is pushed first, then %ds, then %es in struct TrapFrame definition
	//NOTE: GD_KD is only 8 bits

	push %ds 
f0103b45:	1e                   	push   %ds
	push %es
f0103b46:	06                   	push   %es
	pushal          //apparently 'pushal' pushes all registers from the PushRegs struct
f0103b47:	60                   	pusha  
	movw $GD_KD, %bx //can't load immediate into register unless its the same size??
f0103b48:	66 bb 10 00          	mov    $0x10,%bx
	movw %bx, %ds
f0103b4c:	8e db                	mov    %ebx,%ds
	movw %bx, %es
f0103b4e:	8e c3                	mov    %ebx,%es
	pushl %esp
f0103b50:	54                   	push   %esp
	call trap
f0103b51:	e8 29 fe ff ff       	call   f010397f <trap>
	add 4, %esp
f0103b56:	03 25 04 00 00 00    	add    0x4,%esp

f0103b5c <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103b5c:	f3 0f 1e fb          	endbr32 
f0103b60:	55                   	push   %ebp
f0103b61:	89 e5                	mov    %esp,%ebp
f0103b63:	83 ec 18             	sub    $0x18,%esp
f0103b66:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b69:	83 f8 04             	cmp    $0x4,%eax
f0103b6c:	0f 87 c7 00 00 00    	ja     f0103c39 <syscall+0xdd>
f0103b72:	3e ff 24 85 3c 64 10 	notrack jmp *-0xfef9bc4(,%eax,4)
f0103b79:	f0 
	user_mem_assert(curenv, (void *)s, len, PTE_U); //PTE_U for user read 
f0103b7a:	6a 04                	push   $0x4
f0103b7c:	ff 75 10             	pushl  0x10(%ebp)
f0103b7f:	ff 75 0c             	pushl  0xc(%ebp)
f0103b82:	ff 35 4c be 18 f0    	pushl  0xf018be4c
f0103b88:	e8 b2 ef ff ff       	call   f0102b3f <user_mem_assert>
	cprintf("%.*s", len, s);
f0103b8d:	83 c4 0c             	add    $0xc,%esp
f0103b90:	ff 75 0c             	pushl  0xc(%ebp)
f0103b93:	ff 75 10             	pushl  0x10(%ebp)
f0103b96:	68 d0 63 10 f0       	push   $0xf01063d0
f0103b9b:	e8 96 f7 ff ff       	call   f0103336 <cprintf>
}
f0103ba0:	83 c4 10             	add    $0x10,%esp

	switch (syscallno) 
	{
		case SYS_cputs: 
		      sys_cputs((const char*) a1, a2);
		      return 0; //assuming return a value of 0 for success     
f0103ba3:	b8 00 00 00 00       	mov    $0x0,%eax
		      cprintf("did NSYSCALLS but idk what that is supposed to do ");
		      return -1;
	default:
		return -E_INVAL;
	}
}
f0103ba8:	c9                   	leave  
f0103ba9:	c3                   	ret    
	return cons_getc();
f0103baa:	e8 2e c9 ff ff       	call   f01004dd <cons_getc>
		      return val;
f0103baf:	eb f7                	jmp    f0103ba8 <syscall+0x4c>
	return curenv->env_id;
f0103bb1:	a1 4c be 18 f0       	mov    0xf018be4c,%eax
f0103bb6:	8b 40 48             	mov    0x48(%eax),%eax
		      return hehe;
f0103bb9:	eb ed                	jmp    f0103ba8 <syscall+0x4c>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0103bbb:	83 ec 04             	sub    $0x4,%esp
f0103bbe:	6a 01                	push   $0x1
f0103bc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103bc3:	50                   	push   %eax
f0103bc4:	ff 75 0c             	pushl  0xc(%ebp)
f0103bc7:	e8 c3 ef ff ff       	call   f0102b8f <envid2env>
f0103bcc:	83 c4 10             	add    $0x10,%esp
f0103bcf:	85 c0                	test   %eax,%eax
f0103bd1:	78 d5                	js     f0103ba8 <syscall+0x4c>
	if (e == curenv)
f0103bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103bd6:	a1 4c be 18 f0       	mov    0xf018be4c,%eax
f0103bdb:	39 c2                	cmp    %eax,%edx
f0103bdd:	74 2b                	je     f0103c0a <syscall+0xae>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103bdf:	83 ec 04             	sub    $0x4,%esp
f0103be2:	ff 72 48             	pushl  0x48(%edx)
f0103be5:	ff 70 48             	pushl  0x48(%eax)
f0103be8:	68 f0 63 10 f0       	push   $0xf01063f0
f0103bed:	e8 44 f7 ff ff       	call   f0103336 <cprintf>
f0103bf2:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103bf5:	83 ec 0c             	sub    $0xc,%esp
f0103bf8:	ff 75 f4             	pushl  -0xc(%ebp)
f0103bfb:	e8 07 f6 ff ff       	call   f0103207 <env_destroy>
	return 0;
f0103c00:	83 c4 10             	add    $0x10,%esp
f0103c03:	b8 00 00 00 00       	mov    $0x0,%eax
		      return sys_env_destroy(a1);
f0103c08:	eb 9e                	jmp    f0103ba8 <syscall+0x4c>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103c0a:	83 ec 08             	sub    $0x8,%esp
f0103c0d:	ff 70 48             	pushl  0x48(%eax)
f0103c10:	68 d5 63 10 f0       	push   $0xf01063d5
f0103c15:	e8 1c f7 ff ff       	call   f0103336 <cprintf>
f0103c1a:	83 c4 10             	add    $0x10,%esp
f0103c1d:	eb d6                	jmp    f0103bf5 <syscall+0x99>
		      cprintf("did NSYSCALLS but idk what that is supposed to do ");
f0103c1f:	83 ec 0c             	sub    $0xc,%esp
f0103c22:	68 08 64 10 f0       	push   $0xf0106408
f0103c27:	e8 0a f7 ff ff       	call   f0103336 <cprintf>
		      return -1;
f0103c2c:	83 c4 10             	add    $0x10,%esp
f0103c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c34:	e9 6f ff ff ff       	jmp    f0103ba8 <syscall+0x4c>
f0103c39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103c3e:	e9 65 ff ff ff       	jmp    f0103ba8 <syscall+0x4c>

f0103c43 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103c43:	55                   	push   %ebp
f0103c44:	89 e5                	mov    %esp,%ebp
f0103c46:	57                   	push   %edi
f0103c47:	56                   	push   %esi
f0103c48:	53                   	push   %ebx
f0103c49:	83 ec 14             	sub    $0x14,%esp
f0103c4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103c4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103c52:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103c55:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103c58:	8b 1a                	mov    (%edx),%ebx
f0103c5a:	8b 01                	mov    (%ecx),%eax
f0103c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103c5f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103c66:	eb 23                	jmp    f0103c8b <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103c68:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103c6b:	eb 1e                	jmp    f0103c8b <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103c6d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103c70:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103c73:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103c77:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103c7a:	73 46                	jae    f0103cc2 <stab_binsearch+0x7f>
			*region_left = m;
f0103c7c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103c7f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103c81:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103c84:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103c8b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103c8e:	7f 5f                	jg     f0103cef <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0103c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103c93:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0103c96:	89 d0                	mov    %edx,%eax
f0103c98:	c1 e8 1f             	shr    $0x1f,%eax
f0103c9b:	01 d0                	add    %edx,%eax
f0103c9d:	89 c7                	mov    %eax,%edi
f0103c9f:	d1 ff                	sar    %edi
f0103ca1:	83 e0 fe             	and    $0xfffffffe,%eax
f0103ca4:	01 f8                	add    %edi,%eax
f0103ca6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103ca9:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103cad:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103caf:	39 c3                	cmp    %eax,%ebx
f0103cb1:	7f b5                	jg     f0103c68 <stab_binsearch+0x25>
f0103cb3:	0f b6 0a             	movzbl (%edx),%ecx
f0103cb6:	83 ea 0c             	sub    $0xc,%edx
f0103cb9:	39 f1                	cmp    %esi,%ecx
f0103cbb:	74 b0                	je     f0103c6d <stab_binsearch+0x2a>
			m--;
f0103cbd:	83 e8 01             	sub    $0x1,%eax
f0103cc0:	eb ed                	jmp    f0103caf <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0103cc2:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103cc5:	76 14                	jbe    f0103cdb <stab_binsearch+0x98>
			*region_right = m - 1;
f0103cc7:	83 e8 01             	sub    $0x1,%eax
f0103cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103ccd:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103cd0:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103cd2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103cd9:	eb b0                	jmp    f0103c8b <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103cdb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103cde:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103ce0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103ce4:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103ce6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103ced:	eb 9c                	jmp    f0103c8b <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0103cef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103cf3:	75 15                	jne    f0103d0a <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0103cf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103cf8:	8b 00                	mov    (%eax),%eax
f0103cfa:	83 e8 01             	sub    $0x1,%eax
f0103cfd:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103d00:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103d02:	83 c4 14             	add    $0x14,%esp
f0103d05:	5b                   	pop    %ebx
f0103d06:	5e                   	pop    %esi
f0103d07:	5f                   	pop    %edi
f0103d08:	5d                   	pop    %ebp
f0103d09:	c3                   	ret    
		for (l = *region_right;
f0103d0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d0d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103d0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d12:	8b 0f                	mov    (%edi),%ecx
f0103d14:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103d17:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103d1a:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0103d1e:	eb 03                	jmp    f0103d23 <stab_binsearch+0xe0>
		     l--)
f0103d20:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103d23:	39 c1                	cmp    %eax,%ecx
f0103d25:	7d 0a                	jge    f0103d31 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0103d27:	0f b6 1a             	movzbl (%edx),%ebx
f0103d2a:	83 ea 0c             	sub    $0xc,%edx
f0103d2d:	39 f3                	cmp    %esi,%ebx
f0103d2f:	75 ef                	jne    f0103d20 <stab_binsearch+0xdd>
		*region_left = l;
f0103d31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d34:	89 07                	mov    %eax,(%edi)
}
f0103d36:	eb ca                	jmp    f0103d02 <stab_binsearch+0xbf>

f0103d38 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103d38:	f3 0f 1e fb          	endbr32 
f0103d3c:	55                   	push   %ebp
f0103d3d:	89 e5                	mov    %esp,%ebp
f0103d3f:	57                   	push   %edi
f0103d40:	56                   	push   %esi
f0103d41:	53                   	push   %ebx
f0103d42:	83 ec 4c             	sub    $0x4c,%esp
f0103d45:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103d4b:	c7 03 50 64 10 f0    	movl   $0xf0106450,(%ebx)
	info->eip_line = 0;
f0103d51:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103d58:	c7 43 08 50 64 10 f0 	movl   $0xf0106450,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103d5f:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103d66:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103d69:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) 
f0103d70:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103d76:	0f 86 24 01 00 00    	jbe    f0103ea0 <debuginfo_eip+0x168>
	{
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103d7c:	c7 45 b8 8b 2a 11 f0 	movl   $0xf0112a8b,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103d83:	c7 45 b4 e5 fe 10 f0 	movl   $0xf010fee5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0103d8a:	bf e4 fe 10 f0       	mov    $0xf010fee4,%edi
		stabs = __STAB_BEGIN__;
f0103d8f:	c7 45 bc 68 66 10 f0 	movl   $0xf0106668,-0x44(%ebp)
		}
		
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103d96:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0103d99:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f0103d9c:	0f 83 3f 02 00 00    	jae    f0103fe1 <debuginfo_eip+0x2a9>
f0103da2:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103da6:	0f 85 3c 02 00 00    	jne    f0103fe8 <debuginfo_eip+0x2b0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103dac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103db3:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0103db6:	c1 ff 02             	sar    $0x2,%edi
f0103db9:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0103dbf:	83 e8 01             	sub    $0x1,%eax
f0103dc2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103dc5:	83 ec 08             	sub    $0x8,%esp
f0103dc8:	56                   	push   %esi
f0103dc9:	6a 64                	push   $0x64
f0103dcb:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103dce:	89 d1                	mov    %edx,%ecx
f0103dd0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103dd3:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103dd6:	89 f8                	mov    %edi,%eax
f0103dd8:	e8 66 fe ff ff       	call   f0103c43 <stab_binsearch>
	if (lfile == 0)
f0103ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103de0:	83 c4 10             	add    $0x10,%esp
f0103de3:	85 c0                	test   %eax,%eax
f0103de5:	0f 84 04 02 00 00    	je     f0103fef <debuginfo_eip+0x2b7>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103deb:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103df1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103df4:	83 ec 08             	sub    $0x8,%esp
f0103df7:	56                   	push   %esi
f0103df8:	6a 24                	push   $0x24
f0103dfa:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0103dfd:	89 d1                	mov    %edx,%ecx
f0103dff:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103e02:	89 f8                	mov    %edi,%eax
f0103e04:	e8 3a fe ff ff       	call   f0103c43 <stab_binsearch>

	if (lfun <= rfun) {
f0103e09:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103e0c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103e0f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0103e12:	83 c4 10             	add    $0x10,%esp
f0103e15:	39 c8                	cmp    %ecx,%eax
f0103e17:	0f 8f 13 01 00 00    	jg     f0103f30 <debuginfo_eip+0x1f8>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103e1d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103e20:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0103e23:	8b 11                	mov    (%ecx),%edx
f0103e25:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103e28:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0103e2b:	39 fa                	cmp    %edi,%edx
f0103e2d:	73 06                	jae    f0103e35 <debuginfo_eip+0xfd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103e2f:	03 55 b4             	add    -0x4c(%ebp),%edx
f0103e32:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103e35:	8b 51 08             	mov    0x8(%ecx),%edx
f0103e38:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103e3b:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103e3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103e40:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103e43:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103e46:	83 ec 08             	sub    $0x8,%esp
f0103e49:	6a 3a                	push   $0x3a
f0103e4b:	ff 73 08             	pushl  0x8(%ebx)
f0103e4e:	e8 db 09 00 00       	call   f010482e <strfind>
f0103e53:	2b 43 08             	sub    0x8(%ebx),%eax
f0103e56:	89 43 0c             	mov    %eax,0xc(%ebx)
	//Lab 3 code


	//RYAN: it said 'search within [lline, rline] so that tells me to use the binary search functino they included
	//NOTE: i forgot that lline and rline are just indices, not the actual values
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103e59:	83 c4 08             	add    $0x8,%esp
f0103e5c:	56                   	push   %esi
f0103e5d:	6a 44                	push   $0x44
f0103e5f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103e62:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103e65:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0103e68:	89 f0                	mov    %esi,%eax
f0103e6a:	e8 d4 fd ff ff       	call   f0103c43 <stab_binsearch>

	
	//If *region_left > *region_right, then 'addr' is not contained in any matching stab.	
	if (lline > rline)
f0103e6f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103e72:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e75:	83 c4 10             	add    $0x10,%esp
f0103e78:	39 c2                	cmp    %eax,%edx
f0103e7a:	0f 8f 76 01 00 00    	jg     f0103ff6 <debuginfo_eip+0x2be>
	else
	{
		//lline is just an index, just like normal binary search says 
		// in "https://sourceware.org/gdb/onlinedocs/stabs.html/Line-Numbers.html#Line-Numbers"
		// it mentions that n_desc contains the line number and is important when searching for the line number using stab_binsearch
		info->eip_line = stabs[rline].n_desc; 
f0103e80:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103e83:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0103e88:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103e8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e8e:	89 d0                	mov    %edx,%eax
f0103e90:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103e93:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f0103e97:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103e9b:	e9 ae 00 00 00       	jmp    f0103f4e <debuginfo_eip+0x216>
		int val = user_mem_check(curenv, (void*) usd, sizeof(struct UserStabData), PTE_U);
f0103ea0:	6a 04                	push   $0x4
f0103ea2:	6a 10                	push   $0x10
f0103ea4:	68 00 00 20 00       	push   $0x200000
f0103ea9:	ff 35 4c be 18 f0    	pushl  0xf018be4c
f0103eaf:	e8 f4 eb ff ff       	call   f0102aa8 <user_mem_check>
		if (val < 0)
f0103eb4:	83 c4 10             	add    $0x10,%esp
f0103eb7:	85 c0                	test   %eax,%eax
f0103eb9:	0f 88 1b 01 00 00    	js     f0103fda <debuginfo_eip+0x2a2>
		stabs = usd->stabs;
f0103ebf:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0103ec5:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0103ec8:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0103ece:	a1 08 00 20 00       	mov    0x200008,%eax
f0103ed3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103ed6:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103edc:	89 55 b8             	mov    %edx,-0x48(%ebp)
		int stab_val = user_mem_check(curenv, (void *) stabs, stabs - stab_end, PTE_U);
f0103edf:	6a 04                	push   $0x4
f0103ee1:	89 c8                	mov    %ecx,%eax
f0103ee3:	29 f8                	sub    %edi,%eax
f0103ee5:	c1 f8 02             	sar    $0x2,%eax
f0103ee8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103eee:	50                   	push   %eax
f0103eef:	51                   	push   %ecx
f0103ef0:	ff 35 4c be 18 f0    	pushl  0xf018be4c
f0103ef6:	e8 ad eb ff ff       	call   f0102aa8 <user_mem_check>
f0103efb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		int stabstr_val = user_mem_check(curenv, (void *) stabstr, stabstr - stabstr_end, PTE_U);
f0103efe:	6a 04                	push   $0x4
f0103f00:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0103f03:	89 c8                	mov    %ecx,%eax
f0103f05:	2b 45 b8             	sub    -0x48(%ebp),%eax
f0103f08:	50                   	push   %eax
f0103f09:	51                   	push   %ecx
f0103f0a:	ff 35 4c be 18 f0    	pushl  0xf018be4c
f0103f10:	e8 93 eb ff ff       	call   f0102aa8 <user_mem_check>
		if ( (stab_val < 0 ) || (stabstr_val < 0))
f0103f15:	83 c4 20             	add    $0x20,%esp
f0103f18:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0103f1c:	78 08                	js     f0103f26 <debuginfo_eip+0x1ee>
f0103f1e:	85 c0                	test   %eax,%eax
f0103f20:	0f 89 70 fe ff ff    	jns    f0103d96 <debuginfo_eip+0x5e>
			return -1; //error
f0103f26:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0103f2b:	e9 d2 00 00 00       	jmp    f0104002 <debuginfo_eip+0x2ca>
		info->eip_fn_addr = addr;
f0103f30:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103f33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103f36:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103f39:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f3c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103f3f:	e9 02 ff ff ff       	jmp    f0103e46 <debuginfo_eip+0x10e>
f0103f44:	83 e8 01             	sub    $0x1,%eax
f0103f47:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f0103f4a:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0103f4e:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103f51:	39 c7                	cmp    %eax,%edi
f0103f53:	7f 45                	jg     f0103f9a <debuginfo_eip+0x262>
	       && stabs[lline].n_type != N_SOL
f0103f55:	0f b6 0a             	movzbl (%edx),%ecx
f0103f58:	80 f9 84             	cmp    $0x84,%cl
f0103f5b:	74 19                	je     f0103f76 <debuginfo_eip+0x23e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103f5d:	80 f9 64             	cmp    $0x64,%cl
f0103f60:	75 e2                	jne    f0103f44 <debuginfo_eip+0x20c>
f0103f62:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0103f66:	74 dc                	je     f0103f44 <debuginfo_eip+0x20c>
f0103f68:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103f6c:	74 11                	je     f0103f7f <debuginfo_eip+0x247>
f0103f6e:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103f71:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103f74:	eb 09                	jmp    f0103f7f <debuginfo_eip+0x247>
f0103f76:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103f7a:	74 03                	je     f0103f7f <debuginfo_eip+0x247>
f0103f7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103f7f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103f82:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103f85:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103f88:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0103f8b:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0103f8e:	29 f8                	sub    %edi,%eax
f0103f90:	39 c2                	cmp    %eax,%edx
f0103f92:	73 06                	jae    f0103f9a <debuginfo_eip+0x262>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103f94:	89 f8                	mov    %edi,%eax
f0103f96:	01 d0                	add    %edx,%eax
f0103f98:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103f9d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103fa0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0103fa5:	39 f0                	cmp    %esi,%eax
f0103fa7:	7d 59                	jge    f0104002 <debuginfo_eip+0x2ca>
		for (lline = lfun + 1;
f0103fa9:	8d 50 01             	lea    0x1(%eax),%edx
f0103fac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103faf:	89 d0                	mov    %edx,%eax
f0103fb1:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103fb4:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103fb7:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103fbb:	eb 04                	jmp    f0103fc1 <debuginfo_eip+0x289>
			info->eip_fn_narg++;
f0103fbd:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0103fc1:	39 c6                	cmp    %eax,%esi
f0103fc3:	7e 38                	jle    f0103ffd <debuginfo_eip+0x2c5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103fc5:	0f b6 0a             	movzbl (%edx),%ecx
f0103fc8:	83 c0 01             	add    $0x1,%eax
f0103fcb:	83 c2 0c             	add    $0xc,%edx
f0103fce:	80 f9 a0             	cmp    $0xa0,%cl
f0103fd1:	74 ea                	je     f0103fbd <debuginfo_eip+0x285>
	return 0;
f0103fd3:	ba 00 00 00 00       	mov    $0x0,%edx
f0103fd8:	eb 28                	jmp    f0104002 <debuginfo_eip+0x2ca>
			return -1;
f0103fda:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0103fdf:	eb 21                	jmp    f0104002 <debuginfo_eip+0x2ca>
		return -1;
f0103fe1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0103fe6:	eb 1a                	jmp    f0104002 <debuginfo_eip+0x2ca>
f0103fe8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0103fed:	eb 13                	jmp    f0104002 <debuginfo_eip+0x2ca>
		return -1;
f0103fef:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0103ff4:	eb 0c                	jmp    f0104002 <debuginfo_eip+0x2ca>
		return -1; //didn't find the line number stab
f0103ff6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0103ffb:	eb 05                	jmp    f0104002 <debuginfo_eip+0x2ca>
	return 0;
f0103ffd:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104002:	89 d0                	mov    %edx,%eax
f0104004:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104007:	5b                   	pop    %ebx
f0104008:	5e                   	pop    %esi
f0104009:	5f                   	pop    %edi
f010400a:	5d                   	pop    %ebp
f010400b:	c3                   	ret    

f010400c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010400c:	55                   	push   %ebp
f010400d:	89 e5                	mov    %esp,%ebp
f010400f:	57                   	push   %edi
f0104010:	56                   	push   %esi
f0104011:	53                   	push   %ebx
f0104012:	83 ec 1c             	sub    $0x1c,%esp
f0104015:	89 c7                	mov    %eax,%edi
f0104017:	89 d6                	mov    %edx,%esi
f0104019:	8b 45 08             	mov    0x8(%ebp),%eax
f010401c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010401f:	89 d1                	mov    %edx,%ecx
f0104021:	89 c2                	mov    %eax,%edx
f0104023:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104026:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104029:	8b 45 10             	mov    0x10(%ebp),%eax
f010402c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010402f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104032:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104039:	39 c2                	cmp    %eax,%edx
f010403b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f010403e:	72 3e                	jb     f010407e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104040:	83 ec 0c             	sub    $0xc,%esp
f0104043:	ff 75 18             	pushl  0x18(%ebp)
f0104046:	83 eb 01             	sub    $0x1,%ebx
f0104049:	53                   	push   %ebx
f010404a:	50                   	push   %eax
f010404b:	83 ec 08             	sub    $0x8,%esp
f010404e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104051:	ff 75 e0             	pushl  -0x20(%ebp)
f0104054:	ff 75 dc             	pushl  -0x24(%ebp)
f0104057:	ff 75 d8             	pushl  -0x28(%ebp)
f010405a:	e8 01 0a 00 00       	call   f0104a60 <__udivdi3>
f010405f:	83 c4 18             	add    $0x18,%esp
f0104062:	52                   	push   %edx
f0104063:	50                   	push   %eax
f0104064:	89 f2                	mov    %esi,%edx
f0104066:	89 f8                	mov    %edi,%eax
f0104068:	e8 9f ff ff ff       	call   f010400c <printnum>
f010406d:	83 c4 20             	add    $0x20,%esp
f0104070:	eb 13                	jmp    f0104085 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104072:	83 ec 08             	sub    $0x8,%esp
f0104075:	56                   	push   %esi
f0104076:	ff 75 18             	pushl  0x18(%ebp)
f0104079:	ff d7                	call   *%edi
f010407b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010407e:	83 eb 01             	sub    $0x1,%ebx
f0104081:	85 db                	test   %ebx,%ebx
f0104083:	7f ed                	jg     f0104072 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104085:	83 ec 08             	sub    $0x8,%esp
f0104088:	56                   	push   %esi
f0104089:	83 ec 04             	sub    $0x4,%esp
f010408c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010408f:	ff 75 e0             	pushl  -0x20(%ebp)
f0104092:	ff 75 dc             	pushl  -0x24(%ebp)
f0104095:	ff 75 d8             	pushl  -0x28(%ebp)
f0104098:	e8 d3 0a 00 00       	call   f0104b70 <__umoddi3>
f010409d:	83 c4 14             	add    $0x14,%esp
f01040a0:	0f be 80 5a 64 10 f0 	movsbl -0xfef9ba6(%eax),%eax
f01040a7:	50                   	push   %eax
f01040a8:	ff d7                	call   *%edi
}
f01040aa:	83 c4 10             	add    $0x10,%esp
f01040ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040b0:	5b                   	pop    %ebx
f01040b1:	5e                   	pop    %esi
f01040b2:	5f                   	pop    %edi
f01040b3:	5d                   	pop    %ebp
f01040b4:	c3                   	ret    

f01040b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01040b5:	f3 0f 1e fb          	endbr32 
f01040b9:	55                   	push   %ebp
f01040ba:	89 e5                	mov    %esp,%ebp
f01040bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01040bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01040c3:	8b 10                	mov    (%eax),%edx
f01040c5:	3b 50 04             	cmp    0x4(%eax),%edx
f01040c8:	73 0a                	jae    f01040d4 <sprintputch+0x1f>
		*b->buf++ = ch;
f01040ca:	8d 4a 01             	lea    0x1(%edx),%ecx
f01040cd:	89 08                	mov    %ecx,(%eax)
f01040cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01040d2:	88 02                	mov    %al,(%edx)
}
f01040d4:	5d                   	pop    %ebp
f01040d5:	c3                   	ret    

f01040d6 <printfmt>:
{
f01040d6:	f3 0f 1e fb          	endbr32 
f01040da:	55                   	push   %ebp
f01040db:	89 e5                	mov    %esp,%ebp
f01040dd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01040e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01040e3:	50                   	push   %eax
f01040e4:	ff 75 10             	pushl  0x10(%ebp)
f01040e7:	ff 75 0c             	pushl  0xc(%ebp)
f01040ea:	ff 75 08             	pushl  0x8(%ebp)
f01040ed:	e8 05 00 00 00       	call   f01040f7 <vprintfmt>
}
f01040f2:	83 c4 10             	add    $0x10,%esp
f01040f5:	c9                   	leave  
f01040f6:	c3                   	ret    

f01040f7 <vprintfmt>:
{
f01040f7:	f3 0f 1e fb          	endbr32 
f01040fb:	55                   	push   %ebp
f01040fc:	89 e5                	mov    %esp,%ebp
f01040fe:	57                   	push   %edi
f01040ff:	56                   	push   %esi
f0104100:	53                   	push   %ebx
f0104101:	83 ec 3c             	sub    $0x3c,%esp
f0104104:	8b 75 08             	mov    0x8(%ebp),%esi
f0104107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010410a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010410d:	e9 8e 03 00 00       	jmp    f01044a0 <vprintfmt+0x3a9>
		padc = ' ';
f0104112:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0104116:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f010411d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0104124:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010412b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104130:	8d 47 01             	lea    0x1(%edi),%eax
f0104133:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104136:	0f b6 17             	movzbl (%edi),%edx
f0104139:	8d 42 dd             	lea    -0x23(%edx),%eax
f010413c:	3c 55                	cmp    $0x55,%al
f010413e:	0f 87 df 03 00 00    	ja     f0104523 <vprintfmt+0x42c>
f0104144:	0f b6 c0             	movzbl %al,%eax
f0104147:	3e ff 24 85 e4 64 10 	notrack jmp *-0xfef9b1c(,%eax,4)
f010414e:	f0 
f010414f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104152:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0104156:	eb d8                	jmp    f0104130 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0104158:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010415b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f010415f:	eb cf                	jmp    f0104130 <vprintfmt+0x39>
f0104161:	0f b6 d2             	movzbl %dl,%edx
f0104164:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104167:	b8 00 00 00 00       	mov    $0x0,%eax
f010416c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f010416f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104172:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104176:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104179:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010417c:	83 f9 09             	cmp    $0x9,%ecx
f010417f:	77 55                	ja     f01041d6 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0104181:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104184:	eb e9                	jmp    f010416f <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0104186:	8b 45 14             	mov    0x14(%ebp),%eax
f0104189:	8b 00                	mov    (%eax),%eax
f010418b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010418e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104191:	8d 40 04             	lea    0x4(%eax),%eax
f0104194:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104197:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010419a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010419e:	79 90                	jns    f0104130 <vprintfmt+0x39>
				width = precision, precision = -1;
f01041a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01041a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01041a6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01041ad:	eb 81                	jmp    f0104130 <vprintfmt+0x39>
f01041af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041b2:	85 c0                	test   %eax,%eax
f01041b4:	ba 00 00 00 00       	mov    $0x0,%edx
f01041b9:	0f 49 d0             	cmovns %eax,%edx
f01041bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01041bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01041c2:	e9 69 ff ff ff       	jmp    f0104130 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f01041c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01041ca:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01041d1:	e9 5a ff ff ff       	jmp    f0104130 <vprintfmt+0x39>
f01041d6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01041d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041dc:	eb bc                	jmp    f010419a <vprintfmt+0xa3>
			lflag++;
f01041de:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01041e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01041e4:	e9 47 ff ff ff       	jmp    f0104130 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f01041e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01041ec:	8d 78 04             	lea    0x4(%eax),%edi
f01041ef:	83 ec 08             	sub    $0x8,%esp
f01041f2:	53                   	push   %ebx
f01041f3:	ff 30                	pushl  (%eax)
f01041f5:	ff d6                	call   *%esi
			break;
f01041f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01041fa:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01041fd:	e9 9b 02 00 00       	jmp    f010449d <vprintfmt+0x3a6>
			err = va_arg(ap, int);
f0104202:	8b 45 14             	mov    0x14(%ebp),%eax
f0104205:	8d 78 04             	lea    0x4(%eax),%edi
f0104208:	8b 00                	mov    (%eax),%eax
f010420a:	99                   	cltd   
f010420b:	31 d0                	xor    %edx,%eax
f010420d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010420f:	83 f8 06             	cmp    $0x6,%eax
f0104212:	7f 23                	jg     f0104237 <vprintfmt+0x140>
f0104214:	8b 14 85 3c 66 10 f0 	mov    -0xfef99c4(,%eax,4),%edx
f010421b:	85 d2                	test   %edx,%edx
f010421d:	74 18                	je     f0104237 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f010421f:	52                   	push   %edx
f0104220:	68 bf 5a 10 f0       	push   $0xf0105abf
f0104225:	53                   	push   %ebx
f0104226:	56                   	push   %esi
f0104227:	e8 aa fe ff ff       	call   f01040d6 <printfmt>
f010422c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010422f:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104232:	e9 66 02 00 00       	jmp    f010449d <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
f0104237:	50                   	push   %eax
f0104238:	68 72 64 10 f0       	push   $0xf0106472
f010423d:	53                   	push   %ebx
f010423e:	56                   	push   %esi
f010423f:	e8 92 fe ff ff       	call   f01040d6 <printfmt>
f0104244:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104247:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010424a:	e9 4e 02 00 00       	jmp    f010449d <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
f010424f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104252:	83 c0 04             	add    $0x4,%eax
f0104255:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104258:	8b 45 14             	mov    0x14(%ebp),%eax
f010425b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010425d:	85 d2                	test   %edx,%edx
f010425f:	b8 6b 64 10 f0       	mov    $0xf010646b,%eax
f0104264:	0f 45 c2             	cmovne %edx,%eax
f0104267:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010426a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010426e:	7e 06                	jle    f0104276 <vprintfmt+0x17f>
f0104270:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104274:	75 0d                	jne    f0104283 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104276:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104279:	89 c7                	mov    %eax,%edi
f010427b:	03 45 e0             	add    -0x20(%ebp),%eax
f010427e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104281:	eb 55                	jmp    f01042d8 <vprintfmt+0x1e1>
f0104283:	83 ec 08             	sub    $0x8,%esp
f0104286:	ff 75 d8             	pushl  -0x28(%ebp)
f0104289:	ff 75 cc             	pushl  -0x34(%ebp)
f010428c:	e8 2c 04 00 00       	call   f01046bd <strnlen>
f0104291:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104294:	29 c2                	sub    %eax,%edx
f0104296:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104299:	83 c4 10             	add    $0x10,%esp
f010429c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f010429e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01042a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01042a5:	85 ff                	test   %edi,%edi
f01042a7:	7e 11                	jle    f01042ba <vprintfmt+0x1c3>
					putch(padc, putdat);
f01042a9:	83 ec 08             	sub    $0x8,%esp
f01042ac:	53                   	push   %ebx
f01042ad:	ff 75 e0             	pushl  -0x20(%ebp)
f01042b0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01042b2:	83 ef 01             	sub    $0x1,%edi
f01042b5:	83 c4 10             	add    $0x10,%esp
f01042b8:	eb eb                	jmp    f01042a5 <vprintfmt+0x1ae>
f01042ba:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01042bd:	85 d2                	test   %edx,%edx
f01042bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01042c4:	0f 49 c2             	cmovns %edx,%eax
f01042c7:	29 c2                	sub    %eax,%edx
f01042c9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01042cc:	eb a8                	jmp    f0104276 <vprintfmt+0x17f>
					putch(ch, putdat);
f01042ce:	83 ec 08             	sub    $0x8,%esp
f01042d1:	53                   	push   %ebx
f01042d2:	52                   	push   %edx
f01042d3:	ff d6                	call   *%esi
f01042d5:	83 c4 10             	add    $0x10,%esp
f01042d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01042db:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01042dd:	83 c7 01             	add    $0x1,%edi
f01042e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01042e4:	0f be d0             	movsbl %al,%edx
f01042e7:	85 d2                	test   %edx,%edx
f01042e9:	74 4b                	je     f0104336 <vprintfmt+0x23f>
f01042eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01042ef:	78 06                	js     f01042f7 <vprintfmt+0x200>
f01042f1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01042f5:	78 1e                	js     f0104315 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f01042f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01042fb:	74 d1                	je     f01042ce <vprintfmt+0x1d7>
f01042fd:	0f be c0             	movsbl %al,%eax
f0104300:	83 e8 20             	sub    $0x20,%eax
f0104303:	83 f8 5e             	cmp    $0x5e,%eax
f0104306:	76 c6                	jbe    f01042ce <vprintfmt+0x1d7>
					putch('?', putdat);
f0104308:	83 ec 08             	sub    $0x8,%esp
f010430b:	53                   	push   %ebx
f010430c:	6a 3f                	push   $0x3f
f010430e:	ff d6                	call   *%esi
f0104310:	83 c4 10             	add    $0x10,%esp
f0104313:	eb c3                	jmp    f01042d8 <vprintfmt+0x1e1>
f0104315:	89 cf                	mov    %ecx,%edi
f0104317:	eb 0e                	jmp    f0104327 <vprintfmt+0x230>
				putch(' ', putdat);
f0104319:	83 ec 08             	sub    $0x8,%esp
f010431c:	53                   	push   %ebx
f010431d:	6a 20                	push   $0x20
f010431f:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104321:	83 ef 01             	sub    $0x1,%edi
f0104324:	83 c4 10             	add    $0x10,%esp
f0104327:	85 ff                	test   %edi,%edi
f0104329:	7f ee                	jg     f0104319 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f010432b:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010432e:	89 45 14             	mov    %eax,0x14(%ebp)
f0104331:	e9 67 01 00 00       	jmp    f010449d <vprintfmt+0x3a6>
f0104336:	89 cf                	mov    %ecx,%edi
f0104338:	eb ed                	jmp    f0104327 <vprintfmt+0x230>
	if (lflag >= 2)
f010433a:	83 f9 01             	cmp    $0x1,%ecx
f010433d:	7f 1b                	jg     f010435a <vprintfmt+0x263>
	else if (lflag)
f010433f:	85 c9                	test   %ecx,%ecx
f0104341:	74 63                	je     f01043a6 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f0104343:	8b 45 14             	mov    0x14(%ebp),%eax
f0104346:	8b 00                	mov    (%eax),%eax
f0104348:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010434b:	99                   	cltd   
f010434c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010434f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104352:	8d 40 04             	lea    0x4(%eax),%eax
f0104355:	89 45 14             	mov    %eax,0x14(%ebp)
f0104358:	eb 17                	jmp    f0104371 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f010435a:	8b 45 14             	mov    0x14(%ebp),%eax
f010435d:	8b 50 04             	mov    0x4(%eax),%edx
f0104360:	8b 00                	mov    (%eax),%eax
f0104362:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104365:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104368:	8b 45 14             	mov    0x14(%ebp),%eax
f010436b:	8d 40 08             	lea    0x8(%eax),%eax
f010436e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104371:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104374:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104377:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010437c:	85 c9                	test   %ecx,%ecx
f010437e:	0f 89 ff 00 00 00    	jns    f0104483 <vprintfmt+0x38c>
				putch('-', putdat);
f0104384:	83 ec 08             	sub    $0x8,%esp
f0104387:	53                   	push   %ebx
f0104388:	6a 2d                	push   $0x2d
f010438a:	ff d6                	call   *%esi
				num = -(long long) num;
f010438c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010438f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104392:	f7 da                	neg    %edx
f0104394:	83 d1 00             	adc    $0x0,%ecx
f0104397:	f7 d9                	neg    %ecx
f0104399:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010439c:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043a1:	e9 dd 00 00 00       	jmp    f0104483 <vprintfmt+0x38c>
		return va_arg(*ap, int);
f01043a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01043a9:	8b 00                	mov    (%eax),%eax
f01043ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01043ae:	99                   	cltd   
f01043af:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01043b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01043b5:	8d 40 04             	lea    0x4(%eax),%eax
f01043b8:	89 45 14             	mov    %eax,0x14(%ebp)
f01043bb:	eb b4                	jmp    f0104371 <vprintfmt+0x27a>
	if (lflag >= 2)
f01043bd:	83 f9 01             	cmp    $0x1,%ecx
f01043c0:	7f 1e                	jg     f01043e0 <vprintfmt+0x2e9>
	else if (lflag)
f01043c2:	85 c9                	test   %ecx,%ecx
f01043c4:	74 32                	je     f01043f8 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
f01043c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01043c9:	8b 10                	mov    (%eax),%edx
f01043cb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01043d0:	8d 40 04             	lea    0x4(%eax),%eax
f01043d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01043d6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01043db:	e9 a3 00 00 00       	jmp    f0104483 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01043e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01043e3:	8b 10                	mov    (%eax),%edx
f01043e5:	8b 48 04             	mov    0x4(%eax),%ecx
f01043e8:	8d 40 08             	lea    0x8(%eax),%eax
f01043eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01043ee:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01043f3:	e9 8b 00 00 00       	jmp    f0104483 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01043f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01043fb:	8b 10                	mov    (%eax),%edx
f01043fd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104402:	8d 40 04             	lea    0x4(%eax),%eax
f0104405:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104408:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f010440d:	eb 74                	jmp    f0104483 <vprintfmt+0x38c>
	if (lflag >= 2)
f010440f:	83 f9 01             	cmp    $0x1,%ecx
f0104412:	7f 1b                	jg     f010442f <vprintfmt+0x338>
	else if (lflag)
f0104414:	85 c9                	test   %ecx,%ecx
f0104416:	74 2c                	je     f0104444 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
f0104418:	8b 45 14             	mov    0x14(%ebp),%eax
f010441b:	8b 10                	mov    (%eax),%edx
f010441d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104422:	8d 40 04             	lea    0x4(%eax),%eax
f0104425:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0104428:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f010442d:	eb 54                	jmp    f0104483 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f010442f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104432:	8b 10                	mov    (%eax),%edx
f0104434:	8b 48 04             	mov    0x4(%eax),%ecx
f0104437:	8d 40 08             	lea    0x8(%eax),%eax
f010443a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f010443d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0104442:	eb 3f                	jmp    f0104483 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f0104444:	8b 45 14             	mov    0x14(%ebp),%eax
f0104447:	8b 10                	mov    (%eax),%edx
f0104449:	b9 00 00 00 00       	mov    $0x0,%ecx
f010444e:	8d 40 04             	lea    0x4(%eax),%eax
f0104451:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0104454:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f0104459:	eb 28                	jmp    f0104483 <vprintfmt+0x38c>
			putch('0', putdat);
f010445b:	83 ec 08             	sub    $0x8,%esp
f010445e:	53                   	push   %ebx
f010445f:	6a 30                	push   $0x30
f0104461:	ff d6                	call   *%esi
			putch('x', putdat);
f0104463:	83 c4 08             	add    $0x8,%esp
f0104466:	53                   	push   %ebx
f0104467:	6a 78                	push   $0x78
f0104469:	ff d6                	call   *%esi
			num = (unsigned long long)
f010446b:	8b 45 14             	mov    0x14(%ebp),%eax
f010446e:	8b 10                	mov    (%eax),%edx
f0104470:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104475:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104478:	8d 40 04             	lea    0x4(%eax),%eax
f010447b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010447e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104483:	83 ec 0c             	sub    $0xc,%esp
f0104486:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f010448a:	57                   	push   %edi
f010448b:	ff 75 e0             	pushl  -0x20(%ebp)
f010448e:	50                   	push   %eax
f010448f:	51                   	push   %ecx
f0104490:	52                   	push   %edx
f0104491:	89 da                	mov    %ebx,%edx
f0104493:	89 f0                	mov    %esi,%eax
f0104495:	e8 72 fb ff ff       	call   f010400c <printnum>
			break;
f010449a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010449d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01044a0:	83 c7 01             	add    $0x1,%edi
f01044a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01044a7:	83 f8 25             	cmp    $0x25,%eax
f01044aa:	0f 84 62 fc ff ff    	je     f0104112 <vprintfmt+0x1b>
			if (ch == '\0')
f01044b0:	85 c0                	test   %eax,%eax
f01044b2:	0f 84 8b 00 00 00    	je     f0104543 <vprintfmt+0x44c>
			putch(ch, putdat);
f01044b8:	83 ec 08             	sub    $0x8,%esp
f01044bb:	53                   	push   %ebx
f01044bc:	50                   	push   %eax
f01044bd:	ff d6                	call   *%esi
f01044bf:	83 c4 10             	add    $0x10,%esp
f01044c2:	eb dc                	jmp    f01044a0 <vprintfmt+0x3a9>
	if (lflag >= 2)
f01044c4:	83 f9 01             	cmp    $0x1,%ecx
f01044c7:	7f 1b                	jg     f01044e4 <vprintfmt+0x3ed>
	else if (lflag)
f01044c9:	85 c9                	test   %ecx,%ecx
f01044cb:	74 2c                	je     f01044f9 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
f01044cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01044d0:	8b 10                	mov    (%eax),%edx
f01044d2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01044d7:	8d 40 04             	lea    0x4(%eax),%eax
f01044da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01044dd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f01044e2:	eb 9f                	jmp    f0104483 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01044e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01044e7:	8b 10                	mov    (%eax),%edx
f01044e9:	8b 48 04             	mov    0x4(%eax),%ecx
f01044ec:	8d 40 08             	lea    0x8(%eax),%eax
f01044ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01044f2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f01044f7:	eb 8a                	jmp    f0104483 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01044f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01044fc:	8b 10                	mov    (%eax),%edx
f01044fe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104503:	8d 40 04             	lea    0x4(%eax),%eax
f0104506:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104509:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f010450e:	e9 70 ff ff ff       	jmp    f0104483 <vprintfmt+0x38c>
			putch(ch, putdat);
f0104513:	83 ec 08             	sub    $0x8,%esp
f0104516:	53                   	push   %ebx
f0104517:	6a 25                	push   $0x25
f0104519:	ff d6                	call   *%esi
			break;
f010451b:	83 c4 10             	add    $0x10,%esp
f010451e:	e9 7a ff ff ff       	jmp    f010449d <vprintfmt+0x3a6>
			putch('%', putdat);
f0104523:	83 ec 08             	sub    $0x8,%esp
f0104526:	53                   	push   %ebx
f0104527:	6a 25                	push   $0x25
f0104529:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010452b:	83 c4 10             	add    $0x10,%esp
f010452e:	89 f8                	mov    %edi,%eax
f0104530:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104534:	74 05                	je     f010453b <vprintfmt+0x444>
f0104536:	83 e8 01             	sub    $0x1,%eax
f0104539:	eb f5                	jmp    f0104530 <vprintfmt+0x439>
f010453b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010453e:	e9 5a ff ff ff       	jmp    f010449d <vprintfmt+0x3a6>
}
f0104543:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104546:	5b                   	pop    %ebx
f0104547:	5e                   	pop    %esi
f0104548:	5f                   	pop    %edi
f0104549:	5d                   	pop    %ebp
f010454a:	c3                   	ret    

f010454b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010454b:	f3 0f 1e fb          	endbr32 
f010454f:	55                   	push   %ebp
f0104550:	89 e5                	mov    %esp,%ebp
f0104552:	83 ec 18             	sub    $0x18,%esp
f0104555:	8b 45 08             	mov    0x8(%ebp),%eax
f0104558:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010455b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010455e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104562:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104565:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010456c:	85 c0                	test   %eax,%eax
f010456e:	74 26                	je     f0104596 <vsnprintf+0x4b>
f0104570:	85 d2                	test   %edx,%edx
f0104572:	7e 22                	jle    f0104596 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104574:	ff 75 14             	pushl  0x14(%ebp)
f0104577:	ff 75 10             	pushl  0x10(%ebp)
f010457a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010457d:	50                   	push   %eax
f010457e:	68 b5 40 10 f0       	push   $0xf01040b5
f0104583:	e8 6f fb ff ff       	call   f01040f7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104588:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010458b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104591:	83 c4 10             	add    $0x10,%esp
}
f0104594:	c9                   	leave  
f0104595:	c3                   	ret    
		return -E_INVAL;
f0104596:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010459b:	eb f7                	jmp    f0104594 <vsnprintf+0x49>

f010459d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010459d:	f3 0f 1e fb          	endbr32 
f01045a1:	55                   	push   %ebp
f01045a2:	89 e5                	mov    %esp,%ebp
f01045a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01045a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01045aa:	50                   	push   %eax
f01045ab:	ff 75 10             	pushl  0x10(%ebp)
f01045ae:	ff 75 0c             	pushl  0xc(%ebp)
f01045b1:	ff 75 08             	pushl  0x8(%ebp)
f01045b4:	e8 92 ff ff ff       	call   f010454b <vsnprintf>
	va_end(ap);

	return rc;
}
f01045b9:	c9                   	leave  
f01045ba:	c3                   	ret    

f01045bb <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01045bb:	f3 0f 1e fb          	endbr32 
f01045bf:	55                   	push   %ebp
f01045c0:	89 e5                	mov    %esp,%ebp
f01045c2:	57                   	push   %edi
f01045c3:	56                   	push   %esi
f01045c4:	53                   	push   %ebx
f01045c5:	83 ec 0c             	sub    $0xc,%esp
f01045c8:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01045cb:	85 c0                	test   %eax,%eax
f01045cd:	74 11                	je     f01045e0 <readline+0x25>
		cprintf("%s", prompt);
f01045cf:	83 ec 08             	sub    $0x8,%esp
f01045d2:	50                   	push   %eax
f01045d3:	68 bf 5a 10 f0       	push   $0xf0105abf
f01045d8:	e8 59 ed ff ff       	call   f0103336 <cprintf>
f01045dd:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01045e0:	83 ec 0c             	sub    $0xc,%esp
f01045e3:	6a 00                	push   $0x0
f01045e5:	e8 74 c0 ff ff       	call   f010065e <iscons>
f01045ea:	89 c7                	mov    %eax,%edi
f01045ec:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01045ef:	be 00 00 00 00       	mov    $0x0,%esi
f01045f4:	eb 4b                	jmp    f0104641 <readline+0x86>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01045f6:	83 ec 08             	sub    $0x8,%esp
f01045f9:	50                   	push   %eax
f01045fa:	68 58 66 10 f0       	push   $0xf0106658
f01045ff:	e8 32 ed ff ff       	call   f0103336 <cprintf>
			return NULL;
f0104604:	83 c4 10             	add    $0x10,%esp
f0104607:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010460c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010460f:	5b                   	pop    %ebx
f0104610:	5e                   	pop    %esi
f0104611:	5f                   	pop    %edi
f0104612:	5d                   	pop    %ebp
f0104613:	c3                   	ret    
			if (echoing)
f0104614:	85 ff                	test   %edi,%edi
f0104616:	75 05                	jne    f010461d <readline+0x62>
			i--;
f0104618:	83 ee 01             	sub    $0x1,%esi
f010461b:	eb 24                	jmp    f0104641 <readline+0x86>
				cputchar('\b');
f010461d:	83 ec 0c             	sub    $0xc,%esp
f0104620:	6a 08                	push   $0x8
f0104622:	e8 0e c0 ff ff       	call   f0100635 <cputchar>
f0104627:	83 c4 10             	add    $0x10,%esp
f010462a:	eb ec                	jmp    f0104618 <readline+0x5d>
				cputchar(c);
f010462c:	83 ec 0c             	sub    $0xc,%esp
f010462f:	53                   	push   %ebx
f0104630:	e8 00 c0 ff ff       	call   f0100635 <cputchar>
f0104635:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104638:	88 9e 00 c7 18 f0    	mov    %bl,-0xfe73900(%esi)
f010463e:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0104641:	e8 03 c0 ff ff       	call   f0100649 <getchar>
f0104646:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104648:	85 c0                	test   %eax,%eax
f010464a:	78 aa                	js     f01045f6 <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010464c:	83 f8 08             	cmp    $0x8,%eax
f010464f:	0f 94 c2             	sete   %dl
f0104652:	83 f8 7f             	cmp    $0x7f,%eax
f0104655:	0f 94 c0             	sete   %al
f0104658:	08 c2                	or     %al,%dl
f010465a:	74 04                	je     f0104660 <readline+0xa5>
f010465c:	85 f6                	test   %esi,%esi
f010465e:	7f b4                	jg     f0104614 <readline+0x59>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104660:	83 fb 1f             	cmp    $0x1f,%ebx
f0104663:	7e 0e                	jle    f0104673 <readline+0xb8>
f0104665:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010466b:	7f 06                	jg     f0104673 <readline+0xb8>
			if (echoing)
f010466d:	85 ff                	test   %edi,%edi
f010466f:	74 c7                	je     f0104638 <readline+0x7d>
f0104671:	eb b9                	jmp    f010462c <readline+0x71>
		} else if (c == '\n' || c == '\r') {
f0104673:	83 fb 0a             	cmp    $0xa,%ebx
f0104676:	74 05                	je     f010467d <readline+0xc2>
f0104678:	83 fb 0d             	cmp    $0xd,%ebx
f010467b:	75 c4                	jne    f0104641 <readline+0x86>
			if (echoing)
f010467d:	85 ff                	test   %edi,%edi
f010467f:	75 11                	jne    f0104692 <readline+0xd7>
			buf[i] = 0;
f0104681:	c6 86 00 c7 18 f0 00 	movb   $0x0,-0xfe73900(%esi)
			return buf;
f0104688:	b8 00 c7 18 f0       	mov    $0xf018c700,%eax
f010468d:	e9 7a ff ff ff       	jmp    f010460c <readline+0x51>
				cputchar('\n');
f0104692:	83 ec 0c             	sub    $0xc,%esp
f0104695:	6a 0a                	push   $0xa
f0104697:	e8 99 bf ff ff       	call   f0100635 <cputchar>
f010469c:	83 c4 10             	add    $0x10,%esp
f010469f:	eb e0                	jmp    f0104681 <readline+0xc6>

f01046a1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01046a1:	f3 0f 1e fb          	endbr32 
f01046a5:	55                   	push   %ebp
f01046a6:	89 e5                	mov    %esp,%ebp
f01046a8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01046ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01046b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01046b4:	74 05                	je     f01046bb <strlen+0x1a>
		n++;
f01046b6:	83 c0 01             	add    $0x1,%eax
f01046b9:	eb f5                	jmp    f01046b0 <strlen+0xf>
	return n;
}
f01046bb:	5d                   	pop    %ebp
f01046bc:	c3                   	ret    

f01046bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01046bd:	f3 0f 1e fb          	endbr32 
f01046c1:	55                   	push   %ebp
f01046c2:	89 e5                	mov    %esp,%ebp
f01046c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01046c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01046ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01046cf:	39 d0                	cmp    %edx,%eax
f01046d1:	74 0d                	je     f01046e0 <strnlen+0x23>
f01046d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01046d7:	74 05                	je     f01046de <strnlen+0x21>
		n++;
f01046d9:	83 c0 01             	add    $0x1,%eax
f01046dc:	eb f1                	jmp    f01046cf <strnlen+0x12>
f01046de:	89 c2                	mov    %eax,%edx
	return n;
}
f01046e0:	89 d0                	mov    %edx,%eax
f01046e2:	5d                   	pop    %ebp
f01046e3:	c3                   	ret    

f01046e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01046e4:	f3 0f 1e fb          	endbr32 
f01046e8:	55                   	push   %ebp
f01046e9:	89 e5                	mov    %esp,%ebp
f01046eb:	53                   	push   %ebx
f01046ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01046ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01046f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01046f7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01046fb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01046fe:	83 c0 01             	add    $0x1,%eax
f0104701:	84 d2                	test   %dl,%dl
f0104703:	75 f2                	jne    f01046f7 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0104705:	89 c8                	mov    %ecx,%eax
f0104707:	5b                   	pop    %ebx
f0104708:	5d                   	pop    %ebp
f0104709:	c3                   	ret    

f010470a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010470a:	f3 0f 1e fb          	endbr32 
f010470e:	55                   	push   %ebp
f010470f:	89 e5                	mov    %esp,%ebp
f0104711:	53                   	push   %ebx
f0104712:	83 ec 10             	sub    $0x10,%esp
f0104715:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104718:	53                   	push   %ebx
f0104719:	e8 83 ff ff ff       	call   f01046a1 <strlen>
f010471e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104721:	ff 75 0c             	pushl  0xc(%ebp)
f0104724:	01 d8                	add    %ebx,%eax
f0104726:	50                   	push   %eax
f0104727:	e8 b8 ff ff ff       	call   f01046e4 <strcpy>
	return dst;
}
f010472c:	89 d8                	mov    %ebx,%eax
f010472e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104731:	c9                   	leave  
f0104732:	c3                   	ret    

f0104733 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104733:	f3 0f 1e fb          	endbr32 
f0104737:	55                   	push   %ebp
f0104738:	89 e5                	mov    %esp,%ebp
f010473a:	56                   	push   %esi
f010473b:	53                   	push   %ebx
f010473c:	8b 75 08             	mov    0x8(%ebp),%esi
f010473f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104742:	89 f3                	mov    %esi,%ebx
f0104744:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104747:	89 f0                	mov    %esi,%eax
f0104749:	39 d8                	cmp    %ebx,%eax
f010474b:	74 11                	je     f010475e <strncpy+0x2b>
		*dst++ = *src;
f010474d:	83 c0 01             	add    $0x1,%eax
f0104750:	0f b6 0a             	movzbl (%edx),%ecx
f0104753:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104756:	80 f9 01             	cmp    $0x1,%cl
f0104759:	83 da ff             	sbb    $0xffffffff,%edx
f010475c:	eb eb                	jmp    f0104749 <strncpy+0x16>
	}
	return ret;
}
f010475e:	89 f0                	mov    %esi,%eax
f0104760:	5b                   	pop    %ebx
f0104761:	5e                   	pop    %esi
f0104762:	5d                   	pop    %ebp
f0104763:	c3                   	ret    

f0104764 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104764:	f3 0f 1e fb          	endbr32 
f0104768:	55                   	push   %ebp
f0104769:	89 e5                	mov    %esp,%ebp
f010476b:	56                   	push   %esi
f010476c:	53                   	push   %ebx
f010476d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104770:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104773:	8b 55 10             	mov    0x10(%ebp),%edx
f0104776:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104778:	85 d2                	test   %edx,%edx
f010477a:	74 21                	je     f010479d <strlcpy+0x39>
f010477c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104780:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0104782:	39 c2                	cmp    %eax,%edx
f0104784:	74 14                	je     f010479a <strlcpy+0x36>
f0104786:	0f b6 19             	movzbl (%ecx),%ebx
f0104789:	84 db                	test   %bl,%bl
f010478b:	74 0b                	je     f0104798 <strlcpy+0x34>
			*dst++ = *src++;
f010478d:	83 c1 01             	add    $0x1,%ecx
f0104790:	83 c2 01             	add    $0x1,%edx
f0104793:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104796:	eb ea                	jmp    f0104782 <strlcpy+0x1e>
f0104798:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010479a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010479d:	29 f0                	sub    %esi,%eax
}
f010479f:	5b                   	pop    %ebx
f01047a0:	5e                   	pop    %esi
f01047a1:	5d                   	pop    %ebp
f01047a2:	c3                   	ret    

f01047a3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01047a3:	f3 0f 1e fb          	endbr32 
f01047a7:	55                   	push   %ebp
f01047a8:	89 e5                	mov    %esp,%ebp
f01047aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01047ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01047b0:	0f b6 01             	movzbl (%ecx),%eax
f01047b3:	84 c0                	test   %al,%al
f01047b5:	74 0c                	je     f01047c3 <strcmp+0x20>
f01047b7:	3a 02                	cmp    (%edx),%al
f01047b9:	75 08                	jne    f01047c3 <strcmp+0x20>
		p++, q++;
f01047bb:	83 c1 01             	add    $0x1,%ecx
f01047be:	83 c2 01             	add    $0x1,%edx
f01047c1:	eb ed                	jmp    f01047b0 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01047c3:	0f b6 c0             	movzbl %al,%eax
f01047c6:	0f b6 12             	movzbl (%edx),%edx
f01047c9:	29 d0                	sub    %edx,%eax
}
f01047cb:	5d                   	pop    %ebp
f01047cc:	c3                   	ret    

f01047cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01047cd:	f3 0f 1e fb          	endbr32 
f01047d1:	55                   	push   %ebp
f01047d2:	89 e5                	mov    %esp,%ebp
f01047d4:	53                   	push   %ebx
f01047d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01047d8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01047db:	89 c3                	mov    %eax,%ebx
f01047dd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01047e0:	eb 06                	jmp    f01047e8 <strncmp+0x1b>
		n--, p++, q++;
f01047e2:	83 c0 01             	add    $0x1,%eax
f01047e5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01047e8:	39 d8                	cmp    %ebx,%eax
f01047ea:	74 16                	je     f0104802 <strncmp+0x35>
f01047ec:	0f b6 08             	movzbl (%eax),%ecx
f01047ef:	84 c9                	test   %cl,%cl
f01047f1:	74 04                	je     f01047f7 <strncmp+0x2a>
f01047f3:	3a 0a                	cmp    (%edx),%cl
f01047f5:	74 eb                	je     f01047e2 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01047f7:	0f b6 00             	movzbl (%eax),%eax
f01047fa:	0f b6 12             	movzbl (%edx),%edx
f01047fd:	29 d0                	sub    %edx,%eax
}
f01047ff:	5b                   	pop    %ebx
f0104800:	5d                   	pop    %ebp
f0104801:	c3                   	ret    
		return 0;
f0104802:	b8 00 00 00 00       	mov    $0x0,%eax
f0104807:	eb f6                	jmp    f01047ff <strncmp+0x32>

f0104809 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104809:	f3 0f 1e fb          	endbr32 
f010480d:	55                   	push   %ebp
f010480e:	89 e5                	mov    %esp,%ebp
f0104810:	8b 45 08             	mov    0x8(%ebp),%eax
f0104813:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104817:	0f b6 10             	movzbl (%eax),%edx
f010481a:	84 d2                	test   %dl,%dl
f010481c:	74 09                	je     f0104827 <strchr+0x1e>
		if (*s == c)
f010481e:	38 ca                	cmp    %cl,%dl
f0104820:	74 0a                	je     f010482c <strchr+0x23>
	for (; *s; s++)
f0104822:	83 c0 01             	add    $0x1,%eax
f0104825:	eb f0                	jmp    f0104817 <strchr+0xe>
			return (char *) s;
	return 0;
f0104827:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010482c:	5d                   	pop    %ebp
f010482d:	c3                   	ret    

f010482e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010482e:	f3 0f 1e fb          	endbr32 
f0104832:	55                   	push   %ebp
f0104833:	89 e5                	mov    %esp,%ebp
f0104835:	8b 45 08             	mov    0x8(%ebp),%eax
f0104838:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010483c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010483f:	38 ca                	cmp    %cl,%dl
f0104841:	74 09                	je     f010484c <strfind+0x1e>
f0104843:	84 d2                	test   %dl,%dl
f0104845:	74 05                	je     f010484c <strfind+0x1e>
	for (; *s; s++)
f0104847:	83 c0 01             	add    $0x1,%eax
f010484a:	eb f0                	jmp    f010483c <strfind+0xe>
			break;
	return (char *) s;
}
f010484c:	5d                   	pop    %ebp
f010484d:	c3                   	ret    

f010484e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010484e:	f3 0f 1e fb          	endbr32 
f0104852:	55                   	push   %ebp
f0104853:	89 e5                	mov    %esp,%ebp
f0104855:	57                   	push   %edi
f0104856:	56                   	push   %esi
f0104857:	53                   	push   %ebx
f0104858:	8b 7d 08             	mov    0x8(%ebp),%edi
f010485b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010485e:	85 c9                	test   %ecx,%ecx
f0104860:	74 31                	je     f0104893 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104862:	89 f8                	mov    %edi,%eax
f0104864:	09 c8                	or     %ecx,%eax
f0104866:	a8 03                	test   $0x3,%al
f0104868:	75 23                	jne    f010488d <memset+0x3f>
		c &= 0xFF;
f010486a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010486e:	89 d3                	mov    %edx,%ebx
f0104870:	c1 e3 08             	shl    $0x8,%ebx
f0104873:	89 d0                	mov    %edx,%eax
f0104875:	c1 e0 18             	shl    $0x18,%eax
f0104878:	89 d6                	mov    %edx,%esi
f010487a:	c1 e6 10             	shl    $0x10,%esi
f010487d:	09 f0                	or     %esi,%eax
f010487f:	09 c2                	or     %eax,%edx
f0104881:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104883:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104886:	89 d0                	mov    %edx,%eax
f0104888:	fc                   	cld    
f0104889:	f3 ab                	rep stos %eax,%es:(%edi)
f010488b:	eb 06                	jmp    f0104893 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010488d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104890:	fc                   	cld    
f0104891:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104893:	89 f8                	mov    %edi,%eax
f0104895:	5b                   	pop    %ebx
f0104896:	5e                   	pop    %esi
f0104897:	5f                   	pop    %edi
f0104898:	5d                   	pop    %ebp
f0104899:	c3                   	ret    

f010489a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010489a:	f3 0f 1e fb          	endbr32 
f010489e:	55                   	push   %ebp
f010489f:	89 e5                	mov    %esp,%ebp
f01048a1:	57                   	push   %edi
f01048a2:	56                   	push   %esi
f01048a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01048a6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01048a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01048ac:	39 c6                	cmp    %eax,%esi
f01048ae:	73 32                	jae    f01048e2 <memmove+0x48>
f01048b0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01048b3:	39 c2                	cmp    %eax,%edx
f01048b5:	76 2b                	jbe    f01048e2 <memmove+0x48>
		s += n;
		d += n;
f01048b7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01048ba:	89 fe                	mov    %edi,%esi
f01048bc:	09 ce                	or     %ecx,%esi
f01048be:	09 d6                	or     %edx,%esi
f01048c0:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01048c6:	75 0e                	jne    f01048d6 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01048c8:	83 ef 04             	sub    $0x4,%edi
f01048cb:	8d 72 fc             	lea    -0x4(%edx),%esi
f01048ce:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01048d1:	fd                   	std    
f01048d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01048d4:	eb 09                	jmp    f01048df <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01048d6:	83 ef 01             	sub    $0x1,%edi
f01048d9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01048dc:	fd                   	std    
f01048dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01048df:	fc                   	cld    
f01048e0:	eb 1a                	jmp    f01048fc <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01048e2:	89 c2                	mov    %eax,%edx
f01048e4:	09 ca                	or     %ecx,%edx
f01048e6:	09 f2                	or     %esi,%edx
f01048e8:	f6 c2 03             	test   $0x3,%dl
f01048eb:	75 0a                	jne    f01048f7 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01048ed:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01048f0:	89 c7                	mov    %eax,%edi
f01048f2:	fc                   	cld    
f01048f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01048f5:	eb 05                	jmp    f01048fc <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f01048f7:	89 c7                	mov    %eax,%edi
f01048f9:	fc                   	cld    
f01048fa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01048fc:	5e                   	pop    %esi
f01048fd:	5f                   	pop    %edi
f01048fe:	5d                   	pop    %ebp
f01048ff:	c3                   	ret    

f0104900 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104900:	f3 0f 1e fb          	endbr32 
f0104904:	55                   	push   %ebp
f0104905:	89 e5                	mov    %esp,%ebp
f0104907:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010490a:	ff 75 10             	pushl  0x10(%ebp)
f010490d:	ff 75 0c             	pushl  0xc(%ebp)
f0104910:	ff 75 08             	pushl  0x8(%ebp)
f0104913:	e8 82 ff ff ff       	call   f010489a <memmove>
}
f0104918:	c9                   	leave  
f0104919:	c3                   	ret    

f010491a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010491a:	f3 0f 1e fb          	endbr32 
f010491e:	55                   	push   %ebp
f010491f:	89 e5                	mov    %esp,%ebp
f0104921:	56                   	push   %esi
f0104922:	53                   	push   %ebx
f0104923:	8b 45 08             	mov    0x8(%ebp),%eax
f0104926:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104929:	89 c6                	mov    %eax,%esi
f010492b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010492e:	39 f0                	cmp    %esi,%eax
f0104930:	74 1c                	je     f010494e <memcmp+0x34>
		if (*s1 != *s2)
f0104932:	0f b6 08             	movzbl (%eax),%ecx
f0104935:	0f b6 1a             	movzbl (%edx),%ebx
f0104938:	38 d9                	cmp    %bl,%cl
f010493a:	75 08                	jne    f0104944 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010493c:	83 c0 01             	add    $0x1,%eax
f010493f:	83 c2 01             	add    $0x1,%edx
f0104942:	eb ea                	jmp    f010492e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0104944:	0f b6 c1             	movzbl %cl,%eax
f0104947:	0f b6 db             	movzbl %bl,%ebx
f010494a:	29 d8                	sub    %ebx,%eax
f010494c:	eb 05                	jmp    f0104953 <memcmp+0x39>
	}

	return 0;
f010494e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104953:	5b                   	pop    %ebx
f0104954:	5e                   	pop    %esi
f0104955:	5d                   	pop    %ebp
f0104956:	c3                   	ret    

f0104957 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104957:	f3 0f 1e fb          	endbr32 
f010495b:	55                   	push   %ebp
f010495c:	89 e5                	mov    %esp,%ebp
f010495e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104964:	89 c2                	mov    %eax,%edx
f0104966:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104969:	39 d0                	cmp    %edx,%eax
f010496b:	73 09                	jae    f0104976 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f010496d:	38 08                	cmp    %cl,(%eax)
f010496f:	74 05                	je     f0104976 <memfind+0x1f>
	for (; s < ends; s++)
f0104971:	83 c0 01             	add    $0x1,%eax
f0104974:	eb f3                	jmp    f0104969 <memfind+0x12>
			break;
	return (void *) s;
}
f0104976:	5d                   	pop    %ebp
f0104977:	c3                   	ret    

f0104978 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104978:	f3 0f 1e fb          	endbr32 
f010497c:	55                   	push   %ebp
f010497d:	89 e5                	mov    %esp,%ebp
f010497f:	57                   	push   %edi
f0104980:	56                   	push   %esi
f0104981:	53                   	push   %ebx
f0104982:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104985:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104988:	eb 03                	jmp    f010498d <strtol+0x15>
		s++;
f010498a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010498d:	0f b6 01             	movzbl (%ecx),%eax
f0104990:	3c 20                	cmp    $0x20,%al
f0104992:	74 f6                	je     f010498a <strtol+0x12>
f0104994:	3c 09                	cmp    $0x9,%al
f0104996:	74 f2                	je     f010498a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0104998:	3c 2b                	cmp    $0x2b,%al
f010499a:	74 2a                	je     f01049c6 <strtol+0x4e>
	int neg = 0;
f010499c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01049a1:	3c 2d                	cmp    $0x2d,%al
f01049a3:	74 2b                	je     f01049d0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01049a5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01049ab:	75 0f                	jne    f01049bc <strtol+0x44>
f01049ad:	80 39 30             	cmpb   $0x30,(%ecx)
f01049b0:	74 28                	je     f01049da <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01049b2:	85 db                	test   %ebx,%ebx
f01049b4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01049b9:	0f 44 d8             	cmove  %eax,%ebx
f01049bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01049c1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01049c4:	eb 46                	jmp    f0104a0c <strtol+0x94>
		s++;
f01049c6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01049c9:	bf 00 00 00 00       	mov    $0x0,%edi
f01049ce:	eb d5                	jmp    f01049a5 <strtol+0x2d>
		s++, neg = 1;
f01049d0:	83 c1 01             	add    $0x1,%ecx
f01049d3:	bf 01 00 00 00       	mov    $0x1,%edi
f01049d8:	eb cb                	jmp    f01049a5 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01049da:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01049de:	74 0e                	je     f01049ee <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01049e0:	85 db                	test   %ebx,%ebx
f01049e2:	75 d8                	jne    f01049bc <strtol+0x44>
		s++, base = 8;
f01049e4:	83 c1 01             	add    $0x1,%ecx
f01049e7:	bb 08 00 00 00       	mov    $0x8,%ebx
f01049ec:	eb ce                	jmp    f01049bc <strtol+0x44>
		s += 2, base = 16;
f01049ee:	83 c1 02             	add    $0x2,%ecx
f01049f1:	bb 10 00 00 00       	mov    $0x10,%ebx
f01049f6:	eb c4                	jmp    f01049bc <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01049f8:	0f be d2             	movsbl %dl,%edx
f01049fb:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01049fe:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104a01:	7d 3a                	jge    f0104a3d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0104a03:	83 c1 01             	add    $0x1,%ecx
f0104a06:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104a0a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104a0c:	0f b6 11             	movzbl (%ecx),%edx
f0104a0f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104a12:	89 f3                	mov    %esi,%ebx
f0104a14:	80 fb 09             	cmp    $0x9,%bl
f0104a17:	76 df                	jbe    f01049f8 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0104a19:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104a1c:	89 f3                	mov    %esi,%ebx
f0104a1e:	80 fb 19             	cmp    $0x19,%bl
f0104a21:	77 08                	ja     f0104a2b <strtol+0xb3>
			dig = *s - 'a' + 10;
f0104a23:	0f be d2             	movsbl %dl,%edx
f0104a26:	83 ea 57             	sub    $0x57,%edx
f0104a29:	eb d3                	jmp    f01049fe <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0104a2b:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104a2e:	89 f3                	mov    %esi,%ebx
f0104a30:	80 fb 19             	cmp    $0x19,%bl
f0104a33:	77 08                	ja     f0104a3d <strtol+0xc5>
			dig = *s - 'A' + 10;
f0104a35:	0f be d2             	movsbl %dl,%edx
f0104a38:	83 ea 37             	sub    $0x37,%edx
f0104a3b:	eb c1                	jmp    f01049fe <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104a3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104a41:	74 05                	je     f0104a48 <strtol+0xd0>
		*endptr = (char *) s;
f0104a43:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104a46:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104a48:	89 c2                	mov    %eax,%edx
f0104a4a:	f7 da                	neg    %edx
f0104a4c:	85 ff                	test   %edi,%edi
f0104a4e:	0f 45 c2             	cmovne %edx,%eax
}
f0104a51:	5b                   	pop    %ebx
f0104a52:	5e                   	pop    %esi
f0104a53:	5f                   	pop    %edi
f0104a54:	5d                   	pop    %ebp
f0104a55:	c3                   	ret    
f0104a56:	66 90                	xchg   %ax,%ax
f0104a58:	66 90                	xchg   %ax,%ax
f0104a5a:	66 90                	xchg   %ax,%ax
f0104a5c:	66 90                	xchg   %ax,%ax
f0104a5e:	66 90                	xchg   %ax,%ax

f0104a60 <__udivdi3>:
f0104a60:	f3 0f 1e fb          	endbr32 
f0104a64:	55                   	push   %ebp
f0104a65:	57                   	push   %edi
f0104a66:	56                   	push   %esi
f0104a67:	53                   	push   %ebx
f0104a68:	83 ec 1c             	sub    $0x1c,%esp
f0104a6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0104a6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0104a73:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104a77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0104a7b:	85 d2                	test   %edx,%edx
f0104a7d:	75 19                	jne    f0104a98 <__udivdi3+0x38>
f0104a7f:	39 f3                	cmp    %esi,%ebx
f0104a81:	76 4d                	jbe    f0104ad0 <__udivdi3+0x70>
f0104a83:	31 ff                	xor    %edi,%edi
f0104a85:	89 e8                	mov    %ebp,%eax
f0104a87:	89 f2                	mov    %esi,%edx
f0104a89:	f7 f3                	div    %ebx
f0104a8b:	89 fa                	mov    %edi,%edx
f0104a8d:	83 c4 1c             	add    $0x1c,%esp
f0104a90:	5b                   	pop    %ebx
f0104a91:	5e                   	pop    %esi
f0104a92:	5f                   	pop    %edi
f0104a93:	5d                   	pop    %ebp
f0104a94:	c3                   	ret    
f0104a95:	8d 76 00             	lea    0x0(%esi),%esi
f0104a98:	39 f2                	cmp    %esi,%edx
f0104a9a:	76 14                	jbe    f0104ab0 <__udivdi3+0x50>
f0104a9c:	31 ff                	xor    %edi,%edi
f0104a9e:	31 c0                	xor    %eax,%eax
f0104aa0:	89 fa                	mov    %edi,%edx
f0104aa2:	83 c4 1c             	add    $0x1c,%esp
f0104aa5:	5b                   	pop    %ebx
f0104aa6:	5e                   	pop    %esi
f0104aa7:	5f                   	pop    %edi
f0104aa8:	5d                   	pop    %ebp
f0104aa9:	c3                   	ret    
f0104aaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104ab0:	0f bd fa             	bsr    %edx,%edi
f0104ab3:	83 f7 1f             	xor    $0x1f,%edi
f0104ab6:	75 48                	jne    f0104b00 <__udivdi3+0xa0>
f0104ab8:	39 f2                	cmp    %esi,%edx
f0104aba:	72 06                	jb     f0104ac2 <__udivdi3+0x62>
f0104abc:	31 c0                	xor    %eax,%eax
f0104abe:	39 eb                	cmp    %ebp,%ebx
f0104ac0:	77 de                	ja     f0104aa0 <__udivdi3+0x40>
f0104ac2:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ac7:	eb d7                	jmp    f0104aa0 <__udivdi3+0x40>
f0104ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104ad0:	89 d9                	mov    %ebx,%ecx
f0104ad2:	85 db                	test   %ebx,%ebx
f0104ad4:	75 0b                	jne    f0104ae1 <__udivdi3+0x81>
f0104ad6:	b8 01 00 00 00       	mov    $0x1,%eax
f0104adb:	31 d2                	xor    %edx,%edx
f0104add:	f7 f3                	div    %ebx
f0104adf:	89 c1                	mov    %eax,%ecx
f0104ae1:	31 d2                	xor    %edx,%edx
f0104ae3:	89 f0                	mov    %esi,%eax
f0104ae5:	f7 f1                	div    %ecx
f0104ae7:	89 c6                	mov    %eax,%esi
f0104ae9:	89 e8                	mov    %ebp,%eax
f0104aeb:	89 f7                	mov    %esi,%edi
f0104aed:	f7 f1                	div    %ecx
f0104aef:	89 fa                	mov    %edi,%edx
f0104af1:	83 c4 1c             	add    $0x1c,%esp
f0104af4:	5b                   	pop    %ebx
f0104af5:	5e                   	pop    %esi
f0104af6:	5f                   	pop    %edi
f0104af7:	5d                   	pop    %ebp
f0104af8:	c3                   	ret    
f0104af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104b00:	89 f9                	mov    %edi,%ecx
f0104b02:	b8 20 00 00 00       	mov    $0x20,%eax
f0104b07:	29 f8                	sub    %edi,%eax
f0104b09:	d3 e2                	shl    %cl,%edx
f0104b0b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104b0f:	89 c1                	mov    %eax,%ecx
f0104b11:	89 da                	mov    %ebx,%edx
f0104b13:	d3 ea                	shr    %cl,%edx
f0104b15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104b19:	09 d1                	or     %edx,%ecx
f0104b1b:	89 f2                	mov    %esi,%edx
f0104b1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104b21:	89 f9                	mov    %edi,%ecx
f0104b23:	d3 e3                	shl    %cl,%ebx
f0104b25:	89 c1                	mov    %eax,%ecx
f0104b27:	d3 ea                	shr    %cl,%edx
f0104b29:	89 f9                	mov    %edi,%ecx
f0104b2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104b2f:	89 eb                	mov    %ebp,%ebx
f0104b31:	d3 e6                	shl    %cl,%esi
f0104b33:	89 c1                	mov    %eax,%ecx
f0104b35:	d3 eb                	shr    %cl,%ebx
f0104b37:	09 de                	or     %ebx,%esi
f0104b39:	89 f0                	mov    %esi,%eax
f0104b3b:	f7 74 24 08          	divl   0x8(%esp)
f0104b3f:	89 d6                	mov    %edx,%esi
f0104b41:	89 c3                	mov    %eax,%ebx
f0104b43:	f7 64 24 0c          	mull   0xc(%esp)
f0104b47:	39 d6                	cmp    %edx,%esi
f0104b49:	72 15                	jb     f0104b60 <__udivdi3+0x100>
f0104b4b:	89 f9                	mov    %edi,%ecx
f0104b4d:	d3 e5                	shl    %cl,%ebp
f0104b4f:	39 c5                	cmp    %eax,%ebp
f0104b51:	73 04                	jae    f0104b57 <__udivdi3+0xf7>
f0104b53:	39 d6                	cmp    %edx,%esi
f0104b55:	74 09                	je     f0104b60 <__udivdi3+0x100>
f0104b57:	89 d8                	mov    %ebx,%eax
f0104b59:	31 ff                	xor    %edi,%edi
f0104b5b:	e9 40 ff ff ff       	jmp    f0104aa0 <__udivdi3+0x40>
f0104b60:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104b63:	31 ff                	xor    %edi,%edi
f0104b65:	e9 36 ff ff ff       	jmp    f0104aa0 <__udivdi3+0x40>
f0104b6a:	66 90                	xchg   %ax,%ax
f0104b6c:	66 90                	xchg   %ax,%ax
f0104b6e:	66 90                	xchg   %ax,%ax

f0104b70 <__umoddi3>:
f0104b70:	f3 0f 1e fb          	endbr32 
f0104b74:	55                   	push   %ebp
f0104b75:	57                   	push   %edi
f0104b76:	56                   	push   %esi
f0104b77:	53                   	push   %ebx
f0104b78:	83 ec 1c             	sub    $0x1c,%esp
f0104b7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0104b7f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104b83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104b87:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104b8b:	85 c0                	test   %eax,%eax
f0104b8d:	75 19                	jne    f0104ba8 <__umoddi3+0x38>
f0104b8f:	39 df                	cmp    %ebx,%edi
f0104b91:	76 5d                	jbe    f0104bf0 <__umoddi3+0x80>
f0104b93:	89 f0                	mov    %esi,%eax
f0104b95:	89 da                	mov    %ebx,%edx
f0104b97:	f7 f7                	div    %edi
f0104b99:	89 d0                	mov    %edx,%eax
f0104b9b:	31 d2                	xor    %edx,%edx
f0104b9d:	83 c4 1c             	add    $0x1c,%esp
f0104ba0:	5b                   	pop    %ebx
f0104ba1:	5e                   	pop    %esi
f0104ba2:	5f                   	pop    %edi
f0104ba3:	5d                   	pop    %ebp
f0104ba4:	c3                   	ret    
f0104ba5:	8d 76 00             	lea    0x0(%esi),%esi
f0104ba8:	89 f2                	mov    %esi,%edx
f0104baa:	39 d8                	cmp    %ebx,%eax
f0104bac:	76 12                	jbe    f0104bc0 <__umoddi3+0x50>
f0104bae:	89 f0                	mov    %esi,%eax
f0104bb0:	89 da                	mov    %ebx,%edx
f0104bb2:	83 c4 1c             	add    $0x1c,%esp
f0104bb5:	5b                   	pop    %ebx
f0104bb6:	5e                   	pop    %esi
f0104bb7:	5f                   	pop    %edi
f0104bb8:	5d                   	pop    %ebp
f0104bb9:	c3                   	ret    
f0104bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104bc0:	0f bd e8             	bsr    %eax,%ebp
f0104bc3:	83 f5 1f             	xor    $0x1f,%ebp
f0104bc6:	75 50                	jne    f0104c18 <__umoddi3+0xa8>
f0104bc8:	39 d8                	cmp    %ebx,%eax
f0104bca:	0f 82 e0 00 00 00    	jb     f0104cb0 <__umoddi3+0x140>
f0104bd0:	89 d9                	mov    %ebx,%ecx
f0104bd2:	39 f7                	cmp    %esi,%edi
f0104bd4:	0f 86 d6 00 00 00    	jbe    f0104cb0 <__umoddi3+0x140>
f0104bda:	89 d0                	mov    %edx,%eax
f0104bdc:	89 ca                	mov    %ecx,%edx
f0104bde:	83 c4 1c             	add    $0x1c,%esp
f0104be1:	5b                   	pop    %ebx
f0104be2:	5e                   	pop    %esi
f0104be3:	5f                   	pop    %edi
f0104be4:	5d                   	pop    %ebp
f0104be5:	c3                   	ret    
f0104be6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104bed:	8d 76 00             	lea    0x0(%esi),%esi
f0104bf0:	89 fd                	mov    %edi,%ebp
f0104bf2:	85 ff                	test   %edi,%edi
f0104bf4:	75 0b                	jne    f0104c01 <__umoddi3+0x91>
f0104bf6:	b8 01 00 00 00       	mov    $0x1,%eax
f0104bfb:	31 d2                	xor    %edx,%edx
f0104bfd:	f7 f7                	div    %edi
f0104bff:	89 c5                	mov    %eax,%ebp
f0104c01:	89 d8                	mov    %ebx,%eax
f0104c03:	31 d2                	xor    %edx,%edx
f0104c05:	f7 f5                	div    %ebp
f0104c07:	89 f0                	mov    %esi,%eax
f0104c09:	f7 f5                	div    %ebp
f0104c0b:	89 d0                	mov    %edx,%eax
f0104c0d:	31 d2                	xor    %edx,%edx
f0104c0f:	eb 8c                	jmp    f0104b9d <__umoddi3+0x2d>
f0104c11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104c18:	89 e9                	mov    %ebp,%ecx
f0104c1a:	ba 20 00 00 00       	mov    $0x20,%edx
f0104c1f:	29 ea                	sub    %ebp,%edx
f0104c21:	d3 e0                	shl    %cl,%eax
f0104c23:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c27:	89 d1                	mov    %edx,%ecx
f0104c29:	89 f8                	mov    %edi,%eax
f0104c2b:	d3 e8                	shr    %cl,%eax
f0104c2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104c31:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104c35:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104c39:	09 c1                	or     %eax,%ecx
f0104c3b:	89 d8                	mov    %ebx,%eax
f0104c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104c41:	89 e9                	mov    %ebp,%ecx
f0104c43:	d3 e7                	shl    %cl,%edi
f0104c45:	89 d1                	mov    %edx,%ecx
f0104c47:	d3 e8                	shr    %cl,%eax
f0104c49:	89 e9                	mov    %ebp,%ecx
f0104c4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104c4f:	d3 e3                	shl    %cl,%ebx
f0104c51:	89 c7                	mov    %eax,%edi
f0104c53:	89 d1                	mov    %edx,%ecx
f0104c55:	89 f0                	mov    %esi,%eax
f0104c57:	d3 e8                	shr    %cl,%eax
f0104c59:	89 e9                	mov    %ebp,%ecx
f0104c5b:	89 fa                	mov    %edi,%edx
f0104c5d:	d3 e6                	shl    %cl,%esi
f0104c5f:	09 d8                	or     %ebx,%eax
f0104c61:	f7 74 24 08          	divl   0x8(%esp)
f0104c65:	89 d1                	mov    %edx,%ecx
f0104c67:	89 f3                	mov    %esi,%ebx
f0104c69:	f7 64 24 0c          	mull   0xc(%esp)
f0104c6d:	89 c6                	mov    %eax,%esi
f0104c6f:	89 d7                	mov    %edx,%edi
f0104c71:	39 d1                	cmp    %edx,%ecx
f0104c73:	72 06                	jb     f0104c7b <__umoddi3+0x10b>
f0104c75:	75 10                	jne    f0104c87 <__umoddi3+0x117>
f0104c77:	39 c3                	cmp    %eax,%ebx
f0104c79:	73 0c                	jae    f0104c87 <__umoddi3+0x117>
f0104c7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0104c7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104c83:	89 d7                	mov    %edx,%edi
f0104c85:	89 c6                	mov    %eax,%esi
f0104c87:	89 ca                	mov    %ecx,%edx
f0104c89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104c8e:	29 f3                	sub    %esi,%ebx
f0104c90:	19 fa                	sbb    %edi,%edx
f0104c92:	89 d0                	mov    %edx,%eax
f0104c94:	d3 e0                	shl    %cl,%eax
f0104c96:	89 e9                	mov    %ebp,%ecx
f0104c98:	d3 eb                	shr    %cl,%ebx
f0104c9a:	d3 ea                	shr    %cl,%edx
f0104c9c:	09 d8                	or     %ebx,%eax
f0104c9e:	83 c4 1c             	add    $0x1c,%esp
f0104ca1:	5b                   	pop    %ebx
f0104ca2:	5e                   	pop    %esi
f0104ca3:	5f                   	pop    %edi
f0104ca4:	5d                   	pop    %ebp
f0104ca5:	c3                   	ret    
f0104ca6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104cad:	8d 76 00             	lea    0x0(%esi),%esi
f0104cb0:	29 fe                	sub    %edi,%esi
f0104cb2:	19 c3                	sbb    %eax,%ebx
f0104cb4:	89 f2                	mov    %esi,%edx
f0104cb6:	89 d9                	mov    %ebx,%ecx
f0104cb8:	e9 1d ff ff ff       	jmp    f0104bda <__umoddi3+0x6a>
