
obj/kern/printf.o:     file format elf32-i386


Disassembly of section .text:

00000000 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
   0:	55                   	push   ebp
   1:	89 e5                	mov    ebp,esp
   3:	83 ec 28             	sub    esp,0x28
	int cnt = 0;
   6:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [ebp-0xc],0x0

	vprintfmt((void*)putch, &cnt, fmt, ap);
   d:	8b 45 0c             	mov    eax,DWORD PTR [ebp+0xc]
  10:	89 44 24 0c          	mov    DWORD PTR [esp+0xc],eax
  14:	8b 45 08             	mov    eax,DWORD PTR [ebp+0x8]
  17:	89 44 24 08          	mov    DWORD PTR [esp+0x8],eax
  1b:	8d 45 f4             	lea    eax,[ebp-0xc]
  1e:	89 44 24 04          	mov    DWORD PTR [esp+0x4],eax
  22:	c7 04 24 4d 00 00 00 	mov    DWORD PTR [esp],0x4d
  29:	e8 fc ff ff ff       	call   2a <vcprintf+0x2a>
	return cnt;
}
  2e:	8b 45 f4             	mov    eax,DWORD PTR [ebp-0xc]
  31:	c9                   	leave  
  32:	c3                   	ret    

00000033 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  33:	55                   	push   ebp
  34:	89 e5                	mov    ebp,esp
  36:	83 ec 18             	sub    esp,0x18
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  39:	8d 45 0c             	lea    eax,[ebp+0xc]
  3c:	89 44 24 04          	mov    DWORD PTR [esp+0x4],eax
  40:	8b 45 08             	mov    eax,DWORD PTR [ebp+0x8]
  43:	89 04 24             	mov    DWORD PTR [esp],eax
  46:	e8 fc ff ff ff       	call   47 <cprintf+0x14>
	va_end(ap);

	return cnt;
}
  4b:	c9                   	leave  
  4c:	c3                   	ret    

0000004d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
  4d:	55                   	push   ebp
  4e:	89 e5                	mov    ebp,esp
  50:	83 ec 18             	sub    esp,0x18
	cputchar(ch);
  53:	8b 45 08             	mov    eax,DWORD PTR [ebp+0x8]
  56:	89 04 24             	mov    DWORD PTR [esp],eax
  59:	e8 fc ff ff ff       	call   5a <putch+0xd>
	*cnt++;
}
  5e:	c9                   	leave  
  5f:	c3                   	ret    
