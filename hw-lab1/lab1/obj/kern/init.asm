
obj/kern/init.o:     file format elf32-i386


Disassembly of section .text:

00000000 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
   0:	55                   	push   ebp
   1:	89 e5                	mov    ebp,esp
   3:	83 ec 18             	sub    esp,0x18
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
   6:	8b 45 0c             	mov    eax,DWORD PTR [ebp+0xc]
   9:	89 44 24 08          	mov    DWORD PTR [esp+0x8],eax
   d:	8b 45 08             	mov    eax,DWORD PTR [ebp+0x8]
  10:	89 44 24 04          	mov    DWORD PTR [esp+0x4],eax
  14:	c7 04 24 00 00 00 00 	mov    DWORD PTR [esp],0x0
  1b:	e8 fc ff ff ff       	call   1c <_warn+0x1c>
	vcprintf(fmt, ap);
  20:	8d 45 14             	lea    eax,[ebp+0x14]
  23:	89 44 24 04          	mov    DWORD PTR [esp+0x4],eax
  27:	8b 45 10             	mov    eax,DWORD PTR [ebp+0x10]
  2a:	89 04 24             	mov    DWORD PTR [esp],eax
  2d:	e8 fc ff ff ff       	call   2e <_warn+0x2e>
	cprintf("\n");
  32:	c7 04 24 1a 00 00 00 	mov    DWORD PTR [esp],0x1a
  39:	e8 fc ff ff ff       	call   3a <_warn+0x3a>
	va_end(ap);
}
  3e:	c9                   	leave  
  3f:	c3                   	ret    

00000040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  40:	55                   	push   ebp
  41:	89 e5                	mov    ebp,esp
  43:	83 ec 18             	sub    esp,0x18
	va_list ap;

	if (panicstr)
  46:	83 3d 00 00 00 00 00 	cmp    DWORD PTR ds:0x0,0x0
  4d:	75 40                	jne    8f <_panic+0x4f>
		goto dead;
	panicstr = fmt;
  4f:	8b 45 10             	mov    eax,DWORD PTR [ebp+0x10]
  52:	a3 00 00 00 00       	mov    ds:0x0,eax

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
  57:	8b 45 0c             	mov    eax,DWORD PTR [ebp+0xc]
  5a:	89 44 24 08          	mov    DWORD PTR [esp+0x8],eax
  5e:	8b 45 08             	mov    eax,DWORD PTR [ebp+0x8]
  61:	89 44 24 04          	mov    DWORD PTR [esp+0x4],eax
  65:	c7 04 24 1c 00 00 00 	mov    DWORD PTR [esp],0x1c
  6c:	e8 fc ff ff ff       	call   6d <_panic+0x2d>
	vcprintf(fmt, ap);
  71:	8d 45 14             	lea    eax,[ebp+0x14]
  74:	89 44 24 04          	mov    DWORD PTR [esp+0x4],eax
  78:	8b 45 10             	mov    eax,DWORD PTR [ebp+0x10]
  7b:	89 04 24             	mov    DWORD PTR [esp],eax
  7e:	e8 fc ff ff ff       	call   7f <_panic+0x3f>
	cprintf("\n");
  83:	c7 04 24 1a 00 00 00 	mov    DWORD PTR [esp],0x1a
  8a:	e8 fc ff ff ff       	call   8b <_panic+0x4b>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
  8f:	c7 04 24 00 00 00 00 	mov    DWORD PTR [esp],0x0
  96:	e8 fc ff ff ff       	call   97 <_panic+0x57>
  9b:	eb f2                	jmp    8f <_panic+0x4f>

0000009d <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
  9d:	55                   	push   ebp
  9e:	89 e5                	mov    ebp,esp
  a0:	53                   	push   ebx
  a1:	83 ec 14             	sub    esp,0x14
  a4:	8b 5d 08             	mov    ebx,DWORD PTR [ebp+0x8]
	cprintf("entering test_backtrace %d\n", x);
  a7:	89 5c 24 04          	mov    DWORD PTR [esp+0x4],ebx
  ab:	c7 04 24 34 00 00 00 	mov    DWORD PTR [esp],0x34
  b2:	e8 fc ff ff ff       	call   b3 <test_backtrace+0x16>
	if (x > 0)
  b7:	85 db                	test   ebx,ebx
  b9:	7e 0d                	jle    c8 <test_backtrace+0x2b>
		test_backtrace(x-1);
  bb:	8d 43 ff             	lea    eax,[ebx-0x1]
  be:	89 04 24             	mov    DWORD PTR [esp],eax
  c1:	e8 fc ff ff ff       	call   c2 <test_backtrace+0x25>
  c6:	eb 1c                	jmp    e4 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
  c8:	c7 44 24 08 00 00 00 	mov    DWORD PTR [esp+0x8],0x0
  cf:	00 
  d0:	c7 44 24 04 00 00 00 	mov    DWORD PTR [esp+0x4],0x0
  d7:	00 
  d8:	c7 04 24 00 00 00 00 	mov    DWORD PTR [esp],0x0
  df:	e8 fc ff ff ff       	call   e0 <test_backtrace+0x43>
	cprintf("leaving test_backtrace %d\n", x);
  e4:	89 5c 24 04          	mov    DWORD PTR [esp+0x4],ebx
  e8:	c7 04 24 50 00 00 00 	mov    DWORD PTR [esp],0x50
  ef:	e8 fc ff ff ff       	call   f0 <test_backtrace+0x53>
}
  f4:	83 c4 14             	add    esp,0x14
  f7:	5b                   	pop    ebx
  f8:	5d                   	pop    ebp
  f9:	c3                   	ret    

000000fa <i386_init>:

void
i386_init(void)
{
  fa:	55                   	push   ebp
  fb:	89 e5                	mov    ebp,esp
  fd:	83 ec 18             	sub    esp,0x18
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
 100:	b8 00 00 00 00       	mov    eax,0x0
 105:	2d 00 00 00 00       	sub    eax,0x0
 10a:	89 44 24 08          	mov    DWORD PTR [esp+0x8],eax
 10e:	c7 44 24 04 00 00 00 	mov    DWORD PTR [esp+0x4],0x0
 115:	00 
 116:	c7 04 24 00 00 00 00 	mov    DWORD PTR [esp],0x0
 11d:	e8 fc ff ff ff       	call   11e <i386_init+0x24>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
 122:	e8 fc ff ff ff       	call   123 <i386_init+0x29>

	cprintf("6828 decimal is %o octal!\n", 6828);
 127:	c7 44 24 04 ac 1a 00 	mov    DWORD PTR [esp+0x4],0x1aac
 12e:	00 
 12f:	c7 04 24 6b 00 00 00 	mov    DWORD PTR [esp],0x6b
 136:	e8 fc ff ff ff       	call   137 <i386_init+0x3d>

    //Exercise 9, Question 10
    //bochs debug
    __asm__ __volatile__("xchg %bx, %bx");
 13b:	66 87 db             	xchg   bx,bx
    int x = 1, y = 3, z = 4;
    cprintf("x %d, y %x, z %d\n", x, y, z);
 13e:	c7 44 24 0c 04 00 00 	mov    DWORD PTR [esp+0xc],0x4
 145:	00 
 146:	c7 44 24 08 03 00 00 	mov    DWORD PTR [esp+0x8],0x3
 14d:	00 
 14e:	c7 44 24 04 01 00 00 	mov    DWORD PTR [esp+0x4],0x1
 155:	00 
 156:	c7 04 24 86 00 00 00 	mov    DWORD PTR [esp],0x86
 15d:	e8 fc ff ff ff       	call   15e <i386_init+0x64>




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
 162:	c7 04 24 05 00 00 00 	mov    DWORD PTR [esp],0x5
 169:	e8 fc ff ff ff       	call   16a <i386_init+0x70>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
 16e:	c7 04 24 00 00 00 00 	mov    DWORD PTR [esp],0x0
 175:	e8 fc ff ff ff       	call   176 <i386_init+0x7c>
 17a:	eb f2                	jmp    16e <i386_init+0x74>
