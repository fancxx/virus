assume cs:codesg
codesg segment
start: 
    mov ax, cs
    mov ds, ax;源段地址
    mov si, offset newint21start;源地址偏移

    mov ax, 0
    mov es, ax;目标段地址
    mov di, 210h;目标地址偏移
    
    mov cx, offset  newint21end - offset newint21start;目标地址长度

    cld;设置传输方向为正
    rep movsb;ds:[si]->es:[di] 循环cx次

    mov ax, 0
    mov es, ax

    cmp word ptr es:[0200h],0
    jnz endend

	mov bx ,word ptr es:[21h*4]
    mov word ptr es:[0200h], bx
	mov bx ,word ptr es:[21h*4+2]
    mov word ptr es:[0202h],bx

    mov word ptr es:[21h*4], 210h
    mov word ptr es:[21h*4+2],0;设置中断向量表

endend:
    mov ax, 4c00h

    int 80h 

newint21start:
    jmp truestart
    string1 db "Find a virus!",13,10,'$'
    string2 db "Killed",'$'
    head db 30h dup(0) 
truestart:
    sti
    push ax 
    push bx 
    push cx 
    push dx 
    push ds
    push es
    push bp 

    cmp word ptr ds:[bp+3],8899h 
    je virus
normal:
    pop bp
    pop es  
    pop ds  
    pop dx  
    pop cx  
    pop bx  
    pop ax 
    int 80h
    push ax 
    push bx 
    push cx 
    push dx 
    push ds
    push es
    push bp
    jmp exit 
virus:
    mov dx,bp 
    cmp dx,0
    jz orignal_virus

    add dx,0121h 
    jmp kill   
orignal_virus:   
    add dx,5
kill:
    push si   

    mov ax,3d02h
	int 80h

	xchg ax,bx

	mov ax,4200h
	xor cx,cx
	xor dx,dx
	int 80h

    mov ax,cs 
    mov ds,ax

	mov ah,3fh
	mov cx,30h 
	mov dx,offset head - offset newint21start + 210h
	mov si,dx
	int 80h 

	mov word ptr [si+2ah],0000h

	mov ax,word ptr [si+02eh] 
    mov word ptr [si+014h],ax

	mov ax,4200h  
    xor cx,cx
    xor dx,dx
    int 80h

    mov ah,40h
    mov dx,si     ;即head位置
    mov cx,30h     ;长度
    int 80h   
  
    pop si  

printmes:
    
    mov dx, offset string1 - offset newint21start + 210h
    mov ah,09h 
    int 80h 

    add dx,offset string2 - offset string1
    mov ah,09h 
    int 80h

    mov ax,4c00h 
    int 80h  
exit:
    pop bp
    pop es  
    pop ds  
    pop dx  
    pop cx  
    pop bx  
    pop ax
    cli  
    iret
newint21end:nop

codesg ends

end start
