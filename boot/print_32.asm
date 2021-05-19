[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_pm:
	pusha
	mov edx, VIDEO_MEMORY

.loop:
	mov al, [ebx]
	mov ah, WHITE_ON_BLACK

	cmp al, 0
	je .exit

	mov [edx], ax
	add ebx, 1
	add edx, 2

	jmp .loop

.exit:
	popa
	ret
