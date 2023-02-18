;MBR
%include "boot.inc"
section MBR vstart=0x7c00

;initialize registers
;---------------------------
mov ax,cs
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c00
mov ax,0xb800
mov gs,ax

;clear screen
;---------------------------
;using 0x06 function
;---------------------------
;AH      function code
;AL      scroll line counts
;BH      properties
;(CL,CH) window upper left corner position
;(DL,DH) window lower right corner position
;---------------------------
mov ax, 0x600
mov bx, 0x700
mov cx, 0
mov dx, 0x184f
int 0x10

;print
;---------------------------
mov byte [gs:0x00],'1'
mov byte [gs:0x01],0x04

mov byte [gs:0x04],'M'
mov byte [gs:0x05],0x04

mov byte [gs:0x06],'B'
mov byte [gs:0x07],0x04

mov byte [gs:0x08],'R'
mov byte [gs:0x09],0x04


mov eax,LOADER_START_SECTOR
mov bx,LOADER_BASE_ADDR
mov cx,1
call rd_disk_m_16           ;AX 0x2
                            ;BX 0x900
                            ;CX 1
jmp LOADER_BASE_ADDR

;read disk
;---------------------------
;read n sectors from disk
;---------------------------
;AX LBA
;BX loader base address
;CX number of sectors
;---------------------------
rd_disk_m_16:
	mov esi,eax               ;backup eax
	mov di,cx                 ;backup cx
	;1. set sectors count
	;-------------------------
	mov dx,0x1f2
	mov al,cl
	out dx,al                 ;number of sectors
	mov eax,esi               ;recovery eax
	;2. store LBA address in 0x1f3~0x1f6
	;-------------------------
	mov dx,0x1f3
	out dx,al
	
	mov cl,8
	shr eax,cl
	mov dx,0x1f4
	out dx,al
	
	shr eax,cl
	mov dx,0x1f5
	out dx,al
	
	shr eax,cl
	and al,0x0f               ;address remain 3 bit
	or al,0xe0                ;1010+0100(LBA mode)
	mov dx,0x1f6
	out dx,al
	
	;3. write command in 0x1f7
	;-------------------------
	mov dx,0x1f7
	mov al,0x20               ;0x20: read command
	out dx,al

	;4. check disk status
	;-------------------------
.not_readey:
	nop
	in al,dx
	and al,0x88
	cmp al,0x08
	jnz .not_readey
	;5. read data from 0x1f0
	;-------------------------
	mov ax,di                 ;sector counts
	mov dx,256                ;each sectors need to loop 256 cycles(each time read 1 word but 1 sector has 512 bytes)
	mul dx
	mov cx,ax                 ;CX loop counts
	mov dx,0x1f0
.go_on_read:
	in ax,dx
	mov [bx],ax
	add bx,2
	loop .go_on_read
	ret

	times 510-($-$$) db 0
	
	db 0x55,0xaa
