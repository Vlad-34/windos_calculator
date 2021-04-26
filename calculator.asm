.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title db "(c) Vlad Ursache",0
area_width equ 480
area_height equ 640
area dd 0

title_x equ 155
title_y equ 10
cursor dd 0
contor dd 0
button_size equ 120
button_9_x equ 0
button_9_y equ 160
button_8_x equ 120
button_8_y equ 160
button_7_x equ 240
button_7_y equ 160
button_6_x equ 0
button_6_y equ 280
button_5_x equ 120
button_5_y equ 280
button_4_x equ 240
button_4_y equ 280
button_3_x equ 0
button_3_y equ 400
button_2_x equ 120
button_2_y equ 400
button_1_x equ 240
button_1_y equ 400
button_0_x equ 120
button_0_y equ 520
button_plus_x equ 360
button_plus_y equ 520
button_minus_x equ 360
button_minus_y equ 400
button_times_x equ 360
button_times_y equ 280
button_divided_x equ 360
button_divided_y equ 160
button_equal_x equ 240
button_equal_y equ 520
button_clear_x equ 0
button_clear_y equ 520

ten dd 10

nr1 dd 0
nr2 dd 0
rez dd 0
op1 dd 0
op2 dd 0 ;egal

counter dd 0 ; numara evenimentele de tip timer

arg1 equ 8
arg2 equ 12
arg3 equ 16 ;x
arg4 equ 20 ;y

symbol_width equ 10
symbol_height equ 20

include digits.inc
include letters.inc
include symbols.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

glue proc
	push ebp
	mov ebp, esp
	mov eax, [ebp-4]
	mov ebx, ten
	mul ebx
	add eax, [ebp-8]
	mov esp, ebp
	pop ebp
glue endp

arithm proc
	push ebp
	mov ebp, esp
	mov eax, [ebp+12]
plus:
	cmp eax, '+'
	jnz minus
	mov eax, [ebp+8]
	add eax, [ebp+16]
	jmp end_arithm
minus:
	cmp eax, '-'
	jnz time
	mov eax, [ebp+8]
	sub eax, [ebp+16]
	jmp end_arithm
time:
	cmp eax, '*'
	jnz divided
	mov eax, [ebp+8]
	mov ecx, [ebp+16]
	mul ecx
	jmp end_arithm
divided:
	cmp eax, '/'
	jnz end_arithm
	mov eax, [ebp+8]
	mov ecx, [ebp+16]
	div ecx
end_arithm:
	mov esp, ebp
	pop ebp
	ret 12
arithm endp

make_text proc ;grafica
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text

make_digit:
	cmp eax, '0'
	jl make_plus
	cmp eax, '9'
	jg make_plus
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_plus:
	cmp eax, '+'
	jne make_minus
	mov eax, 0
	lea esi, symbols
	jmp draw_text
make_minus:
	cmp eax, '-'
	jne make_times
	mov eax, 1
	lea esi, symbols
	jmp draw_text
make_times:
	cmp eax, "*"
	jne make_divided
	mov eax, 2
	lea esi, symbols
	jmp draw_text
make_divided:
	cmp eax, "/"
	jne make_equal
	mov eax, 3
	lea esi, symbols
	jmp draw_text
make_equal:
	cmp eax, "="
	jne make_space
	mov eax, 4
	lea esi, symbols
	jmp draw_text
	
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0ffffffh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_horizontal_line_macro macro x, y, len, color
local horizontal_line_loop
	mov eax, y ;eax = y
	mov ebx, area_width
	mul ebx ;eax = y * area_width
	add eax, x ;eax = y * area_width + x
	shl eax, 2 ;eax = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
horizontal_line_loop:
	mov dword ptr[eax], color
	add eax, 4
	loop horizontal_line_loop
endm

make_vertical_line_macro macro x, y, len, color
local vertical_line_loop
	mov eax, y ;eax = y
	mov ebx, area_width
	mul ebx ;eax = y * area_width
	add eax, x ;eax = y * area_width + x
	shl eax, 2 ;eax = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
vertical_line_loop:
	mov dword ptr[eax], color
	add eax, area_width * 4
	loop vertical_line_loop
endm

make_button_macro macro x, y, buttonsize, color
	make_horizontal_line_macro x, y, button_size, color
	make_horizontal_line_macro x, y + button_size, button_size, color
	make_vertical_line_macro x, y, button_size, color
	make_vertical_line_macro x + button_size, y, button_size, color
endm

evt_click_buttons_macro macro button_x, button_y, buttonsize, number
local fail_click
	mov eax, [ebp+arg2]
	cmp eax, button_x
	jl fail_click
	cmp eax, button_x + buttonsize
	jg fail_click
	mov eax, [ebp+arg3]
	cmp eax, button_y
	jl fail_click
	cmp eax, button_y + buttonsize
	jg fail_click
	add cursor, 30
	make_text_macro number, area, cursor, 90
	sub cursor, 20
	mov op1, 0
fail_click:
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	mov edi, area
	mov ecx, area_height
	mov ebx, [ebp+arg3]
	and ebx, 7
	inc ebx
	
evt_click_buttons:
	evt_click_buttons_macro button_9_x, button_9_y, button_size, '9'
	evt_click_buttons_macro button_8_x, button_8_y, button_size, '8'
	evt_click_buttons_macro button_7_x, button_7_y, button_size, '7'
	evt_click_buttons_macro button_6_x, button_6_y, button_size, '6'
	evt_click_buttons_macro button_5_x, button_5_y, button_size, '5'
	evt_click_buttons_macro button_4_x, button_4_y, button_size, '4'
	evt_click_buttons_macro button_3_x, button_3_y, button_size, '3'
	evt_click_buttons_macro button_2_x, button_2_y, button_size, '2'
	evt_click_buttons_macro button_1_x, button_1_y, button_size, '1'
	evt_click_buttons_macro button_0_x, button_0_y, button_size, '0'

evt_click_plus: 
	mov eax, [ebp+arg2]
	cmp eax, button_plus_x
	jl evt_click_minus
	cmp eax, button_plus_x + button_size
	jg evt_click_minus
	mov eax, [ebp+arg3]
	cmp eax, button_plus_y
	jl evt_click_minus
	cmp eax, button_plus_y + button_size
	jg evt_click_minus
	cmp op1, 0 ; daca o operatie e activa
	jz plus_over
	sub cursor, 10
plus_over:
	mov op1, 1
	add cursor, 30
	make_text_macro '+', area, cursor , 90
	sub cursor, 20
	

evt_click_minus:
	mov eax, [ebp+arg2]
	cmp eax, button_minus_x
	jl evt_click_times
	cmp eax, button_minus_x + button_size
	jg evt_click_times
	mov eax, [ebp+arg3]
	cmp eax, button_minus_y
	jl evt_click_times
	cmp eax, button_minus_y + button_size
	jg evt_click_times
	cmp op1, 0 ; daca o operatie e activa, sari peste afisare
	jz minus_over
	sub cursor, 10
minus_over:
	mov op1, 2
	add cursor, 30
	make_text_macro '-', area, cursor, 90
	sub cursor, 20
	; cmp op1, 0
	; jz evt_click_times
	; mov op1, 2
	
evt_click_times:
	mov eax, [ebp+arg2]
	cmp eax, button_times_x
	jl evt_click_divided
	cmp eax, button_times_x + button_size
	jg evt_click_divided
	mov eax, [ebp+arg3]
	cmp eax, button_times_y
	jl evt_click_divided
	cmp eax, button_times_y + button_size
	jg evt_click_divided
	cmp op1, 0 ; daca o operatie e activa, sari peste afisare
	jz times_over
	sub cursor, 10
times_over:
	mov op1, 3
	add cursor, 30
	make_text_macro '*', area, cursor, 90
	sub cursor, 20
	; cmp op1, 0
	; jz evt_click_divided
	; mov op1, 3
	
evt_click_divided:
	mov eax, [ebp+arg2]
	cmp eax, button_divided_x
	jl evt_click_equal
	cmp eax, button_divided_x + button_size
	jg evt_click_equal
	mov eax, [ebp+arg3]
	cmp eax, button_divided_y
	jl evt_click_equal
	cmp eax, button_divided_y + button_size
	jg evt_click_equal
	cmp op1, 0 ; daca o operatie e activa, sari peste afisare
	jz divided_over
	sub cursor, 10
divided_over:
	mov op1, 4
	add cursor, 30
	make_text_macro '/', area, cursor, 90
	sub cursor, 20
	; cmp op1, 0
	; jz evt_click_equal
	; mov op1, 4

evt_click_equal:
	mov eax, [ebp+arg2]
	cmp eax, button_equal_x
	jl evt_click_clear
	cmp eax, button_equal_x + button_size
	jg evt_click_clear
	mov eax, [ebp+arg3]
	cmp eax, button_equal_y
	jl evt_click_clear
	cmp eax, button_equal_y + button_size
	jg evt_click_clear
	; cod
	; cmp op2, 0
	; jz evt_click_clear
	; mov op2, 1
	
evt_click_clear:
	mov eax, [ebp+arg2]
	cmp eax, button_clear_x
	jl evt_timer
	cmp eax, button_clear_x + button_size
	jg evt_timer
	mov eax, [ebp+arg3]
	cmp eax, button_clear_y
	jl evt_timer
	cmp eax, button_clear_y + button_size
	jg evt_timer
	
evt_timer:
	inc counter
	
afisare_litere:
	make_text_macro 'W', area, title_x, title_y
	make_text_macro 'I', area, title_x + 10, title_y
	make_text_macro 'N', area, title_x + 20, title_y
	make_text_macro 'D', area, title_x + 30, title_y
	make_text_macro 'O', area, title_x + 40, title_y
	make_text_macro 'S', area, title_x + 50, title_y
	
	make_text_macro 'C', area, title_x + 70, title_y
	make_text_macro 'A', area, title_x + 80, title_y
	make_text_macro 'L', area, title_x + 90, title_y
	make_text_macro 'C', area, title_x + 100, title_y
	make_text_macro 'U', area, title_x + 110, title_y
	make_text_macro 'L', area, title_x + 120, title_y
	make_text_macro 'A', area, title_x + 130, title_y
	make_text_macro 'T', area, title_x + 140, title_y
	make_text_macro 'O', area, title_x + 150, title_y
	make_text_macro 'R', area, title_x + 160, title_y

border:
	make_horizontal_line_macro 0, 0, 480, 0
	make_horizontal_line_macro 0, 40, 480, 0
	make_vertical_line_macro 0, 0, 160, 0
	make_vertical_line_macro 480, 0, 160, 0

buttons:
	make_button_macro button_9_x, button_9_y, button_size, 0
	make_text_macro '9', area, 55, 215
	
	make_button_macro button_8_x, button_8_y, button_size, 0
	make_text_macro '8', area, 175, 215
	
	make_button_macro button_7_x, button_7_y, button_size, 0
	make_text_macro '7', area, 295, 215
	
	make_button_macro button_6_x, button_6_y, button_size, 0
	make_text_macro '6', area, 55, 335
	
	make_button_macro button_5_x, button_5_y, button_size, 0
	make_text_macro '5', area, 175, 335
	
	make_button_macro button_4_x, button_4_y, button_size, 0
	make_text_macro '4', area, 295, 335
	
	make_button_macro button_3_x, button_3_y, button_size, 0
	make_text_macro '3', area, 55, 455
	
	make_button_macro button_2_x, button_2_y, button_size, 0
	make_text_macro '2', area, 175, 455
	
	make_button_macro button_1_x, button_1_y, button_size, 0
	make_text_macro '1', area, 295, 455
	
	make_button_macro button_0_x, button_0_y, button_size, 0
	make_text_macro '0', area, 175, 575
	
	make_button_macro button_plus_x, button_plus_y, button_size, 0
	make_text_macro '+', area, 415, 575
	
	make_button_macro button_minus_x, button_minus_y, button_size, 0
	make_text_macro '-', area, 415, 455
	
	make_button_macro button_times_x, button_times_y, button_size, 0
	make_text_macro '*', area, 415, 335
	
	make_button_macro button_divided_x, button_divided_y, button_size, 0
	make_text_macro '/', area, 415, 215
	
	make_button_macro button_equal_x, button_equal_y, button_size, 0
	make_text_macro '=', area, 295, 575
	
	make_button_macro button_clear_x, button_clear_y, button_size, 0
	make_text_macro 'C', area, 55, 575
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
