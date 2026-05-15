
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003d:	6a 64                	push   $0x64
  80003f:	68 0c 00 10 f0       	push   $0xf010000c
  800044:	e8 72 00 00 00       	call   8000bb <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800064:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  800067:	e8 d9 00 00 00       	call   800145 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800074:	c1 e0 05             	shl    $0x5,%eax
  800077:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800081:	85 db                	test   %ebx,%ebx
  800083:	7e 07                	jle    80008c <libmain+0x3e>
		binaryname = argv[0];
  800085:	8b 06                	mov    (%esi),%eax
  800087:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008c:	83 ec 08             	sub    $0x8,%esp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	e8 9d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800096:	e8 0a 00 00 00       	call   8000a5 <exit>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    

008000a5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a5:	f3 0f 1e fb          	endbr32 
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000af:	6a 00                	push   $0x0
  8000b1:	e8 4a 00 00 00       	call   800100 <sys_env_destroy>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bb:	f3 0f 1e fb          	endbr32 
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d0:	89 c3                	mov    %eax,%ebx
  8000d2:	89 c7                	mov    %eax,%edi
  8000d4:	89 c6                	mov    %eax,%esi
  8000d6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000dd:	f3 0f 1e fb          	endbr32 
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f1:	89 d1                	mov    %edx,%ecx
  8000f3:	89 d3                	mov    %edx,%ebx
  8000f5:	89 d7                	mov    %edx,%edi
  8000f7:	89 d6                	mov    %edx,%esi
  8000f9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800100:	f3 0f 1e fb          	endbr32 
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
  80010a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800112:	8b 55 08             	mov    0x8(%ebp),%edx
  800115:	b8 03 00 00 00       	mov    $0x3,%eax
  80011a:	89 cb                	mov    %ecx,%ebx
  80011c:	89 cf                	mov    %ecx,%edi
  80011e:	89 ce                	mov    %ecx,%esi
  800120:	cd 30                	int    $0x30
	if(check && ret > 0)
  800122:	85 c0                	test   %eax,%eax
  800124:	7f 08                	jg     80012e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012e:	83 ec 0c             	sub    $0xc,%esp
  800131:	50                   	push   %eax
  800132:	6a 03                	push   $0x3
  800134:	68 3a 0e 80 00       	push   $0x800e3a
  800139:	6a 23                	push   $0x23
  80013b:	68 57 0e 80 00       	push   $0x800e57
  800140:	e8 23 00 00 00       	call   800168 <_panic>

00800145 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800145:	f3 0f 1e fb          	endbr32 
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 02 00 00 00       	mov    $0x2,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800168:	f3 0f 1e fb          	endbr32 
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800171:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800174:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80017a:	e8 c6 ff ff ff       	call   800145 <sys_getenvid>
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 0c             	pushl  0xc(%ebp)
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	56                   	push   %esi
  800189:	50                   	push   %eax
  80018a:	68 68 0e 80 00       	push   $0x800e68
  80018f:	e8 bb 00 00 00       	call   80024f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	83 c4 18             	add    $0x18,%esp
  800197:	53                   	push   %ebx
  800198:	ff 75 10             	pushl  0x10(%ebp)
  80019b:	e8 5a 00 00 00       	call   8001fa <vcprintf>
	cprintf("\n");
  8001a0:	c7 04 24 8b 0e 80 00 	movl   $0x800e8b,(%esp)
  8001a7:	e8 a3 00 00 00       	call   80024f <cprintf>
  8001ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x47>

008001b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b2:	f3 0f 1e fb          	endbr32 
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 04             	sub    $0x4,%esp
  8001bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c0:	8b 13                	mov    (%ebx),%edx
  8001c2:	8d 42 01             	lea    0x1(%edx),%eax
  8001c5:	89 03                	mov    %eax,(%ebx)
  8001c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d3:	74 09                	je     8001de <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001dc:	c9                   	leave  
  8001dd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	68 ff 00 00 00       	push   $0xff
  8001e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e9:	50                   	push   %eax
  8001ea:	e8 cc fe ff ff       	call   8000bb <sys_cputs>
		b->idx = 0;
  8001ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f5:	83 c4 10             	add    $0x10,%esp
  8001f8:	eb db                	jmp    8001d5 <putch+0x23>

008001fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fa:	f3 0f 1e fb          	endbr32 
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800207:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020e:	00 00 00 
	b.cnt = 0;
  800211:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800218:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021b:	ff 75 0c             	pushl  0xc(%ebp)
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800227:	50                   	push   %eax
  800228:	68 b2 01 80 00       	push   $0x8001b2
  80022d:	e8 20 01 00 00       	call   800352 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800232:	83 c4 08             	add    $0x8,%esp
  800235:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800241:	50                   	push   %eax
  800242:	e8 74 fe ff ff       	call   8000bb <sys_cputs>

	return b.cnt;
}
  800247:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024f:	f3 0f 1e fb          	endbr32 
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800259:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	e8 95 ff ff ff       	call   8001fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 1c             	sub    $0x1c,%esp
  800270:	89 c7                	mov    %eax,%edi
  800272:	89 d6                	mov    %edx,%esi
  800274:	8b 45 08             	mov    0x8(%ebp),%eax
  800277:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027a:	89 d1                	mov    %edx,%ecx
  80027c:	89 c2                	mov    %eax,%edx
  80027e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800281:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800284:	8b 45 10             	mov    0x10(%ebp),%eax
  800287:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800294:	39 c2                	cmp    %eax,%edx
  800296:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800299:	72 3e                	jb     8002d9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	53                   	push   %ebx
  8002a5:	50                   	push   %eax
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8002af:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b5:	e8 16 09 00 00       	call   800bd0 <__udivdi3>
  8002ba:	83 c4 18             	add    $0x18,%esp
  8002bd:	52                   	push   %edx
  8002be:	50                   	push   %eax
  8002bf:	89 f2                	mov    %esi,%edx
  8002c1:	89 f8                	mov    %edi,%eax
  8002c3:	e8 9f ff ff ff       	call   800267 <printnum>
  8002c8:	83 c4 20             	add    $0x20,%esp
  8002cb:	eb 13                	jmp    8002e0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	56                   	push   %esi
  8002d1:	ff 75 18             	pushl  0x18(%ebp)
  8002d4:	ff d7                	call   *%edi
  8002d6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002d9:	83 eb 01             	sub    $0x1,%ebx
  8002dc:	85 db                	test   %ebx,%ebx
  8002de:	7f ed                	jg     8002cd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	56                   	push   %esi
  8002e4:	83 ec 04             	sub    $0x4,%esp
  8002e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f3:	e8 e8 09 00 00       	call   800ce0 <__umoddi3>
  8002f8:	83 c4 14             	add    $0x14,%esp
  8002fb:	0f be 80 8d 0e 80 00 	movsbl 0x800e8d(%eax),%eax
  800302:	50                   	push   %eax
  800303:	ff d7                	call   *%edi
}
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030b:	5b                   	pop    %ebx
  80030c:	5e                   	pop    %esi
  80030d:	5f                   	pop    %edi
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800310:	f3 0f 1e fb          	endbr32 
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	3b 50 04             	cmp    0x4(%eax),%edx
  800323:	73 0a                	jae    80032f <sprintputch+0x1f>
		*b->buf++ = ch;
  800325:	8d 4a 01             	lea    0x1(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	88 02                	mov    %al,(%edx)
}
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <printfmt>:
{
  800331:	f3 0f 1e fb          	endbr32 
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80033b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033e:	50                   	push   %eax
  80033f:	ff 75 10             	pushl  0x10(%ebp)
  800342:	ff 75 0c             	pushl  0xc(%ebp)
  800345:	ff 75 08             	pushl  0x8(%ebp)
  800348:	e8 05 00 00 00       	call   800352 <vprintfmt>
}
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	c9                   	leave  
  800351:	c3                   	ret    

00800352 <vprintfmt>:
{
  800352:	f3 0f 1e fb          	endbr32 
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	57                   	push   %edi
  80035a:	56                   	push   %esi
  80035b:	53                   	push   %ebx
  80035c:	83 ec 3c             	sub    $0x3c,%esp
  80035f:	8b 75 08             	mov    0x8(%ebp),%esi
  800362:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800365:	8b 7d 10             	mov    0x10(%ebp),%edi
  800368:	e9 8e 03 00 00       	jmp    8006fb <vprintfmt+0x3a9>
		padc = ' ';
  80036d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800371:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800378:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80037f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800386:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8d 47 01             	lea    0x1(%edi),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	0f b6 17             	movzbl (%edi),%edx
  800394:	8d 42 dd             	lea    -0x23(%edx),%eax
  800397:	3c 55                	cmp    $0x55,%al
  800399:	0f 87 df 03 00 00    	ja     80077e <vprintfmt+0x42c>
  80039f:	0f b6 c0             	movzbl %al,%eax
  8003a2:	3e ff 24 85 1c 0f 80 	notrack jmp *0x800f1c(,%eax,4)
  8003a9:	00 
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003ad:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003b1:	eb d8                	jmp    80038b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003ba:	eb cf                	jmp    80038b <vprintfmt+0x39>
  8003bc:	0f b6 d2             	movzbl %dl,%edx
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003d1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003d4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003d7:	83 f9 09             	cmp    $0x9,%ecx
  8003da:	77 55                	ja     800431 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003df:	eb e9                	jmp    8003ca <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8b 00                	mov    (%eax),%eax
  8003e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 40 04             	lea    0x4(%eax),%eax
  8003ef:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f9:	79 90                	jns    80038b <vprintfmt+0x39>
				width = precision, precision = -1;
  8003fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800401:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800408:	eb 81                	jmp    80038b <vprintfmt+0x39>
  80040a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040d:	85 c0                	test   %eax,%eax
  80040f:	ba 00 00 00 00       	mov    $0x0,%edx
  800414:	0f 49 d0             	cmovns %eax,%edx
  800417:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041d:	e9 69 ff ff ff       	jmp    80038b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800425:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80042c:	e9 5a ff ff ff       	jmp    80038b <vprintfmt+0x39>
  800431:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800434:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800437:	eb bc                	jmp    8003f5 <vprintfmt+0xa3>
			lflag++;
  800439:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80043f:	e9 47 ff ff ff       	jmp    80038b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 78 04             	lea    0x4(%eax),%edi
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 30                	pushl  (%eax)
  800450:	ff d6                	call   *%esi
			break;
  800452:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800455:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800458:	e9 9b 02 00 00       	jmp    8006f8 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 78 04             	lea    0x4(%eax),%edi
  800463:	8b 00                	mov    (%eax),%eax
  800465:	99                   	cltd   
  800466:	31 d0                	xor    %edx,%eax
  800468:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046a:	83 f8 06             	cmp    $0x6,%eax
  80046d:	7f 23                	jg     800492 <vprintfmt+0x140>
  80046f:	8b 14 85 74 10 80 00 	mov    0x801074(,%eax,4),%edx
  800476:	85 d2                	test   %edx,%edx
  800478:	74 18                	je     800492 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80047a:	52                   	push   %edx
  80047b:	68 ae 0e 80 00       	push   $0x800eae
  800480:	53                   	push   %ebx
  800481:	56                   	push   %esi
  800482:	e8 aa fe ff ff       	call   800331 <printfmt>
  800487:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80048d:	e9 66 02 00 00       	jmp    8006f8 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800492:	50                   	push   %eax
  800493:	68 a5 0e 80 00       	push   $0x800ea5
  800498:	53                   	push   %ebx
  800499:	56                   	push   %esi
  80049a:	e8 92 fe ff ff       	call   800331 <printfmt>
  80049f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004a2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004a5:	e9 4e 02 00 00       	jmp    8006f8 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	83 c0 04             	add    $0x4,%eax
  8004b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	b8 9e 0e 80 00       	mov    $0x800e9e,%eax
  8004bf:	0f 45 c2             	cmovne %edx,%eax
  8004c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	7e 06                	jle    8004d1 <vprintfmt+0x17f>
  8004cb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004cf:	75 0d                	jne    8004de <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d4:	89 c7                	mov    %eax,%edi
  8004d6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dc:	eb 55                	jmp    800533 <vprintfmt+0x1e1>
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e4:	ff 75 cc             	pushl  -0x34(%ebp)
  8004e7:	e8 46 03 00 00       	call   800832 <strnlen>
  8004ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ef:	29 c2                	sub    %eax,%edx
  8004f1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004f9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	85 ff                	test   %edi,%edi
  800502:	7e 11                	jle    800515 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	ff 75 e0             	pushl  -0x20(%ebp)
  80050b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	83 ef 01             	sub    $0x1,%edi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb eb                	jmp    800500 <vprintfmt+0x1ae>
  800515:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800518:	85 d2                	test   %edx,%edx
  80051a:	b8 00 00 00 00       	mov    $0x0,%eax
  80051f:	0f 49 c2             	cmovns %edx,%eax
  800522:	29 c2                	sub    %eax,%edx
  800524:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800527:	eb a8                	jmp    8004d1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	52                   	push   %edx
  80052e:	ff d6                	call   *%esi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800536:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800538:	83 c7 01             	add    $0x1,%edi
  80053b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053f:	0f be d0             	movsbl %al,%edx
  800542:	85 d2                	test   %edx,%edx
  800544:	74 4b                	je     800591 <vprintfmt+0x23f>
  800546:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054a:	78 06                	js     800552 <vprintfmt+0x200>
  80054c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800550:	78 1e                	js     800570 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800556:	74 d1                	je     800529 <vprintfmt+0x1d7>
  800558:	0f be c0             	movsbl %al,%eax
  80055b:	83 e8 20             	sub    $0x20,%eax
  80055e:	83 f8 5e             	cmp    $0x5e,%eax
  800561:	76 c6                	jbe    800529 <vprintfmt+0x1d7>
					putch('?', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	6a 3f                	push   $0x3f
  800569:	ff d6                	call   *%esi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb c3                	jmp    800533 <vprintfmt+0x1e1>
  800570:	89 cf                	mov    %ecx,%edi
  800572:	eb 0e                	jmp    800582 <vprintfmt+0x230>
				putch(' ', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	53                   	push   %ebx
  800578:	6a 20                	push   $0x20
  80057a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80057c:	83 ef 01             	sub    $0x1,%edi
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	85 ff                	test   %edi,%edi
  800584:	7f ee                	jg     800574 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800586:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
  80058c:	e9 67 01 00 00       	jmp    8006f8 <vprintfmt+0x3a6>
  800591:	89 cf                	mov    %ecx,%edi
  800593:	eb ed                	jmp    800582 <vprintfmt+0x230>
	if (lflag >= 2)
  800595:	83 f9 01             	cmp    $0x1,%ecx
  800598:	7f 1b                	jg     8005b5 <vprintfmt+0x263>
	else if (lflag)
  80059a:	85 c9                	test   %ecx,%ecx
  80059c:	74 63                	je     800601 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	99                   	cltd   
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 40 04             	lea    0x4(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b3:	eb 17                	jmp    8005cc <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 50 04             	mov    0x4(%eax),%edx
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	0f 89 ff 00 00 00    	jns    8006de <vprintfmt+0x38c>
				putch('-', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	6a 2d                	push   $0x2d
  8005e5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ed:	f7 da                	neg    %edx
  8005ef:	83 d1 00             	adc    $0x0,%ecx
  8005f2:	f7 d9                	neg    %ecx
  8005f4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fc:	e9 dd 00 00 00       	jmp    8006de <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	99                   	cltd   
  80060a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 40 04             	lea    0x4(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
  800616:	eb b4                	jmp    8005cc <vprintfmt+0x27a>
	if (lflag >= 2)
  800618:	83 f9 01             	cmp    $0x1,%ecx
  80061b:	7f 1e                	jg     80063b <vprintfmt+0x2e9>
	else if (lflag)
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	74 32                	je     800653 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062b:	8d 40 04             	lea    0x4(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800636:	e9 a3 00 00 00       	jmp    8006de <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	8b 48 04             	mov    0x4(%eax),%ecx
  800643:	8d 40 08             	lea    0x8(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80064e:	e9 8b 00 00 00       	jmp    8006de <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800663:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800668:	eb 74                	jmp    8006de <vprintfmt+0x38c>
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7f 1b                	jg     80068a <vprintfmt+0x338>
	else if (lflag)
  80066f:	85 c9                	test   %ecx,%ecx
  800671:	74 2c                	je     80069f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800683:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800688:	eb 54                	jmp    8006de <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	8b 48 04             	mov    0x4(%eax),%ecx
  800692:	8d 40 08             	lea    0x8(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800698:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80069d:	eb 3f                	jmp    8006de <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8006af:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006b4:	eb 28                	jmp    8006de <vprintfmt+0x38c>
			putch('0', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 30                	push   $0x30
  8006bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8006be:	83 c4 08             	add    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 78                	push   $0x78
  8006c4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 10                	mov    (%eax),%edx
  8006cb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006d0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006de:	83 ec 0c             	sub    $0xc,%esp
  8006e1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006e5:	57                   	push   %edi
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	50                   	push   %eax
  8006ea:	51                   	push   %ecx
  8006eb:	52                   	push   %edx
  8006ec:	89 da                	mov    %ebx,%edx
  8006ee:	89 f0                	mov    %esi,%eax
  8006f0:	e8 72 fb ff ff       	call   800267 <printnum>
			break;
  8006f5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006fb:	83 c7 01             	add    $0x1,%edi
  8006fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800702:	83 f8 25             	cmp    $0x25,%eax
  800705:	0f 84 62 fc ff ff    	je     80036d <vprintfmt+0x1b>
			if (ch == '\0')
  80070b:	85 c0                	test   %eax,%eax
  80070d:	0f 84 8b 00 00 00    	je     80079e <vprintfmt+0x44c>
			putch(ch, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	50                   	push   %eax
  800718:	ff d6                	call   *%esi
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb dc                	jmp    8006fb <vprintfmt+0x3a9>
	if (lflag >= 2)
  80071f:	83 f9 01             	cmp    $0x1,%ecx
  800722:	7f 1b                	jg     80073f <vprintfmt+0x3ed>
	else if (lflag)
  800724:	85 c9                	test   %ecx,%ecx
  800726:	74 2c                	je     800754 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800738:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80073d:	eb 9f                	jmp    8006de <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8b 10                	mov    (%eax),%edx
  800744:	8b 48 04             	mov    0x4(%eax),%ecx
  800747:	8d 40 08             	lea    0x8(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800752:	eb 8a                	jmp    8006de <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 10                	mov    (%eax),%edx
  800759:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075e:	8d 40 04             	lea    0x4(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800764:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800769:	e9 70 ff ff ff       	jmp    8006de <vprintfmt+0x38c>
			putch(ch, putdat);
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 25                	push   $0x25
  800774:	ff d6                	call   *%esi
			break;
  800776:	83 c4 10             	add    $0x10,%esp
  800779:	e9 7a ff ff ff       	jmp    8006f8 <vprintfmt+0x3a6>
			putch('%', putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	53                   	push   %ebx
  800782:	6a 25                	push   $0x25
  800784:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	89 f8                	mov    %edi,%eax
  80078b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80078f:	74 05                	je     800796 <vprintfmt+0x444>
  800791:	83 e8 01             	sub    $0x1,%eax
  800794:	eb f5                	jmp    80078b <vprintfmt+0x439>
  800796:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800799:	e9 5a ff ff ff       	jmp    8006f8 <vprintfmt+0x3a6>
}
  80079e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5f                   	pop    %edi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a6:	f3 0f 1e fb          	endbr32 
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 18             	sub    $0x18,%esp
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	74 26                	je     8007f1 <vsnprintf+0x4b>
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	7e 22                	jle    8007f1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cf:	ff 75 14             	pushl  0x14(%ebp)
  8007d2:	ff 75 10             	pushl  0x10(%ebp)
  8007d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d8:	50                   	push   %eax
  8007d9:	68 10 03 80 00       	push   $0x800310
  8007de:	e8 6f fb ff ff       	call   800352 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ec:	83 c4 10             	add    $0x10,%esp
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    
		return -E_INVAL;
  8007f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f6:	eb f7                	jmp    8007ef <vsnprintf+0x49>

008007f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f8:	f3 0f 1e fb          	endbr32 
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800802:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800805:	50                   	push   %eax
  800806:	ff 75 10             	pushl  0x10(%ebp)
  800809:	ff 75 0c             	pushl  0xc(%ebp)
  80080c:	ff 75 08             	pushl  0x8(%ebp)
  80080f:	e8 92 ff ff ff       	call   8007a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800816:	f3 0f 1e fb          	endbr32 
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800829:	74 05                	je     800830 <strlen+0x1a>
		n++;
  80082b:	83 c0 01             	add    $0x1,%eax
  80082e:	eb f5                	jmp    800825 <strlen+0xf>
	return n;
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800832:	f3 0f 1e fb          	endbr32 
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
  800844:	39 d0                	cmp    %edx,%eax
  800846:	74 0d                	je     800855 <strnlen+0x23>
  800848:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084c:	74 05                	je     800853 <strnlen+0x21>
		n++;
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	eb f1                	jmp    800844 <strnlen+0x12>
  800853:	89 c2                	mov    %eax,%edx
	return n;
}
  800855:	89 d0                	mov    %edx,%eax
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800859:	f3 0f 1e fb          	endbr32 
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	53                   	push   %ebx
  800861:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800864:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
  80086c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800870:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	84 d2                	test   %dl,%dl
  800878:	75 f2                	jne    80086c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80087a:	89 c8                	mov    %ecx,%eax
  80087c:	5b                   	pop    %ebx
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087f:	f3 0f 1e fb          	endbr32 
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	83 ec 10             	sub    $0x10,%esp
  80088a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088d:	53                   	push   %ebx
  80088e:	e8 83 ff ff ff       	call   800816 <strlen>
  800893:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800896:	ff 75 0c             	pushl  0xc(%ebp)
  800899:	01 d8                	add    %ebx,%eax
  80089b:	50                   	push   %eax
  80089c:	e8 b8 ff ff ff       	call   800859 <strcpy>
	return dst;
}
  8008a1:	89 d8                	mov    %ebx,%eax
  8008a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a8:	f3 0f 1e fb          	endbr32 
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	56                   	push   %esi
  8008b0:	53                   	push   %ebx
  8008b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b7:	89 f3                	mov    %esi,%ebx
  8008b9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	39 d8                	cmp    %ebx,%eax
  8008c0:	74 11                	je     8008d3 <strncpy+0x2b>
		*dst++ = *src;
  8008c2:	83 c0 01             	add    $0x1,%eax
  8008c5:	0f b6 0a             	movzbl (%edx),%ecx
  8008c8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cb:	80 f9 01             	cmp    $0x1,%cl
  8008ce:	83 da ff             	sbb    $0xffffffff,%edx
  8008d1:	eb eb                	jmp    8008be <strncpy+0x16>
	}
	return ret;
}
  8008d3:	89 f0                	mov    %esi,%eax
  8008d5:	5b                   	pop    %ebx
  8008d6:	5e                   	pop    %esi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d9:	f3 0f 1e fb          	endbr32 
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e8:	8b 55 10             	mov    0x10(%ebp),%edx
  8008eb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ed:	85 d2                	test   %edx,%edx
  8008ef:	74 21                	je     800912 <strlcpy+0x39>
  8008f1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008f7:	39 c2                	cmp    %eax,%edx
  8008f9:	74 14                	je     80090f <strlcpy+0x36>
  8008fb:	0f b6 19             	movzbl (%ecx),%ebx
  8008fe:	84 db                	test   %bl,%bl
  800900:	74 0b                	je     80090d <strlcpy+0x34>
			*dst++ = *src++;
  800902:	83 c1 01             	add    $0x1,%ecx
  800905:	83 c2 01             	add    $0x1,%edx
  800908:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090b:	eb ea                	jmp    8008f7 <strlcpy+0x1e>
  80090d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80090f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800912:	29 f0                	sub    %esi,%eax
}
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800918:	f3 0f 1e fb          	endbr32 
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800925:	0f b6 01             	movzbl (%ecx),%eax
  800928:	84 c0                	test   %al,%al
  80092a:	74 0c                	je     800938 <strcmp+0x20>
  80092c:	3a 02                	cmp    (%edx),%al
  80092e:	75 08                	jne    800938 <strcmp+0x20>
		p++, q++;
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	83 c2 01             	add    $0x1,%edx
  800936:	eb ed                	jmp    800925 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 c0             	movzbl %al,%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800942:	f3 0f 1e fb          	endbr32 
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800955:	eb 06                	jmp    80095d <strncmp+0x1b>
		n--, p++, q++;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	74 16                	je     800977 <strncmp+0x35>
  800961:	0f b6 08             	movzbl (%eax),%ecx
  800964:	84 c9                	test   %cl,%cl
  800966:	74 04                	je     80096c <strncmp+0x2a>
  800968:	3a 0a                	cmp    (%edx),%cl
  80096a:	74 eb                	je     800957 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	0f b6 12             	movzbl (%edx),%edx
  800972:	29 d0                	sub    %edx,%eax
}
  800974:	5b                   	pop    %ebx
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    
		return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
  80097c:	eb f6                	jmp    800974 <strncmp+0x32>

0080097e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097e:	f3 0f 1e fb          	endbr32 
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098c:	0f b6 10             	movzbl (%eax),%edx
  80098f:	84 d2                	test   %dl,%dl
  800991:	74 09                	je     80099c <strchr+0x1e>
		if (*s == c)
  800993:	38 ca                	cmp    %cl,%dl
  800995:	74 0a                	je     8009a1 <strchr+0x23>
	for (; *s; s++)
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	eb f0                	jmp    80098c <strchr+0xe>
			return (char *) s;
	return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a3:	f3 0f 1e fb          	endbr32 
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b4:	38 ca                	cmp    %cl,%dl
  8009b6:	74 09                	je     8009c1 <strfind+0x1e>
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 05                	je     8009c1 <strfind+0x1e>
	for (; *s; s++)
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	eb f0                	jmp    8009b1 <strfind+0xe>
			break;
	return (char *) s;
}
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c3:	f3 0f 1e fb          	endbr32 
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	74 31                	je     800a08 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d7:	89 f8                	mov    %edi,%eax
  8009d9:	09 c8                	or     %ecx,%eax
  8009db:	a8 03                	test   $0x3,%al
  8009dd:	75 23                	jne    800a02 <memset+0x3f>
		c &= 0xFF;
  8009df:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e3:	89 d3                	mov    %edx,%ebx
  8009e5:	c1 e3 08             	shl    $0x8,%ebx
  8009e8:	89 d0                	mov    %edx,%eax
  8009ea:	c1 e0 18             	shl    $0x18,%eax
  8009ed:	89 d6                	mov    %edx,%esi
  8009ef:	c1 e6 10             	shl    $0x10,%esi
  8009f2:	09 f0                	or     %esi,%eax
  8009f4:	09 c2                	or     %eax,%edx
  8009f6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	fc                   	cld    
  8009fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800a00:	eb 06                	jmp    800a08 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a05:	fc                   	cld    
  800a06:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a08:	89 f8                	mov    %edi,%eax
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0f:	f3 0f 1e fb          	endbr32 
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a21:	39 c6                	cmp    %eax,%esi
  800a23:	73 32                	jae    800a57 <memmove+0x48>
  800a25:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a28:	39 c2                	cmp    %eax,%edx
  800a2a:	76 2b                	jbe    800a57 <memmove+0x48>
		s += n;
		d += n;
  800a2c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2f:	89 fe                	mov    %edi,%esi
  800a31:	09 ce                	or     %ecx,%esi
  800a33:	09 d6                	or     %edx,%esi
  800a35:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3b:	75 0e                	jne    800a4b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a3d:	83 ef 04             	sub    $0x4,%edi
  800a40:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a43:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a46:	fd                   	std    
  800a47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a49:	eb 09                	jmp    800a54 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a4b:	83 ef 01             	sub    $0x1,%edi
  800a4e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a51:	fd                   	std    
  800a52:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a54:	fc                   	cld    
  800a55:	eb 1a                	jmp    800a71 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a57:	89 c2                	mov    %eax,%edx
  800a59:	09 ca                	or     %ecx,%edx
  800a5b:	09 f2                	or     %esi,%edx
  800a5d:	f6 c2 03             	test   $0x3,%dl
  800a60:	75 0a                	jne    800a6c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a62:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a65:	89 c7                	mov    %eax,%edi
  800a67:	fc                   	cld    
  800a68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6a:	eb 05                	jmp    800a71 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a75:	f3 0f 1e fb          	endbr32 
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a7f:	ff 75 10             	pushl  0x10(%ebp)
  800a82:	ff 75 0c             	pushl  0xc(%ebp)
  800a85:	ff 75 08             	pushl  0x8(%ebp)
  800a88:	e8 82 ff ff ff       	call   800a0f <memmove>
}
  800a8d:	c9                   	leave  
  800a8e:	c3                   	ret    

00800a8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8f:	f3 0f 1e fb          	endbr32 
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9e:	89 c6                	mov    %eax,%esi
  800aa0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa3:	39 f0                	cmp    %esi,%eax
  800aa5:	74 1c                	je     800ac3 <memcmp+0x34>
		if (*s1 != *s2)
  800aa7:	0f b6 08             	movzbl (%eax),%ecx
  800aaa:	0f b6 1a             	movzbl (%edx),%ebx
  800aad:	38 d9                	cmp    %bl,%cl
  800aaf:	75 08                	jne    800ab9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	83 c2 01             	add    $0x1,%edx
  800ab7:	eb ea                	jmp    800aa3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c1             	movzbl %cl,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 05                	jmp    800ac8 <memcmp+0x39>
	}

	return 0;
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800acc:	f3 0f 1e fb          	endbr32 
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ad9:	89 c2                	mov    %eax,%edx
  800adb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ade:	39 d0                	cmp    %edx,%eax
  800ae0:	73 09                	jae    800aeb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	38 08                	cmp    %cl,(%eax)
  800ae4:	74 05                	je     800aeb <memfind+0x1f>
	for (; s < ends; s++)
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	eb f3                	jmp    800ade <memfind+0x12>
			break;
	return (void *) s;
}
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aed:	f3 0f 1e fb          	endbr32 
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	57                   	push   %edi
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afd:	eb 03                	jmp    800b02 <strtol+0x15>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b02:	0f b6 01             	movzbl (%ecx),%eax
  800b05:	3c 20                	cmp    $0x20,%al
  800b07:	74 f6                	je     800aff <strtol+0x12>
  800b09:	3c 09                	cmp    $0x9,%al
  800b0b:	74 f2                	je     800aff <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b0d:	3c 2b                	cmp    $0x2b,%al
  800b0f:	74 2a                	je     800b3b <strtol+0x4e>
	int neg = 0;
  800b11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b16:	3c 2d                	cmp    $0x2d,%al
  800b18:	74 2b                	je     800b45 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b20:	75 0f                	jne    800b31 <strtol+0x44>
  800b22:	80 39 30             	cmpb   $0x30,(%ecx)
  800b25:	74 28                	je     800b4f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b27:	85 db                	test   %ebx,%ebx
  800b29:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2e:	0f 44 d8             	cmove  %eax,%ebx
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b39:	eb 46                	jmp    800b81 <strtol+0x94>
		s++;
  800b3b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b43:	eb d5                	jmp    800b1a <strtol+0x2d>
		s++, neg = 1;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bf 01 00 00 00       	mov    $0x1,%edi
  800b4d:	eb cb                	jmp    800b1a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b53:	74 0e                	je     800b63 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 d8                	jne    800b31 <strtol+0x44>
		s++, base = 8;
  800b59:	83 c1 01             	add    $0x1,%ecx
  800b5c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b61:	eb ce                	jmp    800b31 <strtol+0x44>
		s += 2, base = 16;
  800b63:	83 c1 02             	add    $0x2,%ecx
  800b66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6b:	eb c4                	jmp    800b31 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b6d:	0f be d2             	movsbl %dl,%edx
  800b70:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b76:	7d 3a                	jge    800bb2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b78:	83 c1 01             	add    $0x1,%ecx
  800b7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b81:	0f b6 11             	movzbl (%ecx),%edx
  800b84:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 09             	cmp    $0x9,%bl
  800b8c:	76 df                	jbe    800b6d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b8e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b91:	89 f3                	mov    %esi,%ebx
  800b93:	80 fb 19             	cmp    $0x19,%bl
  800b96:	77 08                	ja     800ba0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b98:	0f be d2             	movsbl %dl,%edx
  800b9b:	83 ea 57             	sub    $0x57,%edx
  800b9e:	eb d3                	jmp    800b73 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ba0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba3:	89 f3                	mov    %esi,%ebx
  800ba5:	80 fb 19             	cmp    $0x19,%bl
  800ba8:	77 08                	ja     800bb2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800baa:	0f be d2             	movsbl %dl,%edx
  800bad:	83 ea 37             	sub    $0x37,%edx
  800bb0:	eb c1                	jmp    800b73 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb6:	74 05                	je     800bbd <strtol+0xd0>
		*endptr = (char *) s;
  800bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	f7 da                	neg    %edx
  800bc1:	85 ff                	test   %edi,%edi
  800bc3:	0f 45 c2             	cmovne %edx,%eax
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    
  800bcb:	66 90                	xchg   %ax,%ax
  800bcd:	66 90                	xchg   %ax,%ax
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
