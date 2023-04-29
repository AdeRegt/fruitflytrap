FORMAT MZ
HEAP 0
STACK 8000h
entry text:main 

segment text use16

main:
    ; set our right ds
    mov ax,text
    mov ds,ax

    ; greet our nice  users
    mov dx,welcome_message
    call print

    ; ask for file
    mov dx,askforfilemessage
    call print 

    call readstring
    call trimstringforfile
    mov dx,newlinemessage
    call print

    ; open file
    mov dx,inputresult;defaultfile
    mov ah,0x3D
    int 0x21
    jc error

    ; read file into buffer
    mov word[filehandler],ax
    mov bx,ax 
    mov cx,8206
    mov ah,0x3F
    mov dx,memorylane
    int 0x21
    jc error 

    ; close the file
    mov bx, word [filehandler]
    mov ah,0x3E
    int 0x21
    jc error

    ; enter the main loop
    mov word [program_counter],0
mainloop:
    ; get programcounter then fetch value of memoryarea
    mov cx , word [program_counter]
    cmp cx,0x0FFF
    je warningnoexit
    add cx,cx
    mov si, memorylane 
    add si, 8
    add si,cx 
    mov ax, word [si]
    mov word[current_instruction] , ax 
    ; save argument
    mov ax , word[current_instruction]
    mov bx,0x0FFF
    and ax,bx 
    mov word[current_argument],ax
    ; save command
    mov ax , word[current_instruction]
    mov bx,0xF000
    and ax,bx 
    shr ax,12
    mov word[current_task],ax

    ; cmp word[current_task],0x0
    ; je command_nope

    ; cmp word[current_task],0x1
    ; je command_jne

    ; cmp word[current_task],0x2
    ; je command_jl

    ; cmp word[current_task],0x3
    ; je command_jm

    ; cmp word[current_task],0x4
    ; je command_je

    cmp word[current_task],0x5
    je command_flags

    ; cmp word[current_task],0x6
    ; je command_jump

    ; cmp word[current_task],0x7
    ; je command_rb2a

    ; cmp word[current_task],0x8
    ; je command_ra2a

    ; cmp word[current_task],0x9
    ; je command_a2rb

    ; cmp word[current_task],0xA
    ; je command_a2ra

    cmp word[current_task],0xB
    je command_call

    ; cmp word[current_task],0xC
    ; je command_v2ra

    cmp word[current_task],0xD
    je command_syscall

    ; cmp word[current_task],0xE
    ; je command_v2rb

    cmp word[current_task],0xF
    je command_exit
    

    ; if we are here, we have a unknown instruction!
    mov dx,unknowninstruction
    call print 
    mov ax,0
    mov ax,word[current_task]
    call printhex 
    mov dx,newlinemessage
    call print
    call exit
    ret

command_nope:
    pusha
    call inc_instructionpointer
    popa
    jmp mainloop

command_jne:
    pusha
    mov ax,word [register_A]
    mov bx,word [register_B]
    cmp ax,bx 
    jne .eeks
    call inc_instructionpointer
    popa
    jmp mainloop
    .eeks:
    mov ax,word [current_argument]
    mov word [program_counter],ax
    popa 
    jmp mainloop

command_jl:
    pusha
    mov ax,word [register_A]
    mov bx,word [register_B]
    cmp ax,bx 
    jl .eeks
    call inc_instructionpointer
    popa
    jmp mainloop
    .eeks:
    mov ax,word [current_argument]
    mov word [program_counter],ax
    popa 
    jmp mainloop

command_jm:
    pusha
    mov ax,word [register_A]
    mov bx,word [register_B]
    cmp ax,bx 
    jg .eeks
    call inc_instructionpointer
    popa
    jmp mainloop
    .eeks:
    mov ax,word [current_argument]
    mov word [program_counter],ax
    popa 
    jmp mainloop

command_je:
    pusha
    mov ax,word [register_A]
    mov bx,word [register_B]
    cmp ax,bx 
    je .eeks
    call inc_instructionpointer
    popa
    jmp mainloop
    .eeks:
    mov ax,word [current_argument]
    mov word [program_counter],ax
    popa 
    jmp mainloop

command_flags:
    pusha
    mov ax, word [current_argument]
    cmp ax, 0x11
    je command_flags_return
    jmp invalidflags
    .finosub:
    call inc_instructionpointer
    popa
    jmp mainloop

command_flags_return:
    ; decrease jump stack index
    mov ax, word [jump_stack_index]
    dec ax
    mov word [jump_stack_index], ax
    ; get the value 
    mov di,jump_stack 
    add di,word [jump_stack_index]
    add di,word [jump_stack_index]
    mov ax, word[di]
    ; set the pc to the right value
    mov word[program_counter],ax
    ; clear the jump_stack value 
    mov word[di], 0
    popa 
    jmp mainloop

command_jump:
    pusha
    mov ax,word [current_argument]
    mov word [program_counter],ax
    popa 
    jmp mainloop

command_rb2a:
    pusha
    mov ax, word [register_B]
    mov si, memorylane
    add si,8
    mov bx, word [current_argument]
    add si,bx 
    mov word[si],ax
    call inc_instructionpointer
    popa
    jmp mainloop

command_ra2a:
    pusha
    mov ax, word [register_A]
    mov si, memorylane
    add si,8
    mov bx, word [current_argument]
    add si,bx 
    mov word[si],ax
    call inc_instructionpointer
    popa
    jmp mainloop

command_a2rb:
    pusha
    call inc_instructionpointer
    popa
    jmp mainloop

command_a2ra:
    pusha
    call inc_instructionpointer
    popa
    jmp mainloop

command_call:
    pusha

    ; push value to the call stack
    mov di,jump_stack 
    add di,word [jump_stack_index]
    add di,word [jump_stack_index]
    mov ax, word [program_counter]
    inc ax 
    mov word[di],ax

    ; increse callstack
    mov ax, word [jump_stack_index]
    inc ax
    mov word [jump_stack_index], ax

    ; do the actual call
    mov ax,word [current_argument]
    mov word [program_counter],ax
    popa 
    jmp mainloop

command_v2ra:
    pusha
    call inc_instructionpointer
    popa
    jmp mainloop

command_syscall:
    pusha
    mov ax, word [current_argument]
    add ax,ax 
    mov si,memorylane
    add si,8
    add si,ax 
    mov ax,0
    mov ax,word[si]
    cmp ax,1
    je command_syscall_print
    jmp invalidsyscall
    .finosub:
    call inc_instructionpointer
    popa
    jmp mainloop

command_syscall_print:
    mov ax, word [current_argument]
    add ax,ax 
    mov si,memorylane
    add si,8 ; basepath
    add si,ax ; add currentargument
    add si,2 ; grab the arguments after this
    push si 
    .again: 
    mov al,byte [si]
    inc si
    cmp al,0
    jne .again 
    dec si
    mov byte[si],'$'
    pop si
    mov dx,si 
    call print
    mov dx,newlinemessage
    call print
    jmp command_syscall.finosub

invalidsyscall:
    mov dx,invalidsyscallstring
    call print 
    call printhex
    mov dx,newlinemessage
    call print 
    call exit 

invalidflags:
    mov dx,invalidflagsstring
    call print 
    call printhex
    mov dx,newlinemessage
    call print 
    call exit 

command_v2rb:
    pusha
    call inc_instructionpointer
    popa
    jmp mainloop

command_exit:
    mov dx,normalprogramexitmessage
    call print
    call exit

inc_instructionpointer:
    pusha 
    mov cx , word [program_counter]
    inc cx 
    mov word [program_counter], cx
    popa 
    ret

warningnoexit:
    mov dx,warningnoexitmessage
    call print 
    call exit 
    ret 

error:
    mov dx,errormessage
    call print 
    call exit
    ret

;
; PRINTS HEXSTRING
; IN: AX
printhex:
    pusha
    push ax 
    and ax,0xF000
    shr ax,12
    call .checkup
    pop ax
    push ax 
    and ax,0x0F00
    shr ax,8
    call .checkup
    pop ax
    push ax 
    and ax,0x00F0
    shr ax,4
    call .checkup
    pop ax
    push ax 
    and ax,0x000F
    call .checkup
    pop ax
    popa
    ret
.checkup:
    pusha
    mov si,.chck0 
    add si,ax 
    mov cl,byte[si]
    mov di,.mdg0 
    mov byte[di],cl
    mov dx,.mdg0 
    call print
    popa
    ret
.chck0 db "0123456789ABCDEF$"
.mdg0 db " $"

;
; TRIMS STRING
; IN:
;   - nothing
; OUT:
;   - nothing
trimstringforfile:
    pusha
    mov si,inputresult
    .again:
    mov al,byte[si]
    cmp al,0x0a
    je .finish
    cmp al,0x24
    je .finish
    cmp al,0x0d
    je .finish
    inc si
    jmp .again
    .finish:
    mov byte[si],0
    popa
    ret

;
; GETS STRING
; IN:
;   - nothing
; OUT:
;   - nothing
readstring:
    pusha
    ; clear previously entered text
    mov si,inputresult 
    mov cx,20
    .again2:
    mov byte[si],'$'
    inc si 
    dec cx 
    cmp cx,0
    jne .again2
    ; now ask stuff
    mov ax,0
    mov dx,inputcommandset
    mov ah,0x0A
    int 0x21
    popa
    ret 
inputcommandset: 
    db 20 ; max chars buffer can hold
    db 0
inputresult:
    times 20 db 0
    db '$'
;
; PRINTS STRING
; IN:
;   - dx:STRING
; OUT:
;   - nothing
print:
    pusha
    mov ah,0x09
    int 0x21
    popa
    ret 

;
; EXITS PROGRAM
; IN:
;   - EXITCODE
; OUT:
;   - nothing
exit:
    mov ah,0x4C
    mov al,0
    int 0x21


welcome_message db "Fruitfly virtual machine for KiddieOS",0x0a,"Created by Alexandros de Regt, https://fruitfly.sanderslando.nl ",0x0a,'$'
errormessage db "Program exits with errors",0x0a,'$'
warningnoexitmessage db "WARNING: exit without EXIT",0x0a,'$'
askforfilemessage db "Please enter the path of the SXE file: ",'$'
unknowninstruction db "FATAL: unknown instruction: ",'$'
newlinemessage db 0x0a,'$'
defaultfile db "A:\TEST.SXE",0
normalprogramexitmessage db "Program exits succesfully",0x0a,'$'
invalidsyscallstring db "Unknown syscall: $"
invalidflagsstring db "Unknown flag: $"
filehandler dd 0

program_counter dd 0
register_A dd 0
register_B dd 0
current_instruction dd 0
current_task dd 0
current_argument dd 0
jump_stack:
times 10 dd 0
jump_stack_index dd 0
stacker:
times 10 dd 0
stacker_index dd 0
memorylane: 
times 8206 db 0