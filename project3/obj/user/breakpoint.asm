
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	f3 0f 1e fb          	endbr32 
  80003d:	55                   	push   %ebp
  80003e:	89 e5                	mov    %esp,%ebp
  800040:	56                   	push   %esi
  800041:	53                   	push   %ebx
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800048:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004f:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  800052:	e8 d9 00 00 00       	call   800130 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005f:	c1 e0 05             	shl    $0x5,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x3e>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	f3 0f 1e fb          	endbr32 
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 4a 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	f3 0f 1e fb          	endbr32 
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	f3 0f 1e fb          	endbr32 
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	f3 0f 1e fb          	endbr32 
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	57                   	push   %edi
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
  8000f5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800100:	b8 03 00 00 00       	mov    $0x3,%eax
  800105:	89 cb                	mov    %ecx,%ebx
  800107:	89 cf                	mov    %ecx,%edi
  800109:	89 ce                	mov    %ecx,%esi
  80010b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010d:	85 c0                	test   %eax,%eax
  80010f:	7f 08                	jg     800119 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	50                   	push   %eax
  80011d:	6a 03                	push   $0x3
  80011f:	68 2a 0e 80 00       	push   $0x800e2a
  800124:	6a 23                	push   $0x23
  800126:	68 47 0e 80 00       	push   $0x800e47
  80012b:	e8 23 00 00 00       	call   800153 <_panic>

00800130 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800130:	f3 0f 1e fb          	endbr32 
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	57                   	push   %edi
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 02 00 00 00       	mov    $0x2,%eax
  800144:	89 d1                	mov    %edx,%ecx
  800146:	89 d3                	mov    %edx,%ebx
  800148:	89 d7                	mov    %edx,%edi
  80014a:	89 d6                	mov    %edx,%esi
  80014c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800153:	f3 0f 1e fb          	endbr32 
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800165:	e8 c6 ff ff ff       	call   800130 <sys_getenvid>
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	ff 75 0c             	pushl  0xc(%ebp)
  800170:	ff 75 08             	pushl  0x8(%ebp)
  800173:	56                   	push   %esi
  800174:	50                   	push   %eax
  800175:	68 58 0e 80 00       	push   $0x800e58
  80017a:	e8 bb 00 00 00       	call   80023a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	83 c4 18             	add    $0x18,%esp
  800182:	53                   	push   %ebx
  800183:	ff 75 10             	pushl  0x10(%ebp)
  800186:	e8 5a 00 00 00       	call   8001e5 <vcprintf>
	cprintf("\n");
  80018b:	c7 04 24 7b 0e 80 00 	movl   $0x800e7b,(%esp)
  800192:	e8 a3 00 00 00       	call   80023a <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x47>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	f3 0f 1e fb          	endbr32 
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 04             	sub    $0x4,%esp
  8001a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ab:	8b 13                	mov    (%ebx),%edx
  8001ad:	8d 42 01             	lea    0x1(%edx),%eax
  8001b0:	89 03                	mov    %eax,(%ebx)
  8001b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001be:	74 09                	je     8001c9 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	68 ff 00 00 00       	push   $0xff
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	50                   	push   %eax
  8001d5:	e8 cc fe ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	eb db                	jmp    8001c0 <putch+0x23>

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	f3 0f 1e fb          	endbr32 
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f9:	00 00 00 
	b.cnt = 0;
  8001fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800203:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	ff 75 08             	pushl  0x8(%ebp)
  80020c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800212:	50                   	push   %eax
  800213:	68 9d 01 80 00       	push   $0x80019d
  800218:	e8 20 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021d:	83 c4 08             	add    $0x8,%esp
  800220:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800226:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022c:	50                   	push   %eax
  80022d:	e8 74 fe ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	f3 0f 1e fb          	endbr32 
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800244:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800247:	50                   	push   %eax
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	e8 95 ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 1c             	sub    $0x1c,%esp
  80025b:	89 c7                	mov    %eax,%edi
  80025d:	89 d6                	mov    %edx,%esi
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	8b 55 0c             	mov    0xc(%ebp),%edx
  800265:	89 d1                	mov    %edx,%ecx
  800267:	89 c2                	mov    %eax,%edx
  800269:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80026f:	8b 45 10             	mov    0x10(%ebp),%eax
  800272:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800275:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800278:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80027f:	39 c2                	cmp    %eax,%edx
  800281:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800284:	72 3e                	jb     8002c4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	ff 75 18             	pushl  0x18(%ebp)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	ff 75 e4             	pushl  -0x1c(%ebp)
  800297:	ff 75 e0             	pushl  -0x20(%ebp)
  80029a:	ff 75 dc             	pushl  -0x24(%ebp)
  80029d:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a0:	e8 1b 09 00 00       	call   800bc0 <__udivdi3>
  8002a5:	83 c4 18             	add    $0x18,%esp
  8002a8:	52                   	push   %edx
  8002a9:	50                   	push   %eax
  8002aa:	89 f2                	mov    %esi,%edx
  8002ac:	89 f8                	mov    %edi,%eax
  8002ae:	e8 9f ff ff ff       	call   800252 <printnum>
  8002b3:	83 c4 20             	add    $0x20,%esp
  8002b6:	eb 13                	jmp    8002cb <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	56                   	push   %esi
  8002bc:	ff 75 18             	pushl  0x18(%ebp)
  8002bf:	ff d7                	call   *%edi
  8002c1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002c4:	83 eb 01             	sub    $0x1,%ebx
  8002c7:	85 db                	test   %ebx,%ebx
  8002c9:	7f ed                	jg     8002b8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cb:	83 ec 08             	sub    $0x8,%esp
  8002ce:	56                   	push   %esi
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002db:	ff 75 d8             	pushl  -0x28(%ebp)
  8002de:	e8 ed 09 00 00       	call   800cd0 <__umoddi3>
  8002e3:	83 c4 14             	add    $0x14,%esp
  8002e6:	0f be 80 7d 0e 80 00 	movsbl 0x800e7d(%eax),%eax
  8002ed:	50                   	push   %eax
  8002ee:	ff d7                	call   *%edi
}
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fb:	f3 0f 1e fb          	endbr32 
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800305:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	3b 50 04             	cmp    0x4(%eax),%edx
  80030e:	73 0a                	jae    80031a <sprintputch+0x1f>
		*b->buf++ = ch;
  800310:	8d 4a 01             	lea    0x1(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	88 02                	mov    %al,(%edx)
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <printfmt>:
{
  80031c:	f3 0f 1e fb          	endbr32 
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800326:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800329:	50                   	push   %eax
  80032a:	ff 75 10             	pushl  0x10(%ebp)
  80032d:	ff 75 0c             	pushl  0xc(%ebp)
  800330:	ff 75 08             	pushl  0x8(%ebp)
  800333:	e8 05 00 00 00       	call   80033d <vprintfmt>
}
  800338:	83 c4 10             	add    $0x10,%esp
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
{
  80033d:	f3 0f 1e fb          	endbr32 
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	57                   	push   %edi
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
  800347:	83 ec 3c             	sub    $0x3c,%esp
  80034a:	8b 75 08             	mov    0x8(%ebp),%esi
  80034d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800350:	8b 7d 10             	mov    0x10(%ebp),%edi
  800353:	e9 8e 03 00 00       	jmp    8006e6 <vprintfmt+0x3a9>
		padc = ' ';
  800358:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80035c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800363:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80036a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800371:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8d 47 01             	lea    0x1(%edi),%eax
  800379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037c:	0f b6 17             	movzbl (%edi),%edx
  80037f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800382:	3c 55                	cmp    $0x55,%al
  800384:	0f 87 df 03 00 00    	ja     800769 <vprintfmt+0x42c>
  80038a:	0f b6 c0             	movzbl %al,%eax
  80038d:	3e ff 24 85 0c 0f 80 	notrack jmp *0x800f0c(,%eax,4)
  800394:	00 
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800398:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80039c:	eb d8                	jmp    800376 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a1:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a5:	eb cf                	jmp    800376 <vprintfmt+0x39>
  8003a7:	0f b6 d2             	movzbl %dl,%edx
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003bc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003bf:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c2:	83 f9 09             	cmp    $0x9,%ecx
  8003c5:	77 55                	ja     80041c <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003c7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ca:	eb e9                	jmp    8003b5 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 40 04             	lea    0x4(%eax),%eax
  8003da:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e4:	79 90                	jns    800376 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ec:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f3:	eb 81                	jmp    800376 <vprintfmt+0x39>
  8003f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	0f 49 d0             	cmovns %eax,%edx
  800402:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800408:	e9 69 ff ff ff       	jmp    800376 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800410:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800417:	e9 5a ff ff ff       	jmp    800376 <vprintfmt+0x39>
  80041c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80041f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800422:	eb bc                	jmp    8003e0 <vprintfmt+0xa3>
			lflag++;
  800424:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80042a:	e9 47 ff ff ff       	jmp    800376 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 78 04             	lea    0x4(%eax),%edi
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	53                   	push   %ebx
  800439:	ff 30                	pushl  (%eax)
  80043b:	ff d6                	call   *%esi
			break;
  80043d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800443:	e9 9b 02 00 00       	jmp    8006e3 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 78 04             	lea    0x4(%eax),%edi
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	99                   	cltd   
  800451:	31 d0                	xor    %edx,%eax
  800453:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800455:	83 f8 06             	cmp    $0x6,%eax
  800458:	7f 23                	jg     80047d <vprintfmt+0x140>
  80045a:	8b 14 85 64 10 80 00 	mov    0x801064(,%eax,4),%edx
  800461:	85 d2                	test   %edx,%edx
  800463:	74 18                	je     80047d <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800465:	52                   	push   %edx
  800466:	68 9e 0e 80 00       	push   $0x800e9e
  80046b:	53                   	push   %ebx
  80046c:	56                   	push   %esi
  80046d:	e8 aa fe ff ff       	call   80031c <printfmt>
  800472:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800475:	89 7d 14             	mov    %edi,0x14(%ebp)
  800478:	e9 66 02 00 00       	jmp    8006e3 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80047d:	50                   	push   %eax
  80047e:	68 95 0e 80 00       	push   $0x800e95
  800483:	53                   	push   %ebx
  800484:	56                   	push   %esi
  800485:	e8 92 fe ff ff       	call   80031c <printfmt>
  80048a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800490:	e9 4e 02 00 00       	jmp    8006e3 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	83 c0 04             	add    $0x4,%eax
  80049b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a3:	85 d2                	test   %edx,%edx
  8004a5:	b8 8e 0e 80 00       	mov    $0x800e8e,%eax
  8004aa:	0f 45 c2             	cmovne %edx,%eax
  8004ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b4:	7e 06                	jle    8004bc <vprintfmt+0x17f>
  8004b6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004ba:	75 0d                	jne    8004c9 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004bf:	89 c7                	mov    %eax,%edi
  8004c1:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c7:	eb 55                	jmp    80051e <vprintfmt+0x1e1>
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cf:	ff 75 cc             	pushl  -0x34(%ebp)
  8004d2:	e8 46 03 00 00       	call   80081d <strnlen>
  8004d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004e4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	85 ff                	test   %edi,%edi
  8004ed:	7e 11                	jle    800500 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	eb eb                	jmp    8004eb <vprintfmt+0x1ae>
  800500:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800503:	85 d2                	test   %edx,%edx
  800505:	b8 00 00 00 00       	mov    $0x0,%eax
  80050a:	0f 49 c2             	cmovns %edx,%eax
  80050d:	29 c2                	sub    %eax,%edx
  80050f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800512:	eb a8                	jmp    8004bc <vprintfmt+0x17f>
					putch(ch, putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	52                   	push   %edx
  800519:	ff d6                	call   *%esi
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800521:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800523:	83 c7 01             	add    $0x1,%edi
  800526:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052a:	0f be d0             	movsbl %al,%edx
  80052d:	85 d2                	test   %edx,%edx
  80052f:	74 4b                	je     80057c <vprintfmt+0x23f>
  800531:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800535:	78 06                	js     80053d <vprintfmt+0x200>
  800537:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80053b:	78 1e                	js     80055b <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800541:	74 d1                	je     800514 <vprintfmt+0x1d7>
  800543:	0f be c0             	movsbl %al,%eax
  800546:	83 e8 20             	sub    $0x20,%eax
  800549:	83 f8 5e             	cmp    $0x5e,%eax
  80054c:	76 c6                	jbe    800514 <vprintfmt+0x1d7>
					putch('?', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	6a 3f                	push   $0x3f
  800554:	ff d6                	call   *%esi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb c3                	jmp    80051e <vprintfmt+0x1e1>
  80055b:	89 cf                	mov    %ecx,%edi
  80055d:	eb 0e                	jmp    80056d <vprintfmt+0x230>
				putch(' ', putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	53                   	push   %ebx
  800563:	6a 20                	push   $0x20
  800565:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800567:	83 ef 01             	sub    $0x1,%edi
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	85 ff                	test   %edi,%edi
  80056f:	7f ee                	jg     80055f <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800571:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800574:	89 45 14             	mov    %eax,0x14(%ebp)
  800577:	e9 67 01 00 00       	jmp    8006e3 <vprintfmt+0x3a6>
  80057c:	89 cf                	mov    %ecx,%edi
  80057e:	eb ed                	jmp    80056d <vprintfmt+0x230>
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7f 1b                	jg     8005a0 <vprintfmt+0x263>
	else if (lflag)
  800585:	85 c9                	test   %ecx,%ecx
  800587:	74 63                	je     8005ec <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	99                   	cltd   
  800592:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 40 04             	lea    0x4(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
  80059e:	eb 17                	jmp    8005b7 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8b 50 04             	mov    0x4(%eax),%edx
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 40 08             	lea    0x8(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005bd:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005c2:	85 c9                	test   %ecx,%ecx
  8005c4:	0f 89 ff 00 00 00    	jns    8006c9 <vprintfmt+0x38c>
				putch('-', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d8:	f7 da                	neg    %edx
  8005da:	83 d1 00             	adc    $0x0,%ecx
  8005dd:	f7 d9                	neg    %ecx
  8005df:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e7:	e9 dd 00 00 00       	jmp    8006c9 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	99                   	cltd   
  8005f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
  800601:	eb b4                	jmp    8005b7 <vprintfmt+0x27a>
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7f 1e                	jg     800626 <vprintfmt+0x2e9>
	else if (lflag)
  800608:	85 c9                	test   %ecx,%ecx
  80060a:	74 32                	je     80063e <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800621:	e9 a3 00 00 00       	jmp    8006c9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 10                	mov    (%eax),%edx
  80062b:	8b 48 04             	mov    0x4(%eax),%ecx
  80062e:	8d 40 08             	lea    0x8(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800634:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800639:	e9 8b 00 00 00       	jmp    8006c9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 10                	mov    (%eax),%edx
  800643:	b9 00 00 00 00       	mov    $0x0,%ecx
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800653:	eb 74                	jmp    8006c9 <vprintfmt+0x38c>
	if (lflag >= 2)
  800655:	83 f9 01             	cmp    $0x1,%ecx
  800658:	7f 1b                	jg     800675 <vprintfmt+0x338>
	else if (lflag)
  80065a:	85 c9                	test   %ecx,%ecx
  80065c:	74 2c                	je     80068a <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80066e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800673:	eb 54                	jmp    8006c9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 10                	mov    (%eax),%edx
  80067a:	8b 48 04             	mov    0x4(%eax),%ecx
  80067d:	8d 40 08             	lea    0x8(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800683:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800688:	eb 3f                	jmp    8006c9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80069a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80069f:	eb 28                	jmp    8006c9 <vprintfmt+0x38c>
			putch('0', putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	6a 30                	push   $0x30
  8006a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a9:	83 c4 08             	add    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 78                	push   $0x78
  8006af:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006bb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006be:	8d 40 04             	lea    0x4(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006d0:	57                   	push   %edi
  8006d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d4:	50                   	push   %eax
  8006d5:	51                   	push   %ecx
  8006d6:	52                   	push   %edx
  8006d7:	89 da                	mov    %ebx,%edx
  8006d9:	89 f0                	mov    %esi,%eax
  8006db:	e8 72 fb ff ff       	call   800252 <printnum>
			break;
  8006e0:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e6:	83 c7 01             	add    $0x1,%edi
  8006e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ed:	83 f8 25             	cmp    $0x25,%eax
  8006f0:	0f 84 62 fc ff ff    	je     800358 <vprintfmt+0x1b>
			if (ch == '\0')
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	0f 84 8b 00 00 00    	je     800789 <vprintfmt+0x44c>
			putch(ch, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	50                   	push   %eax
  800703:	ff d6                	call   *%esi
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb dc                	jmp    8006e6 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80070a:	83 f9 01             	cmp    $0x1,%ecx
  80070d:	7f 1b                	jg     80072a <vprintfmt+0x3ed>
	else if (lflag)
  80070f:	85 c9                	test   %ecx,%ecx
  800711:	74 2c                	je     80073f <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071d:	8d 40 04             	lea    0x4(%eax),%eax
  800720:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800723:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800728:	eb 9f                	jmp    8006c9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8b 10                	mov    (%eax),%edx
  80072f:	8b 48 04             	mov    0x4(%eax),%ecx
  800732:	8d 40 08             	lea    0x8(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800738:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80073d:	eb 8a                	jmp    8006c9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8b 10                	mov    (%eax),%edx
  800744:	b9 00 00 00 00       	mov    $0x0,%ecx
  800749:	8d 40 04             	lea    0x4(%eax),%eax
  80074c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800754:	e9 70 ff ff ff       	jmp    8006c9 <vprintfmt+0x38c>
			putch(ch, putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 25                	push   $0x25
  80075f:	ff d6                	call   *%esi
			break;
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	e9 7a ff ff ff       	jmp    8006e3 <vprintfmt+0x3a6>
			putch('%', putdat);
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	53                   	push   %ebx
  80076d:	6a 25                	push   $0x25
  80076f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	89 f8                	mov    %edi,%eax
  800776:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80077a:	74 05                	je     800781 <vprintfmt+0x444>
  80077c:	83 e8 01             	sub    $0x1,%eax
  80077f:	eb f5                	jmp    800776 <vprintfmt+0x439>
  800781:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800784:	e9 5a ff ff ff       	jmp    8006e3 <vprintfmt+0x3a6>
}
  800789:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078c:	5b                   	pop    %ebx
  80078d:	5e                   	pop    %esi
  80078e:	5f                   	pop    %edi
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800791:	f3 0f 1e fb          	endbr32 
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	74 26                	je     8007dc <vsnprintf+0x4b>
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	7e 22                	jle    8007dc <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ba:	ff 75 14             	pushl  0x14(%ebp)
  8007bd:	ff 75 10             	pushl  0x10(%ebp)
  8007c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	68 fb 02 80 00       	push   $0x8002fb
  8007c9:	e8 6f fb ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d7:	83 c4 10             	add    $0x10,%esp
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    
		return -E_INVAL;
  8007dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e1:	eb f7                	jmp    8007da <vsnprintf+0x49>

008007e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e3:	f3 0f 1e fb          	endbr32 
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f0:	50                   	push   %eax
  8007f1:	ff 75 10             	pushl  0x10(%ebp)
  8007f4:	ff 75 0c             	pushl  0xc(%ebp)
  8007f7:	ff 75 08             	pushl  0x8(%ebp)
  8007fa:	e8 92 ff ff ff       	call   800791 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800801:	f3 0f 1e fb          	endbr32 
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800814:	74 05                	je     80081b <strlen+0x1a>
		n++;
  800816:	83 c0 01             	add    $0x1,%eax
  800819:	eb f5                	jmp    800810 <strlen+0xf>
	return n;
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081d:	f3 0f 1e fb          	endbr32 
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082a:	b8 00 00 00 00       	mov    $0x0,%eax
  80082f:	39 d0                	cmp    %edx,%eax
  800831:	74 0d                	je     800840 <strnlen+0x23>
  800833:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800837:	74 05                	je     80083e <strnlen+0x21>
		n++;
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	eb f1                	jmp    80082f <strnlen+0x12>
  80083e:	89 c2                	mov    %eax,%edx
	return n;
}
  800840:	89 d0                	mov    %edx,%eax
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800844:	f3 0f 1e fb          	endbr32 
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
  800857:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80085b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	84 d2                	test   %dl,%dl
  800863:	75 f2                	jne    800857 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800865:	89 c8                	mov    %ecx,%eax
  800867:	5b                   	pop    %ebx
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086a:	f3 0f 1e fb          	endbr32 
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	83 ec 10             	sub    $0x10,%esp
  800875:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800878:	53                   	push   %ebx
  800879:	e8 83 ff ff ff       	call   800801 <strlen>
  80087e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800881:	ff 75 0c             	pushl  0xc(%ebp)
  800884:	01 d8                	add    %ebx,%eax
  800886:	50                   	push   %eax
  800887:	e8 b8 ff ff ff       	call   800844 <strcpy>
	return dst;
}
  80088c:	89 d8                	mov    %ebx,%eax
  80088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800893:	f3 0f 1e fb          	endbr32 
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	8b 75 08             	mov    0x8(%ebp),%esi
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a2:	89 f3                	mov    %esi,%ebx
  8008a4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a7:	89 f0                	mov    %esi,%eax
  8008a9:	39 d8                	cmp    %ebx,%eax
  8008ab:	74 11                	je     8008be <strncpy+0x2b>
		*dst++ = *src;
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	0f b6 0a             	movzbl (%edx),%ecx
  8008b3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b6:	80 f9 01             	cmp    $0x1,%cl
  8008b9:	83 da ff             	sbb    $0xffffffff,%edx
  8008bc:	eb eb                	jmp    8008a9 <strncpy+0x16>
	}
	return ret;
}
  8008be:	89 f0                	mov    %esi,%eax
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c4:	f3 0f 1e fb          	endbr32 
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d8:	85 d2                	test   %edx,%edx
  8008da:	74 21                	je     8008fd <strlcpy+0x39>
  8008dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e0:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008e2:	39 c2                	cmp    %eax,%edx
  8008e4:	74 14                	je     8008fa <strlcpy+0x36>
  8008e6:	0f b6 19             	movzbl (%ecx),%ebx
  8008e9:	84 db                	test   %bl,%bl
  8008eb:	74 0b                	je     8008f8 <strlcpy+0x34>
			*dst++ = *src++;
  8008ed:	83 c1 01             	add    $0x1,%ecx
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f6:	eb ea                	jmp    8008e2 <strlcpy+0x1e>
  8008f8:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fd:	29 f0                	sub    %esi,%eax
}
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800903:	f3 0f 1e fb          	endbr32 
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800910:	0f b6 01             	movzbl (%ecx),%eax
  800913:	84 c0                	test   %al,%al
  800915:	74 0c                	je     800923 <strcmp+0x20>
  800917:	3a 02                	cmp    (%edx),%al
  800919:	75 08                	jne    800923 <strcmp+0x20>
		p++, q++;
  80091b:	83 c1 01             	add    $0x1,%ecx
  80091e:	83 c2 01             	add    $0x1,%edx
  800921:	eb ed                	jmp    800910 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800923:	0f b6 c0             	movzbl %al,%eax
  800926:	0f b6 12             	movzbl (%edx),%edx
  800929:	29 d0                	sub    %edx,%eax
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092d:	f3 0f 1e fb          	endbr32 
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	53                   	push   %ebx
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093b:	89 c3                	mov    %eax,%ebx
  80093d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800940:	eb 06                	jmp    800948 <strncmp+0x1b>
		n--, p++, q++;
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800948:	39 d8                	cmp    %ebx,%eax
  80094a:	74 16                	je     800962 <strncmp+0x35>
  80094c:	0f b6 08             	movzbl (%eax),%ecx
  80094f:	84 c9                	test   %cl,%cl
  800951:	74 04                	je     800957 <strncmp+0x2a>
  800953:	3a 0a                	cmp    (%edx),%cl
  800955:	74 eb                	je     800942 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800957:	0f b6 00             	movzbl (%eax),%eax
  80095a:	0f b6 12             	movzbl (%edx),%edx
  80095d:	29 d0                	sub    %edx,%eax
}
  80095f:	5b                   	pop    %ebx
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    
		return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
  800967:	eb f6                	jmp    80095f <strncmp+0x32>

00800969 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800969:	f3 0f 1e fb          	endbr32 
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800977:	0f b6 10             	movzbl (%eax),%edx
  80097a:	84 d2                	test   %dl,%dl
  80097c:	74 09                	je     800987 <strchr+0x1e>
		if (*s == c)
  80097e:	38 ca                	cmp    %cl,%dl
  800980:	74 0a                	je     80098c <strchr+0x23>
	for (; *s; s++)
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	eb f0                	jmp    800977 <strchr+0xe>
			return (char *) s;
	return 0;
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098e:	f3 0f 1e fb          	endbr32 
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80099f:	38 ca                	cmp    %cl,%dl
  8009a1:	74 09                	je     8009ac <strfind+0x1e>
  8009a3:	84 d2                	test   %dl,%dl
  8009a5:	74 05                	je     8009ac <strfind+0x1e>
	for (; *s; s++)
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	eb f0                	jmp    80099c <strfind+0xe>
			break;
	return (char *) s;
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ae:	f3 0f 1e fb          	endbr32 
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009be:	85 c9                	test   %ecx,%ecx
  8009c0:	74 31                	je     8009f3 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c2:	89 f8                	mov    %edi,%eax
  8009c4:	09 c8                	or     %ecx,%eax
  8009c6:	a8 03                	test   $0x3,%al
  8009c8:	75 23                	jne    8009ed <memset+0x3f>
		c &= 0xFF;
  8009ca:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ce:	89 d3                	mov    %edx,%ebx
  8009d0:	c1 e3 08             	shl    $0x8,%ebx
  8009d3:	89 d0                	mov    %edx,%eax
  8009d5:	c1 e0 18             	shl    $0x18,%eax
  8009d8:	89 d6                	mov    %edx,%esi
  8009da:	c1 e6 10             	shl    $0x10,%esi
  8009dd:	09 f0                	or     %esi,%eax
  8009df:	09 c2                	or     %eax,%edx
  8009e1:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	fc                   	cld    
  8009e9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009eb:	eb 06                	jmp    8009f3 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f0:	fc                   	cld    
  8009f1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f3:	89 f8                	mov    %edi,%eax
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	5f                   	pop    %edi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009fa:	f3 0f 1e fb          	endbr32 
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0c:	39 c6                	cmp    %eax,%esi
  800a0e:	73 32                	jae    800a42 <memmove+0x48>
  800a10:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a13:	39 c2                	cmp    %eax,%edx
  800a15:	76 2b                	jbe    800a42 <memmove+0x48>
		s += n;
		d += n;
  800a17:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1a:	89 fe                	mov    %edi,%esi
  800a1c:	09 ce                	or     %ecx,%esi
  800a1e:	09 d6                	or     %edx,%esi
  800a20:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a26:	75 0e                	jne    800a36 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a28:	83 ef 04             	sub    $0x4,%edi
  800a2b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a31:	fd                   	std    
  800a32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a34:	eb 09                	jmp    800a3f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a36:	83 ef 01             	sub    $0x1,%edi
  800a39:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a3c:	fd                   	std    
  800a3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3f:	fc                   	cld    
  800a40:	eb 1a                	jmp    800a5c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	09 ca                	or     %ecx,%edx
  800a46:	09 f2                	or     %esi,%edx
  800a48:	f6 c2 03             	test   $0x3,%dl
  800a4b:	75 0a                	jne    800a57 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a50:	89 c7                	mov    %eax,%edi
  800a52:	fc                   	cld    
  800a53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a55:	eb 05                	jmp    800a5c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a57:	89 c7                	mov    %eax,%edi
  800a59:	fc                   	cld    
  800a5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a60:	f3 0f 1e fb          	endbr32 
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a6a:	ff 75 10             	pushl  0x10(%ebp)
  800a6d:	ff 75 0c             	pushl  0xc(%ebp)
  800a70:	ff 75 08             	pushl  0x8(%ebp)
  800a73:	e8 82 ff ff ff       	call   8009fa <memmove>
}
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7a:	f3 0f 1e fb          	endbr32 
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8e:	39 f0                	cmp    %esi,%eax
  800a90:	74 1c                	je     800aae <memcmp+0x34>
		if (*s1 != *s2)
  800a92:	0f b6 08             	movzbl (%eax),%ecx
  800a95:	0f b6 1a             	movzbl (%edx),%ebx
  800a98:	38 d9                	cmp    %bl,%cl
  800a9a:	75 08                	jne    800aa4 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	83 c2 01             	add    $0x1,%edx
  800aa2:	eb ea                	jmp    800a8e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aa4:	0f b6 c1             	movzbl %cl,%eax
  800aa7:	0f b6 db             	movzbl %bl,%ebx
  800aaa:	29 d8                	sub    %ebx,%eax
  800aac:	eb 05                	jmp    800ab3 <memcmp+0x39>
	}

	return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab7:	f3 0f 1e fb          	endbr32 
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac4:	89 c2                	mov    %eax,%edx
  800ac6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac9:	39 d0                	cmp    %edx,%eax
  800acb:	73 09                	jae    800ad6 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800acd:	38 08                	cmp    %cl,(%eax)
  800acf:	74 05                	je     800ad6 <memfind+0x1f>
	for (; s < ends; s++)
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	eb f3                	jmp    800ac9 <memfind+0x12>
			break;
	return (void *) s;
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad8:	f3 0f 1e fb          	endbr32 
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae8:	eb 03                	jmp    800aed <strtol+0x15>
		s++;
  800aea:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aed:	0f b6 01             	movzbl (%ecx),%eax
  800af0:	3c 20                	cmp    $0x20,%al
  800af2:	74 f6                	je     800aea <strtol+0x12>
  800af4:	3c 09                	cmp    $0x9,%al
  800af6:	74 f2                	je     800aea <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800af8:	3c 2b                	cmp    $0x2b,%al
  800afa:	74 2a                	je     800b26 <strtol+0x4e>
	int neg = 0;
  800afc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b01:	3c 2d                	cmp    $0x2d,%al
  800b03:	74 2b                	je     800b30 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b05:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b0b:	75 0f                	jne    800b1c <strtol+0x44>
  800b0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b10:	74 28                	je     800b3a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b12:	85 db                	test   %ebx,%ebx
  800b14:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b19:	0f 44 d8             	cmove  %eax,%ebx
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b21:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b24:	eb 46                	jmp    800b6c <strtol+0x94>
		s++;
  800b26:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2e:	eb d5                	jmp    800b05 <strtol+0x2d>
		s++, neg = 1;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bf 01 00 00 00       	mov    $0x1,%edi
  800b38:	eb cb                	jmp    800b05 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3e:	74 0e                	je     800b4e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b40:	85 db                	test   %ebx,%ebx
  800b42:	75 d8                	jne    800b1c <strtol+0x44>
		s++, base = 8;
  800b44:	83 c1 01             	add    $0x1,%ecx
  800b47:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b4c:	eb ce                	jmp    800b1c <strtol+0x44>
		s += 2, base = 16;
  800b4e:	83 c1 02             	add    $0x2,%ecx
  800b51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b56:	eb c4                	jmp    800b1c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b58:	0f be d2             	movsbl %dl,%edx
  800b5b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b61:	7d 3a                	jge    800b9d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b6c:	0f b6 11             	movzbl (%ecx),%edx
  800b6f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b72:	89 f3                	mov    %esi,%ebx
  800b74:	80 fb 09             	cmp    $0x9,%bl
  800b77:	76 df                	jbe    800b58 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b79:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b7c:	89 f3                	mov    %esi,%ebx
  800b7e:	80 fb 19             	cmp    $0x19,%bl
  800b81:	77 08                	ja     800b8b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b83:	0f be d2             	movsbl %dl,%edx
  800b86:	83 ea 57             	sub    $0x57,%edx
  800b89:	eb d3                	jmp    800b5e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b8b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b8e:	89 f3                	mov    %esi,%ebx
  800b90:	80 fb 19             	cmp    $0x19,%bl
  800b93:	77 08                	ja     800b9d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b95:	0f be d2             	movsbl %dl,%edx
  800b98:	83 ea 37             	sub    $0x37,%edx
  800b9b:	eb c1                	jmp    800b5e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba1:	74 05                	je     800ba8 <strtol+0xd0>
		*endptr = (char *) s;
  800ba3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ba8:	89 c2                	mov    %eax,%edx
  800baa:	f7 da                	neg    %edx
  800bac:	85 ff                	test   %edi,%edi
  800bae:	0f 45 c2             	cmovne %edx,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
  800bb6:	66 90                	xchg   %ax,%ax
  800bb8:	66 90                	xchg   %ax,%ax
  800bba:	66 90                	xchg   %ax,%ax
  800bbc:	66 90                	xchg   %ax,%ax
  800bbe:	66 90                	xchg   %ax,%ax

00800bc0 <__udivdi3>:
  800bc0:	f3 0f 1e fb          	endbr32 
  800bc4:	55                   	push   %ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 1c             	sub    $0x1c,%esp
  800bcb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800bcf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800bd3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800bd7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800bdb:	85 d2                	test   %edx,%edx
  800bdd:	75 19                	jne    800bf8 <__udivdi3+0x38>
  800bdf:	39 f3                	cmp    %esi,%ebx
  800be1:	76 4d                	jbe    800c30 <__udivdi3+0x70>
  800be3:	31 ff                	xor    %edi,%edi
  800be5:	89 e8                	mov    %ebp,%eax
  800be7:	89 f2                	mov    %esi,%edx
  800be9:	f7 f3                	div    %ebx
  800beb:	89 fa                	mov    %edi,%edx
  800bed:	83 c4 1c             	add    $0x1c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    
  800bf5:	8d 76 00             	lea    0x0(%esi),%esi
  800bf8:	39 f2                	cmp    %esi,%edx
  800bfa:	76 14                	jbe    800c10 <__udivdi3+0x50>
  800bfc:	31 ff                	xor    %edi,%edi
  800bfe:	31 c0                	xor    %eax,%eax
  800c00:	89 fa                	mov    %edi,%edx
  800c02:	83 c4 1c             	add    $0x1c,%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    
  800c0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c10:	0f bd fa             	bsr    %edx,%edi
  800c13:	83 f7 1f             	xor    $0x1f,%edi
  800c16:	75 48                	jne    800c60 <__udivdi3+0xa0>
  800c18:	39 f2                	cmp    %esi,%edx
  800c1a:	72 06                	jb     800c22 <__udivdi3+0x62>
  800c1c:	31 c0                	xor    %eax,%eax
  800c1e:	39 eb                	cmp    %ebp,%ebx
  800c20:	77 de                	ja     800c00 <__udivdi3+0x40>
  800c22:	b8 01 00 00 00       	mov    $0x1,%eax
  800c27:	eb d7                	jmp    800c00 <__udivdi3+0x40>
  800c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c30:	89 d9                	mov    %ebx,%ecx
  800c32:	85 db                	test   %ebx,%ebx
  800c34:	75 0b                	jne    800c41 <__udivdi3+0x81>
  800c36:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3b:	31 d2                	xor    %edx,%edx
  800c3d:	f7 f3                	div    %ebx
  800c3f:	89 c1                	mov    %eax,%ecx
  800c41:	31 d2                	xor    %edx,%edx
  800c43:	89 f0                	mov    %esi,%eax
  800c45:	f7 f1                	div    %ecx
  800c47:	89 c6                	mov    %eax,%esi
  800c49:	89 e8                	mov    %ebp,%eax
  800c4b:	89 f7                	mov    %esi,%edi
  800c4d:	f7 f1                	div    %ecx
  800c4f:	89 fa                	mov    %edi,%edx
  800c51:	83 c4 1c             	add    $0x1c,%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    
  800c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c60:	89 f9                	mov    %edi,%ecx
  800c62:	b8 20 00 00 00       	mov    $0x20,%eax
  800c67:	29 f8                	sub    %edi,%eax
  800c69:	d3 e2                	shl    %cl,%edx
  800c6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c6f:	89 c1                	mov    %eax,%ecx
  800c71:	89 da                	mov    %ebx,%edx
  800c73:	d3 ea                	shr    %cl,%edx
  800c75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c79:	09 d1                	or     %edx,%ecx
  800c7b:	89 f2                	mov    %esi,%edx
  800c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c81:	89 f9                	mov    %edi,%ecx
  800c83:	d3 e3                	shl    %cl,%ebx
  800c85:	89 c1                	mov    %eax,%ecx
  800c87:	d3 ea                	shr    %cl,%edx
  800c89:	89 f9                	mov    %edi,%ecx
  800c8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800c8f:	89 eb                	mov    %ebp,%ebx
  800c91:	d3 e6                	shl    %cl,%esi
  800c93:	89 c1                	mov    %eax,%ecx
  800c95:	d3 eb                	shr    %cl,%ebx
  800c97:	09 de                	or     %ebx,%esi
  800c99:	89 f0                	mov    %esi,%eax
  800c9b:	f7 74 24 08          	divl   0x8(%esp)
  800c9f:	89 d6                	mov    %edx,%esi
  800ca1:	89 c3                	mov    %eax,%ebx
  800ca3:	f7 64 24 0c          	mull   0xc(%esp)
  800ca7:	39 d6                	cmp    %edx,%esi
  800ca9:	72 15                	jb     800cc0 <__udivdi3+0x100>
  800cab:	89 f9                	mov    %edi,%ecx
  800cad:	d3 e5                	shl    %cl,%ebp
  800caf:	39 c5                	cmp    %eax,%ebp
  800cb1:	73 04                	jae    800cb7 <__udivdi3+0xf7>
  800cb3:	39 d6                	cmp    %edx,%esi
  800cb5:	74 09                	je     800cc0 <__udivdi3+0x100>
  800cb7:	89 d8                	mov    %ebx,%eax
  800cb9:	31 ff                	xor    %edi,%edi
  800cbb:	e9 40 ff ff ff       	jmp    800c00 <__udivdi3+0x40>
  800cc0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cc3:	31 ff                	xor    %edi,%edi
  800cc5:	e9 36 ff ff ff       	jmp    800c00 <__udivdi3+0x40>
  800cca:	66 90                	xchg   %ax,%ax
  800ccc:	66 90                	xchg   %ax,%ax
  800cce:	66 90                	xchg   %ax,%ax

00800cd0 <__umoddi3>:
  800cd0:	f3 0f 1e fb          	endbr32 
  800cd4:	55                   	push   %ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 1c             	sub    $0x1c,%esp
  800cdb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cdf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ce3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ce7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	75 19                	jne    800d08 <__umoddi3+0x38>
  800cef:	39 df                	cmp    %ebx,%edi
  800cf1:	76 5d                	jbe    800d50 <__umoddi3+0x80>
  800cf3:	89 f0                	mov    %esi,%eax
  800cf5:	89 da                	mov    %ebx,%edx
  800cf7:	f7 f7                	div    %edi
  800cf9:	89 d0                	mov    %edx,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	83 c4 1c             	add    $0x1c,%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    
  800d05:	8d 76 00             	lea    0x0(%esi),%esi
  800d08:	89 f2                	mov    %esi,%edx
  800d0a:	39 d8                	cmp    %ebx,%eax
  800d0c:	76 12                	jbe    800d20 <__umoddi3+0x50>
  800d0e:	89 f0                	mov    %esi,%eax
  800d10:	89 da                	mov    %ebx,%edx
  800d12:	83 c4 1c             	add    $0x1c,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
  800d1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d20:	0f bd e8             	bsr    %eax,%ebp
  800d23:	83 f5 1f             	xor    $0x1f,%ebp
  800d26:	75 50                	jne    800d78 <__umoddi3+0xa8>
  800d28:	39 d8                	cmp    %ebx,%eax
  800d2a:	0f 82 e0 00 00 00    	jb     800e10 <__umoddi3+0x140>
  800d30:	89 d9                	mov    %ebx,%ecx
  800d32:	39 f7                	cmp    %esi,%edi
  800d34:	0f 86 d6 00 00 00    	jbe    800e10 <__umoddi3+0x140>
  800d3a:	89 d0                	mov    %edx,%eax
  800d3c:	89 ca                	mov    %ecx,%edx
  800d3e:	83 c4 1c             	add    $0x1c,%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    
  800d46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d4d:	8d 76 00             	lea    0x0(%esi),%esi
  800d50:	89 fd                	mov    %edi,%ebp
  800d52:	85 ff                	test   %edi,%edi
  800d54:	75 0b                	jne    800d61 <__umoddi3+0x91>
  800d56:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	f7 f7                	div    %edi
  800d5f:	89 c5                	mov    %eax,%ebp
  800d61:	89 d8                	mov    %ebx,%eax
  800d63:	31 d2                	xor    %edx,%edx
  800d65:	f7 f5                	div    %ebp
  800d67:	89 f0                	mov    %esi,%eax
  800d69:	f7 f5                	div    %ebp
  800d6b:	89 d0                	mov    %edx,%eax
  800d6d:	31 d2                	xor    %edx,%edx
  800d6f:	eb 8c                	jmp    800cfd <__umoddi3+0x2d>
  800d71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d78:	89 e9                	mov    %ebp,%ecx
  800d7a:	ba 20 00 00 00       	mov    $0x20,%edx
  800d7f:	29 ea                	sub    %ebp,%edx
  800d81:	d3 e0                	shl    %cl,%eax
  800d83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d87:	89 d1                	mov    %edx,%ecx
  800d89:	89 f8                	mov    %edi,%eax
  800d8b:	d3 e8                	shr    %cl,%eax
  800d8d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d91:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d95:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d99:	09 c1                	or     %eax,%ecx
  800d9b:	89 d8                	mov    %ebx,%eax
  800d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800da1:	89 e9                	mov    %ebp,%ecx
  800da3:	d3 e7                	shl    %cl,%edi
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	d3 e8                	shr    %cl,%eax
  800da9:	89 e9                	mov    %ebp,%ecx
  800dab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800daf:	d3 e3                	shl    %cl,%ebx
  800db1:	89 c7                	mov    %eax,%edi
  800db3:	89 d1                	mov    %edx,%ecx
  800db5:	89 f0                	mov    %esi,%eax
  800db7:	d3 e8                	shr    %cl,%eax
  800db9:	89 e9                	mov    %ebp,%ecx
  800dbb:	89 fa                	mov    %edi,%edx
  800dbd:	d3 e6                	shl    %cl,%esi
  800dbf:	09 d8                	or     %ebx,%eax
  800dc1:	f7 74 24 08          	divl   0x8(%esp)
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 f3                	mov    %esi,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	89 c6                	mov    %eax,%esi
  800dcf:	89 d7                	mov    %edx,%edi
  800dd1:	39 d1                	cmp    %edx,%ecx
  800dd3:	72 06                	jb     800ddb <__umoddi3+0x10b>
  800dd5:	75 10                	jne    800de7 <__umoddi3+0x117>
  800dd7:	39 c3                	cmp    %eax,%ebx
  800dd9:	73 0c                	jae    800de7 <__umoddi3+0x117>
  800ddb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800ddf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800de3:	89 d7                	mov    %edx,%edi
  800de5:	89 c6                	mov    %eax,%esi
  800de7:	89 ca                	mov    %ecx,%edx
  800de9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dee:	29 f3                	sub    %esi,%ebx
  800df0:	19 fa                	sbb    %edi,%edx
  800df2:	89 d0                	mov    %edx,%eax
  800df4:	d3 e0                	shl    %cl,%eax
  800df6:	89 e9                	mov    %ebp,%ecx
  800df8:	d3 eb                	shr    %cl,%ebx
  800dfa:	d3 ea                	shr    %cl,%edx
  800dfc:	09 d8                	or     %ebx,%eax
  800dfe:	83 c4 1c             	add    $0x1c,%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
  800e06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e0d:	8d 76 00             	lea    0x0(%esi),%esi
  800e10:	29 fe                	sub    %edi,%esi
  800e12:	19 c3                	sbb    %eax,%ebx
  800e14:	89 f2                	mov    %esi,%edx
  800e16:	89 d9                	mov    %ebx,%ecx
  800e18:	e9 1d ff ff ff       	jmp    800d3a <__umoddi3+0x6a>
