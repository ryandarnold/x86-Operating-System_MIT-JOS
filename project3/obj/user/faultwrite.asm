
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	f3 0f 1e fb          	endbr32 
  800046:	55                   	push   %ebp
  800047:	89 e5                	mov    %esp,%ebp
  800049:	56                   	push   %esi
  80004a:	53                   	push   %ebx
  80004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800051:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800058:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  80005b:	e8 d9 00 00 00       	call   800139 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800068:	c1 e0 05             	shl    $0x5,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x3e>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 0a 00 00 00       	call   800099 <exit>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800095:	5b                   	pop    %ebx
  800096:	5e                   	pop    %esi
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    

00800099 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800099:	f3 0f 1e fb          	endbr32 
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a3:	6a 00                	push   $0x0
  8000a5:	e8 4a 00 00 00       	call   8000f4 <sys_env_destroy>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    

008000af <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000af:	f3 0f 1e fb          	endbr32 
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c4:	89 c3                	mov    %eax,%ebx
  8000c6:	89 c7                	mov    %eax,%edi
  8000c8:	89 c6                	mov    %eax,%esi
  8000ca:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d1:	f3 0f 1e fb          	endbr32 
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000db:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e5:	89 d1                	mov    %edx,%ecx
  8000e7:	89 d3                	mov    %edx,%ebx
  8000e9:	89 d7                	mov    %edx,%edi
  8000eb:	89 d6                	mov    %edx,%esi
  8000ed:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f4:	f3 0f 1e fb          	endbr32 
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	57                   	push   %edi
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800101:	b9 00 00 00 00       	mov    $0x0,%ecx
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	b8 03 00 00 00       	mov    $0x3,%eax
  80010e:	89 cb                	mov    %ecx,%ebx
  800110:	89 cf                	mov    %ecx,%edi
  800112:	89 ce                	mov    %ecx,%esi
  800114:	cd 30                	int    $0x30
	if(check && ret > 0)
  800116:	85 c0                	test   %eax,%eax
  800118:	7f 08                	jg     800122 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011d:	5b                   	pop    %ebx
  80011e:	5e                   	pop    %esi
  80011f:	5f                   	pop    %edi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800122:	83 ec 0c             	sub    $0xc,%esp
  800125:	50                   	push   %eax
  800126:	6a 03                	push   $0x3
  800128:	68 2a 0e 80 00       	push   $0x800e2a
  80012d:	6a 23                	push   $0x23
  80012f:	68 47 0e 80 00       	push   $0x800e47
  800134:	e8 23 00 00 00       	call   80015c <_panic>

00800139 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800139:	f3 0f 1e fb          	endbr32 
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
	asm volatile("int %1\n"
  800143:	ba 00 00 00 00       	mov    $0x0,%edx
  800148:	b8 02 00 00 00       	mov    $0x2,%eax
  80014d:	89 d1                	mov    %edx,%ecx
  80014f:	89 d3                	mov    %edx,%ebx
  800151:	89 d7                	mov    %edx,%edi
  800153:	89 d6                	mov    %edx,%esi
  800155:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	5f                   	pop    %edi
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	f3 0f 1e fb          	endbr32 
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800165:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800168:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80016e:	e8 c6 ff ff ff       	call   800139 <sys_getenvid>
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	56                   	push   %esi
  80017d:	50                   	push   %eax
  80017e:	68 58 0e 80 00       	push   $0x800e58
  800183:	e8 bb 00 00 00       	call   800243 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	83 c4 18             	add    $0x18,%esp
  80018b:	53                   	push   %ebx
  80018c:	ff 75 10             	pushl  0x10(%ebp)
  80018f:	e8 5a 00 00 00       	call   8001ee <vcprintf>
	cprintf("\n");
  800194:	c7 04 24 7b 0e 80 00 	movl   $0x800e7b,(%esp)
  80019b:	e8 a3 00 00 00       	call   800243 <cprintf>
  8001a0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x47>

008001a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a6:	f3 0f 1e fb          	endbr32 
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 04             	sub    $0x4,%esp
  8001b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b4:	8b 13                	mov    (%ebx),%edx
  8001b6:	8d 42 01             	lea    0x1(%edx),%eax
  8001b9:	89 03                	mov    %eax,(%ebx)
  8001bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001be:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	74 09                	je     8001d2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001c9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001d2:	83 ec 08             	sub    $0x8,%esp
  8001d5:	68 ff 00 00 00       	push   $0xff
  8001da:	8d 43 08             	lea    0x8(%ebx),%eax
  8001dd:	50                   	push   %eax
  8001de:	e8 cc fe ff ff       	call   8000af <sys_cputs>
		b->idx = 0;
  8001e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	eb db                	jmp    8001c9 <putch+0x23>

008001ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ee:	f3 0f 1e fb          	endbr32 
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800202:	00 00 00 
	b.cnt = 0;
  800205:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020f:	ff 75 0c             	pushl  0xc(%ebp)
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	68 a6 01 80 00       	push   $0x8001a6
  800221:	e8 20 01 00 00       	call   800346 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80022f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800235:	50                   	push   %eax
  800236:	e8 74 fe ff ff       	call   8000af <sys_cputs>

	return b.cnt;
}
  80023b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800243:	f3 0f 1e fb          	endbr32 
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800250:	50                   	push   %eax
  800251:	ff 75 08             	pushl  0x8(%ebp)
  800254:	e8 95 ff ff ff       	call   8001ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 1c             	sub    $0x1c,%esp
  800264:	89 c7                	mov    %eax,%edi
  800266:	89 d6                	mov    %edx,%esi
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026e:	89 d1                	mov    %edx,%ecx
  800270:	89 c2                	mov    %eax,%edx
  800272:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800275:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800278:	8b 45 10             	mov    0x10(%ebp),%eax
  80027b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800281:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800288:	39 c2                	cmp    %eax,%edx
  80028a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80028d:	72 3e                	jb     8002cd <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	ff 75 18             	pushl  0x18(%ebp)
  800295:	83 eb 01             	sub    $0x1,%ebx
  800298:	53                   	push   %ebx
  800299:	50                   	push   %eax
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 12 09 00 00       	call   800bc0 <__udivdi3>
  8002ae:	83 c4 18             	add    $0x18,%esp
  8002b1:	52                   	push   %edx
  8002b2:	50                   	push   %eax
  8002b3:	89 f2                	mov    %esi,%edx
  8002b5:	89 f8                	mov    %edi,%eax
  8002b7:	e8 9f ff ff ff       	call   80025b <printnum>
  8002bc:	83 c4 20             	add    $0x20,%esp
  8002bf:	eb 13                	jmp    8002d4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	56                   	push   %esi
  8002c5:	ff 75 18             	pushl  0x18(%ebp)
  8002c8:	ff d7                	call   *%edi
  8002ca:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002cd:	83 eb 01             	sub    $0x1,%ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f ed                	jg     8002c1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d4:	83 ec 08             	sub    $0x8,%esp
  8002d7:	56                   	push   %esi
  8002d8:	83 ec 04             	sub    $0x4,%esp
  8002db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002de:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e7:	e8 e4 09 00 00       	call   800cd0 <__umoddi3>
  8002ec:	83 c4 14             	add    $0x14,%esp
  8002ef:	0f be 80 7d 0e 80 00 	movsbl 0x800e7d(%eax),%eax
  8002f6:	50                   	push   %eax
  8002f7:	ff d7                	call   *%edi
}
  8002f9:	83 c4 10             	add    $0x10,%esp
  8002fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800304:	f3 0f 1e fb          	endbr32 
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800312:	8b 10                	mov    (%eax),%edx
  800314:	3b 50 04             	cmp    0x4(%eax),%edx
  800317:	73 0a                	jae    800323 <sprintputch+0x1f>
		*b->buf++ = ch;
  800319:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031c:	89 08                	mov    %ecx,(%eax)
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	88 02                	mov    %al,(%edx)
}
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <printfmt>:
{
  800325:	f3 0f 1e fb          	endbr32 
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80032f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800332:	50                   	push   %eax
  800333:	ff 75 10             	pushl  0x10(%ebp)
  800336:	ff 75 0c             	pushl  0xc(%ebp)
  800339:	ff 75 08             	pushl  0x8(%ebp)
  80033c:	e8 05 00 00 00       	call   800346 <vprintfmt>
}
  800341:	83 c4 10             	add    $0x10,%esp
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <vprintfmt>:
{
  800346:	f3 0f 1e fb          	endbr32 
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	57                   	push   %edi
  80034e:	56                   	push   %esi
  80034f:	53                   	push   %ebx
  800350:	83 ec 3c             	sub    $0x3c,%esp
  800353:	8b 75 08             	mov    0x8(%ebp),%esi
  800356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800359:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035c:	e9 8e 03 00 00       	jmp    8006ef <vprintfmt+0x3a9>
		padc = ' ';
  800361:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800365:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80036c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800373:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80037a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8d 47 01             	lea    0x1(%edi),%eax
  800382:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800385:	0f b6 17             	movzbl (%edi),%edx
  800388:	8d 42 dd             	lea    -0x23(%edx),%eax
  80038b:	3c 55                	cmp    $0x55,%al
  80038d:	0f 87 df 03 00 00    	ja     800772 <vprintfmt+0x42c>
  800393:	0f b6 c0             	movzbl %al,%eax
  800396:	3e ff 24 85 0c 0f 80 	notrack jmp *0x800f0c(,%eax,4)
  80039d:	00 
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003a1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003a5:	eb d8                	jmp    80037f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003aa:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003ae:	eb cf                	jmp    80037f <vprintfmt+0x39>
  8003b0:	0f b6 d2             	movzbl %dl,%edx
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003be:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003cb:	83 f9 09             	cmp    $0x9,%ecx
  8003ce:	77 55                	ja     800425 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003d0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d3:	eb e9                	jmp    8003be <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8b 00                	mov    (%eax),%eax
  8003da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 40 04             	lea    0x4(%eax),%eax
  8003e3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ed:	79 90                	jns    80037f <vprintfmt+0x39>
				width = precision, precision = -1;
  8003ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003fc:	eb 81                	jmp    80037f <vprintfmt+0x39>
  8003fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800401:	85 c0                	test   %eax,%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	0f 49 d0             	cmovns %eax,%edx
  80040b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800411:	e9 69 ff ff ff       	jmp    80037f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800419:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800420:	e9 5a ff ff ff       	jmp    80037f <vprintfmt+0x39>
  800425:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800428:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042b:	eb bc                	jmp    8003e9 <vprintfmt+0xa3>
			lflag++;
  80042d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800433:	e9 47 ff ff ff       	jmp    80037f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 78 04             	lea    0x4(%eax),%edi
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	53                   	push   %ebx
  800442:	ff 30                	pushl  (%eax)
  800444:	ff d6                	call   *%esi
			break;
  800446:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800449:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80044c:	e9 9b 02 00 00       	jmp    8006ec <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 78 04             	lea    0x4(%eax),%edi
  800457:	8b 00                	mov    (%eax),%eax
  800459:	99                   	cltd   
  80045a:	31 d0                	xor    %edx,%eax
  80045c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045e:	83 f8 06             	cmp    $0x6,%eax
  800461:	7f 23                	jg     800486 <vprintfmt+0x140>
  800463:	8b 14 85 64 10 80 00 	mov    0x801064(,%eax,4),%edx
  80046a:	85 d2                	test   %edx,%edx
  80046c:	74 18                	je     800486 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80046e:	52                   	push   %edx
  80046f:	68 9e 0e 80 00       	push   $0x800e9e
  800474:	53                   	push   %ebx
  800475:	56                   	push   %esi
  800476:	e8 aa fe ff ff       	call   800325 <printfmt>
  80047b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800481:	e9 66 02 00 00       	jmp    8006ec <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800486:	50                   	push   %eax
  800487:	68 95 0e 80 00       	push   $0x800e95
  80048c:	53                   	push   %ebx
  80048d:	56                   	push   %esi
  80048e:	e8 92 fe ff ff       	call   800325 <printfmt>
  800493:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800496:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800499:	e9 4e 02 00 00       	jmp    8006ec <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	83 c0 04             	add    $0x4,%eax
  8004a4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	b8 8e 0e 80 00       	mov    $0x800e8e,%eax
  8004b3:	0f 45 c2             	cmovne %edx,%eax
  8004b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bd:	7e 06                	jle    8004c5 <vprintfmt+0x17f>
  8004bf:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004c3:	75 0d                	jne    8004d2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c8:	89 c7                	mov    %eax,%edi
  8004ca:	03 45 e0             	add    -0x20(%ebp),%eax
  8004cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d0:	eb 55                	jmp    800527 <vprintfmt+0x1e1>
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d8:	ff 75 cc             	pushl  -0x34(%ebp)
  8004db:	e8 46 03 00 00       	call   800826 <strnlen>
  8004e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e3:	29 c2                	sub    %eax,%edx
  8004e5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ed:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7e 11                	jle    800509 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ff:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	83 ef 01             	sub    $0x1,%edi
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	eb eb                	jmp    8004f4 <vprintfmt+0x1ae>
  800509:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	b8 00 00 00 00       	mov    $0x0,%eax
  800513:	0f 49 c2             	cmovns %edx,%eax
  800516:	29 c2                	sub    %eax,%edx
  800518:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051b:	eb a8                	jmp    8004c5 <vprintfmt+0x17f>
					putch(ch, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	52                   	push   %edx
  800522:	ff d6                	call   *%esi
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 c7 01             	add    $0x1,%edi
  80052f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800533:	0f be d0             	movsbl %al,%edx
  800536:	85 d2                	test   %edx,%edx
  800538:	74 4b                	je     800585 <vprintfmt+0x23f>
  80053a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053e:	78 06                	js     800546 <vprintfmt+0x200>
  800540:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800544:	78 1e                	js     800564 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800546:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054a:	74 d1                	je     80051d <vprintfmt+0x1d7>
  80054c:	0f be c0             	movsbl %al,%eax
  80054f:	83 e8 20             	sub    $0x20,%eax
  800552:	83 f8 5e             	cmp    $0x5e,%eax
  800555:	76 c6                	jbe    80051d <vprintfmt+0x1d7>
					putch('?', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	6a 3f                	push   $0x3f
  80055d:	ff d6                	call   *%esi
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	eb c3                	jmp    800527 <vprintfmt+0x1e1>
  800564:	89 cf                	mov    %ecx,%edi
  800566:	eb 0e                	jmp    800576 <vprintfmt+0x230>
				putch(' ', putdat);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	53                   	push   %ebx
  80056c:	6a 20                	push   $0x20
  80056e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800570:	83 ef 01             	sub    $0x1,%edi
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	85 ff                	test   %edi,%edi
  800578:	7f ee                	jg     800568 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80057a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
  800580:	e9 67 01 00 00       	jmp    8006ec <vprintfmt+0x3a6>
  800585:	89 cf                	mov    %ecx,%edi
  800587:	eb ed                	jmp    800576 <vprintfmt+0x230>
	if (lflag >= 2)
  800589:	83 f9 01             	cmp    $0x1,%ecx
  80058c:	7f 1b                	jg     8005a9 <vprintfmt+0x263>
	else if (lflag)
  80058e:	85 c9                	test   %ecx,%ecx
  800590:	74 63                	je     8005f5 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059a:	99                   	cltd   
  80059b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 40 04             	lea    0x4(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a7:	eb 17                	jmp    8005c0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 50 04             	mov    0x4(%eax),%edx
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 40 08             	lea    0x8(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005c0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	0f 89 ff 00 00 00    	jns    8006d2 <vprintfmt+0x38c>
				putch('-', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 2d                	push   $0x2d
  8005d9:	ff d6                	call   *%esi
				num = -(long long) num;
  8005db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005de:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e1:	f7 da                	neg    %edx
  8005e3:	83 d1 00             	adc    $0x0,%ecx
  8005e6:	f7 d9                	neg    %ecx
  8005e8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f0:	e9 dd 00 00 00       	jmp    8006d2 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	99                   	cltd   
  8005fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 40 04             	lea    0x4(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
  80060a:	eb b4                	jmp    8005c0 <vprintfmt+0x27a>
	if (lflag >= 2)
  80060c:	83 f9 01             	cmp    $0x1,%ecx
  80060f:	7f 1e                	jg     80062f <vprintfmt+0x2e9>
	else if (lflag)
  800611:	85 c9                	test   %ecx,%ecx
  800613:	74 32                	je     800647 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80062a:	e9 a3 00 00 00       	jmp    8006d2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	8b 48 04             	mov    0x4(%eax),%ecx
  800637:	8d 40 08             	lea    0x8(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800642:	e9 8b 00 00 00       	jmp    8006d2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 10                	mov    (%eax),%edx
  80064c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800651:	8d 40 04             	lea    0x4(%eax),%eax
  800654:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800657:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80065c:	eb 74                	jmp    8006d2 <vprintfmt+0x38c>
	if (lflag >= 2)
  80065e:	83 f9 01             	cmp    $0x1,%ecx
  800661:	7f 1b                	jg     80067e <vprintfmt+0x338>
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	74 2c                	je     800693 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800677:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80067c:	eb 54                	jmp    8006d2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	8b 48 04             	mov    0x4(%eax),%ecx
  800686:	8d 40 08             	lea    0x8(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80068c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800691:	eb 3f                	jmp    8006d2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8006a3:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006a8:	eb 28                	jmp    8006d2 <vprintfmt+0x38c>
			putch('0', putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	6a 30                	push   $0x30
  8006b0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b2:	83 c4 08             	add    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	6a 78                	push   $0x78
  8006b8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cd:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006d2:	83 ec 0c             	sub    $0xc,%esp
  8006d5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006d9:	57                   	push   %edi
  8006da:	ff 75 e0             	pushl  -0x20(%ebp)
  8006dd:	50                   	push   %eax
  8006de:	51                   	push   %ecx
  8006df:	52                   	push   %edx
  8006e0:	89 da                	mov    %ebx,%edx
  8006e2:	89 f0                	mov    %esi,%eax
  8006e4:	e8 72 fb ff ff       	call   80025b <printnum>
			break;
  8006e9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ef:	83 c7 01             	add    $0x1,%edi
  8006f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f6:	83 f8 25             	cmp    $0x25,%eax
  8006f9:	0f 84 62 fc ff ff    	je     800361 <vprintfmt+0x1b>
			if (ch == '\0')
  8006ff:	85 c0                	test   %eax,%eax
  800701:	0f 84 8b 00 00 00    	je     800792 <vprintfmt+0x44c>
			putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	50                   	push   %eax
  80070c:	ff d6                	call   *%esi
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb dc                	jmp    8006ef <vprintfmt+0x3a9>
	if (lflag >= 2)
  800713:	83 f9 01             	cmp    $0x1,%ecx
  800716:	7f 1b                	jg     800733 <vprintfmt+0x3ed>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	74 2c                	je     800748 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
  800726:	8d 40 04             	lea    0x4(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800731:	eb 9f                	jmp    8006d2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	8b 48 04             	mov    0x4(%eax),%ecx
  80073b:	8d 40 08             	lea    0x8(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800741:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800746:	eb 8a                	jmp    8006d2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800758:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80075d:	e9 70 ff ff ff       	jmp    8006d2 <vprintfmt+0x38c>
			putch(ch, putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 25                	push   $0x25
  800768:	ff d6                	call   *%esi
			break;
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	e9 7a ff ff ff       	jmp    8006ec <vprintfmt+0x3a6>
			putch('%', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	89 f8                	mov    %edi,%eax
  80077f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800783:	74 05                	je     80078a <vprintfmt+0x444>
  800785:	83 e8 01             	sub    $0x1,%eax
  800788:	eb f5                	jmp    80077f <vprintfmt+0x439>
  80078a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078d:	e9 5a ff ff ff       	jmp    8006ec <vprintfmt+0x3a6>
}
  800792:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5f                   	pop    %edi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079a:	f3 0f 1e fb          	endbr32 
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 18             	sub    $0x18,%esp
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	74 26                	je     8007e5 <vsnprintf+0x4b>
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	7e 22                	jle    8007e5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c3:	ff 75 14             	pushl  0x14(%ebp)
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	68 04 03 80 00       	push   $0x800304
  8007d2:	e8 6f fb ff ff       	call   800346 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e0:	83 c4 10             	add    $0x10,%esp
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
		return -E_INVAL;
  8007e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ea:	eb f7                	jmp    8007e3 <vsnprintf+0x49>

008007ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ec:	f3 0f 1e fb          	endbr32 
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f9:	50                   	push   %eax
  8007fa:	ff 75 10             	pushl  0x10(%ebp)
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	ff 75 08             	pushl  0x8(%ebp)
  800803:	e8 92 ff ff ff       	call   80079a <vsnprintf>
	va_end(ap);

	return rc;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080a:	f3 0f 1e fb          	endbr32 
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
  800819:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081d:	74 05                	je     800824 <strlen+0x1a>
		n++;
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	eb f5                	jmp    800819 <strlen+0xf>
	return n;
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800826:	f3 0f 1e fb          	endbr32 
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
  800838:	39 d0                	cmp    %edx,%eax
  80083a:	74 0d                	je     800849 <strnlen+0x23>
  80083c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800840:	74 05                	je     800847 <strnlen+0x21>
		n++;
  800842:	83 c0 01             	add    $0x1,%eax
  800845:	eb f1                	jmp    800838 <strnlen+0x12>
  800847:	89 c2                	mov    %eax,%edx
	return n;
}
  800849:	89 d0                	mov    %edx,%eax
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084d:	f3 0f 1e fb          	endbr32 
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
  800860:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800864:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800867:	83 c0 01             	add    $0x1,%eax
  80086a:	84 d2                	test   %dl,%dl
  80086c:	75 f2                	jne    800860 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80086e:	89 c8                	mov    %ecx,%eax
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800873:	f3 0f 1e fb          	endbr32 
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	83 ec 10             	sub    $0x10,%esp
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	53                   	push   %ebx
  800882:	e8 83 ff ff ff       	call   80080a <strlen>
  800887:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80088a:	ff 75 0c             	pushl  0xc(%ebp)
  80088d:	01 d8                	add    %ebx,%eax
  80088f:	50                   	push   %eax
  800890:	e8 b8 ff ff ff       	call   80084d <strcpy>
	return dst;
}
  800895:	89 d8                	mov    %ebx,%eax
  800897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089c:	f3 0f 1e fb          	endbr32 
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
  8008a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 f3                	mov    %esi,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b0:	89 f0                	mov    %esi,%eax
  8008b2:	39 d8                	cmp    %ebx,%eax
  8008b4:	74 11                	je     8008c7 <strncpy+0x2b>
		*dst++ = *src;
  8008b6:	83 c0 01             	add    $0x1,%eax
  8008b9:	0f b6 0a             	movzbl (%edx),%ecx
  8008bc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bf:	80 f9 01             	cmp    $0x1,%cl
  8008c2:	83 da ff             	sbb    $0xffffffff,%edx
  8008c5:	eb eb                	jmp    8008b2 <strncpy+0x16>
	}
	return ret;
}
  8008c7:	89 f0                	mov    %esi,%eax
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cd:	f3 0f 1e fb          	endbr32 
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	56                   	push   %esi
  8008d5:	53                   	push   %ebx
  8008d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dc:	8b 55 10             	mov    0x10(%ebp),%edx
  8008df:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	74 21                	je     800906 <strlcpy+0x39>
  8008e5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008eb:	39 c2                	cmp    %eax,%edx
  8008ed:	74 14                	je     800903 <strlcpy+0x36>
  8008ef:	0f b6 19             	movzbl (%ecx),%ebx
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	74 0b                	je     800901 <strlcpy+0x34>
			*dst++ = *src++;
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ff:	eb ea                	jmp    8008eb <strlcpy+0x1e>
  800901:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800903:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800906:	29 f0                	sub    %esi,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090c:	f3 0f 1e fb          	endbr32 
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800919:	0f b6 01             	movzbl (%ecx),%eax
  80091c:	84 c0                	test   %al,%al
  80091e:	74 0c                	je     80092c <strcmp+0x20>
  800920:	3a 02                	cmp    (%edx),%al
  800922:	75 08                	jne    80092c <strcmp+0x20>
		p++, q++;
  800924:	83 c1 01             	add    $0x1,%ecx
  800927:	83 c2 01             	add    $0x1,%edx
  80092a:	eb ed                	jmp    800919 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 c0             	movzbl %al,%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800936:	f3 0f 1e fb          	endbr32 
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
  800944:	89 c3                	mov    %eax,%ebx
  800946:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800949:	eb 06                	jmp    800951 <strncmp+0x1b>
		n--, p++, q++;
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800951:	39 d8                	cmp    %ebx,%eax
  800953:	74 16                	je     80096b <strncmp+0x35>
  800955:	0f b6 08             	movzbl (%eax),%ecx
  800958:	84 c9                	test   %cl,%cl
  80095a:	74 04                	je     800960 <strncmp+0x2a>
  80095c:	3a 0a                	cmp    (%edx),%cl
  80095e:	74 eb                	je     80094b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800960:	0f b6 00             	movzbl (%eax),%eax
  800963:	0f b6 12             	movzbl (%edx),%edx
  800966:	29 d0                	sub    %edx,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    
		return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
  800970:	eb f6                	jmp    800968 <strncmp+0x32>

00800972 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800972:	f3 0f 1e fb          	endbr32 
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800980:	0f b6 10             	movzbl (%eax),%edx
  800983:	84 d2                	test   %dl,%dl
  800985:	74 09                	je     800990 <strchr+0x1e>
		if (*s == c)
  800987:	38 ca                	cmp    %cl,%dl
  800989:	74 0a                	je     800995 <strchr+0x23>
	for (; *s; s++)
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	eb f0                	jmp    800980 <strchr+0xe>
			return (char *) s;
	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800997:	f3 0f 1e fb          	endbr32 
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 09                	je     8009b5 <strfind+0x1e>
  8009ac:	84 d2                	test   %dl,%dl
  8009ae:	74 05                	je     8009b5 <strfind+0x1e>
	for (; *s; s++)
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	eb f0                	jmp    8009a5 <strfind+0xe>
			break;
	return (char *) s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b7:	f3 0f 1e fb          	endbr32 
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 31                	je     8009fc <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	89 f8                	mov    %edi,%eax
  8009cd:	09 c8                	or     %ecx,%eax
  8009cf:	a8 03                	test   $0x3,%al
  8009d1:	75 23                	jne    8009f6 <memset+0x3f>
		c &= 0xFF;
  8009d3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d7:	89 d3                	mov    %edx,%ebx
  8009d9:	c1 e3 08             	shl    $0x8,%ebx
  8009dc:	89 d0                	mov    %edx,%eax
  8009de:	c1 e0 18             	shl    $0x18,%eax
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 10             	shl    $0x10,%esi
  8009e6:	09 f0                	or     %esi,%eax
  8009e8:	09 c2                	or     %eax,%edx
  8009ea:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	fc                   	cld    
  8009f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f4:	eb 06                	jmp    8009fc <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f9:	fc                   	cld    
  8009fa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fc:	89 f8                	mov    %edi,%eax
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a03:	f3 0f 1e fb          	endbr32 
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a15:	39 c6                	cmp    %eax,%esi
  800a17:	73 32                	jae    800a4b <memmove+0x48>
  800a19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1c:	39 c2                	cmp    %eax,%edx
  800a1e:	76 2b                	jbe    800a4b <memmove+0x48>
		s += n;
		d += n;
  800a20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a23:	89 fe                	mov    %edi,%esi
  800a25:	09 ce                	or     %ecx,%esi
  800a27:	09 d6                	or     %edx,%esi
  800a29:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2f:	75 0e                	jne    800a3f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a31:	83 ef 04             	sub    $0x4,%edi
  800a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a37:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 09                	jmp    800a48 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	83 ef 01             	sub    $0x1,%edi
  800a42:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a45:	fd                   	std    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a48:	fc                   	cld    
  800a49:	eb 1a                	jmp    800a65 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	09 ca                	or     %ecx,%edx
  800a4f:	09 f2                	or     %esi,%edx
  800a51:	f6 c2 03             	test   $0x3,%dl
  800a54:	75 0a                	jne    800a60 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a56:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a59:	89 c7                	mov    %eax,%edi
  800a5b:	fc                   	cld    
  800a5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5e:	eb 05                	jmp    800a65 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a69:	f3 0f 1e fb          	endbr32 
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 82 ff ff ff       	call   800a03 <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	f3 0f 1e fb          	endbr32 
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a97:	39 f0                	cmp    %esi,%eax
  800a99:	74 1c                	je     800ab7 <memcmp+0x34>
		if (*s1 != *s2)
  800a9b:	0f b6 08             	movzbl (%eax),%ecx
  800a9e:	0f b6 1a             	movzbl (%edx),%ebx
  800aa1:	38 d9                	cmp    %bl,%cl
  800aa3:	75 08                	jne    800aad <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	eb ea                	jmp    800a97 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aad:	0f b6 c1             	movzbl %cl,%eax
  800ab0:	0f b6 db             	movzbl %bl,%ebx
  800ab3:	29 d8                	sub    %ebx,%eax
  800ab5:	eb 05                	jmp    800abc <memcmp+0x39>
	}

	return 0;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac0:	f3 0f 1e fb          	endbr32 
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad2:	39 d0                	cmp    %edx,%eax
  800ad4:	73 09                	jae    800adf <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	38 08                	cmp    %cl,(%eax)
  800ad8:	74 05                	je     800adf <memfind+0x1f>
	for (; s < ends; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	eb f3                	jmp    800ad2 <memfind+0x12>
			break;
	return (void *) s;
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae1:	f3 0f 1e fb          	endbr32 
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af1:	eb 03                	jmp    800af6 <strtol+0x15>
		s++;
  800af3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800af6:	0f b6 01             	movzbl (%ecx),%eax
  800af9:	3c 20                	cmp    $0x20,%al
  800afb:	74 f6                	je     800af3 <strtol+0x12>
  800afd:	3c 09                	cmp    $0x9,%al
  800aff:	74 f2                	je     800af3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b01:	3c 2b                	cmp    $0x2b,%al
  800b03:	74 2a                	je     800b2f <strtol+0x4e>
	int neg = 0;
  800b05:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b0a:	3c 2d                	cmp    $0x2d,%al
  800b0c:	74 2b                	je     800b39 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b14:	75 0f                	jne    800b25 <strtol+0x44>
  800b16:	80 39 30             	cmpb   $0x30,(%ecx)
  800b19:	74 28                	je     800b43 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b22:	0f 44 d8             	cmove  %eax,%ebx
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b2d:	eb 46                	jmp    800b75 <strtol+0x94>
		s++;
  800b2f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
  800b37:	eb d5                	jmp    800b0e <strtol+0x2d>
		s++, neg = 1;
  800b39:	83 c1 01             	add    $0x1,%ecx
  800b3c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b41:	eb cb                	jmp    800b0e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b43:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b47:	74 0e                	je     800b57 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b49:	85 db                	test   %ebx,%ebx
  800b4b:	75 d8                	jne    800b25 <strtol+0x44>
		s++, base = 8;
  800b4d:	83 c1 01             	add    $0x1,%ecx
  800b50:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b55:	eb ce                	jmp    800b25 <strtol+0x44>
		s += 2, base = 16;
  800b57:	83 c1 02             	add    $0x2,%ecx
  800b5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b5f:	eb c4                	jmp    800b25 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b61:	0f be d2             	movsbl %dl,%edx
  800b64:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b67:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6a:	7d 3a                	jge    800ba6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b6c:	83 c1 01             	add    $0x1,%ecx
  800b6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b73:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b75:	0f b6 11             	movzbl (%ecx),%edx
  800b78:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7b:	89 f3                	mov    %esi,%ebx
  800b7d:	80 fb 09             	cmp    $0x9,%bl
  800b80:	76 df                	jbe    800b61 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b82:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b85:	89 f3                	mov    %esi,%ebx
  800b87:	80 fb 19             	cmp    $0x19,%bl
  800b8a:	77 08                	ja     800b94 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b8c:	0f be d2             	movsbl %dl,%edx
  800b8f:	83 ea 57             	sub    $0x57,%edx
  800b92:	eb d3                	jmp    800b67 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b94:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b97:	89 f3                	mov    %esi,%ebx
  800b99:	80 fb 19             	cmp    $0x19,%bl
  800b9c:	77 08                	ja     800ba6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b9e:	0f be d2             	movsbl %dl,%edx
  800ba1:	83 ea 37             	sub    $0x37,%edx
  800ba4:	eb c1                	jmp    800b67 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800baa:	74 05                	je     800bb1 <strtol+0xd0>
		*endptr = (char *) s;
  800bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800baf:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bb1:	89 c2                	mov    %eax,%edx
  800bb3:	f7 da                	neg    %edx
  800bb5:	85 ff                	test   %edi,%edi
  800bb7:	0f 45 c2             	cmovne %edx,%eax
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    
  800bbf:	90                   	nop

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
