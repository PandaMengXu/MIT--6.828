
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
f0100054:	c7 04 24 c0 16 10 f0 	movl   $0xf01016c0,(%esp)
f010005b:	e8 eb 08 00 00       	call   f010094b <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 a6 08 00 00       	call   f0100918 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 6b 17 10 f0 	movl   $0xf010176b,(%esp)
f0100079:	e8 cd 08 00 00       	call   f010094b <cprintf>
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
f01000a5:	c7 04 24 da 16 10 f0 	movl   $0xf01016da,(%esp)
f01000ac:	e8 9a 08 00 00       	call   f010094b <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 55 08 00 00       	call   f0100918 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 6b 17 10 f0 	movl   $0xf010176b,(%esp)
f01000ca:	e8 7c 08 00 00       	call   f010094b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 f1 06 00 00       	call   f01007cc <monitor>
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
f01000eb:	c7 04 24 f2 16 10 f0 	movl   $0xf01016f2,(%esp)
f01000f2:	e8 54 08 00 00       	call   f010094b <cprintf>
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
f010011f:	e8 9c 05 00 00       	call   f01006c0 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100128:	c7 04 24 0e 17 10 f0 	movl   $0xf010170e,(%esp)
f010012f:	e8 17 08 00 00       	call   f010094b <cprintf>
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
f010013d:	83 ec 18             	sub    $0x18,%esp
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
f010015d:	e8 d4 10 00 00       	call   f0101236 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100162:	e8 2a 02 00 00       	call   f0100391 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100167:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010016e:	00 
f010016f:	c7 04 24 29 17 10 f0 	movl   $0xf0101729,(%esp)
f0100176:	e8 d0 07 00 00       	call   f010094b <cprintf>




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010017b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100182:	e8 56 ff ff ff       	call   f01000dd <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100187:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010018e:	e8 39 06 00 00       	call   f01007cc <monitor>
f0100193:	eb f2                	jmp    f0100187 <i386_init+0x4d>
	...

f01001a0 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001b0:	f6 c2 01             	test   $0x1,%dl
f01001b3:	74 09                	je     f01001be <serial_proc_data+0x1e>
f01001b5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001ba:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001bb:	0f b6 c0             	movzbl %al,%eax
}
f01001be:	5d                   	pop    %ebp
f01001bf:	c3                   	ret    

f01001c0 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp
f01001c3:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001c4:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01001c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ce:	89 da                	mov    %ebx,%edx
f01001d0:	ee                   	out    %al,(%dx)
f01001d1:	b2 fb                	mov    $0xfb,%dl
f01001d3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01001d8:	ee                   	out    %al,(%dx)
f01001d9:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01001de:	b8 0c 00 00 00       	mov    $0xc,%eax
f01001e3:	89 ca                	mov    %ecx,%edx
f01001e5:	ee                   	out    %al,(%dx)
f01001e6:	b2 f9                	mov    $0xf9,%dl
f01001e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ed:	ee                   	out    %al,(%dx)
f01001ee:	b2 fb                	mov    $0xfb,%dl
f01001f0:	b8 03 00 00 00       	mov    $0x3,%eax
f01001f5:	ee                   	out    %al,(%dx)
f01001f6:	b2 fc                	mov    $0xfc,%dl
f01001f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001fd:	ee                   	out    %al,(%dx)
f01001fe:	b2 f9                	mov    $0xf9,%dl
f0100200:	b8 01 00 00 00       	mov    $0x1,%eax
f0100205:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100206:	b2 fd                	mov    $0xfd,%dl
f0100208:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100209:	3c ff                	cmp    $0xff,%al
f010020b:	0f 95 c0             	setne  %al
f010020e:	0f b6 c0             	movzbl %al,%eax
f0100211:	a3 44 f3 10 f0       	mov    %eax,0xf010f344
f0100216:	89 da                	mov    %ebx,%edx
f0100218:	ec                   	in     (%dx),%al
f0100219:	89 ca                	mov    %ecx,%edx
f010021b:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010021c:	5b                   	pop    %ebx
f010021d:	5d                   	pop    %ebp
f010021e:	c3                   	ret    

f010021f <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010021f:	55                   	push   %ebp
f0100220:	89 e5                	mov    %esp,%ebp
f0100222:	83 ec 0c             	sub    $0xc,%esp
f0100225:	89 1c 24             	mov    %ebx,(%esp)
f0100228:	89 74 24 04          	mov    %esi,0x4(%esp)
f010022c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100230:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100235:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100238:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010023d:	0f b7 00             	movzwl (%eax),%eax
f0100240:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100244:	74 11                	je     f0100257 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100246:	c7 05 48 f3 10 f0 b4 	movl   $0x3b4,0xf010f348
f010024d:	03 00 00 
f0100250:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100255:	eb 16                	jmp    f010026d <cga_init+0x4e>
	} else {
		*cp = was;
f0100257:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010025e:	c7 05 48 f3 10 f0 d4 	movl   $0x3d4,0xf010f348
f0100265:	03 00 00 
f0100268:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010026d:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f0100273:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100275:	b8 0e 00 00 00       	mov    $0xe,%eax
f010027a:	89 ca                	mov    %ecx,%edx
f010027c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010027d:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100280:	89 ca                	mov    %ecx,%edx
f0100282:	ec                   	in     (%dx),%al
f0100283:	0f b6 f8             	movzbl %al,%edi
f0100286:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100289:	b8 0f 00 00 00       	mov    $0xf,%eax
f010028e:	89 da                	mov    %ebx,%edx
f0100290:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100291:	89 ca                	mov    %ecx,%edx
f0100293:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100294:	89 35 4c f3 10 f0    	mov    %esi,0xf010f34c
	crt_pos = pos;
f010029a:	0f b6 c8             	movzbl %al,%ecx
f010029d:	09 cf                	or     %ecx,%edi
f010029f:	66 89 3d 50 f3 10 f0 	mov    %di,0xf010f350
}
f01002a6:	8b 1c 24             	mov    (%esp),%ebx
f01002a9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01002ad:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01002b1:	89 ec                	mov    %ebp,%esp
f01002b3:	5d                   	pop    %ebp
f01002b4:	c3                   	ret    

f01002b5 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f01002b5:	55                   	push   %ebp
f01002b6:	89 e5                	mov    %esp,%ebp
}
f01002b8:	5d                   	pop    %ebp
f01002b9:	c3                   	ret    

f01002ba <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01002ba:	55                   	push   %ebp
f01002bb:	89 e5                	mov    %esp,%ebp
f01002bd:	57                   	push   %edi
f01002be:	56                   	push   %esi
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002c6:	bb 64 f5 10 f0       	mov    $0xf010f564,%ebx
f01002cb:	bf 60 f3 10 f0       	mov    $0xf010f360,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002d0:	eb 1e                	jmp    f01002f0 <cons_intr+0x36>
		if (c == 0)
f01002d2:	85 c0                	test   %eax,%eax
f01002d4:	74 1a                	je     f01002f0 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002d6:	8b 13                	mov    (%ebx),%edx
f01002d8:	88 04 17             	mov    %al,(%edi,%edx,1)
f01002db:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002de:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002e3:	0f 94 c2             	sete   %dl
f01002e6:	0f b6 d2             	movzbl %dl,%edx
f01002e9:	83 ea 01             	sub    $0x1,%edx
f01002ec:	21 d0                	and    %edx,%eax
f01002ee:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002f0:	ff d6                	call   *%esi
f01002f2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f5:	75 db                	jne    f01002d2 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002f7:	83 c4 0c             	add    $0xc,%esp
f01002fa:	5b                   	pop    %ebx
f01002fb:	5e                   	pop    %esi
f01002fc:	5f                   	pop    %edi
f01002fd:	5d                   	pop    %ebp
f01002fe:	c3                   	ret    

f01002ff <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01002ff:	55                   	push   %ebp
f0100300:	89 e5                	mov    %esp,%ebp
f0100302:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100305:	c7 04 24 b8 03 10 f0 	movl   $0xf01003b8,(%esp)
f010030c:	e8 a9 ff ff ff       	call   f01002ba <cons_intr>
}
f0100311:	c9                   	leave  
f0100312:	c3                   	ret    

f0100313 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100313:	55                   	push   %ebp
f0100314:	89 e5                	mov    %esp,%ebp
f0100316:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100319:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f0100320:	74 0c                	je     f010032e <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f0100322:	c7 04 24 a0 01 10 f0 	movl   $0xf01001a0,(%esp)
f0100329:	e8 8c ff ff ff       	call   f01002ba <cons_intr>
}
f010032e:	c9                   	leave  
f010032f:	c3                   	ret    

f0100330 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100330:	55                   	push   %ebp
f0100331:	89 e5                	mov    %esp,%ebp
f0100333:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100336:	e8 d8 ff ff ff       	call   f0100313 <serial_intr>
	kbd_intr();
f010033b:	e8 bf ff ff ff       	call   f01002ff <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100340:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
f0100346:	b8 00 00 00 00       	mov    $0x0,%eax
f010034b:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f0100351:	74 21                	je     f0100374 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100353:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f010035a:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010035d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100363:	0f 94 c1             	sete   %cl
f0100366:	0f b6 c9             	movzbl %cl,%ecx
f0100369:	83 e9 01             	sub    $0x1,%ecx
f010036c:	21 ca                	and    %ecx,%edx
f010036e:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f0100374:	c9                   	leave  
f0100375:	c3                   	ret    

f0100376 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100376:	55                   	push   %ebp
f0100377:	89 e5                	mov    %esp,%ebp
f0100379:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010037c:	e8 af ff ff ff       	call   f0100330 <cons_getc>
f0100381:	85 c0                	test   %eax,%eax
f0100383:	74 f7                	je     f010037c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100385:	c9                   	leave  
f0100386:	c3                   	ret    

f0100387 <iscons>:

int
iscons(int fdnum)
{
f0100387:	55                   	push   %ebp
f0100388:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010038a:	b8 01 00 00 00       	mov    $0x1,%eax
f010038f:	5d                   	pop    %ebp
f0100390:	c3                   	ret    

f0100391 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100391:	55                   	push   %ebp
f0100392:	89 e5                	mov    %esp,%ebp
f0100394:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100397:	e8 83 fe ff ff       	call   f010021f <cga_init>
	kbd_init();
	serial_init();
f010039c:	e8 1f fe ff ff       	call   f01001c0 <serial_init>

	if (!serial_exists)
f01003a1:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f01003a8:	75 0c                	jne    f01003b6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01003aa:	c7 04 24 44 17 10 f0 	movl   $0xf0101744,(%esp)
f01003b1:	e8 95 05 00 00       	call   f010094b <cprintf>
}
f01003b6:	c9                   	leave  
f01003b7:	c3                   	ret    

f01003b8 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003b8:	55                   	push   %ebp
f01003b9:	89 e5                	mov    %esp,%ebp
f01003bb:	53                   	push   %ebx
f01003bc:	83 ec 14             	sub    $0x14,%esp
f01003bf:	ba 64 00 00 00       	mov    $0x64,%edx
f01003c4:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003c5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ca:	a8 01                	test   $0x1,%al
f01003cc:	0f 84 d9 00 00 00    	je     f01004ab <kbd_proc_data+0xf3>
f01003d2:	b2 60                	mov    $0x60,%dl
f01003d4:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003d5:	3c e0                	cmp    $0xe0,%al
f01003d7:	75 11                	jne    f01003ea <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01003d9:	83 0d 40 f3 10 f0 40 	orl    $0x40,0xf010f340
f01003e0:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01003e5:	e9 c1 00 00 00       	jmp    f01004ab <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01003ea:	84 c0                	test   %al,%al
f01003ec:	79 32                	jns    f0100420 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003ee:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f01003f4:	f6 c2 40             	test   $0x40,%dl
f01003f7:	75 03                	jne    f01003fc <kbd_proc_data+0x44>
f01003f9:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01003fc:	0f b6 c0             	movzbl %al,%eax
f01003ff:	0f b6 80 80 17 10 f0 	movzbl -0xfefe880(%eax),%eax
f0100406:	83 c8 40             	or     $0x40,%eax
f0100409:	0f b6 c0             	movzbl %al,%eax
f010040c:	f7 d0                	not    %eax
f010040e:	21 c2                	and    %eax,%edx
f0100410:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
f0100416:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010041b:	e9 8b 00 00 00       	jmp    f01004ab <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100420:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100426:	f6 c2 40             	test   $0x40,%dl
f0100429:	74 0c                	je     f0100437 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010042b:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010042e:	83 e2 bf             	and    $0xffffffbf,%edx
f0100431:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
	}

	shift |= shiftcode[data];
f0100437:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010043a:	0f b6 90 80 17 10 f0 	movzbl -0xfefe880(%eax),%edx
f0100441:	0b 15 40 f3 10 f0    	or     0xf010f340,%edx
f0100447:	0f b6 88 80 18 10 f0 	movzbl -0xfefe780(%eax),%ecx
f010044e:	31 ca                	xor    %ecx,%edx
f0100450:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340

	c = charcode[shift & (CTL | SHIFT)][data];
f0100456:	89 d1                	mov    %edx,%ecx
f0100458:	83 e1 03             	and    $0x3,%ecx
f010045b:	8b 0c 8d 80 19 10 f0 	mov    -0xfefe680(,%ecx,4),%ecx
f0100462:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100466:	f6 c2 08             	test   $0x8,%dl
f0100469:	74 1a                	je     f0100485 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010046b:	89 d9                	mov    %ebx,%ecx
f010046d:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100470:	83 f8 19             	cmp    $0x19,%eax
f0100473:	77 05                	ja     f010047a <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100475:	83 eb 20             	sub    $0x20,%ebx
f0100478:	eb 0b                	jmp    f0100485 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010047a:	83 e9 41             	sub    $0x41,%ecx
f010047d:	83 f9 19             	cmp    $0x19,%ecx
f0100480:	77 03                	ja     f0100485 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100482:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100485:	f7 d2                	not    %edx
f0100487:	f6 c2 06             	test   $0x6,%dl
f010048a:	75 1f                	jne    f01004ab <kbd_proc_data+0xf3>
f010048c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100492:	75 17                	jne    f01004ab <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100494:	c7 04 24 61 17 10 f0 	movl   $0xf0101761,(%esp)
f010049b:	e8 ab 04 00 00       	call   f010094b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004a0:	ba 92 00 00 00       	mov    $0x92,%edx
f01004a5:	b8 03 00 00 00       	mov    $0x3,%eax
f01004aa:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004ab:	89 d8                	mov    %ebx,%eax
f01004ad:	83 c4 14             	add    $0x14,%esp
f01004b0:	5b                   	pop    %ebx
f01004b1:	5d                   	pop    %ebp
f01004b2:	c3                   	ret    

f01004b3 <cga_putc>:



void
cga_putc(int c)
{
f01004b3:	55                   	push   %ebp
f01004b4:	89 e5                	mov    %esp,%ebp
f01004b6:	56                   	push   %esi
f01004b7:	53                   	push   %ebx
f01004b8:	83 ec 10             	sub    $0x10,%esp
f01004bb:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004be:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01004c3:	75 03                	jne    f01004c8 <cga_putc+0x15>
		c |= 0x0700;
f01004c5:	80 cc 07             	or     $0x7,%ah

	switch (c & 0xff) {
f01004c8:	0f b6 d0             	movzbl %al,%edx
f01004cb:	83 fa 09             	cmp    $0x9,%edx
f01004ce:	0f 84 89 00 00 00    	je     f010055d <cga_putc+0xaa>
f01004d4:	83 fa 09             	cmp    $0x9,%edx
f01004d7:	7f 11                	jg     f01004ea <cga_putc+0x37>
f01004d9:	83 fa 08             	cmp    $0x8,%edx
f01004dc:	0f 85 b9 00 00 00    	jne    f010059b <cga_putc+0xe8>
f01004e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01004e8:	eb 18                	jmp    f0100502 <cga_putc+0x4f>
f01004ea:	83 fa 0a             	cmp    $0xa,%edx
f01004ed:	8d 76 00             	lea    0x0(%esi),%esi
f01004f0:	74 41                	je     f0100533 <cga_putc+0x80>
f01004f2:	83 fa 0d             	cmp    $0xd,%edx
f01004f5:	8d 76 00             	lea    0x0(%esi),%esi
f01004f8:	0f 85 9d 00 00 00    	jne    f010059b <cga_putc+0xe8>
f01004fe:	66 90                	xchg   %ax,%ax
f0100500:	eb 39                	jmp    f010053b <cga_putc+0x88>
	case '\b':
		if (crt_pos > 0) {
f0100502:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f0100509:	66 85 d2             	test   %dx,%dx
f010050c:	0f 84 f4 00 00 00    	je     f0100606 <cga_putc+0x153>
			crt_pos--;
f0100512:	83 ea 01             	sub    $0x1,%edx
f0100515:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010051c:	0f b7 d2             	movzwl %dx,%edx
f010051f:	b0 00                	mov    $0x0,%al
f0100521:	83 c8 20             	or     $0x20,%eax
f0100524:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f010052a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010052e:	e9 86 00 00 00       	jmp    f01005b9 <cga_putc+0x106>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100533:	66 83 05 50 f3 10 f0 	addw   $0x50,0xf010f350
f010053a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010053b:	0f b7 05 50 f3 10 f0 	movzwl 0xf010f350,%eax
f0100542:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100548:	c1 e8 10             	shr    $0x10,%eax
f010054b:	66 c1 e8 06          	shr    $0x6,%ax
f010054f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100552:	c1 e0 04             	shl    $0x4,%eax
f0100555:	66 a3 50 f3 10 f0    	mov    %ax,0xf010f350
		break;
f010055b:	eb 5c                	jmp    f01005b9 <cga_putc+0x106>
	case '\t':
		cons_putc(' ');
f010055d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100564:	e8 d4 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100569:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100570:	e8 c8 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100575:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010057c:	e8 bc 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100581:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100588:	e8 b0 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f010058d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100594:	e8 a4 00 00 00       	call   f010063d <cons_putc>
		break;
f0100599:	eb 1e                	jmp    f01005b9 <cga_putc+0x106>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010059b:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f01005a2:	0f b7 da             	movzwl %dx,%ebx
f01005a5:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f01005ab:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005af:	83 c2 01             	add    $0x1,%edx
f01005b2:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005b9:	66 81 3d 50 f3 10 f0 	cmpw   $0x7cf,0xf010f350
f01005c0:	cf 07 
f01005c2:	76 42                	jbe    f0100606 <cga_putc+0x153>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005c4:	a1 4c f3 10 f0       	mov    0xf010f34c,%eax
f01005c9:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005d0:	00 
f01005d1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005d7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005db:	89 04 24             	mov    %eax,(%esp)
f01005de:	e8 78 0c 00 00       	call   f010125b <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005e3:	8b 15 4c f3 10 f0    	mov    0xf010f34c,%edx
f01005e9:	b8 80 07 00 00       	mov    $0x780,%eax
f01005ee:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005f4:	83 c0 01             	add    $0x1,%eax
f01005f7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005fc:	75 f0                	jne    f01005ee <cga_putc+0x13b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005fe:	66 83 2d 50 f3 10 f0 	subw   $0x50,0xf010f350
f0100605:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100606:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010060c:	89 cb                	mov    %ecx,%ebx
f010060e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100616:	0f b7 35 50 f3 10 f0 	movzwl 0xf010f350,%esi
f010061d:	83 c1 01             	add    $0x1,%ecx
f0100620:	89 f0                	mov    %esi,%eax
f0100622:	66 c1 e8 08          	shr    $0x8,%ax
f0100626:	89 ca                	mov    %ecx,%edx
f0100628:	ee                   	out    %al,(%dx)
f0100629:	b8 0f 00 00 00       	mov    $0xf,%eax
f010062e:	89 da                	mov    %ebx,%edx
f0100630:	ee                   	out    %al,(%dx)
f0100631:	89 f0                	mov    %esi,%eax
f0100633:	89 ca                	mov    %ecx,%edx
f0100635:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100636:	83 c4 10             	add    $0x10,%esp
f0100639:	5b                   	pop    %ebx
f010063a:	5e                   	pop    %esi
f010063b:	5d                   	pop    %ebp
f010063c:	c3                   	ret    

f010063d <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f010063d:	55                   	push   %ebp
f010063e:	89 e5                	mov    %esp,%ebp
f0100640:	57                   	push   %edi
f0100641:	56                   	push   %esi
f0100642:	53                   	push   %ebx
f0100643:	83 ec 1c             	sub    $0x1c,%esp
f0100646:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100649:	ba 79 03 00 00       	mov    $0x379,%edx
f010064e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010064f:	84 c0                	test   %al,%al
f0100651:	78 27                	js     f010067a <cons_putc+0x3d>
f0100653:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100658:	b9 84 00 00 00       	mov    $0x84,%ecx
f010065d:	be 79 03 00 00       	mov    $0x379,%esi
f0100662:	89 ca                	mov    %ecx,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	ec                   	in     (%dx),%al
f0100666:	ec                   	in     (%dx),%al
f0100667:	ec                   	in     (%dx),%al
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	84 c0                	test   %al,%al
f010066d:	78 0b                	js     f010067a <cons_putc+0x3d>
f010066f:	83 c3 01             	add    $0x1,%ebx
f0100672:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100678:	75 e8                	jne    f0100662 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010067a:	ba 78 03 00 00       	mov    $0x378,%edx
f010067f:	89 f8                	mov    %edi,%eax
f0100681:	ee                   	out    %al,(%dx)
f0100682:	b2 7a                	mov    $0x7a,%dl
f0100684:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100689:	ee                   	out    %al,(%dx)
f010068a:	b8 08 00 00 00       	mov    $0x8,%eax
f010068f:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f0100690:	89 3c 24             	mov    %edi,(%esp)
f0100693:	e8 1b fe ff ff       	call   f01004b3 <cga_putc>
}
f0100698:	83 c4 1c             	add    $0x1c,%esp
f010069b:	5b                   	pop    %ebx
f010069c:	5e                   	pop    %esi
f010069d:	5f                   	pop    %edi
f010069e:	5d                   	pop    %ebp
f010069f:	c3                   	ret    

f01006a0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
f01006a3:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a9:	89 04 24             	mov    %eax,(%esp)
f01006ac:	e8 8c ff ff ff       	call   f010063d <cons_putc>
}
f01006b1:	c9                   	leave  
f01006b2:	c3                   	ret    
	...

f01006c0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01006c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c8:	5d                   	pop    %ebp
f01006c9:	c3                   	ret    

f01006ca <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006ca:	55                   	push   %ebp
f01006cb:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006cd:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006d0:	5d                   	pop    %ebp
f01006d1:	c3                   	ret    

f01006d2 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006d2:	55                   	push   %ebp
f01006d3:	89 e5                	mov    %esp,%ebp
f01006d5:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006d8:	c7 04 24 90 19 10 f0 	movl   $0xf0101990,(%esp)
f01006df:	e8 67 02 00 00       	call   f010094b <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01006e4:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006eb:	00 
f01006ec:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006f3:	f0 
f01006f4:	c7 04 24 1c 1a 10 f0 	movl   $0xf0101a1c,(%esp)
f01006fb:	e8 4b 02 00 00       	call   f010094b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100700:	c7 44 24 08 b5 16 10 	movl   $0x1016b5,0x8(%esp)
f0100707:	00 
f0100708:	c7 44 24 04 b5 16 10 	movl   $0xf01016b5,0x4(%esp)
f010070f:	f0 
f0100710:	c7 04 24 40 1a 10 f0 	movl   $0xf0101a40,(%esp)
f0100717:	e8 2f 02 00 00       	call   f010094b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010071c:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f0100723:	00 
f0100724:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f010072b:	f0 
f010072c:	c7 04 24 64 1a 10 f0 	movl   $0xf0101a64,(%esp)
f0100733:	e8 13 02 00 00       	call   f010094b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100738:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f010073f:	00 
f0100740:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f0100747:	f0 
f0100748:	c7 04 24 88 1a 10 f0 	movl   $0xf0101a88,(%esp)
f010074f:	e8 f7 01 00 00       	call   f010094b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100754:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f0100759:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010075e:	89 c2                	mov    %eax,%edx
f0100760:	c1 fa 1f             	sar    $0x1f,%edx
f0100763:	c1 ea 16             	shr    $0x16,%edx
f0100766:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100769:	c1 f8 0a             	sar    $0xa,%eax
f010076c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100770:	c7 04 24 ac 1a 10 f0 	movl   $0xf0101aac,(%esp)
f0100777:	e8 cf 01 00 00       	call   f010094b <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010077c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100781:	c9                   	leave  
f0100782:	c3                   	ret    

f0100783 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100783:	55                   	push   %ebp
f0100784:	89 e5                	mov    %esp,%ebp
f0100786:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100789:	a1 50 1b 10 f0       	mov    0xf0101b50,%eax
f010078e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100792:	a1 4c 1b 10 f0       	mov    0xf0101b4c,%eax
f0100797:	89 44 24 04          	mov    %eax,0x4(%esp)
f010079b:	c7 04 24 a9 19 10 f0 	movl   $0xf01019a9,(%esp)
f01007a2:	e8 a4 01 00 00       	call   f010094b <cprintf>
f01007a7:	a1 5c 1b 10 f0       	mov    0xf0101b5c,%eax
f01007ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007b0:	a1 58 1b 10 f0       	mov    0xf0101b58,%eax
f01007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007b9:	c7 04 24 a9 19 10 f0 	movl   $0xf01019a9,(%esp)
f01007c0:	e8 86 01 00 00       	call   f010094b <cprintf>
	return 0;
}
f01007c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ca:	c9                   	leave  
f01007cb:	c3                   	ret    

f01007cc <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007cc:	55                   	push   %ebp
f01007cd:	89 e5                	mov    %esp,%ebp
f01007cf:	57                   	push   %edi
f01007d0:	56                   	push   %esi
f01007d1:	53                   	push   %ebx
f01007d2:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007d5:	c7 04 24 d8 1a 10 f0 	movl   $0xf0101ad8,(%esp)
f01007dc:	e8 6a 01 00 00       	call   f010094b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007e1:	c7 04 24 fc 1a 10 f0 	movl   $0xf0101afc,(%esp)
f01007e8:	e8 5e 01 00 00       	call   f010094b <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01007ed:	bf 4c 1b 10 f0       	mov    $0xf0101b4c,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f01007f2:	c7 04 24 b2 19 10 f0 	movl   $0xf01019b2,(%esp)
f01007f9:	e8 c2 07 00 00       	call   f0100fc0 <readline>
f01007fe:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100800:	85 c0                	test   %eax,%eax
f0100802:	74 ee                	je     f01007f2 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100804:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010080b:	be 00 00 00 00       	mov    $0x0,%esi
f0100810:	eb 06                	jmp    f0100818 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100812:	c6 03 00             	movb   $0x0,(%ebx)
f0100815:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100818:	0f b6 03             	movzbl (%ebx),%eax
f010081b:	84 c0                	test   %al,%al
f010081d:	74 6c                	je     f010088b <monitor+0xbf>
f010081f:	0f be c0             	movsbl %al,%eax
f0100822:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100826:	c7 04 24 b6 19 10 f0 	movl   $0xf01019b6,(%esp)
f010082d:	e8 ac 09 00 00       	call   f01011de <strchr>
f0100832:	85 c0                	test   %eax,%eax
f0100834:	75 dc                	jne    f0100812 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100836:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100839:	74 50                	je     f010088b <monitor+0xbf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010083b:	83 fe 0f             	cmp    $0xf,%esi
f010083e:	66 90                	xchg   %ax,%ax
f0100840:	75 16                	jne    f0100858 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100842:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100849:	00 
f010084a:	c7 04 24 bb 19 10 f0 	movl   $0xf01019bb,(%esp)
f0100851:	e8 f5 00 00 00       	call   f010094b <cprintf>
f0100856:	eb 9a                	jmp    f01007f2 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f0100858:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010085c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010085f:	0f b6 03             	movzbl (%ebx),%eax
f0100862:	84 c0                	test   %al,%al
f0100864:	75 0c                	jne    f0100872 <monitor+0xa6>
f0100866:	eb b0                	jmp    f0100818 <monitor+0x4c>
			buf++;
f0100868:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010086b:	0f b6 03             	movzbl (%ebx),%eax
f010086e:	84 c0                	test   %al,%al
f0100870:	74 a6                	je     f0100818 <monitor+0x4c>
f0100872:	0f be c0             	movsbl %al,%eax
f0100875:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100879:	c7 04 24 b6 19 10 f0 	movl   $0xf01019b6,(%esp)
f0100880:	e8 59 09 00 00       	call   f01011de <strchr>
f0100885:	85 c0                	test   %eax,%eax
f0100887:	74 df                	je     f0100868 <monitor+0x9c>
f0100889:	eb 8d                	jmp    f0100818 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f010088b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100892:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100893:	85 f6                	test   %esi,%esi
f0100895:	0f 84 57 ff ff ff    	je     f01007f2 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010089b:	8b 07                	mov    (%edi),%eax
f010089d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008a4:	89 04 24             	mov    %eax,(%esp)
f01008a7:	e8 bd 08 00 00       	call   f0101169 <strcmp>
f01008ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01008b1:	85 c0                	test   %eax,%eax
f01008b3:	74 1d                	je     f01008d2 <monitor+0x106>
f01008b5:	a1 58 1b 10 f0       	mov    0xf0101b58,%eax
f01008ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 a0 08 00 00       	call   f0101169 <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	75 28                	jne    f01008f5 <monitor+0x129>
f01008cd:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01008d2:	6b d2 0c             	imul   $0xc,%edx,%edx
f01008d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01008d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008dc:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e3:	89 34 24             	mov    %esi,(%esp)
f01008e6:	ff 92 54 1b 10 f0    	call   *-0xfefe4ac(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008ec:	85 c0                	test   %eax,%eax
f01008ee:	78 1d                	js     f010090d <monitor+0x141>
f01008f0:	e9 fd fe ff ff       	jmp    f01007f2 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008f5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008fc:	c7 04 24 d8 19 10 f0 	movl   $0xf01019d8,(%esp)
f0100903:	e8 43 00 00 00       	call   f010094b <cprintf>
f0100908:	e9 e5 fe ff ff       	jmp    f01007f2 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010090d:	83 c4 5c             	add    $0x5c,%esp
f0100910:	5b                   	pop    %ebx
f0100911:	5e                   	pop    %esi
f0100912:	5f                   	pop    %edi
f0100913:	5d                   	pop    %ebp
f0100914:	c3                   	ret    
f0100915:	00 00                	add    %al,(%eax)
	...

f0100918 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100918:	55                   	push   %ebp
f0100919:	89 e5                	mov    %esp,%ebp
f010091b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010091e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100925:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100928:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010092c:	8b 45 08             	mov    0x8(%ebp),%eax
f010092f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100933:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100936:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093a:	c7 04 24 65 09 10 f0 	movl   $0xf0100965,(%esp)
f0100941:	e8 8a 01 00 00       	call   f0100ad0 <vprintfmt>
	return cnt;
}
f0100946:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100949:	c9                   	leave  
f010094a:	c3                   	ret    

f010094b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010094b:	55                   	push   %ebp
f010094c:	89 e5                	mov    %esp,%ebp
f010094e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100951:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100954:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100958:	8b 45 08             	mov    0x8(%ebp),%eax
f010095b:	89 04 24             	mov    %eax,(%esp)
f010095e:	e8 b5 ff ff ff       	call   f0100918 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100963:	c9                   	leave  
f0100964:	c3                   	ret    

f0100965 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100965:	55                   	push   %ebp
f0100966:	89 e5                	mov    %esp,%ebp
f0100968:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010096b:	8b 45 08             	mov    0x8(%ebp),%eax
f010096e:	89 04 24             	mov    %eax,(%esp)
f0100971:	e8 2a fd ff ff       	call   f01006a0 <cputchar>
	*cnt++;
}
f0100976:	c9                   	leave  
f0100977:	c3                   	ret    
	...

f0100980 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100980:	55                   	push   %ebp
f0100981:	89 e5                	mov    %esp,%ebp
f0100983:	57                   	push   %edi
f0100984:	56                   	push   %esi
f0100985:	53                   	push   %ebx
f0100986:	83 ec 4c             	sub    $0x4c,%esp
f0100989:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010098c:	89 d6                	mov    %edx,%esi
f010098e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100991:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100994:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100997:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010099a:	8b 45 10             	mov    0x10(%ebp),%eax
f010099d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01009a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01009a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01009a6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01009ab:	39 d1                	cmp    %edx,%ecx
f01009ad:	72 15                	jb     f01009c4 <printnum+0x44>
f01009af:	77 07                	ja     f01009b8 <printnum+0x38>
f01009b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01009b4:	39 d0                	cmp    %edx,%eax
f01009b6:	76 0c                	jbe    f01009c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01009b8:	83 eb 01             	sub    $0x1,%ebx
f01009bb:	85 db                	test   %ebx,%ebx
f01009bd:	8d 76 00             	lea    0x0(%esi),%esi
f01009c0:	7f 61                	jg     f0100a23 <printnum+0xa3>
f01009c2:	eb 70                	jmp    f0100a34 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01009c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01009c8:	83 eb 01             	sub    $0x1,%ebx
f01009cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01009d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f01009db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01009de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01009e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01009e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01009e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01009ef:	00 
f01009f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009f3:	89 04 24             	mov    %eax,(%esp)
f01009f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01009f9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009fd:	e8 4e 0a 00 00       	call   f0101450 <__udivdi3>
f0100a02:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100a05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100a08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a0c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a10:	89 04 24             	mov    %eax,(%esp)
f0100a13:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a17:	89 f2                	mov    %esi,%edx
f0100a19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1c:	e8 5f ff ff ff       	call   f0100980 <printnum>
f0100a21:	eb 11                	jmp    f0100a34 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100a23:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a27:	89 3c 24             	mov    %edi,(%esp)
f0100a2a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a2d:	83 eb 01             	sub    $0x1,%ebx
f0100a30:	85 db                	test   %ebx,%ebx
f0100a32:	7f ef                	jg     f0100a23 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100a34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a38:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100a3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a3f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a4a:	00 
f0100a4b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a4e:	89 14 24             	mov    %edx,(%esp)
f0100a51:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100a54:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100a58:	e8 23 0b 00 00       	call   f0101580 <__umoddi3>
f0100a5d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a61:	0f be 80 64 1b 10 f0 	movsbl -0xfefe49c(%eax),%eax
f0100a68:	89 04 24             	mov    %eax,(%esp)
f0100a6b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100a6e:	83 c4 4c             	add    $0x4c,%esp
f0100a71:	5b                   	pop    %ebx
f0100a72:	5e                   	pop    %esi
f0100a73:	5f                   	pop    %edi
f0100a74:	5d                   	pop    %ebp
f0100a75:	c3                   	ret    

f0100a76 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100a76:	55                   	push   %ebp
f0100a77:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100a79:	83 fa 01             	cmp    $0x1,%edx
f0100a7c:	7e 0f                	jle    f0100a8d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f0100a7e:	8b 10                	mov    (%eax),%edx
f0100a80:	83 c2 08             	add    $0x8,%edx
f0100a83:	89 10                	mov    %edx,(%eax)
f0100a85:	8b 42 f8             	mov    -0x8(%edx),%eax
f0100a88:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100a8b:	eb 24                	jmp    f0100ab1 <getuint+0x3b>
	else if (lflag)
f0100a8d:	85 d2                	test   %edx,%edx
f0100a8f:	74 11                	je     f0100aa2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0100a91:	8b 10                	mov    (%eax),%edx
f0100a93:	83 c2 04             	add    $0x4,%edx
f0100a96:	89 10                	mov    %edx,(%eax)
f0100a98:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100a9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100aa0:	eb 0f                	jmp    f0100ab1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0100aa2:	8b 10                	mov    (%eax),%edx
f0100aa4:	83 c2 04             	add    $0x4,%edx
f0100aa7:	89 10                	mov    %edx,(%eax)
f0100aa9:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100aac:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100ab1:	5d                   	pop    %ebp
f0100ab2:	c3                   	ret    

f0100ab3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ab3:	55                   	push   %ebp
f0100ab4:	89 e5                	mov    %esp,%ebp
f0100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ab9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100abd:	8b 10                	mov    (%eax),%edx
f0100abf:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ac2:	73 0a                	jae    f0100ace <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100ac7:	88 0a                	mov    %cl,(%edx)
f0100ac9:	83 c2 01             	add    $0x1,%edx
f0100acc:	89 10                	mov    %edx,(%eax)
}
f0100ace:	5d                   	pop    %ebp
f0100acf:	c3                   	ret    

f0100ad0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100ad0:	55                   	push   %ebp
f0100ad1:	89 e5                	mov    %esp,%ebp
f0100ad3:	57                   	push   %edi
f0100ad4:	56                   	push   %esi
f0100ad5:	53                   	push   %ebx
f0100ad6:	83 ec 5c             	sub    $0x5c,%esp
f0100ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100adc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100ae2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0100ae9:	eb 11                	jmp    f0100afc <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100aeb:	85 c0                	test   %eax,%eax
f0100aed:	0f 84 11 04 00 00    	je     f0100f04 <vprintfmt+0x434>
				return;
			putch(ch, putdat);
f0100af3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100af7:	89 04 24             	mov    %eax,(%esp)
f0100afa:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100afc:	0f b6 03             	movzbl (%ebx),%eax
f0100aff:	83 c3 01             	add    $0x1,%ebx
f0100b02:	83 f8 25             	cmp    $0x25,%eax
f0100b05:	75 e4                	jne    f0100aeb <vprintfmt+0x1b>
f0100b07:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0100b0b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0100b12:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0100b19:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100b20:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b25:	eb 06                	jmp    f0100b2d <vprintfmt+0x5d>
f0100b27:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0100b2b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b2d:	0f b6 13             	movzbl (%ebx),%edx
f0100b30:	0f b6 c2             	movzbl %dl,%eax
f0100b33:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100b36:	8d 43 01             	lea    0x1(%ebx),%eax
f0100b39:	83 ea 23             	sub    $0x23,%edx
f0100b3c:	80 fa 55             	cmp    $0x55,%dl
f0100b3f:	0f 87 a2 03 00 00    	ja     f0100ee7 <vprintfmt+0x417>
f0100b45:	0f b6 d2             	movzbl %dl,%edx
f0100b48:	ff 24 95 f4 1b 10 f0 	jmp    *-0xfefe40c(,%edx,4)
f0100b4f:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0100b53:	eb d6                	jmp    f0100b2b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100b55:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100b58:	83 ea 30             	sub    $0x30,%edx
f0100b5b:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f0100b5e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100b61:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100b64:	83 fb 09             	cmp    $0x9,%ebx
f0100b67:	77 4d                	ja     f0100bb6 <vprintfmt+0xe6>
f0100b69:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b6c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100b6f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0100b72:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100b75:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0100b79:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100b7c:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100b7f:	83 fb 09             	cmp    $0x9,%ebx
f0100b82:	76 eb                	jbe    f0100b6f <vprintfmt+0x9f>
f0100b84:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100b87:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100b8a:	eb 2a                	jmp    f0100bb6 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100b8c:	8b 55 14             	mov    0x14(%ebp),%edx
f0100b8f:	83 c2 04             	add    $0x4,%edx
f0100b92:	89 55 14             	mov    %edx,0x14(%ebp)
f0100b95:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100b98:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f0100b9b:	eb 19                	jmp    f0100bb6 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
f0100b9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ba0:	c1 fa 1f             	sar    $0x1f,%edx
f0100ba3:	f7 d2                	not    %edx
f0100ba5:	21 55 e4             	and    %edx,-0x1c(%ebp)
f0100ba8:	eb 81                	jmp    f0100b2b <vprintfmt+0x5b>
f0100baa:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0100bb1:	e9 75 ff ff ff       	jmp    f0100b2b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0100bb6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100bba:	0f 89 6b ff ff ff    	jns    f0100b2b <vprintfmt+0x5b>
f0100bc0:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100bc3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100bc6:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0100bc9:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0100bcc:	e9 5a ff ff ff       	jmp    f0100b2b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100bd1:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0100bd4:	e9 52 ff ff ff       	jmp    f0100b2b <vprintfmt+0x5b>
f0100bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100bdc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100bdf:	83 c0 04             	add    $0x4,%eax
f0100be2:	89 45 14             	mov    %eax,0x14(%ebp)
f0100be5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100be9:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100bec:	89 04 24             	mov    %eax,(%esp)
f0100bef:	ff d7                	call   *%edi
f0100bf1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0100bf4:	e9 03 ff ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100bf9:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100bfc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100bff:	83 c0 04             	add    $0x4,%eax
f0100c02:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c05:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c08:	89 c2                	mov    %eax,%edx
f0100c0a:	c1 fa 1f             	sar    $0x1f,%edx
f0100c0d:	31 d0                	xor    %edx,%eax
f0100c0f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c11:	83 f8 06             	cmp    $0x6,%eax
f0100c14:	7f 0b                	jg     f0100c21 <vprintfmt+0x151>
f0100c16:	8b 14 85 4c 1d 10 f0 	mov    -0xfefe2b4(,%eax,4),%edx
f0100c1d:	85 d2                	test   %edx,%edx
f0100c1f:	75 20                	jne    f0100c41 <vprintfmt+0x171>
				printfmt(putch, putdat, "error %d", err);
f0100c21:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c25:	c7 44 24 08 75 1b 10 	movl   $0xf0101b75,0x8(%esp)
f0100c2c:	f0 
f0100c2d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c31:	89 3c 24             	mov    %edi,(%esp)
f0100c34:	e8 53 03 00 00       	call   f0100f8c <printfmt>
f0100c39:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c3c:	e9 bb fe ff ff       	jmp    f0100afc <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0100c41:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c45:	c7 44 24 08 7e 1b 10 	movl   $0xf0101b7e,0x8(%esp)
f0100c4c:	f0 
f0100c4d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c51:	89 3c 24             	mov    %edi,(%esp)
f0100c54:	e8 33 03 00 00       	call   f0100f8c <printfmt>
f0100c59:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100c5c:	e9 9b fe ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100c61:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100c64:	89 c3                	mov    %eax,%ebx
f0100c66:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100c69:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100c6c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100c6f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c72:	83 c0 04             	add    $0x4,%eax
f0100c75:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c78:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c7b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c7e:	85 c0                	test   %eax,%eax
f0100c80:	75 07                	jne    f0100c89 <vprintfmt+0x1b9>
f0100c82:	c7 45 c4 81 1b 10 f0 	movl   $0xf0101b81,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0100c89:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f0100c8d:	7e 06                	jle    f0100c95 <vprintfmt+0x1c5>
f0100c8f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0100c93:	75 13                	jne    f0100ca8 <vprintfmt+0x1d8>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100c95:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100c98:	0f be 02             	movsbl (%edx),%eax
f0100c9b:	85 c0                	test   %eax,%eax
f0100c9d:	0f 85 99 00 00 00    	jne    f0100d3c <vprintfmt+0x26c>
f0100ca3:	e9 86 00 00 00       	jmp    f0100d2e <vprintfmt+0x25e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ca8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100caf:	89 0c 24             	mov    %ecx,(%esp)
f0100cb2:	e8 f4 03 00 00       	call   f01010ab <strnlen>
f0100cb7:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100cba:	29 c2                	sub    %eax,%edx
f0100cbc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100cbf:	85 d2                	test   %edx,%edx
f0100cc1:	7e d2                	jle    f0100c95 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0100cc3:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
f0100cc7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100cca:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0100ccd:	89 d3                	mov    %edx,%ebx
f0100ccf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cd6:	89 04 24             	mov    %eax,(%esp)
f0100cd9:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100cdb:	83 eb 01             	sub    $0x1,%ebx
f0100cde:	85 db                	test   %ebx,%ebx
f0100ce0:	7f ed                	jg     f0100ccf <vprintfmt+0x1ff>
f0100ce2:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0100ce5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100cec:	eb a7                	jmp    f0100c95 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100cee:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100cf2:	74 18                	je     f0100d0c <vprintfmt+0x23c>
f0100cf4:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100cf7:	83 fa 5e             	cmp    $0x5e,%edx
f0100cfa:	76 10                	jbe    f0100d0c <vprintfmt+0x23c>
					putch('?', putdat);
f0100cfc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d00:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100d07:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d0a:	eb 0a                	jmp    f0100d16 <vprintfmt+0x246>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0100d0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d10:	89 04 24             	mov    %eax,(%esp)
f0100d13:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d16:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100d1a:	0f be 03             	movsbl (%ebx),%eax
f0100d1d:	85 c0                	test   %eax,%eax
f0100d1f:	74 05                	je     f0100d26 <vprintfmt+0x256>
f0100d21:	83 c3 01             	add    $0x1,%ebx
f0100d24:	eb 29                	jmp    f0100d4f <vprintfmt+0x27f>
f0100d26:	89 fe                	mov    %edi,%esi
f0100d28:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100d2b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100d32:	7f 2e                	jg     f0100d62 <vprintfmt+0x292>
f0100d34:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100d37:	e9 c0 fd ff ff       	jmp    f0100afc <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d3c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100d3f:	83 c2 01             	add    $0x1,%edx
f0100d42:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0100d45:	89 f7                	mov    %esi,%edi
f0100d47:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100d4a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100d4d:	89 d3                	mov    %edx,%ebx
f0100d4f:	85 f6                	test   %esi,%esi
f0100d51:	78 9b                	js     f0100cee <vprintfmt+0x21e>
f0100d53:	83 ee 01             	sub    $0x1,%esi
f0100d56:	79 96                	jns    f0100cee <vprintfmt+0x21e>
f0100d58:	89 fe                	mov    %edi,%esi
f0100d5a:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100d5d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100d60:	eb cc                	jmp    f0100d2e <vprintfmt+0x25e>
f0100d62:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100d65:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100d68:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d6c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100d73:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d75:	83 eb 01             	sub    $0x1,%ebx
f0100d78:	85 db                	test   %ebx,%ebx
f0100d7a:	7f ec                	jg     f0100d68 <vprintfmt+0x298>
f0100d7c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100d7f:	e9 78 fd ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100d84:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100d87:	83 f9 01             	cmp    $0x1,%ecx
f0100d8a:	7e 17                	jle    f0100da3 <vprintfmt+0x2d3>
		return va_arg(*ap, long long);
f0100d8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d8f:	83 c0 08             	add    $0x8,%eax
f0100d92:	89 45 14             	mov    %eax,0x14(%ebp)
f0100d95:	8b 50 f8             	mov    -0x8(%eax),%edx
f0100d98:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100d9b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100d9e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100da1:	eb 34                	jmp    f0100dd7 <vprintfmt+0x307>
	else if (lflag)
f0100da3:	85 c9                	test   %ecx,%ecx
f0100da5:	74 19                	je     f0100dc0 <vprintfmt+0x2f0>
		return va_arg(*ap, long);
f0100da7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100daa:	83 c0 04             	add    $0x4,%eax
f0100dad:	89 45 14             	mov    %eax,0x14(%ebp)
f0100db0:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100db3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100db6:	89 c1                	mov    %eax,%ecx
f0100db8:	c1 f9 1f             	sar    $0x1f,%ecx
f0100dbb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100dbe:	eb 17                	jmp    f0100dd7 <vprintfmt+0x307>
	else
		return va_arg(*ap, int);
f0100dc0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dc3:	83 c0 04             	add    $0x4,%eax
f0100dc6:	89 45 14             	mov    %eax,0x14(%ebp)
f0100dc9:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100dcc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dcf:	89 c2                	mov    %eax,%edx
f0100dd1:	c1 fa 1f             	sar    $0x1f,%edx
f0100dd4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100dd7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100dda:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ddd:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100de2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100de6:	0f 89 b9 00 00 00    	jns    f0100ea5 <vprintfmt+0x3d5>
				putch('-', putdat);
f0100dec:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100df0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100df7:	ff d7                	call   *%edi
				num = -(long long) num;
f0100df9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100dfc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100dff:	f7 d9                	neg    %ecx
f0100e01:	83 d3 00             	adc    $0x0,%ebx
f0100e04:	f7 db                	neg    %ebx
f0100e06:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100e0b:	e9 95 00 00 00       	jmp    f0100ea5 <vprintfmt+0x3d5>
f0100e10:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100e13:	89 ca                	mov    %ecx,%edx
f0100e15:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e18:	e8 59 fc ff ff       	call   f0100a76 <getuint>
f0100e1d:	89 c1                	mov    %eax,%ecx
f0100e1f:	89 d3                	mov    %edx,%ebx
f0100e21:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0100e26:	eb 7d                	jmp    f0100ea5 <vprintfmt+0x3d5>
f0100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0100e2b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e2f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100e36:	ff d7                	call   *%edi
			putch('X', putdat);
f0100e38:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e3c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100e43:	ff d7                	call   *%edi
			putch('X', putdat);
f0100e45:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e49:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100e50:	ff d7                	call   *%edi
f0100e52:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0100e55:	e9 a2 fc ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100e5a:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0100e5d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e61:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100e68:	ff d7                	call   *%edi
			putch('x', putdat);
f0100e6a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e6e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100e75:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100e77:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e7a:	83 c0 04             	add    $0x4,%eax
f0100e7d:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100e80:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100e83:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e88:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0100e8d:	eb 16                	jmp    f0100ea5 <vprintfmt+0x3d5>
f0100e8f:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100e92:	89 ca                	mov    %ecx,%edx
f0100e94:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e97:	e8 da fb ff ff       	call   f0100a76 <getuint>
f0100e9c:	89 c1                	mov    %eax,%ecx
f0100e9e:	89 d3                	mov    %edx,%ebx
f0100ea0:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100ea5:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0100ea9:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100ead:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100eb0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100eb4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100eb8:	89 0c 24             	mov    %ecx,(%esp)
f0100ebb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ebf:	89 f2                	mov    %esi,%edx
f0100ec1:	89 f8                	mov    %edi,%eax
f0100ec3:	e8 b8 fa ff ff       	call   f0100980 <printnum>
f0100ec8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0100ecb:	e9 2c fc ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100ed0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100ed3:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100ed6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100eda:	89 14 24             	mov    %edx,(%esp)
f0100edd:	ff d7                	call   *%edi
f0100edf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0100ee2:	e9 15 fc ff ff       	jmp    f0100afc <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100ee7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100eeb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100ef2:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100ef4:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100ef7:	80 38 25             	cmpb   $0x25,(%eax)
f0100efa:	0f 84 fc fb ff ff    	je     f0100afc <vprintfmt+0x2c>
f0100f00:	89 c3                	mov    %eax,%ebx
f0100f02:	eb f0                	jmp    f0100ef4 <vprintfmt+0x424>
				/* do nothing */;
			break;
		}
	}
}
f0100f04:	83 c4 5c             	add    $0x5c,%esp
f0100f07:	5b                   	pop    %ebx
f0100f08:	5e                   	pop    %esi
f0100f09:	5f                   	pop    %edi
f0100f0a:	5d                   	pop    %ebp
f0100f0b:	c3                   	ret    

f0100f0c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100f0c:	55                   	push   %ebp
f0100f0d:	89 e5                	mov    %esp,%ebp
f0100f0f:	83 ec 28             	sub    $0x28,%esp
f0100f12:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f15:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0100f18:	85 c0                	test   %eax,%eax
f0100f1a:	74 04                	je     f0100f20 <vsnprintf+0x14>
f0100f1c:	85 d2                	test   %edx,%edx
f0100f1e:	7f 07                	jg     f0100f27 <vsnprintf+0x1b>
f0100f20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100f25:	eb 3b                	jmp    f0100f62 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100f27:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100f2a:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0100f2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100f38:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f3f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f42:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f46:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100f49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f4d:	c7 04 24 b3 0a 10 f0 	movl   $0xf0100ab3,(%esp)
f0100f54:	e8 77 fb ff ff       	call   f0100ad0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100f59:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f5c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100f62:	c9                   	leave  
f0100f63:	c3                   	ret    

f0100f64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100f64:	55                   	push   %ebp
f0100f65:	89 e5                	mov    %esp,%ebp
f0100f67:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100f6a:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f71:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f74:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f82:	89 04 24             	mov    %eax,(%esp)
f0100f85:	e8 82 ff ff ff       	call   f0100f0c <vsnprintf>
	va_end(ap);

	return rc;
}
f0100f8a:	c9                   	leave  
f0100f8b:	c3                   	ret    

f0100f8c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100f8c:	55                   	push   %ebp
f0100f8d:	89 e5                	mov    %esp,%ebp
f0100f8f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100f92:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f95:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f99:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f9c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100faa:	89 04 24             	mov    %eax,(%esp)
f0100fad:	e8 1e fb ff ff       	call   f0100ad0 <vprintfmt>
	va_end(ap);
}
f0100fb2:	c9                   	leave  
f0100fb3:	c3                   	ret    
	...

f0100fc0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0100fc0:	55                   	push   %ebp
f0100fc1:	89 e5                	mov    %esp,%ebp
f0100fc3:	57                   	push   %edi
f0100fc4:	56                   	push   %esi
f0100fc5:	53                   	push   %ebx
f0100fc6:	83 ec 1c             	sub    $0x1c,%esp
f0100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0100fcc:	85 c0                	test   %eax,%eax
f0100fce:	74 10                	je     f0100fe0 <readline+0x20>
		cprintf("%s", prompt);
f0100fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fd4:	c7 04 24 7e 1b 10 f0 	movl   $0xf0101b7e,(%esp)
f0100fdb:	e8 6b f9 ff ff       	call   f010094b <cprintf>

	i = 0;
	echoing = iscons(0);
f0100fe0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100fe7:	e8 9b f3 ff ff       	call   f0100387 <iscons>
f0100fec:	89 c7                	mov    %eax,%edi
f0100fee:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0100ff3:	e8 7e f3 ff ff       	call   f0100376 <getchar>
f0100ff8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0100ffa:	85 c0                	test   %eax,%eax
f0100ffc:	79 17                	jns    f0101015 <readline+0x55>
			cprintf("read error: %e\n", c);
f0100ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101002:	c7 04 24 68 1d 10 f0 	movl   $0xf0101d68,(%esp)
f0101009:	e8 3d f9 ff ff       	call   f010094b <cprintf>
f010100e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101013:	eb 65                	jmp    f010107a <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101015:	83 f8 1f             	cmp    $0x1f,%eax
f0101018:	7e 1f                	jle    f0101039 <readline+0x79>
f010101a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101020:	7f 17                	jg     f0101039 <readline+0x79>
			if (echoing)
f0101022:	85 ff                	test   %edi,%edi
f0101024:	74 08                	je     f010102e <readline+0x6e>
				cputchar(c);
f0101026:	89 04 24             	mov    %eax,(%esp)
f0101029:	e8 72 f6 ff ff       	call   f01006a0 <cputchar>
			buf[i++] = c;
f010102e:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0101034:	83 c6 01             	add    $0x1,%esi
f0101037:	eb ba                	jmp    f0100ff3 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101039:	83 fb 08             	cmp    $0x8,%ebx
f010103c:	75 15                	jne    f0101053 <readline+0x93>
f010103e:	85 f6                	test   %esi,%esi
f0101040:	7e 11                	jle    f0101053 <readline+0x93>
			if (echoing)
f0101042:	85 ff                	test   %edi,%edi
f0101044:	74 08                	je     f010104e <readline+0x8e>
				cputchar(c);
f0101046:	89 1c 24             	mov    %ebx,(%esp)
f0101049:	e8 52 f6 ff ff       	call   f01006a0 <cputchar>
			i--;
f010104e:	83 ee 01             	sub    $0x1,%esi
f0101051:	eb a0                	jmp    f0100ff3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101053:	83 fb 0a             	cmp    $0xa,%ebx
f0101056:	74 0a                	je     f0101062 <readline+0xa2>
f0101058:	83 fb 0d             	cmp    $0xd,%ebx
f010105b:	90                   	nop
f010105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101060:	75 91                	jne    f0100ff3 <readline+0x33>
			if (echoing)
f0101062:	85 ff                	test   %edi,%edi
f0101064:	74 08                	je     f010106e <readline+0xae>
				cputchar(c);
f0101066:	89 1c 24             	mov    %ebx,(%esp)
f0101069:	e8 32 f6 ff ff       	call   f01006a0 <cputchar>
			buf[i] = 0;
f010106e:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
f0101075:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
			return buf;
		}
	}
}
f010107a:	83 c4 1c             	add    $0x1c,%esp
f010107d:	5b                   	pop    %ebx
f010107e:	5e                   	pop    %esi
f010107f:	5f                   	pop    %edi
f0101080:	5d                   	pop    %ebp
f0101081:	c3                   	ret    
	...

f0101090 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0101090:	55                   	push   %ebp
f0101091:	89 e5                	mov    %esp,%ebp
f0101093:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101096:	b8 00 00 00 00       	mov    $0x0,%eax
f010109b:	80 3a 00             	cmpb   $0x0,(%edx)
f010109e:	74 09                	je     f01010a9 <strlen+0x19>
		n++;
f01010a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01010a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01010a7:	75 f7                	jne    f01010a0 <strlen+0x10>
		n++;
	return n;
}
f01010a9:	5d                   	pop    %ebp
f01010aa:	c3                   	ret    

f01010ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01010ab:	55                   	push   %ebp
f01010ac:	89 e5                	mov    %esp,%ebp
f01010ae:	53                   	push   %ebx
f01010af:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010b5:	85 c9                	test   %ecx,%ecx
f01010b7:	74 19                	je     f01010d2 <strnlen+0x27>
f01010b9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010bc:	74 14                	je     f01010d2 <strnlen+0x27>
f01010be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01010c3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010c6:	39 c8                	cmp    %ecx,%eax
f01010c8:	74 0d                	je     f01010d7 <strnlen+0x2c>
f01010ca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01010ce:	75 f3                	jne    f01010c3 <strnlen+0x18>
f01010d0:	eb 05                	jmp    f01010d7 <strnlen+0x2c>
f01010d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01010d7:	5b                   	pop    %ebx
f01010d8:	5d                   	pop    %ebp
f01010d9:	c3                   	ret    

f01010da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01010da:	55                   	push   %ebp
f01010db:	89 e5                	mov    %esp,%ebp
f01010dd:	53                   	push   %ebx
f01010de:	8b 45 08             	mov    0x8(%ebp),%eax
f01010e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010e4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01010e9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01010ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01010f0:	83 c2 01             	add    $0x1,%edx
f01010f3:	84 c9                	test   %cl,%cl
f01010f5:	75 f2                	jne    f01010e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01010f7:	5b                   	pop    %ebx
f01010f8:	5d                   	pop    %ebp
f01010f9:	c3                   	ret    

f01010fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01010fa:	55                   	push   %ebp
f01010fb:	89 e5                	mov    %esp,%ebp
f01010fd:	56                   	push   %esi
f01010fe:	53                   	push   %ebx
f01010ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101102:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101105:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101108:	85 f6                	test   %esi,%esi
f010110a:	74 18                	je     f0101124 <strncpy+0x2a>
f010110c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101111:	0f b6 1a             	movzbl (%edx),%ebx
f0101114:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101117:	80 3a 01             	cmpb   $0x1,(%edx)
f010111a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010111d:	83 c1 01             	add    $0x1,%ecx
f0101120:	39 ce                	cmp    %ecx,%esi
f0101122:	77 ed                	ja     f0101111 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101124:	5b                   	pop    %ebx
f0101125:	5e                   	pop    %esi
f0101126:	5d                   	pop    %ebp
f0101127:	c3                   	ret    

f0101128 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101128:	55                   	push   %ebp
f0101129:	89 e5                	mov    %esp,%ebp
f010112b:	56                   	push   %esi
f010112c:	53                   	push   %ebx
f010112d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101130:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101133:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101136:	89 f0                	mov    %esi,%eax
f0101138:	85 c9                	test   %ecx,%ecx
f010113a:	74 27                	je     f0101163 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f010113c:	83 e9 01             	sub    $0x1,%ecx
f010113f:	74 1d                	je     f010115e <strlcpy+0x36>
f0101141:	0f b6 1a             	movzbl (%edx),%ebx
f0101144:	84 db                	test   %bl,%bl
f0101146:	74 16                	je     f010115e <strlcpy+0x36>
			*dst++ = *src++;
f0101148:	88 18                	mov    %bl,(%eax)
f010114a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010114d:	83 e9 01             	sub    $0x1,%ecx
f0101150:	74 0e                	je     f0101160 <strlcpy+0x38>
			*dst++ = *src++;
f0101152:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101155:	0f b6 1a             	movzbl (%edx),%ebx
f0101158:	84 db                	test   %bl,%bl
f010115a:	75 ec                	jne    f0101148 <strlcpy+0x20>
f010115c:	eb 02                	jmp    f0101160 <strlcpy+0x38>
f010115e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101160:	c6 00 00             	movb   $0x0,(%eax)
f0101163:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101165:	5b                   	pop    %ebx
f0101166:	5e                   	pop    %esi
f0101167:	5d                   	pop    %ebp
f0101168:	c3                   	ret    

f0101169 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101169:	55                   	push   %ebp
f010116a:	89 e5                	mov    %esp,%ebp
f010116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010116f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101172:	0f b6 01             	movzbl (%ecx),%eax
f0101175:	84 c0                	test   %al,%al
f0101177:	74 15                	je     f010118e <strcmp+0x25>
f0101179:	3a 02                	cmp    (%edx),%al
f010117b:	75 11                	jne    f010118e <strcmp+0x25>
		p++, q++;
f010117d:	83 c1 01             	add    $0x1,%ecx
f0101180:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101183:	0f b6 01             	movzbl (%ecx),%eax
f0101186:	84 c0                	test   %al,%al
f0101188:	74 04                	je     f010118e <strcmp+0x25>
f010118a:	3a 02                	cmp    (%edx),%al
f010118c:	74 ef                	je     f010117d <strcmp+0x14>
f010118e:	0f b6 c0             	movzbl %al,%eax
f0101191:	0f b6 12             	movzbl (%edx),%edx
f0101194:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101196:	5d                   	pop    %ebp
f0101197:	c3                   	ret    

f0101198 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101198:	55                   	push   %ebp
f0101199:	89 e5                	mov    %esp,%ebp
f010119b:	53                   	push   %ebx
f010119c:	8b 55 08             	mov    0x8(%ebp),%edx
f010119f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01011a2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01011a5:	85 c0                	test   %eax,%eax
f01011a7:	74 23                	je     f01011cc <strncmp+0x34>
f01011a9:	0f b6 1a             	movzbl (%edx),%ebx
f01011ac:	84 db                	test   %bl,%bl
f01011ae:	74 24                	je     f01011d4 <strncmp+0x3c>
f01011b0:	3a 19                	cmp    (%ecx),%bl
f01011b2:	75 20                	jne    f01011d4 <strncmp+0x3c>
f01011b4:	83 e8 01             	sub    $0x1,%eax
f01011b7:	74 13                	je     f01011cc <strncmp+0x34>
		n--, p++, q++;
f01011b9:	83 c2 01             	add    $0x1,%edx
f01011bc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01011bf:	0f b6 1a             	movzbl (%edx),%ebx
f01011c2:	84 db                	test   %bl,%bl
f01011c4:	74 0e                	je     f01011d4 <strncmp+0x3c>
f01011c6:	3a 19                	cmp    (%ecx),%bl
f01011c8:	74 ea                	je     f01011b4 <strncmp+0x1c>
f01011ca:	eb 08                	jmp    f01011d4 <strncmp+0x3c>
f01011cc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01011d1:	5b                   	pop    %ebx
f01011d2:	5d                   	pop    %ebp
f01011d3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01011d4:	0f b6 02             	movzbl (%edx),%eax
f01011d7:	0f b6 11             	movzbl (%ecx),%edx
f01011da:	29 d0                	sub    %edx,%eax
f01011dc:	eb f3                	jmp    f01011d1 <strncmp+0x39>

f01011de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01011de:	55                   	push   %ebp
f01011df:	89 e5                	mov    %esp,%ebp
f01011e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01011e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01011e8:	0f b6 10             	movzbl (%eax),%edx
f01011eb:	84 d2                	test   %dl,%dl
f01011ed:	74 15                	je     f0101204 <strchr+0x26>
		if (*s == c)
f01011ef:	38 ca                	cmp    %cl,%dl
f01011f1:	75 07                	jne    f01011fa <strchr+0x1c>
f01011f3:	eb 14                	jmp    f0101209 <strchr+0x2b>
f01011f5:	38 ca                	cmp    %cl,%dl
f01011f7:	90                   	nop
f01011f8:	74 0f                	je     f0101209 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01011fa:	83 c0 01             	add    $0x1,%eax
f01011fd:	0f b6 10             	movzbl (%eax),%edx
f0101200:	84 d2                	test   %dl,%dl
f0101202:	75 f1                	jne    f01011f5 <strchr+0x17>
f0101204:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101209:	5d                   	pop    %ebp
f010120a:	c3                   	ret    

f010120b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010120b:	55                   	push   %ebp
f010120c:	89 e5                	mov    %esp,%ebp
f010120e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101211:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101215:	0f b6 10             	movzbl (%eax),%edx
f0101218:	84 d2                	test   %dl,%dl
f010121a:	74 18                	je     f0101234 <strfind+0x29>
		if (*s == c)
f010121c:	38 ca                	cmp    %cl,%dl
f010121e:	75 0a                	jne    f010122a <strfind+0x1f>
f0101220:	eb 12                	jmp    f0101234 <strfind+0x29>
f0101222:	38 ca                	cmp    %cl,%dl
f0101224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101228:	74 0a                	je     f0101234 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010122a:	83 c0 01             	add    $0x1,%eax
f010122d:	0f b6 10             	movzbl (%eax),%edx
f0101230:	84 d2                	test   %dl,%dl
f0101232:	75 ee                	jne    f0101222 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101234:	5d                   	pop    %ebp
f0101235:	c3                   	ret    

f0101236 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101236:	55                   	push   %ebp
f0101237:	89 e5                	mov    %esp,%ebp
f0101239:	53                   	push   %ebx
f010123a:	8b 45 08             	mov    0x8(%ebp),%eax
f010123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101240:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101243:	89 da                	mov    %ebx,%edx
f0101245:	83 ea 01             	sub    $0x1,%edx
f0101248:	78 0e                	js     f0101258 <memset+0x22>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f010124a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f010124c:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f010124f:	88 0a                	mov    %cl,(%edx)
f0101251:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101254:	39 da                	cmp    %ebx,%edx
f0101256:	75 f7                	jne    f010124f <memset+0x19>
		*p++ = c;

	return v;
}
f0101258:	5b                   	pop    %ebx
f0101259:	5d                   	pop    %ebp
f010125a:	c3                   	ret    

f010125b <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f010125b:	55                   	push   %ebp
f010125c:	89 e5                	mov    %esp,%ebp
f010125e:	56                   	push   %esi
f010125f:	53                   	push   %ebx
f0101260:	8b 45 08             	mov    0x8(%ebp),%eax
f0101263:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101266:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0101269:	85 db                	test   %ebx,%ebx
f010126b:	74 13                	je     f0101280 <memcpy+0x25>
f010126d:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f0101272:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101276:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101279:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f010127c:	39 da                	cmp    %ebx,%edx
f010127e:	75 f2                	jne    f0101272 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f0101280:	5b                   	pop    %ebx
f0101281:	5e                   	pop    %esi
f0101282:	5d                   	pop    %ebp
f0101283:	c3                   	ret    

f0101284 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101284:	55                   	push   %ebp
f0101285:	89 e5                	mov    %esp,%ebp
f0101287:	57                   	push   %edi
f0101288:	56                   	push   %esi
f0101289:	53                   	push   %ebx
f010128a:	8b 45 08             	mov    0x8(%ebp),%eax
f010128d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101290:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f0101293:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f0101295:	39 c6                	cmp    %eax,%esi
f0101297:	72 0b                	jb     f01012a4 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f0101299:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f010129e:	85 db                	test   %ebx,%ebx
f01012a0:	75 2d                	jne    f01012cf <memmove+0x4b>
f01012a2:	eb 39                	jmp    f01012dd <memmove+0x59>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01012a4:	01 df                	add    %ebx,%edi
f01012a6:	39 f8                	cmp    %edi,%eax
f01012a8:	73 ef                	jae    f0101299 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f01012aa:	85 db                	test   %ebx,%ebx
f01012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01012b0:	74 2b                	je     f01012dd <memmove+0x59>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f01012b2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f01012b5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f01012ba:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f01012bf:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f01012c3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f01012c6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f01012c9:	85 c9                	test   %ecx,%ecx
f01012cb:	75 ed                	jne    f01012ba <memmove+0x36>
f01012cd:	eb 0e                	jmp    f01012dd <memmove+0x59>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f01012cf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01012d3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012d6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f01012d9:	39 d3                	cmp    %edx,%ebx
f01012db:	75 f2                	jne    f01012cf <memmove+0x4b>
			*d++ = *s++;

	return dst;
}
f01012dd:	5b                   	pop    %ebx
f01012de:	5e                   	pop    %esi
f01012df:	5f                   	pop    %edi
f01012e0:	5d                   	pop    %ebp
f01012e1:	c3                   	ret    

f01012e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01012e2:	55                   	push   %ebp
f01012e3:	89 e5                	mov    %esp,%ebp
f01012e5:	57                   	push   %edi
f01012e6:	56                   	push   %esi
f01012e7:	53                   	push   %ebx
f01012e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01012eb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01012ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01012f1:	85 c9                	test   %ecx,%ecx
f01012f3:	74 36                	je     f010132b <memcmp+0x49>
		if (*s1 != *s2)
f01012f5:	0f b6 06             	movzbl (%esi),%eax
f01012f8:	0f b6 1f             	movzbl (%edi),%ebx
f01012fb:	38 d8                	cmp    %bl,%al
f01012fd:	74 20                	je     f010131f <memcmp+0x3d>
f01012ff:	eb 14                	jmp    f0101315 <memcmp+0x33>
f0101301:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101306:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010130b:	83 c2 01             	add    $0x1,%edx
f010130e:	83 e9 01             	sub    $0x1,%ecx
f0101311:	38 d8                	cmp    %bl,%al
f0101313:	74 12                	je     f0101327 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101315:	0f b6 c0             	movzbl %al,%eax
f0101318:	0f b6 db             	movzbl %bl,%ebx
f010131b:	29 d8                	sub    %ebx,%eax
f010131d:	eb 11                	jmp    f0101330 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010131f:	83 e9 01             	sub    $0x1,%ecx
f0101322:	ba 00 00 00 00       	mov    $0x0,%edx
f0101327:	85 c9                	test   %ecx,%ecx
f0101329:	75 d6                	jne    f0101301 <memcmp+0x1f>
f010132b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101330:	5b                   	pop    %ebx
f0101331:	5e                   	pop    %esi
f0101332:	5f                   	pop    %edi
f0101333:	5d                   	pop    %ebp
f0101334:	c3                   	ret    

f0101335 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101335:	55                   	push   %ebp
f0101336:	89 e5                	mov    %esp,%ebp
f0101338:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010133b:	89 c2                	mov    %eax,%edx
f010133d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101340:	39 d0                	cmp    %edx,%eax
f0101342:	73 15                	jae    f0101359 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101344:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101348:	38 08                	cmp    %cl,(%eax)
f010134a:	75 06                	jne    f0101352 <memfind+0x1d>
f010134c:	eb 0b                	jmp    f0101359 <memfind+0x24>
f010134e:	38 08                	cmp    %cl,(%eax)
f0101350:	74 07                	je     f0101359 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101352:	83 c0 01             	add    $0x1,%eax
f0101355:	39 c2                	cmp    %eax,%edx
f0101357:	77 f5                	ja     f010134e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101359:	5d                   	pop    %ebp
f010135a:	c3                   	ret    

f010135b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010135b:	55                   	push   %ebp
f010135c:	89 e5                	mov    %esp,%ebp
f010135e:	57                   	push   %edi
f010135f:	56                   	push   %esi
f0101360:	53                   	push   %ebx
f0101361:	83 ec 04             	sub    $0x4,%esp
f0101364:	8b 55 08             	mov    0x8(%ebp),%edx
f0101367:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010136a:	0f b6 02             	movzbl (%edx),%eax
f010136d:	3c 20                	cmp    $0x20,%al
f010136f:	74 04                	je     f0101375 <strtol+0x1a>
f0101371:	3c 09                	cmp    $0x9,%al
f0101373:	75 0e                	jne    f0101383 <strtol+0x28>
		s++;
f0101375:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101378:	0f b6 02             	movzbl (%edx),%eax
f010137b:	3c 20                	cmp    $0x20,%al
f010137d:	74 f6                	je     f0101375 <strtol+0x1a>
f010137f:	3c 09                	cmp    $0x9,%al
f0101381:	74 f2                	je     f0101375 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101383:	3c 2b                	cmp    $0x2b,%al
f0101385:	75 0c                	jne    f0101393 <strtol+0x38>
		s++;
f0101387:	83 c2 01             	add    $0x1,%edx
f010138a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101391:	eb 15                	jmp    f01013a8 <strtol+0x4d>
	else if (*s == '-')
f0101393:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010139a:	3c 2d                	cmp    $0x2d,%al
f010139c:	75 0a                	jne    f01013a8 <strtol+0x4d>
		s++, neg = 1;
f010139e:	83 c2 01             	add    $0x1,%edx
f01013a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013a8:	85 db                	test   %ebx,%ebx
f01013aa:	0f 94 c0             	sete   %al
f01013ad:	74 05                	je     f01013b4 <strtol+0x59>
f01013af:	83 fb 10             	cmp    $0x10,%ebx
f01013b2:	75 18                	jne    f01013cc <strtol+0x71>
f01013b4:	80 3a 30             	cmpb   $0x30,(%edx)
f01013b7:	75 13                	jne    f01013cc <strtol+0x71>
f01013b9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01013bd:	8d 76 00             	lea    0x0(%esi),%esi
f01013c0:	75 0a                	jne    f01013cc <strtol+0x71>
		s += 2, base = 16;
f01013c2:	83 c2 02             	add    $0x2,%edx
f01013c5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013ca:	eb 15                	jmp    f01013e1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01013cc:	84 c0                	test   %al,%al
f01013ce:	66 90                	xchg   %ax,%ax
f01013d0:	74 0f                	je     f01013e1 <strtol+0x86>
f01013d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01013d7:	80 3a 30             	cmpb   $0x30,(%edx)
f01013da:	75 05                	jne    f01013e1 <strtol+0x86>
		s++, base = 8;
f01013dc:	83 c2 01             	add    $0x1,%edx
f01013df:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01013e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01013e6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01013e8:	0f b6 0a             	movzbl (%edx),%ecx
f01013eb:	89 cf                	mov    %ecx,%edi
f01013ed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01013f0:	80 fb 09             	cmp    $0x9,%bl
f01013f3:	77 08                	ja     f01013fd <strtol+0xa2>
			dig = *s - '0';
f01013f5:	0f be c9             	movsbl %cl,%ecx
f01013f8:	83 e9 30             	sub    $0x30,%ecx
f01013fb:	eb 1e                	jmp    f010141b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f01013fd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101400:	80 fb 19             	cmp    $0x19,%bl
f0101403:	77 08                	ja     f010140d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101405:	0f be c9             	movsbl %cl,%ecx
f0101408:	83 e9 57             	sub    $0x57,%ecx
f010140b:	eb 0e                	jmp    f010141b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010140d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101410:	80 fb 19             	cmp    $0x19,%bl
f0101413:	77 15                	ja     f010142a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101415:	0f be c9             	movsbl %cl,%ecx
f0101418:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010141b:	39 f1                	cmp    %esi,%ecx
f010141d:	7d 0b                	jge    f010142a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010141f:	83 c2 01             	add    $0x1,%edx
f0101422:	0f af c6             	imul   %esi,%eax
f0101425:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101428:	eb be                	jmp    f01013e8 <strtol+0x8d>
f010142a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010142c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101430:	74 05                	je     f0101437 <strtol+0xdc>
		*endptr = (char *) s;
f0101432:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101435:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101437:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010143b:	74 04                	je     f0101441 <strtol+0xe6>
f010143d:	89 c8                	mov    %ecx,%eax
f010143f:	f7 d8                	neg    %eax
}
f0101441:	83 c4 04             	add    $0x4,%esp
f0101444:	5b                   	pop    %ebx
f0101445:	5e                   	pop    %esi
f0101446:	5f                   	pop    %edi
f0101447:	5d                   	pop    %ebp
f0101448:	c3                   	ret    
f0101449:	00 00                	add    %al,(%eax)
f010144b:	00 00                	add    %al,(%eax)
f010144d:	00 00                	add    %al,(%eax)
	...

f0101450 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0101450:	55                   	push   %ebp
f0101451:	89 e5                	mov    %esp,%ebp
f0101453:	57                   	push   %edi
f0101454:	56                   	push   %esi
f0101455:	83 ec 10             	sub    $0x10,%esp
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
f0101458:	8b 45 14             	mov    0x14(%ebp),%eax
  n0 = nn.s.low;
f010145b:	8b 55 08             	mov    0x8(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
f010145e:	8b 75 10             	mov    0x10(%ebp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
f0101461:	8b 7d 0c             	mov    0xc(%ebp),%edi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101464:	85 c0                	test   %eax,%eax
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0101466:	89 55 f0             	mov    %edx,-0x10(%ebp)
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101469:	75 35                	jne    f01014a0 <__udivdi3+0x50>
    {
      if (d0 > n1)
f010146b:	39 fe                	cmp    %edi,%esi
f010146d:	77 61                	ja     f01014d0 <__udivdi3+0x80>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010146f:	85 f6                	test   %esi,%esi
f0101471:	75 0b                	jne    f010147e <__udivdi3+0x2e>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101473:	b8 01 00 00 00       	mov    $0x1,%eax
f0101478:	31 d2                	xor    %edx,%edx
f010147a:	f7 f6                	div    %esi
f010147c:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010147e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101481:	31 d2                	xor    %edx,%edx
f0101483:	89 f8                	mov    %edi,%eax
f0101485:	f7 f6                	div    %esi
f0101487:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101489:	89 c8                	mov    %ecx,%eax
f010148b:	f7 f6                	div    %esi
f010148d:	89 c1                	mov    %eax,%ecx
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010148f:	89 fa                	mov    %edi,%edx
f0101491:	89 c8                	mov    %ecx,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	5e                   	pop    %esi
f0101497:	5f                   	pop    %edi
f0101498:	5d                   	pop    %ebp
f0101499:	c3                   	ret    
f010149a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01014a0:	39 f8                	cmp    %edi,%eax
f01014a2:	77 1c                	ja     f01014c0 <__udivdi3+0x70>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01014a4:	0f bd d0             	bsr    %eax,%edx
	  if (bm == 0)
f01014a7:	83 f2 1f             	xor    $0x1f,%edx
f01014aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01014ad:	75 39                	jne    f01014e8 <__udivdi3+0x98>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01014af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01014b2:	0f 86 a0 00 00 00    	jbe    f0101558 <__udivdi3+0x108>
f01014b8:	39 f8                	cmp    %edi,%eax
f01014ba:	0f 82 98 00 00 00    	jb     f0101558 <__udivdi3+0x108>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01014c0:	31 ff                	xor    %edi,%edi
f01014c2:	31 c9                	xor    %ecx,%ecx
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01014c4:	89 c8                	mov    %ecx,%eax
f01014c6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01014c8:	83 c4 10             	add    $0x10,%esp
f01014cb:	5e                   	pop    %esi
f01014cc:	5f                   	pop    %edi
f01014cd:	5d                   	pop    %ebp
f01014ce:	c3                   	ret    
f01014cf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01014d0:	89 d1                	mov    %edx,%ecx
f01014d2:	89 fa                	mov    %edi,%edx
f01014d4:	89 c8                	mov    %ecx,%eax
f01014d6:	31 ff                	xor    %edi,%edi
f01014d8:	f7 f6                	div    %esi
f01014da:	89 c1                	mov    %eax,%ecx
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01014dc:	89 fa                	mov    %edi,%edx
f01014de:	89 c8                	mov    %ecx,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01014e0:	83 c4 10             	add    $0x10,%esp
f01014e3:	5e                   	pop    %esi
f01014e4:	5f                   	pop    %edi
f01014e5:	5d                   	pop    %ebp
f01014e6:	c3                   	ret    
f01014e7:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01014e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01014ec:	89 f2                	mov    %esi,%edx
f01014ee:	d3 e0                	shl    %cl,%eax
f01014f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01014f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f01014fb:	89 c1                	mov    %eax,%ecx
f01014fd:	d3 ea                	shr    %cl,%edx
	      d0 = d0 << bm;
f01014ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101503:	0b 55 ec             	or     -0x14(%ebp),%edx
	      d0 = d0 << bm;
f0101506:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
f0101508:	89 c1                	mov    %eax,%ecx
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
f010150a:	89 75 e8             	mov    %esi,-0x18(%ebp)
	      n2 = n1 >> b;
f010150d:	89 fe                	mov    %edi,%esi
f010150f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
f0101511:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101515:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0101518:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010151b:	d3 e7                	shl    %cl,%edi
f010151d:	89 c1                	mov    %eax,%ecx
f010151f:	d3 ea                	shr    %cl,%edx
f0101521:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101523:	89 f2                	mov    %esi,%edx
f0101525:	89 f8                	mov    %edi,%eax
f0101527:	f7 75 ec             	divl   -0x14(%ebp)
f010152a:	89 d6                	mov    %edx,%esi
f010152c:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f010152e:	f7 65 e8             	mull   -0x18(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101531:	39 d6                	cmp    %edx,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
f0101533:	89 55 ec             	mov    %edx,-0x14(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101536:	72 30                	jb     f0101568 <__udivdi3+0x118>
f0101538:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010153b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010153f:	d3 e2                	shl    %cl,%edx
f0101541:	39 c2                	cmp    %eax,%edx
f0101543:	73 05                	jae    f010154a <__udivdi3+0xfa>
f0101545:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101548:	74 1e                	je     f0101568 <__udivdi3+0x118>
f010154a:	89 f9                	mov    %edi,%ecx
f010154c:	31 ff                	xor    %edi,%edi
f010154e:	e9 71 ff ff ff       	jmp    f01014c4 <__udivdi3+0x74>
f0101553:	90                   	nop
f0101554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101558:	31 ff                	xor    %edi,%edi
f010155a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010155f:	e9 60 ff ff ff       	jmp    f01014c4 <__udivdi3+0x74>
f0101564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0101568:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010156b:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010156d:	89 c8                	mov    %ecx,%eax
f010156f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101571:	83 c4 10             	add    $0x10,%esp
f0101574:	5e                   	pop    %esi
f0101575:	5f                   	pop    %edi
f0101576:	5d                   	pop    %ebp
f0101577:	c3                   	ret    
	...

f0101580 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0101580:	55                   	push   %ebp
f0101581:	89 e5                	mov    %esp,%ebp
f0101583:	57                   	push   %edi
f0101584:	56                   	push   %esi
f0101585:	83 ec 20             	sub    $0x20,%esp
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
f0101588:	8b 55 14             	mov    0x14(%ebp),%edx
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f010158b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
f010158e:	8b 7d 10             	mov    0x10(%ebp),%edi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
f0101591:	8b 75 0c             	mov    0xc(%ebp),%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101594:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0101596:	89 c8                	mov    %ecx,%eax
f0101598:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010159b:	75 13                	jne    f01015b0 <__umoddi3+0x30>
    {
      if (d0 > n1)
f010159d:	39 f7                	cmp    %esi,%edi
f010159f:	76 3f                	jbe    f01015e0 <__umoddi3+0x60>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01015a1:	89 f2                	mov    %esi,%edx
f01015a3:	f7 f7                	div    %edi

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f01015a5:	89 d0                	mov    %edx,%eax
f01015a7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01015a9:	83 c4 20             	add    $0x20,%esp
f01015ac:	5e                   	pop    %esi
f01015ad:	5f                   	pop    %edi
f01015ae:	5d                   	pop    %ebp
f01015af:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01015b0:	39 f2                	cmp    %esi,%edx
f01015b2:	77 4c                	ja     f0101600 <__umoddi3+0x80>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01015b4:	0f bd ca             	bsr    %edx,%ecx
	  if (bm == 0)
f01015b7:	83 f1 1f             	xor    $0x1f,%ecx
f01015ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01015bd:	75 51                	jne    f0101610 <__umoddi3+0x90>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01015bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01015c2:	0f 87 e0 00 00 00    	ja     f01016a8 <__umoddi3+0x128>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01015c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015cb:	29 f8                	sub    %edi,%eax
f01015cd:	19 d6                	sbb    %edx,%esi
f01015cf:	89 45 f4             	mov    %eax,-0xc(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f01015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015d5:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01015d7:	83 c4 20             	add    $0x20,%esp
f01015da:	5e                   	pop    %esi
f01015db:	5f                   	pop    %edi
f01015dc:	5d                   	pop    %ebp
f01015dd:	c3                   	ret    
f01015de:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01015e0:	85 ff                	test   %edi,%edi
f01015e2:	75 0b                	jne    f01015ef <__umoddi3+0x6f>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01015e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01015e9:	31 d2                	xor    %edx,%edx
f01015eb:	f7 f7                	div    %edi
f01015ed:	89 c7                	mov    %eax,%edi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01015ef:	89 f0                	mov    %esi,%eax
f01015f1:	31 d2                	xor    %edx,%edx
f01015f3:	f7 f7                	div    %edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01015f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015f8:	f7 f7                	div    %edi
f01015fa:	eb a9                	jmp    f01015a5 <__umoddi3+0x25>
f01015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0101600:	89 c8                	mov    %ecx,%eax
f0101602:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101604:	83 c4 20             	add    $0x20,%esp
f0101607:	5e                   	pop    %esi
f0101608:	5f                   	pop    %edi
f0101609:	5d                   	pop    %ebp
f010160a:	c3                   	ret    
f010160b:	90                   	nop
f010160c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101610:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101614:	d3 e2                	shl    %cl,%edx
f0101616:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101619:	ba 20 00 00 00       	mov    $0x20,%edx
f010161e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101621:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101624:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101628:	89 fa                	mov    %edi,%edx
f010162a:	d3 ea                	shr    %cl,%edx
	      d0 = d0 << bm;
f010162c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101630:	0b 55 f4             	or     -0xc(%ebp),%edx
	      d0 = d0 << bm;
f0101633:	d3 e7                	shl    %cl,%edi
	      n2 = n1 >> b;
f0101635:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101639:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010163c:	89 f2                	mov    %esi,%edx
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
f010163e:	89 7d e8             	mov    %edi,-0x18(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0101641:	89 c7                	mov    %eax,%edi

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0101643:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
f0101645:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0101649:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f010164c:	89 c2                	mov    %eax,%edx
f010164e:	d3 e6                	shl    %cl,%esi
f0101650:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101654:	d3 ea                	shr    %cl,%edx
	      n0 = n0 << bm;
f0101656:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010165a:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010165c:	89 f0                	mov    %esi,%eax
f010165e:	8b 75 e4             	mov    -0x1c(%ebp),%esi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0101661:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101663:	89 f2                	mov    %esi,%edx
f0101665:	f7 75 f4             	divl   -0xc(%ebp)
f0101668:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f010166a:	f7 65 e8             	mull   -0x18(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010166d:	39 d6                	cmp    %edx,%esi
f010166f:	72 2b                	jb     f010169c <__umoddi3+0x11c>
f0101671:	39 c7                	cmp    %eax,%edi
f0101673:	72 23                	jb     f0101698 <__umoddi3+0x118>

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0101675:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0101679:	29 c7                	sub    %eax,%edi
f010167b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f010167d:	89 f0                	mov    %esi,%eax
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f010167f:	89 f2                	mov    %esi,%edx

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0101681:	d3 ef                	shr    %cl,%edi
f0101683:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101687:	d3 e0                	shl    %cl,%eax
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0101689:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010168d:	09 f8                	or     %edi,%eax
f010168f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101691:	83 c4 20             	add    $0x20,%esp
f0101694:	5e                   	pop    %esi
f0101695:	5f                   	pop    %edi
f0101696:	5d                   	pop    %ebp
f0101697:	c3                   	ret    
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101698:	39 d6                	cmp    %edx,%esi
f010169a:	75 d9                	jne    f0101675 <__umoddi3+0xf5>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f010169c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010169f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01016a2:	eb d1                	jmp    f0101675 <__umoddi3+0xf5>
f01016a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01016a8:	39 f2                	cmp    %esi,%edx
f01016aa:	0f 82 18 ff ff ff    	jb     f01015c8 <__umoddi3+0x48>
f01016b0:	e9 1d ff ff ff       	jmp    f01015d2 <__umoddi3+0x52>
