;load from START sector & store in BASE address
;---------------------------
LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 0x2

;get descriptor
;---------------------------
;%1: Segment base
;%2: Segment limit
;%3: Segment attribute
;---------------------------
%macro Descriptor 3
  dw %2 & 0xffff                            ;segment_limit
  dw %1 & 0xffff                            ;segment_base
  db (%1 >> 16) & 0xff                      ;segment_base
  dw ((%2 >> 8) & 0xf00) | (%3 & 0xf0ff)    ;attribute+segment_limit+attribute
  db (%1 >> 24) & 0xff                      ;segment_base
%endmacro

;descriptor attribute
;---------------------------
DA_32 equ 0x4000               ;32 bit
DA_C equ 0x98                  ;__x
DA_DRW equ 0x92                ;rw_
DA_DRWA equ 0x93               ;rw_(alive)

;selector attribute
;---------------------------
RPL0 equ 0
RPL1 equ 1
RPL2 equ 2
RPL3 equ 3
TI_GDT equ 000b
TI_LDT equ 100b
