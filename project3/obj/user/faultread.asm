
obj/user/faultread:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003d:	ff 35 00 00 00 00    	pushl  0x0
  800043:	68 30 0e 80 00       	push   $0x800e30
  800048:	e8 0f 01 00 00       	call   80015c <cprintf>
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
  800061:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800068:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  80006b:	e8 f2 0a 00 00       	call   800b62 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800078:	c1 e0 05             	shl    $0x5,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x3e>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000b5:	e8 63 0a 00 00       	call   800b1d <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bf:	f3 0f 1e fb          	endbr32 
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cd:	8b 13                	mov    (%ebx),%edx
  8000cf:	8d 42 01             	lea    0x1(%edx),%eax
  8000d2:	89 03                	mov    %eax,(%ebx)
  8000d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e0:	74 09                	je     8000eb <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	68 ff 00 00 00       	push   $0xff
  8000f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f6:	50                   	push   %eax
  8000f7:	e8 dc 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  8000fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800102:	83 c4 10             	add    $0x10,%esp
  800105:	eb db                	jmp    8000e2 <putch+0x23>

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800114:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011b:	00 00 00 
	b.cnt = 0;
  80011e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800125:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800128:	ff 75 0c             	pushl  0xc(%ebp)
  80012b:	ff 75 08             	pushl  0x8(%ebp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	50                   	push   %eax
  800135:	68 bf 00 80 00       	push   $0x8000bf
  80013a:	e8 20 01 00 00       	call   80025f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800148:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 84 09 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  800154:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015c:	f3 0f 1e fb          	endbr32 
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 95 ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 1c             	sub    $0x1c,%esp
  80017d:	89 c7                	mov    %eax,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	89 d1                	mov    %edx,%ecx
  800189:	89 c2                	mov    %eax,%edx
  80018b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800191:	8b 45 10             	mov    0x10(%ebp),%eax
  800194:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a1:	39 c2                	cmp    %eax,%edx
  8001a3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001a6:	72 3e                	jb     8001e6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	ff 75 18             	pushl  0x18(%ebp)
  8001ae:	83 eb 01             	sub    $0x1,%ebx
  8001b1:	53                   	push   %ebx
  8001b2:	50                   	push   %eax
  8001b3:	83 ec 08             	sub    $0x8,%esp
  8001b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c2:	e8 09 0a 00 00       	call   800bd0 <__udivdi3>
  8001c7:	83 c4 18             	add    $0x18,%esp
  8001ca:	52                   	push   %edx
  8001cb:	50                   	push   %eax
  8001cc:	89 f2                	mov    %esi,%edx
  8001ce:	89 f8                	mov    %edi,%eax
  8001d0:	e8 9f ff ff ff       	call   800174 <printnum>
  8001d5:	83 c4 20             	add    $0x20,%esp
  8001d8:	eb 13                	jmp    8001ed <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001da:	83 ec 08             	sub    $0x8,%esp
  8001dd:	56                   	push   %esi
  8001de:	ff 75 18             	pushl  0x18(%ebp)
  8001e1:	ff d7                	call   *%edi
  8001e3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001e6:	83 eb 01             	sub    $0x1,%ebx
  8001e9:	85 db                	test   %ebx,%ebx
  8001eb:	7f ed                	jg     8001da <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	56                   	push   %esi
  8001f1:	83 ec 04             	sub    $0x4,%esp
  8001f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800200:	e8 db 0a 00 00       	call   800ce0 <__umoddi3>
  800205:	83 c4 14             	add    $0x14,%esp
  800208:	0f be 80 58 0e 80 00 	movsbl 0x800e58(%eax),%eax
  80020f:	50                   	push   %eax
  800210:	ff d7                	call   *%edi
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80021d:	f3 0f 1e fb          	endbr32 
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800227:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	3b 50 04             	cmp    0x4(%eax),%edx
  800230:	73 0a                	jae    80023c <sprintputch+0x1f>
		*b->buf++ = ch;
  800232:	8d 4a 01             	lea    0x1(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 45 08             	mov    0x8(%ebp),%eax
  80023a:	88 02                	mov    %al,(%edx)
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <printfmt>:
{
  80023e:	f3 0f 1e fb          	endbr32 
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800248:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80024b:	50                   	push   %eax
  80024c:	ff 75 10             	pushl  0x10(%ebp)
  80024f:	ff 75 0c             	pushl  0xc(%ebp)
  800252:	ff 75 08             	pushl  0x8(%ebp)
  800255:	e8 05 00 00 00       	call   80025f <vprintfmt>
}
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <vprintfmt>:
{
  80025f:	f3 0f 1e fb          	endbr32 
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 3c             	sub    $0x3c,%esp
  80026c:	8b 75 08             	mov    0x8(%ebp),%esi
  80026f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800272:	8b 7d 10             	mov    0x10(%ebp),%edi
  800275:	e9 8e 03 00 00       	jmp    800608 <vprintfmt+0x3a9>
		padc = ' ';
  80027a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80027e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800285:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80028c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800293:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800298:	8d 47 01             	lea    0x1(%edi),%eax
  80029b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029e:	0f b6 17             	movzbl (%edi),%edx
  8002a1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002a4:	3c 55                	cmp    $0x55,%al
  8002a6:	0f 87 df 03 00 00    	ja     80068b <vprintfmt+0x42c>
  8002ac:	0f b6 c0             	movzbl %al,%eax
  8002af:	3e ff 24 85 e8 0e 80 	notrack jmp *0x800ee8(,%eax,4)
  8002b6:	00 
  8002b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002ba:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002be:	eb d8                	jmp    800298 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002c7:	eb cf                	jmp    800298 <vprintfmt+0x39>
  8002c9:	0f b6 d2             	movzbl %dl,%edx
  8002cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002d7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002da:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002de:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e4:	83 f9 09             	cmp    $0x9,%ecx
  8002e7:	77 55                	ja     80033e <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002e9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002ec:	eb e9                	jmp    8002d7 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f1:	8b 00                	mov    (%eax),%eax
  8002f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f9:	8d 40 04             	lea    0x4(%eax),%eax
  8002fc:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800302:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800306:	79 90                	jns    800298 <vprintfmt+0x39>
				width = precision, precision = -1;
  800308:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80030b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800315:	eb 81                	jmp    800298 <vprintfmt+0x39>
  800317:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031a:	85 c0                	test   %eax,%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
  800321:	0f 49 d0             	cmovns %eax,%edx
  800324:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80032a:	e9 69 ff ff ff       	jmp    800298 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800332:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800339:	e9 5a ff ff ff       	jmp    800298 <vprintfmt+0x39>
  80033e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800341:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800344:	eb bc                	jmp    800302 <vprintfmt+0xa3>
			lflag++;
  800346:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80034c:	e9 47 ff ff ff       	jmp    800298 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 78 04             	lea    0x4(%eax),%edi
  800357:	83 ec 08             	sub    $0x8,%esp
  80035a:	53                   	push   %ebx
  80035b:	ff 30                	pushl  (%eax)
  80035d:	ff d6                	call   *%esi
			break;
  80035f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800362:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800365:	e9 9b 02 00 00       	jmp    800605 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80036a:	8b 45 14             	mov    0x14(%ebp),%eax
  80036d:	8d 78 04             	lea    0x4(%eax),%edi
  800370:	8b 00                	mov    (%eax),%eax
  800372:	99                   	cltd   
  800373:	31 d0                	xor    %edx,%eax
  800375:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800377:	83 f8 06             	cmp    $0x6,%eax
  80037a:	7f 23                	jg     80039f <vprintfmt+0x140>
  80037c:	8b 14 85 40 10 80 00 	mov    0x801040(,%eax,4),%edx
  800383:	85 d2                	test   %edx,%edx
  800385:	74 18                	je     80039f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800387:	52                   	push   %edx
  800388:	68 79 0e 80 00       	push   $0x800e79
  80038d:	53                   	push   %ebx
  80038e:	56                   	push   %esi
  80038f:	e8 aa fe ff ff       	call   80023e <printfmt>
  800394:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800397:	89 7d 14             	mov    %edi,0x14(%ebp)
  80039a:	e9 66 02 00 00       	jmp    800605 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80039f:	50                   	push   %eax
  8003a0:	68 70 0e 80 00       	push   $0x800e70
  8003a5:	53                   	push   %ebx
  8003a6:	56                   	push   %esi
  8003a7:	e8 92 fe ff ff       	call   80023e <printfmt>
  8003ac:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003af:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b2:	e9 4e 02 00 00       	jmp    800605 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	83 c0 04             	add    $0x4,%eax
  8003bd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	b8 69 0e 80 00       	mov    $0x800e69,%eax
  8003cc:	0f 45 c2             	cmovne %edx,%eax
  8003cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d6:	7e 06                	jle    8003de <vprintfmt+0x17f>
  8003d8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003dc:	75 0d                	jne    8003eb <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003de:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	03 45 e0             	add    -0x20(%ebp),%eax
  8003e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e9:	eb 55                	jmp    800440 <vprintfmt+0x1e1>
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f1:	ff 75 cc             	pushl  -0x34(%ebp)
  8003f4:	e8 46 03 00 00       	call   80073f <strnlen>
  8003f9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003fc:	29 c2                	sub    %eax,%edx
  8003fe:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800401:	83 c4 10             	add    $0x10,%esp
  800404:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800406:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80040a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80040d:	85 ff                	test   %edi,%edi
  80040f:	7e 11                	jle    800422 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	ff 75 e0             	pushl  -0x20(%ebp)
  800418:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80041a:	83 ef 01             	sub    $0x1,%edi
  80041d:	83 c4 10             	add    $0x10,%esp
  800420:	eb eb                	jmp    80040d <vprintfmt+0x1ae>
  800422:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800425:	85 d2                	test   %edx,%edx
  800427:	b8 00 00 00 00       	mov    $0x0,%eax
  80042c:	0f 49 c2             	cmovns %edx,%eax
  80042f:	29 c2                	sub    %eax,%edx
  800431:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800434:	eb a8                	jmp    8003de <vprintfmt+0x17f>
					putch(ch, putdat);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	53                   	push   %ebx
  80043a:	52                   	push   %edx
  80043b:	ff d6                	call   *%esi
  80043d:	83 c4 10             	add    $0x10,%esp
  800440:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800443:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800445:	83 c7 01             	add    $0x1,%edi
  800448:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80044c:	0f be d0             	movsbl %al,%edx
  80044f:	85 d2                	test   %edx,%edx
  800451:	74 4b                	je     80049e <vprintfmt+0x23f>
  800453:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800457:	78 06                	js     80045f <vprintfmt+0x200>
  800459:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80045d:	78 1e                	js     80047d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80045f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800463:	74 d1                	je     800436 <vprintfmt+0x1d7>
  800465:	0f be c0             	movsbl %al,%eax
  800468:	83 e8 20             	sub    $0x20,%eax
  80046b:	83 f8 5e             	cmp    $0x5e,%eax
  80046e:	76 c6                	jbe    800436 <vprintfmt+0x1d7>
					putch('?', putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	6a 3f                	push   $0x3f
  800476:	ff d6                	call   *%esi
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	eb c3                	jmp    800440 <vprintfmt+0x1e1>
  80047d:	89 cf                	mov    %ecx,%edi
  80047f:	eb 0e                	jmp    80048f <vprintfmt+0x230>
				putch(' ', putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	53                   	push   %ebx
  800485:	6a 20                	push   $0x20
  800487:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800489:	83 ef 01             	sub    $0x1,%edi
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	85 ff                	test   %edi,%edi
  800491:	7f ee                	jg     800481 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800496:	89 45 14             	mov    %eax,0x14(%ebp)
  800499:	e9 67 01 00 00       	jmp    800605 <vprintfmt+0x3a6>
  80049e:	89 cf                	mov    %ecx,%edi
  8004a0:	eb ed                	jmp    80048f <vprintfmt+0x230>
	if (lflag >= 2)
  8004a2:	83 f9 01             	cmp    $0x1,%ecx
  8004a5:	7f 1b                	jg     8004c2 <vprintfmt+0x263>
	else if (lflag)
  8004a7:	85 c9                	test   %ecx,%ecx
  8004a9:	74 63                	je     80050e <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8b 00                	mov    (%eax),%eax
  8004b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b3:	99                   	cltd   
  8004b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 40 04             	lea    0x4(%eax),%eax
  8004bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c0:	eb 17                	jmp    8004d9 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8b 50 04             	mov    0x4(%eax),%edx
  8004c8:	8b 00                	mov    (%eax),%eax
  8004ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 40 08             	lea    0x8(%eax),%eax
  8004d6:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004dc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004df:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004e4:	85 c9                	test   %ecx,%ecx
  8004e6:	0f 89 ff 00 00 00    	jns    8005eb <vprintfmt+0x38c>
				putch('-', putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	53                   	push   %ebx
  8004f0:	6a 2d                	push   $0x2d
  8004f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8004f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004fa:	f7 da                	neg    %edx
  8004fc:	83 d1 00             	adc    $0x0,%ecx
  8004ff:	f7 d9                	neg    %ecx
  800501:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800504:	b8 0a 00 00 00       	mov    $0xa,%eax
  800509:	e9 dd 00 00 00       	jmp    8005eb <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	99                   	cltd   
  800517:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 40 04             	lea    0x4(%eax),%eax
  800520:	89 45 14             	mov    %eax,0x14(%ebp)
  800523:	eb b4                	jmp    8004d9 <vprintfmt+0x27a>
	if (lflag >= 2)
  800525:	83 f9 01             	cmp    $0x1,%ecx
  800528:	7f 1e                	jg     800548 <vprintfmt+0x2e9>
	else if (lflag)
  80052a:	85 c9                	test   %ecx,%ecx
  80052c:	74 32                	je     800560 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8b 10                	mov    (%eax),%edx
  800533:	b9 00 00 00 00       	mov    $0x0,%ecx
  800538:	8d 40 04             	lea    0x4(%eax),%eax
  80053b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80053e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800543:	e9 a3 00 00 00       	jmp    8005eb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8b 10                	mov    (%eax),%edx
  80054d:	8b 48 04             	mov    0x4(%eax),%ecx
  800550:	8d 40 08             	lea    0x8(%eax),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800556:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80055b:	e9 8b 00 00 00       	jmp    8005eb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 10                	mov    (%eax),%edx
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	8d 40 04             	lea    0x4(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800570:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800575:	eb 74                	jmp    8005eb <vprintfmt+0x38c>
	if (lflag >= 2)
  800577:	83 f9 01             	cmp    $0x1,%ecx
  80057a:	7f 1b                	jg     800597 <vprintfmt+0x338>
	else if (lflag)
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	74 2c                	je     8005ac <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 10                	mov    (%eax),%edx
  800585:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058a:	8d 40 04             	lea    0x4(%eax),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800590:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800595:	eb 54                	jmp    8005eb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 10                	mov    (%eax),%edx
  80059c:	8b 48 04             	mov    0x4(%eax),%ecx
  80059f:	8d 40 08             	lea    0x8(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005a5:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005aa:	eb 3f                	jmp    8005eb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005bc:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005c1:	eb 28                	jmp    8005eb <vprintfmt+0x38c>
			putch('0', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	53                   	push   %ebx
  8005c7:	6a 30                	push   $0x30
  8005c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005cb:	83 c4 08             	add    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 78                	push   $0x78
  8005d1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 10                	mov    (%eax),%edx
  8005d8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005dd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005e6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005eb:	83 ec 0c             	sub    $0xc,%esp
  8005ee:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005f2:	57                   	push   %edi
  8005f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f6:	50                   	push   %eax
  8005f7:	51                   	push   %ecx
  8005f8:	52                   	push   %edx
  8005f9:	89 da                	mov    %ebx,%edx
  8005fb:	89 f0                	mov    %esi,%eax
  8005fd:	e8 72 fb ff ff       	call   800174 <printnum>
			break;
  800602:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800608:	83 c7 01             	add    $0x1,%edi
  80060b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060f:	83 f8 25             	cmp    $0x25,%eax
  800612:	0f 84 62 fc ff ff    	je     80027a <vprintfmt+0x1b>
			if (ch == '\0')
  800618:	85 c0                	test   %eax,%eax
  80061a:	0f 84 8b 00 00 00    	je     8006ab <vprintfmt+0x44c>
			putch(ch, putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	50                   	push   %eax
  800625:	ff d6                	call   *%esi
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	eb dc                	jmp    800608 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80062c:	83 f9 01             	cmp    $0x1,%ecx
  80062f:	7f 1b                	jg     80064c <vprintfmt+0x3ed>
	else if (lflag)
  800631:	85 c9                	test   %ecx,%ecx
  800633:	74 2c                	je     800661 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063f:	8d 40 04             	lea    0x4(%eax),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800645:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80064a:	eb 9f                	jmp    8005eb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	8b 48 04             	mov    0x4(%eax),%ecx
  800654:	8d 40 08             	lea    0x8(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80065f:	eb 8a                	jmp    8005eb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8b 10                	mov    (%eax),%edx
  800666:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066b:	8d 40 04             	lea    0x4(%eax),%eax
  80066e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800671:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800676:	e9 70 ff ff ff       	jmp    8005eb <vprintfmt+0x38c>
			putch(ch, putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	6a 25                	push   $0x25
  800681:	ff d6                	call   *%esi
			break;
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	e9 7a ff ff ff       	jmp    800605 <vprintfmt+0x3a6>
			putch('%', putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 25                	push   $0x25
  800691:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	89 f8                	mov    %edi,%eax
  800698:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80069c:	74 05                	je     8006a3 <vprintfmt+0x444>
  80069e:	83 e8 01             	sub    $0x1,%eax
  8006a1:	eb f5                	jmp    800698 <vprintfmt+0x439>
  8006a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a6:	e9 5a ff ff ff       	jmp    800605 <vprintfmt+0x3a6>
}
  8006ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ae:	5b                   	pop    %ebx
  8006af:	5e                   	pop    %esi
  8006b0:	5f                   	pop    %edi
  8006b1:	5d                   	pop    %ebp
  8006b2:	c3                   	ret    

008006b3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b3:	f3 0f 1e fb          	endbr32 
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 18             	sub    $0x18,%esp
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 26                	je     8006fe <vsnprintf+0x4b>
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	7e 22                	jle    8006fe <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006dc:	ff 75 14             	pushl  0x14(%ebp)
  8006df:	ff 75 10             	pushl  0x10(%ebp)
  8006e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e5:	50                   	push   %eax
  8006e6:	68 1d 02 80 00       	push   $0x80021d
  8006eb:	e8 6f fb ff ff       	call   80025f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f9:	83 c4 10             	add    $0x10,%esp
}
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    
		return -E_INVAL;
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800703:	eb f7                	jmp    8006fc <vsnprintf+0x49>

00800705 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800705:	f3 0f 1e fb          	endbr32 
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800712:	50                   	push   %eax
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	ff 75 0c             	pushl  0xc(%ebp)
  800719:	ff 75 08             	pushl  0x8(%ebp)
  80071c:	e8 92 ff ff ff       	call   8006b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800723:	f3 0f 1e fb          	endbr32 
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072d:	b8 00 00 00 00       	mov    $0x0,%eax
  800732:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800736:	74 05                	je     80073d <strlen+0x1a>
		n++;
  800738:	83 c0 01             	add    $0x1,%eax
  80073b:	eb f5                	jmp    800732 <strlen+0xf>
	return n;
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073f:	f3 0f 1e fb          	endbr32 
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074c:	b8 00 00 00 00       	mov    $0x0,%eax
  800751:	39 d0                	cmp    %edx,%eax
  800753:	74 0d                	je     800762 <strnlen+0x23>
  800755:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800759:	74 05                	je     800760 <strnlen+0x21>
		n++;
  80075b:	83 c0 01             	add    $0x1,%eax
  80075e:	eb f1                	jmp    800751 <strnlen+0x12>
  800760:	89 c2                	mov    %eax,%edx
	return n;
}
  800762:	89 d0                	mov    %edx,%eax
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800766:	f3 0f 1e fb          	endbr32 
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	53                   	push   %ebx
  80076e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80077d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800780:	83 c0 01             	add    $0x1,%eax
  800783:	84 d2                	test   %dl,%dl
  800785:	75 f2                	jne    800779 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800787:	89 c8                	mov    %ecx,%eax
  800789:	5b                   	pop    %ebx
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078c:	f3 0f 1e fb          	endbr32 
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	83 ec 10             	sub    $0x10,%esp
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 83 ff ff ff       	call   800723 <strlen>
  8007a0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 b8 ff ff ff       	call   800766 <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	f3 0f 1e fb          	endbr32 
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c4:	89 f3                	mov    %esi,%ebx
  8007c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	89 f0                	mov    %esi,%eax
  8007cb:	39 d8                	cmp    %ebx,%eax
  8007cd:	74 11                	je     8007e0 <strncpy+0x2b>
		*dst++ = *src;
  8007cf:	83 c0 01             	add    $0x1,%eax
  8007d2:	0f b6 0a             	movzbl (%edx),%ecx
  8007d5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d8:	80 f9 01             	cmp    $0x1,%cl
  8007db:	83 da ff             	sbb    $0xffffffff,%edx
  8007de:	eb eb                	jmp    8007cb <strncpy+0x16>
	}
	return ret;
}
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e6:	f3 0f 1e fb          	endbr32 
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	56                   	push   %esi
  8007ee:	53                   	push   %ebx
  8007ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	74 21                	je     80081f <strlcpy+0x39>
  8007fe:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800802:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800804:	39 c2                	cmp    %eax,%edx
  800806:	74 14                	je     80081c <strlcpy+0x36>
  800808:	0f b6 19             	movzbl (%ecx),%ebx
  80080b:	84 db                	test   %bl,%bl
  80080d:	74 0b                	je     80081a <strlcpy+0x34>
			*dst++ = *src++;
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	83 c2 01             	add    $0x1,%edx
  800815:	88 5a ff             	mov    %bl,-0x1(%edx)
  800818:	eb ea                	jmp    800804 <strlcpy+0x1e>
  80081a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80081c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081f:	29 f0                	sub    %esi,%eax
}
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800825:	f3 0f 1e fb          	endbr32 
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800832:	0f b6 01             	movzbl (%ecx),%eax
  800835:	84 c0                	test   %al,%al
  800837:	74 0c                	je     800845 <strcmp+0x20>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	75 08                	jne    800845 <strcmp+0x20>
		p++, q++;
  80083d:	83 c1 01             	add    $0x1,%ecx
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	eb ed                	jmp    800832 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800845:	0f b6 c0             	movzbl %al,%eax
  800848:	0f b6 12             	movzbl (%edx),%edx
  80084b:	29 d0                	sub    %edx,%eax
}
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084f:	f3 0f 1e fb          	endbr32 
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 c3                	mov    %eax,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800862:	eb 06                	jmp    80086a <strncmp+0x1b>
		n--, p++, q++;
  800864:	83 c0 01             	add    $0x1,%eax
  800867:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80086a:	39 d8                	cmp    %ebx,%eax
  80086c:	74 16                	je     800884 <strncmp+0x35>
  80086e:	0f b6 08             	movzbl (%eax),%ecx
  800871:	84 c9                	test   %cl,%cl
  800873:	74 04                	je     800879 <strncmp+0x2a>
  800875:	3a 0a                	cmp    (%edx),%cl
  800877:	74 eb                	je     800864 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800879:	0f b6 00             	movzbl (%eax),%eax
  80087c:	0f b6 12             	movzbl (%edx),%edx
  80087f:	29 d0                	sub    %edx,%eax
}
  800881:	5b                   	pop    %ebx
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    
		return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
  800889:	eb f6                	jmp    800881 <strncmp+0x32>

0080088b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088b:	f3 0f 1e fb          	endbr32 
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800899:	0f b6 10             	movzbl (%eax),%edx
  80089c:	84 d2                	test   %dl,%dl
  80089e:	74 09                	je     8008a9 <strchr+0x1e>
		if (*s == c)
  8008a0:	38 ca                	cmp    %cl,%dl
  8008a2:	74 0a                	je     8008ae <strchr+0x23>
	for (; *s; s++)
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	eb f0                	jmp    800899 <strchr+0xe>
			return (char *) s;
	return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b0:	f3 0f 1e fb          	endbr32 
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008be:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c1:	38 ca                	cmp    %cl,%dl
  8008c3:	74 09                	je     8008ce <strfind+0x1e>
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	74 05                	je     8008ce <strfind+0x1e>
	for (; *s; s++)
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	eb f0                	jmp    8008be <strfind+0xe>
			break;
	return (char *) s;
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d0:	f3 0f 1e fb          	endbr32 
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e0:	85 c9                	test   %ecx,%ecx
  8008e2:	74 31                	je     800915 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e4:	89 f8                	mov    %edi,%eax
  8008e6:	09 c8                	or     %ecx,%eax
  8008e8:	a8 03                	test   $0x3,%al
  8008ea:	75 23                	jne    80090f <memset+0x3f>
		c &= 0xFF;
  8008ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f0:	89 d3                	mov    %edx,%ebx
  8008f2:	c1 e3 08             	shl    $0x8,%ebx
  8008f5:	89 d0                	mov    %edx,%eax
  8008f7:	c1 e0 18             	shl    $0x18,%eax
  8008fa:	89 d6                	mov    %edx,%esi
  8008fc:	c1 e6 10             	shl    $0x10,%esi
  8008ff:	09 f0                	or     %esi,%eax
  800901:	09 c2                	or     %eax,%edx
  800903:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800905:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800908:	89 d0                	mov    %edx,%eax
  80090a:	fc                   	cld    
  80090b:	f3 ab                	rep stos %eax,%es:(%edi)
  80090d:	eb 06                	jmp    800915 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800912:	fc                   	cld    
  800913:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800915:	89 f8                	mov    %edi,%eax
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5f                   	pop    %edi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091c:	f3 0f 1e fb          	endbr32 
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092e:	39 c6                	cmp    %eax,%esi
  800930:	73 32                	jae    800964 <memmove+0x48>
  800932:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800935:	39 c2                	cmp    %eax,%edx
  800937:	76 2b                	jbe    800964 <memmove+0x48>
		s += n;
		d += n;
  800939:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	89 fe                	mov    %edi,%esi
  80093e:	09 ce                	or     %ecx,%esi
  800940:	09 d6                	or     %edx,%esi
  800942:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800948:	75 0e                	jne    800958 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094a:	83 ef 04             	sub    $0x4,%edi
  80094d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800950:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800953:	fd                   	std    
  800954:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800956:	eb 09                	jmp    800961 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800958:	83 ef 01             	sub    $0x1,%edi
  80095b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095e:	fd                   	std    
  80095f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800961:	fc                   	cld    
  800962:	eb 1a                	jmp    80097e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 c2                	mov    %eax,%edx
  800966:	09 ca                	or     %ecx,%edx
  800968:	09 f2                	or     %esi,%edx
  80096a:	f6 c2 03             	test   $0x3,%dl
  80096d:	75 0a                	jne    800979 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 05                	jmp    80097e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800982:	f3 0f 1e fb          	endbr32 
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80098c:	ff 75 10             	pushl  0x10(%ebp)
  80098f:	ff 75 0c             	pushl  0xc(%ebp)
  800992:	ff 75 08             	pushl  0x8(%ebp)
  800995:	e8 82 ff ff ff       	call   80091c <memmove>
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099c:	f3 0f 1e fb          	endbr32 
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ab:	89 c6                	mov    %eax,%esi
  8009ad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	39 f0                	cmp    %esi,%eax
  8009b2:	74 1c                	je     8009d0 <memcmp+0x34>
		if (*s1 != *s2)
  8009b4:	0f b6 08             	movzbl (%eax),%ecx
  8009b7:	0f b6 1a             	movzbl (%edx),%ebx
  8009ba:	38 d9                	cmp    %bl,%cl
  8009bc:	75 08                	jne    8009c6 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009be:	83 c0 01             	add    $0x1,%eax
  8009c1:	83 c2 01             	add    $0x1,%edx
  8009c4:	eb ea                	jmp    8009b0 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009c6:	0f b6 c1             	movzbl %cl,%eax
  8009c9:	0f b6 db             	movzbl %bl,%ebx
  8009cc:	29 d8                	sub    %ebx,%eax
  8009ce:	eb 05                	jmp    8009d5 <memcmp+0x39>
	}

	return 0;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d9:	f3 0f 1e fb          	endbr32 
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e6:	89 c2                	mov    %eax,%edx
  8009e8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009eb:	39 d0                	cmp    %edx,%eax
  8009ed:	73 09                	jae    8009f8 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ef:	38 08                	cmp    %cl,(%eax)
  8009f1:	74 05                	je     8009f8 <memfind+0x1f>
	for (; s < ends; s++)
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	eb f3                	jmp    8009eb <memfind+0x12>
			break;
	return (void *) s;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fa:	f3 0f 1e fb          	endbr32 
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0a:	eb 03                	jmp    800a0f <strtol+0x15>
		s++;
  800a0c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a0f:	0f b6 01             	movzbl (%ecx),%eax
  800a12:	3c 20                	cmp    $0x20,%al
  800a14:	74 f6                	je     800a0c <strtol+0x12>
  800a16:	3c 09                	cmp    $0x9,%al
  800a18:	74 f2                	je     800a0c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a1a:	3c 2b                	cmp    $0x2b,%al
  800a1c:	74 2a                	je     800a48 <strtol+0x4e>
	int neg = 0;
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a23:	3c 2d                	cmp    $0x2d,%al
  800a25:	74 2b                	je     800a52 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a27:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2d:	75 0f                	jne    800a3e <strtol+0x44>
  800a2f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a32:	74 28                	je     800a5c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a3b:	0f 44 d8             	cmove  %eax,%ebx
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a46:	eb 46                	jmp    800a8e <strtol+0x94>
		s++;
  800a48:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a50:	eb d5                	jmp    800a27 <strtol+0x2d>
		s++, neg = 1;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5a:	eb cb                	jmp    800a27 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	74 0e                	je     800a70 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a62:	85 db                	test   %ebx,%ebx
  800a64:	75 d8                	jne    800a3e <strtol+0x44>
		s++, base = 8;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a6e:	eb ce                	jmp    800a3e <strtol+0x44>
		s += 2, base = 16;
  800a70:	83 c1 02             	add    $0x2,%ecx
  800a73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a78:	eb c4                	jmp    800a3e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a7a:	0f be d2             	movsbl %dl,%edx
  800a7d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a80:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a83:	7d 3a                	jge    800abf <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a8e:	0f b6 11             	movzbl (%ecx),%edx
  800a91:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a94:	89 f3                	mov    %esi,%ebx
  800a96:	80 fb 09             	cmp    $0x9,%bl
  800a99:	76 df                	jbe    800a7a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a9b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 19             	cmp    $0x19,%bl
  800aa3:	77 08                	ja     800aad <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 57             	sub    $0x57,%edx
  800aab:	eb d3                	jmp    800a80 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aad:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 08                	ja     800abf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 37             	sub    $0x37,%edx
  800abd:	eb c1                	jmp    800a80 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800abf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac3:	74 05                	je     800aca <strtol+0xd0>
		*endptr = (char *) s;
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aca:	89 c2                	mov    %eax,%edx
  800acc:	f7 da                	neg    %edx
  800ace:	85 ff                	test   %edi,%edi
  800ad0:	0f 45 c2             	cmovne %edx,%eax
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	f3 0f 1e fb          	endbr32 
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	89 c7                	mov    %eax,%edi
  800af1:	89 c6                	mov    %eax,%esi
  800af3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_cgetc>:

int
sys_cgetc(void)
{
  800afa:	f3 0f 1e fb          	endbr32 
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1d:	f3 0f 1e fb          	endbr32 
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	b8 03 00 00 00       	mov    $0x3,%eax
  800b37:	89 cb                	mov    %ecx,%ebx
  800b39:	89 cf                	mov    %ecx,%edi
  800b3b:	89 ce                	mov    %ecx,%esi
  800b3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	7f 08                	jg     800b4b <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	50                   	push   %eax
  800b4f:	6a 03                	push   $0x3
  800b51:	68 5c 10 80 00       	push   $0x80105c
  800b56:	6a 23                	push   $0x23
  800b58:	68 79 10 80 00       	push   $0x801079
  800b5d:	e8 23 00 00 00       	call   800b85 <_panic>

00800b62 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b62:	f3 0f 1e fb          	endbr32 
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 02 00 00 00       	mov    $0x2,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b85:	f3 0f 1e fb          	endbr32 
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b8e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b91:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b97:	e8 c6 ff ff ff       	call   800b62 <sys_getenvid>
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ba2:	ff 75 08             	pushl  0x8(%ebp)
  800ba5:	56                   	push   %esi
  800ba6:	50                   	push   %eax
  800ba7:	68 88 10 80 00       	push   $0x801088
  800bac:	e8 ab f5 ff ff       	call   80015c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bb1:	83 c4 18             	add    $0x18,%esp
  800bb4:	53                   	push   %ebx
  800bb5:	ff 75 10             	pushl  0x10(%ebp)
  800bb8:	e8 4a f5 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  800bbd:	c7 04 24 4c 0e 80 00 	movl   $0x800e4c,(%esp)
  800bc4:	e8 93 f5 ff ff       	call   80015c <cprintf>
  800bc9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bcc:	cc                   	int3   
  800bcd:	eb fd                	jmp    800bcc <_panic+0x47>
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
