
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 f0 10 00 	lgdtl  0x10f018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

        # Set the stack pointer
	movl	$(bootstacktop),%esp
f0100033:	bc 00 f0 10 f0       	mov    $0xf010f000,%esp

	# now to C code
	call	i386_init
f0100038:	e8 fd 00 00 00       	call   f010013a <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f0100046:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100049:	89 44 24 08          	mov    %eax,0x8(%esp)
f010004d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100050:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100054:	c7 04 24 00 17 10 f0 	movl   $0xf0101700,(%esp)
f010005b:	e8 4b 09 00 00       	call   f01009ab <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 06 09 00 00       	call   f0100978 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 d1 17 10 f0 	movl   $0xf01017d1,(%esp)
f0100079:	e8 2d 09 00 00       	call   f01009ab <cprintf>
	va_end(ap);
}
f010007e:	c9                   	leave  
f010007f:	c3                   	ret    

f0100080 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100080:	55                   	push   %ebp
f0100081:	89 e5                	mov    %esp,%ebp
f0100083:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f0100086:	83 3d 20 f3 10 f0 00 	cmpl   $0x0,0xf010f320
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 20 f3 10 f0       	mov    %eax,0xf010f320

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 1a 17 10 f0 	movl   $0xf010171a,(%esp)
f01000ac:	e8 fa 08 00 00       	call   f01009ab <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 b5 08 00 00       	call   f0100978 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 d1 17 10 f0 	movl   $0xf01017d1,(%esp)
f01000ca:	e8 dc 08 00 00       	call   f01009ab <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 51 07 00 00       	call   f010082c <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	53                   	push   %ebx
f01000e1:	83 ec 14             	sub    $0x14,%esp
f01000e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000eb:	c7 04 24 32 17 10 f0 	movl   $0xf0101732,(%esp)
f01000f2:	e8 b4 08 00 00       	call   f01009ab <cprintf>
	if (x > 0)
f01000f7:	85 db                	test   %ebx,%ebx
f01000f9:	7e 0d                	jle    f0100108 <test_backtrace+0x2b>
		test_backtrace(x-1);
f01000fb:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01000fe:	89 04 24             	mov    %eax,(%esp)
f0100101:	e8 d7 ff ff ff       	call   f01000dd <test_backtrace>
f0100106:	eb 1c                	jmp    f0100124 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f0100108:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010010f:	00 
f0100110:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100117:	00 
f0100118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010011f:	e8 fc 05 00 00       	call   f0100720 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100128:	c7 04 24 4e 17 10 f0 	movl   $0xf010174e,(%esp)
f010012f:	e8 77 08 00 00       	call   f01009ab <cprintf>
}
f0100134:	83 c4 14             	add    $0x14,%esp
f0100137:	5b                   	pop    %ebx
f0100138:	5d                   	pop    %ebp
f0100139:	c3                   	ret    

f010013a <i386_init>:

void
i386_init(void)
{
f010013a:	55                   	push   %ebp
f010013b:	89 e5                	mov    %esp,%ebp
f010013d:	83 ec 28             	sub    $0x28,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100140:	b8 80 f9 10 f0       	mov    $0xf010f980,%eax
f0100145:	2d 20 f3 10 f0       	sub    $0xf010f320,%eax
f010014a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010014e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100155:	00 
f0100156:	c7 04 24 20 f3 10 f0 	movl   $0xf010f320,(%esp)
f010015d:	e8 14 11 00 00       	call   f0101276 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100162:	e8 8a 02 00 00       	call   f01003f1 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100167:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010016e:	00 
f010016f:	c7 04 24 69 17 10 f0 	movl   $0xf0101769,(%esp)
f0100176:	e8 30 08 00 00       	call   f01009ab <cprintf>

    //Exercise 9, Question 10
    //bochs debug
    __asm__ __volatile__("xchg %bx, %bx");
f010017b:	66 87 db             	xchg   %bx,%bx
    int x = 1, y = 3, z = 4;
    cprintf("x %d, y %x, z %d\n", x, y, z);
f010017e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0100185:	00 
f0100186:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
f010018d:	00 
f010018e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100195:	00 
f0100196:	c7 04 24 84 17 10 f0 	movl   $0xf0101784,(%esp)
f010019d:	e8 09 08 00 00       	call   f01009ab <cprintf>

    unsigned int i = 0x00646c72;
f01001a2:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
    cprintf("H%x Wo%s\n", 57616,&i);
f01001a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01001ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001b0:	c7 44 24 04 10 e1 00 	movl   $0xe110,0x4(%esp)
f01001b7:	00 
f01001b8:	c7 04 24 96 17 10 f0 	movl   $0xf0101796,(%esp)
f01001bf:	e8 e7 07 00 00       	call   f01009ab <cprintf>
    cprintf("x=%d y=%d", 3);
f01001c4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01001cb:	00 
f01001cc:	c7 04 24 a0 17 10 f0 	movl   $0xf01017a0,(%esp)
f01001d3:	e8 d3 07 00 00       	call   f01009ab <cprintf>



	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01001d8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01001df:	e8 f9 fe ff ff       	call   f01000dd <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01001e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01001eb:	e8 3c 06 00 00       	call   f010082c <monitor>
f01001f0:	eb f2                	jmp    f01001e4 <i386_init+0xaa>
	...

f0100200 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100200:	55                   	push   %ebp
f0100201:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100203:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100208:	ec                   	in     (%dx),%al
f0100209:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010020b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100210:	f6 c2 01             	test   $0x1,%dl
f0100213:	74 09                	je     f010021e <serial_proc_data+0x1e>
f0100215:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010021a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010021b:	0f b6 c0             	movzbl %al,%eax
}
f010021e:	5d                   	pop    %ebp
f010021f:	c3                   	ret    

f0100220 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f0100220:	55                   	push   %ebp
f0100221:	89 e5                	mov    %esp,%ebp
f0100223:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100224:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100229:	b8 00 00 00 00       	mov    $0x0,%eax
f010022e:	89 da                	mov    %ebx,%edx
f0100230:	ee                   	out    %al,(%dx)
f0100231:	b2 fb                	mov    $0xfb,%dl
f0100233:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100238:	ee                   	out    %al,(%dx)
f0100239:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010023e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100243:	89 ca                	mov    %ecx,%edx
f0100245:	ee                   	out    %al,(%dx)
f0100246:	b2 f9                	mov    $0xf9,%dl
f0100248:	b8 00 00 00 00       	mov    $0x0,%eax
f010024d:	ee                   	out    %al,(%dx)
f010024e:	b2 fb                	mov    $0xfb,%dl
f0100250:	b8 03 00 00 00       	mov    $0x3,%eax
f0100255:	ee                   	out    %al,(%dx)
f0100256:	b2 fc                	mov    $0xfc,%dl
f0100258:	b8 00 00 00 00       	mov    $0x0,%eax
f010025d:	ee                   	out    %al,(%dx)
f010025e:	b2 f9                	mov    $0xf9,%dl
f0100260:	b8 01 00 00 00       	mov    $0x1,%eax
f0100265:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	b2 fd                	mov    $0xfd,%dl
f0100268:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100269:	3c ff                	cmp    $0xff,%al
f010026b:	0f 95 c0             	setne  %al
f010026e:	0f b6 c0             	movzbl %al,%eax
f0100271:	a3 44 f3 10 f0       	mov    %eax,0xf010f344
f0100276:	89 da                	mov    %ebx,%edx
f0100278:	ec                   	in     (%dx),%al
f0100279:	89 ca                	mov    %ecx,%edx
f010027b:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010027c:	5b                   	pop    %ebx
f010027d:	5d                   	pop    %ebp
f010027e:	c3                   	ret    

f010027f <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	83 ec 0c             	sub    $0xc,%esp
f0100285:	89 1c 24             	mov    %ebx,(%esp)
f0100288:	89 74 24 04          	mov    %esi,0x4(%esp)
f010028c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100290:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100295:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100298:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010029d:	0f b7 00             	movzwl (%eax),%eax
f01002a0:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01002a4:	74 11                	je     f01002b7 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01002a6:	c7 05 48 f3 10 f0 b4 	movl   $0x3b4,0xf010f348
f01002ad:	03 00 00 
f01002b0:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01002b5:	eb 16                	jmp    f01002cd <cga_init+0x4e>
	} else {
		*cp = was;
f01002b7:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01002be:	c7 05 48 f3 10 f0 d4 	movl   $0x3d4,0xf010f348
f01002c5:	03 00 00 
f01002c8:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01002cd:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f01002d3:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01002da:	89 ca                	mov    %ecx,%edx
f01002dc:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01002dd:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e0:	89 ca                	mov    %ecx,%edx
f01002e2:	ec                   	in     (%dx),%al
f01002e3:	0f b6 f8             	movzbl %al,%edi
f01002e6:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01002ee:	89 da                	mov    %ebx,%edx
f01002f0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f1:	89 ca                	mov    %ecx,%edx
f01002f3:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01002f4:	89 35 4c f3 10 f0    	mov    %esi,0xf010f34c
	crt_pos = pos;
f01002fa:	0f b6 c8             	movzbl %al,%ecx
f01002fd:	09 cf                	or     %ecx,%edi
f01002ff:	66 89 3d 50 f3 10 f0 	mov    %di,0xf010f350
}
f0100306:	8b 1c 24             	mov    (%esp),%ebx
f0100309:	8b 74 24 04          	mov    0x4(%esp),%esi
f010030d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0100311:	89 ec                	mov    %ebp,%esp
f0100313:	5d                   	pop    %ebp
f0100314:	c3                   	ret    

f0100315 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f0100315:	55                   	push   %ebp
f0100316:	89 e5                	mov    %esp,%ebp
}
f0100318:	5d                   	pop    %ebp
f0100319:	c3                   	ret    

f010031a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f010031a:	55                   	push   %ebp
f010031b:	89 e5                	mov    %esp,%ebp
f010031d:	57                   	push   %edi
f010031e:	56                   	push   %esi
f010031f:	53                   	push   %ebx
f0100320:	83 ec 0c             	sub    $0xc,%esp
f0100323:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100326:	bb 64 f5 10 f0       	mov    $0xf010f564,%ebx
f010032b:	bf 60 f3 10 f0       	mov    $0xf010f360,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100330:	eb 1e                	jmp    f0100350 <cons_intr+0x36>
		if (c == 0)
f0100332:	85 c0                	test   %eax,%eax
f0100334:	74 1a                	je     f0100350 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100336:	8b 13                	mov    (%ebx),%edx
f0100338:	88 04 17             	mov    %al,(%edi,%edx,1)
f010033b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010033e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100343:	0f 94 c2             	sete   %dl
f0100346:	0f b6 d2             	movzbl %dl,%edx
f0100349:	83 ea 01             	sub    $0x1,%edx
f010034c:	21 d0                	and    %edx,%eax
f010034e:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100350:	ff d6                	call   *%esi
f0100352:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100355:	75 db                	jne    f0100332 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100357:	83 c4 0c             	add    $0xc,%esp
f010035a:	5b                   	pop    %ebx
f010035b:	5e                   	pop    %esi
f010035c:	5f                   	pop    %edi
f010035d:	5d                   	pop    %ebp
f010035e:	c3                   	ret    

f010035f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010035f:	55                   	push   %ebp
f0100360:	89 e5                	mov    %esp,%ebp
f0100362:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100365:	c7 04 24 18 04 10 f0 	movl   $0xf0100418,(%esp)
f010036c:	e8 a9 ff ff ff       	call   f010031a <cons_intr>
}
f0100371:	c9                   	leave  
f0100372:	c3                   	ret    

f0100373 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100373:	55                   	push   %ebp
f0100374:	89 e5                	mov    %esp,%ebp
f0100376:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100379:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f0100380:	74 0c                	je     f010038e <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f0100382:	c7 04 24 00 02 10 f0 	movl   $0xf0100200,(%esp)
f0100389:	e8 8c ff ff ff       	call   f010031a <cons_intr>
}
f010038e:	c9                   	leave  
f010038f:	c3                   	ret    

f0100390 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100390:	55                   	push   %ebp
f0100391:	89 e5                	mov    %esp,%ebp
f0100393:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100396:	e8 d8 ff ff ff       	call   f0100373 <serial_intr>
	kbd_intr();
f010039b:	e8 bf ff ff ff       	call   f010035f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01003a0:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
f01003a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01003ab:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f01003b1:	74 21                	je     f01003d4 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f01003b3:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f01003ba:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01003bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01003c3:	0f 94 c1             	sete   %cl
f01003c6:	0f b6 c9             	movzbl %cl,%ecx
f01003c9:	83 e9 01             	sub    $0x1,%ecx
f01003cc:	21 ca                	and    %ecx,%edx
f01003ce:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f01003d4:	c9                   	leave  
f01003d5:	c3                   	ret    

f01003d6 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01003d6:	55                   	push   %ebp
f01003d7:	89 e5                	mov    %esp,%ebp
f01003d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01003dc:	e8 af ff ff ff       	call   f0100390 <cons_getc>
f01003e1:	85 c0                	test   %eax,%eax
f01003e3:	74 f7                	je     f01003dc <getchar+0x6>
		/* do nothing */;
	return c;
}
f01003e5:	c9                   	leave  
f01003e6:	c3                   	ret    

f01003e7 <iscons>:

int
iscons(int fdnum)
{
f01003e7:	55                   	push   %ebp
f01003e8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01003ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01003ef:	5d                   	pop    %ebp
f01003f0:	c3                   	ret    

f01003f1 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01003f1:	55                   	push   %ebp
f01003f2:	89 e5                	mov    %esp,%ebp
f01003f4:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f01003f7:	e8 83 fe ff ff       	call   f010027f <cga_init>
	kbd_init();
	serial_init();
f01003fc:	e8 1f fe ff ff       	call   f0100220 <serial_init>

	if (!serial_exists)
f0100401:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f0100408:	75 0c                	jne    f0100416 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f010040a:	c7 04 24 aa 17 10 f0 	movl   $0xf01017aa,(%esp)
f0100411:	e8 95 05 00 00       	call   f01009ab <cprintf>
}
f0100416:	c9                   	leave  
f0100417:	c3                   	ret    

f0100418 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100418:	55                   	push   %ebp
f0100419:	89 e5                	mov    %esp,%ebp
f010041b:	53                   	push   %ebx
f010041c:	83 ec 14             	sub    $0x14,%esp
f010041f:	ba 64 00 00 00       	mov    $0x64,%edx
f0100424:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100425:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010042a:	a8 01                	test   $0x1,%al
f010042c:	0f 84 d9 00 00 00    	je     f010050b <kbd_proc_data+0xf3>
f0100432:	b2 60                	mov    $0x60,%dl
f0100434:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100435:	3c e0                	cmp    $0xe0,%al
f0100437:	75 11                	jne    f010044a <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100439:	83 0d 40 f3 10 f0 40 	orl    $0x40,0xf010f340
f0100440:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100445:	e9 c1 00 00 00       	jmp    f010050b <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010044a:	84 c0                	test   %al,%al
f010044c:	79 32                	jns    f0100480 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010044e:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100454:	f6 c2 40             	test   $0x40,%dl
f0100457:	75 03                	jne    f010045c <kbd_proc_data+0x44>
f0100459:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010045c:	0f b6 c0             	movzbl %al,%eax
f010045f:	0f b6 80 e0 17 10 f0 	movzbl -0xfefe820(%eax),%eax
f0100466:	83 c8 40             	or     $0x40,%eax
f0100469:	0f b6 c0             	movzbl %al,%eax
f010046c:	f7 d0                	not    %eax
f010046e:	21 c2                	and    %eax,%edx
f0100470:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
f0100476:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010047b:	e9 8b 00 00 00       	jmp    f010050b <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100480:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100486:	f6 c2 40             	test   $0x40,%dl
f0100489:	74 0c                	je     f0100497 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010048b:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010048e:	83 e2 bf             	and    $0xffffffbf,%edx
f0100491:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
	}

	shift |= shiftcode[data];
f0100497:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010049a:	0f b6 90 e0 17 10 f0 	movzbl -0xfefe820(%eax),%edx
f01004a1:	0b 15 40 f3 10 f0    	or     0xf010f340,%edx
f01004a7:	0f b6 88 e0 18 10 f0 	movzbl -0xfefe720(%eax),%ecx
f01004ae:	31 ca                	xor    %ecx,%edx
f01004b0:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340

	c = charcode[shift & (CTL | SHIFT)][data];
f01004b6:	89 d1                	mov    %edx,%ecx
f01004b8:	83 e1 03             	and    $0x3,%ecx
f01004bb:	8b 0c 8d e0 19 10 f0 	mov    -0xfefe620(,%ecx,4),%ecx
f01004c2:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01004c6:	f6 c2 08             	test   $0x8,%dl
f01004c9:	74 1a                	je     f01004e5 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f01004cb:	89 d9                	mov    %ebx,%ecx
f01004cd:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01004d0:	83 f8 19             	cmp    $0x19,%eax
f01004d3:	77 05                	ja     f01004da <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f01004d5:	83 eb 20             	sub    $0x20,%ebx
f01004d8:	eb 0b                	jmp    f01004e5 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f01004da:	83 e9 41             	sub    $0x41,%ecx
f01004dd:	83 f9 19             	cmp    $0x19,%ecx
f01004e0:	77 03                	ja     f01004e5 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f01004e2:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004e5:	f7 d2                	not    %edx
f01004e7:	f6 c2 06             	test   $0x6,%dl
f01004ea:	75 1f                	jne    f010050b <kbd_proc_data+0xf3>
f01004ec:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004f2:	75 17                	jne    f010050b <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f01004f4:	c7 04 24 c7 17 10 f0 	movl   $0xf01017c7,(%esp)
f01004fb:	e8 ab 04 00 00       	call   f01009ab <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100500:	ba 92 00 00 00       	mov    $0x92,%edx
f0100505:	b8 03 00 00 00       	mov    $0x3,%eax
f010050a:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010050b:	89 d8                	mov    %ebx,%eax
f010050d:	83 c4 14             	add    $0x14,%esp
f0100510:	5b                   	pop    %ebx
f0100511:	5d                   	pop    %ebp
f0100512:	c3                   	ret    

f0100513 <cga_putc>:



void
cga_putc(int c)
{
f0100513:	55                   	push   %ebp
f0100514:	89 e5                	mov    %esp,%ebp
f0100516:	56                   	push   %esi
f0100517:	53                   	push   %ebx
f0100518:	83 ec 10             	sub    $0x10,%esp
f010051b:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010051e:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f0100523:	75 03                	jne    f0100528 <cga_putc+0x15>
		c |= 0x0700;
f0100525:	80 cc 07             	or     $0x7,%ah

	switch (c & 0xff) {
f0100528:	0f b6 d0             	movzbl %al,%edx
f010052b:	83 fa 09             	cmp    $0x9,%edx
f010052e:	0f 84 89 00 00 00    	je     f01005bd <cga_putc+0xaa>
f0100534:	83 fa 09             	cmp    $0x9,%edx
f0100537:	7f 11                	jg     f010054a <cga_putc+0x37>
f0100539:	83 fa 08             	cmp    $0x8,%edx
f010053c:	0f 85 b9 00 00 00    	jne    f01005fb <cga_putc+0xe8>
f0100542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100548:	eb 18                	jmp    f0100562 <cga_putc+0x4f>
f010054a:	83 fa 0a             	cmp    $0xa,%edx
f010054d:	8d 76 00             	lea    0x0(%esi),%esi
f0100550:	74 41                	je     f0100593 <cga_putc+0x80>
f0100552:	83 fa 0d             	cmp    $0xd,%edx
f0100555:	8d 76 00             	lea    0x0(%esi),%esi
f0100558:	0f 85 9d 00 00 00    	jne    f01005fb <cga_putc+0xe8>
f010055e:	66 90                	xchg   %ax,%ax
f0100560:	eb 39                	jmp    f010059b <cga_putc+0x88>
	case '\b':
		if (crt_pos > 0) {
f0100562:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f0100569:	66 85 d2             	test   %dx,%dx
f010056c:	0f 84 f4 00 00 00    	je     f0100666 <cga_putc+0x153>
			crt_pos--;
f0100572:	83 ea 01             	sub    $0x1,%edx
f0100575:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010057c:	0f b7 d2             	movzwl %dx,%edx
f010057f:	b0 00                	mov    $0x0,%al
f0100581:	83 c8 20             	or     $0x20,%eax
f0100584:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f010058a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010058e:	e9 86 00 00 00       	jmp    f0100619 <cga_putc+0x106>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100593:	66 83 05 50 f3 10 f0 	addw   $0x50,0xf010f350
f010059a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010059b:	0f b7 05 50 f3 10 f0 	movzwl 0xf010f350,%eax
f01005a2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01005a8:	c1 e8 10             	shr    $0x10,%eax
f01005ab:	66 c1 e8 06          	shr    $0x6,%ax
f01005af:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01005b2:	c1 e0 04             	shl    $0x4,%eax
f01005b5:	66 a3 50 f3 10 f0    	mov    %ax,0xf010f350
		break;
f01005bb:	eb 5c                	jmp    f0100619 <cga_putc+0x106>
	case '\t':
		cons_putc(' ');
f01005bd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005c4:	e8 d4 00 00 00       	call   f010069d <cons_putc>
		cons_putc(' ');
f01005c9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005d0:	e8 c8 00 00 00       	call   f010069d <cons_putc>
		cons_putc(' ');
f01005d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005dc:	e8 bc 00 00 00       	call   f010069d <cons_putc>
		cons_putc(' ');
f01005e1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005e8:	e8 b0 00 00 00       	call   f010069d <cons_putc>
		cons_putc(' ');
f01005ed:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005f4:	e8 a4 00 00 00       	call   f010069d <cons_putc>
		break;
f01005f9:	eb 1e                	jmp    f0100619 <cga_putc+0x106>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005fb:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f0100602:	0f b7 da             	movzwl %dx,%ebx
f0100605:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f010060b:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010060f:	83 c2 01             	add    $0x1,%edx
f0100612:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100619:	66 81 3d 50 f3 10 f0 	cmpw   $0x7cf,0xf010f350
f0100620:	cf 07 
f0100622:	76 42                	jbe    f0100666 <cga_putc+0x153>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100624:	a1 4c f3 10 f0       	mov    0xf010f34c,%eax
f0100629:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100630:	00 
f0100631:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100637:	89 54 24 04          	mov    %edx,0x4(%esp)
f010063b:	89 04 24             	mov    %eax,(%esp)
f010063e:	e8 58 0c 00 00       	call   f010129b <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100643:	8b 15 4c f3 10 f0    	mov    0xf010f34c,%edx
f0100649:	b8 80 07 00 00       	mov    $0x780,%eax
f010064e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100654:	83 c0 01             	add    $0x1,%eax
f0100657:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010065c:	75 f0                	jne    f010064e <cga_putc+0x13b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010065e:	66 83 2d 50 f3 10 f0 	subw   $0x50,0xf010f350
f0100665:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100666:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010066c:	89 cb                	mov    %ecx,%ebx
f010066e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100676:	0f b7 35 50 f3 10 f0 	movzwl 0xf010f350,%esi
f010067d:	83 c1 01             	add    $0x1,%ecx
f0100680:	89 f0                	mov    %esi,%eax
f0100682:	66 c1 e8 08          	shr    $0x8,%ax
f0100686:	89 ca                	mov    %ecx,%edx
f0100688:	ee                   	out    %al,(%dx)
f0100689:	b8 0f 00 00 00       	mov    $0xf,%eax
f010068e:	89 da                	mov    %ebx,%edx
f0100690:	ee                   	out    %al,(%dx)
f0100691:	89 f0                	mov    %esi,%eax
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100696:	83 c4 10             	add    $0x10,%esp
f0100699:	5b                   	pop    %ebx
f010069a:	5e                   	pop    %esi
f010069b:	5d                   	pop    %ebp
f010069c:	c3                   	ret    

f010069d <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f010069d:	55                   	push   %ebp
f010069e:	89 e5                	mov    %esp,%ebp
f01006a0:	57                   	push   %edi
f01006a1:	56                   	push   %esi
f01006a2:	53                   	push   %ebx
f01006a3:	83 ec 1c             	sub    $0x1c,%esp
f01006a6:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a9:	ba 79 03 00 00       	mov    $0x379,%edx
f01006ae:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01006af:	84 c0                	test   %al,%al
f01006b1:	78 27                	js     f01006da <cons_putc+0x3d>
f01006b3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006b8:	b9 84 00 00 00       	mov    $0x84,%ecx
f01006bd:	be 79 03 00 00       	mov    $0x379,%esi
f01006c2:	89 ca                	mov    %ecx,%edx
f01006c4:	ec                   	in     (%dx),%al
f01006c5:	ec                   	in     (%dx),%al
f01006c6:	ec                   	in     (%dx),%al
f01006c7:	ec                   	in     (%dx),%al
f01006c8:	89 f2                	mov    %esi,%edx
f01006ca:	ec                   	in     (%dx),%al
f01006cb:	84 c0                	test   %al,%al
f01006cd:	78 0b                	js     f01006da <cons_putc+0x3d>
f01006cf:	83 c3 01             	add    $0x1,%ebx
f01006d2:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01006d8:	75 e8                	jne    f01006c2 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006da:	ba 78 03 00 00       	mov    $0x378,%edx
f01006df:	89 f8                	mov    %edi,%eax
f01006e1:	ee                   	out    %al,(%dx)
f01006e2:	b2 7a                	mov    $0x7a,%dl
f01006e4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	b8 08 00 00 00       	mov    $0x8,%eax
f01006ef:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f01006f0:	89 3c 24             	mov    %edi,(%esp)
f01006f3:	e8 1b fe ff ff       	call   f0100513 <cga_putc>
}
f01006f8:	83 c4 1c             	add    $0x1c,%esp
f01006fb:	5b                   	pop    %ebx
f01006fc:	5e                   	pop    %esi
f01006fd:	5f                   	pop    %edi
f01006fe:	5d                   	pop    %ebp
f01006ff:	c3                   	ret    

f0100700 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100700:	55                   	push   %ebp
f0100701:	89 e5                	mov    %esp,%ebp
f0100703:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f0100706:	8b 45 08             	mov    0x8(%ebp),%eax
f0100709:	89 04 24             	mov    %eax,(%esp)
f010070c:	e8 8c ff ff ff       	call   f010069d <cons_putc>
}
f0100711:	c9                   	leave  
f0100712:	c3                   	ret    
	...

f0100720 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100720:	55                   	push   %ebp
f0100721:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100723:	b8 00 00 00 00       	mov    $0x0,%eax
f0100728:	5d                   	pop    %ebp
f0100729:	c3                   	ret    

f010072a <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f010072a:	55                   	push   %ebp
f010072b:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010072d:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100730:	5d                   	pop    %ebp
f0100731:	c3                   	ret    

f0100732 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100732:	55                   	push   %ebp
f0100733:	89 e5                	mov    %esp,%ebp
f0100735:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100738:	c7 04 24 f0 19 10 f0 	movl   $0xf01019f0,(%esp)
f010073f:	e8 67 02 00 00       	call   f01009ab <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100744:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010074b:	00 
f010074c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100753:	f0 
f0100754:	c7 04 24 7c 1a 10 f0 	movl   $0xf0101a7c,(%esp)
f010075b:	e8 4b 02 00 00       	call   f01009ab <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100760:	c7 44 24 08 f5 16 10 	movl   $0x1016f5,0x8(%esp)
f0100767:	00 
f0100768:	c7 44 24 04 f5 16 10 	movl   $0xf01016f5,0x4(%esp)
f010076f:	f0 
f0100770:	c7 04 24 a0 1a 10 f0 	movl   $0xf0101aa0,(%esp)
f0100777:	e8 2f 02 00 00       	call   f01009ab <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010077c:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f0100783:	00 
f0100784:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f010078b:	f0 
f010078c:	c7 04 24 c4 1a 10 f0 	movl   $0xf0101ac4,(%esp)
f0100793:	e8 13 02 00 00       	call   f01009ab <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100798:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f010079f:	00 
f01007a0:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f01007a7:	f0 
f01007a8:	c7 04 24 e8 1a 10 f0 	movl   $0xf0101ae8,(%esp)
f01007af:	e8 f7 01 00 00       	call   f01009ab <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007b4:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f01007b9:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007be:	89 c2                	mov    %eax,%edx
f01007c0:	c1 fa 1f             	sar    $0x1f,%edx
f01007c3:	c1 ea 16             	shr    $0x16,%edx
f01007c6:	8d 04 02             	lea    (%edx,%eax,1),%eax
f01007c9:	c1 f8 0a             	sar    $0xa,%eax
f01007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007d0:	c7 04 24 0c 1b 10 f0 	movl   $0xf0101b0c,(%esp)
f01007d7:	e8 cf 01 00 00       	call   f01009ab <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f01007dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e1:	c9                   	leave  
f01007e2:	c3                   	ret    

f01007e3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007e3:	55                   	push   %ebp
f01007e4:	89 e5                	mov    %esp,%ebp
f01007e6:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007e9:	a1 b0 1b 10 f0       	mov    0xf0101bb0,%eax
f01007ee:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007f2:	a1 ac 1b 10 f0       	mov    0xf0101bac,%eax
f01007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007fb:	c7 04 24 09 1a 10 f0 	movl   $0xf0101a09,(%esp)
f0100802:	e8 a4 01 00 00       	call   f01009ab <cprintf>
f0100807:	a1 bc 1b 10 f0       	mov    0xf0101bbc,%eax
f010080c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100810:	a1 b8 1b 10 f0       	mov    0xf0101bb8,%eax
f0100815:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100819:	c7 04 24 09 1a 10 f0 	movl   $0xf0101a09,(%esp)
f0100820:	e8 86 01 00 00       	call   f01009ab <cprintf>
	return 0;
}
f0100825:	b8 00 00 00 00       	mov    $0x0,%eax
f010082a:	c9                   	leave  
f010082b:	c3                   	ret    

f010082c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010082c:	55                   	push   %ebp
f010082d:	89 e5                	mov    %esp,%ebp
f010082f:	57                   	push   %edi
f0100830:	56                   	push   %esi
f0100831:	53                   	push   %ebx
f0100832:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100835:	c7 04 24 38 1b 10 f0 	movl   $0xf0101b38,(%esp)
f010083c:	e8 6a 01 00 00       	call   f01009ab <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100841:	c7 04 24 5c 1b 10 f0 	movl   $0xf0101b5c,(%esp)
f0100848:	e8 5e 01 00 00       	call   f01009ab <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010084d:	bf ac 1b 10 f0       	mov    $0xf0101bac,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f0100852:	c7 04 24 12 1a 10 f0 	movl   $0xf0101a12,(%esp)
f0100859:	e8 a2 07 00 00       	call   f0101000 <readline>
f010085e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100860:	85 c0                	test   %eax,%eax
f0100862:	74 ee                	je     f0100852 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100864:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010086b:	be 00 00 00 00       	mov    $0x0,%esi
f0100870:	eb 06                	jmp    f0100878 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100872:	c6 03 00             	movb   $0x0,(%ebx)
f0100875:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100878:	0f b6 03             	movzbl (%ebx),%eax
f010087b:	84 c0                	test   %al,%al
f010087d:	74 6c                	je     f01008eb <monitor+0xbf>
f010087f:	0f be c0             	movsbl %al,%eax
f0100882:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100886:	c7 04 24 16 1a 10 f0 	movl   $0xf0101a16,(%esp)
f010088d:	e8 8c 09 00 00       	call   f010121e <strchr>
f0100892:	85 c0                	test   %eax,%eax
f0100894:	75 dc                	jne    f0100872 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100896:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100899:	74 50                	je     f01008eb <monitor+0xbf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010089b:	83 fe 0f             	cmp    $0xf,%esi
f010089e:	66 90                	xchg   %ax,%ax
f01008a0:	75 16                	jne    f01008b8 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008a2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008a9:	00 
f01008aa:	c7 04 24 1b 1a 10 f0 	movl   $0xf0101a1b,(%esp)
f01008b1:	e8 f5 00 00 00       	call   f01009ab <cprintf>
f01008b6:	eb 9a                	jmp    f0100852 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f01008b8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008bc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008bf:	0f b6 03             	movzbl (%ebx),%eax
f01008c2:	84 c0                	test   %al,%al
f01008c4:	75 0c                	jne    f01008d2 <monitor+0xa6>
f01008c6:	eb b0                	jmp    f0100878 <monitor+0x4c>
			buf++;
f01008c8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008cb:	0f b6 03             	movzbl (%ebx),%eax
f01008ce:	84 c0                	test   %al,%al
f01008d0:	74 a6                	je     f0100878 <monitor+0x4c>
f01008d2:	0f be c0             	movsbl %al,%eax
f01008d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d9:	c7 04 24 16 1a 10 f0 	movl   $0xf0101a16,(%esp)
f01008e0:	e8 39 09 00 00       	call   f010121e <strchr>
f01008e5:	85 c0                	test   %eax,%eax
f01008e7:	74 df                	je     f01008c8 <monitor+0x9c>
f01008e9:	eb 8d                	jmp    f0100878 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f01008eb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008f2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008f3:	85 f6                	test   %esi,%esi
f01008f5:	0f 84 57 ff ff ff    	je     f0100852 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008fb:	8b 07                	mov    (%edi),%eax
f01008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100901:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100904:	89 04 24             	mov    %eax,(%esp)
f0100907:	e8 9d 08 00 00       	call   f01011a9 <strcmp>
f010090c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100911:	85 c0                	test   %eax,%eax
f0100913:	74 1d                	je     f0100932 <monitor+0x106>
f0100915:	a1 b8 1b 10 f0       	mov    0xf0101bb8,%eax
f010091a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100921:	89 04 24             	mov    %eax,(%esp)
f0100924:	e8 80 08 00 00       	call   f01011a9 <strcmp>
f0100929:	85 c0                	test   %eax,%eax
f010092b:	75 28                	jne    f0100955 <monitor+0x129>
f010092d:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f0100932:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100935:	8b 45 08             	mov    0x8(%ebp),%eax
f0100938:	89 44 24 08          	mov    %eax,0x8(%esp)
f010093c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010093f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100943:	89 34 24             	mov    %esi,(%esp)
f0100946:	ff 92 b4 1b 10 f0    	call   *-0xfefe44c(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010094c:	85 c0                	test   %eax,%eax
f010094e:	78 1d                	js     f010096d <monitor+0x141>
f0100950:	e9 fd fe ff ff       	jmp    f0100852 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100955:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100958:	89 44 24 04          	mov    %eax,0x4(%esp)
f010095c:	c7 04 24 38 1a 10 f0 	movl   $0xf0101a38,(%esp)
f0100963:	e8 43 00 00 00       	call   f01009ab <cprintf>
f0100968:	e9 e5 fe ff ff       	jmp    f0100852 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010096d:	83 c4 5c             	add    $0x5c,%esp
f0100970:	5b                   	pop    %ebx
f0100971:	5e                   	pop    %esi
f0100972:	5f                   	pop    %edi
f0100973:	5d                   	pop    %ebp
f0100974:	c3                   	ret    
f0100975:	00 00                	add    %al,(%eax)
	...

f0100978 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100978:	55                   	push   %ebp
f0100979:	89 e5                	mov    %esp,%ebp
f010097b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010097e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100985:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100988:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010098c:	8b 45 08             	mov    0x8(%ebp),%eax
f010098f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100993:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100996:	89 44 24 04          	mov    %eax,0x4(%esp)
f010099a:	c7 04 24 c5 09 10 f0 	movl   $0xf01009c5,(%esp)
f01009a1:	e8 8a 01 00 00       	call   f0100b30 <vprintfmt>
	return cnt;
}
f01009a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009a9:	c9                   	leave  
f01009aa:	c3                   	ret    

f01009ab <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009ab:	55                   	push   %ebp
f01009ac:	89 e5                	mov    %esp,%ebp
f01009ae:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f01009b1:	8d 45 0c             	lea    0xc(%ebp),%eax
f01009b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01009bb:	89 04 24             	mov    %eax,(%esp)
f01009be:	e8 b5 ff ff ff       	call   f0100978 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009c3:	c9                   	leave  
f01009c4:	c3                   	ret    

f01009c5 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009c5:	55                   	push   %ebp
f01009c6:	89 e5                	mov    %esp,%ebp
f01009c8:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01009cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01009ce:	89 04 24             	mov    %eax,(%esp)
f01009d1:	e8 2a fd ff ff       	call   f0100700 <cputchar>
	*cnt++;
}
f01009d6:	c9                   	leave  
f01009d7:	c3                   	ret    
	...

f01009e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01009e0:	55                   	push   %ebp
f01009e1:	89 e5                	mov    %esp,%ebp
f01009e3:	57                   	push   %edi
f01009e4:	56                   	push   %esi
f01009e5:	53                   	push   %ebx
f01009e6:	83 ec 4c             	sub    $0x4c,%esp
f01009e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01009ec:	89 d6                	mov    %edx,%esi
f01009ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01009f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01009f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009fa:	8b 45 10             	mov    0x10(%ebp),%eax
f01009fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100a00:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100a03:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100a06:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100a0b:	39 d1                	cmp    %edx,%ecx
f0100a0d:	72 15                	jb     f0100a24 <printnum+0x44>
f0100a0f:	77 07                	ja     f0100a18 <printnum+0x38>
f0100a11:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a14:	39 d0                	cmp    %edx,%eax
f0100a16:	76 0c                	jbe    f0100a24 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a18:	83 eb 01             	sub    $0x1,%ebx
f0100a1b:	85 db                	test   %ebx,%ebx
f0100a1d:	8d 76 00             	lea    0x0(%esi),%esi
f0100a20:	7f 61                	jg     f0100a83 <printnum+0xa3>
f0100a22:	eb 70                	jmp    f0100a94 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100a24:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100a28:	83 eb 01             	sub    $0x1,%ebx
f0100a2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a33:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0100a37:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0100a3b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100a3e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100a41:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100a44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100a48:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a4f:	00 
f0100a50:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a53:	89 04 24             	mov    %eax,(%esp)
f0100a56:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100a59:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a5d:	e8 2e 0a 00 00       	call   f0101490 <__udivdi3>
f0100a62:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100a65:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100a68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a6c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a70:	89 04 24             	mov    %eax,(%esp)
f0100a73:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a77:	89 f2                	mov    %esi,%edx
f0100a79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a7c:	e8 5f ff ff ff       	call   f01009e0 <printnum>
f0100a81:	eb 11                	jmp    f0100a94 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100a83:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a87:	89 3c 24             	mov    %edi,(%esp)
f0100a8a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a8d:	83 eb 01             	sub    $0x1,%ebx
f0100a90:	85 db                	test   %ebx,%ebx
f0100a92:	7f ef                	jg     f0100a83 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100a94:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a98:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100a9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a9f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100aa3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100aaa:	00 
f0100aab:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100aae:	89 14 24             	mov    %edx,(%esp)
f0100ab1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ab4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100ab8:	e8 03 0b 00 00       	call   f01015c0 <__umoddi3>
f0100abd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ac1:	0f be 80 c4 1b 10 f0 	movsbl -0xfefe43c(%eax),%eax
f0100ac8:	89 04 24             	mov    %eax,(%esp)
f0100acb:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100ace:	83 c4 4c             	add    $0x4c,%esp
f0100ad1:	5b                   	pop    %ebx
f0100ad2:	5e                   	pop    %esi
f0100ad3:	5f                   	pop    %edi
f0100ad4:	5d                   	pop    %ebp
f0100ad5:	c3                   	ret    

f0100ad6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100ad6:	55                   	push   %ebp
f0100ad7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100ad9:	83 fa 01             	cmp    $0x1,%edx
f0100adc:	7e 0f                	jle    f0100aed <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f0100ade:	8b 10                	mov    (%eax),%edx
f0100ae0:	83 c2 08             	add    $0x8,%edx
f0100ae3:	89 10                	mov    %edx,(%eax)
f0100ae5:	8b 42 f8             	mov    -0x8(%edx),%eax
f0100ae8:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100aeb:	eb 24                	jmp    f0100b11 <getuint+0x3b>
	else if (lflag)
f0100aed:	85 d2                	test   %edx,%edx
f0100aef:	74 11                	je     f0100b02 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0100af1:	8b 10                	mov    (%eax),%edx
f0100af3:	83 c2 04             	add    $0x4,%edx
f0100af6:	89 10                	mov    %edx,(%eax)
f0100af8:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100afb:	ba 00 00 00 00       	mov    $0x0,%edx
f0100b00:	eb 0f                	jmp    f0100b11 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0100b02:	8b 10                	mov    (%eax),%edx
f0100b04:	83 c2 04             	add    $0x4,%edx
f0100b07:	89 10                	mov    %edx,(%eax)
f0100b09:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100b0c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100b11:	5d                   	pop    %ebp
f0100b12:	c3                   	ret    

f0100b13 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100b13:	55                   	push   %ebp
f0100b14:	89 e5                	mov    %esp,%ebp
f0100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100b19:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100b1d:	8b 10                	mov    (%eax),%edx
f0100b1f:	3b 50 04             	cmp    0x4(%eax),%edx
f0100b22:	73 0a                	jae    f0100b2e <sprintputch+0x1b>
		*b->buf++ = ch;
f0100b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100b27:	88 0a                	mov    %cl,(%edx)
f0100b29:	83 c2 01             	add    $0x1,%edx
f0100b2c:	89 10                	mov    %edx,(%eax)
}
f0100b2e:	5d                   	pop    %ebp
f0100b2f:	c3                   	ret    

f0100b30 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100b30:	55                   	push   %ebp
f0100b31:	89 e5                	mov    %esp,%ebp
f0100b33:	57                   	push   %edi
f0100b34:	56                   	push   %esi
f0100b35:	53                   	push   %ebx
f0100b36:	83 ec 5c             	sub    $0x5c,%esp
f0100b39:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100b3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100b42:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0100b49:	eb 11                	jmp    f0100b5c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100b4b:	85 c0                	test   %eax,%eax
f0100b4d:	0f 84 f4 03 00 00    	je     f0100f47 <vprintfmt+0x417>
				return;
			putch(ch, putdat);
f0100b53:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b57:	89 04 24             	mov    %eax,(%esp)
f0100b5a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100b5c:	0f b6 03             	movzbl (%ebx),%eax
f0100b5f:	83 c3 01             	add    $0x1,%ebx
f0100b62:	83 f8 25             	cmp    $0x25,%eax
f0100b65:	75 e4                	jne    f0100b4b <vprintfmt+0x1b>
f0100b67:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100b6b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100b72:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100b79:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100b80:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b85:	eb 06                	jmp    f0100b8d <vprintfmt+0x5d>
f0100b87:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100b8b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b8d:	0f b6 13             	movzbl (%ebx),%edx
f0100b90:	0f b6 c2             	movzbl %dl,%eax
f0100b93:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100b96:	8d 43 01             	lea    0x1(%ebx),%eax
f0100b99:	83 ea 23             	sub    $0x23,%edx
f0100b9c:	80 fa 55             	cmp    $0x55,%dl
f0100b9f:	0f 87 85 03 00 00    	ja     f0100f2a <vprintfmt+0x3fa>
f0100ba5:	0f b6 d2             	movzbl %dl,%edx
f0100ba8:	ff 24 95 54 1c 10 f0 	jmp    *-0xfefe3ac(,%edx,4)
f0100baf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100bb3:	eb d6                	jmp    f0100b8b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100bb5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100bb8:	83 ea 30             	sub    $0x30,%edx
f0100bbb:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
f0100bbe:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100bc1:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100bc4:	83 fb 09             	cmp    $0x9,%ebx
f0100bc7:	77 4d                	ja     f0100c16 <vprintfmt+0xe6>
f0100bc9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bcc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100bcf:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0100bd2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100bd5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0100bd9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100bdc:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100bdf:	83 fb 09             	cmp    $0x9,%ebx
f0100be2:	76 eb                	jbe    f0100bcf <vprintfmt+0x9f>
f0100be4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100be7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100bea:	eb 2a                	jmp    f0100c16 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100bec:	8b 55 14             	mov    0x14(%ebp),%edx
f0100bef:	83 c2 04             	add    $0x4,%edx
f0100bf2:	89 55 14             	mov    %edx,0x14(%ebp)
f0100bf5:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100bf8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
f0100bfb:	eb 19                	jmp    f0100c16 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
f0100bfd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c00:	c1 fa 1f             	sar    $0x1f,%edx
f0100c03:	f7 d2                	not    %edx
f0100c05:	21 55 e4             	and    %edx,-0x1c(%ebp)
f0100c08:	eb 81                	jmp    f0100b8b <vprintfmt+0x5b>
f0100c0a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0100c11:	e9 75 ff ff ff       	jmp    f0100b8b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0100c16:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100c1a:	0f 89 6b ff ff ff    	jns    f0100b8b <vprintfmt+0x5b>
f0100c20:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100c23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c26:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0100c29:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c2c:	e9 5a ff ff ff       	jmp    f0100b8b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100c31:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0100c34:	e9 52 ff ff ff       	jmp    f0100b8b <vprintfmt+0x5b>
f0100c39:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100c3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c3f:	83 c0 04             	add    $0x4,%eax
f0100c42:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c45:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c49:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c4c:	89 04 24             	mov    %eax,(%esp)
f0100c4f:	ff d7                	call   *%edi
f0100c51:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100c54:	e9 03 ff ff ff       	jmp    f0100b5c <vprintfmt+0x2c>
f0100c59:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100c5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c5f:	83 c0 04             	add    $0x4,%eax
f0100c62:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c65:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c68:	89 c2                	mov    %eax,%edx
f0100c6a:	c1 fa 1f             	sar    $0x1f,%edx
f0100c6d:	31 d0                	xor    %edx,%eax
f0100c6f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c71:	83 f8 06             	cmp    $0x6,%eax
f0100c74:	7f 0b                	jg     f0100c81 <vprintfmt+0x151>
f0100c76:	8b 14 85 ac 1d 10 f0 	mov    -0xfefe254(,%eax,4),%edx
f0100c7d:	85 d2                	test   %edx,%edx
f0100c7f:	75 20                	jne    f0100ca1 <vprintfmt+0x171>
				printfmt(putch, putdat, "error %d", err);
f0100c81:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c85:	c7 44 24 08 d5 1b 10 	movl   $0xf0101bd5,0x8(%esp)
f0100c8c:	f0 
f0100c8d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c91:	89 3c 24             	mov    %edi,(%esp)
f0100c94:	e8 36 03 00 00       	call   f0100fcf <printfmt>
f0100c99:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c9c:	e9 bb fe ff ff       	jmp    f0100b5c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0100ca1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ca5:	c7 44 24 08 de 1b 10 	movl   $0xf0101bde,0x8(%esp)
f0100cac:	f0 
f0100cad:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cb1:	89 3c 24             	mov    %edi,(%esp)
f0100cb4:	e8 16 03 00 00       	call   f0100fcf <printfmt>
f0100cb9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100cbc:	e9 9b fe ff ff       	jmp    f0100b5c <vprintfmt+0x2c>
f0100cc1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cc4:	89 c3                	mov    %eax,%ebx
f0100cc6:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100cc9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100ccc:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100ccf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cd2:	83 c0 04             	add    $0x4,%eax
f0100cd5:	89 45 14             	mov    %eax,0x14(%ebp)
f0100cd8:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100cdb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100cde:	85 c0                	test   %eax,%eax
f0100ce0:	75 07                	jne    f0100ce9 <vprintfmt+0x1b9>
f0100ce2:	c7 45 e0 e1 1b 10 f0 	movl   $0xf0101be1,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0100ce9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0100ced:	7e 06                	jle    f0100cf5 <vprintfmt+0x1c5>
f0100cef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100cf3:	75 13                	jne    f0100d08 <vprintfmt+0x1d8>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100cf5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100cf8:	0f be 02             	movsbl (%edx),%eax
f0100cfb:	85 c0                	test   %eax,%eax
f0100cfd:	0f 85 99 00 00 00    	jne    f0100d9c <vprintfmt+0x26c>
f0100d03:	e9 86 00 00 00       	jmp    f0100d8e <vprintfmt+0x25e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100d08:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d0c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d0f:	89 0c 24             	mov    %ecx,(%esp)
f0100d12:	e8 d4 03 00 00       	call   f01010eb <strnlen>
f0100d17:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100d1a:	29 c2                	sub    %eax,%edx
f0100d1c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100d1f:	85 d2                	test   %edx,%edx
f0100d21:	7e d2                	jle    f0100cf5 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0100d23:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0100d27:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100d2a:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100d2d:	89 d3                	mov    %edx,%ebx
f0100d2f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d36:	89 04 24             	mov    %eax,(%esp)
f0100d39:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100d3b:	83 eb 01             	sub    $0x1,%ebx
f0100d3e:	85 db                	test   %ebx,%ebx
f0100d40:	7f ed                	jg     f0100d2f <vprintfmt+0x1ff>
f0100d42:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d45:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d4c:	eb a7                	jmp    f0100cf5 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d4e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100d52:	74 18                	je     f0100d6c <vprintfmt+0x23c>
f0100d54:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d57:	83 fa 5e             	cmp    $0x5e,%edx
f0100d5a:	76 10                	jbe    f0100d6c <vprintfmt+0x23c>
					putch('?', putdat);
f0100d5c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d60:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100d67:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d6a:	eb 0a                	jmp    f0100d76 <vprintfmt+0x246>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0100d6c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d70:	89 04 24             	mov    %eax,(%esp)
f0100d73:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d76:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100d7a:	0f be 03             	movsbl (%ebx),%eax
f0100d7d:	85 c0                	test   %eax,%eax
f0100d7f:	74 05                	je     f0100d86 <vprintfmt+0x256>
f0100d81:	83 c3 01             	add    $0x1,%ebx
f0100d84:	eb 29                	jmp    f0100daf <vprintfmt+0x27f>
f0100d86:	89 fe                	mov    %edi,%esi
f0100d88:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100d8b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d8e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100d92:	7f 2e                	jg     f0100dc2 <vprintfmt+0x292>
f0100d94:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100d97:	e9 c0 fd ff ff       	jmp    f0100b5c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d9c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d9f:	83 c2 01             	add    $0x1,%edx
f0100da2:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100da5:	89 f7                	mov    %esi,%edi
f0100da7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100daa:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100dad:	89 d3                	mov    %edx,%ebx
f0100daf:	85 f6                	test   %esi,%esi
f0100db1:	78 9b                	js     f0100d4e <vprintfmt+0x21e>
f0100db3:	83 ee 01             	sub    $0x1,%esi
f0100db6:	79 96                	jns    f0100d4e <vprintfmt+0x21e>
f0100db8:	89 fe                	mov    %edi,%esi
f0100dba:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100dbd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100dc0:	eb cc                	jmp    f0100d8e <vprintfmt+0x25e>
f0100dc2:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0100dc5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100dc8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100dcc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100dd3:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100dd5:	83 eb 01             	sub    $0x1,%ebx
f0100dd8:	85 db                	test   %ebx,%ebx
f0100dda:	7f ec                	jg     f0100dc8 <vprintfmt+0x298>
f0100ddc:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100ddf:	e9 78 fd ff ff       	jmp    f0100b5c <vprintfmt+0x2c>
f0100de4:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100de7:	83 f9 01             	cmp    $0x1,%ecx
f0100dea:	7e 17                	jle    f0100e03 <vprintfmt+0x2d3>
		return va_arg(*ap, long long);
f0100dec:	8b 45 14             	mov    0x14(%ebp),%eax
f0100def:	83 c0 08             	add    $0x8,%eax
f0100df2:	89 45 14             	mov    %eax,0x14(%ebp)
f0100df5:	8b 50 f8             	mov    -0x8(%eax),%edx
f0100df8:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100dfb:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0100dfe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e01:	eb 34                	jmp    f0100e37 <vprintfmt+0x307>
	else if (lflag)
f0100e03:	85 c9                	test   %ecx,%ecx
f0100e05:	74 19                	je     f0100e20 <vprintfmt+0x2f0>
		return va_arg(*ap, long);
f0100e07:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e0a:	83 c0 04             	add    $0x4,%eax
f0100e0d:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e10:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e13:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e16:	89 c1                	mov    %eax,%ecx
f0100e18:	c1 f9 1f             	sar    $0x1f,%ecx
f0100e1b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e1e:	eb 17                	jmp    f0100e37 <vprintfmt+0x307>
	else
		return va_arg(*ap, int);
f0100e20:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e23:	83 c0 04             	add    $0x4,%eax
f0100e26:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e29:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e2f:	89 c2                	mov    %eax,%edx
f0100e31:	c1 fa 1f             	sar    $0x1f,%edx
f0100e34:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100e37:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e3a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e3d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100e42:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100e46:	0f 89 9c 00 00 00    	jns    f0100ee8 <vprintfmt+0x3b8>
				putch('-', putdat);
f0100e4c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e50:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100e57:	ff d7                	call   *%edi
				num = -(long long) num;
f0100e59:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e5c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e5f:	f7 d9                	neg    %ecx
f0100e61:	83 d3 00             	adc    $0x0,%ebx
f0100e64:	f7 db                	neg    %ebx
f0100e66:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100e6b:	eb 7b                	jmp    f0100ee8 <vprintfmt+0x3b8>
f0100e6d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100e70:	89 ca                	mov    %ecx,%edx
f0100e72:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e75:	e8 5c fc ff ff       	call   f0100ad6 <getuint>
f0100e7a:	89 c1                	mov    %eax,%ecx
f0100e7c:	89 d3                	mov    %edx,%ebx
f0100e7e:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0100e83:	eb 63                	jmp    f0100ee8 <vprintfmt+0x3b8>
f0100e85:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
f0100e88:	89 ca                	mov    %ecx,%edx
f0100e8a:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e8d:	e8 44 fc ff ff       	call   f0100ad6 <getuint>
f0100e92:	89 c1                	mov    %eax,%ecx
f0100e94:	89 d3                	mov    %edx,%ebx
f0100e96:	b8 08 00 00 00       	mov    $0x8,%eax
            base = 8;
            goto number;
f0100e9b:	eb 4b                	jmp    f0100ee8 <vprintfmt+0x3b8>
f0100e9d:	89 45 cc             	mov    %eax,-0x34(%ebp)
		//	putch('X', putdat);
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0100ea0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ea4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100eab:	ff d7                	call   *%edi
			putch('x', putdat);
f0100ead:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100eb1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100eb8:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100eba:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ebd:	83 c0 04             	add    $0x4,%eax
f0100ec0:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100ec3:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ecb:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0100ed0:	eb 16                	jmp    f0100ee8 <vprintfmt+0x3b8>
f0100ed2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100ed5:	89 ca                	mov    %ecx,%edx
f0100ed7:	8d 45 14             	lea    0x14(%ebp),%eax
f0100eda:	e8 f7 fb ff ff       	call   f0100ad6 <getuint>
f0100edf:	89 c1                	mov    %eax,%ecx
f0100ee1:	89 d3                	mov    %edx,%ebx
f0100ee3:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100ee8:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0100eec:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100ef0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ef3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ef7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100efb:	89 0c 24             	mov    %ecx,(%esp)
f0100efe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f02:	89 f2                	mov    %esi,%edx
f0100f04:	89 f8                	mov    %edi,%eax
f0100f06:	e8 d5 fa ff ff       	call   f01009e0 <printnum>
f0100f0b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100f0e:	e9 49 fc ff ff       	jmp    f0100b5c <vprintfmt+0x2c>
f0100f13:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f16:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100f19:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f1d:	89 14 24             	mov    %edx,(%esp)
f0100f20:	ff d7                	call   *%edi
f0100f22:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100f25:	e9 32 fc ff ff       	jmp    f0100b5c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100f2a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f2e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100f35:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100f37:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100f3a:	80 38 25             	cmpb   $0x25,(%eax)
f0100f3d:	0f 84 19 fc ff ff    	je     f0100b5c <vprintfmt+0x2c>
f0100f43:	89 c3                	mov    %eax,%ebx
f0100f45:	eb f0                	jmp    f0100f37 <vprintfmt+0x407>
				/* do nothing */;
			break;
		}
	}
}
f0100f47:	83 c4 5c             	add    $0x5c,%esp
f0100f4a:	5b                   	pop    %ebx
f0100f4b:	5e                   	pop    %esi
f0100f4c:	5f                   	pop    %edi
f0100f4d:	5d                   	pop    %ebp
f0100f4e:	c3                   	ret    

f0100f4f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100f4f:	55                   	push   %ebp
f0100f50:	89 e5                	mov    %esp,%ebp
f0100f52:	83 ec 28             	sub    $0x28,%esp
f0100f55:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f58:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0100f5b:	85 c0                	test   %eax,%eax
f0100f5d:	74 04                	je     f0100f63 <vsnprintf+0x14>
f0100f5f:	85 d2                	test   %edx,%edx
f0100f61:	7f 07                	jg     f0100f6a <vsnprintf+0x1b>
f0100f63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100f68:	eb 3b                	jmp    f0100fa5 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100f6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100f6d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0100f71:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100f7b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f82:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f85:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f89:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f90:	c7 04 24 13 0b 10 f0 	movl   $0xf0100b13,(%esp)
f0100f97:	e8 94 fb ff ff       	call   f0100b30 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f9f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100fa5:	c9                   	leave  
f0100fa6:	c3                   	ret    

f0100fa7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100fa7:	55                   	push   %ebp
f0100fa8:	89 e5                	mov    %esp,%ebp
f0100faa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100fad:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fb4:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fc5:	89 04 24             	mov    %eax,(%esp)
f0100fc8:	e8 82 ff ff ff       	call   f0100f4f <vsnprintf>
	va_end(ap);

	return rc;
}
f0100fcd:	c9                   	leave  
f0100fce:	c3                   	ret    

f0100fcf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100fcf:	55                   	push   %ebp
f0100fd0:	89 e5                	mov    %esp,%ebp
f0100fd2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100fd5:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fdc:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fdf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fea:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fed:	89 04 24             	mov    %eax,(%esp)
f0100ff0:	e8 3b fb ff ff       	call   f0100b30 <vprintfmt>
	va_end(ap);
}
f0100ff5:	c9                   	leave  
f0100ff6:	c3                   	ret    
	...

f0101000 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101000:	55                   	push   %ebp
f0101001:	89 e5                	mov    %esp,%ebp
f0101003:	57                   	push   %edi
f0101004:	56                   	push   %esi
f0101005:	53                   	push   %ebx
f0101006:	83 ec 1c             	sub    $0x1c,%esp
f0101009:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010100c:	85 c0                	test   %eax,%eax
f010100e:	74 10                	je     f0101020 <readline+0x20>
		cprintf("%s", prompt);
f0101010:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101014:	c7 04 24 de 1b 10 f0 	movl   $0xf0101bde,(%esp)
f010101b:	e8 8b f9 ff ff       	call   f01009ab <cprintf>

	i = 0;
	echoing = iscons(0);
f0101020:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101027:	e8 bb f3 ff ff       	call   f01003e7 <iscons>
f010102c:	89 c7                	mov    %eax,%edi
f010102e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101033:	e8 9e f3 ff ff       	call   f01003d6 <getchar>
f0101038:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010103a:	85 c0                	test   %eax,%eax
f010103c:	79 17                	jns    f0101055 <readline+0x55>
			cprintf("read error: %e\n", c);
f010103e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101042:	c7 04 24 c8 1d 10 f0 	movl   $0xf0101dc8,(%esp)
f0101049:	e8 5d f9 ff ff       	call   f01009ab <cprintf>
f010104e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101053:	eb 65                	jmp    f01010ba <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101055:	83 f8 1f             	cmp    $0x1f,%eax
f0101058:	7e 1f                	jle    f0101079 <readline+0x79>
f010105a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101060:	7f 17                	jg     f0101079 <readline+0x79>
			if (echoing)
f0101062:	85 ff                	test   %edi,%edi
f0101064:	74 08                	je     f010106e <readline+0x6e>
				cputchar(c);
f0101066:	89 04 24             	mov    %eax,(%esp)
f0101069:	e8 92 f6 ff ff       	call   f0100700 <cputchar>
			buf[i++] = c;
f010106e:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0101074:	83 c6 01             	add    $0x1,%esi
f0101077:	eb ba                	jmp    f0101033 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101079:	83 fb 08             	cmp    $0x8,%ebx
f010107c:	75 15                	jne    f0101093 <readline+0x93>
f010107e:	85 f6                	test   %esi,%esi
f0101080:	7e 11                	jle    f0101093 <readline+0x93>
			if (echoing)
f0101082:	85 ff                	test   %edi,%edi
f0101084:	74 08                	je     f010108e <readline+0x8e>
				cputchar(c);
f0101086:	89 1c 24             	mov    %ebx,(%esp)
f0101089:	e8 72 f6 ff ff       	call   f0100700 <cputchar>
			i--;
f010108e:	83 ee 01             	sub    $0x1,%esi
f0101091:	eb a0                	jmp    f0101033 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101093:	83 fb 0a             	cmp    $0xa,%ebx
f0101096:	74 0a                	je     f01010a2 <readline+0xa2>
f0101098:	83 fb 0d             	cmp    $0xd,%ebx
f010109b:	90                   	nop
f010109c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01010a0:	75 91                	jne    f0101033 <readline+0x33>
			if (echoing)
f01010a2:	85 ff                	test   %edi,%edi
f01010a4:	74 08                	je     f01010ae <readline+0xae>
				cputchar(c);
f01010a6:	89 1c 24             	mov    %ebx,(%esp)
f01010a9:	e8 52 f6 ff ff       	call   f0100700 <cputchar>
			buf[i] = 0;
f01010ae:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
f01010b5:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
			return buf;
		}
	}
}
f01010ba:	83 c4 1c             	add    $0x1c,%esp
f01010bd:	5b                   	pop    %ebx
f01010be:	5e                   	pop    %esi
f01010bf:	5f                   	pop    %edi
f01010c0:	5d                   	pop    %ebp
f01010c1:	c3                   	ret    
	...

f01010d0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01010d0:	55                   	push   %ebp
f01010d1:	89 e5                	mov    %esp,%ebp
f01010d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01010d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010db:	80 3a 00             	cmpb   $0x0,(%edx)
f01010de:	74 09                	je     f01010e9 <strlen+0x19>
		n++;
f01010e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01010e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01010e7:	75 f7                	jne    f01010e0 <strlen+0x10>
		n++;
	return n;
}
f01010e9:	5d                   	pop    %ebp
f01010ea:	c3                   	ret    

f01010eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01010eb:	55                   	push   %ebp
f01010ec:	89 e5                	mov    %esp,%ebp
f01010ee:	53                   	push   %ebx
f01010ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010f5:	85 c9                	test   %ecx,%ecx
f01010f7:	74 19                	je     f0101112 <strnlen+0x27>
f01010f9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010fc:	74 14                	je     f0101112 <strnlen+0x27>
f01010fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101103:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101106:	39 c8                	cmp    %ecx,%eax
f0101108:	74 0d                	je     f0101117 <strnlen+0x2c>
f010110a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010110e:	75 f3                	jne    f0101103 <strnlen+0x18>
f0101110:	eb 05                	jmp    f0101117 <strnlen+0x2c>
f0101112:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101117:	5b                   	pop    %ebx
f0101118:	5d                   	pop    %ebp
f0101119:	c3                   	ret    

f010111a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010111a:	55                   	push   %ebp
f010111b:	89 e5                	mov    %esp,%ebp
f010111d:	53                   	push   %ebx
f010111e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101121:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101124:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101129:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010112d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101130:	83 c2 01             	add    $0x1,%edx
f0101133:	84 c9                	test   %cl,%cl
f0101135:	75 f2                	jne    f0101129 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101137:	5b                   	pop    %ebx
f0101138:	5d                   	pop    %ebp
f0101139:	c3                   	ret    

f010113a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010113a:	55                   	push   %ebp
f010113b:	89 e5                	mov    %esp,%ebp
f010113d:	56                   	push   %esi
f010113e:	53                   	push   %ebx
f010113f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101142:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101145:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101148:	85 f6                	test   %esi,%esi
f010114a:	74 18                	je     f0101164 <strncpy+0x2a>
f010114c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101151:	0f b6 1a             	movzbl (%edx),%ebx
f0101154:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101157:	80 3a 01             	cmpb   $0x1,(%edx)
f010115a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010115d:	83 c1 01             	add    $0x1,%ecx
f0101160:	39 ce                	cmp    %ecx,%esi
f0101162:	77 ed                	ja     f0101151 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101164:	5b                   	pop    %ebx
f0101165:	5e                   	pop    %esi
f0101166:	5d                   	pop    %ebp
f0101167:	c3                   	ret    

f0101168 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101168:	55                   	push   %ebp
f0101169:	89 e5                	mov    %esp,%ebp
f010116b:	56                   	push   %esi
f010116c:	53                   	push   %ebx
f010116d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101170:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101173:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101176:	89 f0                	mov    %esi,%eax
f0101178:	85 c9                	test   %ecx,%ecx
f010117a:	74 27                	je     f01011a3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f010117c:	83 e9 01             	sub    $0x1,%ecx
f010117f:	74 1d                	je     f010119e <strlcpy+0x36>
f0101181:	0f b6 1a             	movzbl (%edx),%ebx
f0101184:	84 db                	test   %bl,%bl
f0101186:	74 16                	je     f010119e <strlcpy+0x36>
			*dst++ = *src++;
f0101188:	88 18                	mov    %bl,(%eax)
f010118a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010118d:	83 e9 01             	sub    $0x1,%ecx
f0101190:	74 0e                	je     f01011a0 <strlcpy+0x38>
			*dst++ = *src++;
f0101192:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101195:	0f b6 1a             	movzbl (%edx),%ebx
f0101198:	84 db                	test   %bl,%bl
f010119a:	75 ec                	jne    f0101188 <strlcpy+0x20>
f010119c:	eb 02                	jmp    f01011a0 <strlcpy+0x38>
f010119e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01011a0:	c6 00 00             	movb   $0x0,(%eax)
f01011a3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01011a5:	5b                   	pop    %ebx
f01011a6:	5e                   	pop    %esi
f01011a7:	5d                   	pop    %ebp
f01011a8:	c3                   	ret    

f01011a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01011a9:	55                   	push   %ebp
f01011aa:	89 e5                	mov    %esp,%ebp
f01011ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01011b2:	0f b6 01             	movzbl (%ecx),%eax
f01011b5:	84 c0                	test   %al,%al
f01011b7:	74 15                	je     f01011ce <strcmp+0x25>
f01011b9:	3a 02                	cmp    (%edx),%al
f01011bb:	75 11                	jne    f01011ce <strcmp+0x25>
		p++, q++;
f01011bd:	83 c1 01             	add    $0x1,%ecx
f01011c0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01011c3:	0f b6 01             	movzbl (%ecx),%eax
f01011c6:	84 c0                	test   %al,%al
f01011c8:	74 04                	je     f01011ce <strcmp+0x25>
f01011ca:	3a 02                	cmp    (%edx),%al
f01011cc:	74 ef                	je     f01011bd <strcmp+0x14>
f01011ce:	0f b6 c0             	movzbl %al,%eax
f01011d1:	0f b6 12             	movzbl (%edx),%edx
f01011d4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01011d6:	5d                   	pop    %ebp
f01011d7:	c3                   	ret    

f01011d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01011d8:	55                   	push   %ebp
f01011d9:	89 e5                	mov    %esp,%ebp
f01011db:	53                   	push   %ebx
f01011dc:	8b 55 08             	mov    0x8(%ebp),%edx
f01011df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01011e2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01011e5:	85 c0                	test   %eax,%eax
f01011e7:	74 23                	je     f010120c <strncmp+0x34>
f01011e9:	0f b6 1a             	movzbl (%edx),%ebx
f01011ec:	84 db                	test   %bl,%bl
f01011ee:	74 24                	je     f0101214 <strncmp+0x3c>
f01011f0:	3a 19                	cmp    (%ecx),%bl
f01011f2:	75 20                	jne    f0101214 <strncmp+0x3c>
f01011f4:	83 e8 01             	sub    $0x1,%eax
f01011f7:	74 13                	je     f010120c <strncmp+0x34>
		n--, p++, q++;
f01011f9:	83 c2 01             	add    $0x1,%edx
f01011fc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01011ff:	0f b6 1a             	movzbl (%edx),%ebx
f0101202:	84 db                	test   %bl,%bl
f0101204:	74 0e                	je     f0101214 <strncmp+0x3c>
f0101206:	3a 19                	cmp    (%ecx),%bl
f0101208:	74 ea                	je     f01011f4 <strncmp+0x1c>
f010120a:	eb 08                	jmp    f0101214 <strncmp+0x3c>
f010120c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101211:	5b                   	pop    %ebx
f0101212:	5d                   	pop    %ebp
f0101213:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101214:	0f b6 02             	movzbl (%edx),%eax
f0101217:	0f b6 11             	movzbl (%ecx),%edx
f010121a:	29 d0                	sub    %edx,%eax
f010121c:	eb f3                	jmp    f0101211 <strncmp+0x39>

f010121e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010121e:	55                   	push   %ebp
f010121f:	89 e5                	mov    %esp,%ebp
f0101221:	8b 45 08             	mov    0x8(%ebp),%eax
f0101224:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101228:	0f b6 10             	movzbl (%eax),%edx
f010122b:	84 d2                	test   %dl,%dl
f010122d:	74 15                	je     f0101244 <strchr+0x26>
		if (*s == c)
f010122f:	38 ca                	cmp    %cl,%dl
f0101231:	75 07                	jne    f010123a <strchr+0x1c>
f0101233:	eb 14                	jmp    f0101249 <strchr+0x2b>
f0101235:	38 ca                	cmp    %cl,%dl
f0101237:	90                   	nop
f0101238:	74 0f                	je     f0101249 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010123a:	83 c0 01             	add    $0x1,%eax
f010123d:	0f b6 10             	movzbl (%eax),%edx
f0101240:	84 d2                	test   %dl,%dl
f0101242:	75 f1                	jne    f0101235 <strchr+0x17>
f0101244:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101249:	5d                   	pop    %ebp
f010124a:	c3                   	ret    

f010124b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010124b:	55                   	push   %ebp
f010124c:	89 e5                	mov    %esp,%ebp
f010124e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101251:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101255:	0f b6 10             	movzbl (%eax),%edx
f0101258:	84 d2                	test   %dl,%dl
f010125a:	74 18                	je     f0101274 <strfind+0x29>
		if (*s == c)
f010125c:	38 ca                	cmp    %cl,%dl
f010125e:	75 0a                	jne    f010126a <strfind+0x1f>
f0101260:	eb 12                	jmp    f0101274 <strfind+0x29>
f0101262:	38 ca                	cmp    %cl,%dl
f0101264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101268:	74 0a                	je     f0101274 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010126a:	83 c0 01             	add    $0x1,%eax
f010126d:	0f b6 10             	movzbl (%eax),%edx
f0101270:	84 d2                	test   %dl,%dl
f0101272:	75 ee                	jne    f0101262 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101274:	5d                   	pop    %ebp
f0101275:	c3                   	ret    

f0101276 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101276:	55                   	push   %ebp
f0101277:	89 e5                	mov    %esp,%ebp
f0101279:	53                   	push   %ebx
f010127a:	8b 45 08             	mov    0x8(%ebp),%eax
f010127d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101280:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101283:	89 da                	mov    %ebx,%edx
f0101285:	83 ea 01             	sub    $0x1,%edx
f0101288:	78 0e                	js     f0101298 <memset+0x22>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f010128a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f010128c:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f010128f:	88 0a                	mov    %cl,(%edx)
f0101291:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101294:	39 da                	cmp    %ebx,%edx
f0101296:	75 f7                	jne    f010128f <memset+0x19>
		*p++ = c;

	return v;
}
f0101298:	5b                   	pop    %ebx
f0101299:	5d                   	pop    %ebp
f010129a:	c3                   	ret    

f010129b <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f010129b:	55                   	push   %ebp
f010129c:	89 e5                	mov    %esp,%ebp
f010129e:	56                   	push   %esi
f010129f:	53                   	push   %ebx
f01012a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01012a3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f01012a9:	85 db                	test   %ebx,%ebx
f01012ab:	74 13                	je     f01012c0 <memcpy+0x25>
f01012ad:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f01012b2:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01012b6:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012b9:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f01012bc:	39 da                	cmp    %ebx,%edx
f01012be:	75 f2                	jne    f01012b2 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f01012c0:	5b                   	pop    %ebx
f01012c1:	5e                   	pop    %esi
f01012c2:	5d                   	pop    %ebp
f01012c3:	c3                   	ret    

f01012c4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01012c4:	55                   	push   %ebp
f01012c5:	89 e5                	mov    %esp,%ebp
f01012c7:	57                   	push   %edi
f01012c8:	56                   	push   %esi
f01012c9:	53                   	push   %ebx
f01012ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01012cd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f01012d3:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f01012d5:	39 c6                	cmp    %eax,%esi
f01012d7:	72 0b                	jb     f01012e4 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f01012d9:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f01012de:	85 db                	test   %ebx,%ebx
f01012e0:	75 2d                	jne    f010130f <memmove+0x4b>
f01012e2:	eb 39                	jmp    f010131d <memmove+0x59>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01012e4:	01 df                	add    %ebx,%edi
f01012e6:	39 f8                	cmp    %edi,%eax
f01012e8:	73 ef                	jae    f01012d9 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f01012ea:	85 db                	test   %ebx,%ebx
f01012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01012f0:	74 2b                	je     f010131d <memmove+0x59>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f01012f2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f01012f5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f01012fa:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f01012ff:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f0101303:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0101306:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0101309:	85 c9                	test   %ecx,%ecx
f010130b:	75 ed                	jne    f01012fa <memmove+0x36>
f010130d:	eb 0e                	jmp    f010131d <memmove+0x59>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f010130f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101313:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101316:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101319:	39 d3                	cmp    %edx,%ebx
f010131b:	75 f2                	jne    f010130f <memmove+0x4b>
			*d++ = *s++;

	return dst;
}
f010131d:	5b                   	pop    %ebx
f010131e:	5e                   	pop    %esi
f010131f:	5f                   	pop    %edi
f0101320:	5d                   	pop    %ebp
f0101321:	c3                   	ret    

f0101322 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101322:	55                   	push   %ebp
f0101323:	89 e5                	mov    %esp,%ebp
f0101325:	57                   	push   %edi
f0101326:	56                   	push   %esi
f0101327:	53                   	push   %ebx
f0101328:	8b 75 08             	mov    0x8(%ebp),%esi
f010132b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010132e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101331:	85 c9                	test   %ecx,%ecx
f0101333:	74 36                	je     f010136b <memcmp+0x49>
		if (*s1 != *s2)
f0101335:	0f b6 06             	movzbl (%esi),%eax
f0101338:	0f b6 1f             	movzbl (%edi),%ebx
f010133b:	38 d8                	cmp    %bl,%al
f010133d:	74 20                	je     f010135f <memcmp+0x3d>
f010133f:	eb 14                	jmp    f0101355 <memcmp+0x33>
f0101341:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101346:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010134b:	83 c2 01             	add    $0x1,%edx
f010134e:	83 e9 01             	sub    $0x1,%ecx
f0101351:	38 d8                	cmp    %bl,%al
f0101353:	74 12                	je     f0101367 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101355:	0f b6 c0             	movzbl %al,%eax
f0101358:	0f b6 db             	movzbl %bl,%ebx
f010135b:	29 d8                	sub    %ebx,%eax
f010135d:	eb 11                	jmp    f0101370 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010135f:	83 e9 01             	sub    $0x1,%ecx
f0101362:	ba 00 00 00 00       	mov    $0x0,%edx
f0101367:	85 c9                	test   %ecx,%ecx
f0101369:	75 d6                	jne    f0101341 <memcmp+0x1f>
f010136b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101370:	5b                   	pop    %ebx
f0101371:	5e                   	pop    %esi
f0101372:	5f                   	pop    %edi
f0101373:	5d                   	pop    %ebp
f0101374:	c3                   	ret    

f0101375 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101375:	55                   	push   %ebp
f0101376:	89 e5                	mov    %esp,%ebp
f0101378:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010137b:	89 c2                	mov    %eax,%edx
f010137d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101380:	39 d0                	cmp    %edx,%eax
f0101382:	73 15                	jae    f0101399 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101384:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101388:	38 08                	cmp    %cl,(%eax)
f010138a:	75 06                	jne    f0101392 <memfind+0x1d>
f010138c:	eb 0b                	jmp    f0101399 <memfind+0x24>
f010138e:	38 08                	cmp    %cl,(%eax)
f0101390:	74 07                	je     f0101399 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101392:	83 c0 01             	add    $0x1,%eax
f0101395:	39 c2                	cmp    %eax,%edx
f0101397:	77 f5                	ja     f010138e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101399:	5d                   	pop    %ebp
f010139a:	c3                   	ret    

f010139b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010139b:	55                   	push   %ebp
f010139c:	89 e5                	mov    %esp,%ebp
f010139e:	57                   	push   %edi
f010139f:	56                   	push   %esi
f01013a0:	53                   	push   %ebx
f01013a1:	83 ec 04             	sub    $0x4,%esp
f01013a4:	8b 55 08             	mov    0x8(%ebp),%edx
f01013a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01013aa:	0f b6 02             	movzbl (%edx),%eax
f01013ad:	3c 20                	cmp    $0x20,%al
f01013af:	74 04                	je     f01013b5 <strtol+0x1a>
f01013b1:	3c 09                	cmp    $0x9,%al
f01013b3:	75 0e                	jne    f01013c3 <strtol+0x28>
		s++;
f01013b5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01013b8:	0f b6 02             	movzbl (%edx),%eax
f01013bb:	3c 20                	cmp    $0x20,%al
f01013bd:	74 f6                	je     f01013b5 <strtol+0x1a>
f01013bf:	3c 09                	cmp    $0x9,%al
f01013c1:	74 f2                	je     f01013b5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01013c3:	3c 2b                	cmp    $0x2b,%al
f01013c5:	75 0c                	jne    f01013d3 <strtol+0x38>
		s++;
f01013c7:	83 c2 01             	add    $0x1,%edx
f01013ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01013d1:	eb 15                	jmp    f01013e8 <strtol+0x4d>
	else if (*s == '-')
f01013d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01013da:	3c 2d                	cmp    $0x2d,%al
f01013dc:	75 0a                	jne    f01013e8 <strtol+0x4d>
		s++, neg = 1;
f01013de:	83 c2 01             	add    $0x1,%edx
f01013e1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013e8:	85 db                	test   %ebx,%ebx
f01013ea:	0f 94 c0             	sete   %al
f01013ed:	74 05                	je     f01013f4 <strtol+0x59>
f01013ef:	83 fb 10             	cmp    $0x10,%ebx
f01013f2:	75 18                	jne    f010140c <strtol+0x71>
f01013f4:	80 3a 30             	cmpb   $0x30,(%edx)
f01013f7:	75 13                	jne    f010140c <strtol+0x71>
f01013f9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01013fd:	8d 76 00             	lea    0x0(%esi),%esi
f0101400:	75 0a                	jne    f010140c <strtol+0x71>
		s += 2, base = 16;
f0101402:	83 c2 02             	add    $0x2,%edx
f0101405:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010140a:	eb 15                	jmp    f0101421 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010140c:	84 c0                	test   %al,%al
f010140e:	66 90                	xchg   %ax,%ax
f0101410:	74 0f                	je     f0101421 <strtol+0x86>
f0101412:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101417:	80 3a 30             	cmpb   $0x30,(%edx)
f010141a:	75 05                	jne    f0101421 <strtol+0x86>
		s++, base = 8;
f010141c:	83 c2 01             	add    $0x1,%edx
f010141f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101421:	b8 00 00 00 00       	mov    $0x0,%eax
f0101426:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101428:	0f b6 0a             	movzbl (%edx),%ecx
f010142b:	89 cf                	mov    %ecx,%edi
f010142d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101430:	80 fb 09             	cmp    $0x9,%bl
f0101433:	77 08                	ja     f010143d <strtol+0xa2>
			dig = *s - '0';
f0101435:	0f be c9             	movsbl %cl,%ecx
f0101438:	83 e9 30             	sub    $0x30,%ecx
f010143b:	eb 1e                	jmp    f010145b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010143d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101440:	80 fb 19             	cmp    $0x19,%bl
f0101443:	77 08                	ja     f010144d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101445:	0f be c9             	movsbl %cl,%ecx
f0101448:	83 e9 57             	sub    $0x57,%ecx
f010144b:	eb 0e                	jmp    f010145b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010144d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101450:	80 fb 19             	cmp    $0x19,%bl
f0101453:	77 15                	ja     f010146a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101455:	0f be c9             	movsbl %cl,%ecx
f0101458:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010145b:	39 f1                	cmp    %esi,%ecx
f010145d:	7d 0b                	jge    f010146a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010145f:	83 c2 01             	add    $0x1,%edx
f0101462:	0f af c6             	imul   %esi,%eax
f0101465:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101468:	eb be                	jmp    f0101428 <strtol+0x8d>
f010146a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010146c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101470:	74 05                	je     f0101477 <strtol+0xdc>
		*endptr = (char *) s;
f0101472:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101475:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101477:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010147b:	74 04                	je     f0101481 <strtol+0xe6>
f010147d:	89 c8                	mov    %ecx,%eax
f010147f:	f7 d8                	neg    %eax
}
f0101481:	83 c4 04             	add    $0x4,%esp
f0101484:	5b                   	pop    %ebx
f0101485:	5e                   	pop    %esi
f0101486:	5f                   	pop    %edi
f0101487:	5d                   	pop    %ebp
f0101488:	c3                   	ret    
f0101489:	00 00                	add    %al,(%eax)
f010148b:	00 00                	add    %al,(%eax)
f010148d:	00 00                	add    %al,(%eax)
	...

f0101490 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0101490:	55                   	push   %ebp
f0101491:	89 e5                	mov    %esp,%ebp
f0101493:	57                   	push   %edi
f0101494:	56                   	push   %esi
f0101495:	83 ec 10             	sub    $0x10,%esp
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
f0101498:	8b 45 14             	mov    0x14(%ebp),%eax
  n0 = nn.s.low;
f010149b:	8b 55 08             	mov    0x8(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
f010149e:	8b 75 10             	mov    0x10(%ebp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
f01014a1:	8b 7d 0c             	mov    0xc(%ebp),%edi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01014a4:	85 c0                	test   %eax,%eax
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f01014a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01014a9:	75 35                	jne    f01014e0 <__udivdi3+0x50>
    {
      if (d0 > n1)
f01014ab:	39 fe                	cmp    %edi,%esi
f01014ad:	77 61                	ja     f0101510 <__udivdi3+0x80>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01014af:	85 f6                	test   %esi,%esi
f01014b1:	75 0b                	jne    f01014be <__udivdi3+0x2e>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01014b3:	b8 01 00 00 00       	mov    $0x1,%eax
f01014b8:	31 d2                	xor    %edx,%edx
f01014ba:	f7 f6                	div    %esi
f01014bc:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01014be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01014c1:	31 d2                	xor    %edx,%edx
f01014c3:	89 f8                	mov    %edi,%eax
f01014c5:	f7 f6                	div    %esi
f01014c7:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01014c9:	89 c8                	mov    %ecx,%eax
f01014cb:	f7 f6                	div    %esi
f01014cd:	89 c1                	mov    %eax,%ecx
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01014cf:	89 fa                	mov    %edi,%edx
f01014d1:	89 c8                	mov    %ecx,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01014d3:	83 c4 10             	add    $0x10,%esp
f01014d6:	5e                   	pop    %esi
f01014d7:	5f                   	pop    %edi
f01014d8:	5d                   	pop    %ebp
f01014d9:	c3                   	ret    
f01014da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01014e0:	39 f8                	cmp    %edi,%eax
f01014e2:	77 1c                	ja     f0101500 <__udivdi3+0x70>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01014e4:	0f bd d0             	bsr    %eax,%edx
	  if (bm == 0)
f01014e7:	83 f2 1f             	xor    $0x1f,%edx
f01014ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01014ed:	75 39                	jne    f0101528 <__udivdi3+0x98>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01014ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01014f2:	0f 86 a0 00 00 00    	jbe    f0101598 <__udivdi3+0x108>
f01014f8:	39 f8                	cmp    %edi,%eax
f01014fa:	0f 82 98 00 00 00    	jb     f0101598 <__udivdi3+0x108>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0101500:	31 ff                	xor    %edi,%edi
f0101502:	31 c9                	xor    %ecx,%ecx
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101504:	89 c8                	mov    %ecx,%eax
f0101506:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101508:	83 c4 10             	add    $0x10,%esp
f010150b:	5e                   	pop    %esi
f010150c:	5f                   	pop    %edi
f010150d:	5d                   	pop    %ebp
f010150e:	c3                   	ret    
f010150f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101510:	89 d1                	mov    %edx,%ecx
f0101512:	89 fa                	mov    %edi,%edx
f0101514:	89 c8                	mov    %ecx,%eax
f0101516:	31 ff                	xor    %edi,%edi
f0101518:	f7 f6                	div    %esi
f010151a:	89 c1                	mov    %eax,%ecx
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010151c:	89 fa                	mov    %edi,%edx
f010151e:	89 c8                	mov    %ecx,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101520:	83 c4 10             	add    $0x10,%esp
f0101523:	5e                   	pop    %esi
f0101524:	5f                   	pop    %edi
f0101525:	5d                   	pop    %ebp
f0101526:	c3                   	ret    
f0101527:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101528:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010152c:	89 f2                	mov    %esi,%edx
f010152e:	d3 e0                	shl    %cl,%eax
f0101530:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101533:	b8 20 00 00 00       	mov    $0x20,%eax
f0101538:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010153b:	89 c1                	mov    %eax,%ecx
f010153d:	d3 ea                	shr    %cl,%edx
	      d0 = d0 << bm;
f010153f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101543:	0b 55 ec             	or     -0x14(%ebp),%edx
	      d0 = d0 << bm;
f0101546:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
f0101548:	89 c1                	mov    %eax,%ecx
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
f010154a:	89 75 e8             	mov    %esi,-0x18(%ebp)
	      n2 = n1 >> b;
f010154d:	89 fe                	mov    %edi,%esi
f010154f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
f0101551:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101555:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0101558:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010155b:	d3 e7                	shl    %cl,%edi
f010155d:	89 c1                	mov    %eax,%ecx
f010155f:	d3 ea                	shr    %cl,%edx
f0101561:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101563:	89 f2                	mov    %esi,%edx
f0101565:	89 f8                	mov    %edi,%eax
f0101567:	f7 75 ec             	divl   -0x14(%ebp)
f010156a:	89 d6                	mov    %edx,%esi
f010156c:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f010156e:	f7 65 e8             	mull   -0x18(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101571:	39 d6                	cmp    %edx,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
f0101573:	89 55 ec             	mov    %edx,-0x14(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101576:	72 30                	jb     f01015a8 <__udivdi3+0x118>
f0101578:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010157b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010157f:	d3 e2                	shl    %cl,%edx
f0101581:	39 c2                	cmp    %eax,%edx
f0101583:	73 05                	jae    f010158a <__udivdi3+0xfa>
f0101585:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101588:	74 1e                	je     f01015a8 <__udivdi3+0x118>
f010158a:	89 f9                	mov    %edi,%ecx
f010158c:	31 ff                	xor    %edi,%edi
f010158e:	e9 71 ff ff ff       	jmp    f0101504 <__udivdi3+0x74>
f0101593:	90                   	nop
f0101594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101598:	31 ff                	xor    %edi,%edi
f010159a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010159f:	e9 60 ff ff ff       	jmp    f0101504 <__udivdi3+0x74>
f01015a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01015a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f01015ab:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01015ad:	89 c8                	mov    %ecx,%eax
f01015af:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01015b1:	83 c4 10             	add    $0x10,%esp
f01015b4:	5e                   	pop    %esi
f01015b5:	5f                   	pop    %edi
f01015b6:	5d                   	pop    %ebp
f01015b7:	c3                   	ret    
	...

f01015c0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01015c0:	55                   	push   %ebp
f01015c1:	89 e5                	mov    %esp,%ebp
f01015c3:	57                   	push   %edi
f01015c4:	56                   	push   %esi
f01015c5:	83 ec 20             	sub    $0x20,%esp
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
f01015c8:	8b 55 14             	mov    0x14(%ebp),%edx
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01015cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
f01015ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
f01015d1:	8b 75 0c             	mov    0xc(%ebp),%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01015d4:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f01015d6:	89 c8                	mov    %ecx,%eax
f01015d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01015db:	75 13                	jne    f01015f0 <__umoddi3+0x30>
    {
      if (d0 > n1)
f01015dd:	39 f7                	cmp    %esi,%edi
f01015df:	76 3f                	jbe    f0101620 <__umoddi3+0x60>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01015e1:	89 f2                	mov    %esi,%edx
f01015e3:	f7 f7                	div    %edi

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f01015e5:	89 d0                	mov    %edx,%eax
f01015e7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01015e9:	83 c4 20             	add    $0x20,%esp
f01015ec:	5e                   	pop    %esi
f01015ed:	5f                   	pop    %edi
f01015ee:	5d                   	pop    %ebp
f01015ef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01015f0:	39 f2                	cmp    %esi,%edx
f01015f2:	77 4c                	ja     f0101640 <__umoddi3+0x80>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01015f4:	0f bd ca             	bsr    %edx,%ecx
	  if (bm == 0)
f01015f7:	83 f1 1f             	xor    $0x1f,%ecx
f01015fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01015fd:	75 51                	jne    f0101650 <__umoddi3+0x90>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01015ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101602:	0f 87 e0 00 00 00    	ja     f01016e8 <__umoddi3+0x128>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101608:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010160b:	29 f8                	sub    %edi,%eax
f010160d:	19 d6                	sbb    %edx,%esi
f010160f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101615:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101617:	83 c4 20             	add    $0x20,%esp
f010161a:	5e                   	pop    %esi
f010161b:	5f                   	pop    %edi
f010161c:	5d                   	pop    %ebp
f010161d:	c3                   	ret    
f010161e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0101620:	85 ff                	test   %edi,%edi
f0101622:	75 0b                	jne    f010162f <__umoddi3+0x6f>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101624:	b8 01 00 00 00       	mov    $0x1,%eax
f0101629:	31 d2                	xor    %edx,%edx
f010162b:	f7 f7                	div    %edi
f010162d:	89 c7                	mov    %eax,%edi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010162f:	89 f0                	mov    %esi,%eax
f0101631:	31 d2                	xor    %edx,%edx
f0101633:	f7 f7                	div    %edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101635:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101638:	f7 f7                	div    %edi
f010163a:	eb a9                	jmp    f01015e5 <__umoddi3+0x25>
f010163c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0101640:	89 c8                	mov    %ecx,%eax
f0101642:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101644:	83 c4 20             	add    $0x20,%esp
f0101647:	5e                   	pop    %esi
f0101648:	5f                   	pop    %edi
f0101649:	5d                   	pop    %ebp
f010164a:	c3                   	ret    
f010164b:	90                   	nop
f010164c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101650:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101654:	d3 e2                	shl    %cl,%edx
f0101656:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101659:	ba 20 00 00 00       	mov    $0x20,%edx
f010165e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101661:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101664:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101668:	89 fa                	mov    %edi,%edx
f010166a:	d3 ea                	shr    %cl,%edx
	      d0 = d0 << bm;
f010166c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101670:	0b 55 f4             	or     -0xc(%ebp),%edx
	      d0 = d0 << bm;
f0101673:	d3 e7                	shl    %cl,%edi
	      n2 = n1 >> b;
f0101675:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101679:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010167c:	89 f2                	mov    %esi,%edx
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
f010167e:	89 7d e8             	mov    %edi,-0x18(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0101681:	89 c7                	mov    %eax,%edi

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0101683:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
f0101685:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0101689:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f010168c:	89 c2                	mov    %eax,%edx
f010168e:	d3 e6                	shl    %cl,%esi
f0101690:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101694:	d3 ea                	shr    %cl,%edx
	      n0 = n0 << bm;
f0101696:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010169a:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010169c:	89 f0                	mov    %esi,%eax
f010169e:	8b 75 e4             	mov    -0x1c(%ebp),%esi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01016a1:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01016a3:	89 f2                	mov    %esi,%edx
f01016a5:	f7 75 f4             	divl   -0xc(%ebp)
f01016a8:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01016aa:	f7 65 e8             	mull   -0x18(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01016ad:	39 d6                	cmp    %edx,%esi
f01016af:	72 2b                	jb     f01016dc <__umoddi3+0x11c>
f01016b1:	39 c7                	cmp    %eax,%edi
f01016b3:	72 23                	jb     f01016d8 <__umoddi3+0x118>

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01016b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01016b9:	29 c7                	sub    %eax,%edi
f01016bb:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01016bd:	89 f0                	mov    %esi,%eax
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01016bf:	89 f2                	mov    %esi,%edx

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01016c1:	d3 ef                	shr    %cl,%edi
f01016c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01016c7:	d3 e0                	shl    %cl,%eax
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01016c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01016cd:	09 f8                	or     %edi,%eax
f01016cf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01016d1:	83 c4 20             	add    $0x20,%esp
f01016d4:	5e                   	pop    %esi
f01016d5:	5f                   	pop    %edi
f01016d6:	5d                   	pop    %ebp
f01016d7:	c3                   	ret    
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01016d8:	39 d6                	cmp    %edx,%esi
f01016da:	75 d9                	jne    f01016b5 <__umoddi3+0xf5>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01016dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01016df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01016e2:	eb d1                	jmp    f01016b5 <__umoddi3+0xf5>
f01016e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01016e8:	39 f2                	cmp    %esi,%edx
f01016ea:	0f 82 18 ff ff ff    	jb     f0101608 <__umoddi3+0x48>
f01016f0:	e9 1d ff ff ff       	jmp    f0101612 <__umoddi3+0x52>
