%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR

[bits 16]
loader_start:
  ;load gdt
  ;---------------------------
  lgdt [gdt_ptr]

  ;protect mode
  ;---------------------------
  ;use A20
  ;---------------------------
  in al,0x92
  or al,0000_0010B
  out 0x92,al

  ;close interruption
  ;---------------------------
  cli

  ;set cr0
  ;---------------------------
  mov eax,cr0
  or eax,0x1
  mov cr0,eax

  ;run code with protect mode
  ;---------------------------
  jmp dword CODE_SELECTOR:(p_mode_start-LOADER_BASE_ADDR)

;gdt content
;-----------------------------
gdt_addr:
  ;the first global descriptor is null
  ;---------------------------
  GDT_BASE:
    dd 0x0
    dd 0x0
  ;code descriptor
  ;---------------------------
  CODE_DESC:
    Descriptor 0x900,SegCode32Len-1,DA_C+DA_32
  ;data descriptor
  ;---------------------------
  DATA_DESC:
  STACK_DESC:
  ;video descriptor
  ;---------------------------
  VIDEO_DESC:
    Descriptor 0xb8000,0xffff,DA_DRW

  GDT_SIZE equ $-GDT_BASE
  GDT_LIMIT equ GDT_SIZE-1
  CODE_SELECTOR equ (0x0001<<3)+TI_GDT+RPL0
  DATA_SELECTOR equ (0x0002<<3)+TI_GDT+RPL0
  STACK_SELECTOR equ (0x0003<<3)+TI_GDT+RPL0
  VIDEO_SELECTOR equ (0x0002<<3)+TI_GDT+RPL0

gdt_ptr:
  dw GDT_LIMIT
  dd GDT_BASE

SegCode32:
[bits 32]
p_mode_start:
  mov eax,VIDEO_SELECTOR
  mov gs,eax

  mov byte [gs:0xA0],'2'
  mov byte [gs:0xA1],0x4
  mov byte [gs:0xA4],'L'
  mov byte [gs:0xA5],0x4
  mov byte [gs:0xA6],'O'
  mov byte [gs:0xA7],0x4
  mov byte [gs:0xA8],'A'
  mov byte [gs:0xA9],0x4
  mov byte [gs:0xAA],'D'
  mov byte [gs:0xAB],0x4
  mov byte [gs:0xAC],'E'
  mov byte [gs:0xAD],0x4
  mov byte [gs:0xAE],'R'
  mov byte [gs:0xAF],0x4

  jmp near $

SegCode32Len equ $-SegCode32
