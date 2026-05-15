
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	f3 0f 1e fb          	endbr32 
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800054:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  800057:	e8 d9 00 00 00       	call   800135 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800064:	c1 e0 05             	shl    $0x5,%eax
  800067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 db                	test   %ebx,%ebx
  800073:	7e 07                	jle    80007c <libmain+0x3e>
		binaryname = argv[0];
  800075:	8b 06                	mov    (%esi),%eax
  800077:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	e8 ad ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800086:	e8 0a 00 00 00       	call   800095 <exit>
}
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    

00800095 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 4a 00 00 00       	call   8000f0 <sys_env_destroy>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ab:	f3 0f 1e fb          	endbr32 
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	89 c6                	mov    %eax,%esi
  8000c6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cd:	f3 0f 1e fb          	endbr32 
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 d1                	mov    %edx,%ecx
  8000e3:	89 d3                	mov    %edx,%ebx
  8000e5:	89 d7                	mov    %edx,%edi
  8000e7:	89 d6                	mov    %edx,%esi
  8000e9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5f                   	pop    %edi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f0:	f3 0f 1e fb          	endbr32 
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	89 cb                	mov    %ecx,%ebx
  80010c:	89 cf                	mov    %ecx,%edi
  80010e:	89 ce                	mov    %ecx,%esi
  800110:	cd 30                	int    $0x30
	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7f 08                	jg     80011e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	50                   	push   %eax
  800122:	6a 03                	push   $0x3
  800124:	68 2a 0e 80 00       	push   $0x800e2a
  800129:	6a 23                	push   $0x23
  80012b:	68 47 0e 80 00       	push   $0x800e47
  800130:	e8 23 00 00 00       	call   800158 <_panic>

00800135 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	57                   	push   %edi
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013f:	ba 00 00 00 00       	mov    $0x0,%edx
  800144:	b8 02 00 00 00       	mov    $0x2,%eax
  800149:	89 d1                	mov    %edx,%ecx
  80014b:	89 d3                	mov    %edx,%ebx
  80014d:	89 d7                	mov    %edx,%edi
  80014f:	89 d6                	mov    %edx,%esi
  800151:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	f3 0f 1e fb          	endbr32 
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800161:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800164:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80016a:	e8 c6 ff ff ff       	call   800135 <sys_getenvid>
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	ff 75 0c             	pushl  0xc(%ebp)
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	56                   	push   %esi
  800179:	50                   	push   %eax
  80017a:	68 58 0e 80 00       	push   $0x800e58
  80017f:	e8 bb 00 00 00       	call   80023f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800184:	83 c4 18             	add    $0x18,%esp
  800187:	53                   	push   %ebx
  800188:	ff 75 10             	pushl  0x10(%ebp)
  80018b:	e8 5a 00 00 00       	call   8001ea <vcprintf>
	cprintf("\n");
  800190:	c7 04 24 7b 0e 80 00 	movl   $0x800e7b,(%esp)
  800197:	e8 a3 00 00 00       	call   80023f <cprintf>
  80019c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019f:	cc                   	int3   
  8001a0:	eb fd                	jmp    80019f <_panic+0x47>

008001a2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a2:	f3 0f 1e fb          	endbr32 
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 04             	sub    $0x4,%esp
  8001ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b0:	8b 13                	mov    (%ebx),%edx
  8001b2:	8d 42 01             	lea    0x1(%edx),%eax
  8001b5:	89 03                	mov    %eax,(%ebx)
  8001b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	74 09                	je     8001ce <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	68 ff 00 00 00       	push   $0xff
  8001d6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d9:	50                   	push   %eax
  8001da:	e8 cc fe ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  8001df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e5:	83 c4 10             	add    $0x10,%esp
  8001e8:	eb db                	jmp    8001c5 <putch+0x23>

008001ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ea:	f3 0f 1e fb          	endbr32 
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fe:	00 00 00 
	b.cnt = 0;
  800201:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800208:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020b:	ff 75 0c             	pushl  0xc(%ebp)
  80020e:	ff 75 08             	pushl  0x8(%ebp)
  800211:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800217:	50                   	push   %eax
  800218:	68 a2 01 80 00       	push   $0x8001a2
  80021d:	e8 20 01 00 00       	call   800342 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800222:	83 c4 08             	add    $0x8,%esp
  800225:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80022b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800231:	50                   	push   %eax
  800232:	e8 74 fe ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  800237:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023f:	f3 0f 1e fb          	endbr32 
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800249:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024c:	50                   	push   %eax
  80024d:	ff 75 08             	pushl  0x8(%ebp)
  800250:	e8 95 ff ff ff       	call   8001ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 1c             	sub    $0x1c,%esp
  800260:	89 c7                	mov    %eax,%edi
  800262:	89 d6                	mov    %edx,%esi
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026a:	89 d1                	mov    %edx,%ecx
  80026c:	89 c2                	mov    %eax,%edx
  80026e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800271:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800274:	8b 45 10             	mov    0x10(%ebp),%eax
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800284:	39 c2                	cmp    %eax,%edx
  800286:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800289:	72 3e                	jb     8002c9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028b:	83 ec 0c             	sub    $0xc,%esp
  80028e:	ff 75 18             	pushl  0x18(%ebp)
  800291:	83 eb 01             	sub    $0x1,%ebx
  800294:	53                   	push   %ebx
  800295:	50                   	push   %eax
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029c:	ff 75 e0             	pushl  -0x20(%ebp)
  80029f:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a5:	e8 16 09 00 00       	call   800bc0 <__udivdi3>
  8002aa:	83 c4 18             	add    $0x18,%esp
  8002ad:	52                   	push   %edx
  8002ae:	50                   	push   %eax
  8002af:	89 f2                	mov    %esi,%edx
  8002b1:	89 f8                	mov    %edi,%eax
  8002b3:	e8 9f ff ff ff       	call   800257 <printnum>
  8002b8:	83 c4 20             	add    $0x20,%esp
  8002bb:	eb 13                	jmp    8002d0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	56                   	push   %esi
  8002c1:	ff 75 18             	pushl  0x18(%ebp)
  8002c4:	ff d7                	call   *%edi
  8002c6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002c9:	83 eb 01             	sub    $0x1,%ebx
  8002cc:	85 db                	test   %ebx,%ebx
  8002ce:	7f ed                	jg     8002bd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	56                   	push   %esi
  8002d4:	83 ec 04             	sub    $0x4,%esp
  8002d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002da:	ff 75 e0             	pushl  -0x20(%ebp)
  8002dd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e3:	e8 e8 09 00 00       	call   800cd0 <__umoddi3>
  8002e8:	83 c4 14             	add    $0x14,%esp
  8002eb:	0f be 80 7d 0e 80 00 	movsbl 0x800e7d(%eax),%eax
  8002f2:	50                   	push   %eax
  8002f3:	ff d7                	call   *%edi
}
  8002f5:	83 c4 10             	add    $0x10,%esp
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	f3 0f 1e fb          	endbr32 
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	3b 50 04             	cmp    0x4(%eax),%edx
  800313:	73 0a                	jae    80031f <sprintputch+0x1f>
		*b->buf++ = ch;
  800315:	8d 4a 01             	lea    0x1(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	88 02                	mov    %al,(%edx)
}
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <printfmt>:
{
  800321:	f3 0f 1e fb          	endbr32 
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80032b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032e:	50                   	push   %eax
  80032f:	ff 75 10             	pushl  0x10(%ebp)
  800332:	ff 75 0c             	pushl  0xc(%ebp)
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	e8 05 00 00 00       	call   800342 <vprintfmt>
}
  80033d:	83 c4 10             	add    $0x10,%esp
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <vprintfmt>:
{
  800342:	f3 0f 1e fb          	endbr32 
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
  80034c:	83 ec 3c             	sub    $0x3c,%esp
  80034f:	8b 75 08             	mov    0x8(%ebp),%esi
  800352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800355:	8b 7d 10             	mov    0x10(%ebp),%edi
  800358:	e9 8e 03 00 00       	jmp    8006eb <vprintfmt+0x3a9>
		padc = ' ';
  80035d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800361:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800368:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80036f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800376:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8d 47 01             	lea    0x1(%edi),%eax
  80037e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800381:	0f b6 17             	movzbl (%edi),%edx
  800384:	8d 42 dd             	lea    -0x23(%edx),%eax
  800387:	3c 55                	cmp    $0x55,%al
  800389:	0f 87 df 03 00 00    	ja     80076e <vprintfmt+0x42c>
  80038f:	0f b6 c0             	movzbl %al,%eax
  800392:	3e ff 24 85 0c 0f 80 	notrack jmp *0x800f0c(,%eax,4)
  800399:	00 
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80039d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003a1:	eb d8                	jmp    80037b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003aa:	eb cf                	jmp    80037b <vprintfmt+0x39>
  8003ac:	0f b6 d2             	movzbl %dl,%edx
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ba:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c7:	83 f9 09             	cmp    $0x9,%ecx
  8003ca:	77 55                	ja     800421 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003cc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003cf:	eb e9                	jmp    8003ba <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 40 04             	lea    0x4(%eax),%eax
  8003df:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e9:	79 90                	jns    80037b <vprintfmt+0x39>
				width = precision, precision = -1;
  8003eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f8:	eb 81                	jmp    80037b <vprintfmt+0x39>
  8003fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800404:	0f 49 d0             	cmovns %eax,%edx
  800407:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040d:	e9 69 ff ff ff       	jmp    80037b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800415:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80041c:	e9 5a ff ff ff       	jmp    80037b <vprintfmt+0x39>
  800421:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	eb bc                	jmp    8003e5 <vprintfmt+0xa3>
			lflag++;
  800429:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80042f:	e9 47 ff ff ff       	jmp    80037b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 78 04             	lea    0x4(%eax),%edi
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 30                	pushl  (%eax)
  800440:	ff d6                	call   *%esi
			break;
  800442:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800445:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800448:	e9 9b 02 00 00       	jmp    8006e8 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 78 04             	lea    0x4(%eax),%edi
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 06             	cmp    $0x6,%eax
  80045d:	7f 23                	jg     800482 <vprintfmt+0x140>
  80045f:	8b 14 85 64 10 80 00 	mov    0x801064(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	74 18                	je     800482 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80046a:	52                   	push   %edx
  80046b:	68 9e 0e 80 00       	push   $0x800e9e
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 aa fe ff ff       	call   800321 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80047d:	e9 66 02 00 00       	jmp    8006e8 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800482:	50                   	push   %eax
  800483:	68 95 0e 80 00       	push   $0x800e95
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 92 fe ff ff       	call   800321 <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800492:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800495:	e9 4e 02 00 00       	jmp    8006e8 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	83 c0 04             	add    $0x4,%eax
  8004a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	b8 8e 0e 80 00       	mov    $0x800e8e,%eax
  8004af:	0f 45 c2             	cmovne %edx,%eax
  8004b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b9:	7e 06                	jle    8004c1 <vprintfmt+0x17f>
  8004bb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004bf:	75 0d                	jne    8004ce <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c4:	89 c7                	mov    %eax,%edi
  8004c6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cc:	eb 55                	jmp    800523 <vprintfmt+0x1e1>
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d4:	ff 75 cc             	pushl  -0x34(%ebp)
  8004d7:	e8 46 03 00 00       	call   800822 <strnlen>
  8004dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004df:	29 c2                	sub    %eax,%edx
  8004e1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004e9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7e 11                	jle    800505 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fb:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	83 ef 01             	sub    $0x1,%edi
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	eb eb                	jmp    8004f0 <vprintfmt+0x1ae>
  800505:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800508:	85 d2                	test   %edx,%edx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c2             	cmovns %edx,%eax
  800512:	29 c2                	sub    %eax,%edx
  800514:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800517:	eb a8                	jmp    8004c1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	53                   	push   %ebx
  80051d:	52                   	push   %edx
  80051e:	ff d6                	call   *%esi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800526:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800528:	83 c7 01             	add    $0x1,%edi
  80052b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052f:	0f be d0             	movsbl %al,%edx
  800532:	85 d2                	test   %edx,%edx
  800534:	74 4b                	je     800581 <vprintfmt+0x23f>
  800536:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053a:	78 06                	js     800542 <vprintfmt+0x200>
  80053c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800540:	78 1e                	js     800560 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800542:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800546:	74 d1                	je     800519 <vprintfmt+0x1d7>
  800548:	0f be c0             	movsbl %al,%eax
  80054b:	83 e8 20             	sub    $0x20,%eax
  80054e:	83 f8 5e             	cmp    $0x5e,%eax
  800551:	76 c6                	jbe    800519 <vprintfmt+0x1d7>
					putch('?', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	53                   	push   %ebx
  800557:	6a 3f                	push   $0x3f
  800559:	ff d6                	call   *%esi
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	eb c3                	jmp    800523 <vprintfmt+0x1e1>
  800560:	89 cf                	mov    %ecx,%edi
  800562:	eb 0e                	jmp    800572 <vprintfmt+0x230>
				putch(' ', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	6a 20                	push   $0x20
  80056a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ee                	jg     800564 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
  80057c:	e9 67 01 00 00       	jmp    8006e8 <vprintfmt+0x3a6>
  800581:	89 cf                	mov    %ecx,%edi
  800583:	eb ed                	jmp    800572 <vprintfmt+0x230>
	if (lflag >= 2)
  800585:	83 f9 01             	cmp    $0x1,%ecx
  800588:	7f 1b                	jg     8005a5 <vprintfmt+0x263>
	else if (lflag)
  80058a:	85 c9                	test   %ecx,%ecx
  80058c:	74 63                	je     8005f1 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	99                   	cltd   
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 04             	lea    0x4(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a3:	eb 17                	jmp    8005bc <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 50 04             	mov    0x4(%eax),%edx
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 08             	lea    0x8(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	0f 89 ff 00 00 00    	jns    8006ce <vprintfmt+0x38c>
				putch('-', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 2d                	push   $0x2d
  8005d5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005dd:	f7 da                	neg    %edx
  8005df:	83 d1 00             	adc    $0x0,%ecx
  8005e2:	f7 d9                	neg    %ecx
  8005e4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	e9 dd 00 00 00       	jmp    8006ce <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	99                   	cltd   
  8005fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
  800606:	eb b4                	jmp    8005bc <vprintfmt+0x27a>
	if (lflag >= 2)
  800608:	83 f9 01             	cmp    $0x1,%ecx
  80060b:	7f 1e                	jg     80062b <vprintfmt+0x2e9>
	else if (lflag)
  80060d:	85 c9                	test   %ecx,%ecx
  80060f:	74 32                	je     800643 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 10                	mov    (%eax),%edx
  800616:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061b:	8d 40 04             	lea    0x4(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800626:	e9 a3 00 00 00       	jmp    8006ce <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	8b 48 04             	mov    0x4(%eax),%ecx
  800633:	8d 40 08             	lea    0x8(%eax),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80063e:	e9 8b 00 00 00       	jmp    8006ce <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800653:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800658:	eb 74                	jmp    8006ce <vprintfmt+0x38c>
	if (lflag >= 2)
  80065a:	83 f9 01             	cmp    $0x1,%ecx
  80065d:	7f 1b                	jg     80067a <vprintfmt+0x338>
	else if (lflag)
  80065f:	85 c9                	test   %ecx,%ecx
  800661:	74 2c                	je     80068f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800673:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800678:	eb 54                	jmp    8006ce <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8b 48 04             	mov    0x4(%eax),%ecx
  800682:	8d 40 08             	lea    0x8(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800688:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80068d:	eb 3f                	jmp    8006ce <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 10                	mov    (%eax),%edx
  800694:	b9 00 00 00 00       	mov    $0x0,%ecx
  800699:	8d 40 04             	lea    0x4(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80069f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006a4:	eb 28                	jmp    8006ce <vprintfmt+0x38c>
			putch('0', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 30                	push   $0x30
  8006ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ae:	83 c4 08             	add    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 78                	push   $0x78
  8006b4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006d5:	57                   	push   %edi
  8006d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d9:	50                   	push   %eax
  8006da:	51                   	push   %ecx
  8006db:	52                   	push   %edx
  8006dc:	89 da                	mov    %ebx,%edx
  8006de:	89 f0                	mov    %esi,%eax
  8006e0:	e8 72 fb ff ff       	call   800257 <printnum>
			break;
  8006e5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006eb:	83 c7 01             	add    $0x1,%edi
  8006ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f2:	83 f8 25             	cmp    $0x25,%eax
  8006f5:	0f 84 62 fc ff ff    	je     80035d <vprintfmt+0x1b>
			if (ch == '\0')
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	0f 84 8b 00 00 00    	je     80078e <vprintfmt+0x44c>
			putch(ch, putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	53                   	push   %ebx
  800707:	50                   	push   %eax
  800708:	ff d6                	call   *%esi
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	eb dc                	jmp    8006eb <vprintfmt+0x3a9>
	if (lflag >= 2)
  80070f:	83 f9 01             	cmp    $0x1,%ecx
  800712:	7f 1b                	jg     80072f <vprintfmt+0x3ed>
	else if (lflag)
  800714:	85 c9                	test   %ecx,%ecx
  800716:	74 2c                	je     800744 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800722:	8d 40 04             	lea    0x4(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800728:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80072d:	eb 9f                	jmp    8006ce <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 10                	mov    (%eax),%edx
  800734:	8b 48 04             	mov    0x4(%eax),%ecx
  800737:	8d 40 08             	lea    0x8(%eax),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800742:	eb 8a                	jmp    8006ce <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8b 10                	mov    (%eax),%edx
  800749:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074e:	8d 40 04             	lea    0x4(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800754:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800759:	e9 70 ff ff ff       	jmp    8006ce <vprintfmt+0x38c>
			putch(ch, putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 25                	push   $0x25
  800764:	ff d6                	call   *%esi
			break;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	e9 7a ff ff ff       	jmp    8006e8 <vprintfmt+0x3a6>
			putch('%', putdat);
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 25                	push   $0x25
  800774:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800776:	83 c4 10             	add    $0x10,%esp
  800779:	89 f8                	mov    %edi,%eax
  80077b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80077f:	74 05                	je     800786 <vprintfmt+0x444>
  800781:	83 e8 01             	sub    $0x1,%eax
  800784:	eb f5                	jmp    80077b <vprintfmt+0x439>
  800786:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800789:	e9 5a ff ff ff       	jmp    8006e8 <vprintfmt+0x3a6>
}
  80078e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5f                   	pop    %edi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800796:	f3 0f 1e fb          	endbr32 
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 18             	sub    $0x18,%esp
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	74 26                	je     8007e1 <vsnprintf+0x4b>
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	7e 22                	jle    8007e1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bf:	ff 75 14             	pushl  0x14(%ebp)
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	68 00 03 80 00       	push   $0x800300
  8007ce:	e8 6f fb ff ff       	call   800342 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007dc:	83 c4 10             	add    $0x10,%esp
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    
		return -E_INVAL;
  8007e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e6:	eb f7                	jmp    8007df <vsnprintf+0x49>

008007e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e8:	f3 0f 1e fb          	endbr32 
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f5:	50                   	push   %eax
  8007f6:	ff 75 10             	pushl  0x10(%ebp)
  8007f9:	ff 75 0c             	pushl  0xc(%ebp)
  8007fc:	ff 75 08             	pushl  0x8(%ebp)
  8007ff:	e8 92 ff ff ff       	call   800796 <vsnprintf>
	va_end(ap);

	return rc;
}
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800806:	f3 0f 1e fb          	endbr32 
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800819:	74 05                	je     800820 <strlen+0x1a>
		n++;
  80081b:	83 c0 01             	add    $0x1,%eax
  80081e:	eb f5                	jmp    800815 <strlen+0xf>
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800822:	f3 0f 1e fb          	endbr32 
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
  800834:	39 d0                	cmp    %edx,%eax
  800836:	74 0d                	je     800845 <strnlen+0x23>
  800838:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80083c:	74 05                	je     800843 <strnlen+0x21>
		n++;
  80083e:	83 c0 01             	add    $0x1,%eax
  800841:	eb f1                	jmp    800834 <strnlen+0x12>
  800843:	89 c2                	mov    %eax,%edx
	return n;
}
  800845:	89 d0                	mov    %edx,%eax
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800849:	f3 0f 1e fb          	endbr32 
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
  80085c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800860:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	84 d2                	test   %dl,%dl
  800868:	75 f2                	jne    80085c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80086a:	89 c8                	mov    %ecx,%eax
  80086c:	5b                   	pop    %ebx
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086f:	f3 0f 1e fb          	endbr32 
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	83 ec 10             	sub    $0x10,%esp
  80087a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087d:	53                   	push   %ebx
  80087e:	e8 83 ff ff ff       	call   800806 <strlen>
  800883:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800886:	ff 75 0c             	pushl  0xc(%ebp)
  800889:	01 d8                	add    %ebx,%eax
  80088b:	50                   	push   %eax
  80088c:	e8 b8 ff ff ff       	call   800849 <strcpy>
	return dst;
}
  800891:	89 d8                	mov    %ebx,%eax
  800893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800898:	f3 0f 1e fb          	endbr32 
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a7:	89 f3                	mov    %esi,%ebx
  8008a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	39 d8                	cmp    %ebx,%eax
  8008b0:	74 11                	je     8008c3 <strncpy+0x2b>
		*dst++ = *src;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 0a             	movzbl (%edx),%ecx
  8008b8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bb:	80 f9 01             	cmp    $0x1,%cl
  8008be:	83 da ff             	sbb    $0xffffffff,%edx
  8008c1:	eb eb                	jmp    8008ae <strncpy+0x16>
	}
	return ret;
}
  8008c3:	89 f0                	mov    %esi,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c9:	f3 0f 1e fb          	endbr32 
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d8:	8b 55 10             	mov    0x10(%ebp),%edx
  8008db:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	74 21                	je     800902 <strlcpy+0x39>
  8008e1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	74 14                	je     8008ff <strlcpy+0x36>
  8008eb:	0f b6 19             	movzbl (%ecx),%ebx
  8008ee:	84 db                	test   %bl,%bl
  8008f0:	74 0b                	je     8008fd <strlcpy+0x34>
			*dst++ = *src++;
  8008f2:	83 c1 01             	add    $0x1,%ecx
  8008f5:	83 c2 01             	add    $0x1,%edx
  8008f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fb:	eb ea                	jmp    8008e7 <strlcpy+0x1e>
  8008fd:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800902:	29 f0                	sub    %esi,%eax
}
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800908:	f3 0f 1e fb          	endbr32 
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800915:	0f b6 01             	movzbl (%ecx),%eax
  800918:	84 c0                	test   %al,%al
  80091a:	74 0c                	je     800928 <strcmp+0x20>
  80091c:	3a 02                	cmp    (%edx),%al
  80091e:	75 08                	jne    800928 <strcmp+0x20>
		p++, q++;
  800920:	83 c1 01             	add    $0x1,%ecx
  800923:	83 c2 01             	add    $0x1,%edx
  800926:	eb ed                	jmp    800915 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 c0             	movzbl %al,%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800940:	89 c3                	mov    %eax,%ebx
  800942:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800945:	eb 06                	jmp    80094d <strncmp+0x1b>
		n--, p++, q++;
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80094d:	39 d8                	cmp    %ebx,%eax
  80094f:	74 16                	je     800967 <strncmp+0x35>
  800951:	0f b6 08             	movzbl (%eax),%ecx
  800954:	84 c9                	test   %cl,%cl
  800956:	74 04                	je     80095c <strncmp+0x2a>
  800958:	3a 0a                	cmp    (%edx),%cl
  80095a:	74 eb                	je     800947 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095c:	0f b6 00             	movzbl (%eax),%eax
  80095f:	0f b6 12             	movzbl (%edx),%edx
  800962:	29 d0                	sub    %edx,%eax
}
  800964:	5b                   	pop    %ebx
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    
		return 0;
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
  80096c:	eb f6                	jmp    800964 <strncmp+0x32>

0080096e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096e:	f3 0f 1e fb          	endbr32 
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097c:	0f b6 10             	movzbl (%eax),%edx
  80097f:	84 d2                	test   %dl,%dl
  800981:	74 09                	je     80098c <strchr+0x1e>
		if (*s == c)
  800983:	38 ca                	cmp    %cl,%dl
  800985:	74 0a                	je     800991 <strchr+0x23>
	for (; *s; s++)
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	eb f0                	jmp    80097c <strchr+0xe>
			return (char *) s;
	return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800993:	f3 0f 1e fb          	endbr32 
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 09                	je     8009b1 <strfind+0x1e>
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	74 05                	je     8009b1 <strfind+0x1e>
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	eb f0                	jmp    8009a1 <strfind+0xe>
			break;
	return (char *) s;
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b3:	f3 0f 1e fb          	endbr32 
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	74 31                	je     8009f8 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c7:	89 f8                	mov    %edi,%eax
  8009c9:	09 c8                	or     %ecx,%eax
  8009cb:	a8 03                	test   $0x3,%al
  8009cd:	75 23                	jne    8009f2 <memset+0x3f>
		c &= 0xFF;
  8009cf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d3:	89 d3                	mov    %edx,%ebx
  8009d5:	c1 e3 08             	shl    $0x8,%ebx
  8009d8:	89 d0                	mov    %edx,%eax
  8009da:	c1 e0 18             	shl    $0x18,%eax
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	c1 e6 10             	shl    $0x10,%esi
  8009e2:	09 f0                	or     %esi,%eax
  8009e4:	09 c2                	or     %eax,%edx
  8009e6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009eb:	89 d0                	mov    %edx,%eax
  8009ed:	fc                   	cld    
  8009ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f0:	eb 06                	jmp    8009f8 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f5:	fc                   	cld    
  8009f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f8:	89 f8                	mov    %edi,%eax
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5f                   	pop    %edi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ff:	f3 0f 1e fb          	endbr32 
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a11:	39 c6                	cmp    %eax,%esi
  800a13:	73 32                	jae    800a47 <memmove+0x48>
  800a15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a18:	39 c2                	cmp    %eax,%edx
  800a1a:	76 2b                	jbe    800a47 <memmove+0x48>
		s += n;
		d += n;
  800a1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	89 fe                	mov    %edi,%esi
  800a21:	09 ce                	or     %ecx,%esi
  800a23:	09 d6                	or     %edx,%esi
  800a25:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2b:	75 0e                	jne    800a3b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2d:	83 ef 04             	sub    $0x4,%edi
  800a30:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a33:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a36:	fd                   	std    
  800a37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a39:	eb 09                	jmp    800a44 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3b:	83 ef 01             	sub    $0x1,%edi
  800a3e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a41:	fd                   	std    
  800a42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a44:	fc                   	cld    
  800a45:	eb 1a                	jmp    800a61 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a47:	89 c2                	mov    %eax,%edx
  800a49:	09 ca                	or     %ecx,%edx
  800a4b:	09 f2                	or     %esi,%edx
  800a4d:	f6 c2 03             	test   $0x3,%dl
  800a50:	75 0a                	jne    800a5c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a52:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	fc                   	cld    
  800a58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5a:	eb 05                	jmp    800a61 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a65:	f3 0f 1e fb          	endbr32 
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a6f:	ff 75 10             	pushl  0x10(%ebp)
  800a72:	ff 75 0c             	pushl  0xc(%ebp)
  800a75:	ff 75 08             	pushl  0x8(%ebp)
  800a78:	e8 82 ff ff ff       	call   8009ff <memmove>
}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7f:	f3 0f 1e fb          	endbr32 
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 f0                	cmp    %esi,%eax
  800a95:	74 1c                	je     800ab3 <memcmp+0x34>
		if (*s1 != *s2)
  800a97:	0f b6 08             	movzbl (%eax),%ecx
  800a9a:	0f b6 1a             	movzbl (%edx),%ebx
  800a9d:	38 d9                	cmp    %bl,%cl
  800a9f:	75 08                	jne    800aa9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aa1:	83 c0 01             	add    $0x1,%eax
  800aa4:	83 c2 01             	add    $0x1,%edx
  800aa7:	eb ea                	jmp    800a93 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aa9:	0f b6 c1             	movzbl %cl,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 05                	jmp    800ab8 <memcmp+0x39>
	}

	return 0;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abc:	f3 0f 1e fb          	endbr32 
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac9:	89 c2                	mov    %eax,%edx
  800acb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ace:	39 d0                	cmp    %edx,%eax
  800ad0:	73 09                	jae    800adb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad2:	38 08                	cmp    %cl,(%eax)
  800ad4:	74 05                	je     800adb <memfind+0x1f>
	for (; s < ends; s++)
  800ad6:	83 c0 01             	add    $0x1,%eax
  800ad9:	eb f3                	jmp    800ace <memfind+0x12>
			break;
	return (void *) s;
}
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800add:	f3 0f 1e fb          	endbr32 
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aed:	eb 03                	jmp    800af2 <strtol+0x15>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800af2:	0f b6 01             	movzbl (%ecx),%eax
  800af5:	3c 20                	cmp    $0x20,%al
  800af7:	74 f6                	je     800aef <strtol+0x12>
  800af9:	3c 09                	cmp    $0x9,%al
  800afb:	74 f2                	je     800aef <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800afd:	3c 2b                	cmp    $0x2b,%al
  800aff:	74 2a                	je     800b2b <strtol+0x4e>
	int neg = 0;
  800b01:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b06:	3c 2d                	cmp    $0x2d,%al
  800b08:	74 2b                	je     800b35 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b10:	75 0f                	jne    800b21 <strtol+0x44>
  800b12:	80 39 30             	cmpb   $0x30,(%ecx)
  800b15:	74 28                	je     800b3f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1e:	0f 44 d8             	cmove  %eax,%ebx
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b29:	eb 46                	jmp    800b71 <strtol+0x94>
		s++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b33:	eb d5                	jmp    800b0a <strtol+0x2d>
		s++, neg = 1;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	bf 01 00 00 00       	mov    $0x1,%edi
  800b3d:	eb cb                	jmp    800b0a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b43:	74 0e                	je     800b53 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b45:	85 db                	test   %ebx,%ebx
  800b47:	75 d8                	jne    800b21 <strtol+0x44>
		s++, base = 8;
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b51:	eb ce                	jmp    800b21 <strtol+0x44>
		s += 2, base = 16;
  800b53:	83 c1 02             	add    $0x2,%ecx
  800b56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b5b:	eb c4                	jmp    800b21 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b5d:	0f be d2             	movsbl %dl,%edx
  800b60:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b63:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b66:	7d 3a                	jge    800ba2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b68:	83 c1 01             	add    $0x1,%ecx
  800b6b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b71:	0f b6 11             	movzbl (%ecx),%edx
  800b74:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b77:	89 f3                	mov    %esi,%ebx
  800b79:	80 fb 09             	cmp    $0x9,%bl
  800b7c:	76 df                	jbe    800b5d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b7e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b81:	89 f3                	mov    %esi,%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 08                	ja     800b90 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b88:	0f be d2             	movsbl %dl,%edx
  800b8b:	83 ea 57             	sub    $0x57,%edx
  800b8e:	eb d3                	jmp    800b63 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b90:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b93:	89 f3                	mov    %esi,%ebx
  800b95:	80 fb 19             	cmp    $0x19,%bl
  800b98:	77 08                	ja     800ba2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b9a:	0f be d2             	movsbl %dl,%edx
  800b9d:	83 ea 37             	sub    $0x37,%edx
  800ba0:	eb c1                	jmp    800b63 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba6:	74 05                	je     800bad <strtol+0xd0>
		*endptr = (char *) s;
  800ba8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bab:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bad:	89 c2                	mov    %eax,%edx
  800baf:	f7 da                	neg    %edx
  800bb1:	85 ff                	test   %edi,%edi
  800bb3:	0f 45 c2             	cmovne %edx,%eax
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    
  800bbb:	66 90                	xchg   %ax,%ax
  800bbd:	66 90                	xchg   %ax,%ax
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
