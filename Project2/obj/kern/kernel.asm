
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
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f010004a:	b8 60 89 11 f0       	mov    $0xf0118960,%eax
f010004f:	2d 00 83 11 f0       	sub    $0xf0118300,%eax
f0100054:	50                   	push   %eax
f0100055:	6a 00                	push   $0x0
f0100057:	68 00 83 11 f0       	push   $0xf0118300
f010005c:	e8 de 34 00 00       	call   f010353f <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100061:	e8 a8 04 00 00       	call   f010050e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100066:	83 c4 08             	add    $0x8,%esp
f0100069:	68 ac 1a 00 00       	push   $0x1aac
f010006e:	68 c0 39 10 f0       	push   $0xf01039c0
f0100073:	e8 a2 29 00 00       	call   f0102a1a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100078:	e8 f7 10 00 00       	call   f0101174 <mem_init>
f010007d:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100080:	83 ec 0c             	sub    $0xc,%esp
f0100083:	6a 00                	push   $0x0
f0100085:	e8 f5 06 00 00       	call   f010077f <monitor>
f010008a:	83 c4 10             	add    $0x10,%esp
f010008d:	eb f1                	jmp    f0100080 <i386_init+0x40>

f010008f <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008f:	f3 0f 1e fb          	endbr32 
f0100093:	55                   	push   %ebp
f0100094:	89 e5                	mov    %esp,%ebp
f0100096:	56                   	push   %esi
f0100097:	53                   	push   %ebx
f0100098:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009b:	83 3d 64 89 11 f0 00 	cmpl   $0x0,0xf0118964
f01000a2:	74 0f                	je     f01000b3 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a4:	83 ec 0c             	sub    $0xc,%esp
f01000a7:	6a 00                	push   $0x0
f01000a9:	e8 d1 06 00 00       	call   f010077f <monitor>
f01000ae:	83 c4 10             	add    $0x10,%esp
f01000b1:	eb f1                	jmp    f01000a4 <_panic+0x15>
	panicstr = fmt;
f01000b3:	89 35 64 89 11 f0    	mov    %esi,0xf0118964
	asm volatile("cli; cld");
f01000b9:	fa                   	cli    
f01000ba:	fc                   	cld    
	va_start(ap, fmt);
f01000bb:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000be:	83 ec 04             	sub    $0x4,%esp
f01000c1:	ff 75 0c             	pushl  0xc(%ebp)
f01000c4:	ff 75 08             	pushl  0x8(%ebp)
f01000c7:	68 db 39 10 f0       	push   $0xf01039db
f01000cc:	e8 49 29 00 00       	call   f0102a1a <cprintf>
	vcprintf(fmt, ap);
f01000d1:	83 c4 08             	add    $0x8,%esp
f01000d4:	53                   	push   %ebx
f01000d5:	56                   	push   %esi
f01000d6:	e8 15 29 00 00       	call   f01029f0 <vcprintf>
	cprintf("\n");
f01000db:	c7 04 24 cc 49 10 f0 	movl   $0xf01049cc,(%esp)
f01000e2:	e8 33 29 00 00       	call   f0102a1a <cprintf>
f01000e7:	83 c4 10             	add    $0x10,%esp
f01000ea:	eb b8                	jmp    f01000a4 <_panic+0x15>

f01000ec <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000ec:	f3 0f 1e fb          	endbr32 
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000f7:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000fa:	ff 75 0c             	pushl  0xc(%ebp)
f01000fd:	ff 75 08             	pushl  0x8(%ebp)
f0100100:	68 f3 39 10 f0       	push   $0xf01039f3
f0100105:	e8 10 29 00 00       	call   f0102a1a <cprintf>
	vcprintf(fmt, ap);
f010010a:	83 c4 08             	add    $0x8,%esp
f010010d:	53                   	push   %ebx
f010010e:	ff 75 10             	pushl  0x10(%ebp)
f0100111:	e8 da 28 00 00       	call   f01029f0 <vcprintf>
	cprintf("\n");
f0100116:	c7 04 24 cc 49 10 f0 	movl   $0xf01049cc,(%esp)
f010011d:	e8 f8 28 00 00       	call   f0102a1a <cprintf>
	va_end(ap);
}
f0100122:	83 c4 10             	add    $0x10,%esp
f0100125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100128:	c9                   	leave  
f0100129:	c3                   	ret    

f010012a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010012a:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010012e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100133:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100134:	a8 01                	test   $0x1,%al
f0100136:	74 0a                	je     f0100142 <serial_proc_data+0x18>
f0100138:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010013d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010013e:	0f b6 c0             	movzbl %al,%eax
f0100141:	c3                   	ret    
		return -1;
f0100142:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100147:	c3                   	ret    

f0100148 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100148:	55                   	push   %ebp
f0100149:	89 e5                	mov    %esp,%ebp
f010014b:	53                   	push   %ebx
f010014c:	83 ec 04             	sub    $0x4,%esp
f010014f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100151:	ff d3                	call   *%ebx
f0100153:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100156:	74 29                	je     f0100181 <cons_intr+0x39>
		if (c == 0)
f0100158:	85 c0                	test   %eax,%eax
f010015a:	74 f5                	je     f0100151 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010015c:	8b 0d 24 85 11 f0    	mov    0xf0118524,%ecx
f0100162:	8d 51 01             	lea    0x1(%ecx),%edx
f0100165:	88 81 20 83 11 f0    	mov    %al,-0xfee7ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010016b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100171:	b8 00 00 00 00       	mov    $0x0,%eax
f0100176:	0f 44 d0             	cmove  %eax,%edx
f0100179:	89 15 24 85 11 f0    	mov    %edx,0xf0118524
f010017f:	eb d0                	jmp    f0100151 <cons_intr+0x9>
	}
}
f0100181:	83 c4 04             	add    $0x4,%esp
f0100184:	5b                   	pop    %ebx
f0100185:	5d                   	pop    %ebp
f0100186:	c3                   	ret    

f0100187 <kbd_proc_data>:
{
f0100187:	f3 0f 1e fb          	endbr32 
f010018b:	55                   	push   %ebp
f010018c:	89 e5                	mov    %esp,%ebp
f010018e:	53                   	push   %ebx
f010018f:	83 ec 04             	sub    $0x4,%esp
f0100192:	ba 64 00 00 00       	mov    $0x64,%edx
f0100197:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100198:	a8 01                	test   $0x1,%al
f010019a:	0f 84 f2 00 00 00    	je     f0100292 <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f01001a0:	a8 20                	test   $0x20,%al
f01001a2:	0f 85 f1 00 00 00    	jne    f0100299 <kbd_proc_data+0x112>
f01001a8:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ad:	ec                   	in     (%dx),%al
f01001ae:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01001b0:	3c e0                	cmp    $0xe0,%al
f01001b2:	74 61                	je     f0100215 <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f01001b4:	84 c0                	test   %al,%al
f01001b6:	78 70                	js     f0100228 <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f01001b8:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f01001be:	f6 c1 40             	test   $0x40,%cl
f01001c1:	74 0e                	je     f01001d1 <kbd_proc_data+0x4a>
		data |= 0x80;
f01001c3:	83 c8 80             	or     $0xffffff80,%eax
f01001c6:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001c8:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001cb:	89 0d 00 83 11 f0    	mov    %ecx,0xf0118300
	shift |= shiftcode[data];
f01001d1:	0f b6 d2             	movzbl %dl,%edx
f01001d4:	0f b6 82 60 3b 10 f0 	movzbl -0xfefc4a0(%edx),%eax
f01001db:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f01001e1:	0f b6 8a 60 3a 10 f0 	movzbl -0xfefc5a0(%edx),%ecx
f01001e8:	31 c8                	xor    %ecx,%eax
f01001ea:	a3 00 83 11 f0       	mov    %eax,0xf0118300
	c = charcode[shift & (CTL | SHIFT)][data];
f01001ef:	89 c1                	mov    %eax,%ecx
f01001f1:	83 e1 03             	and    $0x3,%ecx
f01001f4:	8b 0c 8d 40 3a 10 f0 	mov    -0xfefc5c0(,%ecx,4),%ecx
f01001fb:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01001ff:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100202:	a8 08                	test   $0x8,%al
f0100204:	74 61                	je     f0100267 <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f0100206:	89 da                	mov    %ebx,%edx
f0100208:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010020b:	83 f9 19             	cmp    $0x19,%ecx
f010020e:	77 4b                	ja     f010025b <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f0100210:	83 eb 20             	sub    $0x20,%ebx
f0100213:	eb 0c                	jmp    f0100221 <kbd_proc_data+0x9a>
		shift |= E0ESC;
f0100215:	83 0d 00 83 11 f0 40 	orl    $0x40,0xf0118300
		return 0;
f010021c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100221:	89 d8                	mov    %ebx,%eax
f0100223:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100226:	c9                   	leave  
f0100227:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100228:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f010022e:	89 cb                	mov    %ecx,%ebx
f0100230:	83 e3 40             	and    $0x40,%ebx
f0100233:	83 e0 7f             	and    $0x7f,%eax
f0100236:	85 db                	test   %ebx,%ebx
f0100238:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010023b:	0f b6 d2             	movzbl %dl,%edx
f010023e:	0f b6 82 60 3b 10 f0 	movzbl -0xfefc4a0(%edx),%eax
f0100245:	83 c8 40             	or     $0x40,%eax
f0100248:	0f b6 c0             	movzbl %al,%eax
f010024b:	f7 d0                	not    %eax
f010024d:	21 c8                	and    %ecx,%eax
f010024f:	a3 00 83 11 f0       	mov    %eax,0xf0118300
		return 0;
f0100254:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100259:	eb c6                	jmp    f0100221 <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f010025b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010025e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100261:	83 fa 1a             	cmp    $0x1a,%edx
f0100264:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100267:	f7 d0                	not    %eax
f0100269:	a8 06                	test   $0x6,%al
f010026b:	75 b4                	jne    f0100221 <kbd_proc_data+0x9a>
f010026d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100273:	75 ac                	jne    f0100221 <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f0100275:	83 ec 0c             	sub    $0xc,%esp
f0100278:	68 0d 3a 10 f0       	push   $0xf0103a0d
f010027d:	e8 98 27 00 00       	call   f0102a1a <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100282:	b8 03 00 00 00       	mov    $0x3,%eax
f0100287:	ba 92 00 00 00       	mov    $0x92,%edx
f010028c:	ee                   	out    %al,(%dx)
}
f010028d:	83 c4 10             	add    $0x10,%esp
f0100290:	eb 8f                	jmp    f0100221 <kbd_proc_data+0x9a>
		return -1;
f0100292:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100297:	eb 88                	jmp    f0100221 <kbd_proc_data+0x9a>
		return -1;
f0100299:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010029e:	eb 81                	jmp    f0100221 <kbd_proc_data+0x9a>

f01002a0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002a0:	55                   	push   %ebp
f01002a1:	89 e5                	mov    %esp,%ebp
f01002a3:	57                   	push   %edi
f01002a4:	56                   	push   %esi
f01002a5:	53                   	push   %ebx
f01002a6:	83 ec 1c             	sub    $0x1c,%esp
f01002a9:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f01002ab:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b0:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01002b5:	bb 84 00 00 00       	mov    $0x84,%ebx
f01002ba:	89 fa                	mov    %edi,%edx
f01002bc:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002bd:	a8 20                	test   $0x20,%al
f01002bf:	75 13                	jne    f01002d4 <cons_putc+0x34>
f01002c1:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01002c7:	7f 0b                	jg     f01002d4 <cons_putc+0x34>
f01002c9:	89 da                	mov    %ebx,%edx
f01002cb:	ec                   	in     (%dx),%al
f01002cc:	ec                   	in     (%dx),%al
f01002cd:	ec                   	in     (%dx),%al
f01002ce:	ec                   	in     (%dx),%al
	     i++)
f01002cf:	83 c6 01             	add    $0x1,%esi
f01002d2:	eb e6                	jmp    f01002ba <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f01002d4:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002dc:	89 c8                	mov    %ecx,%eax
f01002de:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002df:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e4:	bf 79 03 00 00       	mov    $0x379,%edi
f01002e9:	bb 84 00 00 00       	mov    $0x84,%ebx
f01002ee:	89 fa                	mov    %edi,%edx
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01002f7:	7f 0f                	jg     f0100308 <cons_putc+0x68>
f01002f9:	84 c0                	test   %al,%al
f01002fb:	78 0b                	js     f0100308 <cons_putc+0x68>
f01002fd:	89 da                	mov    %ebx,%edx
f01002ff:	ec                   	in     (%dx),%al
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	ec                   	in     (%dx),%al
f0100303:	83 c6 01             	add    $0x1,%esi
f0100306:	eb e6                	jmp    f01002ee <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100308:	ba 78 03 00 00       	mov    $0x378,%edx
f010030d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100311:	ee                   	out    %al,(%dx)
f0100312:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100317:	b8 0d 00 00 00       	mov    $0xd,%eax
f010031c:	ee                   	out    %al,(%dx)
f010031d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100322:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100323:	89 c8                	mov    %ecx,%eax
f0100325:	80 cc 07             	or     $0x7,%ah
f0100328:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f010032e:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100331:	0f b6 c1             	movzbl %cl,%eax
f0100334:	80 f9 0a             	cmp    $0xa,%cl
f0100337:	0f 84 dd 00 00 00    	je     f010041a <cons_putc+0x17a>
f010033d:	83 f8 0a             	cmp    $0xa,%eax
f0100340:	7f 46                	jg     f0100388 <cons_putc+0xe8>
f0100342:	83 f8 08             	cmp    $0x8,%eax
f0100345:	0f 84 a7 00 00 00    	je     f01003f2 <cons_putc+0x152>
f010034b:	83 f8 09             	cmp    $0x9,%eax
f010034e:	0f 85 d3 00 00 00    	jne    f0100427 <cons_putc+0x187>
		cons_putc(' ');
f0100354:	b8 20 00 00 00       	mov    $0x20,%eax
f0100359:	e8 42 ff ff ff       	call   f01002a0 <cons_putc>
		cons_putc(' ');
f010035e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100363:	e8 38 ff ff ff       	call   f01002a0 <cons_putc>
		cons_putc(' ');
f0100368:	b8 20 00 00 00       	mov    $0x20,%eax
f010036d:	e8 2e ff ff ff       	call   f01002a0 <cons_putc>
		cons_putc(' ');
f0100372:	b8 20 00 00 00       	mov    $0x20,%eax
f0100377:	e8 24 ff ff ff       	call   f01002a0 <cons_putc>
		cons_putc(' ');
f010037c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100381:	e8 1a ff ff ff       	call   f01002a0 <cons_putc>
		break;
f0100386:	eb 25                	jmp    f01003ad <cons_putc+0x10d>
	switch (c & 0xff) {
f0100388:	83 f8 0d             	cmp    $0xd,%eax
f010038b:	0f 85 96 00 00 00    	jne    f0100427 <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f0100391:	0f b7 05 28 85 11 f0 	movzwl 0xf0118528,%eax
f0100398:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010039e:	c1 e8 16             	shr    $0x16,%eax
f01003a1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a4:	c1 e0 04             	shl    $0x4,%eax
f01003a7:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
	if (crt_pos >= CRT_SIZE) {
f01003ad:	66 81 3d 28 85 11 f0 	cmpw   $0x7cf,0xf0118528
f01003b4:	cf 07 
f01003b6:	0f 87 8e 00 00 00    	ja     f010044a <cons_putc+0x1aa>
	outb(addr_6845, 14);
f01003bc:	8b 0d 30 85 11 f0    	mov    0xf0118530,%ecx
f01003c2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003c7:	89 ca                	mov    %ecx,%edx
f01003c9:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003ca:	0f b7 1d 28 85 11 f0 	movzwl 0xf0118528,%ebx
f01003d1:	8d 71 01             	lea    0x1(%ecx),%esi
f01003d4:	89 d8                	mov    %ebx,%eax
f01003d6:	66 c1 e8 08          	shr    $0x8,%ax
f01003da:	89 f2                	mov    %esi,%edx
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003e2:	89 ca                	mov    %ecx,%edx
f01003e4:	ee                   	out    %al,(%dx)
f01003e5:	89 d8                	mov    %ebx,%eax
f01003e7:	89 f2                	mov    %esi,%edx
f01003e9:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003ed:	5b                   	pop    %ebx
f01003ee:	5e                   	pop    %esi
f01003ef:	5f                   	pop    %edi
f01003f0:	5d                   	pop    %ebp
f01003f1:	c3                   	ret    
		if (crt_pos > 0) {
f01003f2:	0f b7 05 28 85 11 f0 	movzwl 0xf0118528,%eax
f01003f9:	66 85 c0             	test   %ax,%ax
f01003fc:	74 be                	je     f01003bc <cons_putc+0x11c>
			crt_pos--;
f01003fe:	83 e8 01             	sub    $0x1,%eax
f0100401:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100407:	0f b7 d0             	movzwl %ax,%edx
f010040a:	b1 00                	mov    $0x0,%cl
f010040c:	83 c9 20             	or     $0x20,%ecx
f010040f:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f0100414:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f0100418:	eb 93                	jmp    f01003ad <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f010041a:	66 83 05 28 85 11 f0 	addw   $0x50,0xf0118528
f0100421:	50 
f0100422:	e9 6a ff ff ff       	jmp    f0100391 <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100427:	0f b7 05 28 85 11 f0 	movzwl 0xf0118528,%eax
f010042e:	8d 50 01             	lea    0x1(%eax),%edx
f0100431:	66 89 15 28 85 11 f0 	mov    %dx,0xf0118528
f0100438:	0f b7 c0             	movzwl %ax,%eax
f010043b:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f0100441:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f0100445:	e9 63 ff ff ff       	jmp    f01003ad <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010044a:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f010044f:	83 ec 04             	sub    $0x4,%esp
f0100452:	68 00 0f 00 00       	push   $0xf00
f0100457:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010045d:	52                   	push   %edx
f010045e:	50                   	push   %eax
f010045f:	e8 27 31 00 00       	call   f010358b <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100464:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f010046a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100470:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100476:	83 c4 10             	add    $0x10,%esp
f0100479:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010047e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100481:	39 d0                	cmp    %edx,%eax
f0100483:	75 f4                	jne    f0100479 <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f0100485:	66 83 2d 28 85 11 f0 	subw   $0x50,0xf0118528
f010048c:	50 
f010048d:	e9 2a ff ff ff       	jmp    f01003bc <cons_putc+0x11c>

f0100492 <serial_intr>:
{
f0100492:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f0100496:	80 3d 34 85 11 f0 00 	cmpb   $0x0,0xf0118534
f010049d:	75 01                	jne    f01004a0 <serial_intr+0xe>
f010049f:	c3                   	ret    
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01004a6:	b8 2a 01 10 f0       	mov    $0xf010012a,%eax
f01004ab:	e8 98 fc ff ff       	call   f0100148 <cons_intr>
}
f01004b0:	c9                   	leave  
f01004b1:	c3                   	ret    

f01004b2 <kbd_intr>:
{
f01004b2:	f3 0f 1e fb          	endbr32 
f01004b6:	55                   	push   %ebp
f01004b7:	89 e5                	mov    %esp,%ebp
f01004b9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004bc:	b8 87 01 10 f0       	mov    $0xf0100187,%eax
f01004c1:	e8 82 fc ff ff       	call   f0100148 <cons_intr>
}
f01004c6:	c9                   	leave  
f01004c7:	c3                   	ret    

f01004c8 <cons_getc>:
{
f01004c8:	f3 0f 1e fb          	endbr32 
f01004cc:	55                   	push   %ebp
f01004cd:	89 e5                	mov    %esp,%ebp
f01004cf:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01004d2:	e8 bb ff ff ff       	call   f0100492 <serial_intr>
	kbd_intr();
f01004d7:	e8 d6 ff ff ff       	call   f01004b2 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01004dc:	a1 20 85 11 f0       	mov    0xf0118520,%eax
	return 0;
f01004e1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01004e6:	3b 05 24 85 11 f0    	cmp    0xf0118524,%eax
f01004ec:	74 1c                	je     f010050a <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f01004ee:	8d 48 01             	lea    0x1(%eax),%ecx
f01004f1:	0f b6 90 20 83 11 f0 	movzbl -0xfee7ce0(%eax),%edx
			cons.rpos = 0;
f01004f8:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01004fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100502:	0f 45 c1             	cmovne %ecx,%eax
f0100505:	a3 20 85 11 f0       	mov    %eax,0xf0118520
}
f010050a:	89 d0                	mov    %edx,%eax
f010050c:	c9                   	leave  
f010050d:	c3                   	ret    

f010050e <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010050e:	f3 0f 1e fb          	endbr32 
f0100512:	55                   	push   %ebp
f0100513:	89 e5                	mov    %esp,%ebp
f0100515:	57                   	push   %edi
f0100516:	56                   	push   %esi
f0100517:	53                   	push   %ebx
f0100518:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010051b:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100522:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100529:	5a a5 
	if (*cp != 0xA55A) {
f010052b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100532:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100536:	0f 84 b7 00 00 00    	je     f01005f3 <cons_init+0xe5>
		addr_6845 = MONO_BASE;
f010053c:	c7 05 30 85 11 f0 b4 	movl   $0x3b4,0xf0118530
f0100543:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100546:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010054b:	8b 3d 30 85 11 f0    	mov    0xf0118530,%edi
f0100551:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100556:	89 fa                	mov    %edi,%edx
f0100558:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100559:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055c:	89 ca                	mov    %ecx,%edx
f010055e:	ec                   	in     (%dx),%al
f010055f:	0f b6 c0             	movzbl %al,%eax
f0100562:	c1 e0 08             	shl    $0x8,%eax
f0100565:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100567:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056c:	89 fa                	mov    %edi,%edx
f010056e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056f:	89 ca                	mov    %ecx,%edx
f0100571:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100572:	89 35 2c 85 11 f0    	mov    %esi,0xf011852c
	pos |= inb(addr_6845 + 1);
f0100578:	0f b6 c0             	movzbl %al,%eax
f010057b:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f010057d:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100583:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100588:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f010058d:	89 d8                	mov    %ebx,%eax
f010058f:	89 ca                	mov    %ecx,%edx
f0100591:	ee                   	out    %al,(%dx)
f0100592:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100597:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010059c:	89 fa                	mov    %edi,%edx
f010059e:	ee                   	out    %al,(%dx)
f010059f:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005a9:	ee                   	out    %al,(%dx)
f01005aa:	be f9 03 00 00       	mov    $0x3f9,%esi
f01005af:	89 d8                	mov    %ebx,%eax
f01005b1:	89 f2                	mov    %esi,%edx
f01005b3:	ee                   	out    %al,(%dx)
f01005b4:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b9:	89 fa                	mov    %edi,%edx
f01005bb:	ee                   	out    %al,(%dx)
f01005bc:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005c1:	89 d8                	mov    %ebx,%eax
f01005c3:	ee                   	out    %al,(%dx)
f01005c4:	b8 01 00 00 00       	mov    $0x1,%eax
f01005c9:	89 f2                	mov    %esi,%edx
f01005cb:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d4:	3c ff                	cmp    $0xff,%al
f01005d6:	0f 95 05 34 85 11 f0 	setne  0xf0118534
f01005dd:	89 ca                	mov    %ecx,%edx
f01005df:	ec                   	in     (%dx),%al
f01005e0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005e5:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e6:	80 fb ff             	cmp    $0xff,%bl
f01005e9:	74 23                	je     f010060e <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
}
f01005eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ee:	5b                   	pop    %ebx
f01005ef:	5e                   	pop    %esi
f01005f0:	5f                   	pop    %edi
f01005f1:	5d                   	pop    %ebp
f01005f2:	c3                   	ret    
		*cp = was;
f01005f3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005fa:	c7 05 30 85 11 f0 d4 	movl   $0x3d4,0xf0118530
f0100601:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100604:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100609:	e9 3d ff ff ff       	jmp    f010054b <cons_init+0x3d>
		cprintf("Serial port does not exist!\n");
f010060e:	83 ec 0c             	sub    $0xc,%esp
f0100611:	68 19 3a 10 f0       	push   $0xf0103a19
f0100616:	e8 ff 23 00 00       	call   f0102a1a <cprintf>
f010061b:	83 c4 10             	add    $0x10,%esp
}
f010061e:	eb cb                	jmp    f01005eb <cons_init+0xdd>

f0100620 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100620:	f3 0f 1e fb          	endbr32 
f0100624:	55                   	push   %ebp
f0100625:	89 e5                	mov    %esp,%ebp
f0100627:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010062a:	8b 45 08             	mov    0x8(%ebp),%eax
f010062d:	e8 6e fc ff ff       	call   f01002a0 <cons_putc>
}
f0100632:	c9                   	leave  
f0100633:	c3                   	ret    

f0100634 <getchar>:

int
getchar(void)
{
f0100634:	f3 0f 1e fb          	endbr32 
f0100638:	55                   	push   %ebp
f0100639:	89 e5                	mov    %esp,%ebp
f010063b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010063e:	e8 85 fe ff ff       	call   f01004c8 <cons_getc>
f0100643:	85 c0                	test   %eax,%eax
f0100645:	74 f7                	je     f010063e <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100647:	c9                   	leave  
f0100648:	c3                   	ret    

f0100649 <iscons>:

int
iscons(int fdnum)
{
f0100649:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010064d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100652:	c3                   	ret    

f0100653 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100653:	f3 0f 1e fb          	endbr32 
f0100657:	55                   	push   %ebp
f0100658:	89 e5                	mov    %esp,%ebp
f010065a:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010065d:	68 60 3c 10 f0       	push   $0xf0103c60
f0100662:	68 7e 3c 10 f0       	push   $0xf0103c7e
f0100667:	68 83 3c 10 f0       	push   $0xf0103c83
f010066c:	e8 a9 23 00 00       	call   f0102a1a <cprintf>
f0100671:	83 c4 0c             	add    $0xc,%esp
f0100674:	68 fc 3c 10 f0       	push   $0xf0103cfc
f0100679:	68 8c 3c 10 f0       	push   $0xf0103c8c
f010067e:	68 83 3c 10 f0       	push   $0xf0103c83
f0100683:	e8 92 23 00 00       	call   f0102a1a <cprintf>
	return 0;
}
f0100688:	b8 00 00 00 00       	mov    $0x0,%eax
f010068d:	c9                   	leave  
f010068e:	c3                   	ret    

f010068f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010068f:	f3 0f 1e fb          	endbr32 
f0100693:	55                   	push   %ebp
f0100694:	89 e5                	mov    %esp,%ebp
f0100696:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100699:	68 95 3c 10 f0       	push   $0xf0103c95
f010069e:	e8 77 23 00 00       	call   f0102a1a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006a3:	83 c4 08             	add    $0x8,%esp
f01006a6:	68 0c 00 10 00       	push   $0x10000c
f01006ab:	68 24 3d 10 f0       	push   $0xf0103d24
f01006b0:	e8 65 23 00 00       	call   f0102a1a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006b5:	83 c4 0c             	add    $0xc,%esp
f01006b8:	68 0c 00 10 00       	push   $0x10000c
f01006bd:	68 0c 00 10 f0       	push   $0xf010000c
f01006c2:	68 4c 3d 10 f0       	push   $0xf0103d4c
f01006c7:	e8 4e 23 00 00       	call   f0102a1a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006cc:	83 c4 0c             	add    $0xc,%esp
f01006cf:	68 ad 39 10 00       	push   $0x1039ad
f01006d4:	68 ad 39 10 f0       	push   $0xf01039ad
f01006d9:	68 70 3d 10 f0       	push   $0xf0103d70
f01006de:	e8 37 23 00 00       	call   f0102a1a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006e3:	83 c4 0c             	add    $0xc,%esp
f01006e6:	68 00 83 11 00       	push   $0x118300
f01006eb:	68 00 83 11 f0       	push   $0xf0118300
f01006f0:	68 94 3d 10 f0       	push   $0xf0103d94
f01006f5:	e8 20 23 00 00       	call   f0102a1a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006fa:	83 c4 0c             	add    $0xc,%esp
f01006fd:	68 60 89 11 00       	push   $0x118960
f0100702:	68 60 89 11 f0       	push   $0xf0118960
f0100707:	68 b8 3d 10 f0       	push   $0xf0103db8
f010070c:	e8 09 23 00 00       	call   f0102a1a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100711:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100714:	b8 60 89 11 f0       	mov    $0xf0118960,%eax
f0100719:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010071e:	c1 f8 0a             	sar    $0xa,%eax
f0100721:	50                   	push   %eax
f0100722:	68 dc 3d 10 f0       	push   $0xf0103ddc
f0100727:	e8 ee 22 00 00       	call   f0102a1a <cprintf>
	return 0;
}
f010072c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100731:	c9                   	leave  
f0100732:	c3                   	ret    

f0100733 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100733:	f3 0f 1e fb          	endbr32 
f0100737:	55                   	push   %ebp
f0100738:	89 e5                	mov    %esp,%ebp
f010073a:	53                   	push   %ebx
f010073b:	83 ec 10             	sub    $0x10,%esp
    cprintf("stack backtrace:\n");
f010073e:	68 ae 3c 10 f0       	push   $0xf0103cae
f0100743:	e8 d2 22 00 00       	call   f0102a1a <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100748:	89 eb                	mov    %ebp,%ebx
    uint32_t *ebp = (uint32_t *)read_ebp();
    while (ebp != 0) {
f010074a:	83 c4 10             	add    $0x10,%esp
f010074d:	85 db                	test   %ebx,%ebx
f010074f:	74 24                	je     f0100775 <mon_backtrace+0x42>
        uint32_t arg2 = ebp[3];
        uint32_t arg3 = ebp[4];
        uint32_t arg4 = ebp[5];
        uint32_t arg5 = ebp[6];

        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",ebp, eip, arg1, arg2, arg3, arg4, arg5);
f0100751:	ff 73 18             	pushl  0x18(%ebx)
f0100754:	ff 73 14             	pushl  0x14(%ebx)
f0100757:	ff 73 10             	pushl  0x10(%ebx)
f010075a:	ff 73 0c             	pushl  0xc(%ebx)
f010075d:	ff 73 08             	pushl  0x8(%ebx)
f0100760:	ff 73 04             	pushl  0x4(%ebx)
f0100763:	53                   	push   %ebx
f0100764:	68 08 3e 10 f0       	push   $0xf0103e08
f0100769:	e8 ac 22 00 00       	call   f0102a1a <cprintf>

        ebp = (uint32_t *)*ebp;
f010076e:	8b 1b                	mov    (%ebx),%ebx
f0100770:	83 c4 20             	add    $0x20,%esp
f0100773:	eb d8                	jmp    f010074d <mon_backtrace+0x1a>
    }
    return 0;
}
f0100775:	b8 00 00 00 00       	mov    $0x0,%eax
f010077a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010077d:	c9                   	leave  
f010077e:	c3                   	ret    

f010077f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010077f:	f3 0f 1e fb          	endbr32 
f0100783:	55                   	push   %ebp
f0100784:	89 e5                	mov    %esp,%ebp
f0100786:	57                   	push   %edi
f0100787:	56                   	push   %esi
f0100788:	53                   	push   %ebx
f0100789:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010078c:	68 40 3e 10 f0       	push   $0xf0103e40
f0100791:	e8 84 22 00 00       	call   f0102a1a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100796:	c7 04 24 64 3e 10 f0 	movl   $0xf0103e64,(%esp)
f010079d:	e8 78 22 00 00       	call   f0102a1a <cprintf>
f01007a2:	83 c4 10             	add    $0x10,%esp
f01007a5:	e9 cf 00 00 00       	jmp    f0100879 <monitor+0xfa>
		while (*buf && strchr(WHITESPACE, *buf))
f01007aa:	83 ec 08             	sub    $0x8,%esp
f01007ad:	0f be c0             	movsbl %al,%eax
f01007b0:	50                   	push   %eax
f01007b1:	68 c4 3c 10 f0       	push   $0xf0103cc4
f01007b6:	e8 3f 2d 00 00       	call   f01034fa <strchr>
f01007bb:	83 c4 10             	add    $0x10,%esp
f01007be:	85 c0                	test   %eax,%eax
f01007c0:	74 6c                	je     f010082e <monitor+0xaf>
			*buf++ = 0;
f01007c2:	c6 03 00             	movb   $0x0,(%ebx)
f01007c5:	89 f7                	mov    %esi,%edi
f01007c7:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007ca:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01007cc:	0f b6 03             	movzbl (%ebx),%eax
f01007cf:	84 c0                	test   %al,%al
f01007d1:	75 d7                	jne    f01007aa <monitor+0x2b>
	argv[argc] = 0;
f01007d3:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01007da:	00 
	if (argc == 0)
f01007db:	85 f6                	test   %esi,%esi
f01007dd:	0f 84 96 00 00 00    	je     f0100879 <monitor+0xfa>
		if (strcmp(argv[0], commands[i].name) == 0)
f01007e3:	83 ec 08             	sub    $0x8,%esp
f01007e6:	68 7e 3c 10 f0       	push   $0xf0103c7e
f01007eb:	ff 75 a8             	pushl  -0x58(%ebp)
f01007ee:	e8 a1 2c 00 00       	call   f0103494 <strcmp>
f01007f3:	83 c4 10             	add    $0x10,%esp
f01007f6:	85 c0                	test   %eax,%eax
f01007f8:	0f 84 a7 00 00 00    	je     f01008a5 <monitor+0x126>
f01007fe:	83 ec 08             	sub    $0x8,%esp
f0100801:	68 8c 3c 10 f0       	push   $0xf0103c8c
f0100806:	ff 75 a8             	pushl  -0x58(%ebp)
f0100809:	e8 86 2c 00 00       	call   f0103494 <strcmp>
f010080e:	83 c4 10             	add    $0x10,%esp
f0100811:	85 c0                	test   %eax,%eax
f0100813:	0f 84 87 00 00 00    	je     f01008a0 <monitor+0x121>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100819:	83 ec 08             	sub    $0x8,%esp
f010081c:	ff 75 a8             	pushl  -0x58(%ebp)
f010081f:	68 e6 3c 10 f0       	push   $0xf0103ce6
f0100824:	e8 f1 21 00 00       	call   f0102a1a <cprintf>
	return 0;
f0100829:	83 c4 10             	add    $0x10,%esp
f010082c:	eb 4b                	jmp    f0100879 <monitor+0xfa>
		if (*buf == 0)
f010082e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100831:	74 a0                	je     f01007d3 <monitor+0x54>
		if (argc == MAXARGS-1) {
f0100833:	83 fe 0f             	cmp    $0xf,%esi
f0100836:	74 2f                	je     f0100867 <monitor+0xe8>
		argv[argc++] = buf;
f0100838:	8d 7e 01             	lea    0x1(%esi),%edi
f010083b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f010083f:	0f b6 03             	movzbl (%ebx),%eax
f0100842:	84 c0                	test   %al,%al
f0100844:	74 84                	je     f01007ca <monitor+0x4b>
f0100846:	83 ec 08             	sub    $0x8,%esp
f0100849:	0f be c0             	movsbl %al,%eax
f010084c:	50                   	push   %eax
f010084d:	68 c4 3c 10 f0       	push   $0xf0103cc4
f0100852:	e8 a3 2c 00 00       	call   f01034fa <strchr>
f0100857:	83 c4 10             	add    $0x10,%esp
f010085a:	85 c0                	test   %eax,%eax
f010085c:	0f 85 68 ff ff ff    	jne    f01007ca <monitor+0x4b>
			buf++;
f0100862:	83 c3 01             	add    $0x1,%ebx
f0100865:	eb d8                	jmp    f010083f <monitor+0xc0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100867:	83 ec 08             	sub    $0x8,%esp
f010086a:	6a 10                	push   $0x10
f010086c:	68 c9 3c 10 f0       	push   $0xf0103cc9
f0100871:	e8 a4 21 00 00       	call   f0102a1a <cprintf>
			return 0;
f0100876:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100879:	83 ec 0c             	sub    $0xc,%esp
f010087c:	68 c0 3c 10 f0       	push   $0xf0103cc0
f0100881:	e8 26 2a 00 00       	call   f01032ac <readline>
f0100886:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100888:	83 c4 10             	add    $0x10,%esp
f010088b:	85 c0                	test   %eax,%eax
f010088d:	74 ea                	je     f0100879 <monitor+0xfa>
	argv[argc] = 0;
f010088f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100896:	be 00 00 00 00       	mov    $0x0,%esi
f010089b:	e9 2c ff ff ff       	jmp    f01007cc <monitor+0x4d>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008a0:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f01008a5:	83 ec 04             	sub    $0x4,%esp
f01008a8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01008ab:	ff 75 08             	pushl  0x8(%ebp)
f01008ae:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008b1:	52                   	push   %edx
f01008b2:	56                   	push   %esi
f01008b3:	ff 14 85 94 3e 10 f0 	call   *-0xfefc16c(,%eax,4)
			if (runcmd(buf, tf) < 0)
f01008ba:	83 c4 10             	add    $0x10,%esp
f01008bd:	85 c0                	test   %eax,%eax
f01008bf:	79 b8                	jns    f0100879 <monitor+0xfa>
				break;
	}
}
f01008c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008c4:	5b                   	pop    %ebx
f01008c5:	5e                   	pop    %esi
f01008c6:	5f                   	pop    %edi
f01008c7:	5d                   	pop    %ebp
f01008c8:	c3                   	ret    

f01008c9 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01008c9:	55                   	push   %ebp
f01008ca:	89 e5                	mov    %esp,%ebp
f01008cc:	56                   	push   %esi
f01008cd:	53                   	push   %ebx
f01008ce:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01008d0:	83 ec 0c             	sub    $0xc,%esp
f01008d3:	50                   	push   %eax
f01008d4:	e8 ca 20 00 00       	call   f01029a3 <mc146818_read>
f01008d9:	89 c6                	mov    %eax,%esi
f01008db:	83 c3 01             	add    $0x1,%ebx
f01008de:	89 1c 24             	mov    %ebx,(%esp)
f01008e1:	e8 bd 20 00 00       	call   f01029a3 <mc146818_read>
f01008e6:	c1 e0 08             	shl    $0x8,%eax
f01008e9:	09 f0                	or     %esi,%eax
}
f01008eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008ee:	5b                   	pop    %ebx
f01008ef:	5e                   	pop    %esi
f01008f0:	5d                   	pop    %ebp
f01008f1:	c3                   	ret    

f01008f2 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01008f2:	55                   	push   %ebp
f01008f3:	89 e5                	mov    %esp,%ebp
f01008f5:	53                   	push   %ebx
f01008f6:	83 ec 04             	sub    $0x4,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01008f9:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f0100900:	74 5b                	je     f010095d <boot_alloc+0x6b>
	// LAB 2: Your code here.

	if (n == 0)
	{
		//need to return the address of the next free page without allocating anything
		return nextfree;
f0100902:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
	if (n == 0)
f0100908:	85 c0                	test   %eax,%eax
f010090a:	74 4a                	je     f0100956 <boot_alloc+0x64>
	}
	else if (n > 0)
	{
		//allocates enough pages of memory to hold 'n' number of bytes
		//don't initialize the memory
		if (pages_left == 0)
f010090c:	8b 15 38 85 11 f0    	mov    0xf0118538,%edx
f0100912:	85 d2                	test   %edx,%edx
f0100914:	74 66                	je     f010097c <boot_alloc+0x8a>
		else if (pages_left > 0)
		{
			//now that we have at least one page, we need to make sure there is enough space to accommodate all 'n' bytes
			//first need to find total number of pages requested
			//multiply the number of pages left with the size of each page, and 'n' must be <= to this value or else panic!
			uint32_t total_bytes_left = pages_left * PGSIZE;
f0100916:	89 d1                	mov    %edx,%ecx
f0100918:	c1 e1 0c             	shl    $0xc,%ecx
			if (n <= total_bytes_left)
f010091b:	39 c8                	cmp    %ecx,%eax
f010091d:	77 71                	ja     f0100990 <boot_alloc+0x9e>
			{
				//still need to keep track of how many pages were used
				result = nextfree;
f010091f:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
				nextfree = nextfree + ROUNDUP(n, PGSIZE);
f0100925:	05 ff 0f 00 00       	add    $0xfff,%eax
f010092a:	89 c1                	mov    %eax,%ecx
f010092c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100932:	01 d9                	add    %ebx,%ecx
f0100934:	89 0d 3c 85 11 f0    	mov    %ecx,0xf011853c
				uint32_t pages_used  = (nextfree - result) / PGSIZE;
f010093a:	c1 f8 0c             	sar    $0xc,%eax
				pages_left = pages_left - pages_used;
f010093d:	29 c2                	sub    %eax,%edx
f010093f:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
				cprintf("total pages left: %u\n", pages_left);
f0100945:	83 ec 08             	sub    $0x8,%esp
f0100948:	52                   	push   %edx
f0100949:	68 11 47 10 f0       	push   $0xf0104711
f010094e:	e8 c7 20 00 00       	call   f0102a1a <cprintf>
				return result;
f0100953:	83 c4 10             	add    $0x10,%esp
		}
	}

	return NULL;
	
}
f0100956:	89 d8                	mov    %ebx,%eax
f0100958:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010095b:	c9                   	leave  
f010095c:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010095d:	ba 5f 99 11 f0       	mov    $0xf011995f,%edx
f0100962:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100968:	89 15 3c 85 11 f0    	mov    %edx,0xf011853c
		pages_left = npages;
f010096e:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0100974:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
f010097a:	eb 86                	jmp    f0100902 <boot_alloc+0x10>
			panic("no more free pages left! n > 0");
f010097c:	83 ec 04             	sub    $0x4,%esp
f010097f:	68 a4 3e 10 f0       	push   $0xf0103ea4
f0100984:	6a 79                	push   $0x79
f0100986:	68 05 47 10 f0       	push   $0xf0104705
f010098b:	e8 ff f6 ff ff       	call   f010008f <_panic>
				panic("pages left, but 'n' tried allocating too much!");
f0100990:	83 ec 04             	sub    $0x4,%esp
f0100993:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0100998:	68 8d 00 00 00       	push   $0x8d
f010099d:	68 05 47 10 f0       	push   $0xf0104705
f01009a2:	e8 e8 f6 ff ff       	call   f010008f <_panic>

f01009a7 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009a7:	89 d1                	mov    %edx,%ecx
f01009a9:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009ac:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009af:	a8 01                	test   $0x1,%al
f01009b1:	74 51                	je     f0100a04 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009b3:	89 c1                	mov    %eax,%ecx
f01009b5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009bb:	c1 e8 0c             	shr    $0xc,%eax
f01009be:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01009c4:	73 23                	jae    f01009e9 <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f01009c6:	c1 ea 0c             	shr    $0xc,%edx
f01009c9:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009cf:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009d6:	89 d0                	mov    %edx,%eax
f01009d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009dd:	f6 c2 01             	test   $0x1,%dl
f01009e0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009e5:	0f 44 c2             	cmove  %edx,%eax
f01009e8:	c3                   	ret    
{
f01009e9:	55                   	push   %ebp
f01009ea:	89 e5                	mov    %esp,%ebp
f01009ec:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009ef:	51                   	push   %ecx
f01009f0:	68 f4 3e 10 f0       	push   $0xf0103ef4
f01009f5:	68 9c 03 00 00       	push   $0x39c
f01009fa:	68 05 47 10 f0       	push   $0xf0104705
f01009ff:	e8 8b f6 ff ff       	call   f010008f <_panic>
		return ~0;
f0100a04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100a09:	c3                   	ret    

f0100a0a <check_page_free_list>:
{
f0100a0a:	55                   	push   %ebp
f0100a0b:	89 e5                	mov    %esp,%ebp
f0100a0d:	57                   	push   %edi
f0100a0e:	56                   	push   %esi
f0100a0f:	53                   	push   %ebx
f0100a10:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a13:	84 c0                	test   %al,%al
f0100a15:	0f 85 52 02 00 00    	jne    f0100c6d <check_page_free_list+0x263>
	if (!page_free_list)
f0100a1b:	83 3d 40 85 11 f0 00 	cmpl   $0x0,0xf0118540
f0100a22:	74 0d                	je     f0100a31 <check_page_free_list+0x27>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a24:	be 00 04 00 00       	mov    $0x400,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a29:	8b 1d 40 85 11 f0    	mov    0xf0118540,%ebx
f0100a2f:	eb 2b                	jmp    f0100a5c <check_page_free_list+0x52>
		panic("'page_free_list' is a null pointer!");
f0100a31:	83 ec 04             	sub    $0x4,%esp
f0100a34:	68 18 3f 10 f0       	push   $0xf0103f18
f0100a39:	68 dd 02 00 00       	push   $0x2dd
f0100a3e:	68 05 47 10 f0       	push   $0xf0104705
f0100a43:	e8 47 f6 ff ff       	call   f010008f <_panic>
f0100a48:	50                   	push   %eax
f0100a49:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0100a4e:	6a 52                	push   $0x52
f0100a50:	68 27 47 10 f0       	push   $0xf0104727
f0100a55:	e8 35 f6 ff ff       	call   f010008f <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a5a:	8b 1b                	mov    (%ebx),%ebx
f0100a5c:	85 db                	test   %ebx,%ebx
f0100a5e:	74 41                	je     f0100aa1 <check_page_free_list+0x97>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a60:	89 d8                	mov    %ebx,%eax
f0100a62:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100a68:	c1 f8 03             	sar    $0x3,%eax
f0100a6b:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a6e:	89 c2                	mov    %eax,%edx
f0100a70:	c1 ea 16             	shr    $0x16,%edx
f0100a73:	39 f2                	cmp    %esi,%edx
f0100a75:	73 e3                	jae    f0100a5a <check_page_free_list+0x50>
	if (PGNUM(pa) >= npages)
f0100a77:	89 c2                	mov    %eax,%edx
f0100a79:	c1 ea 0c             	shr    $0xc,%edx
f0100a7c:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0100a82:	73 c4                	jae    f0100a48 <check_page_free_list+0x3e>
			memset(page2kva(pp), 0x97, 128);
f0100a84:	83 ec 04             	sub    $0x4,%esp
f0100a87:	68 80 00 00 00       	push   $0x80
f0100a8c:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100a91:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a96:	50                   	push   %eax
f0100a97:	e8 a3 2a 00 00       	call   f010353f <memset>
f0100a9c:	83 c4 10             	add    $0x10,%esp
f0100a9f:	eb b9                	jmp    f0100a5a <check_page_free_list+0x50>
	first_free_page = (char *) boot_alloc(0);
f0100aa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aa6:	e8 47 fe ff ff       	call   f01008f2 <boot_alloc>
f0100aab:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aae:	8b 15 40 85 11 f0    	mov    0xf0118540,%edx
		assert(pp >= pages);
f0100ab4:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
		assert(pp < pages + npages);
f0100aba:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100abf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ac2:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ac5:	bf 00 00 00 00       	mov    $0x0,%edi
f0100aca:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100acd:	e9 c8 00 00 00       	jmp    f0100b9a <check_page_free_list+0x190>
		assert(pp >= pages);
f0100ad2:	68 35 47 10 f0       	push   $0xf0104735
f0100ad7:	68 41 47 10 f0       	push   $0xf0104741
f0100adc:	68 f7 02 00 00       	push   $0x2f7
f0100ae1:	68 05 47 10 f0       	push   $0xf0104705
f0100ae6:	e8 a4 f5 ff ff       	call   f010008f <_panic>
		assert(pp < pages + npages);
f0100aeb:	68 56 47 10 f0       	push   $0xf0104756
f0100af0:	68 41 47 10 f0       	push   $0xf0104741
f0100af5:	68 f8 02 00 00       	push   $0x2f8
f0100afa:	68 05 47 10 f0       	push   $0xf0104705
f0100aff:	e8 8b f5 ff ff       	call   f010008f <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b04:	68 3c 3f 10 f0       	push   $0xf0103f3c
f0100b09:	68 41 47 10 f0       	push   $0xf0104741
f0100b0e:	68 f9 02 00 00       	push   $0x2f9
f0100b13:	68 05 47 10 f0       	push   $0xf0104705
f0100b18:	e8 72 f5 ff ff       	call   f010008f <_panic>
		assert(page2pa(pp) != 0);
f0100b1d:	68 6a 47 10 f0       	push   $0xf010476a
f0100b22:	68 41 47 10 f0       	push   $0xf0104741
f0100b27:	68 fc 02 00 00       	push   $0x2fc
f0100b2c:	68 05 47 10 f0       	push   $0xf0104705
f0100b31:	e8 59 f5 ff ff       	call   f010008f <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b36:	68 7b 47 10 f0       	push   $0xf010477b
f0100b3b:	68 41 47 10 f0       	push   $0xf0104741
f0100b40:	68 fd 02 00 00       	push   $0x2fd
f0100b45:	68 05 47 10 f0       	push   $0xf0104705
f0100b4a:	e8 40 f5 ff ff       	call   f010008f <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b4f:	68 70 3f 10 f0       	push   $0xf0103f70
f0100b54:	68 41 47 10 f0       	push   $0xf0104741
f0100b59:	68 fe 02 00 00       	push   $0x2fe
f0100b5e:	68 05 47 10 f0       	push   $0xf0104705
f0100b63:	e8 27 f5 ff ff       	call   f010008f <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b68:	68 94 47 10 f0       	push   $0xf0104794
f0100b6d:	68 41 47 10 f0       	push   $0xf0104741
f0100b72:	68 ff 02 00 00       	push   $0x2ff
f0100b77:	68 05 47 10 f0       	push   $0xf0104705
f0100b7c:	e8 0e f5 ff ff       	call   f010008f <_panic>
	if (PGNUM(pa) >= npages)
f0100b81:	89 c3                	mov    %eax,%ebx
f0100b83:	c1 eb 0c             	shr    $0xc,%ebx
f0100b86:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100b89:	76 65                	jbe    f0100bf0 <check_page_free_list+0x1e6>
	return (void *)(pa + KERNBASE);
f0100b8b:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100b90:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100b93:	77 6d                	ja     f0100c02 <check_page_free_list+0x1f8>
			++nfree_extmem;
f0100b95:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b98:	8b 12                	mov    (%edx),%edx
f0100b9a:	85 d2                	test   %edx,%edx
f0100b9c:	74 7d                	je     f0100c1b <check_page_free_list+0x211>
		assert(pp >= pages);
f0100b9e:	39 d1                	cmp    %edx,%ecx
f0100ba0:	0f 87 2c ff ff ff    	ja     f0100ad2 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100ba6:	39 d6                	cmp    %edx,%esi
f0100ba8:	0f 86 3d ff ff ff    	jbe    f0100aeb <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bae:	89 d0                	mov    %edx,%eax
f0100bb0:	29 c8                	sub    %ecx,%eax
f0100bb2:	a8 07                	test   $0x7,%al
f0100bb4:	0f 85 4a ff ff ff    	jne    f0100b04 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100bba:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100bbd:	c1 e0 0c             	shl    $0xc,%eax
f0100bc0:	0f 84 57 ff ff ff    	je     f0100b1d <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bcb:	0f 84 65 ff ff ff    	je     f0100b36 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bd1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bd6:	0f 84 73 ff ff ff    	je     f0100b4f <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bdc:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100be1:	74 85                	je     f0100b68 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100be3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100be8:	77 97                	ja     f0100b81 <check_page_free_list+0x177>
			++nfree_basemem;
f0100bea:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f0100bee:	eb a8                	jmp    f0100b98 <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bf0:	50                   	push   %eax
f0100bf1:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0100bf6:	6a 52                	push   $0x52
f0100bf8:	68 27 47 10 f0       	push   $0xf0104727
f0100bfd:	e8 8d f4 ff ff       	call   f010008f <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c02:	68 94 3f 10 f0       	push   $0xf0103f94
f0100c07:	68 41 47 10 f0       	push   $0xf0104741
f0100c0c:	68 00 03 00 00       	push   $0x300
f0100c11:	68 05 47 10 f0       	push   $0xf0104705
f0100c16:	e8 74 f4 ff ff       	call   f010008f <_panic>
f0100c1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100c1e:	85 db                	test   %ebx,%ebx
f0100c20:	7e 19                	jle    f0100c3b <check_page_free_list+0x231>
	assert(nfree_extmem > 0);
f0100c22:	85 ff                	test   %edi,%edi
f0100c24:	7e 2e                	jle    f0100c54 <check_page_free_list+0x24a>
	cprintf("check_page_free_list() succeeded!\n");
f0100c26:	83 ec 0c             	sub    $0xc,%esp
f0100c29:	68 dc 3f 10 f0       	push   $0xf0103fdc
f0100c2e:	e8 e7 1d 00 00       	call   f0102a1a <cprintf>
}
f0100c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c36:	5b                   	pop    %ebx
f0100c37:	5e                   	pop    %esi
f0100c38:	5f                   	pop    %edi
f0100c39:	5d                   	pop    %ebp
f0100c3a:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100c3b:	68 ae 47 10 f0       	push   $0xf01047ae
f0100c40:	68 41 47 10 f0       	push   $0xf0104741
f0100c45:	68 08 03 00 00       	push   $0x308
f0100c4a:	68 05 47 10 f0       	push   $0xf0104705
f0100c4f:	e8 3b f4 ff ff       	call   f010008f <_panic>
	assert(nfree_extmem > 0);
f0100c54:	68 c0 47 10 f0       	push   $0xf01047c0
f0100c59:	68 41 47 10 f0       	push   $0xf0104741
f0100c5e:	68 09 03 00 00       	push   $0x309
f0100c63:	68 05 47 10 f0       	push   $0xf0104705
f0100c68:	e8 22 f4 ff ff       	call   f010008f <_panic>
	if (!page_free_list)
f0100c6d:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f0100c72:	85 c0                	test   %eax,%eax
f0100c74:	0f 84 b7 fd ff ff    	je     f0100a31 <check_page_free_list+0x27>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c7a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c7d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c80:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c83:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100c86:	89 c2                	mov    %eax,%edx
f0100c88:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c8e:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c94:	0f 95 c2             	setne  %dl
f0100c97:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c9a:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c9e:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ca0:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca4:	8b 00                	mov    (%eax),%eax
f0100ca6:	85 c0                	test   %eax,%eax
f0100ca8:	75 dc                	jne    f0100c86 <check_page_free_list+0x27c>
		*tp[1] = 0;
f0100caa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100cb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cb9:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cbe:	a3 40 85 11 f0       	mov    %eax,0xf0118540
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cc3:	be 01 00 00 00       	mov    $0x1,%esi
f0100cc8:	e9 5c fd ff ff       	jmp    f0100a29 <check_page_free_list+0x1f>

f0100ccd <page_init>:
{
f0100ccd:	f3 0f 1e fb          	endbr32 
f0100cd1:	55                   	push   %ebp
f0100cd2:	89 e5                	mov    %esp,%ebp
f0100cd4:	56                   	push   %esi
f0100cd5:	53                   	push   %ebx
	pages[0].pp_ref = 1; //now there's at least one reference to this memory location, so we shouldn't touch it until the application frees it
f0100cd6:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0100cdb:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0100ce1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	for (i = 1; i < npages; i++) 
f0100ce7:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100cec:	eb 28                	jmp    f0100d16 <page_init+0x49>
f0100cee:	8d b3 60 ff 0f 00    	lea    0xfff60(%ebx),%esi
f0100cf4:	c1 e6 0c             	shl    $0xc,%esi
		else if ((IO_hole_start_address <= current_physical_address ) && (current_physical_address < IO_hole_end_address))
f0100cf7:	81 fe ff ff 05 00    	cmp    $0x5ffff,%esi
f0100cfd:	77 55                	ja     f0100d54 <page_init+0x87>
			pages[i].pp_ref = 1;
f0100cff:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0100d04:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100d07:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100d0d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	for (i = 1; i < npages; i++) 
f0100d13:	83 c3 01             	add    $0x1,%ebx
f0100d16:	39 1d 68 89 11 f0    	cmp    %ebx,0xf0118968
f0100d1c:	0f 86 aa 00 00 00    	jbe    f0100dcc <page_init+0xff>
		if (i < npages_basemem)
f0100d22:	39 1d 44 85 11 f0    	cmp    %ebx,0xf0118544
f0100d28:	76 c4                	jbe    f0100cee <page_init+0x21>
f0100d2a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0100d31:	89 c2                	mov    %eax,%edx
f0100d33:	03 15 70 89 11 f0    	add    0xf0118970,%edx
f0100d39:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100d3f:	8b 0d 40 85 11 f0    	mov    0xf0118540,%ecx
f0100d45:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i]; 
f0100d47:	03 05 70 89 11 f0    	add    0xf0118970,%eax
f0100d4d:	a3 40 85 11 f0       	mov    %eax,0xf0118540
f0100d52:	eb bf                	jmp    f0100d13 <page_init+0x46>
		else if (current_physical_address < PADDR(boot_alloc(0)))
f0100d54:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d59:	e8 94 fb ff ff       	call   f01008f2 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100d5e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d63:	76 25                	jbe    f0100d8a <page_init+0xbd>
	return (physaddr_t)kva - KERNBASE;
f0100d65:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d6a:	81 c6 00 00 0a 00    	add    $0xa0000,%esi
f0100d70:	39 f0                	cmp    %esi,%eax
f0100d72:	76 2b                	jbe    f0100d9f <page_init+0xd2>
                        pages[i].pp_ref = 1;
f0100d74:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0100d79:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100d7c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100d82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d88:	eb 89                	jmp    f0100d13 <page_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d8a:	50                   	push   %eax
f0100d8b:	68 00 40 10 f0       	push   $0xf0104000
f0100d90:	68 7f 01 00 00       	push   $0x17f
f0100d95:	68 05 47 10 f0       	push   $0xf0104705
f0100d9a:	e8 f0 f2 ff ff       	call   f010008f <_panic>
f0100d9f:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
                        pages[i].pp_ref = 0;
f0100da6:	89 c2                	mov    %eax,%edx
f0100da8:	03 15 70 89 11 f0    	add    0xf0118970,%edx
f0100dae:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
                        pages[i].pp_link = page_free_list;
f0100db4:	8b 0d 40 85 11 f0    	mov    0xf0118540,%ecx
f0100dba:	89 0a                	mov    %ecx,(%edx)
                        page_free_list = &pages[i];
f0100dbc:	03 05 70 89 11 f0    	add    0xf0118970,%eax
f0100dc2:	a3 40 85 11 f0       	mov    %eax,0xf0118540
f0100dc7:	e9 47 ff ff ff       	jmp    f0100d13 <page_init+0x46>
}
f0100dcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100dcf:	5b                   	pop    %ebx
f0100dd0:	5e                   	pop    %esi
f0100dd1:	5d                   	pop    %ebp
f0100dd2:	c3                   	ret    

f0100dd3 <page_alloc>:
{
f0100dd3:	f3 0f 1e fb          	endbr32 
f0100dd7:	55                   	push   %ebp
f0100dd8:	89 e5                	mov    %esp,%ebp
f0100dda:	53                   	push   %ebx
f0100ddb:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list == NULL)
f0100dde:	8b 1d 40 85 11 f0    	mov    0xf0118540,%ebx
f0100de4:	85 db                	test   %ebx,%ebx
f0100de6:	74 13                	je     f0100dfb <page_alloc+0x28>
	page_free_list = page_free_list->pp_link;
f0100de8:	8b 03                	mov    (%ebx),%eax
f0100dea:	a3 40 85 11 f0       	mov    %eax,0xf0118540
	returnThisPointer->pp_link = NULL;
f0100def:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f0100df5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100df9:	75 07                	jne    f0100e02 <page_alloc+0x2f>
}
f0100dfb:	89 d8                	mov    %ebx,%eax
f0100dfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e00:	c9                   	leave  
f0100e01:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100e02:	89 d8                	mov    %ebx,%eax
f0100e04:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100e0a:	c1 f8 03             	sar    $0x3,%eax
f0100e0d:	89 c2                	mov    %eax,%edx
f0100e0f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100e12:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100e17:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0100e1d:	73 1b                	jae    f0100e3a <page_alloc+0x67>
		memset(page2kva(returnThisPointer), '\0', PGSIZE);
f0100e1f:	83 ec 04             	sub    $0x4,%esp
f0100e22:	68 00 10 00 00       	push   $0x1000
f0100e27:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100e29:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100e2f:	52                   	push   %edx
f0100e30:	e8 0a 27 00 00       	call   f010353f <memset>
f0100e35:	83 c4 10             	add    $0x10,%esp
f0100e38:	eb c1                	jmp    f0100dfb <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e3a:	52                   	push   %edx
f0100e3b:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0100e40:	6a 52                	push   $0x52
f0100e42:	68 27 47 10 f0       	push   $0xf0104727
f0100e47:	e8 43 f2 ff ff       	call   f010008f <_panic>

f0100e4c <page_free>:
{
f0100e4c:	f3 0f 1e fb          	endbr32 
f0100e50:	55                   	push   %ebp
f0100e51:	89 e5                	mov    %esp,%ebp
f0100e53:	83 ec 08             	sub    $0x8,%esp
f0100e56:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0)
f0100e59:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e5e:	75 14                	jne    f0100e74 <page_free+0x28>
	if (pp->pp_link != NULL)
f0100e60:	83 38 00             	cmpl   $0x0,(%eax)
f0100e63:	75 26                	jne    f0100e8b <page_free+0x3f>
	pp->pp_link = page_free_list; //point new free page to head of linked list that has all free pages
f0100e65:	8b 15 40 85 11 f0    	mov    0xf0118540,%edx
f0100e6b:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e6d:	a3 40 85 11 f0       	mov    %eax,0xf0118540
}
f0100e72:	c9                   	leave  
f0100e73:	c3                   	ret    
		panic("inside page_free() -> there are references to this page, so cannot free!!");
f0100e74:	83 ec 04             	sub    $0x4,%esp
f0100e77:	68 24 40 10 f0       	push   $0xf0104024
f0100e7c:	68 bb 01 00 00       	push   $0x1bb
f0100e81:	68 05 47 10 f0       	push   $0xf0104705
f0100e86:	e8 04 f2 ff ff       	call   f010008f <_panic>
		panic("inside page_free -> pp->pp_link is NOT NULL!");
f0100e8b:	83 ec 04             	sub    $0x4,%esp
f0100e8e:	68 70 40 10 f0       	push   $0xf0104070
f0100e93:	68 bf 01 00 00       	push   $0x1bf
f0100e98:	68 05 47 10 f0       	push   $0xf0104705
f0100e9d:	e8 ed f1 ff ff       	call   f010008f <_panic>

f0100ea2 <page_decref>:
{
f0100ea2:	f3 0f 1e fb          	endbr32 
f0100ea6:	55                   	push   %ebp
f0100ea7:	89 e5                	mov    %esp,%ebp
f0100ea9:	83 ec 08             	sub    $0x8,%esp
f0100eac:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100eaf:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100eb3:	83 e8 01             	sub    $0x1,%eax
f0100eb6:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100eba:	66 85 c0             	test   %ax,%ax
f0100ebd:	74 02                	je     f0100ec1 <page_decref+0x1f>
}
f0100ebf:	c9                   	leave  
f0100ec0:	c3                   	ret    
		page_free(pp);
f0100ec1:	83 ec 0c             	sub    $0xc,%esp
f0100ec4:	52                   	push   %edx
f0100ec5:	e8 82 ff ff ff       	call   f0100e4c <page_free>
f0100eca:	83 c4 10             	add    $0x10,%esp
}
f0100ecd:	eb f0                	jmp    f0100ebf <page_decref+0x1d>

f0100ecf <pgdir_walk>:
{	
f0100ecf:	f3 0f 1e fb          	endbr32 
f0100ed3:	55                   	push   %ebp
f0100ed4:	89 e5                	mov    %esp,%ebp
f0100ed6:	57                   	push   %edi
f0100ed7:	56                   	push   %esi
f0100ed8:	53                   	push   %ebx
f0100ed9:	83 ec 0c             	sub    $0xc,%esp
f0100edc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32_t page_directory_index = (uint32_t) PDX(va);
f0100edf:	89 de                	mov    %ebx,%esi
f0100ee1:	c1 ee 16             	shr    $0x16,%esi
	if (((pgdir[page_directory_index] & PTE_P) == 0) && (create == 0 )) // 0 if entry can NOT be used  
f0100ee4:	c1 e6 02             	shl    $0x2,%esi
f0100ee7:	03 75 08             	add    0x8(%ebp),%esi
f0100eea:	8b 06                	mov    (%esi),%eax
f0100eec:	89 c1                	mov    %eax,%ecx
f0100eee:	83 e1 01             	and    $0x1,%ecx
f0100ef1:	0f 94 c2             	sete   %dl
f0100ef4:	89 d7                	mov    %edx,%edi
f0100ef6:	8b 55 10             	mov    0x10(%ebp),%edx
f0100ef9:	09 ca                	or     %ecx,%edx
f0100efb:	0f 84 ee 00 00 00    	je     f0100fef <pgdir_walk+0x120>
	else if (((pgdir[page_directory_index] & PTE_P) == 0) && (create == 1 )) //doesn't exist and you want to create it
f0100f01:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0100f05:	75 06                	jne    f0100f0d <pgdir_walk+0x3e>
f0100f07:	89 fa                	mov    %edi,%edx
f0100f09:	84 d2                	test   %dl,%dl
f0100f0b:	75 33                	jne    f0100f40 <pgdir_walk+0x71>
	else if (((pgdir[page_directory_index] & PTE_P) == 1))
f0100f0d:	85 c9                	test   %ecx,%ecx
f0100f0f:	0f 84 9d 00 00 00    	je     f0100fb2 <pgdir_walk+0xe3>
		return &(((pte_t *) KADDR(pgdir[PDX(va)] & ~0xFFF))[PTX(va)]);
f0100f15:	89 c2                	mov    %eax,%edx
f0100f17:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0100f1d:	c1 e8 0c             	shr    $0xc,%eax
f0100f20:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0100f26:	73 75                	jae    f0100f9d <pgdir_walk+0xce>
f0100f28:	c1 eb 0a             	shr    $0xa,%ebx
f0100f2b:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f31:	8d 84 1a 00 00 00 f0 	lea    -0x10000000(%edx,%ebx,1),%eax
}
f0100f38:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f3b:	5b                   	pop    %ebx
f0100f3c:	5e                   	pop    %esi
f0100f3d:	5f                   	pop    %edi
f0100f3e:	5d                   	pop    %ebp
f0100f3f:	c3                   	ret    
		struct PageInfo *newPage = page_alloc(ALLOC_ZERO); //**********NOTE: ALLOC_ZERO IS NOT ZERO!!! ITS A VALUE OF 1 BECAUSE ITS A FLAG!!
f0100f40:	83 ec 0c             	sub    $0xc,%esp
f0100f43:	6a 01                	push   $0x1
f0100f45:	e8 89 fe ff ff       	call   f0100dd3 <page_alloc>
        	if (newPage == NULL)
f0100f4a:	83 c4 10             	add    $0x10,%esp
f0100f4d:	85 c0                	test   %eax,%eax
f0100f4f:	74 e7                	je     f0100f38 <pgdir_walk+0x69>
        	newPage->pp_ref += 1;
f0100f51:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0100f56:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100f5c:	c1 f8 03             	sar    $0x3,%eax
f0100f5f:	c1 e0 0c             	shl    $0xc,%eax
		physaddr_t phys_addr_of_newPage_struct = page2pa(newPage) | PTE_P | PTE_W | PTE_U; //was getting asserting error so added PTE_U
f0100f62:	89 c2                	mov    %eax,%edx
f0100f64:	83 ca 07             	or     $0x7,%edx
f0100f67:	89 16                	mov    %edx,(%esi)
	if (PGNUM(pa) >= npages)
f0100f69:	89 c2                	mov    %eax,%edx
f0100f6b:	c1 ea 0c             	shr    $0xc,%edx
f0100f6e:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0100f74:	73 12                	jae    f0100f88 <pgdir_walk+0xb9>
		return &(((pte_t *) KADDR(pgdir[PDX(va)] & ~0xFFF))[PTX(va)]); //ignore the last 0xFFF(12) permission bits (figure 5-10)
f0100f76:	c1 eb 0a             	shr    $0xa,%ebx
f0100f79:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f7f:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100f86:	eb b0                	jmp    f0100f38 <pgdir_walk+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f88:	50                   	push   %eax
f0100f89:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0100f8e:	68 05 02 00 00       	push   $0x205
f0100f93:	68 05 47 10 f0       	push   $0xf0104705
f0100f98:	e8 f2 f0 ff ff       	call   f010008f <_panic>
f0100f9d:	52                   	push   %edx
f0100f9e:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0100fa3:	68 0b 02 00 00       	push   $0x20b
f0100fa8:	68 05 47 10 f0       	push   $0xf0104705
f0100fad:	e8 dd f0 ff ff       	call   f010008f <_panic>
	return &(((pte_t *) KADDR(pgdir[PDX(va)] & ~0xFFF))[PTX(va)]);
f0100fb2:	89 c2                	mov    %eax,%edx
f0100fb4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0100fba:	c1 e8 0c             	shr    $0xc,%eax
f0100fbd:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0100fc3:	73 15                	jae    f0100fda <pgdir_walk+0x10b>
f0100fc5:	c1 eb 0a             	shr    $0xa,%ebx
f0100fc8:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100fce:	8d 84 1a 00 00 00 f0 	lea    -0x10000000(%edx,%ebx,1),%eax
f0100fd5:	e9 5e ff ff ff       	jmp    f0100f38 <pgdir_walk+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fda:	52                   	push   %edx
f0100fdb:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0100fe0:	68 0e 02 00 00       	push   $0x20e
f0100fe5:	68 05 47 10 f0       	push   $0xf0104705
f0100fea:	e8 a0 f0 ff ff       	call   f010008f <_panic>
		return NULL;
f0100fef:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff4:	e9 3f ff ff ff       	jmp    f0100f38 <pgdir_walk+0x69>

f0100ff9 <boot_map_region>:
{
f0100ff9:	55                   	push   %ebp
f0100ffa:	89 e5                	mov    %esp,%ebp
f0100ffc:	57                   	push   %edi
f0100ffd:	56                   	push   %esi
f0100ffe:	53                   	push   %ebx
f0100fff:	83 ec 1c             	sub    $0x1c,%esp
f0101002:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101005:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010100b:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f010100e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (int current_page = 0; current_page < size/PGSIZE; current_page++)
f0101011:	89 d6                	mov    %edx,%esi
f0101013:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101016:	29 d7                	sub    %edx,%edi
f0101018:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010101b:	74 24                	je     f0101041 <boot_map_region+0x48>
f010101d:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
		pte_t *pte_ptr = pgdir_walk(pgdir, current_virtual_address, create);
f0101020:	83 ec 04             	sub    $0x4,%esp
f0101023:	6a 01                	push   $0x1
f0101025:	56                   	push   %esi
f0101026:	ff 75 e0             	pushl  -0x20(%ebp)
f0101029:	e8 a1 fe ff ff       	call   f0100ecf <pgdir_walk>
		*pte_ptr = current_physical_address | perm | PTE_P;
f010102e:	0b 5d 0c             	or     0xc(%ebp),%ebx
f0101031:	83 cb 01             	or     $0x1,%ebx
f0101034:	89 18                	mov    %ebx,(%eax)
f0101036:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010103c:	83 c4 10             	add    $0x10,%esp
f010103f:	eb d7                	jmp    f0101018 <boot_map_region+0x1f>
}
f0101041:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101044:	5b                   	pop    %ebx
f0101045:	5e                   	pop    %esi
f0101046:	5f                   	pop    %edi
f0101047:	5d                   	pop    %ebp
f0101048:	c3                   	ret    

f0101049 <page_lookup>:
{
f0101049:	f3 0f 1e fb          	endbr32 
f010104d:	55                   	push   %ebp
f010104e:	89 e5                	mov    %esp,%ebp
f0101050:	53                   	push   %ebx
f0101051:	83 ec 08             	sub    $0x8,%esp
f0101054:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* page_table_entry_ptr = pgdir_walk(pgdir, va, create);
f0101057:	6a 00                	push   $0x0
f0101059:	ff 75 0c             	pushl  0xc(%ebp)
f010105c:	ff 75 08             	pushl  0x8(%ebp)
f010105f:	e8 6b fe ff ff       	call   f0100ecf <pgdir_walk>
	if (page_table_entry_ptr == NULL)  //NOTE: page_table_entry_ptr CAN be NULL because there was no memory left to allocate!
f0101064:	83 c4 10             	add    $0x10,%esp
f0101067:	85 c0                	test   %eax,%eax
f0101069:	74 3c                	je     f01010a7 <page_lookup+0x5e>
	if (((*page_table_entry_ptr) & PTE_P) == 0)
f010106b:	8b 10                	mov    (%eax),%edx
f010106d:	f6 c2 01             	test   $0x1,%dl
f0101070:	74 39                	je     f01010ab <page_lookup+0x62>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101072:	c1 ea 0c             	shr    $0xc,%edx
f0101075:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f010107b:	73 16                	jae    f0101093 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010107d:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
f0101083:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	if (pte_store != 0)
f0101086:	85 db                	test   %ebx,%ebx
f0101088:	74 02                	je     f010108c <page_lookup+0x43>
		*pte_store = page_table_entry_ptr; //you want to modify the incoming pointer, not the value at the address	
f010108a:	89 03                	mov    %eax,(%ebx)
}
f010108c:	89 d0                	mov    %edx,%eax
f010108e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101091:	c9                   	leave  
f0101092:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101093:	83 ec 04             	sub    $0x4,%esp
f0101096:	68 a0 40 10 f0       	push   $0xf01040a0
f010109b:	6a 4b                	push   $0x4b
f010109d:	68 27 47 10 f0       	push   $0xf0104727
f01010a2:	e8 e8 ef ff ff       	call   f010008f <_panic>
		return NULL;
f01010a7:	89 c2                	mov    %eax,%edx
f01010a9:	eb e1                	jmp    f010108c <page_lookup+0x43>
		return NULL;
f01010ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01010b0:	eb da                	jmp    f010108c <page_lookup+0x43>

f01010b2 <page_remove>:
{
f01010b2:	f3 0f 1e fb          	endbr32 
f01010b6:	55                   	push   %ebp
f01010b7:	89 e5                	mov    %esp,%ebp
f01010b9:	53                   	push   %ebx
f01010ba:	83 ec 18             	sub    $0x18,%esp
f01010bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pagey = page_lookup(pgdir, va, &pte);
f01010c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010c3:	50                   	push   %eax
f01010c4:	53                   	push   %ebx
f01010c5:	ff 75 08             	pushl  0x8(%ebp)
f01010c8:	e8 7c ff ff ff       	call   f0101049 <page_lookup>
	if (pagey == NULL)
f01010cd:	83 c4 10             	add    $0x10,%esp
f01010d0:	85 c0                	test   %eax,%eax
f01010d2:	74 18                	je     f01010ec <page_remove+0x3a>
	*pte = 0;
f01010d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01010d7:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(pagey);
f01010dd:	83 ec 0c             	sub    $0xc,%esp
f01010e0:	50                   	push   %eax
f01010e1:	e8 bc fd ff ff       	call   f0100ea2 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010e6:	0f 01 3b             	invlpg (%ebx)
f01010e9:	83 c4 10             	add    $0x10,%esp
}
f01010ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010ef:	c9                   	leave  
f01010f0:	c3                   	ret    

f01010f1 <page_insert>:
{	
f01010f1:	f3 0f 1e fb          	endbr32 
f01010f5:	55                   	push   %ebp
f01010f6:	89 e5                	mov    %esp,%ebp
f01010f8:	57                   	push   %edi
f01010f9:	56                   	push   %esi
f01010fa:	53                   	push   %ebx
f01010fb:	83 ec 10             	sub    $0x10,%esp
f01010fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101101:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, create);
f0101104:	6a 01                	push   $0x1
f0101106:	57                   	push   %edi
f0101107:	ff 75 08             	pushl  0x8(%ebp)
f010110a:	e8 c0 fd ff ff       	call   f0100ecf <pgdir_walk>
	if (pte == NULL) //remember: pte can be NULL if a page couldn't be allocated because there wasn't enough free memory
f010110f:	83 c4 10             	add    $0x10,%esp
f0101112:	85 c0                	test   %eax,%eax
f0101114:	74 57                	je     f010116d <page_insert+0x7c>
f0101116:	89 c6                	mov    %eax,%esi
	pp->pp_ref += 1; //a new reference to the page table entry *pte was created, so must update the number of references to it 
f0101118:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (((*pte) & PTE_P) == 1) //page already mapped; i think i should use permission bits? 
f010111d:	f6 00 01             	testb  $0x1,(%eax)
f0101120:	75 21                	jne    f0101143 <page_insert+0x52>
	return (pp - pages) << PGSHIFT;
f0101122:	2b 1d 70 89 11 f0    	sub    0xf0118970,%ebx
f0101128:	c1 fb 03             	sar    $0x3,%ebx
f010112b:	c1 e3 0c             	shl    $0xc,%ebx
		*pte = page2pa(pp) | perm | PTE_P;
f010112e:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101131:	83 cb 01             	or     $0x1,%ebx
f0101134:	89 18                	mov    %ebx,(%eax)
		return 0;	
f0101136:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010113b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010113e:	5b                   	pop    %ebx
f010113f:	5e                   	pop    %esi
f0101140:	5f                   	pop    %edi
f0101141:	5d                   	pop    %ebp
f0101142:	c3                   	ret    
		page_remove(pgdir, va); //remove it no matter what? 'elegant solution'. Also the invalidation of the TLB happens in page_remove()
f0101143:	83 ec 08             	sub    $0x8,%esp
f0101146:	57                   	push   %edi
f0101147:	ff 75 08             	pushl  0x8(%ebp)
f010114a:	e8 63 ff ff ff       	call   f01010b2 <page_remove>
f010114f:	2b 1d 70 89 11 f0    	sub    0xf0118970,%ebx
f0101155:	c1 fb 03             	sar    $0x3,%ebx
f0101158:	c1 e3 0c             	shl    $0xc,%ebx
		*pte = page2pa(pp)|perm|PTE_P;
f010115b:	0b 5d 14             	or     0x14(%ebp),%ebx
f010115e:	83 cb 01             	or     $0x1,%ebx
f0101161:	89 1e                	mov    %ebx,(%esi)
		return 0;
f0101163:	83 c4 10             	add    $0x10,%esp
f0101166:	b8 00 00 00 00       	mov    $0x0,%eax
f010116b:	eb ce                	jmp    f010113b <page_insert+0x4a>
		return -E_NO_MEM;
f010116d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101172:	eb c7                	jmp    f010113b <page_insert+0x4a>

f0101174 <mem_init>:
{
f0101174:	f3 0f 1e fb          	endbr32 
f0101178:	55                   	push   %ebp
f0101179:	89 e5                	mov    %esp,%ebp
f010117b:	57                   	push   %edi
f010117c:	56                   	push   %esi
f010117d:	53                   	push   %ebx
f010117e:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101181:	b8 15 00 00 00       	mov    $0x15,%eax
f0101186:	e8 3e f7 ff ff       	call   f01008c9 <nvram_read>
f010118b:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010118d:	b8 17 00 00 00       	mov    $0x17,%eax
f0101192:	e8 32 f7 ff ff       	call   f01008c9 <nvram_read>
f0101197:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101199:	b8 34 00 00 00       	mov    $0x34,%eax
f010119e:	e8 26 f7 ff ff       	call   f01008c9 <nvram_read>
	if (ext16mem)
f01011a3:	c1 e0 06             	shl    $0x6,%eax
f01011a6:	0f 84 d3 00 00 00    	je     f010127f <mem_init+0x10b>
		totalmem = 16 * 1024 + ext16mem;
f01011ac:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01011b1:	89 c2                	mov    %eax,%edx
f01011b3:	c1 ea 02             	shr    $0x2,%edx
f01011b6:	89 15 68 89 11 f0    	mov    %edx,0xf0118968
	npages_basemem = basemem / (PGSIZE / 1024);
f01011bc:	89 da                	mov    %ebx,%edx
f01011be:	c1 ea 02             	shr    $0x2,%edx
f01011c1:	89 15 44 85 11 f0    	mov    %edx,0xf0118544
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011c7:	89 c2                	mov    %eax,%edx
f01011c9:	29 da                	sub    %ebx,%edx
f01011cb:	52                   	push   %edx
f01011cc:	53                   	push   %ebx
f01011cd:	50                   	push   %eax
f01011ce:	68 c0 40 10 f0       	push   $0xf01040c0
f01011d3:	e8 42 18 00 00       	call   f0102a1a <cprintf>
	cprintf("\nhehe got into mem_init hehe\n\n");
f01011d8:	c7 04 24 fc 40 10 f0 	movl   $0xf01040fc,(%esp)
f01011df:	e8 36 18 00 00       	call   f0102a1a <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); //RYAN: I think kern_pgdir is just a pointer to the 4096 bytes of data for ONE page DIRECTORY 
f01011e4:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011e9:	e8 04 f7 ff ff       	call   f01008f2 <boot_alloc>
f01011ee:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
	memset(kern_pgdir, 0, PGSIZE); //RYAN: this just sets all the values in the newly-allocated page to all zeros (this makes sense)
f01011f3:	83 c4 0c             	add    $0xc,%esp
f01011f6:	68 00 10 00 00       	push   $0x1000
f01011fb:	6a 00                	push   $0x0
f01011fd:	50                   	push   %eax
f01011fe:	e8 3c 23 00 00       	call   f010353f <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P; 
f0101203:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101208:	83 c4 10             	add    $0x10,%esp
f010120b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101210:	76 7d                	jbe    f010128f <mem_init+0x11b>
	return (physaddr_t)kva - KERNBASE;
f0101212:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101218:	83 ca 05             	or     $0x5,%edx
f010121b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo)); //also, boot_alloc() returns a void pointer so you need to cast it 
f0101221:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101226:	c1 e0 03             	shl    $0x3,%eax
f0101229:	e8 c4 f6 ff ff       	call   f01008f2 <boot_alloc>
f010122e:	a3 70 89 11 f0       	mov    %eax,0xf0118970
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101233:	83 ec 04             	sub    $0x4,%esp
f0101236:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f010123c:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101243:	52                   	push   %edx
f0101244:	6a 00                	push   $0x0
f0101246:	50                   	push   %eax
f0101247:	e8 f3 22 00 00       	call   f010353f <memset>
	page_init();
f010124c:	e8 7c fa ff ff       	call   f0100ccd <page_init>
	check_page_free_list(1);
f0101251:	b8 01 00 00 00       	mov    $0x1,%eax
f0101256:	e8 af f7 ff ff       	call   f0100a0a <check_page_free_list>
	if (!pages)
f010125b:	83 c4 10             	add    $0x10,%esp
f010125e:	83 3d 70 89 11 f0 00 	cmpl   $0x0,0xf0118970
f0101265:	74 3d                	je     f01012a4 <mem_init+0x130>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101267:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f010126c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101273:	85 c0                	test   %eax,%eax
f0101275:	74 44                	je     f01012bb <mem_init+0x147>
		++nfree;
f0101277:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010127b:	8b 00                	mov    (%eax),%eax
f010127d:	eb f4                	jmp    f0101273 <mem_init+0xff>
		totalmem = 1 * 1024 + extmem;
f010127f:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101285:	85 f6                	test   %esi,%esi
f0101287:	0f 44 c3             	cmove  %ebx,%eax
f010128a:	e9 22 ff ff ff       	jmp    f01011b1 <mem_init+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010128f:	50                   	push   %eax
f0101290:	68 00 40 10 f0       	push   $0xf0104000
f0101295:	68 bc 00 00 00       	push   $0xbc
f010129a:	68 05 47 10 f0       	push   $0xf0104705
f010129f:	e8 eb ed ff ff       	call   f010008f <_panic>
		panic("'pages' is a null pointer!");
f01012a4:	83 ec 04             	sub    $0x4,%esp
f01012a7:	68 d1 47 10 f0       	push   $0xf01047d1
f01012ac:	68 1c 03 00 00       	push   $0x31c
f01012b1:	68 05 47 10 f0       	push   $0xf0104705
f01012b6:	e8 d4 ed ff ff       	call   f010008f <_panic>
	assert((pp0 = page_alloc(0)));
f01012bb:	83 ec 0c             	sub    $0xc,%esp
f01012be:	6a 00                	push   $0x0
f01012c0:	e8 0e fb ff ff       	call   f0100dd3 <page_alloc>
f01012c5:	89 c3                	mov    %eax,%ebx
f01012c7:	83 c4 10             	add    $0x10,%esp
f01012ca:	85 c0                	test   %eax,%eax
f01012cc:	0f 84 11 02 00 00    	je     f01014e3 <mem_init+0x36f>
	assert((pp1 = page_alloc(0)));
f01012d2:	83 ec 0c             	sub    $0xc,%esp
f01012d5:	6a 00                	push   $0x0
f01012d7:	e8 f7 fa ff ff       	call   f0100dd3 <page_alloc>
f01012dc:	89 c6                	mov    %eax,%esi
f01012de:	83 c4 10             	add    $0x10,%esp
f01012e1:	85 c0                	test   %eax,%eax
f01012e3:	0f 84 13 02 00 00    	je     f01014fc <mem_init+0x388>
	assert((pp2 = page_alloc(0)));
f01012e9:	83 ec 0c             	sub    $0xc,%esp
f01012ec:	6a 00                	push   $0x0
f01012ee:	e8 e0 fa ff ff       	call   f0100dd3 <page_alloc>
f01012f3:	89 c7                	mov    %eax,%edi
f01012f5:	83 c4 10             	add    $0x10,%esp
f01012f8:	85 c0                	test   %eax,%eax
f01012fa:	0f 84 15 02 00 00    	je     f0101515 <mem_init+0x3a1>
	assert(pp1 && pp1 != pp0);
f0101300:	39 f3                	cmp    %esi,%ebx
f0101302:	0f 84 26 02 00 00    	je     f010152e <mem_init+0x3ba>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101308:	39 c6                	cmp    %eax,%esi
f010130a:	0f 84 37 02 00 00    	je     f0101547 <mem_init+0x3d3>
f0101310:	39 c3                	cmp    %eax,%ebx
f0101312:	0f 84 2f 02 00 00    	je     f0101547 <mem_init+0x3d3>
	return (pp - pages) << PGSHIFT;
f0101318:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010131e:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0101324:	c1 e2 0c             	shl    $0xc,%edx
f0101327:	89 d8                	mov    %ebx,%eax
f0101329:	29 c8                	sub    %ecx,%eax
f010132b:	c1 f8 03             	sar    $0x3,%eax
f010132e:	c1 e0 0c             	shl    $0xc,%eax
f0101331:	39 d0                	cmp    %edx,%eax
f0101333:	0f 83 27 02 00 00    	jae    f0101560 <mem_init+0x3ec>
f0101339:	89 f0                	mov    %esi,%eax
f010133b:	29 c8                	sub    %ecx,%eax
f010133d:	c1 f8 03             	sar    $0x3,%eax
f0101340:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101343:	39 c2                	cmp    %eax,%edx
f0101345:	0f 86 2e 02 00 00    	jbe    f0101579 <mem_init+0x405>
f010134b:	89 f8                	mov    %edi,%eax
f010134d:	29 c8                	sub    %ecx,%eax
f010134f:	c1 f8 03             	sar    $0x3,%eax
f0101352:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101355:	39 c2                	cmp    %eax,%edx
f0101357:	0f 86 35 02 00 00    	jbe    f0101592 <mem_init+0x41e>
	fl = page_free_list;
f010135d:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f0101362:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101365:	c7 05 40 85 11 f0 00 	movl   $0x0,0xf0118540
f010136c:	00 00 00 
	assert(!page_alloc(0));
f010136f:	83 ec 0c             	sub    $0xc,%esp
f0101372:	6a 00                	push   $0x0
f0101374:	e8 5a fa ff ff       	call   f0100dd3 <page_alloc>
f0101379:	83 c4 10             	add    $0x10,%esp
f010137c:	85 c0                	test   %eax,%eax
f010137e:	0f 85 27 02 00 00    	jne    f01015ab <mem_init+0x437>
	page_free(pp0);
f0101384:	83 ec 0c             	sub    $0xc,%esp
f0101387:	53                   	push   %ebx
f0101388:	e8 bf fa ff ff       	call   f0100e4c <page_free>
	page_free(pp1);
f010138d:	89 34 24             	mov    %esi,(%esp)
f0101390:	e8 b7 fa ff ff       	call   f0100e4c <page_free>
	page_free(pp2);
f0101395:	89 3c 24             	mov    %edi,(%esp)
f0101398:	e8 af fa ff ff       	call   f0100e4c <page_free>
	assert((pp0 = page_alloc(0)));
f010139d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013a4:	e8 2a fa ff ff       	call   f0100dd3 <page_alloc>
f01013a9:	89 c3                	mov    %eax,%ebx
f01013ab:	83 c4 10             	add    $0x10,%esp
f01013ae:	85 c0                	test   %eax,%eax
f01013b0:	0f 84 0e 02 00 00    	je     f01015c4 <mem_init+0x450>
	assert((pp1 = page_alloc(0)));
f01013b6:	83 ec 0c             	sub    $0xc,%esp
f01013b9:	6a 00                	push   $0x0
f01013bb:	e8 13 fa ff ff       	call   f0100dd3 <page_alloc>
f01013c0:	89 c6                	mov    %eax,%esi
f01013c2:	83 c4 10             	add    $0x10,%esp
f01013c5:	85 c0                	test   %eax,%eax
f01013c7:	0f 84 10 02 00 00    	je     f01015dd <mem_init+0x469>
	assert((pp2 = page_alloc(0)));
f01013cd:	83 ec 0c             	sub    $0xc,%esp
f01013d0:	6a 00                	push   $0x0
f01013d2:	e8 fc f9 ff ff       	call   f0100dd3 <page_alloc>
f01013d7:	89 c7                	mov    %eax,%edi
f01013d9:	83 c4 10             	add    $0x10,%esp
f01013dc:	85 c0                	test   %eax,%eax
f01013de:	0f 84 12 02 00 00    	je     f01015f6 <mem_init+0x482>
	assert(pp1 && pp1 != pp0);
f01013e4:	39 f3                	cmp    %esi,%ebx
f01013e6:	0f 84 23 02 00 00    	je     f010160f <mem_init+0x49b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013ec:	39 c6                	cmp    %eax,%esi
f01013ee:	0f 84 34 02 00 00    	je     f0101628 <mem_init+0x4b4>
f01013f4:	39 c3                	cmp    %eax,%ebx
f01013f6:	0f 84 2c 02 00 00    	je     f0101628 <mem_init+0x4b4>
	assert(!page_alloc(0));
f01013fc:	83 ec 0c             	sub    $0xc,%esp
f01013ff:	6a 00                	push   $0x0
f0101401:	e8 cd f9 ff ff       	call   f0100dd3 <page_alloc>
f0101406:	83 c4 10             	add    $0x10,%esp
f0101409:	85 c0                	test   %eax,%eax
f010140b:	0f 85 30 02 00 00    	jne    f0101641 <mem_init+0x4cd>
f0101411:	89 d8                	mov    %ebx,%eax
f0101413:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101419:	c1 f8 03             	sar    $0x3,%eax
f010141c:	89 c2                	mov    %eax,%edx
f010141e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101421:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101426:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f010142c:	0f 83 28 02 00 00    	jae    f010165a <mem_init+0x4e6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101432:	83 ec 04             	sub    $0x4,%esp
f0101435:	68 00 10 00 00       	push   $0x1000
f010143a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010143c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101442:	52                   	push   %edx
f0101443:	e8 f7 20 00 00       	call   f010353f <memset>
	page_free(pp0);
f0101448:	89 1c 24             	mov    %ebx,(%esp)
f010144b:	e8 fc f9 ff ff       	call   f0100e4c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101450:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101457:	e8 77 f9 ff ff       	call   f0100dd3 <page_alloc>
f010145c:	83 c4 10             	add    $0x10,%esp
f010145f:	85 c0                	test   %eax,%eax
f0101461:	0f 84 05 02 00 00    	je     f010166c <mem_init+0x4f8>
	assert(pp && pp0 == pp);
f0101467:	39 c3                	cmp    %eax,%ebx
f0101469:	0f 85 16 02 00 00    	jne    f0101685 <mem_init+0x511>
	return (pp - pages) << PGSHIFT;
f010146f:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101475:	c1 f8 03             	sar    $0x3,%eax
f0101478:	89 c2                	mov    %eax,%edx
f010147a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010147d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101482:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0101488:	0f 83 10 02 00 00    	jae    f010169e <mem_init+0x52a>
	return (void *)(pa + KERNBASE);
f010148e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101494:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010149a:	80 38 00             	cmpb   $0x0,(%eax)
f010149d:	0f 85 0d 02 00 00    	jne    f01016b0 <mem_init+0x53c>
f01014a3:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01014a6:	39 d0                	cmp    %edx,%eax
f01014a8:	75 f0                	jne    f010149a <mem_init+0x326>
	page_free_list = fl;
f01014aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014ad:	a3 40 85 11 f0       	mov    %eax,0xf0118540
	page_free(pp0);
f01014b2:	83 ec 0c             	sub    $0xc,%esp
f01014b5:	53                   	push   %ebx
f01014b6:	e8 91 f9 ff ff       	call   f0100e4c <page_free>
	page_free(pp1);
f01014bb:	89 34 24             	mov    %esi,(%esp)
f01014be:	e8 89 f9 ff ff       	call   f0100e4c <page_free>
	page_free(pp2);
f01014c3:	89 3c 24             	mov    %edi,(%esp)
f01014c6:	e8 81 f9 ff ff       	call   f0100e4c <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014cb:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f01014d0:	83 c4 10             	add    $0x10,%esp
f01014d3:	85 c0                	test   %eax,%eax
f01014d5:	0f 84 ee 01 00 00    	je     f01016c9 <mem_init+0x555>
		--nfree;
f01014db:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014df:	8b 00                	mov    (%eax),%eax
f01014e1:	eb f0                	jmp    f01014d3 <mem_init+0x35f>
	assert((pp0 = page_alloc(0)));
f01014e3:	68 ec 47 10 f0       	push   $0xf01047ec
f01014e8:	68 41 47 10 f0       	push   $0xf0104741
f01014ed:	68 24 03 00 00       	push   $0x324
f01014f2:	68 05 47 10 f0       	push   $0xf0104705
f01014f7:	e8 93 eb ff ff       	call   f010008f <_panic>
	assert((pp1 = page_alloc(0)));
f01014fc:	68 02 48 10 f0       	push   $0xf0104802
f0101501:	68 41 47 10 f0       	push   $0xf0104741
f0101506:	68 25 03 00 00       	push   $0x325
f010150b:	68 05 47 10 f0       	push   $0xf0104705
f0101510:	e8 7a eb ff ff       	call   f010008f <_panic>
	assert((pp2 = page_alloc(0)));
f0101515:	68 18 48 10 f0       	push   $0xf0104818
f010151a:	68 41 47 10 f0       	push   $0xf0104741
f010151f:	68 26 03 00 00       	push   $0x326
f0101524:	68 05 47 10 f0       	push   $0xf0104705
f0101529:	e8 61 eb ff ff       	call   f010008f <_panic>
	assert(pp1 && pp1 != pp0);
f010152e:	68 2e 48 10 f0       	push   $0xf010482e
f0101533:	68 41 47 10 f0       	push   $0xf0104741
f0101538:	68 29 03 00 00       	push   $0x329
f010153d:	68 05 47 10 f0       	push   $0xf0104705
f0101542:	e8 48 eb ff ff       	call   f010008f <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101547:	68 1c 41 10 f0       	push   $0xf010411c
f010154c:	68 41 47 10 f0       	push   $0xf0104741
f0101551:	68 2a 03 00 00       	push   $0x32a
f0101556:	68 05 47 10 f0       	push   $0xf0104705
f010155b:	e8 2f eb ff ff       	call   f010008f <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101560:	68 40 48 10 f0       	push   $0xf0104840
f0101565:	68 41 47 10 f0       	push   $0xf0104741
f010156a:	68 2b 03 00 00       	push   $0x32b
f010156f:	68 05 47 10 f0       	push   $0xf0104705
f0101574:	e8 16 eb ff ff       	call   f010008f <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101579:	68 5d 48 10 f0       	push   $0xf010485d
f010157e:	68 41 47 10 f0       	push   $0xf0104741
f0101583:	68 2c 03 00 00       	push   $0x32c
f0101588:	68 05 47 10 f0       	push   $0xf0104705
f010158d:	e8 fd ea ff ff       	call   f010008f <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101592:	68 7a 48 10 f0       	push   $0xf010487a
f0101597:	68 41 47 10 f0       	push   $0xf0104741
f010159c:	68 2d 03 00 00       	push   $0x32d
f01015a1:	68 05 47 10 f0       	push   $0xf0104705
f01015a6:	e8 e4 ea ff ff       	call   f010008f <_panic>
	assert(!page_alloc(0));
f01015ab:	68 97 48 10 f0       	push   $0xf0104897
f01015b0:	68 41 47 10 f0       	push   $0xf0104741
f01015b5:	68 34 03 00 00       	push   $0x334
f01015ba:	68 05 47 10 f0       	push   $0xf0104705
f01015bf:	e8 cb ea ff ff       	call   f010008f <_panic>
	assert((pp0 = page_alloc(0)));
f01015c4:	68 ec 47 10 f0       	push   $0xf01047ec
f01015c9:	68 41 47 10 f0       	push   $0xf0104741
f01015ce:	68 3b 03 00 00       	push   $0x33b
f01015d3:	68 05 47 10 f0       	push   $0xf0104705
f01015d8:	e8 b2 ea ff ff       	call   f010008f <_panic>
	assert((pp1 = page_alloc(0)));
f01015dd:	68 02 48 10 f0       	push   $0xf0104802
f01015e2:	68 41 47 10 f0       	push   $0xf0104741
f01015e7:	68 3c 03 00 00       	push   $0x33c
f01015ec:	68 05 47 10 f0       	push   $0xf0104705
f01015f1:	e8 99 ea ff ff       	call   f010008f <_panic>
	assert((pp2 = page_alloc(0)));
f01015f6:	68 18 48 10 f0       	push   $0xf0104818
f01015fb:	68 41 47 10 f0       	push   $0xf0104741
f0101600:	68 3d 03 00 00       	push   $0x33d
f0101605:	68 05 47 10 f0       	push   $0xf0104705
f010160a:	e8 80 ea ff ff       	call   f010008f <_panic>
	assert(pp1 && pp1 != pp0);
f010160f:	68 2e 48 10 f0       	push   $0xf010482e
f0101614:	68 41 47 10 f0       	push   $0xf0104741
f0101619:	68 3f 03 00 00       	push   $0x33f
f010161e:	68 05 47 10 f0       	push   $0xf0104705
f0101623:	e8 67 ea ff ff       	call   f010008f <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101628:	68 1c 41 10 f0       	push   $0xf010411c
f010162d:	68 41 47 10 f0       	push   $0xf0104741
f0101632:	68 40 03 00 00       	push   $0x340
f0101637:	68 05 47 10 f0       	push   $0xf0104705
f010163c:	e8 4e ea ff ff       	call   f010008f <_panic>
	assert(!page_alloc(0));
f0101641:	68 97 48 10 f0       	push   $0xf0104897
f0101646:	68 41 47 10 f0       	push   $0xf0104741
f010164b:	68 41 03 00 00       	push   $0x341
f0101650:	68 05 47 10 f0       	push   $0xf0104705
f0101655:	e8 35 ea ff ff       	call   f010008f <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010165a:	52                   	push   %edx
f010165b:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0101660:	6a 52                	push   $0x52
f0101662:	68 27 47 10 f0       	push   $0xf0104727
f0101667:	e8 23 ea ff ff       	call   f010008f <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010166c:	68 a6 48 10 f0       	push   $0xf01048a6
f0101671:	68 41 47 10 f0       	push   $0xf0104741
f0101676:	68 46 03 00 00       	push   $0x346
f010167b:	68 05 47 10 f0       	push   $0xf0104705
f0101680:	e8 0a ea ff ff       	call   f010008f <_panic>
	assert(pp && pp0 == pp);
f0101685:	68 c4 48 10 f0       	push   $0xf01048c4
f010168a:	68 41 47 10 f0       	push   $0xf0104741
f010168f:	68 47 03 00 00       	push   $0x347
f0101694:	68 05 47 10 f0       	push   $0xf0104705
f0101699:	e8 f1 e9 ff ff       	call   f010008f <_panic>
f010169e:	52                   	push   %edx
f010169f:	68 f4 3e 10 f0       	push   $0xf0103ef4
f01016a4:	6a 52                	push   $0x52
f01016a6:	68 27 47 10 f0       	push   $0xf0104727
f01016ab:	e8 df e9 ff ff       	call   f010008f <_panic>
		assert(c[i] == 0);
f01016b0:	68 d4 48 10 f0       	push   $0xf01048d4
f01016b5:	68 41 47 10 f0       	push   $0xf0104741
f01016ba:	68 4a 03 00 00       	push   $0x34a
f01016bf:	68 05 47 10 f0       	push   $0xf0104705
f01016c4:	e8 c6 e9 ff ff       	call   f010008f <_panic>
	assert(nfree == 0);
f01016c9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01016cd:	0f 85 a2 07 00 00    	jne    f0101e75 <mem_init+0xd01>
	cprintf("check_page_alloc() succeeded!\n");
f01016d3:	83 ec 0c             	sub    $0xc,%esp
f01016d6:	68 3c 41 10 f0       	push   $0xf010413c
f01016db:	e8 3a 13 00 00       	call   f0102a1a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016e7:	e8 e7 f6 ff ff       	call   f0100dd3 <page_alloc>
f01016ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016ef:	83 c4 10             	add    $0x10,%esp
f01016f2:	85 c0                	test   %eax,%eax
f01016f4:	0f 84 94 07 00 00    	je     f0101e8e <mem_init+0xd1a>
	assert((pp1 = page_alloc(0)));
f01016fa:	83 ec 0c             	sub    $0xc,%esp
f01016fd:	6a 00                	push   $0x0
f01016ff:	e8 cf f6 ff ff       	call   f0100dd3 <page_alloc>
f0101704:	89 c7                	mov    %eax,%edi
f0101706:	83 c4 10             	add    $0x10,%esp
f0101709:	85 c0                	test   %eax,%eax
f010170b:	0f 84 96 07 00 00    	je     f0101ea7 <mem_init+0xd33>
	assert((pp2 = page_alloc(0)));
f0101711:	83 ec 0c             	sub    $0xc,%esp
f0101714:	6a 00                	push   $0x0
f0101716:	e8 b8 f6 ff ff       	call   f0100dd3 <page_alloc>
f010171b:	89 c3                	mov    %eax,%ebx
f010171d:	83 c4 10             	add    $0x10,%esp
f0101720:	85 c0                	test   %eax,%eax
f0101722:	0f 84 98 07 00 00    	je     f0101ec0 <mem_init+0xd4c>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101728:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010172b:	0f 84 a8 07 00 00    	je     f0101ed9 <mem_init+0xd65>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101731:	39 c7                	cmp    %eax,%edi
f0101733:	0f 84 b9 07 00 00    	je     f0101ef2 <mem_init+0xd7e>
f0101739:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010173c:	0f 84 b0 07 00 00    	je     f0101ef2 <mem_init+0xd7e>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101742:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f0101747:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010174a:	c7 05 40 85 11 f0 00 	movl   $0x0,0xf0118540
f0101751:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101754:	83 ec 0c             	sub    $0xc,%esp
f0101757:	6a 00                	push   $0x0
f0101759:	e8 75 f6 ff ff       	call   f0100dd3 <page_alloc>
f010175e:	83 c4 10             	add    $0x10,%esp
f0101761:	85 c0                	test   %eax,%eax
f0101763:	0f 85 a2 07 00 00    	jne    f0101f0b <mem_init+0xd97>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101769:	83 ec 04             	sub    $0x4,%esp
f010176c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010176f:	50                   	push   %eax
f0101770:	6a 00                	push   $0x0
f0101772:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101778:	e8 cc f8 ff ff       	call   f0101049 <page_lookup>
f010177d:	83 c4 10             	add    $0x10,%esp
f0101780:	85 c0                	test   %eax,%eax
f0101782:	0f 85 9c 07 00 00    	jne    f0101f24 <mem_init+0xdb0>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101788:	6a 02                	push   $0x2
f010178a:	6a 00                	push   $0x0
f010178c:	57                   	push   %edi
f010178d:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101793:	e8 59 f9 ff ff       	call   f01010f1 <page_insert>
f0101798:	83 c4 10             	add    $0x10,%esp
f010179b:	85 c0                	test   %eax,%eax
f010179d:	0f 89 9a 07 00 00    	jns    f0101f3d <mem_init+0xdc9>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017a3:	83 ec 0c             	sub    $0xc,%esp
f01017a6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017a9:	e8 9e f6 ff ff       	call   f0100e4c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017ae:	6a 02                	push   $0x2
f01017b0:	6a 00                	push   $0x0
f01017b2:	57                   	push   %edi
f01017b3:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01017b9:	e8 33 f9 ff ff       	call   f01010f1 <page_insert>
f01017be:	83 c4 20             	add    $0x20,%esp
f01017c1:	85 c0                	test   %eax,%eax
f01017c3:	0f 85 8d 07 00 00    	jne    f0101f56 <mem_init+0xde2>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017c9:	8b 35 6c 89 11 f0    	mov    0xf011896c,%esi
	return (pp - pages) << PGSHIFT;
f01017cf:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
f01017d5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01017d8:	8b 16                	mov    (%esi),%edx
f01017da:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017e3:	29 c8                	sub    %ecx,%eax
f01017e5:	c1 f8 03             	sar    $0x3,%eax
f01017e8:	c1 e0 0c             	shl    $0xc,%eax
f01017eb:	39 c2                	cmp    %eax,%edx
f01017ed:	0f 85 7c 07 00 00    	jne    f0101f6f <mem_init+0xdfb>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01017f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01017f8:	89 f0                	mov    %esi,%eax
f01017fa:	e8 a8 f1 ff ff       	call   f01009a7 <check_va2pa>
f01017ff:	89 c2                	mov    %eax,%edx
f0101801:	89 f8                	mov    %edi,%eax
f0101803:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101806:	c1 f8 03             	sar    $0x3,%eax
f0101809:	c1 e0 0c             	shl    $0xc,%eax
f010180c:	39 c2                	cmp    %eax,%edx
f010180e:	0f 85 74 07 00 00    	jne    f0101f88 <mem_init+0xe14>
	assert(pp1->pp_ref == 1);
f0101814:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101819:	0f 85 82 07 00 00    	jne    f0101fa1 <mem_init+0xe2d>
	assert(pp0->pp_ref == 1);
f010181f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101822:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101827:	0f 85 8d 07 00 00    	jne    f0101fba <mem_init+0xe46>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010182d:	6a 02                	push   $0x2
f010182f:	68 00 10 00 00       	push   $0x1000
f0101834:	53                   	push   %ebx
f0101835:	56                   	push   %esi
f0101836:	e8 b6 f8 ff ff       	call   f01010f1 <page_insert>
f010183b:	83 c4 10             	add    $0x10,%esp
f010183e:	85 c0                	test   %eax,%eax
f0101840:	0f 85 8d 07 00 00    	jne    f0101fd3 <mem_init+0xe5f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101846:	ba 00 10 00 00       	mov    $0x1000,%edx
f010184b:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101850:	e8 52 f1 ff ff       	call   f01009a7 <check_va2pa>
f0101855:	89 c2                	mov    %eax,%edx
f0101857:	89 d8                	mov    %ebx,%eax
f0101859:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010185f:	c1 f8 03             	sar    $0x3,%eax
f0101862:	c1 e0 0c             	shl    $0xc,%eax
f0101865:	39 c2                	cmp    %eax,%edx
f0101867:	0f 85 7f 07 00 00    	jne    f0101fec <mem_init+0xe78>
	assert(pp2->pp_ref == 1);
f010186d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101872:	0f 85 8d 07 00 00    	jne    f0102005 <mem_init+0xe91>

	// should be no free memory
	assert(!page_alloc(0));
f0101878:	83 ec 0c             	sub    $0xc,%esp
f010187b:	6a 00                	push   $0x0
f010187d:	e8 51 f5 ff ff       	call   f0100dd3 <page_alloc>
f0101882:	83 c4 10             	add    $0x10,%esp
f0101885:	85 c0                	test   %eax,%eax
f0101887:	0f 85 91 07 00 00    	jne    f010201e <mem_init+0xeaa>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010188d:	6a 02                	push   $0x2
f010188f:	68 00 10 00 00       	push   $0x1000
f0101894:	53                   	push   %ebx
f0101895:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010189b:	e8 51 f8 ff ff       	call   f01010f1 <page_insert>
f01018a0:	83 c4 10             	add    $0x10,%esp
f01018a3:	85 c0                	test   %eax,%eax
f01018a5:	0f 85 8c 07 00 00    	jne    f0102037 <mem_init+0xec3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018ab:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018b0:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f01018b5:	e8 ed f0 ff ff       	call   f01009a7 <check_va2pa>
f01018ba:	89 c2                	mov    %eax,%edx
f01018bc:	89 d8                	mov    %ebx,%eax
f01018be:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01018c4:	c1 f8 03             	sar    $0x3,%eax
f01018c7:	c1 e0 0c             	shl    $0xc,%eax
f01018ca:	39 c2                	cmp    %eax,%edx
f01018cc:	0f 85 7e 07 00 00    	jne    f0102050 <mem_init+0xedc>
	assert(pp2->pp_ref == 1);
f01018d2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018d7:	0f 85 8c 07 00 00    	jne    f0102069 <mem_init+0xef5>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01018dd:	83 ec 0c             	sub    $0xc,%esp
f01018e0:	6a 00                	push   $0x0
f01018e2:	e8 ec f4 ff ff       	call   f0100dd3 <page_alloc>
f01018e7:	83 c4 10             	add    $0x10,%esp
f01018ea:	85 c0                	test   %eax,%eax
f01018ec:	0f 85 90 07 00 00    	jne    f0102082 <mem_init+0xf0e>

	
	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01018f2:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f01018f8:	8b 01                	mov    (%ecx),%eax
f01018fa:	89 c2                	mov    %eax,%edx
f01018fc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101902:	c1 e8 0c             	shr    $0xc,%eax
f0101905:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f010190b:	0f 83 8a 07 00 00    	jae    f010209b <mem_init+0xf27>
	return (void *)(pa + KERNBASE);
f0101911:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101917:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010191a:	83 ec 04             	sub    $0x4,%esp
f010191d:	6a 00                	push   $0x0
f010191f:	68 00 10 00 00       	push   $0x1000
f0101924:	51                   	push   %ecx
f0101925:	e8 a5 f5 ff ff       	call   f0100ecf <pgdir_walk>
f010192a:	89 c2                	mov    %eax,%edx
f010192c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010192f:	83 c0 04             	add    $0x4,%eax
f0101932:	83 c4 10             	add    $0x10,%esp
f0101935:	39 d0                	cmp    %edx,%eax
f0101937:	0f 85 73 07 00 00    	jne    f01020b0 <mem_init+0xf3c>
	
	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010193d:	6a 06                	push   $0x6
f010193f:	68 00 10 00 00       	push   $0x1000
f0101944:	53                   	push   %ebx
f0101945:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010194b:	e8 a1 f7 ff ff       	call   f01010f1 <page_insert>
f0101950:	83 c4 10             	add    $0x10,%esp
f0101953:	85 c0                	test   %eax,%eax
f0101955:	0f 85 6e 07 00 00    	jne    f01020c9 <mem_init+0xf55>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010195b:	8b 35 6c 89 11 f0    	mov    0xf011896c,%esi
f0101961:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101966:	89 f0                	mov    %esi,%eax
f0101968:	e8 3a f0 ff ff       	call   f01009a7 <check_va2pa>
f010196d:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f010196f:	89 d8                	mov    %ebx,%eax
f0101971:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101977:	c1 f8 03             	sar    $0x3,%eax
f010197a:	c1 e0 0c             	shl    $0xc,%eax
f010197d:	39 c2                	cmp    %eax,%edx
f010197f:	0f 85 5d 07 00 00    	jne    f01020e2 <mem_init+0xf6e>
	assert(pp2->pp_ref == 1);
f0101985:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010198a:	0f 85 6b 07 00 00    	jne    f01020fb <mem_init+0xf87>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101990:	83 ec 04             	sub    $0x4,%esp
f0101993:	6a 00                	push   $0x0
f0101995:	68 00 10 00 00       	push   $0x1000
f010199a:	56                   	push   %esi
f010199b:	e8 2f f5 ff ff       	call   f0100ecf <pgdir_walk>
f01019a0:	83 c4 10             	add    $0x10,%esp
f01019a3:	f6 00 04             	testb  $0x4,(%eax)
f01019a6:	0f 84 68 07 00 00    	je     f0102114 <mem_init+0xfa0>
	assert(kern_pgdir[0] & PTE_U);
f01019ac:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f01019b1:	f6 00 04             	testb  $0x4,(%eax)
f01019b4:	0f 84 73 07 00 00    	je     f010212d <mem_init+0xfb9>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019ba:	6a 02                	push   $0x2
f01019bc:	68 00 10 00 00       	push   $0x1000
f01019c1:	53                   	push   %ebx
f01019c2:	50                   	push   %eax
f01019c3:	e8 29 f7 ff ff       	call   f01010f1 <page_insert>
f01019c8:	83 c4 10             	add    $0x10,%esp
f01019cb:	85 c0                	test   %eax,%eax
f01019cd:	0f 85 73 07 00 00    	jne    f0102146 <mem_init+0xfd2>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01019d3:	83 ec 04             	sub    $0x4,%esp
f01019d6:	6a 00                	push   $0x0
f01019d8:	68 00 10 00 00       	push   $0x1000
f01019dd:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01019e3:	e8 e7 f4 ff ff       	call   f0100ecf <pgdir_walk>
f01019e8:	83 c4 10             	add    $0x10,%esp
f01019eb:	f6 00 02             	testb  $0x2,(%eax)
f01019ee:	0f 84 6b 07 00 00    	je     f010215f <mem_init+0xfeb>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01019f4:	83 ec 04             	sub    $0x4,%esp
f01019f7:	6a 00                	push   $0x0
f01019f9:	68 00 10 00 00       	push   $0x1000
f01019fe:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101a04:	e8 c6 f4 ff ff       	call   f0100ecf <pgdir_walk>
f0101a09:	83 c4 10             	add    $0x10,%esp
f0101a0c:	f6 00 04             	testb  $0x4,(%eax)
f0101a0f:	0f 85 63 07 00 00    	jne    f0102178 <mem_init+0x1004>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101a15:	6a 02                	push   $0x2
f0101a17:	68 00 00 40 00       	push   $0x400000
f0101a1c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a1f:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101a25:	e8 c7 f6 ff ff       	call   f01010f1 <page_insert>
f0101a2a:	83 c4 10             	add    $0x10,%esp
f0101a2d:	85 c0                	test   %eax,%eax
f0101a2f:	0f 89 5c 07 00 00    	jns    f0102191 <mem_init+0x101d>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101a35:	6a 02                	push   $0x2
f0101a37:	68 00 10 00 00       	push   $0x1000
f0101a3c:	57                   	push   %edi
f0101a3d:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101a43:	e8 a9 f6 ff ff       	call   f01010f1 <page_insert>
f0101a48:	83 c4 10             	add    $0x10,%esp
f0101a4b:	85 c0                	test   %eax,%eax
f0101a4d:	0f 85 57 07 00 00    	jne    f01021aa <mem_init+0x1036>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101a53:	83 ec 04             	sub    $0x4,%esp
f0101a56:	6a 00                	push   $0x0
f0101a58:	68 00 10 00 00       	push   $0x1000
f0101a5d:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101a63:	e8 67 f4 ff ff       	call   f0100ecf <pgdir_walk>
f0101a68:	83 c4 10             	add    $0x10,%esp
f0101a6b:	f6 00 04             	testb  $0x4,(%eax)
f0101a6e:	0f 85 4f 07 00 00    	jne    f01021c3 <mem_init+0x104f>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101a74:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101a79:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a81:	e8 21 ef ff ff       	call   f01009a7 <check_va2pa>
f0101a86:	89 fe                	mov    %edi,%esi
f0101a88:	2b 35 70 89 11 f0    	sub    0xf0118970,%esi
f0101a8e:	c1 fe 03             	sar    $0x3,%esi
f0101a91:	c1 e6 0c             	shl    $0xc,%esi
f0101a94:	39 f0                	cmp    %esi,%eax
f0101a96:	0f 85 40 07 00 00    	jne    f01021dc <mem_init+0x1068>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101a9c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aa1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101aa4:	e8 fe ee ff ff       	call   f01009a7 <check_va2pa>
f0101aa9:	39 c6                	cmp    %eax,%esi
f0101aab:	0f 85 44 07 00 00    	jne    f01021f5 <mem_init+0x1081>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ab1:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101ab6:	0f 85 52 07 00 00    	jne    f010220e <mem_init+0x109a>
	assert(pp2->pp_ref == 0);
f0101abc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ac1:	0f 85 60 07 00 00    	jne    f0102227 <mem_init+0x10b3>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ac7:	83 ec 0c             	sub    $0xc,%esp
f0101aca:	6a 00                	push   $0x0
f0101acc:	e8 02 f3 ff ff       	call   f0100dd3 <page_alloc>
f0101ad1:	83 c4 10             	add    $0x10,%esp
f0101ad4:	39 c3                	cmp    %eax,%ebx
f0101ad6:	0f 85 64 07 00 00    	jne    f0102240 <mem_init+0x10cc>
f0101adc:	85 c0                	test   %eax,%eax
f0101ade:	0f 84 5c 07 00 00    	je     f0102240 <mem_init+0x10cc>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ae4:	83 ec 08             	sub    $0x8,%esp
f0101ae7:	6a 00                	push   $0x0
f0101ae9:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101aef:	e8 be f5 ff ff       	call   f01010b2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101af4:	8b 35 6c 89 11 f0    	mov    0xf011896c,%esi
f0101afa:	ba 00 00 00 00       	mov    $0x0,%edx
f0101aff:	89 f0                	mov    %esi,%eax
f0101b01:	e8 a1 ee ff ff       	call   f01009a7 <check_va2pa>
f0101b06:	83 c4 10             	add    $0x10,%esp
f0101b09:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101b0c:	0f 85 47 07 00 00    	jne    f0102259 <mem_init+0x10e5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b12:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b17:	89 f0                	mov    %esi,%eax
f0101b19:	e8 89 ee ff ff       	call   f01009a7 <check_va2pa>
f0101b1e:	89 c2                	mov    %eax,%edx
f0101b20:	89 f8                	mov    %edi,%eax
f0101b22:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101b28:	c1 f8 03             	sar    $0x3,%eax
f0101b2b:	c1 e0 0c             	shl    $0xc,%eax
f0101b2e:	39 c2                	cmp    %eax,%edx
f0101b30:	0f 85 3c 07 00 00    	jne    f0102272 <mem_init+0x10fe>
	assert(pp1->pp_ref == 1);
f0101b36:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b3b:	0f 85 4a 07 00 00    	jne    f010228b <mem_init+0x1117>
	assert(pp2->pp_ref == 0);
f0101b41:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101b46:	0f 85 58 07 00 00    	jne    f01022a4 <mem_init+0x1130>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101b4c:	6a 00                	push   $0x0
f0101b4e:	68 00 10 00 00       	push   $0x1000
f0101b53:	57                   	push   %edi
f0101b54:	56                   	push   %esi
f0101b55:	e8 97 f5 ff ff       	call   f01010f1 <page_insert>
f0101b5a:	83 c4 10             	add    $0x10,%esp
f0101b5d:	85 c0                	test   %eax,%eax
f0101b5f:	0f 85 58 07 00 00    	jne    f01022bd <mem_init+0x1149>
	assert(pp1->pp_ref);
f0101b65:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101b6a:	0f 84 66 07 00 00    	je     f01022d6 <mem_init+0x1162>
	assert(pp1->pp_link == NULL);
f0101b70:	83 3f 00             	cmpl   $0x0,(%edi)
f0101b73:	0f 85 76 07 00 00    	jne    f01022ef <mem_init+0x117b>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101b79:	83 ec 08             	sub    $0x8,%esp
f0101b7c:	68 00 10 00 00       	push   $0x1000
f0101b81:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101b87:	e8 26 f5 ff ff       	call   f01010b2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101b8c:	8b 35 6c 89 11 f0    	mov    0xf011896c,%esi
f0101b92:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b97:	89 f0                	mov    %esi,%eax
f0101b99:	e8 09 ee ff ff       	call   f01009a7 <check_va2pa>
f0101b9e:	83 c4 10             	add    $0x10,%esp
f0101ba1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ba4:	0f 85 5e 07 00 00    	jne    f0102308 <mem_init+0x1194>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101baa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101baf:	89 f0                	mov    %esi,%eax
f0101bb1:	e8 f1 ed ff ff       	call   f01009a7 <check_va2pa>
f0101bb6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101bb9:	0f 85 62 07 00 00    	jne    f0102321 <mem_init+0x11ad>
	assert(pp1->pp_ref == 0);
f0101bbf:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101bc4:	0f 85 70 07 00 00    	jne    f010233a <mem_init+0x11c6>
	assert(pp2->pp_ref == 0);
f0101bca:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101bcf:	0f 85 7e 07 00 00    	jne    f0102353 <mem_init+0x11df>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101bd5:	83 ec 0c             	sub    $0xc,%esp
f0101bd8:	6a 00                	push   $0x0
f0101bda:	e8 f4 f1 ff ff       	call   f0100dd3 <page_alloc>
f0101bdf:	83 c4 10             	add    $0x10,%esp
f0101be2:	85 c0                	test   %eax,%eax
f0101be4:	0f 84 82 07 00 00    	je     f010236c <mem_init+0x11f8>
f0101bea:	39 c7                	cmp    %eax,%edi
f0101bec:	0f 85 7a 07 00 00    	jne    f010236c <mem_init+0x11f8>

	// should be no free memory
	assert(!page_alloc(0));
f0101bf2:	83 ec 0c             	sub    $0xc,%esp
f0101bf5:	6a 00                	push   $0x0
f0101bf7:	e8 d7 f1 ff ff       	call   f0100dd3 <page_alloc>
f0101bfc:	83 c4 10             	add    $0x10,%esp
f0101bff:	85 c0                	test   %eax,%eax
f0101c01:	0f 85 7e 07 00 00    	jne    f0102385 <mem_init+0x1211>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c07:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0101c0d:	8b 11                	mov    (%ecx),%edx
f0101c0f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c18:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101c1e:	c1 f8 03             	sar    $0x3,%eax
f0101c21:	c1 e0 0c             	shl    $0xc,%eax
f0101c24:	39 c2                	cmp    %eax,%edx
f0101c26:	0f 85 72 07 00 00    	jne    f010239e <mem_init+0x122a>
	kern_pgdir[0] = 0;
f0101c2c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101c32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c35:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c3a:	0f 85 77 07 00 00    	jne    f01023b7 <mem_init+0x1243>
	pp0->pp_ref = 0;
f0101c40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c43:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101c49:	83 ec 0c             	sub    $0xc,%esp
f0101c4c:	50                   	push   %eax
f0101c4d:	e8 fa f1 ff ff       	call   f0100e4c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101c52:	83 c4 0c             	add    $0xc,%esp
f0101c55:	6a 01                	push   $0x1
f0101c57:	68 00 10 40 00       	push   $0x401000
f0101c5c:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101c62:	e8 68 f2 ff ff       	call   f0100ecf <pgdir_walk>
f0101c67:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101c6d:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0101c73:	8b 41 04             	mov    0x4(%ecx),%eax
f0101c76:	89 c6                	mov    %eax,%esi
f0101c78:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101c7e:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0101c84:	c1 e8 0c             	shr    $0xc,%eax
f0101c87:	83 c4 10             	add    $0x10,%esp
f0101c8a:	39 d0                	cmp    %edx,%eax
f0101c8c:	0f 83 3e 07 00 00    	jae    f01023d0 <mem_init+0x125c>
	assert(ptep == ptep1 + PTX(va));
f0101c92:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101c98:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0101c9b:	0f 85 44 07 00 00    	jne    f01023e5 <mem_init+0x1271>
	kern_pgdir[PDX(va)] = 0;
f0101ca1:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101ca8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cab:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101cb1:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101cb7:	c1 f8 03             	sar    $0x3,%eax
f0101cba:	89 c1                	mov    %eax,%ecx
f0101cbc:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101cbf:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101cc4:	39 c2                	cmp    %eax,%edx
f0101cc6:	0f 86 32 07 00 00    	jbe    f01023fe <mem_init+0x128a>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101ccc:	83 ec 04             	sub    $0x4,%esp
f0101ccf:	68 00 10 00 00       	push   $0x1000
f0101cd4:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101cd9:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101cdf:	51                   	push   %ecx
f0101ce0:	e8 5a 18 00 00       	call   f010353f <memset>
	page_free(pp0);
f0101ce5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101ce8:	89 34 24             	mov    %esi,(%esp)
f0101ceb:	e8 5c f1 ff ff       	call   f0100e4c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101cf0:	83 c4 0c             	add    $0xc,%esp
f0101cf3:	6a 01                	push   $0x1
f0101cf5:	6a 00                	push   $0x0
f0101cf7:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101cfd:	e8 cd f1 ff ff       	call   f0100ecf <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101d02:	89 f0                	mov    %esi,%eax
f0101d04:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101d0a:	c1 f8 03             	sar    $0x3,%eax
f0101d0d:	89 c2                	mov    %eax,%edx
f0101d0f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101d12:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101d17:	83 c4 10             	add    $0x10,%esp
f0101d1a:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0101d20:	0f 83 ea 06 00 00    	jae    f0102410 <mem_init+0x129c>
	return (void *)(pa + KERNBASE);
f0101d26:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101d2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101d2f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101d35:	8b 30                	mov    (%eax),%esi
f0101d37:	83 e6 01             	and    $0x1,%esi
f0101d3a:	0f 85 e2 06 00 00    	jne    f0102422 <mem_init+0x12ae>
f0101d40:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101d43:	39 d0                	cmp    %edx,%eax
f0101d45:	75 ee                	jne    f0101d35 <mem_init+0xbc1>
	kern_pgdir[0] = 0;
f0101d47:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101d4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101d52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d55:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101d5b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101d5e:	89 0d 40 85 11 f0    	mov    %ecx,0xf0118540

	// free the pages we took
	page_free(pp0);
f0101d64:	83 ec 0c             	sub    $0xc,%esp
f0101d67:	50                   	push   %eax
f0101d68:	e8 df f0 ff ff       	call   f0100e4c <page_free>
	page_free(pp1);
f0101d6d:	89 3c 24             	mov    %edi,(%esp)
f0101d70:	e8 d7 f0 ff ff       	call   f0100e4c <page_free>
	page_free(pp2);
f0101d75:	89 1c 24             	mov    %ebx,(%esp)
f0101d78:	e8 cf f0 ff ff       	call   f0100e4c <page_free>

	cprintf("check_page() succeeded!\n");
f0101d7d:	c7 04 24 b5 49 10 f0 	movl   $0xf01049b5,(%esp)
f0101d84:	e8 91 0c 00 00       	call   f0102a1a <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U); //memlayout.h says UPAGEs is virtual so...
f0101d89:	a1 70 89 11 f0       	mov    0xf0118970,%eax
	if ((uint32_t)kva < KERNBASE)
f0101d8e:	83 c4 10             	add    $0x10,%esp
f0101d91:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101d96:	0f 86 9f 06 00 00    	jbe    f010243b <mem_init+0x12c7>
f0101d9c:	83 ec 08             	sub    $0x8,%esp
f0101d9f:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0101da1:	05 00 00 00 10       	add    $0x10000000,%eax
f0101da6:	50                   	push   %eax
f0101da7:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101dac:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101db1:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101db6:	e8 3e f2 ff ff       	call   f0100ff9 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101dbb:	83 c4 10             	add    $0x10,%esp
f0101dbe:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0101dc3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101dc8:	0f 86 82 06 00 00    	jbe    f0102450 <mem_init+0x12dc>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0101dce:	83 ec 08             	sub    $0x8,%esp
f0101dd1:	6a 02                	push   $0x2
f0101dd3:	68 00 e0 10 00       	push   $0x10e000
f0101dd8:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101ddd:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101de2:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101de7:	e8 0d f2 ff ff       	call   f0100ff9 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0x100000000 - KERNBASE, 0, PTE_W);
f0101dec:	83 c4 08             	add    $0x8,%esp
f0101def:	6a 02                	push   $0x2
f0101df1:	6a 00                	push   $0x0
f0101df3:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101df8:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101dfd:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101e02:	e8 f2 f1 ff ff       	call   f0100ff9 <boot_map_region>
	pgdir = kern_pgdir;
f0101e07:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101e0d:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101e12:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101e15:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101e1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101e21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101e24:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0101e29:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101e2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101e2f:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e34:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0101e37:	83 c4 10             	add    $0x10,%esp
f0101e3a:	89 f3                	mov    %esi,%ebx
f0101e3c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101e3f:	0f 86 50 06 00 00    	jbe    f0102495 <mem_init+0x1321>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101e45:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0101e4b:	89 f8                	mov    %edi,%eax
f0101e4d:	e8 55 eb ff ff       	call   f01009a7 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101e52:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0101e59:	0f 86 06 06 00 00    	jbe    f0102465 <mem_init+0x12f1>
f0101e5f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101e62:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0101e65:	39 d0                	cmp    %edx,%eax
f0101e67:	0f 85 0f 06 00 00    	jne    f010247c <mem_init+0x1308>
	for (i = 0; i < n; i += PGSIZE)
f0101e6d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101e73:	eb c7                	jmp    f0101e3c <mem_init+0xcc8>
	assert(nfree == 0);
f0101e75:	68 de 48 10 f0       	push   $0xf01048de
f0101e7a:	68 41 47 10 f0       	push   $0xf0104741
f0101e7f:	68 57 03 00 00       	push   $0x357
f0101e84:	68 05 47 10 f0       	push   $0xf0104705
f0101e89:	e8 01 e2 ff ff       	call   f010008f <_panic>
	assert((pp0 = page_alloc(0)));
f0101e8e:	68 ec 47 10 f0       	push   $0xf01047ec
f0101e93:	68 41 47 10 f0       	push   $0xf0104741
f0101e98:	68 b0 03 00 00       	push   $0x3b0
f0101e9d:	68 05 47 10 f0       	push   $0xf0104705
f0101ea2:	e8 e8 e1 ff ff       	call   f010008f <_panic>
	assert((pp1 = page_alloc(0)));
f0101ea7:	68 02 48 10 f0       	push   $0xf0104802
f0101eac:	68 41 47 10 f0       	push   $0xf0104741
f0101eb1:	68 b1 03 00 00       	push   $0x3b1
f0101eb6:	68 05 47 10 f0       	push   $0xf0104705
f0101ebb:	e8 cf e1 ff ff       	call   f010008f <_panic>
	assert((pp2 = page_alloc(0)));
f0101ec0:	68 18 48 10 f0       	push   $0xf0104818
f0101ec5:	68 41 47 10 f0       	push   $0xf0104741
f0101eca:	68 b2 03 00 00       	push   $0x3b2
f0101ecf:	68 05 47 10 f0       	push   $0xf0104705
f0101ed4:	e8 b6 e1 ff ff       	call   f010008f <_panic>
	assert(pp1 && pp1 != pp0);
f0101ed9:	68 2e 48 10 f0       	push   $0xf010482e
f0101ede:	68 41 47 10 f0       	push   $0xf0104741
f0101ee3:	68 b5 03 00 00       	push   $0x3b5
f0101ee8:	68 05 47 10 f0       	push   $0xf0104705
f0101eed:	e8 9d e1 ff ff       	call   f010008f <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ef2:	68 1c 41 10 f0       	push   $0xf010411c
f0101ef7:	68 41 47 10 f0       	push   $0xf0104741
f0101efc:	68 b6 03 00 00       	push   $0x3b6
f0101f01:	68 05 47 10 f0       	push   $0xf0104705
f0101f06:	e8 84 e1 ff ff       	call   f010008f <_panic>
	assert(!page_alloc(0));
f0101f0b:	68 97 48 10 f0       	push   $0xf0104897
f0101f10:	68 41 47 10 f0       	push   $0xf0104741
f0101f15:	68 bd 03 00 00       	push   $0x3bd
f0101f1a:	68 05 47 10 f0       	push   $0xf0104705
f0101f1f:	e8 6b e1 ff ff       	call   f010008f <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f24:	68 5c 41 10 f0       	push   $0xf010415c
f0101f29:	68 41 47 10 f0       	push   $0xf0104741
f0101f2e:	68 c0 03 00 00       	push   $0x3c0
f0101f33:	68 05 47 10 f0       	push   $0xf0104705
f0101f38:	e8 52 e1 ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101f3d:	68 94 41 10 f0       	push   $0xf0104194
f0101f42:	68 41 47 10 f0       	push   $0xf0104741
f0101f47:	68 c3 03 00 00       	push   $0x3c3
f0101f4c:	68 05 47 10 f0       	push   $0xf0104705
f0101f51:	e8 39 e1 ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101f56:	68 c4 41 10 f0       	push   $0xf01041c4
f0101f5b:	68 41 47 10 f0       	push   $0xf0104741
f0101f60:	68 c7 03 00 00       	push   $0x3c7
f0101f65:	68 05 47 10 f0       	push   $0xf0104705
f0101f6a:	e8 20 e1 ff ff       	call   f010008f <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f6f:	68 f4 41 10 f0       	push   $0xf01041f4
f0101f74:	68 41 47 10 f0       	push   $0xf0104741
f0101f79:	68 c8 03 00 00       	push   $0x3c8
f0101f7e:	68 05 47 10 f0       	push   $0xf0104705
f0101f83:	e8 07 e1 ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101f88:	68 1c 42 10 f0       	push   $0xf010421c
f0101f8d:	68 41 47 10 f0       	push   $0xf0104741
f0101f92:	68 c9 03 00 00       	push   $0x3c9
f0101f97:	68 05 47 10 f0       	push   $0xf0104705
f0101f9c:	e8 ee e0 ff ff       	call   f010008f <_panic>
	assert(pp1->pp_ref == 1);
f0101fa1:	68 e9 48 10 f0       	push   $0xf01048e9
f0101fa6:	68 41 47 10 f0       	push   $0xf0104741
f0101fab:	68 ca 03 00 00       	push   $0x3ca
f0101fb0:	68 05 47 10 f0       	push   $0xf0104705
f0101fb5:	e8 d5 e0 ff ff       	call   f010008f <_panic>
	assert(pp0->pp_ref == 1);
f0101fba:	68 fa 48 10 f0       	push   $0xf01048fa
f0101fbf:	68 41 47 10 f0       	push   $0xf0104741
f0101fc4:	68 cb 03 00 00       	push   $0x3cb
f0101fc9:	68 05 47 10 f0       	push   $0xf0104705
f0101fce:	e8 bc e0 ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fd3:	68 4c 42 10 f0       	push   $0xf010424c
f0101fd8:	68 41 47 10 f0       	push   $0xf0104741
f0101fdd:	68 ce 03 00 00       	push   $0x3ce
f0101fe2:	68 05 47 10 f0       	push   $0xf0104705
f0101fe7:	e8 a3 e0 ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fec:	68 88 42 10 f0       	push   $0xf0104288
f0101ff1:	68 41 47 10 f0       	push   $0xf0104741
f0101ff6:	68 cf 03 00 00       	push   $0x3cf
f0101ffb:	68 05 47 10 f0       	push   $0xf0104705
f0102000:	e8 8a e0 ff ff       	call   f010008f <_panic>
	assert(pp2->pp_ref == 1);
f0102005:	68 0b 49 10 f0       	push   $0xf010490b
f010200a:	68 41 47 10 f0       	push   $0xf0104741
f010200f:	68 d0 03 00 00       	push   $0x3d0
f0102014:	68 05 47 10 f0       	push   $0xf0104705
f0102019:	e8 71 e0 ff ff       	call   f010008f <_panic>
	assert(!page_alloc(0));
f010201e:	68 97 48 10 f0       	push   $0xf0104897
f0102023:	68 41 47 10 f0       	push   $0xf0104741
f0102028:	68 d3 03 00 00       	push   $0x3d3
f010202d:	68 05 47 10 f0       	push   $0xf0104705
f0102032:	e8 58 e0 ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102037:	68 4c 42 10 f0       	push   $0xf010424c
f010203c:	68 41 47 10 f0       	push   $0xf0104741
f0102041:	68 d6 03 00 00       	push   $0x3d6
f0102046:	68 05 47 10 f0       	push   $0xf0104705
f010204b:	e8 3f e0 ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102050:	68 88 42 10 f0       	push   $0xf0104288
f0102055:	68 41 47 10 f0       	push   $0xf0104741
f010205a:	68 d7 03 00 00       	push   $0x3d7
f010205f:	68 05 47 10 f0       	push   $0xf0104705
f0102064:	e8 26 e0 ff ff       	call   f010008f <_panic>
	assert(pp2->pp_ref == 1);
f0102069:	68 0b 49 10 f0       	push   $0xf010490b
f010206e:	68 41 47 10 f0       	push   $0xf0104741
f0102073:	68 d8 03 00 00       	push   $0x3d8
f0102078:	68 05 47 10 f0       	push   $0xf0104705
f010207d:	e8 0d e0 ff ff       	call   f010008f <_panic>
	assert(!page_alloc(0));
f0102082:	68 97 48 10 f0       	push   $0xf0104897
f0102087:	68 41 47 10 f0       	push   $0xf0104741
f010208c:	68 dc 03 00 00       	push   $0x3dc
f0102091:	68 05 47 10 f0       	push   $0xf0104705
f0102096:	e8 f4 df ff ff       	call   f010008f <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010209b:	52                   	push   %edx
f010209c:	68 f4 3e 10 f0       	push   $0xf0103ef4
f01020a1:	68 e0 03 00 00       	push   $0x3e0
f01020a6:	68 05 47 10 f0       	push   $0xf0104705
f01020ab:	e8 df df ff ff       	call   f010008f <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01020b0:	68 b8 42 10 f0       	push   $0xf01042b8
f01020b5:	68 41 47 10 f0       	push   $0xf0104741
f01020ba:	68 e1 03 00 00       	push   $0x3e1
f01020bf:	68 05 47 10 f0       	push   $0xf0104705
f01020c4:	e8 c6 df ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01020c9:	68 f8 42 10 f0       	push   $0xf01042f8
f01020ce:	68 41 47 10 f0       	push   $0xf0104741
f01020d3:	68 e4 03 00 00       	push   $0x3e4
f01020d8:	68 05 47 10 f0       	push   $0xf0104705
f01020dd:	e8 ad df ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020e2:	68 88 42 10 f0       	push   $0xf0104288
f01020e7:	68 41 47 10 f0       	push   $0xf0104741
f01020ec:	68 e5 03 00 00       	push   $0x3e5
f01020f1:	68 05 47 10 f0       	push   $0xf0104705
f01020f6:	e8 94 df ff ff       	call   f010008f <_panic>
	assert(pp2->pp_ref == 1);
f01020fb:	68 0b 49 10 f0       	push   $0xf010490b
f0102100:	68 41 47 10 f0       	push   $0xf0104741
f0102105:	68 e6 03 00 00       	push   $0x3e6
f010210a:	68 05 47 10 f0       	push   $0xf0104705
f010210f:	e8 7b df ff ff       	call   f010008f <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102114:	68 38 43 10 f0       	push   $0xf0104338
f0102119:	68 41 47 10 f0       	push   $0xf0104741
f010211e:	68 e7 03 00 00       	push   $0x3e7
f0102123:	68 05 47 10 f0       	push   $0xf0104705
f0102128:	e8 62 df ff ff       	call   f010008f <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010212d:	68 1c 49 10 f0       	push   $0xf010491c
f0102132:	68 41 47 10 f0       	push   $0xf0104741
f0102137:	68 e8 03 00 00       	push   $0x3e8
f010213c:	68 05 47 10 f0       	push   $0xf0104705
f0102141:	e8 49 df ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102146:	68 4c 42 10 f0       	push   $0xf010424c
f010214b:	68 41 47 10 f0       	push   $0xf0104741
f0102150:	68 eb 03 00 00       	push   $0x3eb
f0102155:	68 05 47 10 f0       	push   $0xf0104705
f010215a:	e8 30 df ff ff       	call   f010008f <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010215f:	68 6c 43 10 f0       	push   $0xf010436c
f0102164:	68 41 47 10 f0       	push   $0xf0104741
f0102169:	68 ec 03 00 00       	push   $0x3ec
f010216e:	68 05 47 10 f0       	push   $0xf0104705
f0102173:	e8 17 df ff ff       	call   f010008f <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102178:	68 a0 43 10 f0       	push   $0xf01043a0
f010217d:	68 41 47 10 f0       	push   $0xf0104741
f0102182:	68 ed 03 00 00       	push   $0x3ed
f0102187:	68 05 47 10 f0       	push   $0xf0104705
f010218c:	e8 fe de ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102191:	68 d8 43 10 f0       	push   $0xf01043d8
f0102196:	68 41 47 10 f0       	push   $0xf0104741
f010219b:	68 f0 03 00 00       	push   $0x3f0
f01021a0:	68 05 47 10 f0       	push   $0xf0104705
f01021a5:	e8 e5 de ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021aa:	68 10 44 10 f0       	push   $0xf0104410
f01021af:	68 41 47 10 f0       	push   $0xf0104741
f01021b4:	68 f3 03 00 00       	push   $0x3f3
f01021b9:	68 05 47 10 f0       	push   $0xf0104705
f01021be:	e8 cc de ff ff       	call   f010008f <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021c3:	68 a0 43 10 f0       	push   $0xf01043a0
f01021c8:	68 41 47 10 f0       	push   $0xf0104741
f01021cd:	68 f4 03 00 00       	push   $0x3f4
f01021d2:	68 05 47 10 f0       	push   $0xf0104705
f01021d7:	e8 b3 de ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021dc:	68 4c 44 10 f0       	push   $0xf010444c
f01021e1:	68 41 47 10 f0       	push   $0xf0104741
f01021e6:	68 f7 03 00 00       	push   $0x3f7
f01021eb:	68 05 47 10 f0       	push   $0xf0104705
f01021f0:	e8 9a de ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021f5:	68 78 44 10 f0       	push   $0xf0104478
f01021fa:	68 41 47 10 f0       	push   $0xf0104741
f01021ff:	68 f8 03 00 00       	push   $0x3f8
f0102204:	68 05 47 10 f0       	push   $0xf0104705
f0102209:	e8 81 de ff ff       	call   f010008f <_panic>
	assert(pp1->pp_ref == 2);
f010220e:	68 32 49 10 f0       	push   $0xf0104932
f0102213:	68 41 47 10 f0       	push   $0xf0104741
f0102218:	68 fa 03 00 00       	push   $0x3fa
f010221d:	68 05 47 10 f0       	push   $0xf0104705
f0102222:	e8 68 de ff ff       	call   f010008f <_panic>
	assert(pp2->pp_ref == 0);
f0102227:	68 43 49 10 f0       	push   $0xf0104943
f010222c:	68 41 47 10 f0       	push   $0xf0104741
f0102231:	68 fb 03 00 00       	push   $0x3fb
f0102236:	68 05 47 10 f0       	push   $0xf0104705
f010223b:	e8 4f de ff ff       	call   f010008f <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102240:	68 a8 44 10 f0       	push   $0xf01044a8
f0102245:	68 41 47 10 f0       	push   $0xf0104741
f010224a:	68 fe 03 00 00       	push   $0x3fe
f010224f:	68 05 47 10 f0       	push   $0xf0104705
f0102254:	e8 36 de ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102259:	68 cc 44 10 f0       	push   $0xf01044cc
f010225e:	68 41 47 10 f0       	push   $0xf0104741
f0102263:	68 02 04 00 00       	push   $0x402
f0102268:	68 05 47 10 f0       	push   $0xf0104705
f010226d:	e8 1d de ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102272:	68 78 44 10 f0       	push   $0xf0104478
f0102277:	68 41 47 10 f0       	push   $0xf0104741
f010227c:	68 03 04 00 00       	push   $0x403
f0102281:	68 05 47 10 f0       	push   $0xf0104705
f0102286:	e8 04 de ff ff       	call   f010008f <_panic>
	assert(pp1->pp_ref == 1);
f010228b:	68 e9 48 10 f0       	push   $0xf01048e9
f0102290:	68 41 47 10 f0       	push   $0xf0104741
f0102295:	68 04 04 00 00       	push   $0x404
f010229a:	68 05 47 10 f0       	push   $0xf0104705
f010229f:	e8 eb dd ff ff       	call   f010008f <_panic>
	assert(pp2->pp_ref == 0);
f01022a4:	68 43 49 10 f0       	push   $0xf0104943
f01022a9:	68 41 47 10 f0       	push   $0xf0104741
f01022ae:	68 05 04 00 00       	push   $0x405
f01022b3:	68 05 47 10 f0       	push   $0xf0104705
f01022b8:	e8 d2 dd ff ff       	call   f010008f <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01022bd:	68 f0 44 10 f0       	push   $0xf01044f0
f01022c2:	68 41 47 10 f0       	push   $0xf0104741
f01022c7:	68 08 04 00 00       	push   $0x408
f01022cc:	68 05 47 10 f0       	push   $0xf0104705
f01022d1:	e8 b9 dd ff ff       	call   f010008f <_panic>
	assert(pp1->pp_ref);
f01022d6:	68 54 49 10 f0       	push   $0xf0104954
f01022db:	68 41 47 10 f0       	push   $0xf0104741
f01022e0:	68 09 04 00 00       	push   $0x409
f01022e5:	68 05 47 10 f0       	push   $0xf0104705
f01022ea:	e8 a0 dd ff ff       	call   f010008f <_panic>
	assert(pp1->pp_link == NULL);
f01022ef:	68 60 49 10 f0       	push   $0xf0104960
f01022f4:	68 41 47 10 f0       	push   $0xf0104741
f01022f9:	68 0a 04 00 00       	push   $0x40a
f01022fe:	68 05 47 10 f0       	push   $0xf0104705
f0102303:	e8 87 dd ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102308:	68 cc 44 10 f0       	push   $0xf01044cc
f010230d:	68 41 47 10 f0       	push   $0xf0104741
f0102312:	68 0e 04 00 00       	push   $0x40e
f0102317:	68 05 47 10 f0       	push   $0xf0104705
f010231c:	e8 6e dd ff ff       	call   f010008f <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102321:	68 28 45 10 f0       	push   $0xf0104528
f0102326:	68 41 47 10 f0       	push   $0xf0104741
f010232b:	68 0f 04 00 00       	push   $0x40f
f0102330:	68 05 47 10 f0       	push   $0xf0104705
f0102335:	e8 55 dd ff ff       	call   f010008f <_panic>
	assert(pp1->pp_ref == 0);
f010233a:	68 75 49 10 f0       	push   $0xf0104975
f010233f:	68 41 47 10 f0       	push   $0xf0104741
f0102344:	68 10 04 00 00       	push   $0x410
f0102349:	68 05 47 10 f0       	push   $0xf0104705
f010234e:	e8 3c dd ff ff       	call   f010008f <_panic>
	assert(pp2->pp_ref == 0);
f0102353:	68 43 49 10 f0       	push   $0xf0104943
f0102358:	68 41 47 10 f0       	push   $0xf0104741
f010235d:	68 11 04 00 00       	push   $0x411
f0102362:	68 05 47 10 f0       	push   $0xf0104705
f0102367:	e8 23 dd ff ff       	call   f010008f <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010236c:	68 50 45 10 f0       	push   $0xf0104550
f0102371:	68 41 47 10 f0       	push   $0xf0104741
f0102376:	68 14 04 00 00       	push   $0x414
f010237b:	68 05 47 10 f0       	push   $0xf0104705
f0102380:	e8 0a dd ff ff       	call   f010008f <_panic>
	assert(!page_alloc(0));
f0102385:	68 97 48 10 f0       	push   $0xf0104897
f010238a:	68 41 47 10 f0       	push   $0xf0104741
f010238f:	68 17 04 00 00       	push   $0x417
f0102394:	68 05 47 10 f0       	push   $0xf0104705
f0102399:	e8 f1 dc ff ff       	call   f010008f <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010239e:	68 f4 41 10 f0       	push   $0xf01041f4
f01023a3:	68 41 47 10 f0       	push   $0xf0104741
f01023a8:	68 1a 04 00 00       	push   $0x41a
f01023ad:	68 05 47 10 f0       	push   $0xf0104705
f01023b2:	e8 d8 dc ff ff       	call   f010008f <_panic>
	assert(pp0->pp_ref == 1);
f01023b7:	68 fa 48 10 f0       	push   $0xf01048fa
f01023bc:	68 41 47 10 f0       	push   $0xf0104741
f01023c1:	68 1c 04 00 00       	push   $0x41c
f01023c6:	68 05 47 10 f0       	push   $0xf0104705
f01023cb:	e8 bf dc ff ff       	call   f010008f <_panic>
f01023d0:	56                   	push   %esi
f01023d1:	68 f4 3e 10 f0       	push   $0xf0103ef4
f01023d6:	68 23 04 00 00       	push   $0x423
f01023db:	68 05 47 10 f0       	push   $0xf0104705
f01023e0:	e8 aa dc ff ff       	call   f010008f <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023e5:	68 86 49 10 f0       	push   $0xf0104986
f01023ea:	68 41 47 10 f0       	push   $0xf0104741
f01023ef:	68 24 04 00 00       	push   $0x424
f01023f4:	68 05 47 10 f0       	push   $0xf0104705
f01023f9:	e8 91 dc ff ff       	call   f010008f <_panic>
f01023fe:	51                   	push   %ecx
f01023ff:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0102404:	6a 52                	push   $0x52
f0102406:	68 27 47 10 f0       	push   $0xf0104727
f010240b:	e8 7f dc ff ff       	call   f010008f <_panic>
f0102410:	52                   	push   %edx
f0102411:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0102416:	6a 52                	push   $0x52
f0102418:	68 27 47 10 f0       	push   $0xf0104727
f010241d:	e8 6d dc ff ff       	call   f010008f <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102422:	68 9e 49 10 f0       	push   $0xf010499e
f0102427:	68 41 47 10 f0       	push   $0xf0104741
f010242c:	68 2e 04 00 00       	push   $0x42e
f0102431:	68 05 47 10 f0       	push   $0xf0104705
f0102436:	e8 54 dc ff ff       	call   f010008f <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010243b:	50                   	push   %eax
f010243c:	68 00 40 10 f0       	push   $0xf0104000
f0102441:	68 00 01 00 00       	push   $0x100
f0102446:	68 05 47 10 f0       	push   $0xf0104705
f010244b:	e8 3f dc ff ff       	call   f010008f <_panic>
f0102450:	50                   	push   %eax
f0102451:	68 00 40 10 f0       	push   $0xf0104000
f0102456:	68 18 01 00 00       	push   $0x118
f010245b:	68 05 47 10 f0       	push   $0xf0104705
f0102460:	e8 2a dc ff ff       	call   f010008f <_panic>
f0102465:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102468:	68 00 40 10 f0       	push   $0xf0104000
f010246d:	68 6f 03 00 00       	push   $0x36f
f0102472:	68 05 47 10 f0       	push   $0xf0104705
f0102477:	e8 13 dc ff ff       	call   f010008f <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010247c:	68 74 45 10 f0       	push   $0xf0104574
f0102481:	68 41 47 10 f0       	push   $0xf0104741
f0102486:	68 6f 03 00 00       	push   $0x36f
f010248b:	68 05 47 10 f0       	push   $0xf0104705
f0102490:	e8 fa db ff ff       	call   f010008f <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102495:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102498:	c1 e0 0c             	shl    $0xc,%eax
f010249b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010249e:	89 f3                	mov    %esi,%ebx
f01024a0:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01024a3:	73 32                	jae    f01024d7 <mem_init+0x1363>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01024a5:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01024ab:	89 f8                	mov    %edi,%eax
f01024ad:	e8 f5 e4 ff ff       	call   f01009a7 <check_va2pa>
f01024b2:	39 c3                	cmp    %eax,%ebx
f01024b4:	75 08                	jne    f01024be <mem_init+0x134a>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01024b6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01024bc:	eb e2                	jmp    f01024a0 <mem_init+0x132c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01024be:	68 a8 45 10 f0       	push   $0xf01045a8
f01024c3:	68 41 47 10 f0       	push   $0xf0104741
f01024c8:	68 74 03 00 00       	push   $0x374
f01024cd:	68 05 47 10 f0       	push   $0xf0104705
f01024d2:	e8 b8 db ff ff       	call   f010008f <_panic>
f01024d7:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01024dc:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f01024e1:	05 00 80 00 20       	add    $0x20008000,%eax
f01024e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024e9:	89 da                	mov    %ebx,%edx
f01024eb:	89 f8                	mov    %edi,%eax
f01024ed:	e8 b5 e4 ff ff       	call   f01009a7 <check_va2pa>
f01024f2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01024f5:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01024f8:	39 c2                	cmp    %eax,%edx
f01024fa:	75 38                	jne    f0102534 <mem_init+0x13c0>
f01024fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102502:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102508:	75 df                	jne    f01024e9 <mem_init+0x1375>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010250a:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010250f:	89 f8                	mov    %edi,%eax
f0102511:	e8 91 e4 ff ff       	call   f01009a7 <check_va2pa>
f0102516:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102519:	74 5f                	je     f010257a <mem_init+0x1406>
f010251b:	68 18 46 10 f0       	push   $0xf0104618
f0102520:	68 41 47 10 f0       	push   $0xf0104741
f0102525:	68 79 03 00 00       	push   $0x379
f010252a:	68 05 47 10 f0       	push   $0xf0104705
f010252f:	e8 5b db ff ff       	call   f010008f <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102534:	68 d0 45 10 f0       	push   $0xf01045d0
f0102539:	68 41 47 10 f0       	push   $0xf0104741
f010253e:	68 78 03 00 00       	push   $0x378
f0102543:	68 05 47 10 f0       	push   $0xf0104705
f0102548:	e8 42 db ff ff       	call   f010008f <_panic>
		switch (i) {
f010254d:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102553:	75 25                	jne    f010257a <mem_init+0x1406>
			assert(pgdir[i] & PTE_P);
f0102555:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102559:	74 46                	je     f01025a1 <mem_init+0x142d>
	for (i = 0; i < NPDENTRIES; i++) {
f010255b:	83 c6 01             	add    $0x1,%esi
f010255e:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102564:	0f 87 8d 00 00 00    	ja     f01025f7 <mem_init+0x1483>
		switch (i) {
f010256a:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102570:	77 db                	ja     f010254d <mem_init+0x13d9>
f0102572:	81 fe bb 03 00 00    	cmp    $0x3bb,%esi
f0102578:	77 db                	ja     f0102555 <mem_init+0x13e1>
			if (i >= PDX(KERNBASE)) {
f010257a:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102580:	77 38                	ja     f01025ba <mem_init+0x1446>
				assert(pgdir[i] == 0);
f0102582:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102586:	74 d3                	je     f010255b <mem_init+0x13e7>
f0102588:	68 f0 49 10 f0       	push   $0xf01049f0
f010258d:	68 41 47 10 f0       	push   $0xf0104741
f0102592:	68 88 03 00 00       	push   $0x388
f0102597:	68 05 47 10 f0       	push   $0xf0104705
f010259c:	e8 ee da ff ff       	call   f010008f <_panic>
			assert(pgdir[i] & PTE_P);
f01025a1:	68 ce 49 10 f0       	push   $0xf01049ce
f01025a6:	68 41 47 10 f0       	push   $0xf0104741
f01025ab:	68 81 03 00 00       	push   $0x381
f01025b0:	68 05 47 10 f0       	push   $0xf0104705
f01025b5:	e8 d5 da ff ff       	call   f010008f <_panic>
				assert(pgdir[i] & PTE_P);
f01025ba:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f01025bd:	a8 01                	test   $0x1,%al
f01025bf:	74 1d                	je     f01025de <mem_init+0x146a>
				assert(pgdir[i] & PTE_W);
f01025c1:	a8 02                	test   $0x2,%al
f01025c3:	75 96                	jne    f010255b <mem_init+0x13e7>
f01025c5:	68 df 49 10 f0       	push   $0xf01049df
f01025ca:	68 41 47 10 f0       	push   $0xf0104741
f01025cf:	68 86 03 00 00       	push   $0x386
f01025d4:	68 05 47 10 f0       	push   $0xf0104705
f01025d9:	e8 b1 da ff ff       	call   f010008f <_panic>
				assert(pgdir[i] & PTE_P);
f01025de:	68 ce 49 10 f0       	push   $0xf01049ce
f01025e3:	68 41 47 10 f0       	push   $0xf0104741
f01025e8:	68 85 03 00 00       	push   $0x385
f01025ed:	68 05 47 10 f0       	push   $0xf0104705
f01025f2:	e8 98 da ff ff       	call   f010008f <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01025f7:	83 ec 0c             	sub    $0xc,%esp
f01025fa:	68 48 46 10 f0       	push   $0xf0104648
f01025ff:	e8 16 04 00 00       	call   f0102a1a <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102604:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102609:	83 c4 10             	add    $0x10,%esp
f010260c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102611:	0f 86 06 02 00 00    	jbe    f010281d <mem_init+0x16a9>
	return (physaddr_t)kva - KERNBASE;
f0102617:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010261c:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f010261f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102624:	e8 e1 e3 ff ff       	call   f0100a0a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102629:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010262c:	83 e0 f3             	and    $0xfffffff3,%eax
f010262f:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102634:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102637:	83 ec 0c             	sub    $0xc,%esp
f010263a:	6a 00                	push   $0x0
f010263c:	e8 92 e7 ff ff       	call   f0100dd3 <page_alloc>
f0102641:	89 c6                	mov    %eax,%esi
f0102643:	83 c4 10             	add    $0x10,%esp
f0102646:	85 c0                	test   %eax,%eax
f0102648:	0f 84 e4 01 00 00    	je     f0102832 <mem_init+0x16be>
	assert((pp1 = page_alloc(0)));
f010264e:	83 ec 0c             	sub    $0xc,%esp
f0102651:	6a 00                	push   $0x0
f0102653:	e8 7b e7 ff ff       	call   f0100dd3 <page_alloc>
f0102658:	89 c7                	mov    %eax,%edi
f010265a:	83 c4 10             	add    $0x10,%esp
f010265d:	85 c0                	test   %eax,%eax
f010265f:	0f 84 e6 01 00 00    	je     f010284b <mem_init+0x16d7>
	assert((pp2 = page_alloc(0)));
f0102665:	83 ec 0c             	sub    $0xc,%esp
f0102668:	6a 00                	push   $0x0
f010266a:	e8 64 e7 ff ff       	call   f0100dd3 <page_alloc>
f010266f:	89 c3                	mov    %eax,%ebx
f0102671:	83 c4 10             	add    $0x10,%esp
f0102674:	85 c0                	test   %eax,%eax
f0102676:	0f 84 e8 01 00 00    	je     f0102864 <mem_init+0x16f0>
	page_free(pp0);
f010267c:	83 ec 0c             	sub    $0xc,%esp
f010267f:	56                   	push   %esi
f0102680:	e8 c7 e7 ff ff       	call   f0100e4c <page_free>
	return (pp - pages) << PGSHIFT;
f0102685:	89 f8                	mov    %edi,%eax
f0102687:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010268d:	c1 f8 03             	sar    $0x3,%eax
f0102690:	89 c2                	mov    %eax,%edx
f0102692:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102695:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010269a:	83 c4 10             	add    $0x10,%esp
f010269d:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01026a3:	0f 83 d4 01 00 00    	jae    f010287d <mem_init+0x1709>
	memset(page2kva(pp1), 1, PGSIZE);
f01026a9:	83 ec 04             	sub    $0x4,%esp
f01026ac:	68 00 10 00 00       	push   $0x1000
f01026b1:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01026b3:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01026b9:	52                   	push   %edx
f01026ba:	e8 80 0e 00 00       	call   f010353f <memset>
	return (pp - pages) << PGSHIFT;
f01026bf:	89 d8                	mov    %ebx,%eax
f01026c1:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01026c7:	c1 f8 03             	sar    $0x3,%eax
f01026ca:	89 c2                	mov    %eax,%edx
f01026cc:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01026cf:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01026d4:	83 c4 10             	add    $0x10,%esp
f01026d7:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01026dd:	0f 83 ac 01 00 00    	jae    f010288f <mem_init+0x171b>
	memset(page2kva(pp2), 2, PGSIZE);
f01026e3:	83 ec 04             	sub    $0x4,%esp
f01026e6:	68 00 10 00 00       	push   $0x1000
f01026eb:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01026ed:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01026f3:	52                   	push   %edx
f01026f4:	e8 46 0e 00 00       	call   f010353f <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01026f9:	6a 02                	push   $0x2
f01026fb:	68 00 10 00 00       	push   $0x1000
f0102700:	57                   	push   %edi
f0102701:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0102707:	e8 e5 e9 ff ff       	call   f01010f1 <page_insert>
	assert(pp1->pp_ref == 1);
f010270c:	83 c4 20             	add    $0x20,%esp
f010270f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102714:	0f 85 87 01 00 00    	jne    f01028a1 <mem_init+0x172d>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010271a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102721:	01 01 01 
f0102724:	0f 85 90 01 00 00    	jne    f01028ba <mem_init+0x1746>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010272a:	6a 02                	push   $0x2
f010272c:	68 00 10 00 00       	push   $0x1000
f0102731:	53                   	push   %ebx
f0102732:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0102738:	e8 b4 e9 ff ff       	call   f01010f1 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010273d:	83 c4 10             	add    $0x10,%esp
f0102740:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102747:	02 02 02 
f010274a:	0f 85 83 01 00 00    	jne    f01028d3 <mem_init+0x175f>
	assert(pp2->pp_ref == 1);
f0102750:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102755:	0f 85 91 01 00 00    	jne    f01028ec <mem_init+0x1778>
	assert(pp1->pp_ref == 0);
f010275b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102760:	0f 85 9f 01 00 00    	jne    f0102905 <mem_init+0x1791>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102766:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010276d:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102770:	89 d8                	mov    %ebx,%eax
f0102772:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0102778:	c1 f8 03             	sar    $0x3,%eax
f010277b:	89 c2                	mov    %eax,%edx
f010277d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102780:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102785:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f010278b:	0f 83 8d 01 00 00    	jae    f010291e <mem_init+0x17aa>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102791:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102798:	03 03 03 
f010279b:	0f 85 8f 01 00 00    	jne    f0102930 <mem_init+0x17bc>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01027a1:	83 ec 08             	sub    $0x8,%esp
f01027a4:	68 00 10 00 00       	push   $0x1000
f01027a9:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01027af:	e8 fe e8 ff ff       	call   f01010b2 <page_remove>
	assert(pp2->pp_ref == 0);
f01027b4:	83 c4 10             	add    $0x10,%esp
f01027b7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01027bc:	0f 85 87 01 00 00    	jne    f0102949 <mem_init+0x17d5>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027c2:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f01027c8:	8b 11                	mov    (%ecx),%edx
f01027ca:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f01027d0:	89 f0                	mov    %esi,%eax
f01027d2:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01027d8:	c1 f8 03             	sar    $0x3,%eax
f01027db:	c1 e0 0c             	shl    $0xc,%eax
f01027de:	39 c2                	cmp    %eax,%edx
f01027e0:	0f 85 7c 01 00 00    	jne    f0102962 <mem_init+0x17ee>
	kern_pgdir[0] = 0;
f01027e6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01027ec:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027f1:	0f 85 84 01 00 00    	jne    f010297b <mem_init+0x1807>
	pp0->pp_ref = 0;
f01027f7:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01027fd:	83 ec 0c             	sub    $0xc,%esp
f0102800:	56                   	push   %esi
f0102801:	e8 46 e6 ff ff       	call   f0100e4c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102806:	c7 04 24 dc 46 10 f0 	movl   $0xf01046dc,(%esp)
f010280d:	e8 08 02 00 00       	call   f0102a1a <cprintf>
}
f0102812:	83 c4 10             	add    $0x10,%esp
f0102815:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102818:	5b                   	pop    %ebx
f0102819:	5e                   	pop    %esi
f010281a:	5f                   	pop    %edi
f010281b:	5d                   	pop    %ebp
f010281c:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010281d:	50                   	push   %eax
f010281e:	68 00 40 10 f0       	push   $0xf0104000
f0102823:	68 33 01 00 00       	push   $0x133
f0102828:	68 05 47 10 f0       	push   $0xf0104705
f010282d:	e8 5d d8 ff ff       	call   f010008f <_panic>
	assert((pp0 = page_alloc(0)));
f0102832:	68 ec 47 10 f0       	push   $0xf01047ec
f0102837:	68 41 47 10 f0       	push   $0xf0104741
f010283c:	68 49 04 00 00       	push   $0x449
f0102841:	68 05 47 10 f0       	push   $0xf0104705
f0102846:	e8 44 d8 ff ff       	call   f010008f <_panic>
	assert((pp1 = page_alloc(0)));
f010284b:	68 02 48 10 f0       	push   $0xf0104802
f0102850:	68 41 47 10 f0       	push   $0xf0104741
f0102855:	68 4a 04 00 00       	push   $0x44a
f010285a:	68 05 47 10 f0       	push   $0xf0104705
f010285f:	e8 2b d8 ff ff       	call   f010008f <_panic>
	assert((pp2 = page_alloc(0)));
f0102864:	68 18 48 10 f0       	push   $0xf0104818
f0102869:	68 41 47 10 f0       	push   $0xf0104741
f010286e:	68 4b 04 00 00       	push   $0x44b
f0102873:	68 05 47 10 f0       	push   $0xf0104705
f0102878:	e8 12 d8 ff ff       	call   f010008f <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010287d:	52                   	push   %edx
f010287e:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0102883:	6a 52                	push   $0x52
f0102885:	68 27 47 10 f0       	push   $0xf0104727
f010288a:	e8 00 d8 ff ff       	call   f010008f <_panic>
f010288f:	52                   	push   %edx
f0102890:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0102895:	6a 52                	push   $0x52
f0102897:	68 27 47 10 f0       	push   $0xf0104727
f010289c:	e8 ee d7 ff ff       	call   f010008f <_panic>
	assert(pp1->pp_ref == 1);
f01028a1:	68 e9 48 10 f0       	push   $0xf01048e9
f01028a6:	68 41 47 10 f0       	push   $0xf0104741
f01028ab:	68 50 04 00 00       	push   $0x450
f01028b0:	68 05 47 10 f0       	push   $0xf0104705
f01028b5:	e8 d5 d7 ff ff       	call   f010008f <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01028ba:	68 68 46 10 f0       	push   $0xf0104668
f01028bf:	68 41 47 10 f0       	push   $0xf0104741
f01028c4:	68 51 04 00 00       	push   $0x451
f01028c9:	68 05 47 10 f0       	push   $0xf0104705
f01028ce:	e8 bc d7 ff ff       	call   f010008f <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01028d3:	68 8c 46 10 f0       	push   $0xf010468c
f01028d8:	68 41 47 10 f0       	push   $0xf0104741
f01028dd:	68 53 04 00 00       	push   $0x453
f01028e2:	68 05 47 10 f0       	push   $0xf0104705
f01028e7:	e8 a3 d7 ff ff       	call   f010008f <_panic>
	assert(pp2->pp_ref == 1);
f01028ec:	68 0b 49 10 f0       	push   $0xf010490b
f01028f1:	68 41 47 10 f0       	push   $0xf0104741
f01028f6:	68 54 04 00 00       	push   $0x454
f01028fb:	68 05 47 10 f0       	push   $0xf0104705
f0102900:	e8 8a d7 ff ff       	call   f010008f <_panic>
	assert(pp1->pp_ref == 0);
f0102905:	68 75 49 10 f0       	push   $0xf0104975
f010290a:	68 41 47 10 f0       	push   $0xf0104741
f010290f:	68 55 04 00 00       	push   $0x455
f0102914:	68 05 47 10 f0       	push   $0xf0104705
f0102919:	e8 71 d7 ff ff       	call   f010008f <_panic>
f010291e:	52                   	push   %edx
f010291f:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0102924:	6a 52                	push   $0x52
f0102926:	68 27 47 10 f0       	push   $0xf0104727
f010292b:	e8 5f d7 ff ff       	call   f010008f <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102930:	68 b0 46 10 f0       	push   $0xf01046b0
f0102935:	68 41 47 10 f0       	push   $0xf0104741
f010293a:	68 57 04 00 00       	push   $0x457
f010293f:	68 05 47 10 f0       	push   $0xf0104705
f0102944:	e8 46 d7 ff ff       	call   f010008f <_panic>
	assert(pp2->pp_ref == 0);
f0102949:	68 43 49 10 f0       	push   $0xf0104943
f010294e:	68 41 47 10 f0       	push   $0xf0104741
f0102953:	68 59 04 00 00       	push   $0x459
f0102958:	68 05 47 10 f0       	push   $0xf0104705
f010295d:	e8 2d d7 ff ff       	call   f010008f <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102962:	68 f4 41 10 f0       	push   $0xf01041f4
f0102967:	68 41 47 10 f0       	push   $0xf0104741
f010296c:	68 5c 04 00 00       	push   $0x45c
f0102971:	68 05 47 10 f0       	push   $0xf0104705
f0102976:	e8 14 d7 ff ff       	call   f010008f <_panic>
	assert(pp0->pp_ref == 1);
f010297b:	68 fa 48 10 f0       	push   $0xf01048fa
f0102980:	68 41 47 10 f0       	push   $0xf0104741
f0102985:	68 5e 04 00 00       	push   $0x45e
f010298a:	68 05 47 10 f0       	push   $0xf0104705
f010298f:	e8 fb d6 ff ff       	call   f010008f <_panic>

f0102994 <tlb_invalidate>:
{
f0102994:	f3 0f 1e fb          	endbr32 
f0102998:	55                   	push   %ebp
f0102999:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010299b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010299e:	0f 01 38             	invlpg (%eax)
}
f01029a1:	5d                   	pop    %ebp
f01029a2:	c3                   	ret    

f01029a3 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01029a3:	f3 0f 1e fb          	endbr32 
f01029a7:	55                   	push   %ebp
f01029a8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01029aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01029ad:	ba 70 00 00 00       	mov    $0x70,%edx
f01029b2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01029b3:	ba 71 00 00 00       	mov    $0x71,%edx
f01029b8:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01029b9:	0f b6 c0             	movzbl %al,%eax
}
f01029bc:	5d                   	pop    %ebp
f01029bd:	c3                   	ret    

f01029be <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01029be:	f3 0f 1e fb          	endbr32 
f01029c2:	55                   	push   %ebp
f01029c3:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01029c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01029c8:	ba 70 00 00 00       	mov    $0x70,%edx
f01029cd:	ee                   	out    %al,(%dx)
f01029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029d1:	ba 71 00 00 00       	mov    $0x71,%edx
f01029d6:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01029d7:	5d                   	pop    %ebp
f01029d8:	c3                   	ret    

f01029d9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01029d9:	f3 0f 1e fb          	endbr32 
f01029dd:	55                   	push   %ebp
f01029de:	89 e5                	mov    %esp,%ebp
f01029e0:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01029e3:	ff 75 08             	pushl  0x8(%ebp)
f01029e6:	e8 35 dc ff ff       	call   f0100620 <cputchar>
	*cnt++;
}
f01029eb:	83 c4 10             	add    $0x10,%esp
f01029ee:	c9                   	leave  
f01029ef:	c3                   	ret    

f01029f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01029f0:	f3 0f 1e fb          	endbr32 
f01029f4:	55                   	push   %ebp
f01029f5:	89 e5                	mov    %esp,%ebp
f01029f7:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01029fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102a01:	ff 75 0c             	pushl  0xc(%ebp)
f0102a04:	ff 75 08             	pushl  0x8(%ebp)
f0102a07:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102a0a:	50                   	push   %eax
f0102a0b:	68 d9 29 10 f0       	push   $0xf01029d9
f0102a10:	e8 d3 03 00 00       	call   f0102de8 <vprintfmt>
	return cnt;
}
f0102a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a18:	c9                   	leave  
f0102a19:	c3                   	ret    

f0102a1a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102a1a:	f3 0f 1e fb          	endbr32 
f0102a1e:	55                   	push   %ebp
f0102a1f:	89 e5                	mov    %esp,%ebp
f0102a21:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102a24:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102a27:	50                   	push   %eax
f0102a28:	ff 75 08             	pushl  0x8(%ebp)
f0102a2b:	e8 c0 ff ff ff       	call   f01029f0 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102a30:	c9                   	leave  
f0102a31:	c3                   	ret    

f0102a32 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102a32:	55                   	push   %ebp
f0102a33:	89 e5                	mov    %esp,%ebp
f0102a35:	57                   	push   %edi
f0102a36:	56                   	push   %esi
f0102a37:	53                   	push   %ebx
f0102a38:	83 ec 14             	sub    $0x14,%esp
f0102a3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102a3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102a41:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102a44:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102a47:	8b 1a                	mov    (%edx),%ebx
f0102a49:	8b 01                	mov    (%ecx),%eax
f0102a4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102a4e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102a55:	eb 23                	jmp    f0102a7a <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102a57:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102a5a:	eb 1e                	jmp    f0102a7a <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102a5c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102a5f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102a62:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102a66:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102a69:	73 46                	jae    f0102ab1 <stab_binsearch+0x7f>
			*region_left = m;
f0102a6b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102a6e:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102a70:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0102a73:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102a7a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102a7d:	7f 5f                	jg     f0102ade <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0102a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102a82:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0102a85:	89 d0                	mov    %edx,%eax
f0102a87:	c1 e8 1f             	shr    $0x1f,%eax
f0102a8a:	01 d0                	add    %edx,%eax
f0102a8c:	89 c7                	mov    %eax,%edi
f0102a8e:	d1 ff                	sar    %edi
f0102a90:	83 e0 fe             	and    $0xfffffffe,%eax
f0102a93:	01 f8                	add    %edi,%eax
f0102a95:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102a98:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102a9c:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0102a9e:	39 c3                	cmp    %eax,%ebx
f0102aa0:	7f b5                	jg     f0102a57 <stab_binsearch+0x25>
f0102aa2:	0f b6 0a             	movzbl (%edx),%ecx
f0102aa5:	83 ea 0c             	sub    $0xc,%edx
f0102aa8:	39 f1                	cmp    %esi,%ecx
f0102aaa:	74 b0                	je     f0102a5c <stab_binsearch+0x2a>
			m--;
f0102aac:	83 e8 01             	sub    $0x1,%eax
f0102aaf:	eb ed                	jmp    f0102a9e <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0102ab1:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102ab4:	76 14                	jbe    f0102aca <stab_binsearch+0x98>
			*region_right = m - 1;
f0102ab6:	83 e8 01             	sub    $0x1,%eax
f0102ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102abc:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102abf:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0102ac1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102ac8:	eb b0                	jmp    f0102a7a <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102aca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102acd:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0102acf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102ad3:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0102ad5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102adc:	eb 9c                	jmp    f0102a7a <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0102ade:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102ae2:	75 15                	jne    f0102af9 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0102ae4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102ae7:	8b 00                	mov    (%eax),%eax
f0102ae9:	83 e8 01             	sub    $0x1,%eax
f0102aec:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102aef:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102af1:	83 c4 14             	add    $0x14,%esp
f0102af4:	5b                   	pop    %ebx
f0102af5:	5e                   	pop    %esi
f0102af6:	5f                   	pop    %edi
f0102af7:	5d                   	pop    %ebp
f0102af8:	c3                   	ret    
		for (l = *region_right;
f0102af9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102afc:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102afe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102b01:	8b 0f                	mov    (%edi),%ecx
f0102b03:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102b06:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102b09:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0102b0d:	eb 03                	jmp    f0102b12 <stab_binsearch+0xe0>
		     l--)
f0102b0f:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0102b12:	39 c1                	cmp    %eax,%ecx
f0102b14:	7d 0a                	jge    f0102b20 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0102b16:	0f b6 1a             	movzbl (%edx),%ebx
f0102b19:	83 ea 0c             	sub    $0xc,%edx
f0102b1c:	39 f3                	cmp    %esi,%ebx
f0102b1e:	75 ef                	jne    f0102b0f <stab_binsearch+0xdd>
		*region_left = l;
f0102b20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102b23:	89 07                	mov    %eax,(%edi)
}
f0102b25:	eb ca                	jmp    f0102af1 <stab_binsearch+0xbf>

f0102b27 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102b27:	f3 0f 1e fb          	endbr32 
f0102b2b:	55                   	push   %ebp
f0102b2c:	89 e5                	mov    %esp,%ebp
f0102b2e:	57                   	push   %edi
f0102b2f:	56                   	push   %esi
f0102b30:	53                   	push   %ebx
f0102b31:	83 ec 1c             	sub    $0x1c,%esp
f0102b34:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102b37:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102b3a:	c7 06 fe 49 10 f0    	movl   $0xf01049fe,(%esi)
	info->eip_line = 0;
f0102b40:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0102b47:	c7 46 08 fe 49 10 f0 	movl   $0xf01049fe,0x8(%esi)
	info->eip_fn_namelen = 9;
f0102b4e:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0102b55:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0102b58:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102b5f:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0102b65:	0f 86 db 00 00 00    	jbe    f0102c46 <debuginfo_eip+0x11f>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102b6b:	b8 a4 dd 10 f0       	mov    $0xf010dda4,%eax
f0102b70:	3d 01 bf 10 f0       	cmp    $0xf010bf01,%eax
f0102b75:	0f 86 5e 01 00 00    	jbe    f0102cd9 <debuginfo_eip+0x1b2>
f0102b7b:	80 3d a3 dd 10 f0 00 	cmpb   $0x0,0xf010dda3
f0102b82:	0f 85 58 01 00 00    	jne    f0102ce0 <debuginfo_eip+0x1b9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102b88:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102b8f:	b8 00 bf 10 f0       	mov    $0xf010bf00,%eax
f0102b94:	2d 34 4c 10 f0       	sub    $0xf0104c34,%eax
f0102b99:	c1 f8 02             	sar    $0x2,%eax
f0102b9c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102ba2:	83 e8 01             	sub    $0x1,%eax
f0102ba5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102ba8:	83 ec 08             	sub    $0x8,%esp
f0102bab:	57                   	push   %edi
f0102bac:	6a 64                	push   $0x64
f0102bae:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102bb1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102bb4:	b8 34 4c 10 f0       	mov    $0xf0104c34,%eax
f0102bb9:	e8 74 fe ff ff       	call   f0102a32 <stab_binsearch>
	if (lfile == 0)
f0102bbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bc1:	83 c4 10             	add    $0x10,%esp
f0102bc4:	85 c0                	test   %eax,%eax
f0102bc6:	0f 84 1b 01 00 00    	je     f0102ce7 <debuginfo_eip+0x1c0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102bcc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102bcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102bd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102bd5:	83 ec 08             	sub    $0x8,%esp
f0102bd8:	57                   	push   %edi
f0102bd9:	6a 24                	push   $0x24
f0102bdb:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102bde:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102be1:	b8 34 4c 10 f0       	mov    $0xf0104c34,%eax
f0102be6:	e8 47 fe ff ff       	call   f0102a32 <stab_binsearch>

	if (lfun <= rfun) {
f0102beb:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0102bee:	83 c4 10             	add    $0x10,%esp
f0102bf1:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0102bf4:	7f 64                	jg     f0102c5a <debuginfo_eip+0x133>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102bf6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102bf9:	c1 e0 02             	shl    $0x2,%eax
f0102bfc:	8d 90 34 4c 10 f0    	lea    -0xfefb3cc(%eax),%edx
f0102c02:	8b 88 34 4c 10 f0    	mov    -0xfefb3cc(%eax),%ecx
f0102c08:	b8 a4 dd 10 f0       	mov    $0xf010dda4,%eax
f0102c0d:	2d 01 bf 10 f0       	sub    $0xf010bf01,%eax
f0102c12:	39 c1                	cmp    %eax,%ecx
f0102c14:	73 09                	jae    f0102c1f <debuginfo_eip+0xf8>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102c16:	81 c1 01 bf 10 f0    	add    $0xf010bf01,%ecx
f0102c1c:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102c1f:	8b 42 08             	mov    0x8(%edx),%eax
f0102c22:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102c25:	83 ec 08             	sub    $0x8,%esp
f0102c28:	6a 3a                	push   $0x3a
f0102c2a:	ff 76 08             	pushl  0x8(%esi)
f0102c2d:	e8 ed 08 00 00       	call   f010351f <strfind>
f0102c32:	2b 46 08             	sub    0x8(%esi),%eax
f0102c35:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102c38:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102c3b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102c3e:	c1 e0 02             	shl    $0x2,%eax
f0102c41:	83 c4 10             	add    $0x10,%esp
f0102c44:	eb 22                	jmp    f0102c68 <debuginfo_eip+0x141>
  	        panic("User address");
f0102c46:	83 ec 04             	sub    $0x4,%esp
f0102c49:	68 08 4a 10 f0       	push   $0xf0104a08
f0102c4e:	6a 7f                	push   $0x7f
f0102c50:	68 15 4a 10 f0       	push   $0xf0104a15
f0102c55:	e8 35 d4 ff ff       	call   f010008f <_panic>
		info->eip_fn_addr = addr;
f0102c5a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0102c5d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102c60:	eb c3                	jmp    f0102c25 <debuginfo_eip+0xfe>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102c62:	83 eb 01             	sub    $0x1,%ebx
f0102c65:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0102c68:	39 d9                	cmp    %ebx,%ecx
f0102c6a:	7f 3a                	jg     f0102ca6 <debuginfo_eip+0x17f>
	       && stabs[lline].n_type != N_SOL
f0102c6c:	0f b6 90 38 4c 10 f0 	movzbl -0xfefb3c8(%eax),%edx
f0102c73:	80 fa 84             	cmp    $0x84,%dl
f0102c76:	74 0e                	je     f0102c86 <debuginfo_eip+0x15f>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102c78:	80 fa 64             	cmp    $0x64,%dl
f0102c7b:	75 e5                	jne    f0102c62 <debuginfo_eip+0x13b>
f0102c7d:	83 b8 3c 4c 10 f0 00 	cmpl   $0x0,-0xfefb3c4(%eax)
f0102c84:	74 dc                	je     f0102c62 <debuginfo_eip+0x13b>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102c86:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102c89:	8b 14 85 34 4c 10 f0 	mov    -0xfefb3cc(,%eax,4),%edx
f0102c90:	b8 a4 dd 10 f0       	mov    $0xf010dda4,%eax
f0102c95:	2d 01 bf 10 f0       	sub    $0xf010bf01,%eax
f0102c9a:	39 c2                	cmp    %eax,%edx
f0102c9c:	73 08                	jae    f0102ca6 <debuginfo_eip+0x17f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102c9e:	81 c2 01 bf 10 f0    	add    $0xf010bf01,%edx
f0102ca4:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102ca6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102ca9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102cac:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0102cb1:	39 c8                	cmp    %ecx,%eax
f0102cb3:	7d 3e                	jge    f0102cf3 <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
f0102cb5:	83 c0 01             	add    $0x1,%eax
f0102cb8:	eb 07                	jmp    f0102cc1 <debuginfo_eip+0x19a>
			info->eip_fn_narg++;
f0102cba:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline++)
f0102cbe:	83 c0 01             	add    $0x1,%eax
		for (lline = lfun + 1;
f0102cc1:	39 c1                	cmp    %eax,%ecx
f0102cc3:	74 29                	je     f0102cee <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102cc5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102cc8:	80 3c 95 38 4c 10 f0 	cmpb   $0xa0,-0xfefb3c8(,%edx,4)
f0102ccf:	a0 
f0102cd0:	74 e8                	je     f0102cba <debuginfo_eip+0x193>
	return 0;
f0102cd2:	ba 00 00 00 00       	mov    $0x0,%edx
f0102cd7:	eb 1a                	jmp    f0102cf3 <debuginfo_eip+0x1cc>
		return -1;
f0102cd9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0102cde:	eb 13                	jmp    f0102cf3 <debuginfo_eip+0x1cc>
f0102ce0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0102ce5:	eb 0c                	jmp    f0102cf3 <debuginfo_eip+0x1cc>
		return -1;
f0102ce7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0102cec:	eb 05                	jmp    f0102cf3 <debuginfo_eip+0x1cc>
	return 0;
f0102cee:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102cf3:	89 d0                	mov    %edx,%eax
f0102cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cf8:	5b                   	pop    %ebx
f0102cf9:	5e                   	pop    %esi
f0102cfa:	5f                   	pop    %edi
f0102cfb:	5d                   	pop    %ebp
f0102cfc:	c3                   	ret    

f0102cfd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102cfd:	55                   	push   %ebp
f0102cfe:	89 e5                	mov    %esp,%ebp
f0102d00:	57                   	push   %edi
f0102d01:	56                   	push   %esi
f0102d02:	53                   	push   %ebx
f0102d03:	83 ec 1c             	sub    $0x1c,%esp
f0102d06:	89 c7                	mov    %eax,%edi
f0102d08:	89 d6                	mov    %edx,%esi
f0102d0a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d0d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102d10:	89 d1                	mov    %edx,%ecx
f0102d12:	89 c2                	mov    %eax,%edx
f0102d14:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d17:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102d1a:	8b 45 10             	mov    0x10(%ebp),%eax
f0102d1d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102d20:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d23:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102d2a:	39 c2                	cmp    %eax,%edx
f0102d2c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0102d2f:	72 3e                	jb     f0102d6f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102d31:	83 ec 0c             	sub    $0xc,%esp
f0102d34:	ff 75 18             	pushl  0x18(%ebp)
f0102d37:	83 eb 01             	sub    $0x1,%ebx
f0102d3a:	53                   	push   %ebx
f0102d3b:	50                   	push   %eax
f0102d3c:	83 ec 08             	sub    $0x8,%esp
f0102d3f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102d42:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d45:	ff 75 dc             	pushl  -0x24(%ebp)
f0102d48:	ff 75 d8             	pushl  -0x28(%ebp)
f0102d4b:	e8 00 0a 00 00       	call   f0103750 <__udivdi3>
f0102d50:	83 c4 18             	add    $0x18,%esp
f0102d53:	52                   	push   %edx
f0102d54:	50                   	push   %eax
f0102d55:	89 f2                	mov    %esi,%edx
f0102d57:	89 f8                	mov    %edi,%eax
f0102d59:	e8 9f ff ff ff       	call   f0102cfd <printnum>
f0102d5e:	83 c4 20             	add    $0x20,%esp
f0102d61:	eb 13                	jmp    f0102d76 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102d63:	83 ec 08             	sub    $0x8,%esp
f0102d66:	56                   	push   %esi
f0102d67:	ff 75 18             	pushl  0x18(%ebp)
f0102d6a:	ff d7                	call   *%edi
f0102d6c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102d6f:	83 eb 01             	sub    $0x1,%ebx
f0102d72:	85 db                	test   %ebx,%ebx
f0102d74:	7f ed                	jg     f0102d63 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102d76:	83 ec 08             	sub    $0x8,%esp
f0102d79:	56                   	push   %esi
f0102d7a:	83 ec 04             	sub    $0x4,%esp
f0102d7d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102d80:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d83:	ff 75 dc             	pushl  -0x24(%ebp)
f0102d86:	ff 75 d8             	pushl  -0x28(%ebp)
f0102d89:	e8 d2 0a 00 00       	call   f0103860 <__umoddi3>
f0102d8e:	83 c4 14             	add    $0x14,%esp
f0102d91:	0f be 80 23 4a 10 f0 	movsbl -0xfefb5dd(%eax),%eax
f0102d98:	50                   	push   %eax
f0102d99:	ff d7                	call   *%edi
}
f0102d9b:	83 c4 10             	add    $0x10,%esp
f0102d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102da1:	5b                   	pop    %ebx
f0102da2:	5e                   	pop    %esi
f0102da3:	5f                   	pop    %edi
f0102da4:	5d                   	pop    %ebp
f0102da5:	c3                   	ret    

f0102da6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102da6:	f3 0f 1e fb          	endbr32 
f0102daa:	55                   	push   %ebp
f0102dab:	89 e5                	mov    %esp,%ebp
f0102dad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102db0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102db4:	8b 10                	mov    (%eax),%edx
f0102db6:	3b 50 04             	cmp    0x4(%eax),%edx
f0102db9:	73 0a                	jae    f0102dc5 <sprintputch+0x1f>
		*b->buf++ = ch;
f0102dbb:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102dbe:	89 08                	mov    %ecx,(%eax)
f0102dc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102dc3:	88 02                	mov    %al,(%edx)
}
f0102dc5:	5d                   	pop    %ebp
f0102dc6:	c3                   	ret    

f0102dc7 <printfmt>:
{
f0102dc7:	f3 0f 1e fb          	endbr32 
f0102dcb:	55                   	push   %ebp
f0102dcc:	89 e5                	mov    %esp,%ebp
f0102dce:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0102dd1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102dd4:	50                   	push   %eax
f0102dd5:	ff 75 10             	pushl  0x10(%ebp)
f0102dd8:	ff 75 0c             	pushl  0xc(%ebp)
f0102ddb:	ff 75 08             	pushl  0x8(%ebp)
f0102dde:	e8 05 00 00 00       	call   f0102de8 <vprintfmt>
}
f0102de3:	83 c4 10             	add    $0x10,%esp
f0102de6:	c9                   	leave  
f0102de7:	c3                   	ret    

f0102de8 <vprintfmt>:
{
f0102de8:	f3 0f 1e fb          	endbr32 
f0102dec:	55                   	push   %ebp
f0102ded:	89 e5                	mov    %esp,%ebp
f0102def:	57                   	push   %edi
f0102df0:	56                   	push   %esi
f0102df1:	53                   	push   %ebx
f0102df2:	83 ec 3c             	sub    $0x3c,%esp
f0102df5:	8b 75 08             	mov    0x8(%ebp),%esi
f0102df8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102dfb:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102dfe:	e9 8e 03 00 00       	jmp    f0103191 <vprintfmt+0x3a9>
		padc = ' ';
f0102e03:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0102e07:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0102e0e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0102e15:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0102e1c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102e21:	8d 47 01             	lea    0x1(%edi),%eax
f0102e24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102e27:	0f b6 17             	movzbl (%edi),%edx
f0102e2a:	8d 42 dd             	lea    -0x23(%edx),%eax
f0102e2d:	3c 55                	cmp    $0x55,%al
f0102e2f:	0f 87 df 03 00 00    	ja     f0103214 <vprintfmt+0x42c>
f0102e35:	0f b6 c0             	movzbl %al,%eax
f0102e38:	3e ff 24 85 b0 4a 10 	notrack jmp *-0xfefb550(,%eax,4)
f0102e3f:	f0 
f0102e40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0102e43:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0102e47:	eb d8                	jmp    f0102e21 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0102e49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e4c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0102e50:	eb cf                	jmp    f0102e21 <vprintfmt+0x39>
f0102e52:	0f b6 d2             	movzbl %dl,%edx
f0102e55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0102e58:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e5d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0102e60:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102e63:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0102e67:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102e6a:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102e6d:	83 f9 09             	cmp    $0x9,%ecx
f0102e70:	77 55                	ja     f0102ec7 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0102e72:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0102e75:	eb e9                	jmp    f0102e60 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0102e77:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e7a:	8b 00                	mov    (%eax),%eax
f0102e7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e82:	8d 40 04             	lea    0x4(%eax),%eax
f0102e85:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0102e88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0102e8b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102e8f:	79 90                	jns    f0102e21 <vprintfmt+0x39>
				width = precision, precision = -1;
f0102e91:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e94:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102e97:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0102e9e:	eb 81                	jmp    f0102e21 <vprintfmt+0x39>
f0102ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ea3:	85 c0                	test   %eax,%eax
f0102ea5:	ba 00 00 00 00       	mov    $0x0,%edx
f0102eaa:	0f 49 d0             	cmovns %eax,%edx
f0102ead:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0102eb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102eb3:	e9 69 ff ff ff       	jmp    f0102e21 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0102eb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0102ebb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0102ec2:	e9 5a ff ff ff       	jmp    f0102e21 <vprintfmt+0x39>
f0102ec7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102eca:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102ecd:	eb bc                	jmp    f0102e8b <vprintfmt+0xa3>
			lflag++;
f0102ecf:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102ed2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102ed5:	e9 47 ff ff ff       	jmp    f0102e21 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f0102eda:	8b 45 14             	mov    0x14(%ebp),%eax
f0102edd:	8d 78 04             	lea    0x4(%eax),%edi
f0102ee0:	83 ec 08             	sub    $0x8,%esp
f0102ee3:	53                   	push   %ebx
f0102ee4:	ff 30                	pushl  (%eax)
f0102ee6:	ff d6                	call   *%esi
			break;
f0102ee8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0102eeb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0102eee:	e9 9b 02 00 00       	jmp    f010318e <vprintfmt+0x3a6>
			err = va_arg(ap, int);
f0102ef3:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ef6:	8d 78 04             	lea    0x4(%eax),%edi
f0102ef9:	8b 00                	mov    (%eax),%eax
f0102efb:	99                   	cltd   
f0102efc:	31 d0                	xor    %edx,%eax
f0102efe:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102f00:	83 f8 06             	cmp    $0x6,%eax
f0102f03:	7f 23                	jg     f0102f28 <vprintfmt+0x140>
f0102f05:	8b 14 85 08 4c 10 f0 	mov    -0xfefb3f8(,%eax,4),%edx
f0102f0c:	85 d2                	test   %edx,%edx
f0102f0e:	74 18                	je     f0102f28 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f0102f10:	52                   	push   %edx
f0102f11:	68 53 47 10 f0       	push   $0xf0104753
f0102f16:	53                   	push   %ebx
f0102f17:	56                   	push   %esi
f0102f18:	e8 aa fe ff ff       	call   f0102dc7 <printfmt>
f0102f1d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102f20:	89 7d 14             	mov    %edi,0x14(%ebp)
f0102f23:	e9 66 02 00 00       	jmp    f010318e <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
f0102f28:	50                   	push   %eax
f0102f29:	68 3b 4a 10 f0       	push   $0xf0104a3b
f0102f2e:	53                   	push   %ebx
f0102f2f:	56                   	push   %esi
f0102f30:	e8 92 fe ff ff       	call   f0102dc7 <printfmt>
f0102f35:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102f38:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0102f3b:	e9 4e 02 00 00       	jmp    f010318e <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
f0102f40:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f43:	83 c0 04             	add    $0x4,%eax
f0102f46:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102f49:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f4c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0102f4e:	85 d2                	test   %edx,%edx
f0102f50:	b8 34 4a 10 f0       	mov    $0xf0104a34,%eax
f0102f55:	0f 45 c2             	cmovne %edx,%eax
f0102f58:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0102f5b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102f5f:	7e 06                	jle    f0102f67 <vprintfmt+0x17f>
f0102f61:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0102f65:	75 0d                	jne    f0102f74 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102f67:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102f6a:	89 c7                	mov    %eax,%edi
f0102f6c:	03 45 e0             	add    -0x20(%ebp),%eax
f0102f6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102f72:	eb 55                	jmp    f0102fc9 <vprintfmt+0x1e1>
f0102f74:	83 ec 08             	sub    $0x8,%esp
f0102f77:	ff 75 d8             	pushl  -0x28(%ebp)
f0102f7a:	ff 75 cc             	pushl  -0x34(%ebp)
f0102f7d:	e8 2c 04 00 00       	call   f01033ae <strnlen>
f0102f82:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102f85:	29 c2                	sub    %eax,%edx
f0102f87:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0102f8a:	83 c4 10             	add    $0x10,%esp
f0102f8d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0102f8f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0102f93:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0102f96:	85 ff                	test   %edi,%edi
f0102f98:	7e 11                	jle    f0102fab <vprintfmt+0x1c3>
					putch(padc, putdat);
f0102f9a:	83 ec 08             	sub    $0x8,%esp
f0102f9d:	53                   	push   %ebx
f0102f9e:	ff 75 e0             	pushl  -0x20(%ebp)
f0102fa1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0102fa3:	83 ef 01             	sub    $0x1,%edi
f0102fa6:	83 c4 10             	add    $0x10,%esp
f0102fa9:	eb eb                	jmp    f0102f96 <vprintfmt+0x1ae>
f0102fab:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102fae:	85 d2                	test   %edx,%edx
f0102fb0:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fb5:	0f 49 c2             	cmovns %edx,%eax
f0102fb8:	29 c2                	sub    %eax,%edx
f0102fba:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0102fbd:	eb a8                	jmp    f0102f67 <vprintfmt+0x17f>
					putch(ch, putdat);
f0102fbf:	83 ec 08             	sub    $0x8,%esp
f0102fc2:	53                   	push   %ebx
f0102fc3:	52                   	push   %edx
f0102fc4:	ff d6                	call   *%esi
f0102fc6:	83 c4 10             	add    $0x10,%esp
f0102fc9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102fcc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102fce:	83 c7 01             	add    $0x1,%edi
f0102fd1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102fd5:	0f be d0             	movsbl %al,%edx
f0102fd8:	85 d2                	test   %edx,%edx
f0102fda:	74 4b                	je     f0103027 <vprintfmt+0x23f>
f0102fdc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102fe0:	78 06                	js     f0102fe8 <vprintfmt+0x200>
f0102fe2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0102fe6:	78 1e                	js     f0103006 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f0102fe8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0102fec:	74 d1                	je     f0102fbf <vprintfmt+0x1d7>
f0102fee:	0f be c0             	movsbl %al,%eax
f0102ff1:	83 e8 20             	sub    $0x20,%eax
f0102ff4:	83 f8 5e             	cmp    $0x5e,%eax
f0102ff7:	76 c6                	jbe    f0102fbf <vprintfmt+0x1d7>
					putch('?', putdat);
f0102ff9:	83 ec 08             	sub    $0x8,%esp
f0102ffc:	53                   	push   %ebx
f0102ffd:	6a 3f                	push   $0x3f
f0102fff:	ff d6                	call   *%esi
f0103001:	83 c4 10             	add    $0x10,%esp
f0103004:	eb c3                	jmp    f0102fc9 <vprintfmt+0x1e1>
f0103006:	89 cf                	mov    %ecx,%edi
f0103008:	eb 0e                	jmp    f0103018 <vprintfmt+0x230>
				putch(' ', putdat);
f010300a:	83 ec 08             	sub    $0x8,%esp
f010300d:	53                   	push   %ebx
f010300e:	6a 20                	push   $0x20
f0103010:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103012:	83 ef 01             	sub    $0x1,%edi
f0103015:	83 c4 10             	add    $0x10,%esp
f0103018:	85 ff                	test   %edi,%edi
f010301a:	7f ee                	jg     f010300a <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f010301c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010301f:	89 45 14             	mov    %eax,0x14(%ebp)
f0103022:	e9 67 01 00 00       	jmp    f010318e <vprintfmt+0x3a6>
f0103027:	89 cf                	mov    %ecx,%edi
f0103029:	eb ed                	jmp    f0103018 <vprintfmt+0x230>
	if (lflag >= 2)
f010302b:	83 f9 01             	cmp    $0x1,%ecx
f010302e:	7f 1b                	jg     f010304b <vprintfmt+0x263>
	else if (lflag)
f0103030:	85 c9                	test   %ecx,%ecx
f0103032:	74 63                	je     f0103097 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f0103034:	8b 45 14             	mov    0x14(%ebp),%eax
f0103037:	8b 00                	mov    (%eax),%eax
f0103039:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010303c:	99                   	cltd   
f010303d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103040:	8b 45 14             	mov    0x14(%ebp),%eax
f0103043:	8d 40 04             	lea    0x4(%eax),%eax
f0103046:	89 45 14             	mov    %eax,0x14(%ebp)
f0103049:	eb 17                	jmp    f0103062 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f010304b:	8b 45 14             	mov    0x14(%ebp),%eax
f010304e:	8b 50 04             	mov    0x4(%eax),%edx
f0103051:	8b 00                	mov    (%eax),%eax
f0103053:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103056:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103059:	8b 45 14             	mov    0x14(%ebp),%eax
f010305c:	8d 40 08             	lea    0x8(%eax),%eax
f010305f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103062:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103065:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0103068:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010306d:	85 c9                	test   %ecx,%ecx
f010306f:	0f 89 ff 00 00 00    	jns    f0103174 <vprintfmt+0x38c>
				putch('-', putdat);
f0103075:	83 ec 08             	sub    $0x8,%esp
f0103078:	53                   	push   %ebx
f0103079:	6a 2d                	push   $0x2d
f010307b:	ff d6                	call   *%esi
				num = -(long long) num;
f010307d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103080:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103083:	f7 da                	neg    %edx
f0103085:	83 d1 00             	adc    $0x0,%ecx
f0103088:	f7 d9                	neg    %ecx
f010308a:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010308d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103092:	e9 dd 00 00 00       	jmp    f0103174 <vprintfmt+0x38c>
		return va_arg(*ap, int);
f0103097:	8b 45 14             	mov    0x14(%ebp),%eax
f010309a:	8b 00                	mov    (%eax),%eax
f010309c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010309f:	99                   	cltd   
f01030a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01030a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01030a6:	8d 40 04             	lea    0x4(%eax),%eax
f01030a9:	89 45 14             	mov    %eax,0x14(%ebp)
f01030ac:	eb b4                	jmp    f0103062 <vprintfmt+0x27a>
	if (lflag >= 2)
f01030ae:	83 f9 01             	cmp    $0x1,%ecx
f01030b1:	7f 1e                	jg     f01030d1 <vprintfmt+0x2e9>
	else if (lflag)
f01030b3:	85 c9                	test   %ecx,%ecx
f01030b5:	74 32                	je     f01030e9 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
f01030b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01030ba:	8b 10                	mov    (%eax),%edx
f01030bc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030c1:	8d 40 04             	lea    0x4(%eax),%eax
f01030c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01030c7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01030cc:	e9 a3 00 00 00       	jmp    f0103174 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01030d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01030d4:	8b 10                	mov    (%eax),%edx
f01030d6:	8b 48 04             	mov    0x4(%eax),%ecx
f01030d9:	8d 40 08             	lea    0x8(%eax),%eax
f01030dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01030df:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01030e4:	e9 8b 00 00 00       	jmp    f0103174 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01030e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01030ec:	8b 10                	mov    (%eax),%edx
f01030ee:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030f3:	8d 40 04             	lea    0x4(%eax),%eax
f01030f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01030f9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01030fe:	eb 74                	jmp    f0103174 <vprintfmt+0x38c>
	if (lflag >= 2)
f0103100:	83 f9 01             	cmp    $0x1,%ecx
f0103103:	7f 1b                	jg     f0103120 <vprintfmt+0x338>
	else if (lflag)
f0103105:	85 c9                	test   %ecx,%ecx
f0103107:	74 2c                	je     f0103135 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
f0103109:	8b 45 14             	mov    0x14(%ebp),%eax
f010310c:	8b 10                	mov    (%eax),%edx
f010310e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103113:	8d 40 04             	lea    0x4(%eax),%eax
f0103116:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103119:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f010311e:	eb 54                	jmp    f0103174 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f0103120:	8b 45 14             	mov    0x14(%ebp),%eax
f0103123:	8b 10                	mov    (%eax),%edx
f0103125:	8b 48 04             	mov    0x4(%eax),%ecx
f0103128:	8d 40 08             	lea    0x8(%eax),%eax
f010312b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010312e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0103133:	eb 3f                	jmp    f0103174 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f0103135:	8b 45 14             	mov    0x14(%ebp),%eax
f0103138:	8b 10                	mov    (%eax),%edx
f010313a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010313f:	8d 40 04             	lea    0x4(%eax),%eax
f0103142:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103145:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f010314a:	eb 28                	jmp    f0103174 <vprintfmt+0x38c>
			putch('0', putdat);
f010314c:	83 ec 08             	sub    $0x8,%esp
f010314f:	53                   	push   %ebx
f0103150:	6a 30                	push   $0x30
f0103152:	ff d6                	call   *%esi
			putch('x', putdat);
f0103154:	83 c4 08             	add    $0x8,%esp
f0103157:	53                   	push   %ebx
f0103158:	6a 78                	push   $0x78
f010315a:	ff d6                	call   *%esi
			num = (unsigned long long)
f010315c:	8b 45 14             	mov    0x14(%ebp),%eax
f010315f:	8b 10                	mov    (%eax),%edx
f0103161:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103166:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103169:	8d 40 04             	lea    0x4(%eax),%eax
f010316c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010316f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0103174:	83 ec 0c             	sub    $0xc,%esp
f0103177:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f010317b:	57                   	push   %edi
f010317c:	ff 75 e0             	pushl  -0x20(%ebp)
f010317f:	50                   	push   %eax
f0103180:	51                   	push   %ecx
f0103181:	52                   	push   %edx
f0103182:	89 da                	mov    %ebx,%edx
f0103184:	89 f0                	mov    %esi,%eax
f0103186:	e8 72 fb ff ff       	call   f0102cfd <printnum>
			break;
f010318b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010318e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103191:	83 c7 01             	add    $0x1,%edi
f0103194:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103198:	83 f8 25             	cmp    $0x25,%eax
f010319b:	0f 84 62 fc ff ff    	je     f0102e03 <vprintfmt+0x1b>
			if (ch == '\0')
f01031a1:	85 c0                	test   %eax,%eax
f01031a3:	0f 84 8b 00 00 00    	je     f0103234 <vprintfmt+0x44c>
			putch(ch, putdat);
f01031a9:	83 ec 08             	sub    $0x8,%esp
f01031ac:	53                   	push   %ebx
f01031ad:	50                   	push   %eax
f01031ae:	ff d6                	call   *%esi
f01031b0:	83 c4 10             	add    $0x10,%esp
f01031b3:	eb dc                	jmp    f0103191 <vprintfmt+0x3a9>
	if (lflag >= 2)
f01031b5:	83 f9 01             	cmp    $0x1,%ecx
f01031b8:	7f 1b                	jg     f01031d5 <vprintfmt+0x3ed>
	else if (lflag)
f01031ba:	85 c9                	test   %ecx,%ecx
f01031bc:	74 2c                	je     f01031ea <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
f01031be:	8b 45 14             	mov    0x14(%ebp),%eax
f01031c1:	8b 10                	mov    (%eax),%edx
f01031c3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01031c8:	8d 40 04             	lea    0x4(%eax),%eax
f01031cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01031ce:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f01031d3:	eb 9f                	jmp    f0103174 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01031d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01031d8:	8b 10                	mov    (%eax),%edx
f01031da:	8b 48 04             	mov    0x4(%eax),%ecx
f01031dd:	8d 40 08             	lea    0x8(%eax),%eax
f01031e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01031e3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f01031e8:	eb 8a                	jmp    f0103174 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01031ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01031ed:	8b 10                	mov    (%eax),%edx
f01031ef:	b9 00 00 00 00       	mov    $0x0,%ecx
f01031f4:	8d 40 04             	lea    0x4(%eax),%eax
f01031f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01031fa:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f01031ff:	e9 70 ff ff ff       	jmp    f0103174 <vprintfmt+0x38c>
			putch(ch, putdat);
f0103204:	83 ec 08             	sub    $0x8,%esp
f0103207:	53                   	push   %ebx
f0103208:	6a 25                	push   $0x25
f010320a:	ff d6                	call   *%esi
			break;
f010320c:	83 c4 10             	add    $0x10,%esp
f010320f:	e9 7a ff ff ff       	jmp    f010318e <vprintfmt+0x3a6>
			putch('%', putdat);
f0103214:	83 ec 08             	sub    $0x8,%esp
f0103217:	53                   	push   %ebx
f0103218:	6a 25                	push   $0x25
f010321a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010321c:	83 c4 10             	add    $0x10,%esp
f010321f:	89 f8                	mov    %edi,%eax
f0103221:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103225:	74 05                	je     f010322c <vprintfmt+0x444>
f0103227:	83 e8 01             	sub    $0x1,%eax
f010322a:	eb f5                	jmp    f0103221 <vprintfmt+0x439>
f010322c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010322f:	e9 5a ff ff ff       	jmp    f010318e <vprintfmt+0x3a6>
}
f0103234:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103237:	5b                   	pop    %ebx
f0103238:	5e                   	pop    %esi
f0103239:	5f                   	pop    %edi
f010323a:	5d                   	pop    %ebp
f010323b:	c3                   	ret    

f010323c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010323c:	f3 0f 1e fb          	endbr32 
f0103240:	55                   	push   %ebp
f0103241:	89 e5                	mov    %esp,%ebp
f0103243:	83 ec 18             	sub    $0x18,%esp
f0103246:	8b 45 08             	mov    0x8(%ebp),%eax
f0103249:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010324c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010324f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103253:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103256:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010325d:	85 c0                	test   %eax,%eax
f010325f:	74 26                	je     f0103287 <vsnprintf+0x4b>
f0103261:	85 d2                	test   %edx,%edx
f0103263:	7e 22                	jle    f0103287 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103265:	ff 75 14             	pushl  0x14(%ebp)
f0103268:	ff 75 10             	pushl  0x10(%ebp)
f010326b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010326e:	50                   	push   %eax
f010326f:	68 a6 2d 10 f0       	push   $0xf0102da6
f0103274:	e8 6f fb ff ff       	call   f0102de8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103279:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010327c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010327f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103282:	83 c4 10             	add    $0x10,%esp
}
f0103285:	c9                   	leave  
f0103286:	c3                   	ret    
		return -E_INVAL;
f0103287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010328c:	eb f7                	jmp    f0103285 <vsnprintf+0x49>

f010328e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010328e:	f3 0f 1e fb          	endbr32 
f0103292:	55                   	push   %ebp
f0103293:	89 e5                	mov    %esp,%ebp
f0103295:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103298:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010329b:	50                   	push   %eax
f010329c:	ff 75 10             	pushl  0x10(%ebp)
f010329f:	ff 75 0c             	pushl  0xc(%ebp)
f01032a2:	ff 75 08             	pushl  0x8(%ebp)
f01032a5:	e8 92 ff ff ff       	call   f010323c <vsnprintf>
	va_end(ap);

	return rc;
}
f01032aa:	c9                   	leave  
f01032ab:	c3                   	ret    

f01032ac <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01032ac:	f3 0f 1e fb          	endbr32 
f01032b0:	55                   	push   %ebp
f01032b1:	89 e5                	mov    %esp,%ebp
f01032b3:	57                   	push   %edi
f01032b4:	56                   	push   %esi
f01032b5:	53                   	push   %ebx
f01032b6:	83 ec 0c             	sub    $0xc,%esp
f01032b9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01032bc:	85 c0                	test   %eax,%eax
f01032be:	74 11                	je     f01032d1 <readline+0x25>
		cprintf("%s", prompt);
f01032c0:	83 ec 08             	sub    $0x8,%esp
f01032c3:	50                   	push   %eax
f01032c4:	68 53 47 10 f0       	push   $0xf0104753
f01032c9:	e8 4c f7 ff ff       	call   f0102a1a <cprintf>
f01032ce:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01032d1:	83 ec 0c             	sub    $0xc,%esp
f01032d4:	6a 00                	push   $0x0
f01032d6:	e8 6e d3 ff ff       	call   f0100649 <iscons>
f01032db:	89 c7                	mov    %eax,%edi
f01032dd:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01032e0:	be 00 00 00 00       	mov    $0x0,%esi
f01032e5:	eb 4b                	jmp    f0103332 <readline+0x86>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01032e7:	83 ec 08             	sub    $0x8,%esp
f01032ea:	50                   	push   %eax
f01032eb:	68 24 4c 10 f0       	push   $0xf0104c24
f01032f0:	e8 25 f7 ff ff       	call   f0102a1a <cprintf>
			return NULL;
f01032f5:	83 c4 10             	add    $0x10,%esp
f01032f8:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01032fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103300:	5b                   	pop    %ebx
f0103301:	5e                   	pop    %esi
f0103302:	5f                   	pop    %edi
f0103303:	5d                   	pop    %ebp
f0103304:	c3                   	ret    
			if (echoing)
f0103305:	85 ff                	test   %edi,%edi
f0103307:	75 05                	jne    f010330e <readline+0x62>
			i--;
f0103309:	83 ee 01             	sub    $0x1,%esi
f010330c:	eb 24                	jmp    f0103332 <readline+0x86>
				cputchar('\b');
f010330e:	83 ec 0c             	sub    $0xc,%esp
f0103311:	6a 08                	push   $0x8
f0103313:	e8 08 d3 ff ff       	call   f0100620 <cputchar>
f0103318:	83 c4 10             	add    $0x10,%esp
f010331b:	eb ec                	jmp    f0103309 <readline+0x5d>
				cputchar(c);
f010331d:	83 ec 0c             	sub    $0xc,%esp
f0103320:	53                   	push   %ebx
f0103321:	e8 fa d2 ff ff       	call   f0100620 <cputchar>
f0103326:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103329:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f010332f:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0103332:	e8 fd d2 ff ff       	call   f0100634 <getchar>
f0103337:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103339:	85 c0                	test   %eax,%eax
f010333b:	78 aa                	js     f01032e7 <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010333d:	83 f8 08             	cmp    $0x8,%eax
f0103340:	0f 94 c2             	sete   %dl
f0103343:	83 f8 7f             	cmp    $0x7f,%eax
f0103346:	0f 94 c0             	sete   %al
f0103349:	08 c2                	or     %al,%dl
f010334b:	74 04                	je     f0103351 <readline+0xa5>
f010334d:	85 f6                	test   %esi,%esi
f010334f:	7f b4                	jg     f0103305 <readline+0x59>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103351:	83 fb 1f             	cmp    $0x1f,%ebx
f0103354:	7e 0e                	jle    f0103364 <readline+0xb8>
f0103356:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010335c:	7f 06                	jg     f0103364 <readline+0xb8>
			if (echoing)
f010335e:	85 ff                	test   %edi,%edi
f0103360:	74 c7                	je     f0103329 <readline+0x7d>
f0103362:	eb b9                	jmp    f010331d <readline+0x71>
		} else if (c == '\n' || c == '\r') {
f0103364:	83 fb 0a             	cmp    $0xa,%ebx
f0103367:	74 05                	je     f010336e <readline+0xc2>
f0103369:	83 fb 0d             	cmp    $0xd,%ebx
f010336c:	75 c4                	jne    f0103332 <readline+0x86>
			if (echoing)
f010336e:	85 ff                	test   %edi,%edi
f0103370:	75 11                	jne    f0103383 <readline+0xd7>
			buf[i] = 0;
f0103372:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f0103379:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
f010337e:	e9 7a ff ff ff       	jmp    f01032fd <readline+0x51>
				cputchar('\n');
f0103383:	83 ec 0c             	sub    $0xc,%esp
f0103386:	6a 0a                	push   $0xa
f0103388:	e8 93 d2 ff ff       	call   f0100620 <cputchar>
f010338d:	83 c4 10             	add    $0x10,%esp
f0103390:	eb e0                	jmp    f0103372 <readline+0xc6>

f0103392 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103392:	f3 0f 1e fb          	endbr32 
f0103396:	55                   	push   %ebp
f0103397:	89 e5                	mov    %esp,%ebp
f0103399:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010339c:	b8 00 00 00 00       	mov    $0x0,%eax
f01033a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01033a5:	74 05                	je     f01033ac <strlen+0x1a>
		n++;
f01033a7:	83 c0 01             	add    $0x1,%eax
f01033aa:	eb f5                	jmp    f01033a1 <strlen+0xf>
	return n;
}
f01033ac:	5d                   	pop    %ebp
f01033ad:	c3                   	ret    

f01033ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01033ae:	f3 0f 1e fb          	endbr32 
f01033b2:	55                   	push   %ebp
f01033b3:	89 e5                	mov    %esp,%ebp
f01033b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01033b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01033bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01033c0:	39 d0                	cmp    %edx,%eax
f01033c2:	74 0d                	je     f01033d1 <strnlen+0x23>
f01033c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01033c8:	74 05                	je     f01033cf <strnlen+0x21>
		n++;
f01033ca:	83 c0 01             	add    $0x1,%eax
f01033cd:	eb f1                	jmp    f01033c0 <strnlen+0x12>
f01033cf:	89 c2                	mov    %eax,%edx
	return n;
}
f01033d1:	89 d0                	mov    %edx,%eax
f01033d3:	5d                   	pop    %ebp
f01033d4:	c3                   	ret    

f01033d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01033d5:	f3 0f 1e fb          	endbr32 
f01033d9:	55                   	push   %ebp
f01033da:	89 e5                	mov    %esp,%ebp
f01033dc:	53                   	push   %ebx
f01033dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01033e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01033e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01033e8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01033ec:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01033ef:	83 c0 01             	add    $0x1,%eax
f01033f2:	84 d2                	test   %dl,%dl
f01033f4:	75 f2                	jne    f01033e8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f01033f6:	89 c8                	mov    %ecx,%eax
f01033f8:	5b                   	pop    %ebx
f01033f9:	5d                   	pop    %ebp
f01033fa:	c3                   	ret    

f01033fb <strcat>:

char *
strcat(char *dst, const char *src)
{
f01033fb:	f3 0f 1e fb          	endbr32 
f01033ff:	55                   	push   %ebp
f0103400:	89 e5                	mov    %esp,%ebp
f0103402:	53                   	push   %ebx
f0103403:	83 ec 10             	sub    $0x10,%esp
f0103406:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103409:	53                   	push   %ebx
f010340a:	e8 83 ff ff ff       	call   f0103392 <strlen>
f010340f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103412:	ff 75 0c             	pushl  0xc(%ebp)
f0103415:	01 d8                	add    %ebx,%eax
f0103417:	50                   	push   %eax
f0103418:	e8 b8 ff ff ff       	call   f01033d5 <strcpy>
	return dst;
}
f010341d:	89 d8                	mov    %ebx,%eax
f010341f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103422:	c9                   	leave  
f0103423:	c3                   	ret    

f0103424 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103424:	f3 0f 1e fb          	endbr32 
f0103428:	55                   	push   %ebp
f0103429:	89 e5                	mov    %esp,%ebp
f010342b:	56                   	push   %esi
f010342c:	53                   	push   %ebx
f010342d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103430:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103433:	89 f3                	mov    %esi,%ebx
f0103435:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103438:	89 f0                	mov    %esi,%eax
f010343a:	39 d8                	cmp    %ebx,%eax
f010343c:	74 11                	je     f010344f <strncpy+0x2b>
		*dst++ = *src;
f010343e:	83 c0 01             	add    $0x1,%eax
f0103441:	0f b6 0a             	movzbl (%edx),%ecx
f0103444:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103447:	80 f9 01             	cmp    $0x1,%cl
f010344a:	83 da ff             	sbb    $0xffffffff,%edx
f010344d:	eb eb                	jmp    f010343a <strncpy+0x16>
	}
	return ret;
}
f010344f:	89 f0                	mov    %esi,%eax
f0103451:	5b                   	pop    %ebx
f0103452:	5e                   	pop    %esi
f0103453:	5d                   	pop    %ebp
f0103454:	c3                   	ret    

f0103455 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103455:	f3 0f 1e fb          	endbr32 
f0103459:	55                   	push   %ebp
f010345a:	89 e5                	mov    %esp,%ebp
f010345c:	56                   	push   %esi
f010345d:	53                   	push   %ebx
f010345e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103464:	8b 55 10             	mov    0x10(%ebp),%edx
f0103467:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103469:	85 d2                	test   %edx,%edx
f010346b:	74 21                	je     f010348e <strlcpy+0x39>
f010346d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103471:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0103473:	39 c2                	cmp    %eax,%edx
f0103475:	74 14                	je     f010348b <strlcpy+0x36>
f0103477:	0f b6 19             	movzbl (%ecx),%ebx
f010347a:	84 db                	test   %bl,%bl
f010347c:	74 0b                	je     f0103489 <strlcpy+0x34>
			*dst++ = *src++;
f010347e:	83 c1 01             	add    $0x1,%ecx
f0103481:	83 c2 01             	add    $0x1,%edx
f0103484:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103487:	eb ea                	jmp    f0103473 <strlcpy+0x1e>
f0103489:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010348b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010348e:	29 f0                	sub    %esi,%eax
}
f0103490:	5b                   	pop    %ebx
f0103491:	5e                   	pop    %esi
f0103492:	5d                   	pop    %ebp
f0103493:	c3                   	ret    

f0103494 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103494:	f3 0f 1e fb          	endbr32 
f0103498:	55                   	push   %ebp
f0103499:	89 e5                	mov    %esp,%ebp
f010349b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010349e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01034a1:	0f b6 01             	movzbl (%ecx),%eax
f01034a4:	84 c0                	test   %al,%al
f01034a6:	74 0c                	je     f01034b4 <strcmp+0x20>
f01034a8:	3a 02                	cmp    (%edx),%al
f01034aa:	75 08                	jne    f01034b4 <strcmp+0x20>
		p++, q++;
f01034ac:	83 c1 01             	add    $0x1,%ecx
f01034af:	83 c2 01             	add    $0x1,%edx
f01034b2:	eb ed                	jmp    f01034a1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01034b4:	0f b6 c0             	movzbl %al,%eax
f01034b7:	0f b6 12             	movzbl (%edx),%edx
f01034ba:	29 d0                	sub    %edx,%eax
}
f01034bc:	5d                   	pop    %ebp
f01034bd:	c3                   	ret    

f01034be <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01034be:	f3 0f 1e fb          	endbr32 
f01034c2:	55                   	push   %ebp
f01034c3:	89 e5                	mov    %esp,%ebp
f01034c5:	53                   	push   %ebx
f01034c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034cc:	89 c3                	mov    %eax,%ebx
f01034ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01034d1:	eb 06                	jmp    f01034d9 <strncmp+0x1b>
		n--, p++, q++;
f01034d3:	83 c0 01             	add    $0x1,%eax
f01034d6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01034d9:	39 d8                	cmp    %ebx,%eax
f01034db:	74 16                	je     f01034f3 <strncmp+0x35>
f01034dd:	0f b6 08             	movzbl (%eax),%ecx
f01034e0:	84 c9                	test   %cl,%cl
f01034e2:	74 04                	je     f01034e8 <strncmp+0x2a>
f01034e4:	3a 0a                	cmp    (%edx),%cl
f01034e6:	74 eb                	je     f01034d3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01034e8:	0f b6 00             	movzbl (%eax),%eax
f01034eb:	0f b6 12             	movzbl (%edx),%edx
f01034ee:	29 d0                	sub    %edx,%eax
}
f01034f0:	5b                   	pop    %ebx
f01034f1:	5d                   	pop    %ebp
f01034f2:	c3                   	ret    
		return 0;
f01034f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01034f8:	eb f6                	jmp    f01034f0 <strncmp+0x32>

f01034fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01034fa:	f3 0f 1e fb          	endbr32 
f01034fe:	55                   	push   %ebp
f01034ff:	89 e5                	mov    %esp,%ebp
f0103501:	8b 45 08             	mov    0x8(%ebp),%eax
f0103504:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103508:	0f b6 10             	movzbl (%eax),%edx
f010350b:	84 d2                	test   %dl,%dl
f010350d:	74 09                	je     f0103518 <strchr+0x1e>
		if (*s == c)
f010350f:	38 ca                	cmp    %cl,%dl
f0103511:	74 0a                	je     f010351d <strchr+0x23>
	for (; *s; s++)
f0103513:	83 c0 01             	add    $0x1,%eax
f0103516:	eb f0                	jmp    f0103508 <strchr+0xe>
			return (char *) s;
	return 0;
f0103518:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010351d:	5d                   	pop    %ebp
f010351e:	c3                   	ret    

f010351f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010351f:	f3 0f 1e fb          	endbr32 
f0103523:	55                   	push   %ebp
f0103524:	89 e5                	mov    %esp,%ebp
f0103526:	8b 45 08             	mov    0x8(%ebp),%eax
f0103529:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010352d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103530:	38 ca                	cmp    %cl,%dl
f0103532:	74 09                	je     f010353d <strfind+0x1e>
f0103534:	84 d2                	test   %dl,%dl
f0103536:	74 05                	je     f010353d <strfind+0x1e>
	for (; *s; s++)
f0103538:	83 c0 01             	add    $0x1,%eax
f010353b:	eb f0                	jmp    f010352d <strfind+0xe>
			break;
	return (char *) s;
}
f010353d:	5d                   	pop    %ebp
f010353e:	c3                   	ret    

f010353f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010353f:	f3 0f 1e fb          	endbr32 
f0103543:	55                   	push   %ebp
f0103544:	89 e5                	mov    %esp,%ebp
f0103546:	57                   	push   %edi
f0103547:	56                   	push   %esi
f0103548:	53                   	push   %ebx
f0103549:	8b 7d 08             	mov    0x8(%ebp),%edi
f010354c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010354f:	85 c9                	test   %ecx,%ecx
f0103551:	74 31                	je     f0103584 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103553:	89 f8                	mov    %edi,%eax
f0103555:	09 c8                	or     %ecx,%eax
f0103557:	a8 03                	test   $0x3,%al
f0103559:	75 23                	jne    f010357e <memset+0x3f>
		c &= 0xFF;
f010355b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010355f:	89 d3                	mov    %edx,%ebx
f0103561:	c1 e3 08             	shl    $0x8,%ebx
f0103564:	89 d0                	mov    %edx,%eax
f0103566:	c1 e0 18             	shl    $0x18,%eax
f0103569:	89 d6                	mov    %edx,%esi
f010356b:	c1 e6 10             	shl    $0x10,%esi
f010356e:	09 f0                	or     %esi,%eax
f0103570:	09 c2                	or     %eax,%edx
f0103572:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103574:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103577:	89 d0                	mov    %edx,%eax
f0103579:	fc                   	cld    
f010357a:	f3 ab                	rep stos %eax,%es:(%edi)
f010357c:	eb 06                	jmp    f0103584 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010357e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103581:	fc                   	cld    
f0103582:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103584:	89 f8                	mov    %edi,%eax
f0103586:	5b                   	pop    %ebx
f0103587:	5e                   	pop    %esi
f0103588:	5f                   	pop    %edi
f0103589:	5d                   	pop    %ebp
f010358a:	c3                   	ret    

f010358b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010358b:	f3 0f 1e fb          	endbr32 
f010358f:	55                   	push   %ebp
f0103590:	89 e5                	mov    %esp,%ebp
f0103592:	57                   	push   %edi
f0103593:	56                   	push   %esi
f0103594:	8b 45 08             	mov    0x8(%ebp),%eax
f0103597:	8b 75 0c             	mov    0xc(%ebp),%esi
f010359a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010359d:	39 c6                	cmp    %eax,%esi
f010359f:	73 32                	jae    f01035d3 <memmove+0x48>
f01035a1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01035a4:	39 c2                	cmp    %eax,%edx
f01035a6:	76 2b                	jbe    f01035d3 <memmove+0x48>
		s += n;
		d += n;
f01035a8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01035ab:	89 fe                	mov    %edi,%esi
f01035ad:	09 ce                	or     %ecx,%esi
f01035af:	09 d6                	or     %edx,%esi
f01035b1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01035b7:	75 0e                	jne    f01035c7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01035b9:	83 ef 04             	sub    $0x4,%edi
f01035bc:	8d 72 fc             	lea    -0x4(%edx),%esi
f01035bf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01035c2:	fd                   	std    
f01035c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01035c5:	eb 09                	jmp    f01035d0 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01035c7:	83 ef 01             	sub    $0x1,%edi
f01035ca:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01035cd:	fd                   	std    
f01035ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01035d0:	fc                   	cld    
f01035d1:	eb 1a                	jmp    f01035ed <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01035d3:	89 c2                	mov    %eax,%edx
f01035d5:	09 ca                	or     %ecx,%edx
f01035d7:	09 f2                	or     %esi,%edx
f01035d9:	f6 c2 03             	test   $0x3,%dl
f01035dc:	75 0a                	jne    f01035e8 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01035de:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01035e1:	89 c7                	mov    %eax,%edi
f01035e3:	fc                   	cld    
f01035e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01035e6:	eb 05                	jmp    f01035ed <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f01035e8:	89 c7                	mov    %eax,%edi
f01035ea:	fc                   	cld    
f01035eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01035ed:	5e                   	pop    %esi
f01035ee:	5f                   	pop    %edi
f01035ef:	5d                   	pop    %ebp
f01035f0:	c3                   	ret    

f01035f1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01035f1:	f3 0f 1e fb          	endbr32 
f01035f5:	55                   	push   %ebp
f01035f6:	89 e5                	mov    %esp,%ebp
f01035f8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01035fb:	ff 75 10             	pushl  0x10(%ebp)
f01035fe:	ff 75 0c             	pushl  0xc(%ebp)
f0103601:	ff 75 08             	pushl  0x8(%ebp)
f0103604:	e8 82 ff ff ff       	call   f010358b <memmove>
}
f0103609:	c9                   	leave  
f010360a:	c3                   	ret    

f010360b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010360b:	f3 0f 1e fb          	endbr32 
f010360f:	55                   	push   %ebp
f0103610:	89 e5                	mov    %esp,%ebp
f0103612:	56                   	push   %esi
f0103613:	53                   	push   %ebx
f0103614:	8b 45 08             	mov    0x8(%ebp),%eax
f0103617:	8b 55 0c             	mov    0xc(%ebp),%edx
f010361a:	89 c6                	mov    %eax,%esi
f010361c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010361f:	39 f0                	cmp    %esi,%eax
f0103621:	74 1c                	je     f010363f <memcmp+0x34>
		if (*s1 != *s2)
f0103623:	0f b6 08             	movzbl (%eax),%ecx
f0103626:	0f b6 1a             	movzbl (%edx),%ebx
f0103629:	38 d9                	cmp    %bl,%cl
f010362b:	75 08                	jne    f0103635 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010362d:	83 c0 01             	add    $0x1,%eax
f0103630:	83 c2 01             	add    $0x1,%edx
f0103633:	eb ea                	jmp    f010361f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0103635:	0f b6 c1             	movzbl %cl,%eax
f0103638:	0f b6 db             	movzbl %bl,%ebx
f010363b:	29 d8                	sub    %ebx,%eax
f010363d:	eb 05                	jmp    f0103644 <memcmp+0x39>
	}

	return 0;
f010363f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103644:	5b                   	pop    %ebx
f0103645:	5e                   	pop    %esi
f0103646:	5d                   	pop    %ebp
f0103647:	c3                   	ret    

f0103648 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103648:	f3 0f 1e fb          	endbr32 
f010364c:	55                   	push   %ebp
f010364d:	89 e5                	mov    %esp,%ebp
f010364f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103652:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103655:	89 c2                	mov    %eax,%edx
f0103657:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010365a:	39 d0                	cmp    %edx,%eax
f010365c:	73 09                	jae    f0103667 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f010365e:	38 08                	cmp    %cl,(%eax)
f0103660:	74 05                	je     f0103667 <memfind+0x1f>
	for (; s < ends; s++)
f0103662:	83 c0 01             	add    $0x1,%eax
f0103665:	eb f3                	jmp    f010365a <memfind+0x12>
			break;
	return (void *) s;
}
f0103667:	5d                   	pop    %ebp
f0103668:	c3                   	ret    

f0103669 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103669:	f3 0f 1e fb          	endbr32 
f010366d:	55                   	push   %ebp
f010366e:	89 e5                	mov    %esp,%ebp
f0103670:	57                   	push   %edi
f0103671:	56                   	push   %esi
f0103672:	53                   	push   %ebx
f0103673:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103676:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103679:	eb 03                	jmp    f010367e <strtol+0x15>
		s++;
f010367b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010367e:	0f b6 01             	movzbl (%ecx),%eax
f0103681:	3c 20                	cmp    $0x20,%al
f0103683:	74 f6                	je     f010367b <strtol+0x12>
f0103685:	3c 09                	cmp    $0x9,%al
f0103687:	74 f2                	je     f010367b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0103689:	3c 2b                	cmp    $0x2b,%al
f010368b:	74 2a                	je     f01036b7 <strtol+0x4e>
	int neg = 0;
f010368d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103692:	3c 2d                	cmp    $0x2d,%al
f0103694:	74 2b                	je     f01036c1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103696:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010369c:	75 0f                	jne    f01036ad <strtol+0x44>
f010369e:	80 39 30             	cmpb   $0x30,(%ecx)
f01036a1:	74 28                	je     f01036cb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01036a3:	85 db                	test   %ebx,%ebx
f01036a5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036aa:	0f 44 d8             	cmove  %eax,%ebx
f01036ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01036b2:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01036b5:	eb 46                	jmp    f01036fd <strtol+0x94>
		s++;
f01036b7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01036ba:	bf 00 00 00 00       	mov    $0x0,%edi
f01036bf:	eb d5                	jmp    f0103696 <strtol+0x2d>
		s++, neg = 1;
f01036c1:	83 c1 01             	add    $0x1,%ecx
f01036c4:	bf 01 00 00 00       	mov    $0x1,%edi
f01036c9:	eb cb                	jmp    f0103696 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01036cb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01036cf:	74 0e                	je     f01036df <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01036d1:	85 db                	test   %ebx,%ebx
f01036d3:	75 d8                	jne    f01036ad <strtol+0x44>
		s++, base = 8;
f01036d5:	83 c1 01             	add    $0x1,%ecx
f01036d8:	bb 08 00 00 00       	mov    $0x8,%ebx
f01036dd:	eb ce                	jmp    f01036ad <strtol+0x44>
		s += 2, base = 16;
f01036df:	83 c1 02             	add    $0x2,%ecx
f01036e2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01036e7:	eb c4                	jmp    f01036ad <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01036e9:	0f be d2             	movsbl %dl,%edx
f01036ec:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01036ef:	3b 55 10             	cmp    0x10(%ebp),%edx
f01036f2:	7d 3a                	jge    f010372e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01036f4:	83 c1 01             	add    $0x1,%ecx
f01036f7:	0f af 45 10          	imul   0x10(%ebp),%eax
f01036fb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01036fd:	0f b6 11             	movzbl (%ecx),%edx
f0103700:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103703:	89 f3                	mov    %esi,%ebx
f0103705:	80 fb 09             	cmp    $0x9,%bl
f0103708:	76 df                	jbe    f01036e9 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f010370a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010370d:	89 f3                	mov    %esi,%ebx
f010370f:	80 fb 19             	cmp    $0x19,%bl
f0103712:	77 08                	ja     f010371c <strtol+0xb3>
			dig = *s - 'a' + 10;
f0103714:	0f be d2             	movsbl %dl,%edx
f0103717:	83 ea 57             	sub    $0x57,%edx
f010371a:	eb d3                	jmp    f01036ef <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f010371c:	8d 72 bf             	lea    -0x41(%edx),%esi
f010371f:	89 f3                	mov    %esi,%ebx
f0103721:	80 fb 19             	cmp    $0x19,%bl
f0103724:	77 08                	ja     f010372e <strtol+0xc5>
			dig = *s - 'A' + 10;
f0103726:	0f be d2             	movsbl %dl,%edx
f0103729:	83 ea 37             	sub    $0x37,%edx
f010372c:	eb c1                	jmp    f01036ef <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f010372e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103732:	74 05                	je     f0103739 <strtol+0xd0>
		*endptr = (char *) s;
f0103734:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103737:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103739:	89 c2                	mov    %eax,%edx
f010373b:	f7 da                	neg    %edx
f010373d:	85 ff                	test   %edi,%edi
f010373f:	0f 45 c2             	cmovne %edx,%eax
}
f0103742:	5b                   	pop    %ebx
f0103743:	5e                   	pop    %esi
f0103744:	5f                   	pop    %edi
f0103745:	5d                   	pop    %ebp
f0103746:	c3                   	ret    
f0103747:	66 90                	xchg   %ax,%ax
f0103749:	66 90                	xchg   %ax,%ax
f010374b:	66 90                	xchg   %ax,%ax
f010374d:	66 90                	xchg   %ax,%ax
f010374f:	90                   	nop

f0103750 <__udivdi3>:
f0103750:	f3 0f 1e fb          	endbr32 
f0103754:	55                   	push   %ebp
f0103755:	57                   	push   %edi
f0103756:	56                   	push   %esi
f0103757:	53                   	push   %ebx
f0103758:	83 ec 1c             	sub    $0x1c,%esp
f010375b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010375f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103763:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103767:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010376b:	85 d2                	test   %edx,%edx
f010376d:	75 19                	jne    f0103788 <__udivdi3+0x38>
f010376f:	39 f3                	cmp    %esi,%ebx
f0103771:	76 4d                	jbe    f01037c0 <__udivdi3+0x70>
f0103773:	31 ff                	xor    %edi,%edi
f0103775:	89 e8                	mov    %ebp,%eax
f0103777:	89 f2                	mov    %esi,%edx
f0103779:	f7 f3                	div    %ebx
f010377b:	89 fa                	mov    %edi,%edx
f010377d:	83 c4 1c             	add    $0x1c,%esp
f0103780:	5b                   	pop    %ebx
f0103781:	5e                   	pop    %esi
f0103782:	5f                   	pop    %edi
f0103783:	5d                   	pop    %ebp
f0103784:	c3                   	ret    
f0103785:	8d 76 00             	lea    0x0(%esi),%esi
f0103788:	39 f2                	cmp    %esi,%edx
f010378a:	76 14                	jbe    f01037a0 <__udivdi3+0x50>
f010378c:	31 ff                	xor    %edi,%edi
f010378e:	31 c0                	xor    %eax,%eax
f0103790:	89 fa                	mov    %edi,%edx
f0103792:	83 c4 1c             	add    $0x1c,%esp
f0103795:	5b                   	pop    %ebx
f0103796:	5e                   	pop    %esi
f0103797:	5f                   	pop    %edi
f0103798:	5d                   	pop    %ebp
f0103799:	c3                   	ret    
f010379a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01037a0:	0f bd fa             	bsr    %edx,%edi
f01037a3:	83 f7 1f             	xor    $0x1f,%edi
f01037a6:	75 48                	jne    f01037f0 <__udivdi3+0xa0>
f01037a8:	39 f2                	cmp    %esi,%edx
f01037aa:	72 06                	jb     f01037b2 <__udivdi3+0x62>
f01037ac:	31 c0                	xor    %eax,%eax
f01037ae:	39 eb                	cmp    %ebp,%ebx
f01037b0:	77 de                	ja     f0103790 <__udivdi3+0x40>
f01037b2:	b8 01 00 00 00       	mov    $0x1,%eax
f01037b7:	eb d7                	jmp    f0103790 <__udivdi3+0x40>
f01037b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01037c0:	89 d9                	mov    %ebx,%ecx
f01037c2:	85 db                	test   %ebx,%ebx
f01037c4:	75 0b                	jne    f01037d1 <__udivdi3+0x81>
f01037c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01037cb:	31 d2                	xor    %edx,%edx
f01037cd:	f7 f3                	div    %ebx
f01037cf:	89 c1                	mov    %eax,%ecx
f01037d1:	31 d2                	xor    %edx,%edx
f01037d3:	89 f0                	mov    %esi,%eax
f01037d5:	f7 f1                	div    %ecx
f01037d7:	89 c6                	mov    %eax,%esi
f01037d9:	89 e8                	mov    %ebp,%eax
f01037db:	89 f7                	mov    %esi,%edi
f01037dd:	f7 f1                	div    %ecx
f01037df:	89 fa                	mov    %edi,%edx
f01037e1:	83 c4 1c             	add    $0x1c,%esp
f01037e4:	5b                   	pop    %ebx
f01037e5:	5e                   	pop    %esi
f01037e6:	5f                   	pop    %edi
f01037e7:	5d                   	pop    %ebp
f01037e8:	c3                   	ret    
f01037e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01037f0:	89 f9                	mov    %edi,%ecx
f01037f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01037f7:	29 f8                	sub    %edi,%eax
f01037f9:	d3 e2                	shl    %cl,%edx
f01037fb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01037ff:	89 c1                	mov    %eax,%ecx
f0103801:	89 da                	mov    %ebx,%edx
f0103803:	d3 ea                	shr    %cl,%edx
f0103805:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103809:	09 d1                	or     %edx,%ecx
f010380b:	89 f2                	mov    %esi,%edx
f010380d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103811:	89 f9                	mov    %edi,%ecx
f0103813:	d3 e3                	shl    %cl,%ebx
f0103815:	89 c1                	mov    %eax,%ecx
f0103817:	d3 ea                	shr    %cl,%edx
f0103819:	89 f9                	mov    %edi,%ecx
f010381b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010381f:	89 eb                	mov    %ebp,%ebx
f0103821:	d3 e6                	shl    %cl,%esi
f0103823:	89 c1                	mov    %eax,%ecx
f0103825:	d3 eb                	shr    %cl,%ebx
f0103827:	09 de                	or     %ebx,%esi
f0103829:	89 f0                	mov    %esi,%eax
f010382b:	f7 74 24 08          	divl   0x8(%esp)
f010382f:	89 d6                	mov    %edx,%esi
f0103831:	89 c3                	mov    %eax,%ebx
f0103833:	f7 64 24 0c          	mull   0xc(%esp)
f0103837:	39 d6                	cmp    %edx,%esi
f0103839:	72 15                	jb     f0103850 <__udivdi3+0x100>
f010383b:	89 f9                	mov    %edi,%ecx
f010383d:	d3 e5                	shl    %cl,%ebp
f010383f:	39 c5                	cmp    %eax,%ebp
f0103841:	73 04                	jae    f0103847 <__udivdi3+0xf7>
f0103843:	39 d6                	cmp    %edx,%esi
f0103845:	74 09                	je     f0103850 <__udivdi3+0x100>
f0103847:	89 d8                	mov    %ebx,%eax
f0103849:	31 ff                	xor    %edi,%edi
f010384b:	e9 40 ff ff ff       	jmp    f0103790 <__udivdi3+0x40>
f0103850:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103853:	31 ff                	xor    %edi,%edi
f0103855:	e9 36 ff ff ff       	jmp    f0103790 <__udivdi3+0x40>
f010385a:	66 90                	xchg   %ax,%ax
f010385c:	66 90                	xchg   %ax,%ax
f010385e:	66 90                	xchg   %ax,%ax

f0103860 <__umoddi3>:
f0103860:	f3 0f 1e fb          	endbr32 
f0103864:	55                   	push   %ebp
f0103865:	57                   	push   %edi
f0103866:	56                   	push   %esi
f0103867:	53                   	push   %ebx
f0103868:	83 ec 1c             	sub    $0x1c,%esp
f010386b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010386f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103873:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103877:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010387b:	85 c0                	test   %eax,%eax
f010387d:	75 19                	jne    f0103898 <__umoddi3+0x38>
f010387f:	39 df                	cmp    %ebx,%edi
f0103881:	76 5d                	jbe    f01038e0 <__umoddi3+0x80>
f0103883:	89 f0                	mov    %esi,%eax
f0103885:	89 da                	mov    %ebx,%edx
f0103887:	f7 f7                	div    %edi
f0103889:	89 d0                	mov    %edx,%eax
f010388b:	31 d2                	xor    %edx,%edx
f010388d:	83 c4 1c             	add    $0x1c,%esp
f0103890:	5b                   	pop    %ebx
f0103891:	5e                   	pop    %esi
f0103892:	5f                   	pop    %edi
f0103893:	5d                   	pop    %ebp
f0103894:	c3                   	ret    
f0103895:	8d 76 00             	lea    0x0(%esi),%esi
f0103898:	89 f2                	mov    %esi,%edx
f010389a:	39 d8                	cmp    %ebx,%eax
f010389c:	76 12                	jbe    f01038b0 <__umoddi3+0x50>
f010389e:	89 f0                	mov    %esi,%eax
f01038a0:	89 da                	mov    %ebx,%edx
f01038a2:	83 c4 1c             	add    $0x1c,%esp
f01038a5:	5b                   	pop    %ebx
f01038a6:	5e                   	pop    %esi
f01038a7:	5f                   	pop    %edi
f01038a8:	5d                   	pop    %ebp
f01038a9:	c3                   	ret    
f01038aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01038b0:	0f bd e8             	bsr    %eax,%ebp
f01038b3:	83 f5 1f             	xor    $0x1f,%ebp
f01038b6:	75 50                	jne    f0103908 <__umoddi3+0xa8>
f01038b8:	39 d8                	cmp    %ebx,%eax
f01038ba:	0f 82 e0 00 00 00    	jb     f01039a0 <__umoddi3+0x140>
f01038c0:	89 d9                	mov    %ebx,%ecx
f01038c2:	39 f7                	cmp    %esi,%edi
f01038c4:	0f 86 d6 00 00 00    	jbe    f01039a0 <__umoddi3+0x140>
f01038ca:	89 d0                	mov    %edx,%eax
f01038cc:	89 ca                	mov    %ecx,%edx
f01038ce:	83 c4 1c             	add    $0x1c,%esp
f01038d1:	5b                   	pop    %ebx
f01038d2:	5e                   	pop    %esi
f01038d3:	5f                   	pop    %edi
f01038d4:	5d                   	pop    %ebp
f01038d5:	c3                   	ret    
f01038d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01038dd:	8d 76 00             	lea    0x0(%esi),%esi
f01038e0:	89 fd                	mov    %edi,%ebp
f01038e2:	85 ff                	test   %edi,%edi
f01038e4:	75 0b                	jne    f01038f1 <__umoddi3+0x91>
f01038e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01038eb:	31 d2                	xor    %edx,%edx
f01038ed:	f7 f7                	div    %edi
f01038ef:	89 c5                	mov    %eax,%ebp
f01038f1:	89 d8                	mov    %ebx,%eax
f01038f3:	31 d2                	xor    %edx,%edx
f01038f5:	f7 f5                	div    %ebp
f01038f7:	89 f0                	mov    %esi,%eax
f01038f9:	f7 f5                	div    %ebp
f01038fb:	89 d0                	mov    %edx,%eax
f01038fd:	31 d2                	xor    %edx,%edx
f01038ff:	eb 8c                	jmp    f010388d <__umoddi3+0x2d>
f0103901:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103908:	89 e9                	mov    %ebp,%ecx
f010390a:	ba 20 00 00 00       	mov    $0x20,%edx
f010390f:	29 ea                	sub    %ebp,%edx
f0103911:	d3 e0                	shl    %cl,%eax
f0103913:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103917:	89 d1                	mov    %edx,%ecx
f0103919:	89 f8                	mov    %edi,%eax
f010391b:	d3 e8                	shr    %cl,%eax
f010391d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103921:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103925:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103929:	09 c1                	or     %eax,%ecx
f010392b:	89 d8                	mov    %ebx,%eax
f010392d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103931:	89 e9                	mov    %ebp,%ecx
f0103933:	d3 e7                	shl    %cl,%edi
f0103935:	89 d1                	mov    %edx,%ecx
f0103937:	d3 e8                	shr    %cl,%eax
f0103939:	89 e9                	mov    %ebp,%ecx
f010393b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010393f:	d3 e3                	shl    %cl,%ebx
f0103941:	89 c7                	mov    %eax,%edi
f0103943:	89 d1                	mov    %edx,%ecx
f0103945:	89 f0                	mov    %esi,%eax
f0103947:	d3 e8                	shr    %cl,%eax
f0103949:	89 e9                	mov    %ebp,%ecx
f010394b:	89 fa                	mov    %edi,%edx
f010394d:	d3 e6                	shl    %cl,%esi
f010394f:	09 d8                	or     %ebx,%eax
f0103951:	f7 74 24 08          	divl   0x8(%esp)
f0103955:	89 d1                	mov    %edx,%ecx
f0103957:	89 f3                	mov    %esi,%ebx
f0103959:	f7 64 24 0c          	mull   0xc(%esp)
f010395d:	89 c6                	mov    %eax,%esi
f010395f:	89 d7                	mov    %edx,%edi
f0103961:	39 d1                	cmp    %edx,%ecx
f0103963:	72 06                	jb     f010396b <__umoddi3+0x10b>
f0103965:	75 10                	jne    f0103977 <__umoddi3+0x117>
f0103967:	39 c3                	cmp    %eax,%ebx
f0103969:	73 0c                	jae    f0103977 <__umoddi3+0x117>
f010396b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010396f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0103973:	89 d7                	mov    %edx,%edi
f0103975:	89 c6                	mov    %eax,%esi
f0103977:	89 ca                	mov    %ecx,%edx
f0103979:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010397e:	29 f3                	sub    %esi,%ebx
f0103980:	19 fa                	sbb    %edi,%edx
f0103982:	89 d0                	mov    %edx,%eax
f0103984:	d3 e0                	shl    %cl,%eax
f0103986:	89 e9                	mov    %ebp,%ecx
f0103988:	d3 eb                	shr    %cl,%ebx
f010398a:	d3 ea                	shr    %cl,%edx
f010398c:	09 d8                	or     %ebx,%eax
f010398e:	83 c4 1c             	add    $0x1c,%esp
f0103991:	5b                   	pop    %ebx
f0103992:	5e                   	pop    %esi
f0103993:	5f                   	pop    %edi
f0103994:	5d                   	pop    %ebp
f0103995:	c3                   	ret    
f0103996:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010399d:	8d 76 00             	lea    0x0(%esi),%esi
f01039a0:	29 fe                	sub    %edi,%esi
f01039a2:	19 c3                	sbb    %eax,%ebx
f01039a4:	89 f2                	mov    %esi,%edx
f01039a6:	89 d9                	mov    %ebx,%ecx
f01039a8:	e9 1d ff ff ff       	jmp    f01038ca <__umoddi3+0x6a>
