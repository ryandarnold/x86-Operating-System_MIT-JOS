
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800044:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800047:	b8 01 00 00 00       	mov    $0x1,%eax
  80004c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800051:	99                   	cltd   
  800052:	f7 f9                	idiv   %ecx
  800054:	50                   	push   %eax
  800055:	68 50 0e 80 00       	push   $0x800e50
  80005a:	e8 0f 01 00 00       	call   80016e <cprintf>
}
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	c9                   	leave  
  800063:	c3                   	ret    

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	f3 0f 1e fb          	endbr32 
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800070:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800073:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80007a:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  80007d:	e8 f2 0a 00 00       	call   800b74 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  800082:	25 ff 03 00 00       	and    $0x3ff,%eax
  800087:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80008a:	c1 e0 05             	shl    $0x5,%eax
  80008d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800092:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800097:	85 db                	test   %ebx,%ebx
  800099:	7e 07                	jle    8000a2 <libmain+0x3e>
		binaryname = argv[0];
  80009b:	8b 06                	mov    (%esi),%eax
  80009d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a2:	83 ec 08             	sub    $0x8,%esp
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	e8 87 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ac:	e8 0a 00 00 00       	call   8000bb <exit>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bb:	f3 0f 1e fb          	endbr32 
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000c5:	6a 00                	push   $0x0
  8000c7:	e8 63 0a 00 00       	call   800b2f <sys_env_destroy>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d1:	f3 0f 1e fb          	endbr32 
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 04             	sub    $0x4,%esp
  8000dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000df:	8b 13                	mov    (%ebx),%edx
  8000e1:	8d 42 01             	lea    0x1(%edx),%eax
  8000e4:	89 03                	mov    %eax,(%ebx)
  8000e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f2:	74 09                	je     8000fd <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	68 ff 00 00 00       	push   $0xff
  800105:	8d 43 08             	lea    0x8(%ebx),%eax
  800108:	50                   	push   %eax
  800109:	e8 dc 09 00 00       	call   800aea <sys_cputs>
		b->idx = 0;
  80010e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	eb db                	jmp    8000f4 <putch+0x23>

00800119 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800119:	f3 0f 1e fb          	endbr32 
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800126:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012d:	00 00 00 
	b.cnt = 0;
  800130:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800137:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013a:	ff 75 0c             	pushl  0xc(%ebp)
  80013d:	ff 75 08             	pushl  0x8(%ebp)
  800140:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800146:	50                   	push   %eax
  800147:	68 d1 00 80 00       	push   $0x8000d1
  80014c:	e8 20 01 00 00       	call   800271 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800151:	83 c4 08             	add    $0x8,%esp
  800154:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800160:	50                   	push   %eax
  800161:	e8 84 09 00 00       	call   800aea <sys_cputs>

	return b.cnt;
}
  800166:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    

0080016e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016e:	f3 0f 1e fb          	endbr32 
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800178:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017b:	50                   	push   %eax
  80017c:	ff 75 08             	pushl  0x8(%ebp)
  80017f:	e8 95 ff ff ff       	call   800119 <vcprintf>
	va_end(ap);

	return cnt;
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	57                   	push   %edi
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
  80018c:	83 ec 1c             	sub    $0x1c,%esp
  80018f:	89 c7                	mov    %eax,%edi
  800191:	89 d6                	mov    %edx,%esi
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	8b 55 0c             	mov    0xc(%ebp),%edx
  800199:	89 d1                	mov    %edx,%ecx
  80019b:	89 c2                	mov    %eax,%edx
  80019d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b3:	39 c2                	cmp    %eax,%edx
  8001b5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b8:	72 3e                	jb     8001f8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	ff 75 18             	pushl  0x18(%ebp)
  8001c0:	83 eb 01             	sub    $0x1,%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	50                   	push   %eax
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d4:	e8 17 0a 00 00       	call   800bf0 <__udivdi3>
  8001d9:	83 c4 18             	add    $0x18,%esp
  8001dc:	52                   	push   %edx
  8001dd:	50                   	push   %eax
  8001de:	89 f2                	mov    %esi,%edx
  8001e0:	89 f8                	mov    %edi,%eax
  8001e2:	e8 9f ff ff ff       	call   800186 <printnum>
  8001e7:	83 c4 20             	add    $0x20,%esp
  8001ea:	eb 13                	jmp    8001ff <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	56                   	push   %esi
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	ff d7                	call   *%edi
  8001f5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	85 db                	test   %ebx,%ebx
  8001fd:	7f ed                	jg     8001ec <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	56                   	push   %esi
  800203:	83 ec 04             	sub    $0x4,%esp
  800206:	ff 75 e4             	pushl  -0x1c(%ebp)
  800209:	ff 75 e0             	pushl  -0x20(%ebp)
  80020c:	ff 75 dc             	pushl  -0x24(%ebp)
  80020f:	ff 75 d8             	pushl  -0x28(%ebp)
  800212:	e8 e9 0a 00 00       	call   800d00 <__umoddi3>
  800217:	83 c4 14             	add    $0x14,%esp
  80021a:	0f be 80 68 0e 80 00 	movsbl 0x800e68(%eax),%eax
  800221:	50                   	push   %eax
  800222:	ff d7                	call   *%edi
}
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80022f:	f3 0f 1e fb          	endbr32 
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800239:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023d:	8b 10                	mov    (%eax),%edx
  80023f:	3b 50 04             	cmp    0x4(%eax),%edx
  800242:	73 0a                	jae    80024e <sprintputch+0x1f>
		*b->buf++ = ch;
  800244:	8d 4a 01             	lea    0x1(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	88 02                	mov    %al,(%edx)
}
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <printfmt>:
{
  800250:	f3 0f 1e fb          	endbr32 
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80025a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025d:	50                   	push   %eax
  80025e:	ff 75 10             	pushl  0x10(%ebp)
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	ff 75 08             	pushl  0x8(%ebp)
  800267:	e8 05 00 00 00       	call   800271 <vprintfmt>
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <vprintfmt>:
{
  800271:	f3 0f 1e fb          	endbr32 
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	53                   	push   %ebx
  80027b:	83 ec 3c             	sub    $0x3c,%esp
  80027e:	8b 75 08             	mov    0x8(%ebp),%esi
  800281:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800284:	8b 7d 10             	mov    0x10(%ebp),%edi
  800287:	e9 8e 03 00 00       	jmp    80061a <vprintfmt+0x3a9>
		padc = ' ';
  80028c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800290:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800297:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80029e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002aa:	8d 47 01             	lea    0x1(%edi),%eax
  8002ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b0:	0f b6 17             	movzbl (%edi),%edx
  8002b3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b6:	3c 55                	cmp    $0x55,%al
  8002b8:	0f 87 df 03 00 00    	ja     80069d <vprintfmt+0x42c>
  8002be:	0f b6 c0             	movzbl %al,%eax
  8002c1:	3e ff 24 85 f8 0e 80 	notrack jmp *0x800ef8(,%eax,4)
  8002c8:	00 
  8002c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002cc:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002d0:	eb d8                	jmp    8002aa <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d5:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002d9:	eb cf                	jmp    8002aa <vprintfmt+0x39>
  8002db:	0f b6 d2             	movzbl %dl,%edx
  8002de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ec:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f6:	83 f9 09             	cmp    $0x9,%ecx
  8002f9:	77 55                	ja     800350 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002fb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002fe:	eb e9                	jmp    8002e9 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800300:	8b 45 14             	mov    0x14(%ebp),%eax
  800303:	8b 00                	mov    (%eax),%eax
  800305:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 40 04             	lea    0x4(%eax),%eax
  80030e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800314:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800318:	79 90                	jns    8002aa <vprintfmt+0x39>
				width = precision, precision = -1;
  80031a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80031d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800320:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800327:	eb 81                	jmp    8002aa <vprintfmt+0x39>
  800329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032c:	85 c0                	test   %eax,%eax
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	0f 49 d0             	cmovns %eax,%edx
  800336:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80033c:	e9 69 ff ff ff       	jmp    8002aa <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800344:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80034b:	e9 5a ff ff ff       	jmp    8002aa <vprintfmt+0x39>
  800350:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800353:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800356:	eb bc                	jmp    800314 <vprintfmt+0xa3>
			lflag++;
  800358:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80035e:	e9 47 ff ff ff       	jmp    8002aa <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800363:	8b 45 14             	mov    0x14(%ebp),%eax
  800366:	8d 78 04             	lea    0x4(%eax),%edi
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	53                   	push   %ebx
  80036d:	ff 30                	pushl  (%eax)
  80036f:	ff d6                	call   *%esi
			break;
  800371:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800374:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800377:	e9 9b 02 00 00       	jmp    800617 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 78 04             	lea    0x4(%eax),%edi
  800382:	8b 00                	mov    (%eax),%eax
  800384:	99                   	cltd   
  800385:	31 d0                	xor    %edx,%eax
  800387:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800389:	83 f8 06             	cmp    $0x6,%eax
  80038c:	7f 23                	jg     8003b1 <vprintfmt+0x140>
  80038e:	8b 14 85 50 10 80 00 	mov    0x801050(,%eax,4),%edx
  800395:	85 d2                	test   %edx,%edx
  800397:	74 18                	je     8003b1 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800399:	52                   	push   %edx
  80039a:	68 89 0e 80 00       	push   $0x800e89
  80039f:	53                   	push   %ebx
  8003a0:	56                   	push   %esi
  8003a1:	e8 aa fe ff ff       	call   800250 <printfmt>
  8003a6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a9:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003ac:	e9 66 02 00 00       	jmp    800617 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003b1:	50                   	push   %eax
  8003b2:	68 80 0e 80 00       	push   $0x800e80
  8003b7:	53                   	push   %ebx
  8003b8:	56                   	push   %esi
  8003b9:	e8 92 fe ff ff       	call   800250 <printfmt>
  8003be:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c1:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003c4:	e9 4e 02 00 00       	jmp    800617 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	83 c0 04             	add    $0x4,%eax
  8003cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003d7:	85 d2                	test   %edx,%edx
  8003d9:	b8 79 0e 80 00       	mov    $0x800e79,%eax
  8003de:	0f 45 c2             	cmovne %edx,%eax
  8003e1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e8:	7e 06                	jle    8003f0 <vprintfmt+0x17f>
  8003ea:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003ee:	75 0d                	jne    8003fd <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003f3:	89 c7                	mov    %eax,%edi
  8003f5:	03 45 e0             	add    -0x20(%ebp),%eax
  8003f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fb:	eb 55                	jmp    800452 <vprintfmt+0x1e1>
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	ff 75 d8             	pushl  -0x28(%ebp)
  800403:	ff 75 cc             	pushl  -0x34(%ebp)
  800406:	e8 46 03 00 00       	call   800751 <strnlen>
  80040b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80040e:	29 c2                	sub    %eax,%edx
  800410:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800413:	83 c4 10             	add    $0x10,%esp
  800416:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800418:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80041c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80041f:	85 ff                	test   %edi,%edi
  800421:	7e 11                	jle    800434 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	53                   	push   %ebx
  800427:	ff 75 e0             	pushl  -0x20(%ebp)
  80042a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80042c:	83 ef 01             	sub    $0x1,%edi
  80042f:	83 c4 10             	add    $0x10,%esp
  800432:	eb eb                	jmp    80041f <vprintfmt+0x1ae>
  800434:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800437:	85 d2                	test   %edx,%edx
  800439:	b8 00 00 00 00       	mov    $0x0,%eax
  80043e:	0f 49 c2             	cmovns %edx,%eax
  800441:	29 c2                	sub    %eax,%edx
  800443:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800446:	eb a8                	jmp    8003f0 <vprintfmt+0x17f>
					putch(ch, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	53                   	push   %ebx
  80044c:	52                   	push   %edx
  80044d:	ff d6                	call   *%esi
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800455:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800457:	83 c7 01             	add    $0x1,%edi
  80045a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80045e:	0f be d0             	movsbl %al,%edx
  800461:	85 d2                	test   %edx,%edx
  800463:	74 4b                	je     8004b0 <vprintfmt+0x23f>
  800465:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800469:	78 06                	js     800471 <vprintfmt+0x200>
  80046b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80046f:	78 1e                	js     80048f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800471:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800475:	74 d1                	je     800448 <vprintfmt+0x1d7>
  800477:	0f be c0             	movsbl %al,%eax
  80047a:	83 e8 20             	sub    $0x20,%eax
  80047d:	83 f8 5e             	cmp    $0x5e,%eax
  800480:	76 c6                	jbe    800448 <vprintfmt+0x1d7>
					putch('?', putdat);
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	53                   	push   %ebx
  800486:	6a 3f                	push   $0x3f
  800488:	ff d6                	call   *%esi
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb c3                	jmp    800452 <vprintfmt+0x1e1>
  80048f:	89 cf                	mov    %ecx,%edi
  800491:	eb 0e                	jmp    8004a1 <vprintfmt+0x230>
				putch(' ', putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	53                   	push   %ebx
  800497:	6a 20                	push   $0x20
  800499:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80049b:	83 ef 01             	sub    $0x1,%edi
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	85 ff                	test   %edi,%edi
  8004a3:	7f ee                	jg     800493 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ab:	e9 67 01 00 00       	jmp    800617 <vprintfmt+0x3a6>
  8004b0:	89 cf                	mov    %ecx,%edi
  8004b2:	eb ed                	jmp    8004a1 <vprintfmt+0x230>
	if (lflag >= 2)
  8004b4:	83 f9 01             	cmp    $0x1,%ecx
  8004b7:	7f 1b                	jg     8004d4 <vprintfmt+0x263>
	else if (lflag)
  8004b9:	85 c9                	test   %ecx,%ecx
  8004bb:	74 63                	je     800520 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8b 00                	mov    (%eax),%eax
  8004c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c5:	99                   	cltd   
  8004c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 40 04             	lea    0x4(%eax),%eax
  8004cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d2:	eb 17                	jmp    8004eb <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8b 50 04             	mov    0x4(%eax),%edx
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 40 08             	lea    0x8(%eax),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004f1:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004f6:	85 c9                	test   %ecx,%ecx
  8004f8:	0f 89 ff 00 00 00    	jns    8005fd <vprintfmt+0x38c>
				putch('-', putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	53                   	push   %ebx
  800502:	6a 2d                	push   $0x2d
  800504:	ff d6                	call   *%esi
				num = -(long long) num;
  800506:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800509:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050c:	f7 da                	neg    %edx
  80050e:	83 d1 00             	adc    $0x0,%ecx
  800511:	f7 d9                	neg    %ecx
  800513:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800516:	b8 0a 00 00 00       	mov    $0xa,%eax
  80051b:	e9 dd 00 00 00       	jmp    8005fd <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8b 00                	mov    (%eax),%eax
  800525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800528:	99                   	cltd   
  800529:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 40 04             	lea    0x4(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
  800535:	eb b4                	jmp    8004eb <vprintfmt+0x27a>
	if (lflag >= 2)
  800537:	83 f9 01             	cmp    $0x1,%ecx
  80053a:	7f 1e                	jg     80055a <vprintfmt+0x2e9>
	else if (lflag)
  80053c:	85 c9                	test   %ecx,%ecx
  80053e:	74 32                	je     800572 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8b 10                	mov    (%eax),%edx
  800545:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054a:	8d 40 04             	lea    0x4(%eax),%eax
  80054d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800550:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800555:	e9 a3 00 00 00       	jmp    8005fd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8b 10                	mov    (%eax),%edx
  80055f:	8b 48 04             	mov    0x4(%eax),%ecx
  800562:	8d 40 08             	lea    0x8(%eax),%eax
  800565:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800568:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80056d:	e9 8b 00 00 00       	jmp    8005fd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 10                	mov    (%eax),%edx
  800577:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800582:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800587:	eb 74                	jmp    8005fd <vprintfmt+0x38c>
	if (lflag >= 2)
  800589:	83 f9 01             	cmp    $0x1,%ecx
  80058c:	7f 1b                	jg     8005a9 <vprintfmt+0x338>
	else if (lflag)
  80058e:	85 c9                	test   %ecx,%ecx
  800590:	74 2c                	je     8005be <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005a2:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005a7:	eb 54                	jmp    8005fd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b1:	8d 40 08             	lea    0x8(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005b7:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005bc:	eb 3f                	jmp    8005fd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c8:	8d 40 04             	lea    0x4(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005ce:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005d3:	eb 28                	jmp    8005fd <vprintfmt+0x38c>
			putch('0', putdat);
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	6a 30                	push   $0x30
  8005db:	ff d6                	call   *%esi
			putch('x', putdat);
  8005dd:	83 c4 08             	add    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	6a 78                	push   $0x78
  8005e3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005ef:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800604:	57                   	push   %edi
  800605:	ff 75 e0             	pushl  -0x20(%ebp)
  800608:	50                   	push   %eax
  800609:	51                   	push   %ecx
  80060a:	52                   	push   %edx
  80060b:	89 da                	mov    %ebx,%edx
  80060d:	89 f0                	mov    %esi,%eax
  80060f:	e8 72 fb ff ff       	call   800186 <printnum>
			break;
  800614:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80061a:	83 c7 01             	add    $0x1,%edi
  80061d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800621:	83 f8 25             	cmp    $0x25,%eax
  800624:	0f 84 62 fc ff ff    	je     80028c <vprintfmt+0x1b>
			if (ch == '\0')
  80062a:	85 c0                	test   %eax,%eax
  80062c:	0f 84 8b 00 00 00    	je     8006bd <vprintfmt+0x44c>
			putch(ch, putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	50                   	push   %eax
  800637:	ff d6                	call   *%esi
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb dc                	jmp    80061a <vprintfmt+0x3a9>
	if (lflag >= 2)
  80063e:	83 f9 01             	cmp    $0x1,%ecx
  800641:	7f 1b                	jg     80065e <vprintfmt+0x3ed>
	else if (lflag)
  800643:	85 c9                	test   %ecx,%ecx
  800645:	74 2c                	je     800673 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 10                	mov    (%eax),%edx
  80064c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800651:	8d 40 04             	lea    0x4(%eax),%eax
  800654:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800657:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80065c:	eb 9f                	jmp    8005fd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	8b 48 04             	mov    0x4(%eax),%ecx
  800666:	8d 40 08             	lea    0x8(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800671:	eb 8a                	jmp    8005fd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800688:	e9 70 ff ff ff       	jmp    8005fd <vprintfmt+0x38c>
			putch(ch, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 25                	push   $0x25
  800693:	ff d6                	call   *%esi
			break;
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	e9 7a ff ff ff       	jmp    800617 <vprintfmt+0x3a6>
			putch('%', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 25                	push   $0x25
  8006a3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	89 f8                	mov    %edi,%eax
  8006aa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ae:	74 05                	je     8006b5 <vprintfmt+0x444>
  8006b0:	83 e8 01             	sub    $0x1,%eax
  8006b3:	eb f5                	jmp    8006aa <vprintfmt+0x439>
  8006b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b8:	e9 5a ff ff ff       	jmp    800617 <vprintfmt+0x3a6>
}
  8006bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5f                   	pop    %edi
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c5:	f3 0f 1e fb          	endbr32 
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 18             	sub    $0x18,%esp
  8006cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006dc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	74 26                	je     800710 <vsnprintf+0x4b>
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	7e 22                	jle    800710 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ee:	ff 75 14             	pushl  0x14(%ebp)
  8006f1:	ff 75 10             	pushl  0x10(%ebp)
  8006f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f7:	50                   	push   %eax
  8006f8:	68 2f 02 80 00       	push   $0x80022f
  8006fd:	e8 6f fb ff ff       	call   800271 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800702:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800705:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070b:	83 c4 10             	add    $0x10,%esp
}
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    
		return -E_INVAL;
  800710:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800715:	eb f7                	jmp    80070e <vsnprintf+0x49>

00800717 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800717:	f3 0f 1e fb          	endbr32 
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800721:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800724:	50                   	push   %eax
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	ff 75 08             	pushl  0x8(%ebp)
  80072e:	e8 92 ff ff ff       	call   8006c5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800735:	f3 0f 1e fb          	endbr32 
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800748:	74 05                	je     80074f <strlen+0x1a>
		n++;
  80074a:	83 c0 01             	add    $0x1,%eax
  80074d:	eb f5                	jmp    800744 <strlen+0xf>
	return n;
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800751:	f3 0f 1e fb          	endbr32 
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	39 d0                	cmp    %edx,%eax
  800765:	74 0d                	je     800774 <strnlen+0x23>
  800767:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076b:	74 05                	je     800772 <strnlen+0x21>
		n++;
  80076d:	83 c0 01             	add    $0x1,%eax
  800770:	eb f1                	jmp    800763 <strnlen+0x12>
  800772:	89 c2                	mov    %eax,%edx
	return n;
}
  800774:	89 d0                	mov    %edx,%eax
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800778:	f3 0f 1e fb          	endbr32 
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	53                   	push   %ebx
  800780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80078f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800792:	83 c0 01             	add    $0x1,%eax
  800795:	84 d2                	test   %dl,%dl
  800797:	75 f2                	jne    80078b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800799:	89 c8                	mov    %ecx,%eax
  80079b:	5b                   	pop    %ebx
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079e:	f3 0f 1e fb          	endbr32 
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	83 ec 10             	sub    $0x10,%esp
  8007a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ac:	53                   	push   %ebx
  8007ad:	e8 83 ff ff ff       	call   800735 <strlen>
  8007b2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	01 d8                	add    %ebx,%eax
  8007ba:	50                   	push   %eax
  8007bb:	e8 b8 ff ff ff       	call   800778 <strcpy>
	return dst;
}
  8007c0:	89 d8                	mov    %ebx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c7:	f3 0f 1e fb          	endbr32 
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	89 f3                	mov    %esi,%ebx
  8007d8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007db:	89 f0                	mov    %esi,%eax
  8007dd:	39 d8                	cmp    %ebx,%eax
  8007df:	74 11                	je     8007f2 <strncpy+0x2b>
		*dst++ = *src;
  8007e1:	83 c0 01             	add    $0x1,%eax
  8007e4:	0f b6 0a             	movzbl (%edx),%ecx
  8007e7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ea:	80 f9 01             	cmp    $0x1,%cl
  8007ed:	83 da ff             	sbb    $0xffffffff,%edx
  8007f0:	eb eb                	jmp    8007dd <strncpy+0x16>
	}
	return ret;
}
  8007f2:	89 f0                	mov    %esi,%eax
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f8:	f3 0f 1e fb          	endbr32 
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	8b 75 08             	mov    0x8(%ebp),%esi
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800807:	8b 55 10             	mov    0x10(%ebp),%edx
  80080a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080c:	85 d2                	test   %edx,%edx
  80080e:	74 21                	je     800831 <strlcpy+0x39>
  800810:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800814:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800816:	39 c2                	cmp    %eax,%edx
  800818:	74 14                	je     80082e <strlcpy+0x36>
  80081a:	0f b6 19             	movzbl (%ecx),%ebx
  80081d:	84 db                	test   %bl,%bl
  80081f:	74 0b                	je     80082c <strlcpy+0x34>
			*dst++ = *src++;
  800821:	83 c1 01             	add    $0x1,%ecx
  800824:	83 c2 01             	add    $0x1,%edx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082a:	eb ea                	jmp    800816 <strlcpy+0x1e>
  80082c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80082e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800831:	29 f0                	sub    %esi,%eax
}
  800833:	5b                   	pop    %ebx
  800834:	5e                   	pop    %esi
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800837:	f3 0f 1e fb          	endbr32 
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800844:	0f b6 01             	movzbl (%ecx),%eax
  800847:	84 c0                	test   %al,%al
  800849:	74 0c                	je     800857 <strcmp+0x20>
  80084b:	3a 02                	cmp    (%edx),%al
  80084d:	75 08                	jne    800857 <strcmp+0x20>
		p++, q++;
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	83 c2 01             	add    $0x1,%edx
  800855:	eb ed                	jmp    800844 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 c0             	movzbl %al,%eax
  80085a:	0f b6 12             	movzbl (%edx),%edx
  80085d:	29 d0                	sub    %edx,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800861:	f3 0f 1e fb          	endbr32 
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086f:	89 c3                	mov    %eax,%ebx
  800871:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800874:	eb 06                	jmp    80087c <strncmp+0x1b>
		n--, p++, q++;
  800876:	83 c0 01             	add    $0x1,%eax
  800879:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80087c:	39 d8                	cmp    %ebx,%eax
  80087e:	74 16                	je     800896 <strncmp+0x35>
  800880:	0f b6 08             	movzbl (%eax),%ecx
  800883:	84 c9                	test   %cl,%cl
  800885:	74 04                	je     80088b <strncmp+0x2a>
  800887:	3a 0a                	cmp    (%edx),%cl
  800889:	74 eb                	je     800876 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 00             	movzbl (%eax),%eax
  80088e:	0f b6 12             	movzbl (%edx),%edx
  800891:	29 d0                	sub    %edx,%eax
}
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    
		return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	eb f6                	jmp    800893 <strncmp+0x32>

0080089d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089d:	f3 0f 1e fb          	endbr32 
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ab:	0f b6 10             	movzbl (%eax),%edx
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	74 09                	je     8008bb <strchr+0x1e>
		if (*s == c)
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 0a                	je     8008c0 <strchr+0x23>
	for (; *s; s++)
  8008b6:	83 c0 01             	add    $0x1,%eax
  8008b9:	eb f0                	jmp    8008ab <strchr+0xe>
			return (char *) s;
	return 0;
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c2:	f3 0f 1e fb          	endbr32 
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	74 09                	je     8008e0 <strfind+0x1e>
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	74 05                	je     8008e0 <strfind+0x1e>
	for (; *s; s++)
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	eb f0                	jmp    8008d0 <strfind+0xe>
			break;
	return (char *) s;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e2:	f3 0f 1e fb          	endbr32 
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	57                   	push   %edi
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
  8008ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f2:	85 c9                	test   %ecx,%ecx
  8008f4:	74 31                	je     800927 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f6:	89 f8                	mov    %edi,%eax
  8008f8:	09 c8                	or     %ecx,%eax
  8008fa:	a8 03                	test   $0x3,%al
  8008fc:	75 23                	jne    800921 <memset+0x3f>
		c &= 0xFF;
  8008fe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800902:	89 d3                	mov    %edx,%ebx
  800904:	c1 e3 08             	shl    $0x8,%ebx
  800907:	89 d0                	mov    %edx,%eax
  800909:	c1 e0 18             	shl    $0x18,%eax
  80090c:	89 d6                	mov    %edx,%esi
  80090e:	c1 e6 10             	shl    $0x10,%esi
  800911:	09 f0                	or     %esi,%eax
  800913:	09 c2                	or     %eax,%edx
  800915:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800917:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80091a:	89 d0                	mov    %edx,%eax
  80091c:	fc                   	cld    
  80091d:	f3 ab                	rep stos %eax,%es:(%edi)
  80091f:	eb 06                	jmp    800927 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800921:	8b 45 0c             	mov    0xc(%ebp),%eax
  800924:	fc                   	cld    
  800925:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800927:	89 f8                	mov    %edi,%eax
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5f                   	pop    %edi
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092e:	f3 0f 1e fb          	endbr32 
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	57                   	push   %edi
  800936:	56                   	push   %esi
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800940:	39 c6                	cmp    %eax,%esi
  800942:	73 32                	jae    800976 <memmove+0x48>
  800944:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800947:	39 c2                	cmp    %eax,%edx
  800949:	76 2b                	jbe    800976 <memmove+0x48>
		s += n;
		d += n;
  80094b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094e:	89 fe                	mov    %edi,%esi
  800950:	09 ce                	or     %ecx,%esi
  800952:	09 d6                	or     %edx,%esi
  800954:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095a:	75 0e                	jne    80096a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095c:	83 ef 04             	sub    $0x4,%edi
  80095f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800962:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800965:	fd                   	std    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 09                	jmp    800973 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096a:	83 ef 01             	sub    $0x1,%edi
  80096d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800970:	fd                   	std    
  800971:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800973:	fc                   	cld    
  800974:	eb 1a                	jmp    800990 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	89 c2                	mov    %eax,%edx
  800978:	09 ca                	or     %ecx,%edx
  80097a:	09 f2                	or     %esi,%edx
  80097c:	f6 c2 03             	test   $0x3,%dl
  80097f:	75 0a                	jne    80098b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800981:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 05                	jmp    800990 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80098b:	89 c7                	mov    %eax,%edi
  80098d:	fc                   	cld    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800994:	f3 0f 1e fb          	endbr32 
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099e:	ff 75 10             	pushl  0x10(%ebp)
  8009a1:	ff 75 0c             	pushl  0xc(%ebp)
  8009a4:	ff 75 08             	pushl  0x8(%ebp)
  8009a7:	e8 82 ff ff ff       	call   80092e <memmove>
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ae:	f3 0f 1e fb          	endbr32 
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bd:	89 c6                	mov    %eax,%esi
  8009bf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c2:	39 f0                	cmp    %esi,%eax
  8009c4:	74 1c                	je     8009e2 <memcmp+0x34>
		if (*s1 != *s2)
  8009c6:	0f b6 08             	movzbl (%eax),%ecx
  8009c9:	0f b6 1a             	movzbl (%edx),%ebx
  8009cc:	38 d9                	cmp    %bl,%cl
  8009ce:	75 08                	jne    8009d8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d0:	83 c0 01             	add    $0x1,%eax
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	eb ea                	jmp    8009c2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009d8:	0f b6 c1             	movzbl %cl,%eax
  8009db:	0f b6 db             	movzbl %bl,%ebx
  8009de:	29 d8                	sub    %ebx,%eax
  8009e0:	eb 05                	jmp    8009e7 <memcmp+0x39>
	}

	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009eb:	f3 0f 1e fb          	endbr32 
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f8:	89 c2                	mov    %eax,%edx
  8009fa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	73 09                	jae    800a0a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a01:	38 08                	cmp    %cl,(%eax)
  800a03:	74 05                	je     800a0a <memfind+0x1f>
	for (; s < ends; s++)
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	eb f3                	jmp    8009fd <memfind+0x12>
			break;
	return (void *) s;
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0c:	f3 0f 1e fb          	endbr32 
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1c:	eb 03                	jmp    800a21 <strtol+0x15>
		s++;
  800a1e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a21:	0f b6 01             	movzbl (%ecx),%eax
  800a24:	3c 20                	cmp    $0x20,%al
  800a26:	74 f6                	je     800a1e <strtol+0x12>
  800a28:	3c 09                	cmp    $0x9,%al
  800a2a:	74 f2                	je     800a1e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a2c:	3c 2b                	cmp    $0x2b,%al
  800a2e:	74 2a                	je     800a5a <strtol+0x4e>
	int neg = 0;
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a35:	3c 2d                	cmp    $0x2d,%al
  800a37:	74 2b                	je     800a64 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a39:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3f:	75 0f                	jne    800a50 <strtol+0x44>
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	74 28                	je     800a6e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a46:	85 db                	test   %ebx,%ebx
  800a48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a4d:	0f 44 d8             	cmove  %eax,%ebx
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a58:	eb 46                	jmp    800aa0 <strtol+0x94>
		s++;
  800a5a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a62:	eb d5                	jmp    800a39 <strtol+0x2d>
		s++, neg = 1;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6c:	eb cb                	jmp    800a39 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a72:	74 0e                	je     800a82 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	75 d8                	jne    800a50 <strtol+0x44>
		s++, base = 8;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a80:	eb ce                	jmp    800a50 <strtol+0x44>
		s += 2, base = 16;
  800a82:	83 c1 02             	add    $0x2,%ecx
  800a85:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8a:	eb c4                	jmp    800a50 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a8c:	0f be d2             	movsbl %dl,%edx
  800a8f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a92:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a95:	7d 3a                	jge    800ad1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa0:	0f b6 11             	movzbl (%ecx),%edx
  800aa3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 09             	cmp    $0x9,%bl
  800aab:	76 df                	jbe    800a8c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aad:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 08                	ja     800abf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 57             	sub    $0x57,%edx
  800abd:	eb d3                	jmp    800a92 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800abf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 19             	cmp    $0x19,%bl
  800ac7:	77 08                	ja     800ad1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 37             	sub    $0x37,%edx
  800acf:	eb c1                	jmp    800a92 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 05                	je     800adc <strtol+0xd0>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800adc:	89 c2                	mov    %eax,%edx
  800ade:	f7 da                	neg    %edx
  800ae0:	85 ff                	test   %edi,%edi
  800ae2:	0f 45 c2             	cmovne %edx,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aea:	f3 0f 1e fb          	endbr32 
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	89 c7                	mov    %eax,%edi
  800b03:	89 c6                	mov    %eax,%esi
  800b05:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0c:	f3 0f 1e fb          	endbr32 
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	f3 0f 1e fb          	endbr32 
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b41:	8b 55 08             	mov    0x8(%ebp),%edx
  800b44:	b8 03 00 00 00       	mov    $0x3,%eax
  800b49:	89 cb                	mov    %ecx,%ebx
  800b4b:	89 cf                	mov    %ecx,%edi
  800b4d:	89 ce                	mov    %ecx,%esi
  800b4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	7f 08                	jg     800b5d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 03                	push   $0x3
  800b63:	68 6c 10 80 00       	push   $0x80106c
  800b68:	6a 23                	push   $0x23
  800b6a:	68 89 10 80 00       	push   $0x801089
  800b6f:	e8 23 00 00 00       	call   800b97 <_panic>

00800b74 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b74:	f3 0f 1e fb          	endbr32 
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 02 00 00 00       	mov    $0x2,%eax
  800b88:	89 d1                	mov    %edx,%ecx
  800b8a:	89 d3                	mov    %edx,%ebx
  800b8c:	89 d7                	mov    %edx,%edi
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b97:	f3 0f 1e fb          	endbr32 
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ba0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ba3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ba9:	e8 c6 ff ff ff       	call   800b74 <sys_getenvid>
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	ff 75 0c             	pushl  0xc(%ebp)
  800bb4:	ff 75 08             	pushl  0x8(%ebp)
  800bb7:	56                   	push   %esi
  800bb8:	50                   	push   %eax
  800bb9:	68 98 10 80 00       	push   $0x801098
  800bbe:	e8 ab f5 ff ff       	call   80016e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bc3:	83 c4 18             	add    $0x18,%esp
  800bc6:	53                   	push   %ebx
  800bc7:	ff 75 10             	pushl  0x10(%ebp)
  800bca:	e8 4a f5 ff ff       	call   800119 <vcprintf>
	cprintf("\n");
  800bcf:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  800bd6:	e8 93 f5 ff ff       	call   80016e <cprintf>
  800bdb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bde:	cc                   	int3   
  800bdf:	eb fd                	jmp    800bde <_panic+0x47>
  800be1:	66 90                	xchg   %ax,%ax
  800be3:	66 90                	xchg   %ax,%ax
  800be5:	66 90                	xchg   %ax,%ax
  800be7:	66 90                	xchg   %ax,%ax
  800be9:	66 90                	xchg   %ax,%ax
  800beb:	66 90                	xchg   %ax,%ax
  800bed:	66 90                	xchg   %ax,%ax
  800bef:	90                   	nop

00800bf0 <__udivdi3>:
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 1c             	sub    $0x1c,%esp
  800bfb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800bff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c0b:	85 d2                	test   %edx,%edx
  800c0d:	75 19                	jne    800c28 <__udivdi3+0x38>
  800c0f:	39 f3                	cmp    %esi,%ebx
  800c11:	76 4d                	jbe    800c60 <__udivdi3+0x70>
  800c13:	31 ff                	xor    %edi,%edi
  800c15:	89 e8                	mov    %ebp,%eax
  800c17:	89 f2                	mov    %esi,%edx
  800c19:	f7 f3                	div    %ebx
  800c1b:	89 fa                	mov    %edi,%edx
  800c1d:	83 c4 1c             	add    $0x1c,%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    
  800c25:	8d 76 00             	lea    0x0(%esi),%esi
  800c28:	39 f2                	cmp    %esi,%edx
  800c2a:	76 14                	jbe    800c40 <__udivdi3+0x50>
  800c2c:	31 ff                	xor    %edi,%edi
  800c2e:	31 c0                	xor    %eax,%eax
  800c30:	89 fa                	mov    %edi,%edx
  800c32:	83 c4 1c             	add    $0x1c,%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    
  800c3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c40:	0f bd fa             	bsr    %edx,%edi
  800c43:	83 f7 1f             	xor    $0x1f,%edi
  800c46:	75 48                	jne    800c90 <__udivdi3+0xa0>
  800c48:	39 f2                	cmp    %esi,%edx
  800c4a:	72 06                	jb     800c52 <__udivdi3+0x62>
  800c4c:	31 c0                	xor    %eax,%eax
  800c4e:	39 eb                	cmp    %ebp,%ebx
  800c50:	77 de                	ja     800c30 <__udivdi3+0x40>
  800c52:	b8 01 00 00 00       	mov    $0x1,%eax
  800c57:	eb d7                	jmp    800c30 <__udivdi3+0x40>
  800c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c60:	89 d9                	mov    %ebx,%ecx
  800c62:	85 db                	test   %ebx,%ebx
  800c64:	75 0b                	jne    800c71 <__udivdi3+0x81>
  800c66:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6b:	31 d2                	xor    %edx,%edx
  800c6d:	f7 f3                	div    %ebx
  800c6f:	89 c1                	mov    %eax,%ecx
  800c71:	31 d2                	xor    %edx,%edx
  800c73:	89 f0                	mov    %esi,%eax
  800c75:	f7 f1                	div    %ecx
  800c77:	89 c6                	mov    %eax,%esi
  800c79:	89 e8                	mov    %ebp,%eax
  800c7b:	89 f7                	mov    %esi,%edi
  800c7d:	f7 f1                	div    %ecx
  800c7f:	89 fa                	mov    %edi,%edx
  800c81:	83 c4 1c             	add    $0x1c,%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
  800c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	b8 20 00 00 00       	mov    $0x20,%eax
  800c97:	29 f8                	sub    %edi,%eax
  800c99:	d3 e2                	shl    %cl,%edx
  800c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	89 da                	mov    %ebx,%edx
  800ca3:	d3 ea                	shr    %cl,%edx
  800ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ca9:	09 d1                	or     %edx,%ecx
  800cab:	89 f2                	mov    %esi,%edx
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f9                	mov    %edi,%ecx
  800cb3:	d3 e3                	shl    %cl,%ebx
  800cb5:	89 c1                	mov    %eax,%ecx
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cbf:	89 eb                	mov    %ebp,%ebx
  800cc1:	d3 e6                	shl    %cl,%esi
  800cc3:	89 c1                	mov    %eax,%ecx
  800cc5:	d3 eb                	shr    %cl,%ebx
  800cc7:	09 de                	or     %ebx,%esi
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	f7 74 24 08          	divl   0x8(%esp)
  800ccf:	89 d6                	mov    %edx,%esi
  800cd1:	89 c3                	mov    %eax,%ebx
  800cd3:	f7 64 24 0c          	mull   0xc(%esp)
  800cd7:	39 d6                	cmp    %edx,%esi
  800cd9:	72 15                	jb     800cf0 <__udivdi3+0x100>
  800cdb:	89 f9                	mov    %edi,%ecx
  800cdd:	d3 e5                	shl    %cl,%ebp
  800cdf:	39 c5                	cmp    %eax,%ebp
  800ce1:	73 04                	jae    800ce7 <__udivdi3+0xf7>
  800ce3:	39 d6                	cmp    %edx,%esi
  800ce5:	74 09                	je     800cf0 <__udivdi3+0x100>
  800ce7:	89 d8                	mov    %ebx,%eax
  800ce9:	31 ff                	xor    %edi,%edi
  800ceb:	e9 40 ff ff ff       	jmp    800c30 <__udivdi3+0x40>
  800cf0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cf3:	31 ff                	xor    %edi,%edi
  800cf5:	e9 36 ff ff ff       	jmp    800c30 <__udivdi3+0x40>
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__umoddi3>:
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 1c             	sub    $0x1c,%esp
  800d0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	75 19                	jne    800d38 <__umoddi3+0x38>
  800d1f:	39 df                	cmp    %ebx,%edi
  800d21:	76 5d                	jbe    800d80 <__umoddi3+0x80>
  800d23:	89 f0                	mov    %esi,%eax
  800d25:	89 da                	mov    %ebx,%edx
  800d27:	f7 f7                	div    %edi
  800d29:	89 d0                	mov    %edx,%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	83 c4 1c             	add    $0x1c,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
  800d35:	8d 76 00             	lea    0x0(%esi),%esi
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	39 d8                	cmp    %ebx,%eax
  800d3c:	76 12                	jbe    800d50 <__umoddi3+0x50>
  800d3e:	89 f0                	mov    %esi,%eax
  800d40:	89 da                	mov    %ebx,%edx
  800d42:	83 c4 1c             	add    $0x1c,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
  800d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d50:	0f bd e8             	bsr    %eax,%ebp
  800d53:	83 f5 1f             	xor    $0x1f,%ebp
  800d56:	75 50                	jne    800da8 <__umoddi3+0xa8>
  800d58:	39 d8                	cmp    %ebx,%eax
  800d5a:	0f 82 e0 00 00 00    	jb     800e40 <__umoddi3+0x140>
  800d60:	89 d9                	mov    %ebx,%ecx
  800d62:	39 f7                	cmp    %esi,%edi
  800d64:	0f 86 d6 00 00 00    	jbe    800e40 <__umoddi3+0x140>
  800d6a:	89 d0                	mov    %edx,%eax
  800d6c:	89 ca                	mov    %ecx,%edx
  800d6e:	83 c4 1c             	add    $0x1c,%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
  800d76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
  800d80:	89 fd                	mov    %edi,%ebp
  800d82:	85 ff                	test   %edi,%edi
  800d84:	75 0b                	jne    800d91 <__umoddi3+0x91>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f7                	div    %edi
  800d8f:	89 c5                	mov    %eax,%ebp
  800d91:	89 d8                	mov    %ebx,%eax
  800d93:	31 d2                	xor    %edx,%edx
  800d95:	f7 f5                	div    %ebp
  800d97:	89 f0                	mov    %esi,%eax
  800d99:	f7 f5                	div    %ebp
  800d9b:	89 d0                	mov    %edx,%eax
  800d9d:	31 d2                	xor    %edx,%edx
  800d9f:	eb 8c                	jmp    800d2d <__umoddi3+0x2d>
  800da1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da8:	89 e9                	mov    %ebp,%ecx
  800daa:	ba 20 00 00 00       	mov    $0x20,%edx
  800daf:	29 ea                	sub    %ebp,%edx
  800db1:	d3 e0                	shl    %cl,%eax
  800db3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db7:	89 d1                	mov    %edx,%ecx
  800db9:	89 f8                	mov    %edi,%eax
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dc5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800dc9:	09 c1                	or     %eax,%ecx
  800dcb:	89 d8                	mov    %ebx,%eax
  800dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dd1:	89 e9                	mov    %ebp,%ecx
  800dd3:	d3 e7                	shl    %cl,%edi
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	d3 e8                	shr    %cl,%eax
  800dd9:	89 e9                	mov    %ebp,%ecx
  800ddb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ddf:	d3 e3                	shl    %cl,%ebx
  800de1:	89 c7                	mov    %eax,%edi
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	89 f0                	mov    %esi,%eax
  800de7:	d3 e8                	shr    %cl,%eax
  800de9:	89 e9                	mov    %ebp,%ecx
  800deb:	89 fa                	mov    %edi,%edx
  800ded:	d3 e6                	shl    %cl,%esi
  800def:	09 d8                	or     %ebx,%eax
  800df1:	f7 74 24 08          	divl   0x8(%esp)
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 f3                	mov    %esi,%ebx
  800df9:	f7 64 24 0c          	mull   0xc(%esp)
  800dfd:	89 c6                	mov    %eax,%esi
  800dff:	89 d7                	mov    %edx,%edi
  800e01:	39 d1                	cmp    %edx,%ecx
  800e03:	72 06                	jb     800e0b <__umoddi3+0x10b>
  800e05:	75 10                	jne    800e17 <__umoddi3+0x117>
  800e07:	39 c3                	cmp    %eax,%ebx
  800e09:	73 0c                	jae    800e17 <__umoddi3+0x117>
  800e0b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800e0f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e13:	89 d7                	mov    %edx,%edi
  800e15:	89 c6                	mov    %eax,%esi
  800e17:	89 ca                	mov    %ecx,%edx
  800e19:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e1e:	29 f3                	sub    %esi,%ebx
  800e20:	19 fa                	sbb    %edi,%edx
  800e22:	89 d0                	mov    %edx,%eax
  800e24:	d3 e0                	shl    %cl,%eax
  800e26:	89 e9                	mov    %ebp,%ecx
  800e28:	d3 eb                	shr    %cl,%ebx
  800e2a:	d3 ea                	shr    %cl,%edx
  800e2c:	09 d8                	or     %ebx,%eax
  800e2e:	83 c4 1c             	add    $0x1c,%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
  800e36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e3d:	8d 76 00             	lea    0x0(%esi),%esi
  800e40:	29 fe                	sub    %edi,%esi
  800e42:	19 c3                	sbb    %eax,%ebx
  800e44:	89 f2                	mov    %esi,%edx
  800e46:	89 d9                	mov    %ebx,%ecx
  800e48:	e9 1d ff ff ff       	jmp    800d6a <__umoddi3+0x6a>
