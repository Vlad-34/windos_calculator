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
display_x equ 30
display_y equ 90
cursor equ 0
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

zero dd 0
one dd 1
two dd 2
three dd 3
four dd 4
five dd 5
six dd 6
seven dd 7
eight dd 8
nine dd 9

nr1 dd 0
nr2 dd 0
rez dd 0
op1 dd 0
op2 dd 0 ;egal
ten dd 10

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

stick proc
	push ebp
	mov ebp, esp
	mov eax, [ebp-4]
	mov ebx, ten
	mul ebx
	add eax, [ebp-8]
	mov esp, ebp
	pop ebp
	ret 8 ;cele 2 cifre
stick endp

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

print_number_macro macro nr, cursor
local number0, number1, number2, number3, number4, number5, number6, number7, number8, number9, skip_print, skip_print2, skip_print3
	cmp nr, 0
	je number0
	cmp nr, 1
	je number1
	cmp nr, 2
	je number2
	cmp nr, 3
	je number3
	cmp nr, 4
	je number4
	cmp nr, 5
	je number5
	cmp nr, 6
	je number6
	cmp nr, 7
	je number7
	cmp nr, 8
	je number8
	cmp nr, 9
	je number9
	jmp skip_print
number0:
	make_text_macro '0', area, cursor, display_y
	jmp skip_print
number1:
	make_text_macro '1', area, cursor, display_y
	jmp skip_print
number2:
	make_text_macro '2', area, cursor, display_y
	jmp skip_print
number3:
	make_text_macro '3', area, cursor, display_y
	jmp skip_print
number4:
	make_text_macro '4', area, cursor, display_y
	jmp skip_print
number5:
	make_text_macro '5', area, cursor, display_y
	jmp skip_print
number6:
	make_text_macro '6', area, cursor, display_y
	jmp skip_print
number7:
	make_text_macro '7', area, cursor, display_y
	jmp skip_print
number8:
	make_text_macro '8', area, cursor, display_y
	jmp skip_print
number9:
	make_text_macro '9', area, cursor, display_y
	jmp skip_print
skip_print:
	cmp op2, 1
	je skip_print2
	mov eax, cursor
	add eax, 10
	jmp skip_print3
skip_print2:
	mov eax, cursor
	sub eax, 10
skip_print3:
endm

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

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

; un macro ca sa apelam mai usor desenarea liniilor orizontale
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

; un macro ca sa apelam mai usor desenarea liniilor verticale
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

; un macro ca sa apelam mai usor desenarea butoanelor
make_button_macro macro x, y, buttonsize, color
	make_horizontal_line_macro x, y, button_size, color
	make_horizontal_line_macro x, y + button_size, button_size, color
	make_vertical_line_macro x, y, button_size, color
	make_vertical_line_macro x + button_size, y, button_size, color
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

evt_click_9:
	mov eax, [ebp+arg2]
	cmp eax, button_9_x
	jl evt_click_8
	cmp eax, button_9_x + button_size
	jg evt_click_8
	mov eax, [ebp+arg3]
	cmp eax, button_9_y
	jl evt_click_8
	cmp eax, button_9_y + button_size
	jg evt_click_8
	make_text_macro '9', area, display_x + cursor, display_y
	
evt_click_8:
	mov eax, [ebp+arg2]
	cmp eax, button_8_x
	jl evt_click_7
	cmp eax, button_8_x + button_size
	jg evt_click_7
	mov eax, [ebp+arg3]
	cmp eax, button_8_y
	jl evt_click_7
	cmp eax, button_8_y + button_size
	jg evt_click_7
	make_text_macro '8', area, display_x, display_y
	
evt_click_7:
	mov eax, [ebp+arg2]
	cmp eax, button_7_x
	jl evt_click_6
	cmp eax, button_7_x + button_size
	jg evt_click_6
	mov eax, [ebp+arg3]
	cmp eax, button_7_y
	jl evt_click_6
	cmp eax, button_7_y + button_size
	jg evt_click_6
	make_text_macro '7', area, display_x, display_y

evt_click_6:
	mov eax, [ebp+arg2]
	cmp eax, button_6_x
	jl evt_click_5
	cmp eax, button_6_x + button_size
	jg evt_click_5
	mov eax, [ebp+arg3]
	cmp eax, button_6_y
	jl evt_click_5
	cmp eax, button_6_y + button_size
	jg evt_click_5
	make_text_macro '6', area, display_x, display_y
	
evt_click_5:
	mov eax, [ebp+arg2]
	cmp eax, button_5_x
	jl evt_click_4
	cmp eax, button_5_x + button_size
	jg evt_click_4
	mov eax, [ebp+arg3]
	cmp eax, button_5_y
	jl evt_click_4
	cmp eax, button_5_y + button_size
	jg evt_click_4
	make_text_macro '5', area, display_x, display_y
	
evt_click_4:
	mov eax, [ebp+arg2]
	cmp eax, button_4_x
	jl evt_click_3
	cmp eax, button_4_x + button_size
	jg evt_click_3
	mov eax, [ebp+arg3]
	cmp eax, button_4_y
	jl evt_click_3
	cmp eax, button_4_y + button_size
	jg evt_click_3
	make_text_macro '4', area, display_x, display_y

evt_click_3:
	mov eax, [ebp+arg2]
	cmp eax, button_3_x
	jl evt_click_2
	cmp eax, button_3_x + button_size
	jg evt_click_2
	mov eax, [ebp+arg3]
	cmp eax, button_3_y
	jl evt_click_2
	cmp eax, button_3_y + button_size
	jg evt_click_2
	make_text_macro '3', area, display_x, display_y

evt_click_2:
	mov eax, [ebp+arg2]
	cmp eax, button_2_x
	jl evt_click_1
	cmp eax, button_2_x + button_size
	jg evt_click_1
	mov eax, [ebp+arg3]
	cmp eax, button_2_y
	jl evt_click_1
	cmp eax, button_2_y + button_size
	jg evt_click_1
	make_text_macro '2', area, display_x, display_y
	
evt_click_1:
	mov eax, [ebp+arg2]
	cmp eax, button_1_x
	jl evt_click_0
	cmp eax, button_1_x + button_size
	jg evt_click_0
	mov eax, [ebp+arg3]
	cmp eax, button_1_y
	jl evt_click_0
	cmp eax, button_1_y + button_size
	jg evt_click_0
	make_text_macro '1', area, display_x, display_y
	
evt_click_0:
	mov eax, [ebp+arg2]
	cmp eax, button_0_x
	jl evt_click_plus
	cmp eax, button_0_x + button_size
	jg evt_click_plus
	mov eax, [ebp+arg3]
	cmp eax, button_0_y
	jl evt_click_plus
	cmp eax, button_0_y + button_size
	jg evt_click_plus
	make_text_macro '0', area, display_x, display_y
	
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
	make_text_macro '+', area, display_x + cursor, display_y
	cmp op1, 0
	jz evt_click_minus
	mov op1, 1

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
	make_text_macro '-', area, display_x + cursor, display_y
	cmp op1, 0
	jz evt_click_times
	mov op1, 2
	
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
	make_text_macro '*', area, display_x + cursor, display_y
	cmp op1, 0
	jz evt_click_divided
	mov op1, 3
	
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
	make_text_macro '/', area, display_x + cursor, display_y
	cmp op1, 0
	jz evt_click_equal
	mov op1, 4

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
	make_text_macro '=', area, display_x, display_y
	cmp op2, 0
	jz evt_click_clear
	mov op2, 1
	
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
	make_text_macro 'C', area, display_x, display_y
	
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
