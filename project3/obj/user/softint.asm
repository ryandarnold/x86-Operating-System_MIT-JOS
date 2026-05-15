
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	f3 0f 1e fb          	endbr32 
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800049:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800050:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  800053:	e8 d9 00 00 00       	call   800131 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800060:	c1 e0 05             	shl    $0x5,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 db                	test   %ebx,%ebx
  80006f:	7e 07                	jle    800078 <libmain+0x3e>
		binaryname = argv[0];
  800071:	8b 06                	mov    (%esi),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	e8 b1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800082:	e8 0a 00 00 00       	call   800091 <exit>
}
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    

00800091 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800091:	f3 0f 1e fb          	endbr32 
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009b:	6a 00                	push   $0x0
  80009d:	e8 4a 00 00 00       	call   8000ec <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	f3 0f 1e fb          	endbr32 
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	89 c3                	mov    %eax,%ebx
  8000be:	89 c7                	mov    %eax,%edi
  8000c0:	89 c6                	mov    %eax,%esi
  8000c2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c9:	f3 0f 1e fb          	endbr32 
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dd:	89 d1                	mov    %edx,%ecx
  8000df:	89 d3                	mov    %edx,%ebx
  8000e1:	89 d7                	mov    %edx,%edi
  8000e3:	89 d6                	mov    %edx,%esi
  8000e5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ec:	f3 0f 1e fb          	endbr32 
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	57                   	push   %edi
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	89 cb                	mov    %ecx,%ebx
  800108:	89 cf                	mov    %ecx,%edi
  80010a:	89 ce                	mov    %ecx,%esi
  80010c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	7f 08                	jg     80011a <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011a:	83 ec 0c             	sub    $0xc,%esp
  80011d:	50                   	push   %eax
  80011e:	6a 03                	push   $0x3
  800120:	68 2a 0e 80 00       	push   $0x800e2a
  800125:	6a 23                	push   $0x23
  800127:	68 47 0e 80 00       	push   $0x800e47
  80012c:	e8 23 00 00 00       	call   800154 <_panic>

00800131 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800131:	f3 0f 1e fb          	endbr32 
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	57                   	push   %edi
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013b:	ba 00 00 00 00       	mov    $0x0,%edx
  800140:	b8 02 00 00 00       	mov    $0x2,%eax
  800145:	89 d1                	mov    %edx,%ecx
  800147:	89 d3                	mov    %edx,%ebx
  800149:	89 d7                	mov    %edx,%edi
  80014b:	89 d6                	mov    %edx,%esi
  80014d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	f3 0f 1e fb          	endbr32 
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800166:	e8 c6 ff ff ff       	call   800131 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 58 0e 80 00       	push   $0x800e58
  80017b:	e8 bb 00 00 00       	call   80023b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 5a 00 00 00       	call   8001e6 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 7b 0e 80 00 	movl   $0x800e7b,(%esp)
  800193:	e8 a3 00 00 00       	call   80023b <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x47>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	f3 0f 1e fb          	endbr32 
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 04             	sub    $0x4,%esp
  8001a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ac:	8b 13                	mov    (%ebx),%edx
  8001ae:	8d 42 01             	lea    0x1(%edx),%eax
  8001b1:	89 03                	mov    %eax,(%ebx)
  8001b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	74 09                	je     8001ca <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001c1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ca:	83 ec 08             	sub    $0x8,%esp
  8001cd:	68 ff 00 00 00       	push   $0xff
  8001d2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d5:	50                   	push   %eax
  8001d6:	e8 cc fe ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8001db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e1:	83 c4 10             	add    $0x10,%esp
  8001e4:	eb db                	jmp    8001c1 <putch+0x23>

008001e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e6:	f3 0f 1e fb          	endbr32 
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fa:	00 00 00 
	b.cnt = 0;
  8001fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800204:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800207:	ff 75 0c             	pushl  0xc(%ebp)
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800213:	50                   	push   %eax
  800214:	68 9e 01 80 00       	push   $0x80019e
  800219:	e8 20 01 00 00       	call   80033e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021e:	83 c4 08             	add    $0x8,%esp
  800221:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800227:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022d:	50                   	push   %eax
  80022e:	e8 74 fe ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  800233:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023b:	f3 0f 1e fb          	endbr32 
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800245:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800248:	50                   	push   %eax
  800249:	ff 75 08             	pushl  0x8(%ebp)
  80024c:	e8 95 ff ff ff       	call   8001e6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	83 ec 1c             	sub    $0x1c,%esp
  80025c:	89 c7                	mov    %eax,%edi
  80025e:	89 d6                	mov    %edx,%esi
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	8b 55 0c             	mov    0xc(%ebp),%edx
  800266:	89 d1                	mov    %edx,%ecx
  800268:	89 c2                	mov    %eax,%edx
  80026a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800270:	8b 45 10             	mov    0x10(%ebp),%eax
  800273:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800276:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800279:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800280:	39 c2                	cmp    %eax,%edx
  800282:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800285:	72 3e                	jb     8002c5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 18             	pushl  0x18(%ebp)
  80028d:	83 eb 01             	sub    $0x1,%ebx
  800290:	53                   	push   %ebx
  800291:	50                   	push   %eax
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	ff 75 e4             	pushl  -0x1c(%ebp)
  800298:	ff 75 e0             	pushl  -0x20(%ebp)
  80029b:	ff 75 dc             	pushl  -0x24(%ebp)
  80029e:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a1:	e8 1a 09 00 00       	call   800bc0 <__udivdi3>
  8002a6:	83 c4 18             	add    $0x18,%esp
  8002a9:	52                   	push   %edx
  8002aa:	50                   	push   %eax
  8002ab:	89 f2                	mov    %esi,%edx
  8002ad:	89 f8                	mov    %edi,%eax
  8002af:	e8 9f ff ff ff       	call   800253 <printnum>
  8002b4:	83 c4 20             	add    $0x20,%esp
  8002b7:	eb 13                	jmp    8002cc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	ff 75 18             	pushl  0x18(%ebp)
  8002c0:	ff d7                	call   *%edi
  8002c2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002c5:	83 eb 01             	sub    $0x1,%ebx
  8002c8:	85 db                	test   %ebx,%ebx
  8002ca:	7f ed                	jg     8002b9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	56                   	push   %esi
  8002d0:	83 ec 04             	sub    $0x4,%esp
  8002d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002df:	e8 ec 09 00 00       	call   800cd0 <__umoddi3>
  8002e4:	83 c4 14             	add    $0x14,%esp
  8002e7:	0f be 80 7d 0e 80 00 	movsbl 0x800e7d(%eax),%eax
  8002ee:	50                   	push   %eax
  8002ef:	ff d7                	call   *%edi
}
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fc:	f3 0f 1e fb          	endbr32 
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1f>
		*b->buf++ = ch;
  800311:	8d 4a 01             	lea    0x1(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	88 02                	mov    %al,(%edx)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <printfmt>:
{
  80031d:	f3 0f 1e fb          	endbr32 
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800327:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032a:	50                   	push   %eax
  80032b:	ff 75 10             	pushl  0x10(%ebp)
  80032e:	ff 75 0c             	pushl  0xc(%ebp)
  800331:	ff 75 08             	pushl  0x8(%ebp)
  800334:	e8 05 00 00 00       	call   80033e <vprintfmt>
}
  800339:	83 c4 10             	add    $0x10,%esp
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <vprintfmt>:
{
  80033e:	f3 0f 1e fb          	endbr32 
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
  800348:	83 ec 3c             	sub    $0x3c,%esp
  80034b:	8b 75 08             	mov    0x8(%ebp),%esi
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800351:	8b 7d 10             	mov    0x10(%ebp),%edi
  800354:	e9 8e 03 00 00       	jmp    8006e7 <vprintfmt+0x3a9>
		padc = ' ';
  800359:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80035d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800364:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80036b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800372:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8d 47 01             	lea    0x1(%edi),%eax
  80037a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037d:	0f b6 17             	movzbl (%edi),%edx
  800380:	8d 42 dd             	lea    -0x23(%edx),%eax
  800383:	3c 55                	cmp    $0x55,%al
  800385:	0f 87 df 03 00 00    	ja     80076a <vprintfmt+0x42c>
  80038b:	0f b6 c0             	movzbl %al,%eax
  80038e:	3e ff 24 85 0c 0f 80 	notrack jmp *0x800f0c(,%eax,4)
  800395:	00 
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800399:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80039d:	eb d8                	jmp    800377 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a6:	eb cf                	jmp    800377 <vprintfmt+0x39>
  8003a8:	0f b6 d2             	movzbl %dl,%edx
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003bd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c3:	83 f9 09             	cmp    $0x9,%ecx
  8003c6:	77 55                	ja     80041d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003cb:	eb e9                	jmp    8003b6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8b 00                	mov    (%eax),%eax
  8003d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8d 40 04             	lea    0x4(%eax),%eax
  8003db:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e5:	79 90                	jns    800377 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ed:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f4:	eb 81                	jmp    800377 <vprintfmt+0x39>
  8003f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800400:	0f 49 d0             	cmovns %eax,%edx
  800403:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800409:	e9 69 ff ff ff       	jmp    800377 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800411:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800418:	e9 5a ff ff ff       	jmp    800377 <vprintfmt+0x39>
  80041d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800420:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800423:	eb bc                	jmp    8003e1 <vprintfmt+0xa3>
			lflag++;
  800425:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80042b:	e9 47 ff ff ff       	jmp    800377 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 78 04             	lea    0x4(%eax),%edi
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	53                   	push   %ebx
  80043a:	ff 30                	pushl  (%eax)
  80043c:	ff d6                	call   *%esi
			break;
  80043e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800441:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800444:	e9 9b 02 00 00       	jmp    8006e4 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 78 04             	lea    0x4(%eax),%edi
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	99                   	cltd   
  800452:	31 d0                	xor    %edx,%eax
  800454:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800456:	83 f8 06             	cmp    $0x6,%eax
  800459:	7f 23                	jg     80047e <vprintfmt+0x140>
  80045b:	8b 14 85 64 10 80 00 	mov    0x801064(,%eax,4),%edx
  800462:	85 d2                	test   %edx,%edx
  800464:	74 18                	je     80047e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800466:	52                   	push   %edx
  800467:	68 9e 0e 80 00       	push   $0x800e9e
  80046c:	53                   	push   %ebx
  80046d:	56                   	push   %esi
  80046e:	e8 aa fe ff ff       	call   80031d <printfmt>
  800473:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800476:	89 7d 14             	mov    %edi,0x14(%ebp)
  800479:	e9 66 02 00 00       	jmp    8006e4 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80047e:	50                   	push   %eax
  80047f:	68 95 0e 80 00       	push   $0x800e95
  800484:	53                   	push   %ebx
  800485:	56                   	push   %esi
  800486:	e8 92 fe ff ff       	call   80031d <printfmt>
  80048b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800491:	e9 4e 02 00 00       	jmp    8006e4 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	83 c0 04             	add    $0x4,%eax
  80049c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a4:	85 d2                	test   %edx,%edx
  8004a6:	b8 8e 0e 80 00       	mov    $0x800e8e,%eax
  8004ab:	0f 45 c2             	cmovne %edx,%eax
  8004ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b5:	7e 06                	jle    8004bd <vprintfmt+0x17f>
  8004b7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004bb:	75 0d                	jne    8004ca <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c0:	89 c7                	mov    %eax,%edi
  8004c2:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c8:	eb 55                	jmp    80051f <vprintfmt+0x1e1>
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d0:	ff 75 cc             	pushl  -0x34(%ebp)
  8004d3:	e8 46 03 00 00       	call   80081e <strnlen>
  8004d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004db:	29 c2                	sub    %eax,%edx
  8004dd:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004e5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	7e 11                	jle    800501 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	83 ef 01             	sub    $0x1,%edi
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	eb eb                	jmp    8004ec <vprintfmt+0x1ae>
  800501:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800504:	85 d2                	test   %edx,%edx
  800506:	b8 00 00 00 00       	mov    $0x0,%eax
  80050b:	0f 49 c2             	cmovns %edx,%eax
  80050e:	29 c2                	sub    %eax,%edx
  800510:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800513:	eb a8                	jmp    8004bd <vprintfmt+0x17f>
					putch(ch, putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	52                   	push   %edx
  80051a:	ff d6                	call   *%esi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800522:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800524:	83 c7 01             	add    $0x1,%edi
  800527:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052b:	0f be d0             	movsbl %al,%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	74 4b                	je     80057d <vprintfmt+0x23f>
  800532:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800536:	78 06                	js     80053e <vprintfmt+0x200>
  800538:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80053c:	78 1e                	js     80055c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800542:	74 d1                	je     800515 <vprintfmt+0x1d7>
  800544:	0f be c0             	movsbl %al,%eax
  800547:	83 e8 20             	sub    $0x20,%eax
  80054a:	83 f8 5e             	cmp    $0x5e,%eax
  80054d:	76 c6                	jbe    800515 <vprintfmt+0x1d7>
					putch('?', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 3f                	push   $0x3f
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	eb c3                	jmp    80051f <vprintfmt+0x1e1>
  80055c:	89 cf                	mov    %ecx,%edi
  80055e:	eb 0e                	jmp    80056e <vprintfmt+0x230>
				putch(' ', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	6a 20                	push   $0x20
  800566:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800568:	83 ef 01             	sub    $0x1,%edi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	85 ff                	test   %edi,%edi
  800570:	7f ee                	jg     800560 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800572:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
  800578:	e9 67 01 00 00       	jmp    8006e4 <vprintfmt+0x3a6>
  80057d:	89 cf                	mov    %ecx,%edi
  80057f:	eb ed                	jmp    80056e <vprintfmt+0x230>
	if (lflag >= 2)
  800581:	83 f9 01             	cmp    $0x1,%ecx
  800584:	7f 1b                	jg     8005a1 <vprintfmt+0x263>
	else if (lflag)
  800586:	85 c9                	test   %ecx,%ecx
  800588:	74 63                	je     8005ed <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800592:	99                   	cltd   
  800593:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 40 04             	lea    0x4(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
  80059f:	eb 17                	jmp    8005b8 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 50 04             	mov    0x4(%eax),%edx
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 40 08             	lea    0x8(%eax),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005c3:	85 c9                	test   %ecx,%ecx
  8005c5:	0f 89 ff 00 00 00    	jns    8006ca <vprintfmt+0x38c>
				putch('-', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 2d                	push   $0x2d
  8005d1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d9:	f7 da                	neg    %edx
  8005db:	83 d1 00             	adc    $0x0,%ecx
  8005de:	f7 d9                	neg    %ecx
  8005e0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e8:	e9 dd 00 00 00       	jmp    8006ca <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	99                   	cltd   
  8005f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800602:	eb b4                	jmp    8005b8 <vprintfmt+0x27a>
	if (lflag >= 2)
  800604:	83 f9 01             	cmp    $0x1,%ecx
  800607:	7f 1e                	jg     800627 <vprintfmt+0x2e9>
	else if (lflag)
  800609:	85 c9                	test   %ecx,%ecx
  80060b:	74 32                	je     80063f <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800622:	e9 a3 00 00 00       	jmp    8006ca <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	8b 48 04             	mov    0x4(%eax),%ecx
  80062f:	8d 40 08             	lea    0x8(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800635:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80063a:	e9 8b 00 00 00       	jmp    8006ca <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	b9 00 00 00 00       	mov    $0x0,%ecx
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800654:	eb 74                	jmp    8006ca <vprintfmt+0x38c>
	if (lflag >= 2)
  800656:	83 f9 01             	cmp    $0x1,%ecx
  800659:	7f 1b                	jg     800676 <vprintfmt+0x338>
	else if (lflag)
  80065b:	85 c9                	test   %ecx,%ecx
  80065d:	74 2c                	je     80068b <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 10                	mov    (%eax),%edx
  800664:	b9 00 00 00 00       	mov    $0x0,%ecx
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80066f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800674:	eb 54                	jmp    8006ca <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	8b 48 04             	mov    0x4(%eax),%ecx
  80067e:	8d 40 08             	lea    0x8(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800684:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800689:	eb 3f                	jmp    8006ca <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	b9 00 00 00 00       	mov    $0x0,%ecx
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80069b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006a0:	eb 28                	jmp    8006ca <vprintfmt+0x38c>
			putch('0', putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	6a 30                	push   $0x30
  8006a8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006aa:	83 c4 08             	add    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	6a 78                	push   $0x78
  8006b0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 10                	mov    (%eax),%edx
  8006b7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006bc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006bf:	8d 40 04             	lea    0x4(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006d1:	57                   	push   %edi
  8006d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d5:	50                   	push   %eax
  8006d6:	51                   	push   %ecx
  8006d7:	52                   	push   %edx
  8006d8:	89 da                	mov    %ebx,%edx
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	e8 72 fb ff ff       	call   800253 <printnum>
			break;
  8006e1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	83 f8 25             	cmp    $0x25,%eax
  8006f1:	0f 84 62 fc ff ff    	je     800359 <vprintfmt+0x1b>
			if (ch == '\0')
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	0f 84 8b 00 00 00    	je     80078a <vprintfmt+0x44c>
			putch(ch, putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	53                   	push   %ebx
  800703:	50                   	push   %eax
  800704:	ff d6                	call   *%esi
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	eb dc                	jmp    8006e7 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80070b:	83 f9 01             	cmp    $0x1,%ecx
  80070e:	7f 1b                	jg     80072b <vprintfmt+0x3ed>
	else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	74 2c                	je     800740 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071e:	8d 40 04             	lea    0x4(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800724:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800729:	eb 9f                	jmp    8006ca <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8b 10                	mov    (%eax),%edx
  800730:	8b 48 04             	mov    0x4(%eax),%ecx
  800733:	8d 40 08             	lea    0x8(%eax),%eax
  800736:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800739:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80073e:	eb 8a                	jmp    8006ca <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8b 10                	mov    (%eax),%edx
  800745:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800750:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800755:	e9 70 ff ff ff       	jmp    8006ca <vprintfmt+0x38c>
			putch(ch, putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	6a 25                	push   $0x25
  800760:	ff d6                	call   *%esi
			break;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	e9 7a ff ff ff       	jmp    8006e4 <vprintfmt+0x3a6>
			putch('%', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 25                	push   $0x25
  800770:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	89 f8                	mov    %edi,%eax
  800777:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80077b:	74 05                	je     800782 <vprintfmt+0x444>
  80077d:	83 e8 01             	sub    $0x1,%eax
  800780:	eb f5                	jmp    800777 <vprintfmt+0x439>
  800782:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800785:	e9 5a ff ff ff       	jmp    8006e4 <vprintfmt+0x3a6>
}
  80078a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5f                   	pop    %edi
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800792:	f3 0f 1e fb          	endbr32 
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 18             	sub    $0x18,%esp
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	74 26                	je     8007dd <vsnprintf+0x4b>
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	7e 22                	jle    8007dd <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bb:	ff 75 14             	pushl  0x14(%ebp)
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	68 fc 02 80 00       	push   $0x8002fc
  8007ca:	e8 6f fb ff ff       	call   80033e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d8:	83 c4 10             	add    $0x10,%esp
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
		return -E_INVAL;
  8007dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e2:	eb f7                	jmp    8007db <vsnprintf+0x49>

008007e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e4:	f3 0f 1e fb          	endbr32 
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f1:	50                   	push   %eax
  8007f2:	ff 75 10             	pushl  0x10(%ebp)
  8007f5:	ff 75 0c             	pushl  0xc(%ebp)
  8007f8:	ff 75 08             	pushl  0x8(%ebp)
  8007fb:	e8 92 ff ff ff       	call   800792 <vsnprintf>
	va_end(ap);

	return rc;
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800802:	f3 0f 1e fb          	endbr32 
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800815:	74 05                	je     80081c <strlen+0x1a>
		n++;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	eb f5                	jmp    800811 <strlen+0xf>
	return n;
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081e:	f3 0f 1e fb          	endbr32 
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
  800830:	39 d0                	cmp    %edx,%eax
  800832:	74 0d                	je     800841 <strnlen+0x23>
  800834:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800838:	74 05                	je     80083f <strnlen+0x21>
		n++;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	eb f1                	jmp    800830 <strnlen+0x12>
  80083f:	89 c2                	mov    %eax,%edx
	return n;
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800845:	f3 0f 1e fb          	endbr32 
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800850:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80085c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80085f:	83 c0 01             	add    $0x1,%eax
  800862:	84 d2                	test   %dl,%dl
  800864:	75 f2                	jne    800858 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800866:	89 c8                	mov    %ecx,%eax
  800868:	5b                   	pop    %ebx
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086b:	f3 0f 1e fb          	endbr32 
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	83 ec 10             	sub    $0x10,%esp
  800876:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800879:	53                   	push   %ebx
  80087a:	e8 83 ff ff ff       	call   800802 <strlen>
  80087f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	01 d8                	add    %ebx,%eax
  800887:	50                   	push   %eax
  800888:	e8 b8 ff ff ff       	call   800845 <strcpy>
	return dst;
}
  80088d:	89 d8                	mov    %ebx,%eax
  80088f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800894:	f3 0f 1e fb          	endbr32 
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	56                   	push   %esi
  80089c:	53                   	push   %ebx
  80089d:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a3:	89 f3                	mov    %esi,%ebx
  8008a5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a8:	89 f0                	mov    %esi,%eax
  8008aa:	39 d8                	cmp    %ebx,%eax
  8008ac:	74 11                	je     8008bf <strncpy+0x2b>
		*dst++ = *src;
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	0f b6 0a             	movzbl (%edx),%ecx
  8008b4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b7:	80 f9 01             	cmp    $0x1,%cl
  8008ba:	83 da ff             	sbb    $0xffffffff,%edx
  8008bd:	eb eb                	jmp    8008aa <strncpy+0x16>
	}
	return ret;
}
  8008bf:	89 f0                	mov    %esi,%eax
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c5:	f3 0f 1e fb          	endbr32 
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	74 21                	je     8008fe <strlcpy+0x39>
  8008dd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e1:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008e3:	39 c2                	cmp    %eax,%edx
  8008e5:	74 14                	je     8008fb <strlcpy+0x36>
  8008e7:	0f b6 19             	movzbl (%ecx),%ebx
  8008ea:	84 db                	test   %bl,%bl
  8008ec:	74 0b                	je     8008f9 <strlcpy+0x34>
			*dst++ = *src++;
  8008ee:	83 c1 01             	add    $0x1,%ecx
  8008f1:	83 c2 01             	add    $0x1,%edx
  8008f4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f7:	eb ea                	jmp    8008e3 <strlcpy+0x1e>
  8008f9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008fb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fe:	29 f0                	sub    %esi,%eax
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800904:	f3 0f 1e fb          	endbr32 
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800911:	0f b6 01             	movzbl (%ecx),%eax
  800914:	84 c0                	test   %al,%al
  800916:	74 0c                	je     800924 <strcmp+0x20>
  800918:	3a 02                	cmp    (%edx),%al
  80091a:	75 08                	jne    800924 <strcmp+0x20>
		p++, q++;
  80091c:	83 c1 01             	add    $0x1,%ecx
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	eb ed                	jmp    800911 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800924:	0f b6 c0             	movzbl %al,%eax
  800927:	0f b6 12             	movzbl (%edx),%edx
  80092a:	29 d0                	sub    %edx,%eax
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092e:	f3 0f 1e fb          	endbr32 
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	53                   	push   %ebx
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 c3                	mov    %eax,%ebx
  80093e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800941:	eb 06                	jmp    800949 <strncmp+0x1b>
		n--, p++, q++;
  800943:	83 c0 01             	add    $0x1,%eax
  800946:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800949:	39 d8                	cmp    %ebx,%eax
  80094b:	74 16                	je     800963 <strncmp+0x35>
  80094d:	0f b6 08             	movzbl (%eax),%ecx
  800950:	84 c9                	test   %cl,%cl
  800952:	74 04                	je     800958 <strncmp+0x2a>
  800954:	3a 0a                	cmp    (%edx),%cl
  800956:	74 eb                	je     800943 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	0f b6 12             	movzbl (%edx),%edx
  80095e:	29 d0                	sub    %edx,%eax
}
  800960:	5b                   	pop    %ebx
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    
		return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
  800968:	eb f6                	jmp    800960 <strncmp+0x32>

0080096a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096a:	f3 0f 1e fb          	endbr32 
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800978:	0f b6 10             	movzbl (%eax),%edx
  80097b:	84 d2                	test   %dl,%dl
  80097d:	74 09                	je     800988 <strchr+0x1e>
		if (*s == c)
  80097f:	38 ca                	cmp    %cl,%dl
  800981:	74 0a                	je     80098d <strchr+0x23>
	for (; *s; s++)
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	eb f0                	jmp    800978 <strchr+0xe>
			return (char *) s;
	return 0;
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098f:	f3 0f 1e fb          	endbr32 
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	74 09                	je     8009ad <strfind+0x1e>
  8009a4:	84 d2                	test   %dl,%dl
  8009a6:	74 05                	je     8009ad <strfind+0x1e>
	for (; *s; s++)
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	eb f0                	jmp    80099d <strfind+0xe>
			break;
	return (char *) s;
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009af:	f3 0f 1e fb          	endbr32 
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bf:	85 c9                	test   %ecx,%ecx
  8009c1:	74 31                	je     8009f4 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c3:	89 f8                	mov    %edi,%eax
  8009c5:	09 c8                	or     %ecx,%eax
  8009c7:	a8 03                	test   $0x3,%al
  8009c9:	75 23                	jne    8009ee <memset+0x3f>
		c &= 0xFF;
  8009cb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cf:	89 d3                	mov    %edx,%ebx
  8009d1:	c1 e3 08             	shl    $0x8,%ebx
  8009d4:	89 d0                	mov    %edx,%eax
  8009d6:	c1 e0 18             	shl    $0x18,%eax
  8009d9:	89 d6                	mov    %edx,%esi
  8009db:	c1 e6 10             	shl    $0x10,%esi
  8009de:	09 f0                	or     %esi,%eax
  8009e0:	09 c2                	or     %eax,%edx
  8009e2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e7:	89 d0                	mov    %edx,%eax
  8009e9:	fc                   	cld    
  8009ea:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ec:	eb 06                	jmp    8009f4 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f1:	fc                   	cld    
  8009f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f4:	89 f8                	mov    %edi,%eax
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5f                   	pop    %edi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009fb:	f3 0f 1e fb          	endbr32 
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0d:	39 c6                	cmp    %eax,%esi
  800a0f:	73 32                	jae    800a43 <memmove+0x48>
  800a11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a14:	39 c2                	cmp    %eax,%edx
  800a16:	76 2b                	jbe    800a43 <memmove+0x48>
		s += n;
		d += n;
  800a18:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1b:	89 fe                	mov    %edi,%esi
  800a1d:	09 ce                	or     %ecx,%esi
  800a1f:	09 d6                	or     %edx,%esi
  800a21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a27:	75 0e                	jne    800a37 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a29:	83 ef 04             	sub    $0x4,%edi
  800a2c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a32:	fd                   	std    
  800a33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a35:	eb 09                	jmp    800a40 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a37:	83 ef 01             	sub    $0x1,%edi
  800a3a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a3d:	fd                   	std    
  800a3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a40:	fc                   	cld    
  800a41:	eb 1a                	jmp    800a5d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	09 ca                	or     %ecx,%edx
  800a47:	09 f2                	or     %esi,%edx
  800a49:	f6 c2 03             	test   $0x3,%dl
  800a4c:	75 0a                	jne    800a58 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a56:	eb 05                	jmp    800a5d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	fc                   	cld    
  800a5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a61:	f3 0f 1e fb          	endbr32 
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a6b:	ff 75 10             	pushl  0x10(%ebp)
  800a6e:	ff 75 0c             	pushl  0xc(%ebp)
  800a71:	ff 75 08             	pushl  0x8(%ebp)
  800a74:	e8 82 ff ff ff       	call   8009fb <memmove>
}
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7b:	f3 0f 1e fb          	endbr32 
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8a:	89 c6                	mov    %eax,%esi
  800a8c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8f:	39 f0                	cmp    %esi,%eax
  800a91:	74 1c                	je     800aaf <memcmp+0x34>
		if (*s1 != *s2)
  800a93:	0f b6 08             	movzbl (%eax),%ecx
  800a96:	0f b6 1a             	movzbl (%edx),%ebx
  800a99:	38 d9                	cmp    %bl,%cl
  800a9b:	75 08                	jne    800aa5 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a9d:	83 c0 01             	add    $0x1,%eax
  800aa0:	83 c2 01             	add    $0x1,%edx
  800aa3:	eb ea                	jmp    800a8f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aa5:	0f b6 c1             	movzbl %cl,%eax
  800aa8:	0f b6 db             	movzbl %bl,%ebx
  800aab:	29 d8                	sub    %ebx,%eax
  800aad:	eb 05                	jmp    800ab4 <memcmp+0x39>
	}

	return 0;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac5:	89 c2                	mov    %eax,%edx
  800ac7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aca:	39 d0                	cmp    %edx,%eax
  800acc:	73 09                	jae    800ad7 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	38 08                	cmp    %cl,(%eax)
  800ad0:	74 05                	je     800ad7 <memfind+0x1f>
	for (; s < ends; s++)
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	eb f3                	jmp    800aca <memfind+0x12>
			break;
	return (void *) s;
}
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad9:	f3 0f 1e fb          	endbr32 
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae9:	eb 03                	jmp    800aee <strtol+0x15>
		s++;
  800aeb:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aee:	0f b6 01             	movzbl (%ecx),%eax
  800af1:	3c 20                	cmp    $0x20,%al
  800af3:	74 f6                	je     800aeb <strtol+0x12>
  800af5:	3c 09                	cmp    $0x9,%al
  800af7:	74 f2                	je     800aeb <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800af9:	3c 2b                	cmp    $0x2b,%al
  800afb:	74 2a                	je     800b27 <strtol+0x4e>
	int neg = 0;
  800afd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b02:	3c 2d                	cmp    $0x2d,%al
  800b04:	74 2b                	je     800b31 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b06:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b0c:	75 0f                	jne    800b1d <strtol+0x44>
  800b0e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b11:	74 28                	je     800b3b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1a:	0f 44 d8             	cmove  %eax,%ebx
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b25:	eb 46                	jmp    800b6d <strtol+0x94>
		s++;
  800b27:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2f:	eb d5                	jmp    800b06 <strtol+0x2d>
		s++, neg = 1;
  800b31:	83 c1 01             	add    $0x1,%ecx
  800b34:	bf 01 00 00 00       	mov    $0x1,%edi
  800b39:	eb cb                	jmp    800b06 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3f:	74 0e                	je     800b4f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	75 d8                	jne    800b1d <strtol+0x44>
		s++, base = 8;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b4d:	eb ce                	jmp    800b1d <strtol+0x44>
		s += 2, base = 16;
  800b4f:	83 c1 02             	add    $0x2,%ecx
  800b52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b57:	eb c4                	jmp    800b1d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b59:	0f be d2             	movsbl %dl,%edx
  800b5c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b62:	7d 3a                	jge    800b9e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b64:	83 c1 01             	add    $0x1,%ecx
  800b67:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b6d:	0f b6 11             	movzbl (%ecx),%edx
  800b70:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b73:	89 f3                	mov    %esi,%ebx
  800b75:	80 fb 09             	cmp    $0x9,%bl
  800b78:	76 df                	jbe    800b59 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b7a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b7d:	89 f3                	mov    %esi,%ebx
  800b7f:	80 fb 19             	cmp    $0x19,%bl
  800b82:	77 08                	ja     800b8c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b84:	0f be d2             	movsbl %dl,%edx
  800b87:	83 ea 57             	sub    $0x57,%edx
  800b8a:	eb d3                	jmp    800b5f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b8c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 19             	cmp    $0x19,%bl
  800b94:	77 08                	ja     800b9e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b96:	0f be d2             	movsbl %dl,%edx
  800b99:	83 ea 37             	sub    $0x37,%edx
  800b9c:	eb c1                	jmp    800b5f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba2:	74 05                	je     800ba9 <strtol+0xd0>
		*endptr = (char *) s;
  800ba4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ba9:	89 c2                	mov    %eax,%edx
  800bab:	f7 da                	neg    %edx
  800bad:	85 ff                	test   %edi,%edi
  800baf:	0f 45 c2             	cmovne %edx,%eax
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    
  800bb7:	66 90                	xchg   %ax,%ax
  800bb9:	66 90                	xchg   %ax,%ax
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
