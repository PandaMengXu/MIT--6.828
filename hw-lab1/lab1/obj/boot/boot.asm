
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
# memory can accessed, then calls into C.
###############################################################################
	
.globl start					# Entry point	
start:		.code16				# This runs in real mode
		cli				# Disable interrupts
    7c00:	fa                   	cli    
		cld				# String operations increment
    7c01:	fc                   	cld    

		# Set up the important data segment registers (DS, ES, SS).
		xorw	%ax,%ax			# Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
		movw	%ax,%ds			# -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
		movw	%ax,%es			# -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
		movw	%ax,%ss			# -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

		# Set up the stack pointer, growing downward from 0x7c00.
		movw	$start,%sp         	# Stack Pointer
    7c0a:	bc 00 7c e4 64       	mov    $0x64e47c00,%esp

00007c0d <seta20.1>:
#   and subsequent 80286-based PCs wanted to retain maximum compatibility),
#   physical address line 20 is tied to low when the machine boots.
#   Obviously this a bit of a drag for us, especially when trying to
#   address memory above 1MB.  This code undoes this.
	
seta20.1:	inb	$0x64,%al		# Get status
    7c0d:	e4 64                	in     $0x64,%al
		testb	$0x2,%al		# Busy?
    7c0f:	a8 02                	test   $0x2,%al
		jnz	seta20.1		# Yes
    7c11:	75 fa                	jne    7c0d <seta20.1>
		movb	$0xd1,%al		# Command: Write
    7c13:	b0 d1                	mov    $0xd1,%al
		outb	%al,$0x64		#  output port
    7c15:	e6 64                	out    %al,$0x64

00007c17 <seta20.2>:
seta20.2:	inb	$0x64,%al		# Get status
    7c17:	e4 64                	in     $0x64,%al
		testb	$0x2,%al		# Busy?
    7c19:	a8 02                	test   $0x2,%al
		jnz	seta20.2		# Yes
    7c1b:	75 fa                	jne    7c17 <seta20.2>
		movb	$0xdf,%al		# Enable
    7c1d:	b0 df                	mov    $0xdf,%al
		outb	%al,$0x60		#  A20
    7c1f:	e6 60                	out    %al,$0x60

00007c21 <real_to_prot>:
#   OK to run code at any address, or write to any address.
#   The 'gdt' and 'gdtdesc' tables below define these segments.
#   This code loads them into the processor.
#   We need this setup to ensure the transition to protected mode is smooth.

real_to_prot:	cli			# Don't allow interrupts: mandatory,
    7c21:	fa                   	cli    
					# since we didn't set up an interrupt
					# descriptor table for handling them
		lgdt	gdtdesc		# load GDT: mandatory in protected mode
    7c22:	0f 01 16             	lgdtl  (%esi)
    7c25:	64                   	fs
    7c26:	7c 0f                	jl     7c37 <protcseg+0x1>
		movl	%cr0, %eax	# Turn on protected mode
    7c28:	20 c0                	and    %al,%al
		orl	$CR0_PE_ON, %eax
    7c2a:	66 83 c8 01          	or     $0x1,%ax
		movl	%eax, %cr0
    7c2e:	0f 22 c0             	mov    %eax,%cr0

	        # CPU magic: jump to relocation, flush prefetch queue, and
		# reload %cs.  Has the effect of just jmp to the next
		# instruction, but simultaneously loads CS with
		# $PROT_MODE_CSEG.
		ljmp	$PROT_MODE_CSEG, $protcseg
    7c31:	ea 36 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c36

00007c36 <protcseg>:
	
		# we've switched to 32-bit protected mode; tell the assembler
		# to generate code for that mode
protcseg:	.code32
		# Set up the protected-mode data segment registers
		movw	$PROT_MODE_DSEG, %ax	# Our data segment selector
    7c36:	66 b8 10 00          	mov    $0x10,%ax
		movw	%ax, %ds		# -> DS: Data Segment
    7c3a:	8e d8                	mov    %eax,%ds
		movw	%ax, %es		# -> ES: Extra Segment
    7c3c:	8e c0                	mov    %eax,%es
		movw	%ax, %fs		# -> FS
    7c3e:	8e e0                	mov    %eax,%fs
		movw	%ax, %gs		# -> GS
    7c40:	8e e8                	mov    %eax,%gs
		movw	%ax, %ss		# -> SS: Stack Segment
    7c42:	8e d0                	mov    %eax,%ss
	
		call cmain			# finish the boot load from C.
    7c44:	e8 d9 00 00 00       	call   7d22 <cmain>

00007c49 <spin>:
						# cmain() should not return
spin:		jmp spin			# ..but in case it does, spin
    7c49:	eb fe                	jmp    7c49 <spin>
    7c4b:	90                   	nop

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
    7c69:	00 90 90 55 ba f7    	add    %dl,-0x845aa70(%eax)

00007c6c <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c6c:	55                   	push   %ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c6d:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c72:	89 e5                	mov    %esp,%ebp
    7c74:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c75:	25 c0 00 00 00       	and    $0xc0,%eax
    7c7a:	83 f8 40             	cmp    $0x40,%eax
    7c7d:	75 f5                	jne    7c74 <waitdisk+0x8>
		/* do nothing */;
}
    7c7f:	5d                   	pop    %ebp
    7c80:	c3                   	ret    

00007c81 <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7c81:	55                   	push   %ebp
    7c82:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c87:	89 e5                	mov    %esp,%ebp
    7c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    7c8c:	57                   	push   %edi
    7c8d:	ec                   	in     (%dx),%al

void
waitdisk(void)
{
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c8e:	25 c0 00 00 00       	and    $0xc0,%eax
    7c93:	83 f8 40             	cmp    $0x40,%eax
    7c96:	75 f5                	jne    7c8d <readsect+0xc>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c98:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c9d:	b0 01                	mov    $0x1,%al
    7c9f:	ee                   	out    %al,(%dx)
    7ca0:	b2 f3                	mov    $0xf3,%dl
    7ca2:	88 c8                	mov    %cl,%al
    7ca4:	ee                   	out    %al,(%dx)
    7ca5:	89 c8                	mov    %ecx,%eax
    7ca7:	b2 f4                	mov    $0xf4,%dl
    7ca9:	c1 e8 08             	shr    $0x8,%eax
    7cac:	ee                   	out    %al,(%dx)
    7cad:	89 c8                	mov    %ecx,%eax
    7caf:	b2 f5                	mov    $0xf5,%dl
    7cb1:	c1 e8 10             	shr    $0x10,%eax
    7cb4:	ee                   	out    %al,(%dx)
    7cb5:	c1 e9 18             	shr    $0x18,%ecx
    7cb8:	b2 f6                	mov    $0xf6,%dl
    7cba:	88 c8                	mov    %cl,%al
    7cbc:	83 c8 e0             	or     $0xffffffe0,%eax
    7cbf:	ee                   	out    %al,(%dx)
    7cc0:	b0 20                	mov    $0x20,%al
    7cc2:	b2 f7                	mov    $0xf7,%dl
    7cc4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7cc5:	ec                   	in     (%dx),%al
    7cc6:	25 c0 00 00 00       	and    $0xc0,%eax
    7ccb:	83 f8 40             	cmp    $0x40,%eax
    7cce:	75 f5                	jne    7cc5 <readsect+0x44>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cd3:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cd8:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cdd:	fc                   	cld    
    7cde:	f2 6d                	repnz insl (%dx),%es:(%edi)
	// wait for disk to be ready
	waitdisk();

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7ce0:	5f                   	pop    %edi
    7ce1:	5d                   	pop    %ebp
    7ce2:	c3                   	ret    

00007ce3 <readseg>:

// Read 'count' bytes at 'offset' from kernel into virtual address 'va'.
// Might copy more than asked
void
readseg(uint32_t va, uint32_t count, uint32_t offset)
{
    7ce3:	55                   	push   %ebp
    7ce4:	89 e5                	mov    %esp,%ebp
    7ce6:	57                   	push   %edi
    7ce7:	56                   	push   %esi
    7ce8:	8b 75 10             	mov    0x10(%ebp),%esi
    7ceb:	53                   	push   %ebx
    7cec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	// round down to sector boundary
	va &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cef:	c1 ee 09             	shr    $0x9,%esi
void
readseg(uint32_t va, uint32_t count, uint32_t offset)
{
	uint32_t end_va;

	va &= 0xFFFFFF;
    7cf2:	89 df                	mov    %ebx,%edi
	
	// round down to sector boundary
	va &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cf4:	46                   	inc    %esi
void
readseg(uint32_t va, uint32_t count, uint32_t offset)
{
	uint32_t end_va;

	va &= 0xFFFFFF;
    7cf5:	81 e7 ff ff ff 00    	and    $0xffffff,%edi
	end_va = va + count;
	
	// round down to sector boundary
	va &= ~(SECTSIZE - 1);
    7cfb:	81 e3 00 fe ff 00    	and    $0xfffe00,%ebx
readseg(uint32_t va, uint32_t count, uint32_t offset)
{
	uint32_t end_va;

	va &= 0xFFFFFF;
	end_va = va + count;
    7d01:	03 7d 0c             	add    0xc(%ebp),%edi
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
    7d04:	eb 10                	jmp    7d16 <readseg+0x33>
		readsect((uint8_t*) va, offset);
    7d06:	56                   	push   %esi
		va += SECTSIZE;
		offset++;
    7d07:	46                   	inc    %esi

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
		readsect((uint8_t*) va, offset);
    7d08:	53                   	push   %ebx
		va += SECTSIZE;
    7d09:	81 c3 00 02 00 00    	add    $0x200,%ebx

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
		readsect((uint8_t*) va, offset);
    7d0f:	e8 6d ff ff ff       	call   7c81 <readsect>
		va += SECTSIZE;
		offset++;
    7d14:	58                   	pop    %eax
    7d15:	5a                   	pop    %edx
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
    7d16:	39 fb                	cmp    %edi,%ebx
    7d18:	72 ec                	jb     7d06 <readseg+0x23>
		readsect((uint8_t*) va, offset);
		va += SECTSIZE;
		offset++;
	}
}
    7d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d1d:	5b                   	pop    %ebx
    7d1e:	5e                   	pop    %esi
    7d1f:	5f                   	pop    %edi
    7d20:	5d                   	pop    %ebp
    7d21:	c3                   	ret    

00007d22 <cmain>:
void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
cmain(void)
{
    7d22:	55                   	push   %ebp
    7d23:	89 e5                	mov    %esp,%ebp
    7d25:	56                   	push   %esi
    7d26:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d27:	6a 00                	push   $0x0
    7d29:	68 00 10 00 00       	push   $0x1000
    7d2e:	68 00 00 01 00       	push   $0x10000
    7d33:	e8 ab ff ff ff       	call   7ce3 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d38:	83 c4 0c             	add    $0xc,%esp
    7d3b:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d42:	45 4c 46 
    7d45:	75 3f                	jne    7d86 <cmain+0x64>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d47:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d4d:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d54:	81 c3 00 00 01 00    	add    $0x10000,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d5a:	c1 e0 05             	shl    $0x5,%eax
    7d5d:	8d 34 03             	lea    (%ebx,%eax,1),%esi
	for (; ph < eph; ph++)
    7d60:	eb 14                	jmp    7d76 <cmain+0x54>
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);
    7d62:	ff 73 04             	pushl  0x4(%ebx)
    7d65:	ff 73 14             	pushl  0x14(%ebx)
    7d68:	ff 73 08             	pushl  0x8(%ebx)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d6b:	83 c3 20             	add    $0x20,%ebx
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);
    7d6e:	e8 70 ff ff ff       	call   7ce3 <readseg>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d73:	83 c4 0c             	add    $0xc,%esp
    7d76:	39 f3                	cmp    %esi,%ebx
    7d78:	72 e8                	jb     7d62 <cmain+0x40>
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry & 0xFFFFFF))();
    7d7a:	a1 18 00 01 00       	mov    0x10018,%eax
    7d7f:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d84:	ff d0                	call   *%eax
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d86:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d8b:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d90:	66 ef                	out    %ax,(%dx)
    7d92:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d97:	66 ef                	out    %ax,(%dx)
    7d99:	eb fe                	jmp    7d99 <cmain+0x77>
