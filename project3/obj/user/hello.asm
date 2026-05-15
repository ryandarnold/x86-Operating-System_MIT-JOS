
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 31 00 00 00       	call   800062 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003d:	68 40 0e 80 00       	push   $0x800e40
  800042:	e8 25 01 00 00       	call   80016c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800047:	a1 04 20 80 00       	mov    0x802004,%eax
  80004c:	8b 40 48             	mov    0x48(%eax),%eax
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	50                   	push   %eax
  800053:	68 4e 0e 80 00       	push   $0x800e4e
  800058:	e8 0f 01 00 00       	call   80016c <cprintf>
}
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800062:	f3 0f 1e fb          	endbr32 
  800066:	55                   	push   %ebp
  800067:	89 e5                	mov    %esp,%ebp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800071:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800078:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  80007b:	e8 f2 0a 00 00       	call   800b72 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  800080:	25 ff 03 00 00       	and    $0x3ff,%eax
  800085:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800088:	c1 e0 05             	shl    $0x5,%eax
  80008b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800090:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800095:	85 db                	test   %ebx,%ebx
  800097:	7e 07                	jle    8000a0 <libmain+0x3e>
		binaryname = argv[0];
  800099:	8b 06                	mov    (%esi),%eax
  80009b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
  8000a5:	e8 89 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000aa:	e8 0a 00 00 00       	call   8000b9 <exit>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b5:	5b                   	pop    %ebx
  8000b6:	5e                   	pop    %esi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000c3:	6a 00                	push   $0x0
  8000c5:	e8 63 0a 00 00       	call   800b2d <sys_env_destroy>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    

008000cf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cf:	f3 0f 1e fb          	endbr32 
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 04             	sub    $0x4,%esp
  8000da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000dd:	8b 13                	mov    (%ebx),%edx
  8000df:	8d 42 01             	lea    0x1(%edx),%eax
  8000e2:	89 03                	mov    %eax,(%ebx)
  8000e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f0:	74 09                	je     8000fb <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fb:	83 ec 08             	sub    $0x8,%esp
  8000fe:	68 ff 00 00 00       	push   $0xff
  800103:	8d 43 08             	lea    0x8(%ebx),%eax
  800106:	50                   	push   %eax
  800107:	e8 dc 09 00 00       	call   800ae8 <sys_cputs>
		b->idx = 0;
  80010c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	eb db                	jmp    8000f2 <putch+0x23>

00800117 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800117:	f3 0f 1e fb          	endbr32 
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800124:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012b:	00 00 00 
	b.cnt = 0;
  80012e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800135:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800138:	ff 75 0c             	pushl  0xc(%ebp)
  80013b:	ff 75 08             	pushl  0x8(%ebp)
  80013e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800144:	50                   	push   %eax
  800145:	68 cf 00 80 00       	push   $0x8000cf
  80014a:	e8 20 01 00 00       	call   80026f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014f:	83 c4 08             	add    $0x8,%esp
  800152:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800158:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015e:	50                   	push   %eax
  80015f:	e8 84 09 00 00       	call   800ae8 <sys_cputs>

	return b.cnt;
}
  800164:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016c:	f3 0f 1e fb          	endbr32 
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800176:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800179:	50                   	push   %eax
  80017a:	ff 75 08             	pushl  0x8(%ebp)
  80017d:	e8 95 ff ff ff       	call   800117 <vcprintf>
	va_end(ap);

	return cnt;
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 1c             	sub    $0x1c,%esp
  80018d:	89 c7                	mov    %eax,%edi
  80018f:	89 d6                	mov    %edx,%esi
  800191:	8b 45 08             	mov    0x8(%ebp),%eax
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 d1                	mov    %edx,%ecx
  800199:	89 c2                	mov    %eax,%edx
  80019b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b1:	39 c2                	cmp    %eax,%edx
  8001b3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b6:	72 3e                	jb     8001f6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	ff 75 18             	pushl  0x18(%ebp)
  8001be:	83 eb 01             	sub    $0x1,%ebx
  8001c1:	53                   	push   %ebx
  8001c2:	50                   	push   %eax
  8001c3:	83 ec 08             	sub    $0x8,%esp
  8001c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d2:	e8 09 0a 00 00       	call   800be0 <__udivdi3>
  8001d7:	83 c4 18             	add    $0x18,%esp
  8001da:	52                   	push   %edx
  8001db:	50                   	push   %eax
  8001dc:	89 f2                	mov    %esi,%edx
  8001de:	89 f8                	mov    %edi,%eax
  8001e0:	e8 9f ff ff ff       	call   800184 <printnum>
  8001e5:	83 c4 20             	add    $0x20,%esp
  8001e8:	eb 13                	jmp    8001fd <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	56                   	push   %esi
  8001ee:	ff 75 18             	pushl  0x18(%ebp)
  8001f1:	ff d7                	call   *%edi
  8001f3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f6:	83 eb 01             	sub    $0x1,%ebx
  8001f9:	85 db                	test   %ebx,%ebx
  8001fb:	7f ed                	jg     8001ea <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	56                   	push   %esi
  800201:	83 ec 04             	sub    $0x4,%esp
  800204:	ff 75 e4             	pushl  -0x1c(%ebp)
  800207:	ff 75 e0             	pushl  -0x20(%ebp)
  80020a:	ff 75 dc             	pushl  -0x24(%ebp)
  80020d:	ff 75 d8             	pushl  -0x28(%ebp)
  800210:	e8 db 0a 00 00       	call   800cf0 <__umoddi3>
  800215:	83 c4 14             	add    $0x14,%esp
  800218:	0f be 80 6f 0e 80 00 	movsbl 0x800e6f(%eax),%eax
  80021f:	50                   	push   %eax
  800220:	ff d7                	call   *%edi
}
  800222:	83 c4 10             	add    $0x10,%esp
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80022d:	f3 0f 1e fb          	endbr32 
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800237:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023b:	8b 10                	mov    (%eax),%edx
  80023d:	3b 50 04             	cmp    0x4(%eax),%edx
  800240:	73 0a                	jae    80024c <sprintputch+0x1f>
		*b->buf++ = ch;
  800242:	8d 4a 01             	lea    0x1(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	88 02                	mov    %al,(%edx)
}
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <printfmt>:
{
  80024e:	f3 0f 1e fb          	endbr32 
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800258:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025b:	50                   	push   %eax
  80025c:	ff 75 10             	pushl  0x10(%ebp)
  80025f:	ff 75 0c             	pushl  0xc(%ebp)
  800262:	ff 75 08             	pushl  0x8(%ebp)
  800265:	e8 05 00 00 00       	call   80026f <vprintfmt>
}
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <vprintfmt>:
{
  80026f:	f3 0f 1e fb          	endbr32 
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 3c             	sub    $0x3c,%esp
  80027c:	8b 75 08             	mov    0x8(%ebp),%esi
  80027f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800282:	8b 7d 10             	mov    0x10(%ebp),%edi
  800285:	e9 8e 03 00 00       	jmp    800618 <vprintfmt+0x3a9>
		padc = ' ';
  80028a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80028e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800295:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80029c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a8:	8d 47 01             	lea    0x1(%edi),%eax
  8002ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ae:	0f b6 17             	movzbl (%edi),%edx
  8002b1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b4:	3c 55                	cmp    $0x55,%al
  8002b6:	0f 87 df 03 00 00    	ja     80069b <vprintfmt+0x42c>
  8002bc:	0f b6 c0             	movzbl %al,%eax
  8002bf:	3e ff 24 85 fc 0e 80 	notrack jmp *0x800efc(,%eax,4)
  8002c6:	00 
  8002c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002ca:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002ce:	eb d8                	jmp    8002a8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002d7:	eb cf                	jmp    8002a8 <vprintfmt+0x39>
  8002d9:	0f b6 d2             	movzbl %dl,%edx
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002df:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ea:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ee:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f4:	83 f9 09             	cmp    $0x9,%ecx
  8002f7:	77 55                	ja     80034e <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002fc:	eb e9                	jmp    8002e7 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800301:	8b 00                	mov    (%eax),%eax
  800303:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800306:	8b 45 14             	mov    0x14(%ebp),%eax
  800309:	8d 40 04             	lea    0x4(%eax),%eax
  80030c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800312:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800316:	79 90                	jns    8002a8 <vprintfmt+0x39>
				width = precision, precision = -1;
  800318:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80031b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800325:	eb 81                	jmp    8002a8 <vprintfmt+0x39>
  800327:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032a:	85 c0                	test   %eax,%eax
  80032c:	ba 00 00 00 00       	mov    $0x0,%edx
  800331:	0f 49 d0             	cmovns %eax,%edx
  800334:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80033a:	e9 69 ff ff ff       	jmp    8002a8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800342:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800349:	e9 5a ff ff ff       	jmp    8002a8 <vprintfmt+0x39>
  80034e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800351:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800354:	eb bc                	jmp    800312 <vprintfmt+0xa3>
			lflag++;
  800356:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80035c:	e9 47 ff ff ff       	jmp    8002a8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 78 04             	lea    0x4(%eax),%edi
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	53                   	push   %ebx
  80036b:	ff 30                	pushl  (%eax)
  80036d:	ff d6                	call   *%esi
			break;
  80036f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800372:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800375:	e9 9b 02 00 00       	jmp    800615 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	8d 78 04             	lea    0x4(%eax),%edi
  800380:	8b 00                	mov    (%eax),%eax
  800382:	99                   	cltd   
  800383:	31 d0                	xor    %edx,%eax
  800385:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800387:	83 f8 06             	cmp    $0x6,%eax
  80038a:	7f 23                	jg     8003af <vprintfmt+0x140>
  80038c:	8b 14 85 54 10 80 00 	mov    0x801054(,%eax,4),%edx
  800393:	85 d2                	test   %edx,%edx
  800395:	74 18                	je     8003af <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800397:	52                   	push   %edx
  800398:	68 90 0e 80 00       	push   $0x800e90
  80039d:	53                   	push   %ebx
  80039e:	56                   	push   %esi
  80039f:	e8 aa fe ff ff       	call   80024e <printfmt>
  8003a4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003aa:	e9 66 02 00 00       	jmp    800615 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003af:	50                   	push   %eax
  8003b0:	68 87 0e 80 00       	push   $0x800e87
  8003b5:	53                   	push   %ebx
  8003b6:	56                   	push   %esi
  8003b7:	e8 92 fe ff ff       	call   80024e <printfmt>
  8003bc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003bf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003c2:	e9 4e 02 00 00       	jmp    800615 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	83 c0 04             	add    $0x4,%eax
  8003cd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003d5:	85 d2                	test   %edx,%edx
  8003d7:	b8 80 0e 80 00       	mov    $0x800e80,%eax
  8003dc:	0f 45 c2             	cmovne %edx,%eax
  8003df:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e6:	7e 06                	jle    8003ee <vprintfmt+0x17f>
  8003e8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003ec:	75 0d                	jne    8003fb <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003f1:	89 c7                	mov    %eax,%edi
  8003f3:	03 45 e0             	add    -0x20(%ebp),%eax
  8003f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f9:	eb 55                	jmp    800450 <vprintfmt+0x1e1>
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800401:	ff 75 cc             	pushl  -0x34(%ebp)
  800404:	e8 46 03 00 00       	call   80074f <strnlen>
  800409:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80040c:	29 c2                	sub    %eax,%edx
  80040e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800411:	83 c4 10             	add    $0x10,%esp
  800414:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800416:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80041a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80041d:	85 ff                	test   %edi,%edi
  80041f:	7e 11                	jle    800432 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	53                   	push   %ebx
  800425:	ff 75 e0             	pushl  -0x20(%ebp)
  800428:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80042a:	83 ef 01             	sub    $0x1,%edi
  80042d:	83 c4 10             	add    $0x10,%esp
  800430:	eb eb                	jmp    80041d <vprintfmt+0x1ae>
  800432:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800435:	85 d2                	test   %edx,%edx
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	0f 49 c2             	cmovns %edx,%eax
  80043f:	29 c2                	sub    %eax,%edx
  800441:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800444:	eb a8                	jmp    8003ee <vprintfmt+0x17f>
					putch(ch, putdat);
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	53                   	push   %ebx
  80044a:	52                   	push   %edx
  80044b:	ff d6                	call   *%esi
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800453:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800455:	83 c7 01             	add    $0x1,%edi
  800458:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80045c:	0f be d0             	movsbl %al,%edx
  80045f:	85 d2                	test   %edx,%edx
  800461:	74 4b                	je     8004ae <vprintfmt+0x23f>
  800463:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800467:	78 06                	js     80046f <vprintfmt+0x200>
  800469:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80046d:	78 1e                	js     80048d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80046f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800473:	74 d1                	je     800446 <vprintfmt+0x1d7>
  800475:	0f be c0             	movsbl %al,%eax
  800478:	83 e8 20             	sub    $0x20,%eax
  80047b:	83 f8 5e             	cmp    $0x5e,%eax
  80047e:	76 c6                	jbe    800446 <vprintfmt+0x1d7>
					putch('?', putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	53                   	push   %ebx
  800484:	6a 3f                	push   $0x3f
  800486:	ff d6                	call   *%esi
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	eb c3                	jmp    800450 <vprintfmt+0x1e1>
  80048d:	89 cf                	mov    %ecx,%edi
  80048f:	eb 0e                	jmp    80049f <vprintfmt+0x230>
				putch(' ', putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	53                   	push   %ebx
  800495:	6a 20                	push   $0x20
  800497:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800499:	83 ef 01             	sub    $0x1,%edi
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 ff                	test   %edi,%edi
  8004a1:	7f ee                	jg     800491 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a9:	e9 67 01 00 00       	jmp    800615 <vprintfmt+0x3a6>
  8004ae:	89 cf                	mov    %ecx,%edi
  8004b0:	eb ed                	jmp    80049f <vprintfmt+0x230>
	if (lflag >= 2)
  8004b2:	83 f9 01             	cmp    $0x1,%ecx
  8004b5:	7f 1b                	jg     8004d2 <vprintfmt+0x263>
	else if (lflag)
  8004b7:	85 c9                	test   %ecx,%ecx
  8004b9:	74 63                	je     80051e <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c3:	99                   	cltd   
  8004c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 40 04             	lea    0x4(%eax),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d0:	eb 17                	jmp    8004e9 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8b 50 04             	mov    0x4(%eax),%edx
  8004d8:	8b 00                	mov    (%eax),%eax
  8004da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 40 08             	lea    0x8(%eax),%eax
  8004e6:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004ef:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004f4:	85 c9                	test   %ecx,%ecx
  8004f6:	0f 89 ff 00 00 00    	jns    8005fb <vprintfmt+0x38c>
				putch('-', putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	53                   	push   %ebx
  800500:	6a 2d                	push   $0x2d
  800502:	ff d6                	call   *%esi
				num = -(long long) num;
  800504:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800507:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050a:	f7 da                	neg    %edx
  80050c:	83 d1 00             	adc    $0x0,%ecx
  80050f:	f7 d9                	neg    %ecx
  800511:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800514:	b8 0a 00 00 00       	mov    $0xa,%eax
  800519:	e9 dd 00 00 00       	jmp    8005fb <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800526:	99                   	cltd   
  800527:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 40 04             	lea    0x4(%eax),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
  800533:	eb b4                	jmp    8004e9 <vprintfmt+0x27a>
	if (lflag >= 2)
  800535:	83 f9 01             	cmp    $0x1,%ecx
  800538:	7f 1e                	jg     800558 <vprintfmt+0x2e9>
	else if (lflag)
  80053a:	85 c9                	test   %ecx,%ecx
  80053c:	74 32                	je     800570 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8b 10                	mov    (%eax),%edx
  800543:	b9 00 00 00 00       	mov    $0x0,%ecx
  800548:	8d 40 04             	lea    0x4(%eax),%eax
  80054b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800553:	e9 a3 00 00 00       	jmp    8005fb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8b 10                	mov    (%eax),%edx
  80055d:	8b 48 04             	mov    0x4(%eax),%ecx
  800560:	8d 40 08             	lea    0x8(%eax),%eax
  800563:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80056b:	e9 8b 00 00 00       	jmp    8005fb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 10                	mov    (%eax),%edx
  800575:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057a:	8d 40 04             	lea    0x4(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800585:	eb 74                	jmp    8005fb <vprintfmt+0x38c>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7f 1b                	jg     8005a7 <vprintfmt+0x338>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 2c                	je     8005bc <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 10                	mov    (%eax),%edx
  800595:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059a:	8d 40 04             	lea    0x4(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005a0:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005a5:	eb 54                	jmp    8005fb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	8b 48 04             	mov    0x4(%eax),%ecx
  8005af:	8d 40 08             	lea    0x8(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005b5:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005ba:	eb 3f                	jmp    8005fb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c6:	8d 40 04             	lea    0x4(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005cc:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005d1:	eb 28                	jmp    8005fb <vprintfmt+0x38c>
			putch('0', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 30                	push   $0x30
  8005d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005db:	83 c4 08             	add    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 78                	push   $0x78
  8005e1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005ed:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800602:	57                   	push   %edi
  800603:	ff 75 e0             	pushl  -0x20(%ebp)
  800606:	50                   	push   %eax
  800607:	51                   	push   %ecx
  800608:	52                   	push   %edx
  800609:	89 da                	mov    %ebx,%edx
  80060b:	89 f0                	mov    %esi,%eax
  80060d:	e8 72 fb ff ff       	call   800184 <printnum>
			break;
  800612:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800618:	83 c7 01             	add    $0x1,%edi
  80061b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061f:	83 f8 25             	cmp    $0x25,%eax
  800622:	0f 84 62 fc ff ff    	je     80028a <vprintfmt+0x1b>
			if (ch == '\0')
  800628:	85 c0                	test   %eax,%eax
  80062a:	0f 84 8b 00 00 00    	je     8006bb <vprintfmt+0x44c>
			putch(ch, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	50                   	push   %eax
  800635:	ff d6                	call   *%esi
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	eb dc                	jmp    800618 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80063c:	83 f9 01             	cmp    $0x1,%ecx
  80063f:	7f 1b                	jg     80065c <vprintfmt+0x3ed>
	else if (lflag)
  800641:	85 c9                	test   %ecx,%ecx
  800643:	74 2c                	je     800671 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064f:	8d 40 04             	lea    0x4(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800655:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80065a:	eb 9f                	jmp    8005fb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	8b 48 04             	mov    0x4(%eax),%ecx
  800664:	8d 40 08             	lea    0x8(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80066f:	eb 8a                	jmp    8005fb <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800681:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800686:	e9 70 ff ff ff       	jmp    8005fb <vprintfmt+0x38c>
			putch(ch, putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 25                	push   $0x25
  800691:	ff d6                	call   *%esi
			break;
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	e9 7a ff ff ff       	jmp    800615 <vprintfmt+0x3a6>
			putch('%', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 25                	push   $0x25
  8006a1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	89 f8                	mov    %edi,%eax
  8006a8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ac:	74 05                	je     8006b3 <vprintfmt+0x444>
  8006ae:	83 e8 01             	sub    $0x1,%eax
  8006b1:	eb f5                	jmp    8006a8 <vprintfmt+0x439>
  8006b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b6:	e9 5a ff ff ff       	jmp    800615 <vprintfmt+0x3a6>
}
  8006bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006be:	5b                   	pop    %ebx
  8006bf:	5e                   	pop    %esi
  8006c0:	5f                   	pop    %edi
  8006c1:	5d                   	pop    %ebp
  8006c2:	c3                   	ret    

008006c3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c3:	f3 0f 1e fb          	endbr32 
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	83 ec 18             	sub    $0x18,%esp
  8006cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 26                	je     80070e <vsnprintf+0x4b>
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	7e 22                	jle    80070e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ec:	ff 75 14             	pushl  0x14(%ebp)
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f5:	50                   	push   %eax
  8006f6:	68 2d 02 80 00       	push   $0x80022d
  8006fb:	e8 6f fb ff ff       	call   80026f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800700:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800703:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800709:	83 c4 10             	add    $0x10,%esp
}
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    
		return -E_INVAL;
  80070e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800713:	eb f7                	jmp    80070c <vsnprintf+0x49>

00800715 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800715:	f3 0f 1e fb          	endbr32 
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800722:	50                   	push   %eax
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	ff 75 0c             	pushl  0xc(%ebp)
  800729:	ff 75 08             	pushl  0x8(%ebp)
  80072c:	e8 92 ff ff ff       	call   8006c3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800733:	f3 0f 1e fb          	endbr32 
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073d:	b8 00 00 00 00       	mov    $0x0,%eax
  800742:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800746:	74 05                	je     80074d <strlen+0x1a>
		n++;
  800748:	83 c0 01             	add    $0x1,%eax
  80074b:	eb f5                	jmp    800742 <strlen+0xf>
	return n;
}
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074f:	f3 0f 1e fb          	endbr32 
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075c:	b8 00 00 00 00       	mov    $0x0,%eax
  800761:	39 d0                	cmp    %edx,%eax
  800763:	74 0d                	je     800772 <strnlen+0x23>
  800765:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800769:	74 05                	je     800770 <strnlen+0x21>
		n++;
  80076b:	83 c0 01             	add    $0x1,%eax
  80076e:	eb f1                	jmp    800761 <strnlen+0x12>
  800770:	89 c2                	mov    %eax,%edx
	return n;
}
  800772:	89 d0                	mov    %edx,%eax
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800776:	f3 0f 1e fb          	endbr32 
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800781:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80078d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800790:	83 c0 01             	add    $0x1,%eax
  800793:	84 d2                	test   %dl,%dl
  800795:	75 f2                	jne    800789 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800797:	89 c8                	mov    %ecx,%eax
  800799:	5b                   	pop    %ebx
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079c:	f3 0f 1e fb          	endbr32 
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 10             	sub    $0x10,%esp
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	53                   	push   %ebx
  8007ab:	e8 83 ff ff ff       	call   800733 <strlen>
  8007b0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	01 d8                	add    %ebx,%eax
  8007b8:	50                   	push   %eax
  8007b9:	e8 b8 ff ff ff       	call   800776 <strcpy>
	return dst;
}
  8007be:	89 d8                	mov    %ebx,%eax
  8007c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c5:	f3 0f 1e fb          	endbr32 
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d4:	89 f3                	mov    %esi,%ebx
  8007d6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	89 f0                	mov    %esi,%eax
  8007db:	39 d8                	cmp    %ebx,%eax
  8007dd:	74 11                	je     8007f0 <strncpy+0x2b>
		*dst++ = *src;
  8007df:	83 c0 01             	add    $0x1,%eax
  8007e2:	0f b6 0a             	movzbl (%edx),%ecx
  8007e5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e8:	80 f9 01             	cmp    $0x1,%cl
  8007eb:	83 da ff             	sbb    $0xffffffff,%edx
  8007ee:	eb eb                	jmp    8007db <strncpy+0x16>
	}
	return ret;
}
  8007f0:	89 f0                	mov    %esi,%eax
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f6:	f3 0f 1e fb          	endbr32 
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800805:	8b 55 10             	mov    0x10(%ebp),%edx
  800808:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080a:	85 d2                	test   %edx,%edx
  80080c:	74 21                	je     80082f <strlcpy+0x39>
  80080e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800812:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800814:	39 c2                	cmp    %eax,%edx
  800816:	74 14                	je     80082c <strlcpy+0x36>
  800818:	0f b6 19             	movzbl (%ecx),%ebx
  80081b:	84 db                	test   %bl,%bl
  80081d:	74 0b                	je     80082a <strlcpy+0x34>
			*dst++ = *src++;
  80081f:	83 c1 01             	add    $0x1,%ecx
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
  800828:	eb ea                	jmp    800814 <strlcpy+0x1e>
  80082a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80082c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082f:	29 f0                	sub    %esi,%eax
}
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800835:	f3 0f 1e fb          	endbr32 
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800842:	0f b6 01             	movzbl (%ecx),%eax
  800845:	84 c0                	test   %al,%al
  800847:	74 0c                	je     800855 <strcmp+0x20>
  800849:	3a 02                	cmp    (%edx),%al
  80084b:	75 08                	jne    800855 <strcmp+0x20>
		p++, q++;
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	eb ed                	jmp    800842 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800855:	0f b6 c0             	movzbl %al,%eax
  800858:	0f b6 12             	movzbl (%edx),%edx
  80085b:	29 d0                	sub    %edx,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085f:	f3 0f 1e fb          	endbr32 
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086d:	89 c3                	mov    %eax,%ebx
  80086f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800872:	eb 06                	jmp    80087a <strncmp+0x1b>
		n--, p++, q++;
  800874:	83 c0 01             	add    $0x1,%eax
  800877:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80087a:	39 d8                	cmp    %ebx,%eax
  80087c:	74 16                	je     800894 <strncmp+0x35>
  80087e:	0f b6 08             	movzbl (%eax),%ecx
  800881:	84 c9                	test   %cl,%cl
  800883:	74 04                	je     800889 <strncmp+0x2a>
  800885:	3a 0a                	cmp    (%edx),%cl
  800887:	74 eb                	je     800874 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800889:	0f b6 00             	movzbl (%eax),%eax
  80088c:	0f b6 12             	movzbl (%edx),%edx
  80088f:	29 d0                	sub    %edx,%eax
}
  800891:	5b                   	pop    %ebx
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    
		return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
  800899:	eb f6                	jmp    800891 <strncmp+0x32>

0080089b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089b:	f3 0f 1e fb          	endbr32 
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	0f b6 10             	movzbl (%eax),%edx
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	74 09                	je     8008b9 <strchr+0x1e>
		if (*s == c)
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 0a                	je     8008be <strchr+0x23>
	for (; *s; s++)
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	eb f0                	jmp    8008a9 <strchr+0xe>
			return (char *) s;
	return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c0:	f3 0f 1e fb          	endbr32 
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 09                	je     8008de <strfind+0x1e>
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	74 05                	je     8008de <strfind+0x1e>
	for (; *s; s++)
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	eb f0                	jmp    8008ce <strfind+0xe>
			break;
	return (char *) s;
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f0:	85 c9                	test   %ecx,%ecx
  8008f2:	74 31                	je     800925 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f4:	89 f8                	mov    %edi,%eax
  8008f6:	09 c8                	or     %ecx,%eax
  8008f8:	a8 03                	test   $0x3,%al
  8008fa:	75 23                	jne    80091f <memset+0x3f>
		c &= 0xFF;
  8008fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800900:	89 d3                	mov    %edx,%ebx
  800902:	c1 e3 08             	shl    $0x8,%ebx
  800905:	89 d0                	mov    %edx,%eax
  800907:	c1 e0 18             	shl    $0x18,%eax
  80090a:	89 d6                	mov    %edx,%esi
  80090c:	c1 e6 10             	shl    $0x10,%esi
  80090f:	09 f0                	or     %esi,%eax
  800911:	09 c2                	or     %eax,%edx
  800913:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800915:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800918:	89 d0                	mov    %edx,%eax
  80091a:	fc                   	cld    
  80091b:	f3 ab                	rep stos %eax,%es:(%edi)
  80091d:	eb 06                	jmp    800925 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092c:	f3 0f 1e fb          	endbr32 
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093e:	39 c6                	cmp    %eax,%esi
  800940:	73 32                	jae    800974 <memmove+0x48>
  800942:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800945:	39 c2                	cmp    %eax,%edx
  800947:	76 2b                	jbe    800974 <memmove+0x48>
		s += n;
		d += n;
  800949:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	89 fe                	mov    %edi,%esi
  80094e:	09 ce                	or     %ecx,%esi
  800950:	09 d6                	or     %edx,%esi
  800952:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800958:	75 0e                	jne    800968 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095a:	83 ef 04             	sub    $0x4,%edi
  80095d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800960:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800963:	fd                   	std    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 09                	jmp    800971 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800968:	83 ef 01             	sub    $0x1,%edi
  80096b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80096e:	fd                   	std    
  80096f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800971:	fc                   	cld    
  800972:	eb 1a                	jmp    80098e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	89 c2                	mov    %eax,%edx
  800976:	09 ca                	or     %ecx,%edx
  800978:	09 f2                	or     %esi,%edx
  80097a:	f6 c2 03             	test   $0x3,%dl
  80097d:	75 0a                	jne    800989 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	f3 0f 1e fb          	endbr32 
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099c:	ff 75 10             	pushl  0x10(%ebp)
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	ff 75 08             	pushl  0x8(%ebp)
  8009a5:	e8 82 ff ff ff       	call   80092c <memmove>
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ac:	f3 0f 1e fb          	endbr32 
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 c6                	mov    %eax,%esi
  8009bd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c0:	39 f0                	cmp    %esi,%eax
  8009c2:	74 1c                	je     8009e0 <memcmp+0x34>
		if (*s1 != *s2)
  8009c4:	0f b6 08             	movzbl (%eax),%ecx
  8009c7:	0f b6 1a             	movzbl (%edx),%ebx
  8009ca:	38 d9                	cmp    %bl,%cl
  8009cc:	75 08                	jne    8009d6 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	83 c2 01             	add    $0x1,%edx
  8009d4:	eb ea                	jmp    8009c0 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009d6:	0f b6 c1             	movzbl %cl,%eax
  8009d9:	0f b6 db             	movzbl %bl,%ebx
  8009dc:	29 d8                	sub    %ebx,%eax
  8009de:	eb 05                	jmp    8009e5 <memcmp+0x39>
	}

	return 0;
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e9:	f3 0f 1e fb          	endbr32 
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f6:	89 c2                	mov    %eax,%edx
  8009f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fb:	39 d0                	cmp    %edx,%eax
  8009fd:	73 09                	jae    800a08 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ff:	38 08                	cmp    %cl,(%eax)
  800a01:	74 05                	je     800a08 <memfind+0x1f>
	for (; s < ends; s++)
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	eb f3                	jmp    8009fb <memfind+0x12>
			break;
	return (void *) s;
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0a:	f3 0f 1e fb          	endbr32 
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1a:	eb 03                	jmp    800a1f <strtol+0x15>
		s++;
  800a1c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a1f:	0f b6 01             	movzbl (%ecx),%eax
  800a22:	3c 20                	cmp    $0x20,%al
  800a24:	74 f6                	je     800a1c <strtol+0x12>
  800a26:	3c 09                	cmp    $0x9,%al
  800a28:	74 f2                	je     800a1c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a2a:	3c 2b                	cmp    $0x2b,%al
  800a2c:	74 2a                	je     800a58 <strtol+0x4e>
	int neg = 0;
  800a2e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a33:	3c 2d                	cmp    $0x2d,%al
  800a35:	74 2b                	je     800a62 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a37:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3d:	75 0f                	jne    800a4e <strtol+0x44>
  800a3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a42:	74 28                	je     800a6c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a4b:	0f 44 d8             	cmove  %eax,%ebx
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a56:	eb 46                	jmp    800a9e <strtol+0x94>
		s++;
  800a58:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a60:	eb d5                	jmp    800a37 <strtol+0x2d>
		s++, neg = 1;
  800a62:	83 c1 01             	add    $0x1,%ecx
  800a65:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6a:	eb cb                	jmp    800a37 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a70:	74 0e                	je     800a80 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a72:	85 db                	test   %ebx,%ebx
  800a74:	75 d8                	jne    800a4e <strtol+0x44>
		s++, base = 8;
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a7e:	eb ce                	jmp    800a4e <strtol+0x44>
		s += 2, base = 16;
  800a80:	83 c1 02             	add    $0x2,%ecx
  800a83:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a88:	eb c4                	jmp    800a4e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a93:	7d 3a                	jge    800acf <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a95:	83 c1 01             	add    $0x1,%ecx
  800a98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a9e:	0f b6 11             	movzbl (%ecx),%edx
  800aa1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa4:	89 f3                	mov    %esi,%ebx
  800aa6:	80 fb 09             	cmp    $0x9,%bl
  800aa9:	76 df                	jbe    800a8a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 08                	ja     800abd <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 57             	sub    $0x57,%edx
  800abb:	eb d3                	jmp    800a90 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800abd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 08                	ja     800acf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ac7:	0f be d2             	movsbl %dl,%edx
  800aca:	83 ea 37             	sub    $0x37,%edx
  800acd:	eb c1                	jmp    800a90 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800acf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad3:	74 05                	je     800ada <strtol+0xd0>
		*endptr = (char *) s;
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	f7 da                	neg    %edx
  800ade:	85 ff                	test   %edi,%edi
  800ae0:	0f 45 c2             	cmovne %edx,%eax
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae8:	f3 0f 1e fb          	endbr32 
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
  800af7:	8b 55 08             	mov    0x8(%ebp),%edx
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	89 c7                	mov    %eax,%edi
  800b01:	89 c6                	mov    %eax,%esi
  800b03:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0a:	f3 0f 1e fb          	endbr32 
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2d:	f3 0f 1e fb          	endbr32 
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	b8 03 00 00 00       	mov    $0x3,%eax
  800b47:	89 cb                	mov    %ecx,%ebx
  800b49:	89 cf                	mov    %ecx,%edi
  800b4b:	89 ce                	mov    %ecx,%esi
  800b4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	7f 08                	jg     800b5b <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	50                   	push   %eax
  800b5f:	6a 03                	push   $0x3
  800b61:	68 70 10 80 00       	push   $0x801070
  800b66:	6a 23                	push   $0x23
  800b68:	68 8d 10 80 00       	push   $0x80108d
  800b6d:	e8 23 00 00 00       	call   800b95 <_panic>

00800b72 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b72:	f3 0f 1e fb          	endbr32 
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 02 00 00 00       	mov    $0x2,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b95:	f3 0f 1e fb          	endbr32 
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b9e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ba1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ba7:	e8 c6 ff ff ff       	call   800b72 <sys_getenvid>
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	ff 75 08             	pushl  0x8(%ebp)
  800bb5:	56                   	push   %esi
  800bb6:	50                   	push   %eax
  800bb7:	68 9c 10 80 00       	push   $0x80109c
  800bbc:	e8 ab f5 ff ff       	call   80016c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bc1:	83 c4 18             	add    $0x18,%esp
  800bc4:	53                   	push   %ebx
  800bc5:	ff 75 10             	pushl  0x10(%ebp)
  800bc8:	e8 4a f5 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  800bcd:	c7 04 24 4c 0e 80 00 	movl   $0x800e4c,(%esp)
  800bd4:	e8 93 f5 ff ff       	call   80016c <cprintf>
  800bd9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bdc:	cc                   	int3   
  800bdd:	eb fd                	jmp    800bdc <_panic+0x47>
  800bdf:	90                   	nop

00800be0 <__udivdi3>:
  800be0:	f3 0f 1e fb          	endbr32 
  800be4:	55                   	push   %ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 1c             	sub    $0x1c,%esp
  800beb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800bef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800bf3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800bf7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800bfb:	85 d2                	test   %edx,%edx
  800bfd:	75 19                	jne    800c18 <__udivdi3+0x38>
  800bff:	39 f3                	cmp    %esi,%ebx
  800c01:	76 4d                	jbe    800c50 <__udivdi3+0x70>
  800c03:	31 ff                	xor    %edi,%edi
  800c05:	89 e8                	mov    %ebp,%eax
  800c07:	89 f2                	mov    %esi,%edx
  800c09:	f7 f3                	div    %ebx
  800c0b:	89 fa                	mov    %edi,%edx
  800c0d:	83 c4 1c             	add    $0x1c,%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
  800c15:	8d 76 00             	lea    0x0(%esi),%esi
  800c18:	39 f2                	cmp    %esi,%edx
  800c1a:	76 14                	jbe    800c30 <__udivdi3+0x50>
  800c1c:	31 ff                	xor    %edi,%edi
  800c1e:	31 c0                	xor    %eax,%eax
  800c20:	89 fa                	mov    %edi,%edx
  800c22:	83 c4 1c             	add    $0x1c,%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    
  800c2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c30:	0f bd fa             	bsr    %edx,%edi
  800c33:	83 f7 1f             	xor    $0x1f,%edi
  800c36:	75 48                	jne    800c80 <__udivdi3+0xa0>
  800c38:	39 f2                	cmp    %esi,%edx
  800c3a:	72 06                	jb     800c42 <__udivdi3+0x62>
  800c3c:	31 c0                	xor    %eax,%eax
  800c3e:	39 eb                	cmp    %ebp,%ebx
  800c40:	77 de                	ja     800c20 <__udivdi3+0x40>
  800c42:	b8 01 00 00 00       	mov    $0x1,%eax
  800c47:	eb d7                	jmp    800c20 <__udivdi3+0x40>
  800c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c50:	89 d9                	mov    %ebx,%ecx
  800c52:	85 db                	test   %ebx,%ebx
  800c54:	75 0b                	jne    800c61 <__udivdi3+0x81>
  800c56:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5b:	31 d2                	xor    %edx,%edx
  800c5d:	f7 f3                	div    %ebx
  800c5f:	89 c1                	mov    %eax,%ecx
  800c61:	31 d2                	xor    %edx,%edx
  800c63:	89 f0                	mov    %esi,%eax
  800c65:	f7 f1                	div    %ecx
  800c67:	89 c6                	mov    %eax,%esi
  800c69:	89 e8                	mov    %ebp,%eax
  800c6b:	89 f7                	mov    %esi,%edi
  800c6d:	f7 f1                	div    %ecx
  800c6f:	89 fa                	mov    %edi,%edx
  800c71:	83 c4 1c             	add    $0x1c,%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    
  800c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	b8 20 00 00 00       	mov    $0x20,%eax
  800c87:	29 f8                	sub    %edi,%eax
  800c89:	d3 e2                	shl    %cl,%edx
  800c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	d3 ea                	shr    %cl,%edx
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 d1                	or     %edx,%ecx
  800c9b:	89 f2                	mov    %esi,%edx
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f9                	mov    %edi,%ecx
  800ca3:	d3 e3                	shl    %cl,%ebx
  800ca5:	89 c1                	mov    %eax,%ecx
  800ca7:	d3 ea                	shr    %cl,%edx
  800ca9:	89 f9                	mov    %edi,%ecx
  800cab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800caf:	89 eb                	mov    %ebp,%ebx
  800cb1:	d3 e6                	shl    %cl,%esi
  800cb3:	89 c1                	mov    %eax,%ecx
  800cb5:	d3 eb                	shr    %cl,%ebx
  800cb7:	09 de                	or     %ebx,%esi
  800cb9:	89 f0                	mov    %esi,%eax
  800cbb:	f7 74 24 08          	divl   0x8(%esp)
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	f7 64 24 0c          	mull   0xc(%esp)
  800cc7:	39 d6                	cmp    %edx,%esi
  800cc9:	72 15                	jb     800ce0 <__udivdi3+0x100>
  800ccb:	89 f9                	mov    %edi,%ecx
  800ccd:	d3 e5                	shl    %cl,%ebp
  800ccf:	39 c5                	cmp    %eax,%ebp
  800cd1:	73 04                	jae    800cd7 <__udivdi3+0xf7>
  800cd3:	39 d6                	cmp    %edx,%esi
  800cd5:	74 09                	je     800ce0 <__udivdi3+0x100>
  800cd7:	89 d8                	mov    %ebx,%eax
  800cd9:	31 ff                	xor    %edi,%edi
  800cdb:	e9 40 ff ff ff       	jmp    800c20 <__udivdi3+0x40>
  800ce0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ce3:	31 ff                	xor    %edi,%edi
  800ce5:	e9 36 ff ff ff       	jmp    800c20 <__udivdi3+0x40>
  800cea:	66 90                	xchg   %ax,%ax
  800cec:	66 90                	xchg   %ax,%ax
  800cee:	66 90                	xchg   %ax,%ax

00800cf0 <__umoddi3>:
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 1c             	sub    $0x1c,%esp
  800cfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cff:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d03:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d07:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	75 19                	jne    800d28 <__umoddi3+0x38>
  800d0f:	39 df                	cmp    %ebx,%edi
  800d11:	76 5d                	jbe    800d70 <__umoddi3+0x80>
  800d13:	89 f0                	mov    %esi,%eax
  800d15:	89 da                	mov    %ebx,%edx
  800d17:	f7 f7                	div    %edi
  800d19:	89 d0                	mov    %edx,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	83 c4 1c             	add    $0x1c,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
  800d25:	8d 76 00             	lea    0x0(%esi),%esi
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	39 d8                	cmp    %ebx,%eax
  800d2c:	76 12                	jbe    800d40 <__umoddi3+0x50>
  800d2e:	89 f0                	mov    %esi,%eax
  800d30:	89 da                	mov    %ebx,%edx
  800d32:	83 c4 1c             	add    $0x1c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
  800d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d40:	0f bd e8             	bsr    %eax,%ebp
  800d43:	83 f5 1f             	xor    $0x1f,%ebp
  800d46:	75 50                	jne    800d98 <__umoddi3+0xa8>
  800d48:	39 d8                	cmp    %ebx,%eax
  800d4a:	0f 82 e0 00 00 00    	jb     800e30 <__umoddi3+0x140>
  800d50:	89 d9                	mov    %ebx,%ecx
  800d52:	39 f7                	cmp    %esi,%edi
  800d54:	0f 86 d6 00 00 00    	jbe    800e30 <__umoddi3+0x140>
  800d5a:	89 d0                	mov    %edx,%eax
  800d5c:	89 ca                	mov    %ecx,%edx
  800d5e:	83 c4 1c             	add    $0x1c,%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
  800d66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d6d:	8d 76 00             	lea    0x0(%esi),%esi
  800d70:	89 fd                	mov    %edi,%ebp
  800d72:	85 ff                	test   %edi,%edi
  800d74:	75 0b                	jne    800d81 <__umoddi3+0x91>
  800d76:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	f7 f7                	div    %edi
  800d7f:	89 c5                	mov    %eax,%ebp
  800d81:	89 d8                	mov    %ebx,%eax
  800d83:	31 d2                	xor    %edx,%edx
  800d85:	f7 f5                	div    %ebp
  800d87:	89 f0                	mov    %esi,%eax
  800d89:	f7 f5                	div    %ebp
  800d8b:	89 d0                	mov    %edx,%eax
  800d8d:	31 d2                	xor    %edx,%edx
  800d8f:	eb 8c                	jmp    800d1d <__umoddi3+0x2d>
  800d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d98:	89 e9                	mov    %ebp,%ecx
  800d9a:	ba 20 00 00 00       	mov    $0x20,%edx
  800d9f:	29 ea                	sub    %ebp,%edx
  800da1:	d3 e0                	shl    %cl,%eax
  800da3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da7:	89 d1                	mov    %edx,%ecx
  800da9:	89 f8                	mov    %edi,%eax
  800dab:	d3 e8                	shr    %cl,%eax
  800dad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800db1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800db5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800db9:	09 c1                	or     %eax,%ecx
  800dbb:	89 d8                	mov    %ebx,%eax
  800dbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dc1:	89 e9                	mov    %ebp,%ecx
  800dc3:	d3 e7                	shl    %cl,%edi
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	d3 e8                	shr    %cl,%eax
  800dc9:	89 e9                	mov    %ebp,%ecx
  800dcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dcf:	d3 e3                	shl    %cl,%ebx
  800dd1:	89 c7                	mov    %eax,%edi
  800dd3:	89 d1                	mov    %edx,%ecx
  800dd5:	89 f0                	mov    %esi,%eax
  800dd7:	d3 e8                	shr    %cl,%eax
  800dd9:	89 e9                	mov    %ebp,%ecx
  800ddb:	89 fa                	mov    %edi,%edx
  800ddd:	d3 e6                	shl    %cl,%esi
  800ddf:	09 d8                	or     %ebx,%eax
  800de1:	f7 74 24 08          	divl   0x8(%esp)
  800de5:	89 d1                	mov    %edx,%ecx
  800de7:	89 f3                	mov    %esi,%ebx
  800de9:	f7 64 24 0c          	mull   0xc(%esp)
  800ded:	89 c6                	mov    %eax,%esi
  800def:	89 d7                	mov    %edx,%edi
  800df1:	39 d1                	cmp    %edx,%ecx
  800df3:	72 06                	jb     800dfb <__umoddi3+0x10b>
  800df5:	75 10                	jne    800e07 <__umoddi3+0x117>
  800df7:	39 c3                	cmp    %eax,%ebx
  800df9:	73 0c                	jae    800e07 <__umoddi3+0x117>
  800dfb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800dff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e03:	89 d7                	mov    %edx,%edi
  800e05:	89 c6                	mov    %eax,%esi
  800e07:	89 ca                	mov    %ecx,%edx
  800e09:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e0e:	29 f3                	sub    %esi,%ebx
  800e10:	19 fa                	sbb    %edi,%edx
  800e12:	89 d0                	mov    %edx,%eax
  800e14:	d3 e0                	shl    %cl,%eax
  800e16:	89 e9                	mov    %ebp,%ecx
  800e18:	d3 eb                	shr    %cl,%ebx
  800e1a:	d3 ea                	shr    %cl,%edx
  800e1c:	09 d8                	or     %ebx,%eax
  800e1e:	83 c4 1c             	add    $0x1c,%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    
  800e26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
  800e30:	29 fe                	sub    %edi,%esi
  800e32:	19 c3                	sbb    %eax,%ebx
  800e34:	89 f2                	mov    %esi,%edx
  800e36:	89 d9                	mov    %ebx,%ecx
  800e38:	e9 1d ff ff ff       	jmp    800d5a <__umoddi3+0x6a>
