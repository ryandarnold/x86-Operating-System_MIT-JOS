
obj/user/buggyhello2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003d:	68 00 00 10 00       	push   $0x100000
  800042:	ff 35 00 20 80 00    	pushl  0x802000
  800048:	e8 72 00 00 00       	call   8000bf <sys_cputs>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800061:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800068:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  80006b:	e8 d9 00 00 00       	call   800149 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800078:	c1 e0 05             	shl    $0x5,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x3e>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	e8 99 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009a:	e8 0a 00 00 00       	call   8000a9 <exit>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    

008000a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a9:	f3 0f 1e fb          	endbr32 
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b3:	6a 00                	push   $0x0
  8000b5:	e8 4a 00 00 00       	call   800104 <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bf:	f3 0f 1e fb          	endbr32 
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d4:	89 c3                	mov    %eax,%ebx
  8000d6:	89 c7                	mov    %eax,%edi
  8000d8:	89 c6                	mov    %eax,%esi
  8000da:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e1:	f3 0f 1e fb          	endbr32 
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f5:	89 d1                	mov    %edx,%ecx
  8000f7:	89 d3                	mov    %edx,%ebx
  8000f9:	89 d7                	mov    %edx,%edi
  8000fb:	89 d6                	mov    %edx,%esi
  8000fd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800104:	f3 0f 1e fb          	endbr32 
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800111:	b9 00 00 00 00       	mov    $0x0,%ecx
  800116:	8b 55 08             	mov    0x8(%ebp),%edx
  800119:	b8 03 00 00 00       	mov    $0x3,%eax
  80011e:	89 cb                	mov    %ecx,%ebx
  800120:	89 cf                	mov    %ecx,%edi
  800122:	89 ce                	mov    %ecx,%esi
  800124:	cd 30                	int    $0x30
	if(check && ret > 0)
  800126:	85 c0                	test   %eax,%eax
  800128:	7f 08                	jg     800132 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	50                   	push   %eax
  800136:	6a 03                	push   $0x3
  800138:	68 48 0e 80 00       	push   $0x800e48
  80013d:	6a 23                	push   $0x23
  80013f:	68 65 0e 80 00       	push   $0x800e65
  800144:	e8 23 00 00 00       	call   80016c <_panic>

00800149 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800149:	f3 0f 1e fb          	endbr32 
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 02 00 00 00       	mov    $0x2,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	f3 0f 1e fb          	endbr32 
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800175:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800178:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80017e:	e8 c6 ff ff ff       	call   800149 <sys_getenvid>
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 0c             	pushl  0xc(%ebp)
  800189:	ff 75 08             	pushl  0x8(%ebp)
  80018c:	56                   	push   %esi
  80018d:	50                   	push   %eax
  80018e:	68 74 0e 80 00       	push   $0x800e74
  800193:	e8 bb 00 00 00       	call   800253 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800198:	83 c4 18             	add    $0x18,%esp
  80019b:	53                   	push   %ebx
  80019c:	ff 75 10             	pushl  0x10(%ebp)
  80019f:	e8 5a 00 00 00       	call   8001fe <vcprintf>
	cprintf("\n");
  8001a4:	c7 04 24 3c 0e 80 00 	movl   $0x800e3c,(%esp)
  8001ab:	e8 a3 00 00 00       	call   800253 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b3:	cc                   	int3   
  8001b4:	eb fd                	jmp    8001b3 <_panic+0x47>

008001b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b6:	f3 0f 1e fb          	endbr32 
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 04             	sub    $0x4,%esp
  8001c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c4:	8b 13                	mov    (%ebx),%edx
  8001c6:	8d 42 01             	lea    0x1(%edx),%eax
  8001c9:	89 03                	mov    %eax,(%ebx)
  8001cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ce:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d7:	74 09                	je     8001e2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	68 ff 00 00 00       	push   $0xff
  8001ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 cc fe ff ff       	call   8000bf <sys_cputs>
		b->idx = 0;
  8001f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb db                	jmp    8001d9 <putch+0x23>

008001fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fe:	f3 0f 1e fb          	endbr32 
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80020b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800212:	00 00 00 
	b.cnt = 0;
  800215:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021f:	ff 75 0c             	pushl  0xc(%ebp)
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022b:	50                   	push   %eax
  80022c:	68 b6 01 80 00       	push   $0x8001b6
  800231:	e8 20 01 00 00       	call   800356 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800236:	83 c4 08             	add    $0x8,%esp
  800239:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	e8 74 fe ff ff       	call   8000bf <sys_cputs>

	return b.cnt;
}
  80024b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800253:	f3 0f 1e fb          	endbr32 
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800260:	50                   	push   %eax
  800261:	ff 75 08             	pushl  0x8(%ebp)
  800264:	e8 95 ff ff ff       	call   8001fe <vcprintf>
	va_end(ap);

	return cnt;
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 1c             	sub    $0x1c,%esp
  800274:	89 c7                	mov    %eax,%edi
  800276:	89 d6                	mov    %edx,%esi
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
  80027b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027e:	89 d1                	mov    %edx,%ecx
  800280:	89 c2                	mov    %eax,%edx
  800282:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800285:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800288:	8b 45 10             	mov    0x10(%ebp),%eax
  80028b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800291:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800298:	39 c2                	cmp    %eax,%edx
  80029a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80029d:	72 3e                	jb     8002dd <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029f:	83 ec 0c             	sub    $0xc,%esp
  8002a2:	ff 75 18             	pushl  0x18(%ebp)
  8002a5:	83 eb 01             	sub    $0x1,%ebx
  8002a8:	53                   	push   %ebx
  8002a9:	50                   	push   %eax
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b9:	e8 12 09 00 00       	call   800bd0 <__udivdi3>
  8002be:	83 c4 18             	add    $0x18,%esp
  8002c1:	52                   	push   %edx
  8002c2:	50                   	push   %eax
  8002c3:	89 f2                	mov    %esi,%edx
  8002c5:	89 f8                	mov    %edi,%eax
  8002c7:	e8 9f ff ff ff       	call   80026b <printnum>
  8002cc:	83 c4 20             	add    $0x20,%esp
  8002cf:	eb 13                	jmp    8002e4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	56                   	push   %esi
  8002d5:	ff 75 18             	pushl  0x18(%ebp)
  8002d8:	ff d7                	call   *%edi
  8002da:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	85 db                	test   %ebx,%ebx
  8002e2:	7f ed                	jg     8002d1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	56                   	push   %esi
  8002e8:	83 ec 04             	sub    $0x4,%esp
  8002eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f7:	e8 e4 09 00 00       	call   800ce0 <__umoddi3>
  8002fc:	83 c4 14             	add    $0x14,%esp
  8002ff:	0f be 80 97 0e 80 00 	movsbl 0x800e97(%eax),%eax
  800306:	50                   	push   %eax
  800307:	ff d7                	call   *%edi
}
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800314:	f3 0f 1e fb          	endbr32 
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800322:	8b 10                	mov    (%eax),%edx
  800324:	3b 50 04             	cmp    0x4(%eax),%edx
  800327:	73 0a                	jae    800333 <sprintputch+0x1f>
		*b->buf++ = ch;
  800329:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032c:	89 08                	mov    %ecx,(%eax)
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	88 02                	mov    %al,(%edx)
}
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <printfmt>:
{
  800335:	f3 0f 1e fb          	endbr32 
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80033f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800342:	50                   	push   %eax
  800343:	ff 75 10             	pushl  0x10(%ebp)
  800346:	ff 75 0c             	pushl  0xc(%ebp)
  800349:	ff 75 08             	pushl  0x8(%ebp)
  80034c:	e8 05 00 00 00       	call   800356 <vprintfmt>
}
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	c9                   	leave  
  800355:	c3                   	ret    

00800356 <vprintfmt>:
{
  800356:	f3 0f 1e fb          	endbr32 
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	57                   	push   %edi
  80035e:	56                   	push   %esi
  80035f:	53                   	push   %ebx
  800360:	83 ec 3c             	sub    $0x3c,%esp
  800363:	8b 75 08             	mov    0x8(%ebp),%esi
  800366:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800369:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036c:	e9 8e 03 00 00       	jmp    8006ff <vprintfmt+0x3a9>
		padc = ' ';
  800371:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800375:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80037c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800383:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80038a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8d 47 01             	lea    0x1(%edi),%eax
  800392:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800395:	0f b6 17             	movzbl (%edi),%edx
  800398:	8d 42 dd             	lea    -0x23(%edx),%eax
  80039b:	3c 55                	cmp    $0x55,%al
  80039d:	0f 87 df 03 00 00    	ja     800782 <vprintfmt+0x42c>
  8003a3:	0f b6 c0             	movzbl %al,%eax
  8003a6:	3e ff 24 85 24 0f 80 	notrack jmp *0x800f24(,%eax,4)
  8003ad:	00 
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003b1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003b5:	eb d8                	jmp    80038f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ba:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003be:	eb cf                	jmp    80038f <vprintfmt+0x39>
  8003c0:	0f b6 d2             	movzbl %dl,%edx
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ce:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003d5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003d8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003db:	83 f9 09             	cmp    $0x9,%ecx
  8003de:	77 55                	ja     800435 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003e0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003e3:	eb e9                	jmp    8003ce <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 40 04             	lea    0x4(%eax),%eax
  8003f3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fd:	79 90                	jns    80038f <vprintfmt+0x39>
				width = precision, precision = -1;
  8003ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800402:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800405:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80040c:	eb 81                	jmp    80038f <vprintfmt+0x39>
  80040e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800411:	85 c0                	test   %eax,%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
  800418:	0f 49 d0             	cmovns %eax,%edx
  80041b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800421:	e9 69 ff ff ff       	jmp    80038f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800429:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800430:	e9 5a ff ff ff       	jmp    80038f <vprintfmt+0x39>
  800435:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800438:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043b:	eb bc                	jmp    8003f9 <vprintfmt+0xa3>
			lflag++;
  80043d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800443:	e9 47 ff ff ff       	jmp    80038f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 78 04             	lea    0x4(%eax),%edi
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	53                   	push   %ebx
  800452:	ff 30                	pushl  (%eax)
  800454:	ff d6                	call   *%esi
			break;
  800456:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800459:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80045c:	e9 9b 02 00 00       	jmp    8006fc <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 78 04             	lea    0x4(%eax),%edi
  800467:	8b 00                	mov    (%eax),%eax
  800469:	99                   	cltd   
  80046a:	31 d0                	xor    %edx,%eax
  80046c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046e:	83 f8 06             	cmp    $0x6,%eax
  800471:	7f 23                	jg     800496 <vprintfmt+0x140>
  800473:	8b 14 85 7c 10 80 00 	mov    0x80107c(,%eax,4),%edx
  80047a:	85 d2                	test   %edx,%edx
  80047c:	74 18                	je     800496 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80047e:	52                   	push   %edx
  80047f:	68 b8 0e 80 00       	push   $0x800eb8
  800484:	53                   	push   %ebx
  800485:	56                   	push   %esi
  800486:	e8 aa fe ff ff       	call   800335 <printfmt>
  80048b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800491:	e9 66 02 00 00       	jmp    8006fc <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800496:	50                   	push   %eax
  800497:	68 af 0e 80 00       	push   $0x800eaf
  80049c:	53                   	push   %ebx
  80049d:	56                   	push   %esi
  80049e:	e8 92 fe ff ff       	call   800335 <printfmt>
  8004a3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004a6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004a9:	e9 4e 02 00 00       	jmp    8006fc <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	83 c0 04             	add    $0x4,%eax
  8004b4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004bc:	85 d2                	test   %edx,%edx
  8004be:	b8 a8 0e 80 00       	mov    $0x800ea8,%eax
  8004c3:	0f 45 c2             	cmovne %edx,%eax
  8004c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cd:	7e 06                	jle    8004d5 <vprintfmt+0x17f>
  8004cf:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004d3:	75 0d                	jne    8004e2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d8:	89 c7                	mov    %eax,%edi
  8004da:	03 45 e0             	add    -0x20(%ebp),%eax
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e0:	eb 55                	jmp    800537 <vprintfmt+0x1e1>
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e8:	ff 75 cc             	pushl  -0x34(%ebp)
  8004eb:	e8 46 03 00 00       	call   800836 <strnlen>
  8004f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f3:	29 c2                	sub    %eax,%edx
  8004f5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004fd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	85 ff                	test   %edi,%edi
  800506:	7e 11                	jle    800519 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	ff 75 e0             	pushl  -0x20(%ebp)
  80050f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ef 01             	sub    $0x1,%edi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb eb                	jmp    800504 <vprintfmt+0x1ae>
  800519:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80051c:	85 d2                	test   %edx,%edx
  80051e:	b8 00 00 00 00       	mov    $0x0,%eax
  800523:	0f 49 c2             	cmovns %edx,%eax
  800526:	29 c2                	sub    %eax,%edx
  800528:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80052b:	eb a8                	jmp    8004d5 <vprintfmt+0x17f>
					putch(ch, putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	52                   	push   %edx
  800532:	ff d6                	call   *%esi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053c:	83 c7 01             	add    $0x1,%edi
  80053f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800543:	0f be d0             	movsbl %al,%edx
  800546:	85 d2                	test   %edx,%edx
  800548:	74 4b                	je     800595 <vprintfmt+0x23f>
  80054a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054e:	78 06                	js     800556 <vprintfmt+0x200>
  800550:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800554:	78 1e                	js     800574 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800556:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055a:	74 d1                	je     80052d <vprintfmt+0x1d7>
  80055c:	0f be c0             	movsbl %al,%eax
  80055f:	83 e8 20             	sub    $0x20,%eax
  800562:	83 f8 5e             	cmp    $0x5e,%eax
  800565:	76 c6                	jbe    80052d <vprintfmt+0x1d7>
					putch('?', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	53                   	push   %ebx
  80056b:	6a 3f                	push   $0x3f
  80056d:	ff d6                	call   *%esi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	eb c3                	jmp    800537 <vprintfmt+0x1e1>
  800574:	89 cf                	mov    %ecx,%edi
  800576:	eb 0e                	jmp    800586 <vprintfmt+0x230>
				putch(' ', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	6a 20                	push   $0x20
  80057e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800580:	83 ef 01             	sub    $0x1,%edi
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	85 ff                	test   %edi,%edi
  800588:	7f ee                	jg     800578 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80058a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
  800590:	e9 67 01 00 00       	jmp    8006fc <vprintfmt+0x3a6>
  800595:	89 cf                	mov    %ecx,%edi
  800597:	eb ed                	jmp    800586 <vprintfmt+0x230>
	if (lflag >= 2)
  800599:	83 f9 01             	cmp    $0x1,%ecx
  80059c:	7f 1b                	jg     8005b9 <vprintfmt+0x263>
	else if (lflag)
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	74 63                	je     800605 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	99                   	cltd   
  8005ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 40 04             	lea    0x4(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b7:	eb 17                	jmp    8005d0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 50 04             	mov    0x4(%eax),%edx
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 40 08             	lea    0x8(%eax),%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005db:	85 c9                	test   %ecx,%ecx
  8005dd:	0f 89 ff 00 00 00    	jns    8006e2 <vprintfmt+0x38c>
				putch('-', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 2d                	push   $0x2d
  8005e9:	ff d6                	call   *%esi
				num = -(long long) num;
  8005eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005f1:	f7 da                	neg    %edx
  8005f3:	83 d1 00             	adc    $0x0,%ecx
  8005f6:	f7 d9                	neg    %ecx
  8005f8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800600:	e9 dd 00 00 00       	jmp    8006e2 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 00                	mov    (%eax),%eax
  80060a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060d:	99                   	cltd   
  80060e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 40 04             	lea    0x4(%eax),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
  80061a:	eb b4                	jmp    8005d0 <vprintfmt+0x27a>
	if (lflag >= 2)
  80061c:	83 f9 01             	cmp    $0x1,%ecx
  80061f:	7f 1e                	jg     80063f <vprintfmt+0x2e9>
	else if (lflag)
  800621:	85 c9                	test   %ecx,%ecx
  800623:	74 32                	je     800657 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062f:	8d 40 04             	lea    0x4(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800635:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80063a:	e9 a3 00 00 00       	jmp    8006e2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	8b 48 04             	mov    0x4(%eax),%ecx
  800647:	8d 40 08             	lea    0x8(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800652:	e9 8b 00 00 00       	jmp    8006e2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800667:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80066c:	eb 74                	jmp    8006e2 <vprintfmt+0x38c>
	if (lflag >= 2)
  80066e:	83 f9 01             	cmp    $0x1,%ecx
  800671:	7f 1b                	jg     80068e <vprintfmt+0x338>
	else if (lflag)
  800673:	85 c9                	test   %ecx,%ecx
  800675:	74 2c                	je     8006a3 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800687:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80068c:	eb 54                	jmp    8006e2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 10                	mov    (%eax),%edx
  800693:	8b 48 04             	mov    0x4(%eax),%ecx
  800696:	8d 40 08             	lea    0x8(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80069c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8006a1:	eb 3f                	jmp    8006e2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8006b3:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006b8:	eb 28                	jmp    8006e2 <vprintfmt+0x38c>
			putch('0', putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	6a 30                	push   $0x30
  8006c0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c2:	83 c4 08             	add    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 78                	push   $0x78
  8006c8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006d4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dd:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006e2:	83 ec 0c             	sub    $0xc,%esp
  8006e5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006e9:	57                   	push   %edi
  8006ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ed:	50                   	push   %eax
  8006ee:	51                   	push   %ecx
  8006ef:	52                   	push   %edx
  8006f0:	89 da                	mov    %ebx,%edx
  8006f2:	89 f0                	mov    %esi,%eax
  8006f4:	e8 72 fb ff ff       	call   80026b <printnum>
			break;
  8006f9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ff:	83 c7 01             	add    $0x1,%edi
  800702:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800706:	83 f8 25             	cmp    $0x25,%eax
  800709:	0f 84 62 fc ff ff    	je     800371 <vprintfmt+0x1b>
			if (ch == '\0')
  80070f:	85 c0                	test   %eax,%eax
  800711:	0f 84 8b 00 00 00    	je     8007a2 <vprintfmt+0x44c>
			putch(ch, putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	50                   	push   %eax
  80071c:	ff d6                	call   *%esi
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb dc                	jmp    8006ff <vprintfmt+0x3a9>
	if (lflag >= 2)
  800723:	83 f9 01             	cmp    $0x1,%ecx
  800726:	7f 1b                	jg     800743 <vprintfmt+0x3ed>
	else if (lflag)
  800728:	85 c9                	test   %ecx,%ecx
  80072a:	74 2c                	je     800758 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	b9 00 00 00 00       	mov    $0x0,%ecx
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800741:	eb 9f                	jmp    8006e2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8b 10                	mov    (%eax),%edx
  800748:	8b 48 04             	mov    0x4(%eax),%ecx
  80074b:	8d 40 08             	lea    0x8(%eax),%eax
  80074e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800751:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800756:	eb 8a                	jmp    8006e2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800762:	8d 40 04             	lea    0x4(%eax),%eax
  800765:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800768:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80076d:	e9 70 ff ff ff       	jmp    8006e2 <vprintfmt+0x38c>
			putch(ch, putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			break;
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	e9 7a ff ff ff       	jmp    8006fc <vprintfmt+0x3a6>
			putch('%', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 25                	push   $0x25
  800788:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	89 f8                	mov    %edi,%eax
  80078f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800793:	74 05                	je     80079a <vprintfmt+0x444>
  800795:	83 e8 01             	sub    $0x1,%eax
  800798:	eb f5                	jmp    80078f <vprintfmt+0x439>
  80079a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80079d:	e9 5a ff ff ff       	jmp    8006fc <vprintfmt+0x3a6>
}
  8007a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a5:	5b                   	pop    %ebx
  8007a6:	5e                   	pop    %esi
  8007a7:	5f                   	pop    %edi
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007aa:	f3 0f 1e fb          	endbr32 
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	83 ec 18             	sub    $0x18,%esp
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	74 26                	je     8007f5 <vsnprintf+0x4b>
  8007cf:	85 d2                	test   %edx,%edx
  8007d1:	7e 22                	jle    8007f5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d3:	ff 75 14             	pushl  0x14(%ebp)
  8007d6:	ff 75 10             	pushl  0x10(%ebp)
  8007d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	68 14 03 80 00       	push   $0x800314
  8007e2:	e8 6f fb ff ff       	call   800356 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f0:	83 c4 10             	add    $0x10,%esp
}
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    
		return -E_INVAL;
  8007f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fa:	eb f7                	jmp    8007f3 <vsnprintf+0x49>

008007fc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fc:	f3 0f 1e fb          	endbr32 
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800809:	50                   	push   %eax
  80080a:	ff 75 10             	pushl  0x10(%ebp)
  80080d:	ff 75 0c             	pushl  0xc(%ebp)
  800810:	ff 75 08             	pushl  0x8(%ebp)
  800813:	e8 92 ff ff ff       	call   8007aa <vsnprintf>
	va_end(ap);

	return rc;
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081a:	f3 0f 1e fb          	endbr32 
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082d:	74 05                	je     800834 <strlen+0x1a>
		n++;
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	eb f5                	jmp    800829 <strlen+0xf>
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800836:	f3 0f 1e fb          	endbr32 
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	39 d0                	cmp    %edx,%eax
  80084a:	74 0d                	je     800859 <strnlen+0x23>
  80084c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800850:	74 05                	je     800857 <strnlen+0x21>
		n++;
  800852:	83 c0 01             	add    $0x1,%eax
  800855:	eb f1                	jmp    800848 <strnlen+0x12>
  800857:	89 c2                	mov    %eax,%edx
	return n;
}
  800859:	89 d0                	mov    %edx,%eax
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085d:	f3 0f 1e fb          	endbr32 
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
  800870:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800874:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800877:	83 c0 01             	add    $0x1,%eax
  80087a:	84 d2                	test   %dl,%dl
  80087c:	75 f2                	jne    800870 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80087e:	89 c8                	mov    %ecx,%eax
  800880:	5b                   	pop    %ebx
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800883:	f3 0f 1e fb          	endbr32 
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 10             	sub    $0x10,%esp
  80088e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800891:	53                   	push   %ebx
  800892:	e8 83 ff ff ff       	call   80081a <strlen>
  800897:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80089a:	ff 75 0c             	pushl  0xc(%ebp)
  80089d:	01 d8                	add    %ebx,%eax
  80089f:	50                   	push   %eax
  8008a0:	e8 b8 ff ff ff       	call   80085d <strcpy>
	return dst;
}
  8008a5:	89 d8                	mov    %ebx,%eax
  8008a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ac:	f3 0f 1e fb          	endbr32 
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	56                   	push   %esi
  8008b4:	53                   	push   %ebx
  8008b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bb:	89 f3                	mov    %esi,%ebx
  8008bd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c0:	89 f0                	mov    %esi,%eax
  8008c2:	39 d8                	cmp    %ebx,%eax
  8008c4:	74 11                	je     8008d7 <strncpy+0x2b>
		*dst++ = *src;
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	0f b6 0a             	movzbl (%edx),%ecx
  8008cc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cf:	80 f9 01             	cmp    $0x1,%cl
  8008d2:	83 da ff             	sbb    $0xffffffff,%edx
  8008d5:	eb eb                	jmp    8008c2 <strncpy+0x16>
	}
	return ret;
}
  8008d7:	89 f0                	mov    %esi,%eax
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008dd:	f3 0f 1e fb          	endbr32 
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ef:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	74 21                	je     800916 <strlcpy+0x39>
  8008f5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008fb:	39 c2                	cmp    %eax,%edx
  8008fd:	74 14                	je     800913 <strlcpy+0x36>
  8008ff:	0f b6 19             	movzbl (%ecx),%ebx
  800902:	84 db                	test   %bl,%bl
  800904:	74 0b                	je     800911 <strlcpy+0x34>
			*dst++ = *src++;
  800906:	83 c1 01             	add    $0x1,%ecx
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090f:	eb ea                	jmp    8008fb <strlcpy+0x1e>
  800911:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800913:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800916:	29 f0                	sub    %esi,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091c:	f3 0f 1e fb          	endbr32 
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800929:	0f b6 01             	movzbl (%ecx),%eax
  80092c:	84 c0                	test   %al,%al
  80092e:	74 0c                	je     80093c <strcmp+0x20>
  800930:	3a 02                	cmp    (%edx),%al
  800932:	75 08                	jne    80093c <strcmp+0x20>
		p++, q++;
  800934:	83 c1 01             	add    $0x1,%ecx
  800937:	83 c2 01             	add    $0x1,%edx
  80093a:	eb ed                	jmp    800929 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093c:	0f b6 c0             	movzbl %al,%eax
  80093f:	0f b6 12             	movzbl (%edx),%edx
  800942:	29 d0                	sub    %edx,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800946:	f3 0f 1e fb          	endbr32 
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	89 c3                	mov    %eax,%ebx
  800956:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800959:	eb 06                	jmp    800961 <strncmp+0x1b>
		n--, p++, q++;
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800961:	39 d8                	cmp    %ebx,%eax
  800963:	74 16                	je     80097b <strncmp+0x35>
  800965:	0f b6 08             	movzbl (%eax),%ecx
  800968:	84 c9                	test   %cl,%cl
  80096a:	74 04                	je     800970 <strncmp+0x2a>
  80096c:	3a 0a                	cmp    (%edx),%cl
  80096e:	74 eb                	je     80095b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800970:	0f b6 00             	movzbl (%eax),%eax
  800973:	0f b6 12             	movzbl (%edx),%edx
  800976:	29 d0                	sub    %edx,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    
		return 0;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
  800980:	eb f6                	jmp    800978 <strncmp+0x32>

00800982 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800982:	f3 0f 1e fb          	endbr32 
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800990:	0f b6 10             	movzbl (%eax),%edx
  800993:	84 d2                	test   %dl,%dl
  800995:	74 09                	je     8009a0 <strchr+0x1e>
		if (*s == c)
  800997:	38 ca                	cmp    %cl,%dl
  800999:	74 0a                	je     8009a5 <strchr+0x23>
	for (; *s; s++)
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	eb f0                	jmp    800990 <strchr+0xe>
			return (char *) s;
	return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a7:	f3 0f 1e fb          	endbr32 
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b8:	38 ca                	cmp    %cl,%dl
  8009ba:	74 09                	je     8009c5 <strfind+0x1e>
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	74 05                	je     8009c5 <strfind+0x1e>
	for (; *s; s++)
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	eb f0                	jmp    8009b5 <strfind+0xe>
			break;
	return (char *) s;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c7:	f3 0f 1e fb          	endbr32 
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d7:	85 c9                	test   %ecx,%ecx
  8009d9:	74 31                	je     800a0c <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009db:	89 f8                	mov    %edi,%eax
  8009dd:	09 c8                	or     %ecx,%eax
  8009df:	a8 03                	test   $0x3,%al
  8009e1:	75 23                	jne    800a06 <memset+0x3f>
		c &= 0xFF;
  8009e3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e7:	89 d3                	mov    %edx,%ebx
  8009e9:	c1 e3 08             	shl    $0x8,%ebx
  8009ec:	89 d0                	mov    %edx,%eax
  8009ee:	c1 e0 18             	shl    $0x18,%eax
  8009f1:	89 d6                	mov    %edx,%esi
  8009f3:	c1 e6 10             	shl    $0x10,%esi
  8009f6:	09 f0                	or     %esi,%eax
  8009f8:	09 c2                	or     %eax,%edx
  8009fa:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ff:	89 d0                	mov    %edx,%eax
  800a01:	fc                   	cld    
  800a02:	f3 ab                	rep stos %eax,%es:(%edi)
  800a04:	eb 06                	jmp    800a0c <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a09:	fc                   	cld    
  800a0a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0c:	89 f8                	mov    %edi,%eax
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a13:	f3 0f 1e fb          	endbr32 
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a25:	39 c6                	cmp    %eax,%esi
  800a27:	73 32                	jae    800a5b <memmove+0x48>
  800a29:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2c:	39 c2                	cmp    %eax,%edx
  800a2e:	76 2b                	jbe    800a5b <memmove+0x48>
		s += n;
		d += n;
  800a30:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a33:	89 fe                	mov    %edi,%esi
  800a35:	09 ce                	or     %ecx,%esi
  800a37:	09 d6                	or     %edx,%esi
  800a39:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3f:	75 0e                	jne    800a4f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a41:	83 ef 04             	sub    $0x4,%edi
  800a44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a47:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4d:	eb 09                	jmp    800a58 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a4f:	83 ef 01             	sub    $0x1,%edi
  800a52:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a55:	fd                   	std    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a58:	fc                   	cld    
  800a59:	eb 1a                	jmp    800a75 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	09 ca                	or     %ecx,%edx
  800a5f:	09 f2                	or     %esi,%edx
  800a61:	f6 c2 03             	test   $0x3,%dl
  800a64:	75 0a                	jne    800a70 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a66:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a69:	89 c7                	mov    %eax,%edi
  800a6b:	fc                   	cld    
  800a6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6e:	eb 05                	jmp    800a75 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a70:	89 c7                	mov    %eax,%edi
  800a72:	fc                   	cld    
  800a73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a79:	f3 0f 1e fb          	endbr32 
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a83:	ff 75 10             	pushl  0x10(%ebp)
  800a86:	ff 75 0c             	pushl  0xc(%ebp)
  800a89:	ff 75 08             	pushl  0x8(%ebp)
  800a8c:	e8 82 ff ff ff       	call   800a13 <memmove>
}
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a93:	f3 0f 1e fb          	endbr32 
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa2:	89 c6                	mov    %eax,%esi
  800aa4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	39 f0                	cmp    %esi,%eax
  800aa9:	74 1c                	je     800ac7 <memcmp+0x34>
		if (*s1 != *s2)
  800aab:	0f b6 08             	movzbl (%eax),%ecx
  800aae:	0f b6 1a             	movzbl (%edx),%ebx
  800ab1:	38 d9                	cmp    %bl,%cl
  800ab3:	75 08                	jne    800abd <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab5:	83 c0 01             	add    $0x1,%eax
  800ab8:	83 c2 01             	add    $0x1,%edx
  800abb:	eb ea                	jmp    800aa7 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 05                	jmp    800acc <memcmp+0x39>
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad0:	f3 0f 1e fb          	endbr32 
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800add:	89 c2                	mov    %eax,%edx
  800adf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae2:	39 d0                	cmp    %edx,%eax
  800ae4:	73 09                	jae    800aef <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	38 08                	cmp    %cl,(%eax)
  800ae8:	74 05                	je     800aef <memfind+0x1f>
	for (; s < ends; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	eb f3                	jmp    800ae2 <memfind+0x12>
			break;
	return (void *) s;
}
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af1:	f3 0f 1e fb          	endbr32 
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b01:	eb 03                	jmp    800b06 <strtol+0x15>
		s++;
  800b03:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b06:	0f b6 01             	movzbl (%ecx),%eax
  800b09:	3c 20                	cmp    $0x20,%al
  800b0b:	74 f6                	je     800b03 <strtol+0x12>
  800b0d:	3c 09                	cmp    $0x9,%al
  800b0f:	74 f2                	je     800b03 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b11:	3c 2b                	cmp    $0x2b,%al
  800b13:	74 2a                	je     800b3f <strtol+0x4e>
	int neg = 0;
  800b15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1a:	3c 2d                	cmp    $0x2d,%al
  800b1c:	74 2b                	je     800b49 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b24:	75 0f                	jne    800b35 <strtol+0x44>
  800b26:	80 39 30             	cmpb   $0x30,(%ecx)
  800b29:	74 28                	je     800b53 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2b:	85 db                	test   %ebx,%ebx
  800b2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b32:	0f 44 d8             	cmove  %eax,%ebx
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b3d:	eb 46                	jmp    800b85 <strtol+0x94>
		s++;
  800b3f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b42:	bf 00 00 00 00       	mov    $0x0,%edi
  800b47:	eb d5                	jmp    800b1e <strtol+0x2d>
		s++, neg = 1;
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b51:	eb cb                	jmp    800b1e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b57:	74 0e                	je     800b67 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b59:	85 db                	test   %ebx,%ebx
  800b5b:	75 d8                	jne    800b35 <strtol+0x44>
		s++, base = 8;
  800b5d:	83 c1 01             	add    $0x1,%ecx
  800b60:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b65:	eb ce                	jmp    800b35 <strtol+0x44>
		s += 2, base = 16;
  800b67:	83 c1 02             	add    $0x2,%ecx
  800b6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6f:	eb c4                	jmp    800b35 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b71:	0f be d2             	movsbl %dl,%edx
  800b74:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b77:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7a:	7d 3a                	jge    800bb6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b7c:	83 c1 01             	add    $0x1,%ecx
  800b7f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b83:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b85:	0f b6 11             	movzbl (%ecx),%edx
  800b88:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 09             	cmp    $0x9,%bl
  800b90:	76 df                	jbe    800b71 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b92:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 19             	cmp    $0x19,%bl
  800b9a:	77 08                	ja     800ba4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	83 ea 57             	sub    $0x57,%edx
  800ba2:	eb d3                	jmp    800b77 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ba4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba7:	89 f3                	mov    %esi,%ebx
  800ba9:	80 fb 19             	cmp    $0x19,%bl
  800bac:	77 08                	ja     800bb6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bae:	0f be d2             	movsbl %dl,%edx
  800bb1:	83 ea 37             	sub    $0x37,%edx
  800bb4:	eb c1                	jmp    800b77 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bba:	74 05                	je     800bc1 <strtol+0xd0>
		*endptr = (char *) s;
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bc1:	89 c2                	mov    %eax,%edx
  800bc3:	f7 da                	neg    %edx
  800bc5:	85 ff                	test   %edi,%edi
  800bc7:	0f 45 c2             	cmovne %edx,%eax
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    
  800bcf:	90                   	nop

00800bd0 <__udivdi3>:
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 1c             	sub    $0x1c,%esp
  800bdb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800bdf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800be3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800be7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800beb:	85 d2                	test   %edx,%edx
  800bed:	75 19                	jne    800c08 <__udivdi3+0x38>
  800bef:	39 f3                	cmp    %esi,%ebx
  800bf1:	76 4d                	jbe    800c40 <__udivdi3+0x70>
  800bf3:	31 ff                	xor    %edi,%edi
  800bf5:	89 e8                	mov    %ebp,%eax
  800bf7:	89 f2                	mov    %esi,%edx
  800bf9:	f7 f3                	div    %ebx
  800bfb:	89 fa                	mov    %edi,%edx
  800bfd:	83 c4 1c             	add    $0x1c,%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    
  800c05:	8d 76 00             	lea    0x0(%esi),%esi
  800c08:	39 f2                	cmp    %esi,%edx
  800c0a:	76 14                	jbe    800c20 <__udivdi3+0x50>
  800c0c:	31 ff                	xor    %edi,%edi
  800c0e:	31 c0                	xor    %eax,%eax
  800c10:	89 fa                	mov    %edi,%edx
  800c12:	83 c4 1c             	add    $0x1c,%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    
  800c1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c20:	0f bd fa             	bsr    %edx,%edi
  800c23:	83 f7 1f             	xor    $0x1f,%edi
  800c26:	75 48                	jne    800c70 <__udivdi3+0xa0>
  800c28:	39 f2                	cmp    %esi,%edx
  800c2a:	72 06                	jb     800c32 <__udivdi3+0x62>
  800c2c:	31 c0                	xor    %eax,%eax
  800c2e:	39 eb                	cmp    %ebp,%ebx
  800c30:	77 de                	ja     800c10 <__udivdi3+0x40>
  800c32:	b8 01 00 00 00       	mov    $0x1,%eax
  800c37:	eb d7                	jmp    800c10 <__udivdi3+0x40>
  800c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c40:	89 d9                	mov    %ebx,%ecx
  800c42:	85 db                	test   %ebx,%ebx
  800c44:	75 0b                	jne    800c51 <__udivdi3+0x81>
  800c46:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4b:	31 d2                	xor    %edx,%edx
  800c4d:	f7 f3                	div    %ebx
  800c4f:	89 c1                	mov    %eax,%ecx
  800c51:	31 d2                	xor    %edx,%edx
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	f7 f1                	div    %ecx
  800c57:	89 c6                	mov    %eax,%esi
  800c59:	89 e8                	mov    %ebp,%eax
  800c5b:	89 f7                	mov    %esi,%edi
  800c5d:	f7 f1                	div    %ecx
  800c5f:	89 fa                	mov    %edi,%edx
  800c61:	83 c4 1c             	add    $0x1c,%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    
  800c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c70:	89 f9                	mov    %edi,%ecx
  800c72:	b8 20 00 00 00       	mov    $0x20,%eax
  800c77:	29 f8                	sub    %edi,%eax
  800c79:	d3 e2                	shl    %cl,%edx
  800c7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c7f:	89 c1                	mov    %eax,%ecx
  800c81:	89 da                	mov    %ebx,%edx
  800c83:	d3 ea                	shr    %cl,%edx
  800c85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c89:	09 d1                	or     %edx,%ecx
  800c8b:	89 f2                	mov    %esi,%edx
  800c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c91:	89 f9                	mov    %edi,%ecx
  800c93:	d3 e3                	shl    %cl,%ebx
  800c95:	89 c1                	mov    %eax,%ecx
  800c97:	d3 ea                	shr    %cl,%edx
  800c99:	89 f9                	mov    %edi,%ecx
  800c9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800c9f:	89 eb                	mov    %ebp,%ebx
  800ca1:	d3 e6                	shl    %cl,%esi
  800ca3:	89 c1                	mov    %eax,%ecx
  800ca5:	d3 eb                	shr    %cl,%ebx
  800ca7:	09 de                	or     %ebx,%esi
  800ca9:	89 f0                	mov    %esi,%eax
  800cab:	f7 74 24 08          	divl   0x8(%esp)
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	f7 64 24 0c          	mull   0xc(%esp)
  800cb7:	39 d6                	cmp    %edx,%esi
  800cb9:	72 15                	jb     800cd0 <__udivdi3+0x100>
  800cbb:	89 f9                	mov    %edi,%ecx
  800cbd:	d3 e5                	shl    %cl,%ebp
  800cbf:	39 c5                	cmp    %eax,%ebp
  800cc1:	73 04                	jae    800cc7 <__udivdi3+0xf7>
  800cc3:	39 d6                	cmp    %edx,%esi
  800cc5:	74 09                	je     800cd0 <__udivdi3+0x100>
  800cc7:	89 d8                	mov    %ebx,%eax
  800cc9:	31 ff                	xor    %edi,%edi
  800ccb:	e9 40 ff ff ff       	jmp    800c10 <__udivdi3+0x40>
  800cd0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cd3:	31 ff                	xor    %edi,%edi
  800cd5:	e9 36 ff ff ff       	jmp    800c10 <__udivdi3+0x40>
  800cda:	66 90                	xchg   %ax,%ax
  800cdc:	66 90                	xchg   %ax,%ax
  800cde:	66 90                	xchg   %ax,%ax

00800ce0 <__umoddi3>:
  800ce0:	f3 0f 1e fb          	endbr32 
  800ce4:	55                   	push   %ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 1c             	sub    $0x1c,%esp
  800ceb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cef:	8b 74 24 30          	mov    0x30(%esp),%esi
  800cf3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800cf7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	75 19                	jne    800d18 <__umoddi3+0x38>
  800cff:	39 df                	cmp    %ebx,%edi
  800d01:	76 5d                	jbe    800d60 <__umoddi3+0x80>
  800d03:	89 f0                	mov    %esi,%eax
  800d05:	89 da                	mov    %ebx,%edx
  800d07:	f7 f7                	div    %edi
  800d09:	89 d0                	mov    %edx,%eax
  800d0b:	31 d2                	xor    %edx,%edx
  800d0d:	83 c4 1c             	add    $0x1c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
  800d15:	8d 76 00             	lea    0x0(%esi),%esi
  800d18:	89 f2                	mov    %esi,%edx
  800d1a:	39 d8                	cmp    %ebx,%eax
  800d1c:	76 12                	jbe    800d30 <__umoddi3+0x50>
  800d1e:	89 f0                	mov    %esi,%eax
  800d20:	89 da                	mov    %ebx,%edx
  800d22:	83 c4 1c             	add    $0x1c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    
  800d2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d30:	0f bd e8             	bsr    %eax,%ebp
  800d33:	83 f5 1f             	xor    $0x1f,%ebp
  800d36:	75 50                	jne    800d88 <__umoddi3+0xa8>
  800d38:	39 d8                	cmp    %ebx,%eax
  800d3a:	0f 82 e0 00 00 00    	jb     800e20 <__umoddi3+0x140>
  800d40:	89 d9                	mov    %ebx,%ecx
  800d42:	39 f7                	cmp    %esi,%edi
  800d44:	0f 86 d6 00 00 00    	jbe    800e20 <__umoddi3+0x140>
  800d4a:	89 d0                	mov    %edx,%eax
  800d4c:	89 ca                	mov    %ecx,%edx
  800d4e:	83 c4 1c             	add    $0x1c,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
  800d56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d5d:	8d 76 00             	lea    0x0(%esi),%esi
  800d60:	89 fd                	mov    %edi,%ebp
  800d62:	85 ff                	test   %edi,%edi
  800d64:	75 0b                	jne    800d71 <__umoddi3+0x91>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f7                	div    %edi
  800d6f:	89 c5                	mov    %eax,%ebp
  800d71:	89 d8                	mov    %ebx,%eax
  800d73:	31 d2                	xor    %edx,%edx
  800d75:	f7 f5                	div    %ebp
  800d77:	89 f0                	mov    %esi,%eax
  800d79:	f7 f5                	div    %ebp
  800d7b:	89 d0                	mov    %edx,%eax
  800d7d:	31 d2                	xor    %edx,%edx
  800d7f:	eb 8c                	jmp    800d0d <__umoddi3+0x2d>
  800d81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d88:	89 e9                	mov    %ebp,%ecx
  800d8a:	ba 20 00 00 00       	mov    $0x20,%edx
  800d8f:	29 ea                	sub    %ebp,%edx
  800d91:	d3 e0                	shl    %cl,%eax
  800d93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d97:	89 d1                	mov    %edx,%ecx
  800d99:	89 f8                	mov    %edi,%eax
  800d9b:	d3 e8                	shr    %cl,%eax
  800d9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800da1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800da5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800da9:	09 c1                	or     %eax,%ecx
  800dab:	89 d8                	mov    %ebx,%eax
  800dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800db1:	89 e9                	mov    %ebp,%ecx
  800db3:	d3 e7                	shl    %cl,%edi
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	d3 e8                	shr    %cl,%eax
  800db9:	89 e9                	mov    %ebp,%ecx
  800dbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dbf:	d3 e3                	shl    %cl,%ebx
  800dc1:	89 c7                	mov    %eax,%edi
  800dc3:	89 d1                	mov    %edx,%ecx
  800dc5:	89 f0                	mov    %esi,%eax
  800dc7:	d3 e8                	shr    %cl,%eax
  800dc9:	89 e9                	mov    %ebp,%ecx
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	d3 e6                	shl    %cl,%esi
  800dcf:	09 d8                	or     %ebx,%eax
  800dd1:	f7 74 24 08          	divl   0x8(%esp)
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	89 f3                	mov    %esi,%ebx
  800dd9:	f7 64 24 0c          	mull   0xc(%esp)
  800ddd:	89 c6                	mov    %eax,%esi
  800ddf:	89 d7                	mov    %edx,%edi
  800de1:	39 d1                	cmp    %edx,%ecx
  800de3:	72 06                	jb     800deb <__umoddi3+0x10b>
  800de5:	75 10                	jne    800df7 <__umoddi3+0x117>
  800de7:	39 c3                	cmp    %eax,%ebx
  800de9:	73 0c                	jae    800df7 <__umoddi3+0x117>
  800deb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800def:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800df3:	89 d7                	mov    %edx,%edi
  800df5:	89 c6                	mov    %eax,%esi
  800df7:	89 ca                	mov    %ecx,%edx
  800df9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dfe:	29 f3                	sub    %esi,%ebx
  800e00:	19 fa                	sbb    %edi,%edx
  800e02:	89 d0                	mov    %edx,%eax
  800e04:	d3 e0                	shl    %cl,%eax
  800e06:	89 e9                	mov    %ebp,%ecx
  800e08:	d3 eb                	shr    %cl,%ebx
  800e0a:	d3 ea                	shr    %cl,%edx
  800e0c:	09 d8                	or     %ebx,%eax
  800e0e:	83 c4 1c             	add    $0x1c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e1d:	8d 76 00             	lea    0x0(%esi),%esi
  800e20:	29 fe                	sub    %edi,%esi
  800e22:	19 c3                	sbb    %eax,%ebx
  800e24:	89 f2                	mov    %esi,%edx
  800e26:	89 d9                	mov    %ebx,%ecx
  800e28:	e9 1d ff ff ff       	jmp    800d4a <__umoddi3+0x6a>
