
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003d:	68 c0 0e 80 00       	push   $0x800ec0
  800042:	e8 ed 01 00 00       	call   800234 <cprintf>
  800047:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  80004a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004f:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800056:	00 
  800057:	75 63                	jne    8000bc <umain+0x89>
	for (i = 0; i < ARRAYSIZE; i++)
  800059:	83 c0 01             	add    $0x1,%eax
  80005c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800061:	75 ec                	jne    80004f <umain+0x1c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800068:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	83 c0 01             	add    $0x1,%eax
  800072:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800077:	75 ef                	jne    800068 <umain+0x35>
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007e:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800085:	75 47                	jne    8000ce <umain+0x9b>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	83 c0 01             	add    $0x1,%eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 ed                	jne    80007e <umain+0x4b>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  800091:	83 ec 0c             	sub    $0xc,%esp
  800094:	68 08 0f 80 00       	push   $0x800f08
  800099:	e8 96 01 00 00       	call   800234 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009e:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 67 0f 80 00       	push   $0x800f67
  8000b0:	6a 1a                	push   $0x1a
  8000b2:	68 58 0f 80 00       	push   $0x800f58
  8000b7:	e8 91 00 00 00       	call   80014d <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000bc:	50                   	push   %eax
  8000bd:	68 3b 0f 80 00       	push   $0x800f3b
  8000c2:	6a 11                	push   $0x11
  8000c4:	68 58 0f 80 00       	push   $0x800f58
  8000c9:	e8 7f 00 00 00       	call   80014d <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ce:	50                   	push   %eax
  8000cf:	68 e0 0e 80 00       	push   $0x800ee0
  8000d4:	6a 16                	push   $0x16
  8000d6:	68 58 0f 80 00       	push   $0x800f58
  8000db:	e8 6d 00 00 00       	call   80014d <_panic>

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	f3 0f 1e fb          	endbr32 
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ef:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  8000f6:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  8000f9:	e8 3c 0b 00 00       	call   800c3a <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  8000fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800103:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800106:	c1 e0 05             	shl    $0x5,%eax
  800109:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010e:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800113:	85 db                	test   %ebx,%ebx
  800115:	7e 07                	jle    80011e <libmain+0x3e>
		binaryname = argv[0];
  800117:	8b 06                	mov    (%esi),%eax
  800119:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011e:	83 ec 08             	sub    $0x8,%esp
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
  800123:	e8 0b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800128:	e8 0a 00 00 00       	call   800137 <exit>
}
  80012d:	83 c4 10             	add    $0x10,%esp
  800130:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800133:	5b                   	pop    %ebx
  800134:	5e                   	pop    %esi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800137:	f3 0f 1e fb          	endbr32 
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800141:	6a 00                	push   $0x0
  800143:	e8 ad 0a 00 00       	call   800bf5 <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	f3 0f 1e fb          	endbr32 
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800156:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800159:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015f:	e8 d6 0a 00 00       	call   800c3a <sys_getenvid>
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	ff 75 0c             	pushl  0xc(%ebp)
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	56                   	push   %esi
  80016e:	50                   	push   %eax
  80016f:	68 88 0f 80 00       	push   $0x800f88
  800174:	e8 bb 00 00 00       	call   800234 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800179:	83 c4 18             	add    $0x18,%esp
  80017c:	53                   	push   %ebx
  80017d:	ff 75 10             	pushl  0x10(%ebp)
  800180:	e8 5a 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  800185:	c7 04 24 56 0f 80 00 	movl   $0x800f56,(%esp)
  80018c:	e8 a3 00 00 00       	call   800234 <cprintf>
  800191:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800194:	cc                   	int3   
  800195:	eb fd                	jmp    800194 <_panic+0x47>

00800197 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800197:	f3 0f 1e fb          	endbr32 
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	83 ec 04             	sub    $0x4,%esp
  8001a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a5:	8b 13                	mov    (%ebx),%edx
  8001a7:	8d 42 01             	lea    0x1(%edx),%eax
  8001aa:	89 03                	mov    %eax,(%ebx)
  8001ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b8:	74 09                	je     8001c3 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c3:	83 ec 08             	sub    $0x8,%esp
  8001c6:	68 ff 00 00 00       	push   $0xff
  8001cb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ce:	50                   	push   %eax
  8001cf:	e8 dc 09 00 00       	call   800bb0 <sys_cputs>
		b->idx = 0;
  8001d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001da:	83 c4 10             	add    $0x10,%esp
  8001dd:	eb db                	jmp    8001ba <putch+0x23>

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	f3 0f 1e fb          	endbr32 
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	ff 75 0c             	pushl  0xc(%ebp)
  800203:	ff 75 08             	pushl  0x8(%ebp)
  800206:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	68 97 01 80 00       	push   $0x800197
  800212:	e8 20 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800217:	83 c4 08             	add    $0x8,%esp
  80021a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	50                   	push   %eax
  800227:	e8 84 09 00 00       	call   800bb0 <sys_cputs>

	return b.cnt;
}
  80022c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800234:	f3 0f 1e fb          	endbr32 
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800241:	50                   	push   %eax
  800242:	ff 75 08             	pushl  0x8(%ebp)
  800245:	e8 95 ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 1c             	sub    $0x1c,%esp
  800255:	89 c7                	mov    %eax,%edi
  800257:	89 d6                	mov    %edx,%esi
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025f:	89 d1                	mov    %edx,%ecx
  800261:	89 c2                	mov    %eax,%edx
  800263:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800266:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800269:	8b 45 10             	mov    0x10(%ebp),%eax
  80026c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800272:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800279:	39 c2                	cmp    %eax,%edx
  80027b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80027e:	72 3e                	jb     8002be <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800280:	83 ec 0c             	sub    $0xc,%esp
  800283:	ff 75 18             	pushl  0x18(%ebp)
  800286:	83 eb 01             	sub    $0x1,%ebx
  800289:	53                   	push   %ebx
  80028a:	50                   	push   %eax
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800291:	ff 75 e0             	pushl  -0x20(%ebp)
  800294:	ff 75 dc             	pushl  -0x24(%ebp)
  800297:	ff 75 d8             	pushl  -0x28(%ebp)
  80029a:	e8 c1 09 00 00       	call   800c60 <__udivdi3>
  80029f:	83 c4 18             	add    $0x18,%esp
  8002a2:	52                   	push   %edx
  8002a3:	50                   	push   %eax
  8002a4:	89 f2                	mov    %esi,%edx
  8002a6:	89 f8                	mov    %edi,%eax
  8002a8:	e8 9f ff ff ff       	call   80024c <printnum>
  8002ad:	83 c4 20             	add    $0x20,%esp
  8002b0:	eb 13                	jmp    8002c5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	56                   	push   %esi
  8002b6:	ff 75 18             	pushl  0x18(%ebp)
  8002b9:	ff d7                	call   *%edi
  8002bb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002be:	83 eb 01             	sub    $0x1,%ebx
  8002c1:	85 db                	test   %ebx,%ebx
  8002c3:	7f ed                	jg     8002b2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	56                   	push   %esi
  8002c9:	83 ec 04             	sub    $0x4,%esp
  8002cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d8:	e8 93 0a 00 00       	call   800d70 <__umoddi3>
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	0f be 80 ab 0f 80 00 	movsbl 0x800fab(%eax),%eax
  8002e7:	50                   	push   %eax
  8002e8:	ff d7                	call   *%edi
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f5:	f3 0f 1e fb          	endbr32 
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800303:	8b 10                	mov    (%eax),%edx
  800305:	3b 50 04             	cmp    0x4(%eax),%edx
  800308:	73 0a                	jae    800314 <sprintputch+0x1f>
		*b->buf++ = ch;
  80030a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 45 08             	mov    0x8(%ebp),%eax
  800312:	88 02                	mov    %al,(%edx)
}
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <printfmt>:
{
  800316:	f3 0f 1e fb          	endbr32 
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
{
  800337:	f3 0f 1e fb          	endbr32 
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 3c             	sub    $0x3c,%esp
  800344:	8b 75 08             	mov    0x8(%ebp),%esi
  800347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034d:	e9 8e 03 00 00       	jmp    8006e0 <vprintfmt+0x3a9>
		padc = ' ';
  800352:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800356:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80035d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800364:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8d 47 01             	lea    0x1(%edi),%eax
  800373:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800376:	0f b6 17             	movzbl (%edi),%edx
  800379:	8d 42 dd             	lea    -0x23(%edx),%eax
  80037c:	3c 55                	cmp    $0x55,%al
  80037e:	0f 87 df 03 00 00    	ja     800763 <vprintfmt+0x42c>
  800384:	0f b6 c0             	movzbl %al,%eax
  800387:	3e ff 24 85 38 10 80 	notrack jmp *0x801038(,%eax,4)
  80038e:	00 
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800392:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800396:	eb d8                	jmp    800370 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80039f:	eb cf                	jmp    800370 <vprintfmt+0x39>
  8003a1:	0f b6 d2             	movzbl %dl,%edx
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003af:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003bc:	83 f9 09             	cmp    $0x9,%ecx
  8003bf:	77 55                	ja     800416 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003c1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c4:	eb e9                	jmp    8003af <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8b 00                	mov    (%eax),%eax
  8003cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 40 04             	lea    0x4(%eax),%eax
  8003d4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003de:	79 90                	jns    800370 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ed:	eb 81                	jmp    800370 <vprintfmt+0x39>
  8003ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f9:	0f 49 d0             	cmovns %eax,%edx
  8003fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800402:	e9 69 ff ff ff       	jmp    800370 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80040a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800411:	e9 5a ff ff ff       	jmp    800370 <vprintfmt+0x39>
  800416:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800419:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041c:	eb bc                	jmp    8003da <vprintfmt+0xa3>
			lflag++;
  80041e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800424:	e9 47 ff ff ff       	jmp    800370 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 78 04             	lea    0x4(%eax),%edi
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	53                   	push   %ebx
  800433:	ff 30                	pushl  (%eax)
  800435:	ff d6                	call   *%esi
			break;
  800437:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80043a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80043d:	e9 9b 02 00 00       	jmp    8006dd <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 78 04             	lea    0x4(%eax),%edi
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	99                   	cltd   
  80044b:	31 d0                	xor    %edx,%eax
  80044d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044f:	83 f8 06             	cmp    $0x6,%eax
  800452:	7f 23                	jg     800477 <vprintfmt+0x140>
  800454:	8b 14 85 90 11 80 00 	mov    0x801190(,%eax,4),%edx
  80045b:	85 d2                	test   %edx,%edx
  80045d:	74 18                	je     800477 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80045f:	52                   	push   %edx
  800460:	68 cc 0f 80 00       	push   $0x800fcc
  800465:	53                   	push   %ebx
  800466:	56                   	push   %esi
  800467:	e8 aa fe ff ff       	call   800316 <printfmt>
  80046c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800472:	e9 66 02 00 00       	jmp    8006dd <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800477:	50                   	push   %eax
  800478:	68 c3 0f 80 00       	push   $0x800fc3
  80047d:	53                   	push   %ebx
  80047e:	56                   	push   %esi
  80047f:	e8 92 fe ff ff       	call   800316 <printfmt>
  800484:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800487:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80048a:	e9 4e 02 00 00       	jmp    8006dd <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	83 c0 04             	add    $0x4,%eax
  800495:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80049d:	85 d2                	test   %edx,%edx
  80049f:	b8 bc 0f 80 00       	mov    $0x800fbc,%eax
  8004a4:	0f 45 c2             	cmovne %edx,%eax
  8004a7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ae:	7e 06                	jle    8004b6 <vprintfmt+0x17f>
  8004b0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b4:	75 0d                	jne    8004c3 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b9:	89 c7                	mov    %eax,%edi
  8004bb:	03 45 e0             	add    -0x20(%ebp),%eax
  8004be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c1:	eb 55                	jmp    800518 <vprintfmt+0x1e1>
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c9:	ff 75 cc             	pushl  -0x34(%ebp)
  8004cc:	e8 46 03 00 00       	call   800817 <strnlen>
  8004d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d4:	29 c2                	sub    %eax,%edx
  8004d6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004de:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	7e 11                	jle    8004fa <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	53                   	push   %ebx
  8004ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f2:	83 ef 01             	sub    $0x1,%edi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb eb                	jmp    8004e5 <vprintfmt+0x1ae>
  8004fa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004fd:	85 d2                	test   %edx,%edx
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800504:	0f 49 c2             	cmovns %edx,%eax
  800507:	29 c2                	sub    %eax,%edx
  800509:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050c:	eb a8                	jmp    8004b6 <vprintfmt+0x17f>
					putch(ch, putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	52                   	push   %edx
  800513:	ff d6                	call   *%esi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051d:	83 c7 01             	add    $0x1,%edi
  800520:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800524:	0f be d0             	movsbl %al,%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	74 4b                	je     800576 <vprintfmt+0x23f>
  80052b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052f:	78 06                	js     800537 <vprintfmt+0x200>
  800531:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800535:	78 1e                	js     800555 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053b:	74 d1                	je     80050e <vprintfmt+0x1d7>
  80053d:	0f be c0             	movsbl %al,%eax
  800540:	83 e8 20             	sub    $0x20,%eax
  800543:	83 f8 5e             	cmp    $0x5e,%eax
  800546:	76 c6                	jbe    80050e <vprintfmt+0x1d7>
					putch('?', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 3f                	push   $0x3f
  80054e:	ff d6                	call   *%esi
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	eb c3                	jmp    800518 <vprintfmt+0x1e1>
  800555:	89 cf                	mov    %ecx,%edi
  800557:	eb 0e                	jmp    800567 <vprintfmt+0x230>
				putch(' ', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 20                	push   $0x20
  80055f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800561:	83 ef 01             	sub    $0x1,%edi
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	85 ff                	test   %edi,%edi
  800569:	7f ee                	jg     800559 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80056b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	e9 67 01 00 00       	jmp    8006dd <vprintfmt+0x3a6>
  800576:	89 cf                	mov    %ecx,%edi
  800578:	eb ed                	jmp    800567 <vprintfmt+0x230>
	if (lflag >= 2)
  80057a:	83 f9 01             	cmp    $0x1,%ecx
  80057d:	7f 1b                	jg     80059a <vprintfmt+0x263>
	else if (lflag)
  80057f:	85 c9                	test   %ecx,%ecx
  800581:	74 63                	je     8005e6 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058b:	99                   	cltd   
  80058c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 40 04             	lea    0x4(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
  800598:	eb 17                	jmp    8005b1 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 50 04             	mov    0x4(%eax),%edx
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 40 08             	lea    0x8(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	0f 89 ff 00 00 00    	jns    8006c3 <vprintfmt+0x38c>
				putch('-', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 2d                	push   $0x2d
  8005ca:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d2:	f7 da                	neg    %edx
  8005d4:	83 d1 00             	adc    $0x0,%ecx
  8005d7:	f7 d9                	neg    %ecx
  8005d9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e1:	e9 dd 00 00 00       	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	99                   	cltd   
  8005ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fb:	eb b4                	jmp    8005b1 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005fd:	83 f9 01             	cmp    $0x1,%ecx
  800600:	7f 1e                	jg     800620 <vprintfmt+0x2e9>
	else if (lflag)
  800602:	85 c9                	test   %ecx,%ecx
  800604:	74 32                	je     800638 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8b 10                	mov    (%eax),%edx
  80060b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800610:	8d 40 04             	lea    0x4(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80061b:	e9 a3 00 00 00       	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	8b 48 04             	mov    0x4(%eax),%ecx
  800628:	8d 40 08             	lea    0x8(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800633:	e9 8b 00 00 00       	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800648:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80064d:	eb 74                	jmp    8006c3 <vprintfmt+0x38c>
	if (lflag >= 2)
  80064f:	83 f9 01             	cmp    $0x1,%ecx
  800652:	7f 1b                	jg     80066f <vprintfmt+0x338>
	else if (lflag)
  800654:	85 c9                	test   %ecx,%ecx
  800656:	74 2c                	je     800684 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800668:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80066d:	eb 54                	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80067d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800682:	eb 3f                	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800694:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800699:	eb 28                	jmp    8006c3 <vprintfmt+0x38c>
			putch('0', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 30                	push   $0x30
  8006a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 78                	push   $0x78
  8006a9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006ca:	57                   	push   %edi
  8006cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ce:	50                   	push   %eax
  8006cf:	51                   	push   %ecx
  8006d0:	52                   	push   %edx
  8006d1:	89 da                	mov    %ebx,%edx
  8006d3:	89 f0                	mov    %esi,%eax
  8006d5:	e8 72 fb ff ff       	call   80024c <printnum>
			break;
  8006da:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e0:	83 c7 01             	add    $0x1,%edi
  8006e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e7:	83 f8 25             	cmp    $0x25,%eax
  8006ea:	0f 84 62 fc ff ff    	je     800352 <vprintfmt+0x1b>
			if (ch == '\0')
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	0f 84 8b 00 00 00    	je     800783 <vprintfmt+0x44c>
			putch(ch, putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	50                   	push   %eax
  8006fd:	ff d6                	call   *%esi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	eb dc                	jmp    8006e0 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800704:	83 f9 01             	cmp    $0x1,%ecx
  800707:	7f 1b                	jg     800724 <vprintfmt+0x3ed>
	else if (lflag)
  800709:	85 c9                	test   %ecx,%ecx
  80070b:	74 2c                	je     800739 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800722:	eb 9f                	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8b 10                	mov    (%eax),%edx
  800729:	8b 48 04             	mov    0x4(%eax),%ecx
  80072c:	8d 40 08             	lea    0x8(%eax),%eax
  80072f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800737:	eb 8a                	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800743:	8d 40 04             	lea    0x4(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800749:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80074e:	e9 70 ff ff ff       	jmp    8006c3 <vprintfmt+0x38c>
			putch(ch, putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	53                   	push   %ebx
  800757:	6a 25                	push   $0x25
  800759:	ff d6                	call   *%esi
			break;
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	e9 7a ff ff ff       	jmp    8006dd <vprintfmt+0x3a6>
			putch('%', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 25                	push   $0x25
  800769:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	89 f8                	mov    %edi,%eax
  800770:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800774:	74 05                	je     80077b <vprintfmt+0x444>
  800776:	83 e8 01             	sub    $0x1,%eax
  800779:	eb f5                	jmp    800770 <vprintfmt+0x439>
  80077b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80077e:	e9 5a ff ff ff       	jmp    8006dd <vprintfmt+0x3a6>
}
  800783:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5f                   	pop    %edi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078b:	f3 0f 1e fb          	endbr32 
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	83 ec 18             	sub    $0x18,%esp
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ac:	85 c0                	test   %eax,%eax
  8007ae:	74 26                	je     8007d6 <vsnprintf+0x4b>
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	7e 22                	jle    8007d6 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b4:	ff 75 14             	pushl  0x14(%ebp)
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	68 f5 02 80 00       	push   $0x8002f5
  8007c3:	e8 6f fb ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d1:	83 c4 10             	add    $0x10,%esp
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    
		return -E_INVAL;
  8007d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007db:	eb f7                	jmp    8007d4 <vsnprintf+0x49>

008007dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007dd:	f3 0f 1e fb          	endbr32 
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ea:	50                   	push   %eax
  8007eb:	ff 75 10             	pushl  0x10(%ebp)
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	ff 75 08             	pushl  0x8(%ebp)
  8007f4:	e8 92 ff ff ff       	call   80078b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fb:	f3 0f 1e fb          	endbr32 
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080e:	74 05                	je     800815 <strlen+0x1a>
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	eb f5                	jmp    80080a <strlen+0xf>
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800817:	f3 0f 1e fb          	endbr32 
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	39 d0                	cmp    %edx,%eax
  80082b:	74 0d                	je     80083a <strnlen+0x23>
  80082d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800831:	74 05                	je     800838 <strnlen+0x21>
		n++;
  800833:	83 c0 01             	add    $0x1,%eax
  800836:	eb f1                	jmp    800829 <strnlen+0x12>
  800838:	89 c2                	mov    %eax,%edx
	return n;
}
  80083a:	89 d0                	mov    %edx,%eax
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083e:	f3 0f 1e fb          	endbr32 
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
  800851:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800855:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80085f:	89 c8                	mov    %ecx,%eax
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800864:	f3 0f 1e fb          	endbr32 
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	83 ec 10             	sub    $0x10,%esp
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800872:	53                   	push   %ebx
  800873:	e8 83 ff ff ff       	call   8007fb <strlen>
  800878:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80087b:	ff 75 0c             	pushl  0xc(%ebp)
  80087e:	01 d8                	add    %ebx,%eax
  800880:	50                   	push   %eax
  800881:	e8 b8 ff ff ff       	call   80083e <strcpy>
	return dst;
}
  800886:	89 d8                	mov    %ebx,%eax
  800888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	8b 75 08             	mov    0x8(%ebp),%esi
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 f3                	mov    %esi,%ebx
  80089e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a1:	89 f0                	mov    %esi,%eax
  8008a3:	39 d8                	cmp    %ebx,%eax
  8008a5:	74 11                	je     8008b8 <strncpy+0x2b>
		*dst++ = *src;
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	0f b6 0a             	movzbl (%edx),%ecx
  8008ad:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b0:	80 f9 01             	cmp    $0x1,%cl
  8008b3:	83 da ff             	sbb    $0xffffffff,%edx
  8008b6:	eb eb                	jmp    8008a3 <strncpy+0x16>
	}
	return ret;
}
  8008b8:	89 f0                	mov    %esi,%eax
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008be:	f3 0f 1e fb          	endbr32 
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	74 21                	je     8008f7 <strlcpy+0x39>
  8008d6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008da:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008dc:	39 c2                	cmp    %eax,%edx
  8008de:	74 14                	je     8008f4 <strlcpy+0x36>
  8008e0:	0f b6 19             	movzbl (%ecx),%ebx
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	74 0b                	je     8008f2 <strlcpy+0x34>
			*dst++ = *src++;
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f0:	eb ea                	jmp    8008dc <strlcpy+0x1e>
  8008f2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f7:	29 f0                	sub    %esi,%eax
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fd:	f3 0f 1e fb          	endbr32 
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090a:	0f b6 01             	movzbl (%ecx),%eax
  80090d:	84 c0                	test   %al,%al
  80090f:	74 0c                	je     80091d <strcmp+0x20>
  800911:	3a 02                	cmp    (%edx),%al
  800913:	75 08                	jne    80091d <strcmp+0x20>
		p++, q++;
  800915:	83 c1 01             	add    $0x1,%ecx
  800918:	83 c2 01             	add    $0x1,%edx
  80091b:	eb ed                	jmp    80090a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091d:	0f b6 c0             	movzbl %al,%eax
  800920:	0f b6 12             	movzbl (%edx),%edx
  800923:	29 d0                	sub    %edx,%eax
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800927:	f3 0f 1e fb          	endbr32 
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  800935:	89 c3                	mov    %eax,%ebx
  800937:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80093a:	eb 06                	jmp    800942 <strncmp+0x1b>
		n--, p++, q++;
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800942:	39 d8                	cmp    %ebx,%eax
  800944:	74 16                	je     80095c <strncmp+0x35>
  800946:	0f b6 08             	movzbl (%eax),%ecx
  800949:	84 c9                	test   %cl,%cl
  80094b:	74 04                	je     800951 <strncmp+0x2a>
  80094d:	3a 0a                	cmp    (%edx),%cl
  80094f:	74 eb                	je     80093c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 00             	movzbl (%eax),%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
}
  800959:	5b                   	pop    %ebx
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    
		return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
  800961:	eb f6                	jmp    800959 <strncmp+0x32>

00800963 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800963:	f3 0f 1e fb          	endbr32 
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800971:	0f b6 10             	movzbl (%eax),%edx
  800974:	84 d2                	test   %dl,%dl
  800976:	74 09                	je     800981 <strchr+0x1e>
		if (*s == c)
  800978:	38 ca                	cmp    %cl,%dl
  80097a:	74 0a                	je     800986 <strchr+0x23>
	for (; *s; s++)
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	eb f0                	jmp    800971 <strchr+0xe>
			return (char *) s;
	return 0;
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800988:	f3 0f 1e fb          	endbr32 
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800996:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800999:	38 ca                	cmp    %cl,%dl
  80099b:	74 09                	je     8009a6 <strfind+0x1e>
  80099d:	84 d2                	test   %dl,%dl
  80099f:	74 05                	je     8009a6 <strfind+0x1e>
	for (; *s; s++)
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	eb f0                	jmp    800996 <strfind+0xe>
			break;
	return (char *) s;
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a8:	f3 0f 1e fb          	endbr32 
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	74 31                	je     8009ed <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bc:	89 f8                	mov    %edi,%eax
  8009be:	09 c8                	or     %ecx,%eax
  8009c0:	a8 03                	test   $0x3,%al
  8009c2:	75 23                	jne    8009e7 <memset+0x3f>
		c &= 0xFF;
  8009c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c8:	89 d3                	mov    %edx,%ebx
  8009ca:	c1 e3 08             	shl    $0x8,%ebx
  8009cd:	89 d0                	mov    %edx,%eax
  8009cf:	c1 e0 18             	shl    $0x18,%eax
  8009d2:	89 d6                	mov    %edx,%esi
  8009d4:	c1 e6 10             	shl    $0x10,%esi
  8009d7:	09 f0                	or     %esi,%eax
  8009d9:	09 c2                	or     %eax,%edx
  8009db:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009dd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e0:	89 d0                	mov    %edx,%eax
  8009e2:	fc                   	cld    
  8009e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e5:	eb 06                	jmp    8009ed <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	fc                   	cld    
  8009eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f4:	f3 0f 1e fb          	endbr32 
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a06:	39 c6                	cmp    %eax,%esi
  800a08:	73 32                	jae    800a3c <memmove+0x48>
  800a0a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0d:	39 c2                	cmp    %eax,%edx
  800a0f:	76 2b                	jbe    800a3c <memmove+0x48>
		s += n;
		d += n;
  800a11:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	89 fe                	mov    %edi,%esi
  800a16:	09 ce                	or     %ecx,%esi
  800a18:	09 d6                	or     %edx,%esi
  800a1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a20:	75 0e                	jne    800a30 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a22:	83 ef 04             	sub    $0x4,%edi
  800a25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a28:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a2b:	fd                   	std    
  800a2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2e:	eb 09                	jmp    800a39 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a30:	83 ef 01             	sub    $0x1,%edi
  800a33:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a36:	fd                   	std    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a39:	fc                   	cld    
  800a3a:	eb 1a                	jmp    800a56 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3c:	89 c2                	mov    %eax,%edx
  800a3e:	09 ca                	or     %ecx,%edx
  800a40:	09 f2                	or     %esi,%edx
  800a42:	f6 c2 03             	test   $0x3,%dl
  800a45:	75 0a                	jne    800a51 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a47:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	fc                   	cld    
  800a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4f:	eb 05                	jmp    800a56 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5a:	f3 0f 1e fb          	endbr32 
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a64:	ff 75 10             	pushl  0x10(%ebp)
  800a67:	ff 75 0c             	pushl  0xc(%ebp)
  800a6a:	ff 75 08             	pushl  0x8(%ebp)
  800a6d:	e8 82 ff ff ff       	call   8009f4 <memmove>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a74:	f3 0f 1e fb          	endbr32 
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	89 c6                	mov    %eax,%esi
  800a85:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a88:	39 f0                	cmp    %esi,%eax
  800a8a:	74 1c                	je     800aa8 <memcmp+0x34>
		if (*s1 != *s2)
  800a8c:	0f b6 08             	movzbl (%eax),%ecx
  800a8f:	0f b6 1a             	movzbl (%edx),%ebx
  800a92:	38 d9                	cmp    %bl,%cl
  800a94:	75 08                	jne    800a9e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	83 c2 01             	add    $0x1,%edx
  800a9c:	eb ea                	jmp    800a88 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a9e:	0f b6 c1             	movzbl %cl,%eax
  800aa1:	0f b6 db             	movzbl %bl,%ebx
  800aa4:	29 d8                	sub    %ebx,%eax
  800aa6:	eb 05                	jmp    800aad <memcmp+0x39>
	}

	return 0;
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab1:	f3 0f 1e fb          	endbr32 
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac3:	39 d0                	cmp    %edx,%eax
  800ac5:	73 09                	jae    800ad0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac7:	38 08                	cmp    %cl,(%eax)
  800ac9:	74 05                	je     800ad0 <memfind+0x1f>
	for (; s < ends; s++)
  800acb:	83 c0 01             	add    $0x1,%eax
  800ace:	eb f3                	jmp    800ac3 <memfind+0x12>
			break;
	return (void *) s;
}
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad2:	f3 0f 1e fb          	endbr32 
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae2:	eb 03                	jmp    800ae7 <strtol+0x15>
		s++;
  800ae4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ae7:	0f b6 01             	movzbl (%ecx),%eax
  800aea:	3c 20                	cmp    $0x20,%al
  800aec:	74 f6                	je     800ae4 <strtol+0x12>
  800aee:	3c 09                	cmp    $0x9,%al
  800af0:	74 f2                	je     800ae4 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800af2:	3c 2b                	cmp    $0x2b,%al
  800af4:	74 2a                	je     800b20 <strtol+0x4e>
	int neg = 0;
  800af6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800afb:	3c 2d                	cmp    $0x2d,%al
  800afd:	74 2b                	je     800b2a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b05:	75 0f                	jne    800b16 <strtol+0x44>
  800b07:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0a:	74 28                	je     800b34 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b0c:	85 db                	test   %ebx,%ebx
  800b0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b13:	0f 44 d8             	cmove  %eax,%ebx
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b1e:	eb 46                	jmp    800b66 <strtol+0x94>
		s++;
  800b20:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
  800b28:	eb d5                	jmp    800aff <strtol+0x2d>
		s++, neg = 1;
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b32:	eb cb                	jmp    800aff <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b34:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b38:	74 0e                	je     800b48 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b3a:	85 db                	test   %ebx,%ebx
  800b3c:	75 d8                	jne    800b16 <strtol+0x44>
		s++, base = 8;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b46:	eb ce                	jmp    800b16 <strtol+0x44>
		s += 2, base = 16;
  800b48:	83 c1 02             	add    $0x2,%ecx
  800b4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b50:	eb c4                	jmp    800b16 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b52:	0f be d2             	movsbl %dl,%edx
  800b55:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5b:	7d 3a                	jge    800b97 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b5d:	83 c1 01             	add    $0x1,%ecx
  800b60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b64:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b66:	0f b6 11             	movzbl (%ecx),%edx
  800b69:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6c:	89 f3                	mov    %esi,%ebx
  800b6e:	80 fb 09             	cmp    $0x9,%bl
  800b71:	76 df                	jbe    800b52 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b76:	89 f3                	mov    %esi,%ebx
  800b78:	80 fb 19             	cmp    $0x19,%bl
  800b7b:	77 08                	ja     800b85 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b7d:	0f be d2             	movsbl %dl,%edx
  800b80:	83 ea 57             	sub    $0x57,%edx
  800b83:	eb d3                	jmp    800b58 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b85:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b88:	89 f3                	mov    %esi,%ebx
  800b8a:	80 fb 19             	cmp    $0x19,%bl
  800b8d:	77 08                	ja     800b97 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b8f:	0f be d2             	movsbl %dl,%edx
  800b92:	83 ea 37             	sub    $0x37,%edx
  800b95:	eb c1                	jmp    800b58 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9b:	74 05                	je     800ba2 <strtol+0xd0>
		*endptr = (char *) s;
  800b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ba2:	89 c2                	mov    %eax,%edx
  800ba4:	f7 da                	neg    %edx
  800ba6:	85 ff                	test   %edi,%edi
  800ba8:	0f 45 c2             	cmovne %edx,%eax
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb0:	f3 0f 1e fb          	endbr32 
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	89 c3                	mov    %eax,%ebx
  800bc7:	89 c7                	mov    %eax,%edi
  800bc9:	89 c6                	mov    %eax,%esi
  800bcb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd2:	f3 0f 1e fb          	endbr32 
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf5:	f3 0f 1e fb          	endbr32 
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0f:	89 cb                	mov    %ecx,%ebx
  800c11:	89 cf                	mov    %ecx,%edi
  800c13:	89 ce                	mov    %ecx,%esi
  800c15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c17:	85 c0                	test   %eax,%eax
  800c19:	7f 08                	jg     800c23 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 03                	push   $0x3
  800c29:	68 ac 11 80 00       	push   $0x8011ac
  800c2e:	6a 23                	push   $0x23
  800c30:	68 c9 11 80 00       	push   $0x8011c9
  800c35:	e8 13 f5 ff ff       	call   80014d <_panic>

00800c3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3a:	f3 0f 1e fb          	endbr32 
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c44:	ba 00 00 00 00       	mov    $0x0,%edx
  800c49:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4e:	89 d1                	mov    %edx,%ecx
  800c50:	89 d3                	mov    %edx,%ebx
  800c52:	89 d7                	mov    %edx,%edi
  800c54:	89 d6                	mov    %edx,%esi
  800c56:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    
  800c5d:	66 90                	xchg   %ax,%ax
  800c5f:	90                   	nop

00800c60 <__udivdi3>:
  800c60:	f3 0f 1e fb          	endbr32 
  800c64:	55                   	push   %ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 1c             	sub    $0x1c,%esp
  800c6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c73:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c7b:	85 d2                	test   %edx,%edx
  800c7d:	75 19                	jne    800c98 <__udivdi3+0x38>
  800c7f:	39 f3                	cmp    %esi,%ebx
  800c81:	76 4d                	jbe    800cd0 <__udivdi3+0x70>
  800c83:	31 ff                	xor    %edi,%edi
  800c85:	89 e8                	mov    %ebp,%eax
  800c87:	89 f2                	mov    %esi,%edx
  800c89:	f7 f3                	div    %ebx
  800c8b:	89 fa                	mov    %edi,%edx
  800c8d:	83 c4 1c             	add    $0x1c,%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    
  800c95:	8d 76 00             	lea    0x0(%esi),%esi
  800c98:	39 f2                	cmp    %esi,%edx
  800c9a:	76 14                	jbe    800cb0 <__udivdi3+0x50>
  800c9c:	31 ff                	xor    %edi,%edi
  800c9e:	31 c0                	xor    %eax,%eax
  800ca0:	89 fa                	mov    %edi,%edx
  800ca2:	83 c4 1c             	add    $0x1c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
  800caa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb0:	0f bd fa             	bsr    %edx,%edi
  800cb3:	83 f7 1f             	xor    $0x1f,%edi
  800cb6:	75 48                	jne    800d00 <__udivdi3+0xa0>
  800cb8:	39 f2                	cmp    %esi,%edx
  800cba:	72 06                	jb     800cc2 <__udivdi3+0x62>
  800cbc:	31 c0                	xor    %eax,%eax
  800cbe:	39 eb                	cmp    %ebp,%ebx
  800cc0:	77 de                	ja     800ca0 <__udivdi3+0x40>
  800cc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc7:	eb d7                	jmp    800ca0 <__udivdi3+0x40>
  800cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	89 d9                	mov    %ebx,%ecx
  800cd2:	85 db                	test   %ebx,%ebx
  800cd4:	75 0b                	jne    800ce1 <__udivdi3+0x81>
  800cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdb:	31 d2                	xor    %edx,%edx
  800cdd:	f7 f3                	div    %ebx
  800cdf:	89 c1                	mov    %eax,%ecx
  800ce1:	31 d2                	xor    %edx,%edx
  800ce3:	89 f0                	mov    %esi,%eax
  800ce5:	f7 f1                	div    %ecx
  800ce7:	89 c6                	mov    %eax,%esi
  800ce9:	89 e8                	mov    %ebp,%eax
  800ceb:	89 f7                	mov    %esi,%edi
  800ced:	f7 f1                	div    %ecx
  800cef:	89 fa                	mov    %edi,%edx
  800cf1:	83 c4 1c             	add    $0x1c,%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
  800cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d00:	89 f9                	mov    %edi,%ecx
  800d02:	b8 20 00 00 00       	mov    $0x20,%eax
  800d07:	29 f8                	sub    %edi,%eax
  800d09:	d3 e2                	shl    %cl,%edx
  800d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d0f:	89 c1                	mov    %eax,%ecx
  800d11:	89 da                	mov    %ebx,%edx
  800d13:	d3 ea                	shr    %cl,%edx
  800d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d19:	09 d1                	or     %edx,%ecx
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d21:	89 f9                	mov    %edi,%ecx
  800d23:	d3 e3                	shl    %cl,%ebx
  800d25:	89 c1                	mov    %eax,%ecx
  800d27:	d3 ea                	shr    %cl,%edx
  800d29:	89 f9                	mov    %edi,%ecx
  800d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d2f:	89 eb                	mov    %ebp,%ebx
  800d31:	d3 e6                	shl    %cl,%esi
  800d33:	89 c1                	mov    %eax,%ecx
  800d35:	d3 eb                	shr    %cl,%ebx
  800d37:	09 de                	or     %ebx,%esi
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	f7 74 24 08          	divl   0x8(%esp)
  800d3f:	89 d6                	mov    %edx,%esi
  800d41:	89 c3                	mov    %eax,%ebx
  800d43:	f7 64 24 0c          	mull   0xc(%esp)
  800d47:	39 d6                	cmp    %edx,%esi
  800d49:	72 15                	jb     800d60 <__udivdi3+0x100>
  800d4b:	89 f9                	mov    %edi,%ecx
  800d4d:	d3 e5                	shl    %cl,%ebp
  800d4f:	39 c5                	cmp    %eax,%ebp
  800d51:	73 04                	jae    800d57 <__udivdi3+0xf7>
  800d53:	39 d6                	cmp    %edx,%esi
  800d55:	74 09                	je     800d60 <__udivdi3+0x100>
  800d57:	89 d8                	mov    %ebx,%eax
  800d59:	31 ff                	xor    %edi,%edi
  800d5b:	e9 40 ff ff ff       	jmp    800ca0 <__udivdi3+0x40>
  800d60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d63:	31 ff                	xor    %edi,%edi
  800d65:	e9 36 ff ff ff       	jmp    800ca0 <__udivdi3+0x40>
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	66 90                	xchg   %ax,%ax
  800d6e:	66 90                	xchg   %ax,%ax

00800d70 <__umoddi3>:
  800d70:	f3 0f 1e fb          	endbr32 
  800d74:	55                   	push   %ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 1c             	sub    $0x1c,%esp
  800d7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	75 19                	jne    800da8 <__umoddi3+0x38>
  800d8f:	39 df                	cmp    %ebx,%edi
  800d91:	76 5d                	jbe    800df0 <__umoddi3+0x80>
  800d93:	89 f0                	mov    %esi,%eax
  800d95:	89 da                	mov    %ebx,%edx
  800d97:	f7 f7                	div    %edi
  800d99:	89 d0                	mov    %edx,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	83 c4 1c             	add    $0x1c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
  800da5:	8d 76 00             	lea    0x0(%esi),%esi
  800da8:	89 f2                	mov    %esi,%edx
  800daa:	39 d8                	cmp    %ebx,%eax
  800dac:	76 12                	jbe    800dc0 <__umoddi3+0x50>
  800dae:	89 f0                	mov    %esi,%eax
  800db0:	89 da                	mov    %ebx,%edx
  800db2:	83 c4 1c             	add    $0x1c,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    
  800dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc0:	0f bd e8             	bsr    %eax,%ebp
  800dc3:	83 f5 1f             	xor    $0x1f,%ebp
  800dc6:	75 50                	jne    800e18 <__umoddi3+0xa8>
  800dc8:	39 d8                	cmp    %ebx,%eax
  800dca:	0f 82 e0 00 00 00    	jb     800eb0 <__umoddi3+0x140>
  800dd0:	89 d9                	mov    %ebx,%ecx
  800dd2:	39 f7                	cmp    %esi,%edi
  800dd4:	0f 86 d6 00 00 00    	jbe    800eb0 <__umoddi3+0x140>
  800dda:	89 d0                	mov    %edx,%eax
  800ddc:	89 ca                	mov    %ecx,%edx
  800dde:	83 c4 1c             	add    $0x1c,%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    
  800de6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ded:	8d 76 00             	lea    0x0(%esi),%esi
  800df0:	89 fd                	mov    %edi,%ebp
  800df2:	85 ff                	test   %edi,%edi
  800df4:	75 0b                	jne    800e01 <__umoddi3+0x91>
  800df6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfb:	31 d2                	xor    %edx,%edx
  800dfd:	f7 f7                	div    %edi
  800dff:	89 c5                	mov    %eax,%ebp
  800e01:	89 d8                	mov    %ebx,%eax
  800e03:	31 d2                	xor    %edx,%edx
  800e05:	f7 f5                	div    %ebp
  800e07:	89 f0                	mov    %esi,%eax
  800e09:	f7 f5                	div    %ebp
  800e0b:	89 d0                	mov    %edx,%eax
  800e0d:	31 d2                	xor    %edx,%edx
  800e0f:	eb 8c                	jmp    800d9d <__umoddi3+0x2d>
  800e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e18:	89 e9                	mov    %ebp,%ecx
  800e1a:	ba 20 00 00 00       	mov    $0x20,%edx
  800e1f:	29 ea                	sub    %ebp,%edx
  800e21:	d3 e0                	shl    %cl,%eax
  800e23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e27:	89 d1                	mov    %edx,%ecx
  800e29:	89 f8                	mov    %edi,%eax
  800e2b:	d3 e8                	shr    %cl,%eax
  800e2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e31:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e35:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e39:	09 c1                	or     %eax,%ecx
  800e3b:	89 d8                	mov    %ebx,%eax
  800e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e41:	89 e9                	mov    %ebp,%ecx
  800e43:	d3 e7                	shl    %cl,%edi
  800e45:	89 d1                	mov    %edx,%ecx
  800e47:	d3 e8                	shr    %cl,%eax
  800e49:	89 e9                	mov    %ebp,%ecx
  800e4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e4f:	d3 e3                	shl    %cl,%ebx
  800e51:	89 c7                	mov    %eax,%edi
  800e53:	89 d1                	mov    %edx,%ecx
  800e55:	89 f0                	mov    %esi,%eax
  800e57:	d3 e8                	shr    %cl,%eax
  800e59:	89 e9                	mov    %ebp,%ecx
  800e5b:	89 fa                	mov    %edi,%edx
  800e5d:	d3 e6                	shl    %cl,%esi
  800e5f:	09 d8                	or     %ebx,%eax
  800e61:	f7 74 24 08          	divl   0x8(%esp)
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	89 f3                	mov    %esi,%ebx
  800e69:	f7 64 24 0c          	mull   0xc(%esp)
  800e6d:	89 c6                	mov    %eax,%esi
  800e6f:	89 d7                	mov    %edx,%edi
  800e71:	39 d1                	cmp    %edx,%ecx
  800e73:	72 06                	jb     800e7b <__umoddi3+0x10b>
  800e75:	75 10                	jne    800e87 <__umoddi3+0x117>
  800e77:	39 c3                	cmp    %eax,%ebx
  800e79:	73 0c                	jae    800e87 <__umoddi3+0x117>
  800e7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800e7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e83:	89 d7                	mov    %edx,%edi
  800e85:	89 c6                	mov    %eax,%esi
  800e87:	89 ca                	mov    %ecx,%edx
  800e89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e8e:	29 f3                	sub    %esi,%ebx
  800e90:	19 fa                	sbb    %edi,%edx
  800e92:	89 d0                	mov    %edx,%eax
  800e94:	d3 e0                	shl    %cl,%eax
  800e96:	89 e9                	mov    %ebp,%ecx
  800e98:	d3 eb                	shr    %cl,%ebx
  800e9a:	d3 ea                	shr    %cl,%edx
  800e9c:	09 d8                	or     %ebx,%eax
  800e9e:	83 c4 1c             	add    $0x1c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    
  800ea6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ead:	8d 76 00             	lea    0x0(%esi),%esi
  800eb0:	29 fe                	sub    %edi,%esi
  800eb2:	19 c3                	sbb    %eax,%ebx
  800eb4:	89 f2                	mov    %esi,%edx
  800eb6:	89 d9                	mov    %ebx,%ecx
  800eb8:	e9 1d ff ff ff       	jmp    800dda <__umoddi3+0x6a>
