ORG 0 ; origin
BITS 16 ; 16 bit architecture (for now)

_start: ; Bios Parameter Block specific
    jmp short start
    nop

times 33 db 0 ; fill null to BPB (offset total is 33)

start:
    jmp 0x7c0:step2

step2:
    cli ; clear interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax

    mov ax, 0x00 ; set stack 0
    mov ss, ax
    mov sp, 0x7c00 ; stack pointer
    sti ; enable interrupts

    mov ah, 2 ; Read sector cmd
    mov al, 1 ; one sector to read
    mov ch, 0 ; cylinder low eight bits
    mov cl, 2 ; sector 2
    mov dh, 0 ; head number

    mov bx, buffer ; set data to our buffer
    int 0x13

    jc error

    mov si, buffer
    call print
    jmp $

error:
    mov si, error_message
    call print
    jmp $ ; endless loop

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10 ; BIOS call
    ret

error_message: db 'Failed to load sector', 0

times 510-($- $$) db 0 ; fill at least 510 bytes of data, pabbing rest to 0
dw 0xAA55 ; signature

buffer: