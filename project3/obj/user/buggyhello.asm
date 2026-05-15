
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1a 00 00 00       	call   80004b <libmain>
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
	sys_cputs((char*)1, 1);
  80003d:	6a 01                	push   $0x1
  80003f:	6a 01                	push   $0x1
  800041:	e8 72 00 00 00       	call   8000b8 <sys_cputs>
}
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	c9                   	leave  
  80004a:	c3                   	ret    

0080004b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004b:	f3 0f 1e fb          	endbr32 
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800057:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800061:	00 00 00 
	envid_t current_env = sys_getenvid(); //use sys_getenvid() from the lab 3 page. Kinda makes sense because we are a user!
  800064:	e8 d9 00 00 00       	call   800142 <sys_getenvid>

	thisenv = &envs[ENVX(current_env)]; //not sure why ENVX() is needed for the index but hey the lab 3 doc said to look at inc/env.h so 
  800069:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800071:	c1 e0 05             	shl    $0x5,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x3e>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	56                   	push   %esi
  80008d:	53                   	push   %ebx
  80008e:	e8 a0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800093:	e8 0a 00 00 00       	call   8000a2 <exit>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5e                   	pop    %esi
  8000a0:	5d                   	pop    %ebp
  8000a1:	c3                   	ret    

008000a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a2:	f3 0f 1e fb          	endbr32 
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 4a 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	f3 0f 1e fb          	endbr32 
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	f3 0f 1e fb          	endbr32 
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	f3 0f 1e fb          	endbr32 
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	8b 55 08             	mov    0x8(%ebp),%edx
  800112:	b8 03 00 00 00       	mov    $0x3,%eax
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7f 08                	jg     80012b <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	83 ec 0c             	sub    $0xc,%esp
  80012e:	50                   	push   %eax
  80012f:	6a 03                	push   $0x3
  800131:	68 3a 0e 80 00       	push   $0x800e3a
  800136:	6a 23                	push   $0x23
  800138:	68 57 0e 80 00       	push   $0x800e57
  80013d:	e8 23 00 00 00       	call   800165 <_panic>

00800142 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800142:	f3 0f 1e fb          	endbr32 
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 02 00 00 00       	mov    $0x2,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800165:	f3 0f 1e fb          	endbr32 
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80016e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800171:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800177:	e8 c6 ff ff ff       	call   800142 <sys_getenvid>
  80017c:	83 ec 0c             	sub    $0xc,%esp
  80017f:	ff 75 0c             	pushl  0xc(%ebp)
  800182:	ff 75 08             	pushl  0x8(%ebp)
  800185:	56                   	push   %esi
  800186:	50                   	push   %eax
  800187:	68 68 0e 80 00       	push   $0x800e68
  80018c:	e8 bb 00 00 00       	call   80024c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800191:	83 c4 18             	add    $0x18,%esp
  800194:	53                   	push   %ebx
  800195:	ff 75 10             	pushl  0x10(%ebp)
  800198:	e8 5a 00 00 00       	call   8001f7 <vcprintf>
	cprintf("\n");
  80019d:	c7 04 24 8b 0e 80 00 	movl   $0x800e8b,(%esp)
  8001a4:	e8 a3 00 00 00       	call   80024c <cprintf>
  8001a9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ac:	cc                   	int3   
  8001ad:	eb fd                	jmp    8001ac <_panic+0x47>

008001af <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001af:	f3 0f 1e fb          	endbr32 
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	53                   	push   %ebx
  8001b7:	83 ec 04             	sub    $0x4,%esp
  8001ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001bd:	8b 13                	mov    (%ebx),%edx
  8001bf:	8d 42 01             	lea    0x1(%edx),%eax
  8001c2:	89 03                	mov    %eax,(%ebx)
  8001c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001cb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d0:	74 09                	je     8001db <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	68 ff 00 00 00       	push   $0xff
  8001e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e6:	50                   	push   %eax
  8001e7:	e8 cc fe ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8001ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f2:	83 c4 10             	add    $0x10,%esp
  8001f5:	eb db                	jmp    8001d2 <putch+0x23>

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	f3 0f 1e fb          	endbr32 
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800204:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020b:	00 00 00 
	b.cnt = 0;
  80020e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800215:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800218:	ff 75 0c             	pushl  0xc(%ebp)
  80021b:	ff 75 08             	pushl  0x8(%ebp)
  80021e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	68 af 01 80 00       	push   $0x8001af
  80022a:	e8 20 01 00 00       	call   80034f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022f:	83 c4 08             	add    $0x8,%esp
  800232:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800238:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023e:	50                   	push   %eax
  80023f:	e8 74 fe ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800244:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024c:	f3 0f 1e fb          	endbr32 
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800256:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800259:	50                   	push   %eax
  80025a:	ff 75 08             	pushl  0x8(%ebp)
  80025d:	e8 95 ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 1c             	sub    $0x1c,%esp
  80026d:	89 c7                	mov    %eax,%edi
  80026f:	89 d6                	mov    %edx,%esi
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	8b 55 0c             	mov    0xc(%ebp),%edx
  800277:	89 d1                	mov    %edx,%ecx
  800279:	89 c2                	mov    %eax,%edx
  80027b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800281:	8b 45 10             	mov    0x10(%ebp),%eax
  800284:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800291:	39 c2                	cmp    %eax,%edx
  800293:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800296:	72 3e                	jb     8002d6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800298:	83 ec 0c             	sub    $0xc,%esp
  80029b:	ff 75 18             	pushl  0x18(%ebp)
  80029e:	83 eb 01             	sub    $0x1,%ebx
  8002a1:	53                   	push   %ebx
  8002a2:	50                   	push   %eax
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8002af:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b2:	e8 19 09 00 00       	call   800bd0 <__udivdi3>
  8002b7:	83 c4 18             	add    $0x18,%esp
  8002ba:	52                   	push   %edx
  8002bb:	50                   	push   %eax
  8002bc:	89 f2                	mov    %esi,%edx
  8002be:	89 f8                	mov    %edi,%eax
  8002c0:	e8 9f ff ff ff       	call   800264 <printnum>
  8002c5:	83 c4 20             	add    $0x20,%esp
  8002c8:	eb 13                	jmp    8002dd <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	56                   	push   %esi
  8002ce:	ff 75 18             	pushl  0x18(%ebp)
  8002d1:	ff d7                	call   *%edi
  8002d3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002d6:	83 eb 01             	sub    $0x1,%ebx
  8002d9:	85 db                	test   %ebx,%ebx
  8002db:	7f ed                	jg     8002ca <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002dd:	83 ec 08             	sub    $0x8,%esp
  8002e0:	56                   	push   %esi
  8002e1:	83 ec 04             	sub    $0x4,%esp
  8002e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f0:	e8 eb 09 00 00       	call   800ce0 <__umoddi3>
  8002f5:	83 c4 14             	add    $0x14,%esp
  8002f8:	0f be 80 8d 0e 80 00 	movsbl 0x800e8d(%eax),%eax
  8002ff:	50                   	push   %eax
  800300:	ff d7                	call   *%edi
}
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030d:	f3 0f 1e fb          	endbr32 
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800317:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	3b 50 04             	cmp    0x4(%eax),%edx
  800320:	73 0a                	jae    80032c <sprintputch+0x1f>
		*b->buf++ = ch;
  800322:	8d 4a 01             	lea    0x1(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	88 02                	mov    %al,(%edx)
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <printfmt>:
{
  80032e:	f3 0f 1e fb          	endbr32 
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800338:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033b:	50                   	push   %eax
  80033c:	ff 75 10             	pushl  0x10(%ebp)
  80033f:	ff 75 0c             	pushl  0xc(%ebp)
  800342:	ff 75 08             	pushl  0x8(%ebp)
  800345:	e8 05 00 00 00       	call   80034f <vprintfmt>
}
  80034a:	83 c4 10             	add    $0x10,%esp
  80034d:	c9                   	leave  
  80034e:	c3                   	ret    

0080034f <vprintfmt>:
{
  80034f:	f3 0f 1e fb          	endbr32 
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	57                   	push   %edi
  800357:	56                   	push   %esi
  800358:	53                   	push   %ebx
  800359:	83 ec 3c             	sub    $0x3c,%esp
  80035c:	8b 75 08             	mov    0x8(%ebp),%esi
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800362:	8b 7d 10             	mov    0x10(%ebp),%edi
  800365:	e9 8e 03 00 00       	jmp    8006f8 <vprintfmt+0x3a9>
		padc = ' ';
  80036a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80036e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800375:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80037c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800383:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8d 47 01             	lea    0x1(%edi),%eax
  80038b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038e:	0f b6 17             	movzbl (%edi),%edx
  800391:	8d 42 dd             	lea    -0x23(%edx),%eax
  800394:	3c 55                	cmp    $0x55,%al
  800396:	0f 87 df 03 00 00    	ja     80077b <vprintfmt+0x42c>
  80039c:	0f b6 c0             	movzbl %al,%eax
  80039f:	3e ff 24 85 1c 0f 80 	notrack jmp *0x800f1c(,%eax,4)
  8003a6:	00 
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003aa:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003ae:	eb d8                	jmp    800388 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003b7:	eb cf                	jmp    800388 <vprintfmt+0x39>
  8003b9:	0f b6 d2             	movzbl %dl,%edx
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003c7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ca:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ce:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003d1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003d4:	83 f9 09             	cmp    $0x9,%ecx
  8003d7:	77 55                	ja     80042e <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003d9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003dc:	eb e9                	jmp    8003c7 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 40 04             	lea    0x4(%eax),%eax
  8003ec:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f6:	79 90                	jns    800388 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fe:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800405:	eb 81                	jmp    800388 <vprintfmt+0x39>
  800407:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040a:	85 c0                	test   %eax,%eax
  80040c:	ba 00 00 00 00       	mov    $0x0,%edx
  800411:	0f 49 d0             	cmovns %eax,%edx
  800414:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041a:	e9 69 ff ff ff       	jmp    800388 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800422:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800429:	e9 5a ff ff ff       	jmp    800388 <vprintfmt+0x39>
  80042e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800431:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800434:	eb bc                	jmp    8003f2 <vprintfmt+0xa3>
			lflag++;
  800436:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80043c:	e9 47 ff ff ff       	jmp    800388 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 78 04             	lea    0x4(%eax),%edi
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	53                   	push   %ebx
  80044b:	ff 30                	pushl  (%eax)
  80044d:	ff d6                	call   *%esi
			break;
  80044f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800452:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800455:	e9 9b 02 00 00       	jmp    8006f5 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 78 04             	lea    0x4(%eax),%edi
  800460:	8b 00                	mov    (%eax),%eax
  800462:	99                   	cltd   
  800463:	31 d0                	xor    %edx,%eax
  800465:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800467:	83 f8 06             	cmp    $0x6,%eax
  80046a:	7f 23                	jg     80048f <vprintfmt+0x140>
  80046c:	8b 14 85 74 10 80 00 	mov    0x801074(,%eax,4),%edx
  800473:	85 d2                	test   %edx,%edx
  800475:	74 18                	je     80048f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800477:	52                   	push   %edx
  800478:	68 ae 0e 80 00       	push   $0x800eae
  80047d:	53                   	push   %ebx
  80047e:	56                   	push   %esi
  80047f:	e8 aa fe ff ff       	call   80032e <printfmt>
  800484:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800487:	89 7d 14             	mov    %edi,0x14(%ebp)
  80048a:	e9 66 02 00 00       	jmp    8006f5 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80048f:	50                   	push   %eax
  800490:	68 a5 0e 80 00       	push   $0x800ea5
  800495:	53                   	push   %ebx
  800496:	56                   	push   %esi
  800497:	e8 92 fe ff ff       	call   80032e <printfmt>
  80049c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80049f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004a2:	e9 4e 02 00 00       	jmp    8006f5 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	83 c0 04             	add    $0x4,%eax
  8004ad:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004b5:	85 d2                	test   %edx,%edx
  8004b7:	b8 9e 0e 80 00       	mov    $0x800e9e,%eax
  8004bc:	0f 45 c2             	cmovne %edx,%eax
  8004bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c6:	7e 06                	jle    8004ce <vprintfmt+0x17f>
  8004c8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004cc:	75 0d                	jne    8004db <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	03 45 e0             	add    -0x20(%ebp),%eax
  8004d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d9:	eb 55                	jmp    800530 <vprintfmt+0x1e1>
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e1:	ff 75 cc             	pushl  -0x34(%ebp)
  8004e4:	e8 46 03 00 00       	call   80082f <strnlen>
  8004e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ec:	29 c2                	sub    %eax,%edx
  8004ee:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004f6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	85 ff                	test   %edi,%edi
  8004ff:	7e 11                	jle    800512 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	ff 75 e0             	pushl  -0x20(%ebp)
  800508:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	83 ef 01             	sub    $0x1,%edi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	eb eb                	jmp    8004fd <vprintfmt+0x1ae>
  800512:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800515:	85 d2                	test   %edx,%edx
  800517:	b8 00 00 00 00       	mov    $0x0,%eax
  80051c:	0f 49 c2             	cmovns %edx,%eax
  80051f:	29 c2                	sub    %eax,%edx
  800521:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800524:	eb a8                	jmp    8004ce <vprintfmt+0x17f>
					putch(ch, putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	53                   	push   %ebx
  80052a:	52                   	push   %edx
  80052b:	ff d6                	call   *%esi
  80052d:	83 c4 10             	add    $0x10,%esp
  800530:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800533:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800535:	83 c7 01             	add    $0x1,%edi
  800538:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053c:	0f be d0             	movsbl %al,%edx
  80053f:	85 d2                	test   %edx,%edx
  800541:	74 4b                	je     80058e <vprintfmt+0x23f>
  800543:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800547:	78 06                	js     80054f <vprintfmt+0x200>
  800549:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80054d:	78 1e                	js     80056d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800553:	74 d1                	je     800526 <vprintfmt+0x1d7>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 c6                	jbe    800526 <vprintfmt+0x1d7>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	6a 3f                	push   $0x3f
  800566:	ff d6                	call   *%esi
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	eb c3                	jmp    800530 <vprintfmt+0x1e1>
  80056d:	89 cf                	mov    %ecx,%edi
  80056f:	eb 0e                	jmp    80057f <vprintfmt+0x230>
				putch(' ', putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	53                   	push   %ebx
  800575:	6a 20                	push   $0x20
  800577:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800579:	83 ef 01             	sub    $0x1,%edi
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	85 ff                	test   %edi,%edi
  800581:	7f ee                	jg     800571 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800583:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
  800589:	e9 67 01 00 00       	jmp    8006f5 <vprintfmt+0x3a6>
  80058e:	89 cf                	mov    %ecx,%edi
  800590:	eb ed                	jmp    80057f <vprintfmt+0x230>
	if (lflag >= 2)
  800592:	83 f9 01             	cmp    $0x1,%ecx
  800595:	7f 1b                	jg     8005b2 <vprintfmt+0x263>
	else if (lflag)
  800597:	85 c9                	test   %ecx,%ecx
  800599:	74 63                	je     8005fe <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a3:	99                   	cltd   
  8005a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b0:	eb 17                	jmp    8005c9 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 50 04             	mov    0x4(%eax),%edx
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 40 08             	lea    0x8(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005cf:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d4:	85 c9                	test   %ecx,%ecx
  8005d6:	0f 89 ff 00 00 00    	jns    8006db <vprintfmt+0x38c>
				putch('-', putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	53                   	push   %ebx
  8005e0:	6a 2d                	push   $0x2d
  8005e2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ea:	f7 da                	neg    %edx
  8005ec:	83 d1 00             	adc    $0x0,%ecx
  8005ef:	f7 d9                	neg    %ecx
  8005f1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f9:	e9 dd 00 00 00       	jmp    8006db <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	99                   	cltd   
  800607:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
  800613:	eb b4                	jmp    8005c9 <vprintfmt+0x27a>
	if (lflag >= 2)
  800615:	83 f9 01             	cmp    $0x1,%ecx
  800618:	7f 1e                	jg     800638 <vprintfmt+0x2e9>
	else if (lflag)
  80061a:	85 c9                	test   %ecx,%ecx
  80061c:	74 32                	je     800650 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8b 10                	mov    (%eax),%edx
  800623:	b9 00 00 00 00       	mov    $0x0,%ecx
  800628:	8d 40 04             	lea    0x4(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800633:	e9 a3 00 00 00       	jmp    8006db <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	8b 48 04             	mov    0x4(%eax),%ecx
  800640:	8d 40 08             	lea    0x8(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80064b:	e9 8b 00 00 00       	jmp    8006db <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800660:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800665:	eb 74                	jmp    8006db <vprintfmt+0x38c>
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7f 1b                	jg     800687 <vprintfmt+0x338>
	else if (lflag)
  80066c:	85 c9                	test   %ecx,%ecx
  80066e:	74 2c                	je     80069c <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800680:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800685:	eb 54                	jmp    8006db <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	8b 48 04             	mov    0x4(%eax),%ecx
  80068f:	8d 40 08             	lea    0x8(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80069a:	eb 3f                	jmp    8006db <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8006ac:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006b1:	eb 28                	jmp    8006db <vprintfmt+0x38c>
			putch('0', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 30                	push   $0x30
  8006b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 78                	push   $0x78
  8006c1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006cd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006db:	83 ec 0c             	sub    $0xc,%esp
  8006de:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006e2:	57                   	push   %edi
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	50                   	push   %eax
  8006e7:	51                   	push   %ecx
  8006e8:	52                   	push   %edx
  8006e9:	89 da                	mov    %ebx,%edx
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	e8 72 fb ff ff       	call   800264 <printnum>
			break;
  8006f2:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f8:	83 c7 01             	add    $0x1,%edi
  8006fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ff:	83 f8 25             	cmp    $0x25,%eax
  800702:	0f 84 62 fc ff ff    	je     80036a <vprintfmt+0x1b>
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 8b 00 00 00    	je     80079b <vprintfmt+0x44c>
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb dc                	jmp    8006f8 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80071c:	83 f9 01             	cmp    $0x1,%ecx
  80071f:	7f 1b                	jg     80073c <vprintfmt+0x3ed>
	else if (lflag)
  800721:	85 c9                	test   %ecx,%ecx
  800723:	74 2c                	je     800751 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800735:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80073a:	eb 9f                	jmp    8006db <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 10                	mov    (%eax),%edx
  800741:	8b 48 04             	mov    0x4(%eax),%ecx
  800744:	8d 40 08             	lea    0x8(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80074f:	eb 8a                	jmp    8006db <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 10                	mov    (%eax),%edx
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	8d 40 04             	lea    0x4(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800761:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800766:	e9 70 ff ff ff       	jmp    8006db <vprintfmt+0x38c>
			putch(ch, putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	6a 25                	push   $0x25
  800771:	ff d6                	call   *%esi
			break;
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	e9 7a ff ff ff       	jmp    8006f5 <vprintfmt+0x3a6>
			putch('%', putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 25                	push   $0x25
  800781:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	89 f8                	mov    %edi,%eax
  800788:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80078c:	74 05                	je     800793 <vprintfmt+0x444>
  80078e:	83 e8 01             	sub    $0x1,%eax
  800791:	eb f5                	jmp    800788 <vprintfmt+0x439>
  800793:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800796:	e9 5a ff ff ff       	jmp    8006f5 <vprintfmt+0x3a6>
}
  80079b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5f                   	pop    %edi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a3:	f3 0f 1e fb          	endbr32 
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 18             	sub    $0x18,%esp
  8007ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c4:	85 c0                	test   %eax,%eax
  8007c6:	74 26                	je     8007ee <vsnprintf+0x4b>
  8007c8:	85 d2                	test   %edx,%edx
  8007ca:	7e 22                	jle    8007ee <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cc:	ff 75 14             	pushl  0x14(%ebp)
  8007cf:	ff 75 10             	pushl  0x10(%ebp)
  8007d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	68 0d 03 80 00       	push   $0x80030d
  8007db:	e8 6f fb ff ff       	call   80034f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e9:	83 c4 10             	add    $0x10,%esp
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    
		return -E_INVAL;
  8007ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f3:	eb f7                	jmp    8007ec <vsnprintf+0x49>

008007f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f5:	f3 0f 1e fb          	endbr32 
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800802:	50                   	push   %eax
  800803:	ff 75 10             	pushl  0x10(%ebp)
  800806:	ff 75 0c             	pushl  0xc(%ebp)
  800809:	ff 75 08             	pushl  0x8(%ebp)
  80080c:	e8 92 ff ff ff       	call   8007a3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800813:	f3 0f 1e fb          	endbr32 
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081d:	b8 00 00 00 00       	mov    $0x0,%eax
  800822:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800826:	74 05                	je     80082d <strlen+0x1a>
		n++;
  800828:	83 c0 01             	add    $0x1,%eax
  80082b:	eb f5                	jmp    800822 <strlen+0xf>
	return n;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082f:	f3 0f 1e fb          	endbr32 
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	39 d0                	cmp    %edx,%eax
  800843:	74 0d                	je     800852 <strnlen+0x23>
  800845:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800849:	74 05                	je     800850 <strnlen+0x21>
		n++;
  80084b:	83 c0 01             	add    $0x1,%eax
  80084e:	eb f1                	jmp    800841 <strnlen+0x12>
  800850:	89 c2                	mov    %eax,%edx
	return n;
}
  800852:	89 d0                	mov    %edx,%eax
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800856:	f3 0f 1e fb          	endbr32 
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
  800869:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80086d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	84 d2                	test   %dl,%dl
  800875:	75 f2                	jne    800869 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800877:	89 c8                	mov    %ecx,%eax
  800879:	5b                   	pop    %ebx
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087c:	f3 0f 1e fb          	endbr32 
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	53                   	push   %ebx
  800884:	83 ec 10             	sub    $0x10,%esp
  800887:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088a:	53                   	push   %ebx
  80088b:	e8 83 ff ff ff       	call   800813 <strlen>
  800890:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800893:	ff 75 0c             	pushl  0xc(%ebp)
  800896:	01 d8                	add    %ebx,%eax
  800898:	50                   	push   %eax
  800899:	e8 b8 ff ff ff       	call   800856 <strcpy>
	return dst;
}
  80089e:	89 d8                	mov    %ebx,%eax
  8008a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a5:	f3 0f 1e fb          	endbr32 
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b4:	89 f3                	mov    %esi,%ebx
  8008b6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	89 f0                	mov    %esi,%eax
  8008bb:	39 d8                	cmp    %ebx,%eax
  8008bd:	74 11                	je     8008d0 <strncpy+0x2b>
		*dst++ = *src;
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	0f b6 0a             	movzbl (%edx),%ecx
  8008c5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c8:	80 f9 01             	cmp    $0x1,%cl
  8008cb:	83 da ff             	sbb    $0xffffffff,%edx
  8008ce:	eb eb                	jmp    8008bb <strncpy+0x16>
	}
	return ret;
}
  8008d0:	89 f0                	mov    %esi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d6:	f3 0f 1e fb          	endbr32 
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e5:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ea:	85 d2                	test   %edx,%edx
  8008ec:	74 21                	je     80090f <strlcpy+0x39>
  8008ee:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f2:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008f4:	39 c2                	cmp    %eax,%edx
  8008f6:	74 14                	je     80090c <strlcpy+0x36>
  8008f8:	0f b6 19             	movzbl (%ecx),%ebx
  8008fb:	84 db                	test   %bl,%bl
  8008fd:	74 0b                	je     80090a <strlcpy+0x34>
			*dst++ = *src++;
  8008ff:	83 c1 01             	add    $0x1,%ecx
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	88 5a ff             	mov    %bl,-0x1(%edx)
  800908:	eb ea                	jmp    8008f4 <strlcpy+0x1e>
  80090a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80090c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80090f:	29 f0                	sub    %esi,%eax
}
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800915:	f3 0f 1e fb          	endbr32 
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800922:	0f b6 01             	movzbl (%ecx),%eax
  800925:	84 c0                	test   %al,%al
  800927:	74 0c                	je     800935 <strcmp+0x20>
  800929:	3a 02                	cmp    (%edx),%al
  80092b:	75 08                	jne    800935 <strcmp+0x20>
		p++, q++;
  80092d:	83 c1 01             	add    $0x1,%ecx
  800930:	83 c2 01             	add    $0x1,%edx
  800933:	eb ed                	jmp    800922 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800935:	0f b6 c0             	movzbl %al,%eax
  800938:	0f b6 12             	movzbl (%edx),%edx
  80093b:	29 d0                	sub    %edx,%eax
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093f:	f3 0f 1e fb          	endbr32 
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	89 c3                	mov    %eax,%ebx
  80094f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800952:	eb 06                	jmp    80095a <strncmp+0x1b>
		n--, p++, q++;
  800954:	83 c0 01             	add    $0x1,%eax
  800957:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80095a:	39 d8                	cmp    %ebx,%eax
  80095c:	74 16                	je     800974 <strncmp+0x35>
  80095e:	0f b6 08             	movzbl (%eax),%ecx
  800961:	84 c9                	test   %cl,%cl
  800963:	74 04                	je     800969 <strncmp+0x2a>
  800965:	3a 0a                	cmp    (%edx),%cl
  800967:	74 eb                	je     800954 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800969:	0f b6 00             	movzbl (%eax),%eax
  80096c:	0f b6 12             	movzbl (%edx),%edx
  80096f:	29 d0                	sub    %edx,%eax
}
  800971:	5b                   	pop    %ebx
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    
		return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
  800979:	eb f6                	jmp    800971 <strncmp+0x32>

0080097b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097b:	f3 0f 1e fb          	endbr32 
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800989:	0f b6 10             	movzbl (%eax),%edx
  80098c:	84 d2                	test   %dl,%dl
  80098e:	74 09                	je     800999 <strchr+0x1e>
		if (*s == c)
  800990:	38 ca                	cmp    %cl,%dl
  800992:	74 0a                	je     80099e <strchr+0x23>
	for (; *s; s++)
  800994:	83 c0 01             	add    $0x1,%eax
  800997:	eb f0                	jmp    800989 <strchr+0xe>
			return (char *) s;
	return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a0:	f3 0f 1e fb          	endbr32 
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 09                	je     8009be <strfind+0x1e>
  8009b5:	84 d2                	test   %dl,%dl
  8009b7:	74 05                	je     8009be <strfind+0x1e>
	for (; *s; s++)
  8009b9:	83 c0 01             	add    $0x1,%eax
  8009bc:	eb f0                	jmp    8009ae <strfind+0xe>
			break;
	return (char *) s;
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c0:	f3 0f 1e fb          	endbr32 
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d0:	85 c9                	test   %ecx,%ecx
  8009d2:	74 31                	je     800a05 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	09 c8                	or     %ecx,%eax
  8009d8:	a8 03                	test   $0x3,%al
  8009da:	75 23                	jne    8009ff <memset+0x3f>
		c &= 0xFF;
  8009dc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e0:	89 d3                	mov    %edx,%ebx
  8009e2:	c1 e3 08             	shl    $0x8,%ebx
  8009e5:	89 d0                	mov    %edx,%eax
  8009e7:	c1 e0 18             	shl    $0x18,%eax
  8009ea:	89 d6                	mov    %edx,%esi
  8009ec:	c1 e6 10             	shl    $0x10,%esi
  8009ef:	09 f0                	or     %esi,%eax
  8009f1:	09 c2                	or     %eax,%edx
  8009f3:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009f8:	89 d0                	mov    %edx,%eax
  8009fa:	fc                   	cld    
  8009fb:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fd:	eb 06                	jmp    800a05 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	fc                   	cld    
  800a03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a05:	89 f8                	mov    %edi,%eax
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0c:	f3 0f 1e fb          	endbr32 
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1e:	39 c6                	cmp    %eax,%esi
  800a20:	73 32                	jae    800a54 <memmove+0x48>
  800a22:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a25:	39 c2                	cmp    %eax,%edx
  800a27:	76 2b                	jbe    800a54 <memmove+0x48>
		s += n;
		d += n;
  800a29:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2c:	89 fe                	mov    %edi,%esi
  800a2e:	09 ce                	or     %ecx,%esi
  800a30:	09 d6                	or     %edx,%esi
  800a32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a38:	75 0e                	jne    800a48 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a3a:	83 ef 04             	sub    $0x4,%edi
  800a3d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a40:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a43:	fd                   	std    
  800a44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a46:	eb 09                	jmp    800a51 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a48:	83 ef 01             	sub    $0x1,%edi
  800a4b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a4e:	fd                   	std    
  800a4f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a51:	fc                   	cld    
  800a52:	eb 1a                	jmp    800a6e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a54:	89 c2                	mov    %eax,%edx
  800a56:	09 ca                	or     %ecx,%edx
  800a58:	09 f2                	or     %esi,%edx
  800a5a:	f6 c2 03             	test   $0x3,%dl
  800a5d:	75 0a                	jne    800a69 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	fc                   	cld    
  800a65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a67:	eb 05                	jmp    800a6e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a69:	89 c7                	mov    %eax,%edi
  800a6b:	fc                   	cld    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a72:	f3 0f 1e fb          	endbr32 
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a7c:	ff 75 10             	pushl  0x10(%ebp)
  800a7f:	ff 75 0c             	pushl  0xc(%ebp)
  800a82:	ff 75 08             	pushl  0x8(%ebp)
  800a85:	e8 82 ff ff ff       	call   800a0c <memmove>
}
  800a8a:	c9                   	leave  
  800a8b:	c3                   	ret    

00800a8c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8c:	f3 0f 1e fb          	endbr32 
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9b:	89 c6                	mov    %eax,%esi
  800a9d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa0:	39 f0                	cmp    %esi,%eax
  800aa2:	74 1c                	je     800ac0 <memcmp+0x34>
		if (*s1 != *s2)
  800aa4:	0f b6 08             	movzbl (%eax),%ecx
  800aa7:	0f b6 1a             	movzbl (%edx),%ebx
  800aaa:	38 d9                	cmp    %bl,%cl
  800aac:	75 08                	jne    800ab6 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aae:	83 c0 01             	add    $0x1,%eax
  800ab1:	83 c2 01             	add    $0x1,%edx
  800ab4:	eb ea                	jmp    800aa0 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ab6:	0f b6 c1             	movzbl %cl,%eax
  800ab9:	0f b6 db             	movzbl %bl,%ebx
  800abc:	29 d8                	sub    %ebx,%eax
  800abe:	eb 05                	jmp    800ac5 <memcmp+0x39>
	}

	return 0;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac9:	f3 0f 1e fb          	endbr32 
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ad6:	89 c2                	mov    %eax,%edx
  800ad8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800adb:	39 d0                	cmp    %edx,%eax
  800add:	73 09                	jae    800ae8 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800adf:	38 08                	cmp    %cl,(%eax)
  800ae1:	74 05                	je     800ae8 <memfind+0x1f>
	for (; s < ends; s++)
  800ae3:	83 c0 01             	add    $0x1,%eax
  800ae6:	eb f3                	jmp    800adb <memfind+0x12>
			break;
	return (void *) s;
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aea:	f3 0f 1e fb          	endbr32 
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afa:	eb 03                	jmp    800aff <strtol+0x15>
		s++;
  800afc:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aff:	0f b6 01             	movzbl (%ecx),%eax
  800b02:	3c 20                	cmp    $0x20,%al
  800b04:	74 f6                	je     800afc <strtol+0x12>
  800b06:	3c 09                	cmp    $0x9,%al
  800b08:	74 f2                	je     800afc <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b0a:	3c 2b                	cmp    $0x2b,%al
  800b0c:	74 2a                	je     800b38 <strtol+0x4e>
	int neg = 0;
  800b0e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b13:	3c 2d                	cmp    $0x2d,%al
  800b15:	74 2b                	je     800b42 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b1d:	75 0f                	jne    800b2e <strtol+0x44>
  800b1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b22:	74 28                	je     800b4c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2b:	0f 44 d8             	cmove  %eax,%ebx
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b33:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b36:	eb 46                	jmp    800b7e <strtol+0x94>
		s++;
  800b38:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b40:	eb d5                	jmp    800b17 <strtol+0x2d>
		s++, neg = 1;
  800b42:	83 c1 01             	add    $0x1,%ecx
  800b45:	bf 01 00 00 00       	mov    $0x1,%edi
  800b4a:	eb cb                	jmp    800b17 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b50:	74 0e                	je     800b60 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b52:	85 db                	test   %ebx,%ebx
  800b54:	75 d8                	jne    800b2e <strtol+0x44>
		s++, base = 8;
  800b56:	83 c1 01             	add    $0x1,%ecx
  800b59:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b5e:	eb ce                	jmp    800b2e <strtol+0x44>
		s += 2, base = 16;
  800b60:	83 c1 02             	add    $0x2,%ecx
  800b63:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b68:	eb c4                	jmp    800b2e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b6a:	0f be d2             	movsbl %dl,%edx
  800b6d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b73:	7d 3a                	jge    800baf <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b75:	83 c1 01             	add    $0x1,%ecx
  800b78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b7e:	0f b6 11             	movzbl (%ecx),%edx
  800b81:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b84:	89 f3                	mov    %esi,%ebx
  800b86:	80 fb 09             	cmp    $0x9,%bl
  800b89:	76 df                	jbe    800b6a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8e:	89 f3                	mov    %esi,%ebx
  800b90:	80 fb 19             	cmp    $0x19,%bl
  800b93:	77 08                	ja     800b9d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b95:	0f be d2             	movsbl %dl,%edx
  800b98:	83 ea 57             	sub    $0x57,%edx
  800b9b:	eb d3                	jmp    800b70 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b9d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba0:	89 f3                	mov    %esi,%ebx
  800ba2:	80 fb 19             	cmp    $0x19,%bl
  800ba5:	77 08                	ja     800baf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ba7:	0f be d2             	movsbl %dl,%edx
  800baa:	83 ea 37             	sub    $0x37,%edx
  800bad:	eb c1                	jmp    800b70 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800baf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb3:	74 05                	je     800bba <strtol+0xd0>
		*endptr = (char *) s;
  800bb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bba:	89 c2                	mov    %eax,%edx
  800bbc:	f7 da                	neg    %edx
  800bbe:	85 ff                	test   %edi,%edi
  800bc0:	0f 45 c2             	cmovne %edx,%eax
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    
  800bc8:	66 90                	xchg   %ax,%ax
  800bca:	66 90                	xchg   %ax,%ax
  800bcc:	66 90                	xchg   %ax,%ax
  800bce:	66 90                	xchg   %ax,%ax

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
