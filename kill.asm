data segment
	filename db "*.exe",0
	programstart db "The antivirus program begins",13,10,'$'
	programends db "Program ends",13,10,'$'
	virusname db 25 dup(0)
	string db ".exe has been infected",13,10,'$'
	num db '0'," virus have been killed!",13,10,'$'
	dta db 02bh dup(0)
	head db 30h dup(0)
	NoVirus db "No virus found.",13,10,"$"
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax

	mov ah,09h
	lea dx,programstart
	int 21h

	call find

	lea dx,programends
	mov ah,09h
	int 21h

	mov ah,4ch
	int 21h

find proc
	lea dx,dta
	mov ah,1ah
	int 21h
	
	mov dx, offset filename
	mov cx,0
	mov ah,4eh
	int 21h
	jnc loopkill
	ret
loopkill:
	mov dx,offset dta
	add dx,1eh

	mov ax,3d02h
	int 21h

	xchg ax,bx

	mov ax,4200h
	xor cx,cx
	xor dx,dx
	int 21h

	mov ah,3fh
	mov cx,30h 
	lea dx,head
	mov si,dx
	int 21h

	cmp word ptr [si],5a4dh
	jnz nextfile

	cmp word ptr [si+2ah],4321h
	jne nextfile 

delvirus:	
	mov dx,offset dta
	add dx,1eh
	call printname
	
	mov word ptr [si+2ah],0000h

	mov ax,word ptr [si+02eh] 
    mov word ptr [si+014h],ax

	mov ax,4200h  
    xor cx,cx
    xor dx,dx
    int 21h

    mov ah,40h
    mov dx,si     ;即head位置
    mov cx,30h     ;长度
    int 21h   

	lea dx,num
	mov si,dx
	mov al,byte ptr [si]
	inc al
	mov byte ptr [si],al
	mov dx,offset num
	mov ah,09h
	int 21h
nextfile:
	mov ah,3eh
	int 21h

	mov ah,4fh
	int 21h
	jc error
	jmp loopkill
error:
	ret
find endp

printname proc
	push si
	mov si,dx
	mov di,offset virusname
	push cx
	push bx
	push ax
	push dx
	mov bx,dx
	mov cx,0
loop1:
	cmp byte ptr [bx],'.'
	je part2
	mov dx, [bx]
	mov ah,02h 
	int 21h
	inc cx
	inc bx
	jmp loop1

part2:
	
	mov dx,offset string
	mov ah,09h
	int 21h

	pop dx
	pop ax

	pop bx
	pop cx
	pop si 
	ret
printname endp

code ends
end start