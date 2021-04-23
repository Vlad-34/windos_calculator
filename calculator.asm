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

title_start_x equ 155
button_size equ 120

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
make_text proc
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
	mov dword ptr [edi], 0FFFFFFh
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
	
evt_timer:
	inc counter
	
afisare_litere:
	;scriem un mesaj
	make_text_macro 'W', area, title_start_x, 10
	make_text_macro 'I', area, title_start_x + 10, 10
	make_text_macro 'N', area, title_start_x + 20, 10
	make_text_macro 'D', area, title_start_x + 30, 10
	make_text_macro 'O', area, title_start_x + 40, 10
	make_text_macro 'S', area, title_start_x + 50, 10
	
	make_text_macro 'C', area, title_start_x + 70, 10
	make_text_macro 'A', area, title_start_x + 80, 10
	make_text_macro 'L', area, title_start_x + 90, 10
	make_text_macro 'C', area, title_start_x + 100, 10
	make_text_macro 'U', area, title_start_x + 110, 10
	make_text_macro 'L', area, title_start_x + 120, 10
	make_text_macro 'A', area, title_start_x + 130, 10
	make_text_macro 'T', area, title_start_x + 140, 10
	make_text_macro 'O', area, title_start_x + 150, 10
	make_text_macro 'R', area, title_start_x + 160, 10
	
	make_horizontal_line_macro 0, 0, 480, 0
	make_horizontal_line_macro 0, 40, 480, 0
	make_vertical_line_macro 0, 0, 160, 0
	make_vertical_line_macro 480, 0, 160, 0
	
	make_button_macro 0, 160, button_size, 0
	make_text_macro '9', area, 55, 215
	make_button_macro 120, 160, button_size, 0
	make_text_macro '8', area, 175, 215
	make_button_macro 240, 160, button_size, 0
	make_text_macro '7', area, 295, 215
	
	make_button_macro 0, 280, button_size, 0
	make_text_macro '6', area, 55, 335
	make_button_macro 120, 280, button_size, 0
	make_text_macro '5', area, 175, 335
	make_button_macro 240, 280, button_size, 0
	make_text_macro '4', area, 295, 335
	
	make_button_macro 0, 400, button_size, 0
	make_text_macro '3', area, 55, 455
	make_button_macro 120, 400, button_size, 0
	make_text_macro '2', area, 175, 455
	make_button_macro 240, 400, button_size, 0
	make_text_macro '1', area, 295, 455
	
	make_button_macro 0, 520, button_size, 0
	make_text_macro 'C', area, 55, 575
	make_button_macro 120, 520, button_size, 0
	make_text_macro '0', area, 175, 575
	make_button_macro 240, 520, button_size, 0
	make_text_macro '=', area, 295, 575
	
	make_button_macro 360, 40, button_size, 0
	make_text_macro 'D', area, 415, 95
	make_button_macro 360, 160, button_size, 0
	make_text_macro '/', area, 415, 215
	make_button_macro 360, 280, button_size, 0
	make_text_macro '*', area, 415, 335
	make_button_macro 360, 400, button_size, 0
	make_text_macro '-', area, 415, 455
	make_button_macro 360, 520, button_size, 0
	make_text_macro '+', area, 415, 575
	
	
	
	
	
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
