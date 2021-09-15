.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Checkers in ASM",0
area_width EQU 1600
area_height EQU 900
restartbut dd 0

first_x dd 0
first_y dd 0
second_x dd 0
second_y dd 0
clickok dd 0
jucatorok dd 0
openprog dd 0

format DB "%d ",0
format2 DB " ",13,10,0
format3 DB "%d %d %d %d ",13,10,0
button_x EQU 1345
button_y EQU 395
matrice dd 65 dup(0)
scor1 dd 0
scor2 dd 0
scormax1 dd 0
scormax2 dd 0
winner1 dd 0
winner2 dd 0

button_size EQU 80
area DD 0

counter DD 0 ; numara evenimentele de tip timer
counterbut DD 0 ;numara evenimentele de tip timer pentru mesaj ok
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 equ 24
colorfortext EQU 0ffffffh
colorforbgtext EQU 18046d

colorlight EQU 0ffebcdh ;color patratica deschisa
colorbrown EQU 8b3e2fh ;color patratica inchisa
colorpl1 EQU 0  ;color player1 score
colorpl2 EQU 0a70a0ah;color player2 score
symbol_width EQU 10
symbol_height EQU 20

piece_width EQU 70
piece_height EQU 70

line_x EQU 400
line_y EQU 50
line_size equ 800
line_len equ 810
include digits.inc
include letters.inc
include piecesymbol.inc
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
; arg5 - color 
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
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
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
	mov ebx,[ebp+arg5]
	mov dword ptr [edi], ebx
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

color_fill proc  ;coloreaza bg-ul textului
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
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
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
    mov ebx,[ebp+arg5]
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi],ebx
	jmp simbol_pixel_next
simbol_pixel_alb:
    mov ebx,[ebp+arg5]
	mov dword ptr [edi],ebx
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
color_fill endp

color_text proc  ;coloreaza bg-ul textului
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
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
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
	mov ebx,[ebp+arg5]
	mov dword ptr [edi], colorfortext
	jmp simbol_pixel_next
simbol_pixel_alb:
    mov ebx,[ebp+arg5]
	mov dword ptr [edi], ebx
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
color_text endp
; un macro ca sa apelam mai usor desenarea simbolului

draw_piece proc  ;coloreaza bg-ul textului
	push ebp
	mov ebp, esp
	pusha	
    
	mov ebx, piece_width
	mul ebx
	mov ebx, piece_height
	mul ebx
	add esi, eax
	mov ecx, piece_height
	lea esi,piecesymbol
bucla_simbol_linii:
	mov edi, [ebp+arg1] ; pointer la matricea de pixeli
	mov eax, [ebp+arg3] ; pointer la coord y
	add eax, piece_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg2] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, piece_width
	
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov ebx,[ebp+arg4]
	mov dword ptr [edi], ebx
	jmp simbol_pixel_next
	simbol_pixel_alb:
   	mov dword ptr [edi], colorlight
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
draw_piece endp

make_text_macro macro symbol, drawArea, x, y,color
    push color
    push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 20
endm
color_text_macro macro symbol, drawArea, x, y,color
    push color
	push y
	push x
	push drawArea
	push symbol
	call color_text
	add esp, 20
endm
fill_macro macro symbol, drawArea, x, y,color
    push color
	push y
	push x
	push drawArea
	push symbol
	call color_fill
	add esp, 20
endm
line_hor macro x,y,len,color
local bucla_lhor  ;deseneaza linie orizontala
    mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
    add eax, area
	mov ecx,len
bucla_lhor:
   mov dword ptr[eax],color
   add eax,4
  loop bucla_lhor
endm
line_ver macro x,y,len,color
local bucla_line  ;deseneaza linie verticala
    mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
    add eax, area
	mov ecx, len
bucla_line:
   mov dword ptr[eax],color
   add eax, area_width*4
  loop bucla_line
endm
draw_piece_macro macro x,y,color
    push color
	push y
	push x
    push area
	call draw_piece
	add esp,16
endm
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y

fill_sqrtable macro x,y,color,sqrsize ;coloreaza patrat
local filleti,resetx
mov ecx,sqrsize*sqrsize
mov edx,100+x
mov esi,x
mov edi,y
filleti:
  cmp esi,edx
  jle resetx
  mov esi,x
  inc edi
  resetx:
  fill_macro ' ',area,esi,edi,color
  inc esi
    
loop filleti

endm

drawplayer1 macro x,y,score
local finalm,dcifre
  make_text_macro 'P', area, x, y,colorpl1
  make_text_macro 'L', area, x+10, y,colorpl1
  make_text_macro 'A', area, x+20, y,colorpl1
  make_text_macro 'Y', area, x+30, y,colorpl1
  make_text_macro 'E', area, x+40, y,colorpl1
  make_text_macro 'R', area, x+50, y ,colorpl1
  make_text_macro ' ', area, x+60, y,colorpl1
  make_text_macro '1', area, x+70, y,colorpl1
  make_text_macro ' ', area, x+80, y,colorpl1
  make_text_macro 'S', area, x+90, y,colorpl1
  make_text_macro 'C', area, x+100, y,colorpl1
  make_text_macro 'O', area, x+110, y,colorpl1
  make_text_macro 'R', area, x+120, y,colorpl1
  make_text_macro 'E', area, x+130, y,colorpl1
  make_text_macro '.', area, x+140, y,colorpl1
   
  mov ebx,score
  cmp ebx,9
  jg dcifre
  add ebx,'0'
   make_text_macro '0',area,x+150,y,colorpl1
  make_text_macro ebx,area,x+160,y,colorpl1
  jmp finalm
  dcifre:
  mov edx,0
  mov eax,ebx
  mov esi,10
  div esi
  add eax,'0'
  add edx,'0'
  make_text_macro eax,area,x+150,y,colorpl1
  make_text_macro edx,area,x+160,y,colorpl1
  finalm:
endm

drawplayer2 macro x,y,score
local finalm,dcifre
  make_text_macro 'P', area, x, y,colorpl2
  make_text_macro 'L', area, x+10,y, colorpl2
  make_text_macro 'A', area, x+20,y, colorpl2
  make_text_macro 'Y', area, x+30,y, colorpl2
  make_text_macro 'E', area, x+40,y, colorpl2
  make_text_macro 'R', area, x+50,y, colorpl2
  make_text_macro ' ', area, x+60,y, colorpl2
  make_text_macro '2', area, x+70,y, colorpl2
  make_text_macro ' ', area, x+80,y, colorpl2
  make_text_macro 'S', area, x+90,y, colorpl2
  make_text_macro 'C', area, x+100,y, colorpl2
  make_text_macro 'O', area, x+110,y, colorpl2
  make_text_macro 'R', area, x+120,y, colorpl2
  make_text_macro 'E', area, x+130,y, colorpl2
  make_text_macro '.', area, x+140,y,colorpl2
   
  mov ebx,score
  cmp ebx,9
  jg dcifre
  add ebx,'0'
  make_text_macro '0',area,x+150,y,colorpl2
  make_text_macro ebx,area,x+160,y,colorpl2
  jmp finalm
  dcifre:
  mov edx,0
  mov eax,ebx
  mov esi,10
  div esi
  add eax,'0'
  add edx,'0'
  make_text_macro eax,area,x+150,y,colorpl2
  make_text_macro edx,area,x+160,y,colorpl2
  finalm:

endm
resetare_scor macro 
    drawplayer1 85,400,0
	drawplayer2 85,420,0
    
endm
initmat macro 
local loop1,loop2,loop3,loop4,loop5,loop6,loop7,down,loopinit
    mov ecx,64
	mov esi,0
    loopinit: 
     
	mov matrice[esi*4],0
	inc esi
	loop loopinit
	
    mov ecx,4             
	mov esi,1
	loop1:
	mov matrice[esi*4],1
	add esi,2
	loop loop1 ;0 1 0 1 0 1 0 1
    
	mov ecx,4
	mov esi,8
	loop2:
	mov matrice[esi*4],1 ;1 0 1 0 1 0 1 0
	add esi,2
	loop loop2
	
	mov ecx,4
	mov esi,17
	loop3:
	mov matrice[esi*4],1 ;0 1 0 1 0 1 0 1
	add esi,2
	loop loop3
	
	mov ecx,4
	mov esi,40
	loop4:
	mov matrice[esi*4], 2 ;2 0 2 0 2 0 2 0
	add esi,2
	loop loop4
     
	mov ecx,4
	mov esi,49
	loop5:
	mov matrice[esi*4], 2 ;0 2 0 2 0 2 0 2
	add esi,2
	loop loop5
	
	mov ecx,4
	mov esi,56
	loop6:
	mov matrice[esi*4], 2 ;2 0 2 0 2 0 2 0
	add esi,2
	loop loop6
	
	 ; mov ebx,65
	 ; mov esi,0
	 ; mov edi,0
	 ; loop7:
	     ; mov ecx,ebx
	     ; push matrice[esi*4]
		 ; push offset format
		 ; call printf
		 ; inc edi
		 ; cmp edi,8
		 ; jne down
		 ; push offset format2
		 ; call printf
		 ; mov edi,0
		 ; down:
		 
		 ; inc esi
		 ; dec ebx
		 ; mov ecx,ebx
	 ; loop loop7 
	
endm

line_hor macro x,y,len,color                           ;;functie pentru linie orizontala
local bucla_line
   mov eax,y
   mov ebx, area_width
   mul ebx
   add eax, x
   shl eax,2 
   add eax,area
   mov ecx, len
bucla_line:
    mov dword ptr[eax],color
	add eax,4
	loop bucla_line
endm
playcode macro 

endm

drawtable macro 
    make_text_macro 'C', area, 120, 115,colorfortext
	make_text_macro 'H', area, 130, 115,colorfortext
	make_text_macro 'E', area, 140, 115,colorfortext
	make_text_macro 'C', area, 150, 115,colorfortext
	make_text_macro 'K', area, 160, 115 ,colorfortext
	make_text_macro 'E', area, 170, 115 ,colorfortext
	make_text_macro 'R', area, 180, 115 ,colorfortext
	make_text_macro 'S', area, 190, 115 ,colorfortext
	color_text_macro 'C', area, 120, 115,colorforbgtext    ;coloreaza bg-ul textului 
	color_text_macro 'H', area, 130, 115,colorforbgtext
	color_text_macro 'E', area, 140, 115,colorforbgtext
	color_text_macro 'C', area, 150, 115,colorforbgtext
	color_text_macro 'K', area, 160, 115,colorforbgtext
	color_text_macro 'E', area, 170, 115,colorforbgtext
	color_text_macro 'R', area, 180, 115,colorforbgtext
	color_text_macro 'S', area, 190, 115,colorforbgtext
	
	make_text_macro 'R', area, 1352, 420 ,colorfortext 
	make_text_macro 'E', area, 1362, 420 ,colorfortext
	make_text_macro 'S', area, 1372, 420 ,colorfortext
	make_text_macro 'T', area, 1382, 420 ,colorfortext
	make_text_macro 'A', area, 1392, 420 ,colorfortext
	make_text_macro 'R', area, 1402, 420 ,colorfortext
	make_text_macro 'T', area, 1412, 420 ,colorfortext
	color_text_macro 'R', area, 1352, 420,colorforbgtext   ;coloreaza bg-ul textului 
	color_text_macro 'E', area, 1362, 420,colorforbgtext
	color_text_macro 'S', area, 1372, 420,colorforbgtext
	color_text_macro 'T', area, 1382, 420,colorforbgtext
	color_text_macro 'A', area, 1392, 420,colorforbgtext
	color_text_macro 'R', area, 1402, 420,colorforbgtext
	color_text_macro 'T', area, 1412, 420,colorforbgtext
	
	line_hor 104,110,110,05e2c02h ;upline 
	line_hor 104,109,110,05e2c02h ;upline 
	line_hor 104,108,110,05e2c02h ;downline
	line_hor 104,107,110,05e2c02h ;downline
	line_ver 211,110,30,05e2c02h ;right vertical
	line_ver 212,110,30,05e2c02h ;right vertical
	line_ver 213,110,30,05e2c02h ;right vertical
	line_ver 106,110,30,05e2c02h ;left vertical
	line_ver 105,110,30,05e2c02h ;left vertical
	line_ver 104,110,30,05e2c02h ;left vertical
	line_hor 104,140,110,05e2c02h ;downline 
	line_hor 104,141,110,05e2c02h ;downline
    line_hor 104,142,110,05e2c02h ;downline 	
	line_hor 104,143,110,05e2c02h ;downline
	;desenare tabla
		
	fill_sqrtable 400,50,colorbrown,100
	fill_sqrtable 500,50,colorlight,100
	fill_sqrtable 600,50,colorbrown,100
	fill_sqrtable 700,50,colorlight,100
	fill_sqrtable 800,50,colorbrown,100
	fill_sqrtable 900,50,colorlight,100
	fill_sqrtable 1000,50,colorbrown,100
	fill_sqrtable 1100,50,colorlight,100
	fill_sqrtable 400,150,colorlight,100
	fill_sqrtable 500,150,colorbrown,100
	fill_sqrtable 600,150,colorlight,100
	fill_sqrtable 700,150,colorbrown,100
	fill_sqrtable 800,150,colorlight,100
	fill_sqrtable 900,150,colorbrown,100
	fill_sqrtable 1000,150,colorlight,100
	fill_sqrtable 1100,150,colorbrown,100
	
	fill_sqrtable 400,250,colorbrown,100
	fill_sqrtable 500,250,colorlight,100
	fill_sqrtable 600,250,colorbrown,100
	fill_sqrtable 700,250,colorlight,100
	fill_sqrtable 800,250,colorbrown,100
	fill_sqrtable 900,250,colorlight,100
	fill_sqrtable 1000,250,colorbrown,100
	fill_sqrtable 1100,250,colorlight,100
	fill_sqrtable 400,350,colorlight,100
	fill_sqrtable 500,350,colorbrown,100
	fill_sqrtable 600,350,colorlight,100
	fill_sqrtable 700,350,colorbrown,100
	fill_sqrtable 800,350,colorlight,100
	fill_sqrtable 900,350,colorbrown,100
	fill_sqrtable 1000,350,colorlight,100
	fill_sqrtable 1100,350,colorbrown,100
	
	fill_sqrtable 400,450,colorbrown,100
	fill_sqrtable 500,450,colorlight,100
	fill_sqrtable 600,450,colorbrown,100
	fill_sqrtable 700,450,colorlight,100
	fill_sqrtable 800,450,colorbrown,100
	fill_sqrtable 900,450,colorlight,100
	fill_sqrtable 1000,450,colorbrown,100
	fill_sqrtable 1100,450,colorlight,100
	fill_sqrtable 400,550,colorlight,100
	fill_sqrtable 500,550,colorbrown,100
	fill_sqrtable 600,550,colorlight,100
	fill_sqrtable 700,550,colorbrown,100
	fill_sqrtable 800,550,colorlight,100
	fill_sqrtable 900,550,colorbrown,100
	fill_sqrtable 1000,550,colorlight,100
	fill_sqrtable 1100,550,colorbrown,100
	
	fill_sqrtable 400,650,colorbrown,100
	fill_sqrtable 500,650,colorlight,100
	fill_sqrtable 600,650,colorbrown,100
	fill_sqrtable 700,650,colorlight,100
	fill_sqrtable 800,650,colorbrown,100
	fill_sqrtable 900,650,colorlight,100
	fill_sqrtable 1000,650,colorbrown,100
	fill_sqrtable 1100,650,colorlight,100
	fill_sqrtable 400,750,colorlight,100
	fill_sqrtable 500,750,colorbrown,100
	fill_sqrtable 600,750,colorlight,100
	fill_sqrtable 700,750,colorbrown,100
	fill_sqrtable 800,750,colorlight,100
	fill_sqrtable 900,750,colorbrown,100
	fill_sqrtable 1000,750,colorlight,100
	fill_sqrtable 1100,750,colorbrown,100
	
	line_hor line_x,line_y-4,line_len,05e2c02h ;upline 
	line_hor line_x,line_y-3,line_len,05e2c02h ;upline 
	line_hor line_x,line_y-2,line_len,05e2c02h ;upline 
	line_hor line_x,line_y-1,line_len,05e2c02h ;upline 
	line_hor line_x,line_y,line_len,05e2c02h ;upline   
	line_hor line_x,line_y+1,line_len,05e2c02h ;upline
	line_hor line_x,line_y+2,line_len,05e2c02h ;upline
	line_hor line_x,line_y+3,line_len,05e2c02h ;upline
    line_hor line_x,line_y+4,line_len,05e2c02h ;upline
	line_hor line_x,line_y+5,line_len,05e2c02h ;upline
	line_hor line_x,line_y+line_size+18,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+17,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+16,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+15,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+14,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+13,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+12,line_len+1,0FFFFFFh; bottomline
	line_hor line_x,line_y+line_size+11,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+10,line_len+1,0FFFFFFh; bottomline
	line_hor line_x,line_y+line_size+9,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+8,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+7,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+6,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+5,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+4,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+3,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+2,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size+1,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size,line_len+1,0FFFFFFh ; bottomline
	line_hor line_x,line_y+line_size-1,line_len+1,0FFFFFFh ; bottomline
	
	
	; line_ver line_x+line_len+24,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+23,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+22,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+21,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+20,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+19,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+18,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+17,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+16,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+15,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+14,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+13,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+12,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+11,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+10,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+9,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+8,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+7,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+6,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+5,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+4,line_y-4,line_len-2,05e2c02h ;right vertical
	; line_ver line_x+line_len+3,line_y-4,line_len-2,05e2c02h ;right vertical
	line_ver line_x+line_len+2,line_y-4,line_len-2,05e2c02h ;right vertical
	line_ver line_x+line_len+1,line_y-4,line_len-2,05e2c02h ;right vertical
	line_ver line_x+line_len,  line_y-4,line_len-2,05e2c02h;right vertical
	line_ver line_x+line_len-1,line_y-4,line_len-2,05e2c02h ;right vertical
	line_ver line_x+line_len-2,line_y-4,line_len-2,05e2c02h;right vertical
	line_ver line_x+line_len-3,line_y-4,line_len-2,05e2c02h ;right vertical
	line_ver line_x+line_len-4,line_y-4,line_len-2,05e2c02h;right vertical
	line_ver line_x+line_len-5,line_y-4,line_len-2,05e2c02h ;right vertical
	line_ver line_x+line_len-6,line_y-4,line_len-2,05e2c02h ;right vertical
	line_ver line_x+line_len-7,line_y-4,line_len-2,05e2c02h ;right vertical
	
	line_ver line_x,line_y,line_len-6 ,05e2c02h ;left vertical 
	line_ver line_x+1,line_y,line_len-6 ,05e2c02h ;left vertical 
	line_ver line_x+2,line_y,line_len-6,05e2c02h ;left vertical 
	line_ver line_x+3,line_y,line_len-6,05e2c02h ;left vertical 
	line_ver line_x+4,line_y,line_len-6,05e2c02h ;left vertical 
	line_ver line_x+5,line_y,line_len-6,05e2c02h ;left vertical 
    line_ver line_x+6,line_y,line_len-6,05e2c02h ;left vertical 
    line_ver line_x+7,line_y,line_len-6,05e2c02h ;left vertical 
	line_ver line_x+8,line_y,line_len-6,05e2c02h ;left vertical 

	line_hor line_x,line_y+line_size+3,line_len,05e2c02h ; bottomline
    line_hor line_x,line_y+line_size+2,line_len,05e2c02h ; bottomline
	line_hor line_x,line_y+line_size+1,line_len,05e2c02h ; bottomline
	line_hor line_x,line_y+line_size,line_len,05e2c02h ; bottomline
	line_hor line_x,line_y+line_size-1,line_len,05e2c02h ; bottomline
	line_hor line_x,line_y+line_size-2,line_len,05e2c02h ; bottomline
	line_hor line_x,line_y+line_size-3,line_len,05e2c02h ; bottomline
	line_hor line_x,line_y+line_size-4,line_len,05e2c02h ; bottomline
	line_hor line_x,line_y+line_size-5,line_len,05e2c02h ; bottomline
	line_hor line_x,line_y+line_size-6,line_len,05e2c02h ; bottomline
    	
	
	;restart button
	line_hor button_x,button_y,button_size+1,05e2c02h ;upline
	line_hor button_x,button_y+1,button_size+1,05e2c02h ;upline
	line_hor button_x,button_y+2,button_size+1,05e2c02h ;upline
	line_ver button_x,button_y,button_size ,05e2c02h ;left vertical 
	line_ver button_x+1,button_y,button_size ,05e2c02h ;left vertical 
	line_ver button_x+2,button_y,button_size ,05e2c02h ;left vertical 
	line_ver button_x+button_size+1,button_y,button_size+3,05e2c02h ;right vertical
	line_ver button_x+button_size+2,button_y,button_size+3,05e2c02h ;right vertical
	line_ver button_x+button_size+3,button_y,button_size+3,05e2c02h ;right vertical
	line_hor button_x,button_y+button_size,button_size+1,05e2c02h ; bottomline
	line_hor button_x,button_y+button_size+1,button_size+1,05e2c02h ; bottomline
	line_hor button_x,button_y+button_size+2,button_size+1,05e2c02h ; bottomline
	
	make_text_macro 'A',area,445,860,05e2c02h
	make_text_macro 'B',area,545,860,05e2c02h
	make_text_macro 'C',area,645,860,05e2c02h
	make_text_macro 'D',area,745,860,05e2c02h
	make_text_macro 'E',area,845,860,05e2c02h
	make_text_macro 'F',area,945,860,05e2c02h
	make_text_macro 'G',area,1045,860,05e2c02h
	make_text_macro 'H',area,1145,860,05e2c02h
	
	make_text_macro 'A',area,445,20,05e2c02h
	make_text_macro 'B',area,545,20,05e2c02h
	make_text_macro 'C',area,645,20,05e2c02h
	make_text_macro 'D',area,745,20,05e2c02h
	make_text_macro 'E',area,845,20,05e2c02h
	make_text_macro 'F',area,945,20,05e2c02h
	make_text_macro 'G',area,1045,20,05e2c02h
	make_text_macro 'H',area,1145,20,05e2c02h
	
	
	
	make_text_macro '1',area,380,90  ,05e2c02h
	make_text_macro '2',area,380,190,05e2c02h
	make_text_macro '3',area,380,290,05e2c02h
	make_text_macro '4',area,380,390,05e2c02h
	make_text_macro '5',area,380,490,05e2c02h
	make_text_macro '6',area,380,590,05e2c02h
	make_text_macro '7',area,380,690,05e2c02h
	make_text_macro '8',area,380,790,05e2c02h
	
	make_text_macro '1',area,1220,90  ,05e2c02h
	make_text_macro '2',area,1220,190,05e2c02h
	make_text_macro '3',area,1220,290,05e2c02h
	make_text_macro '4',area,1220,390,05e2c02h
	make_text_macro '5',area,1220,490,05e2c02h
	make_text_macro '6',area,1220,590,05e2c02h
	make_text_macro '7',area,1220,690,05e2c02h
	make_text_macro '8',area,1220,790,05e2c02h
        draw_piece_macro 415,760,0
		draw_piece_macro 515,660 ,0
		draw_piece_macro 615,760,0
		draw_piece_macro 715,660 ,0
		draw_piece_macro 815,760,0
		draw_piece_macro 915,660 ,0
		draw_piece_macro 1115,660 ,0
		draw_piece_macro 1015,760,0
		draw_piece_macro 415,560,0
		draw_piece_macro 615,560,0
		draw_piece_macro 815,560,0
		draw_piece_macro 1015,560,0
		
		draw_piece_macro 515,60,0a70a0ah
		draw_piece_macro 716,60 ,0a70a0ah
		draw_piece_macro 915,60,0a70a0ah
		draw_piece_macro 1115,60 ,0a70a0ah
		draw_piece_macro 415,160,0a70a0ah
		draw_piece_macro 615,160 ,0a70a0ah
		draw_piece_macro 815,160 ,0a70a0ah
		draw_piece_macro 1015,160,0a70a0ah
		draw_piece_macro 515,260,0a70a0ah
		draw_piece_macro 715,260,0a70a0ah
		draw_piece_macro 915,260,0a70a0ah
		draw_piece_macro 1115,260,0a70a0ah
		drawplayer1 85,400,scor1
		drawplayer2 85,420,scor2

endm
stergepiesa macro x,y
     draw_piece_macro x,y,colorlight
	  
endm
stergepieseinamic2 macro
local player2win,final,sterge2,sterge1
local next1,next2,next3,next4,next5,next6,next7,next8,next9,next10,next11,next12,next13,next14,next15
local next16,next17,next18,next19,next20,next21,next22,next23,next24,next25,next26,next27,next28,next29,next30,next31,next32
	cmp matrice[1*4],1
	jne next1
	stergepiesa 515,60
	mov matrice[1*4],0
	next1:
	cmp matrice[3*4],1
	jne next2
	stergepiesa 715,60
	mov matrice[3*4],0
	next2:
	cmp matrice[5*4],1
	jne next3
	stergepiesa 915,60
	mov matrice[5*4],0
	next3:
	cmp matrice[7*4],1
	jne next4
	stergepiesa 1115,60
	mov matrice[7*4],0
	next4:
	cmp matrice[8*4],1
	jne next5
	stergepiesa 415,160
	mov matrice[8*4],0
	next5:
	cmp matrice[10*4],1
	jne next6
	stergepiesa 615,160
	mov matrice[10*4],0
	next6:
	cmp matrice[12*4],1
	jne next7
	stergepiesa 815,160
	mov matrice[12*4],0
	next7:
	cmp matrice[14*4],1
	jne next8
	stergepiesa 1015,160
	mov matrice[14*4],0
	next8:
	cmp matrice[17*4],1
	jne next9
	stergepiesa 515,260
	mov matrice[17*4],0
	next9:
	cmp matrice[19*4],1
	jne next10
	stergepiesa 715,260
	mov matrice[19*4],0
	next10:
	cmp matrice[21*4],1
	jne next11
	stergepiesa 915,260
	mov matrice[21*4],0
	next11:
	cmp matrice[23*4],1
	jne next12
	stergepiesa 1115,260
	mov matrice[23*4],0
	next12:
	cmp matrice[24*4],1
	jne next13
	stergepiesa 415,360
	mov matrice[24*4],0
	next13:
	cmp matrice[26*4],1
	jne next14
	stergepiesa 615,360
	mov matrice[26*4],0
	next14:
	cmp matrice[28*4],1
	jne next15
	stergepiesa 815,360
	mov matrice[28*4],0
	next15:
	cmp matrice[30*4],1
	jne next16
	stergepiesa 1015,360
	mov matrice[30*4],0
	next16:
	cmp matrice[33*4],1
	jne next17
	stergepiesa 515,460
	mov matrice[33*4],0
	next17:
	cmp matrice[35*4],1
	jne next18
	stergepiesa 715,460
	mov matrice[35*4],0
	next18:
	cmp matrice[37*4],1
	jne next19
	stergepiesa 915,460
	mov matrice[37*4],0
	next19:
	cmp matrice[39*4],1
	jne next20
	stergepiesa 1115,460
	mov matrice[39*4],0
	next20:
	cmp matrice[40*4],1
	jne next21
	stergepiesa 415,560
	mov matrice[40*4],0
	next21:
	cmp matrice[42*4],1
	jne next22
	stergepiesa 615,560
	mov matrice[42*4],0
	next22:
	cmp matrice[44*4],1
	jne next23
	stergepiesa 815,560
	mov matrice[44*4],0
	next23:
	cmp matrice[46*4],1
	jne next24
	stergepiesa 1015,560
	mov matrice[46*4],0
	next24:
	cmp matrice[49*4],1
	jne next25
	stergepiesa 515,660
	mov matrice[49*4],0
	next25:
	cmp matrice[51*4],1
	jne next26
	stergepiesa 715,660
	mov matrice[51*4],0
	next26:
	cmp matrice[53*4],1
	jne next27
	stergepiesa 915,660
	mov matrice[53*4],0
	next27:
	cmp matrice[55*4],1
	jne next28
	stergepiesa 1115,660
	mov matrice[55*4],0
	next28:
	
endm
stergepieseinamic1 macro
local player2win,final,sterge2,sterge1
local next1,next2,next3,next4,next5,next6,next7,next8,next9,next10,next11,next12,next13,next14,next15
local next16,next17,next18,next19,next20,next21,next22,next23,next24,next25,next26,next27,next28,next29,next30,next31,next32
	cmp matrice[1*4],2
	jne next1
	stergepiesa 515,60
	mov matrice[1*4],0
	next1:
	cmp matrice[3*4],2
	jne next2
	mov matrice[3*4],0
	stergepiesa 715,60
	mov matrice[3*4],0
	next2:
	cmp matrice[5*4],2
	jne next3
	stergepiesa 915,60
	mov matrice[5*4],0
	next3:
	cmp matrice[7*4],2
	jne next4
	stergepiesa 1115,60
	mov matrice[7*4],0
	next4:
	cmp matrice[8*4],2
	jne next5
	stergepiesa 415,160
	mov matrice[8*4],0
	next5:
	cmp matrice[10*4],2
	jne next6
	stergepiesa 615,160
	mov matrice[10*4],0
	next6:
	cmp matrice[12*4],2
	jne next7
	stergepiesa 815,160
	mov matrice[12*4],0
	next7:
	cmp matrice[14*4],2
	jne next8
	stergepiesa 1015,160
	mov matrice[14*4],0
	next8:
	cmp matrice[17*4],2
	jne next9
	stergepiesa 515,260
	mov matrice[17*4],0
	next9:
	cmp matrice[19*4],2
	jne next10
	stergepiesa 715,260
	mov matrice[19*4],0
	next10:
	cmp matrice[21*4],2
	jne next11
	stergepiesa 915,260
	mov matrice[21*4],0
	next11:
	cmp matrice[23*4],2
	jne next12
	stergepiesa 1115,260
	mov matrice[23*4],0
	next12:
	cmp matrice[24*4],2
	jne next13
	stergepiesa 415,360
	mov matrice[24*4],0
	next13:
	cmp matrice[26*4],2
	jne next14
	stergepiesa 615,360
	mov matrice[26*4],0
	next14:
	cmp matrice[28*4],2
	jne next15
	stergepiesa 815,360
	mov matrice[28*4],0
	next15:
	cmp matrice[30*4],2
	jne next16
	stergepiesa 1015,360
	mov matrice[30*4],0
	next16:
	cmp matrice[33*4],2
	jne next17
	stergepiesa 515,460
	mov matrice[33*4],0
	next17:
	cmp matrice[35*4],2
	jne next18
	stergepiesa 715,460
	mov matrice[35*4],0
	next18:
	cmp matrice[37*4],2
	jne next19
	stergepiesa 915,460
	mov matrice[37*4],0
	next19:
	cmp matrice[39*4],2
	jne next20
	stergepiesa 1115,460
	mov matrice[39*4],0
	next20:
	cmp matrice[40*4],2
	jne next21
	stergepiesa 415,560
	mov matrice[40*4],0
	next21:
	cmp matrice[42*4],2
	jne next22
	stergepiesa 615,560
	mov matrice[42*4],0
	next22:
	cmp matrice[44*4],2
	jne next23
	stergepiesa 815,560
	mov matrice[44*4],0
	next23:
	cmp matrice[46*4],2
	jne next24
	stergepiesa 1015,560
	mov matrice[46*4],0
	next24:
	cmp matrice[49*4],2
	jne next25
	stergepiesa 515,660
	mov matrice[49*4],0
	next25:
	cmp matrice[51*4],2
	jne next26
	stergepiesa 715,660
	mov matrice[51*4],0
	next26:
	cmp matrice[53*4],2
	jne next27
	stergepiesa 915,660
	mov matrice[53*4],0
	next27:
	cmp matrice[55*4],2
	jne next28
	stergepiesa 1115,660
	mov matrice[55*4],0
	next28:
	cmp matrice[56*4],2
	jne next29
	stergepiesa 415,760
	mov matrice[56*4],0
	next29:
	cmp matrice[58*4],2
	jne next30
	stergepiesa 615,760
	mov matrice[58*4],0
	next30:
	cmp matrice[60*4],2
	jne next31
	stergepiesa 815,760
	mov matrice[60*4],0
	next31:
	cmp matrice[62*4],2
	jne next32
	stergepiesa 1015,760
	mov matrice[62*4],0
	next32:
	
endm
testpiesarosie macro x1,y1,x2,y2
local out1,out3,out5,out7,out8,out10,out12,out14,out16,out17,out19,out21,out23,out24,out26,out28,out30,out33,out35,out37,out39,out40,out42,out44,out46,out49,out51,out53,out55,out56,out58,out60,out62
local int11,int2,int33,int4,int5,int6,int7,int8,int9,int10,int11,int12,int13,int14,int15,int16,int17,int18,int19,int20,int21,int22,int23,int24,int25,int26,int27,int28,int29,int30,int31,int32
local capt1,capt2,capt3,capt4,capt5,capt6,capt7,capt8,capt9,capt10,capt11,capt12,capt13,capt14,capt15,capt16,capt17,capt18,capt19,capt20,capt21,capt22,capt23,capt24,capt25,capt26,capt27,capt28,capt29,capt30,capt31,capt32 
local etii1,etii2,etii3,etii4,etii5,etii6,etii7,etii8,etii9,etii10,etii11,etii12,etii13,etii14,etii15,etii16,etii17,etii18,etii19,etii20,etii21,etii22,etii23,etii24,etii25,etii26,etii27,etii28,etii29,etii30,etii31,etii32,etiii33,etii34,etiii35  
   ;patratul 1
   cmp matrice[1*4],1 ;daca nu este piesa neagra pe patrat 
   jne out1
   cmp x1,500   ;verif daca s-a dat click in patratul 42
   jl out1
   cmp x1,599 
   jg out1
   cmp y1,49
   jl out1
   cmp y1,149
   jg out1
      
   cmp x2,400  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int111
   cmp x2,499
   jg int111
   cmp y2,149
   jl int111
   cmp y2,249
   jg int111
   cmp matrice[8*4],0 ;verif daca patratul e gol (stanga)
   
   jne int111
   mov matrice[8*4],1
   mov matrice[1*4],0
   draw_piece_macro 415,160,0a70a0ah
   stergepiesa 515, 60 
   mov jucatorok,0
   player1turn
   int111:
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out1 
   cmp x2,699
   jg out1 
   cmp y2,149
   jl out1 
   cmp y2,249
   jg out1 
   cmp matrice[10*4],0 ;verif daca patratul e gol (dreapta)
   jne capt1
   jmp etii1
capt1:
   cmp matrice[10*4],2
   jne out1
   cmp matrice[19*4],0
   jne out1
   mov matrice[19*4],1
   mov matrice[10*4],0
   mov matrice[1*4],0
   draw_piece_macro 715, 260,0a70a0ah
   stergepiesa 615,160
   stergepiesa 515, 60
   inc scor2
   player2turn
   jmp out1
   
   etii1:
    
   mov matrice[10*4],1
   mov matrice[1*4],0
   draw_piece_macro 615,160,0a70a0ah
   stergepiesa 515, 60  
   mov jucatorok,0
   player1turn  
     
   out1:
   
   ;patratul 3
   cmp matrice[3*4],1 ;daca nu este piesa neagra pe patrat 
   jne out3
   cmp x1,700   ;verif daca s-a dat click in patratul 42
   jl out3
   cmp x1,799 
   jg out3
   cmp y1,49
   jl out3
   cmp y1,149
   jg out3
      
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int222
   cmp x2,699
   jg int222
   cmp y2,149
   jl int222
   cmp y2,249
   jg int222
   cmp matrice[10*4],0 ;verif daca patratul e gol (stanga)
   jne capt2
   jmp etii2
capt2:
   cmp matrice[10*4],2
   jne out3
   cmp matrice[17*4],0
   jne out3
   mov matrice[17*4],1
   mov matrice[10*4],0
   mov matrice[3*4],0
   draw_piece_macro 515, 260,0a70a0ah
   stergepiesa 615,160
   stergepiesa 715, 60
   inc scor2
   player2turn
   jmp out3
   
   etii2:
    
   jne int222
   mov matrice[10*4],1
   mov matrice[3*4],0
   draw_piece_macro 615,160,0a70a0ah
   stergepiesa 715, 60 
   mov jucatorok,0
   player1turn
   int222:
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out3 
   cmp x2,899
   jg out3 
   cmp y2,149
   jl out3
   cmp y2,249
   jg out3 
   cmp matrice[12*4],0 ;verif daca patratul e gol (dreapta)
   jne capt3
   jmp etii3
capt3:
   cmp matrice[12*4],2
   jne out3
   cmp matrice[21*4],0
   jne out3
   mov matrice[21*4],1
   mov matrice[12*4],0
   mov matrice[3*4],0
   draw_piece_macro 915, 260,0a70a0ah
   stergepiesa 815,160
   stergepiesa 715, 60
   player2turn
   inc scor2
   jmp out3
   
   etii3:
    
   
   mov matrice[12*4],1
   mov matrice[3*4],0
   draw_piece_macro 815,160,0a70a0ah
   stergepiesa 715, 60  
   player1turn
   mov jucatorok,0
     
     
   out3:
   
   ;patratul 5
   cmp matrice[5*4],1 ;daca nu este piesa neagra pe patrat 
   jne out5
   cmp x1,900   ;verif daca s-a dat click in patratul 42
   jl out5
   cmp x1,999 
   jg out5
   cmp y1,49
   jl out5
   cmp y1,149
   jg out5
      
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int333
   cmp x2,899
   jg int333
   cmp y2,149
   jl int333
   cmp y2,249
   jg int333
   cmp matrice[12*4],0 ;verif daca patratul e gol (stanga)
   jne capt4
   jmp etii4
capt4:
   cmp matrice[12*4],2
   jne out5
   cmp matrice[19*4],0
   jne out5
   mov matrice[19*4],1
   mov matrice[12*4],0
   mov matrice[5*4],0
   draw_piece_macro 715, 260,0a70a0ah
   stergepiesa 815,160
   stergepiesa 915, 60
   player2turn
   inc scor2
   jmp out5
   
   etii4:
    
   mov matrice[12*4],1
   mov matrice[5*4],0
   draw_piece_macro 815,160,0a70a0ah
   stergepiesa 915, 60
   mov jucatorok,0   
   player1turn
   int333:
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out5
   cmp x2,1099
   jg out5
   cmp y2,149
   jl out5
   cmp y2,249
   jg out5 
   cmp matrice[14*4],0 ;verif daca patratul e gol (dreapta)
   jne capt5
   jmp etii5
capt5:
   cmp matrice[14*4],2
   jne out5
   cmp matrice[23*4],0
   jne out5
   mov matrice[23*4],1
   mov matrice[14*4],0
   mov matrice[5*4],0
   draw_piece_macro 1115, 260,0a70a0ah
   stergepiesa 1015,160
   stergepiesa 915, 60
   player2turn
   inc scor2
   jmp out5
   
   etii5:
     
   mov matrice[14*4],1
   mov matrice[5*4],0
   draw_piece_macro 1015,160,0a70a0ah
   stergepiesa 915, 60 
   player1turn   
   mov jucatorok,0
     
     
   out5:
   
   ;patratul 7
   cmp matrice[7*4],1 ;daca nu este piesa neagra pe patrat 
   jne out7
   cmp x1,1100   ;verif daca s-a dat click in patratul 42
   jl out7
   cmp x1,1199 
   jg out7
   cmp y1,49
   jl out7
   cmp y1,149
   jg out7
      
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out7
   cmp x2,1099
   jg out7
   cmp y2,149
   jl out7
   cmp y2,249
   jg out7
   cmp matrice[14*4],0 ;verif daca patratul e gol (stanga)
   jne capt6
   jmp etii6
capt6:
   cmp matrice[14*4],2
   jne out7
   cmp matrice[21*4],0
   jne out7
   mov matrice[21*4],1
   mov matrice[14*4],0
   mov matrice[7*4],0
   draw_piece_macro 915, 260,0a70a0ah
   stergepiesa 1015,160
   stergepiesa 1115, 60
   player2turn
   inc scor2
   jmp out7
   
   etii6:
   mov matrice[14*4],1
   mov matrice[7*4],0
   draw_piece_macro 1015,160,0a70a0ah
   stergepiesa 1115, 60 
   mov jucatorok,0     
   player1turn
   out7:
   
   ;patratul 8
   cmp matrice[8*4],1 ;daca nu este piesa neagra pe patrat 
   jne out8
   cmp x1,400   ;verif daca s-a dat click in patratul 42
   jl out8
   cmp x1,499 
   jg out8
   cmp y1,149
   jl out8
   cmp y1,249
   jg out8
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out8
   cmp x2,599
   jg out8
   cmp y2,249
   jl out8
   cmp y2,349
   jg out8
   cmp matrice[17*4],0 ;verif daca patratul e gol (dreapta)
   jne capt7
   jmp etii7
capt7:
   cmp matrice[17*4],2
   jne out8
   cmp matrice[26*4],0
   jne out8
   mov matrice[26*4],1
   mov matrice[17*4],0
   mov matrice[8*4],0
   draw_piece_macro 615, 360,0a70a0ah
   stergepiesa 515,260
   stergepiesa 415, 160
   player2turn
   inc scor2
   jmp out8
   
   etii7:
    
   mov matrice[17*4],1
   mov matrice[8*4],0
   draw_piece_macro 515,260,0a70a0ah
   stergepiesa 415,160 
   player1turn
   mov jucatorok,0
     
   out8:
  
   ;patratul 10
   cmp matrice[10*4],1 ;daca nu este piesa neagra pe patrat 
   jne out10
   cmp x1,600   ;verif daca s-a dat click in patratul 42
   jl out10
   cmp x1,699 
   jg out10
   cmp y1,149
   jl out10
   cmp y1,249
   jg out10
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int12
   cmp x2,599
   jg int12
   cmp y2,249
   jl int12
   cmp y2,349
   jg int12
   cmp matrice[17*4],0 ;verif daca patratul e gol (stanga)
   jne capt8
   jmp etii8
capt8:
   cmp matrice[17*4],2
   jne out10
   cmp matrice[24*4],0
   jne out10
   mov matrice[24*4],1
   mov matrice[17*4],0
   mov matrice[10*4],0
   draw_piece_macro 415, 360,0a70a0ah
   stergepiesa 515,260
   stergepiesa 615, 160
   player2turn
   inc scor2
   jmp out10
   
   etii8:
       
   mov matrice[17*4],1
   mov matrice[10*4],0
   draw_piece_macro 515,260,0a70a0ah
   stergepiesa 615,160 
   player1turn
   mov jucatorok,0
   int12:
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out10
   cmp x2,799
   jg out10
   cmp y2,249
   jl out10
   cmp y2,349
   jg out10
   cmp matrice[19*4],0 ;verif daca patratul e gol (dreapta)
   jne capt9
   jmp etii9
capt9:
   cmp matrice[19*4],2
   jne out10
   cmp matrice[28*4],0
   jne out10
   mov matrice[28*4],1
   mov matrice[19*4],0
   mov matrice[10*4],0
   draw_piece_macro 815, 360,0a70a0ah
   stergepiesa 715,260
   stergepiesa 615, 160
   player2turn
   inc scor2
   jmp out10
   
   etii9:
    
    
   mov matrice[19*4],1
   mov matrice[10*4],0
   draw_piece_macro 715,260,0a70a0ah
   stergepiesa 615,160  
   player1turn
   mov jucatorok,0
     
   out10:
   
   ;patratul 12
   cmp matrice[12*4],1 ;daca nu este piesa neagra pe patrat 
   jne out12
   cmp x1,800   ;verif daca s-a dat click in patratul 12
   jl out12
   cmp x1,899 
   jg out12
   cmp y1,149
   jl out12
   cmp y1,249
   jg out12
      
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int11
   cmp x2,799
   jg int11
   cmp y2,249
   jl int11
   cmp y2,349
   jg int11
   cmp matrice[19*4],0 ;verif daca patratul e gol (stanga)
   jne capt10
   jmp etii10
capt10:
   cmp matrice[19*4],2
   jne out12
   cmp matrice[26*4],0
   jne out12
   mov matrice[26*4],1
   mov matrice[19*4],0
   mov matrice[12*4],0
   draw_piece_macro 615, 360,0a70a0ah
   stergepiesa 715,260
   stergepiesa 815, 160
   player2turn
   inc scor2
   jmp out12
   
   etii10:
    
    
   mov matrice[19*4],1
   mov matrice[12*4],0
   draw_piece_macro 715,260,0a70a0ah
   stergepiesa 815,160 
   player1turn
   mov jucatorok,0
   int11:
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out12
   cmp x2,999
   jg out12
   cmp y2,249
   jl out12
   cmp y2,349
   jg out12
   cmp matrice[21*4],0 ;verif daca patratul e gol (dreapta)
   jne capt11
   jmp etii11
capt11:
   cmp matrice[21*4],2
   jne out12
   cmp matrice[30*4],0
   jne out12
   mov matrice[30*4],1
   mov matrice[21*4],0
   mov matrice[12*4],0
   draw_piece_macro 1015, 360,0a70a0ah
   stergepiesa 915,260
   stergepiesa 815, 160
   player2turn
   inc scor2
   jmp out12
   
   etii11:
    
    
   mov matrice[21*4],1
   mov matrice[12*4],0
   draw_piece_macro 915,260,0a70a0ah
   stergepiesa 815,160  
   player1turn
   mov jucatorok,0
     
   out12:
   
   ;patratul 14
   cmp matrice[14*4],1 ;daca nu este piesa neagra pe patrat 
   jne out14
   cmp x1,1000   ;verif daca s-a dat click in patratul 42
   jl out14
   cmp x1,1099 
   jg out14
   cmp y1,149
   jl out14
   cmp y1,249
   jg out14
      
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int10
   cmp x2,999
   jg int10
   cmp y2,249
   jl int10
   cmp y2,349
   jg int10
   cmp matrice[21*4],0 ;verif daca patratul e gol (stanga)
   jne capt12
   jmp etii12
capt12:
   cmp matrice[21*4],2
   jne out14
   cmp matrice[28*4],0
   jne out14
   mov matrice[28*4],1
   mov matrice[21*4],0
   mov matrice[14*4],0
   draw_piece_macro 815, 360,0a70a0ah
   stergepiesa 915,260
   stergepiesa 1015, 160
   player2turn
   inc scor2
   jmp out14
   
   etii12:
    
    
   mov matrice[21*4],1
   mov matrice[14*4],0
   draw_piece_macro 915,260,0a70a0ah
   stergepiesa 1015,160 
   player1turn
   mov jucatorok,0
   int10:
   cmp x2,1100  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out14
   cmp x2,1199
   jg out14
   cmp y2,249
   jl out14
   cmp y2,349
   jg out14
   cmp matrice[23*4],0 ;verif daca patratul e gol (dreapta)
   jne out14
   mov matrice[23*4],1
   mov matrice[14*4],0
   draw_piece_macro 1115,260,0a70a0ah
   stergepiesa 1015,160  
   player1turn
   mov jucatorok,0
     
   out14:
   
   ;patratul 17
   cmp matrice[17*4],1 ;daca nu este piesa neagra pe patrat 
   jne out17
   cmp x1,500   ;verif daca s-a dat click in patratul 42
   jl out17
   cmp x1,599 
   jg out17
   cmp y1,249
   jl out17
   cmp y1,349
   jg out17
      
   cmp x2,400  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int15
   cmp x2,499
   jg int15
   cmp y2,349
   jl int15
   cmp y2,449
   jg int15
   cmp matrice[24*4],0 ;verif daca patratul e gol (stanga)
   jne int15
   mov matrice[24*4],1
   mov matrice[17*4],0
   draw_piece_macro 415,360,0a70a0ah
   stergepiesa 515,260 
   player1turn
   mov jucatorok,0
   int15:
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out17
   cmp x2,699
   jg out17
   cmp y2,349
   jl out17
   cmp y2,449
   jg out17
   cmp matrice[26*4],0 ;verif daca patratul e gol (dreapta)
   jne capt13
   jmp etii13
capt13:
   cmp matrice[26*4],2
   jne out17
   cmp matrice[35*4],0
   jne out17
   mov matrice[35*4],1
   mov matrice[26*4],0
   mov matrice[17*4],0
   draw_piece_macro 715, 460,0a70a0ah
   stergepiesa 615,360
   stergepiesa 515, 260
   player2turn
   inc scor2
   jmp out17
   
   etii13:
    
    
   mov matrice[26*4],1
   mov matrice[17*4],0
   draw_piece_macro 615,360,0a70a0ah
   stergepiesa 515,260  
   player1turn
   mov jucatorok,0
     
   out17:
   ;patratul 19
   cmp matrice[19*4],1 ;daca nu este piesa neagra pe patrat 
   jne out19
   cmp x1,700   ;verif daca s-a dat click in patratul 42
   jl out19
   cmp x1,799 
   jg out19
   cmp y1,249
   jl out19
   cmp y1,349
   jg out19
      
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int14
   cmp x2,699
   jg int14
   cmp y2,349
   jl int14
   cmp y2,449
   jg int14
   cmp matrice[26*4],0 ;verif daca patratul e gol (stanga)
   jne capt14
   jmp etii14
capt14:
   cmp matrice[26*4],2
   jne out19
   cmp matrice[33*4],0
   jne out19
   mov matrice[33*4],1
   mov matrice[26*4],0
   mov matrice[19*4],0
   draw_piece_macro 515, 460,0a70a0ah
   stergepiesa 615,360
   stergepiesa 715, 260
   player2turn
   inc scor2
   jmp out19
   
   etii14:
     
   mov matrice[26*4],1
   mov matrice[19*4],0
   draw_piece_macro 615,360,0a70a0ah
   stergepiesa 715,260 
   player1turn
   mov jucatorok,0
   int14:
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out19
   cmp x2,899
   jg out19
   cmp y2,349
   jl out19
   cmp y2,449
   jg out19
   cmp matrice[28*4],0 ;verif daca patratul e gol (dreapta)
   jne capt15
   jmp etii15
capt15:
   cmp matrice[28*4],2
   jne out19
   cmp matrice[37*4],0
   jne out19
   mov matrice[37*4],1
   mov matrice[28*4],0
   mov matrice[19*4],0
   draw_piece_macro 915, 460,0a70a0ah
   stergepiesa 815,360
   stergepiesa 715, 260
   player2turn
   inc scor2
   jmp out19
   
   etii15:
     
  
   mov matrice[28*4],1
   mov matrice[19*4],0
   draw_piece_macro 815,360,0a70a0ah
   stergepiesa 715,260  
   player1turn
   mov jucatorok,0
     
   out19:
    
	;patratul 21
   cmp matrice[21*4],1 ;daca nu este piesa neagra pe patrat 
   jne out21
   cmp x1,900   ;verif daca s-a dat click in patratul 42
   jl out21
   cmp x1,999 
   jg out21
   cmp y1,249
   jl out21
   cmp y1,349
   jg out21
      
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int13
   cmp x2,899
   jg int13
   cmp y2,349
   jl int13
   cmp y2,449
   jg int13
   cmp matrice[28*4],0 ;verif daca patratul e gol (stanga)
   jne capt16
   jmp etii16
capt16:
   cmp matrice[28*4],2
   jne out21
   cmp matrice[35*4],0
   jne out21
   mov matrice[35*4],1
   mov matrice[28*4],0
   mov matrice[21*4],0
   draw_piece_macro 715, 460,0a70a0ah
   stergepiesa 815,360
   stergepiesa 915, 260
   player2turn
   inc scor2
   jmp out21
   
   etii16:
  
   mov matrice[28*4],1
   mov matrice[21*4],0
   draw_piece_macro 815,360,0a70a0ah
   stergepiesa 915,260 
   player1turn
   mov jucatorok,0
   int13:
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out21
   cmp x2,1099
   jg out21
   cmp y2,349
   jl out21
   cmp y2,449
   jg out21
   cmp matrice[30*4],0 ;verif daca patratul e gol (dreapta)
   jne capt17
   jmp etii17
capt17:
   cmp matrice[30*4],2
   jne out21
   cmp matrice[39*4],0
   jne out21
   mov matrice[39*4],1
   mov matrice[30*4],0
   mov matrice[21*4],0
   draw_piece_macro 1115, 460,0a70a0ah
   stergepiesa 1015,360
   stergepiesa 915, 260
   player2turn
   inc scor2
   jmp out21
   
   etii17:
     
   
   mov matrice[30*4],1
   mov matrice[21*4],0
   draw_piece_macro 1015,360,0a70a0ah
   stergepiesa 915,260  
   player1turn
   mov jucatorok,0
     
   out21:
   
   ;patratul 23
   cmp matrice[23*4],1 ;daca nu este piesa neagra pe patrat 
   jne out23
   cmp x1,1100   ;verif daca s-a dat click in patratul 42
   jl out23
   cmp x1,1199 
   jg out23
   cmp y1,249
   jl out23
   cmp y1,349
   jg out23
      
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out23
   cmp x2,1099
   jg out23
   cmp y2,349
   jl out23
   cmp y2,449
   jg out23
   cmp matrice[30*4],0 ;verif daca patratul e gol (stanga)
   jne capt18
   jmp etii18
capt18:
   cmp matrice[30*4],2
   jne out23
   cmp matrice[37*4],0
   jne out23
   mov matrice[37*4],1
   mov matrice[30*4],0
   mov matrice[23*4],0
   draw_piece_macro 915, 460,0a70a0ah
   stergepiesa 1015,360
   stergepiesa 1115, 260
   player2turn
   inc scor2
   jmp out23
   
   etii18:
    
   mov matrice[30*4],1
   mov matrice[23*4],0
   draw_piece_macro 1015,360,0a70a0ah
   stergepiesa 1115,260 
   player1turn
   mov jucatorok,0
     
   out23:

  ;patratul 24
   cmp matrice[24*4],1 ;daca nu este piesa neagra pe patrat 
   jne out24
   cmp x1,400   ;verif daca s-a dat click in patratul 42
   jl out24
   cmp x1,499 
   jg out24
   cmp y1,349
   jl out24
   cmp y1,449
   jg out24
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out24
   cmp x2,599
   jg out24
   cmp y2,449
   jl out24
   cmp y2,549
   jg out24
   cmp matrice[33*4],0 ;verif daca patratul e gol (stanga)
   jne capt19
   jmp etii19
capt19:
   cmp matrice[33*4],2
   jne out24
   cmp matrice[42*4],0
   jne out24
   mov matrice[42*4],1
   mov matrice[33*4],0
   mov matrice[24*4],0
   draw_piece_macro 615, 560,0a70a0ah
   stergepiesa 515,460
   stergepiesa 415, 360
   player2turn
   inc scor2
   jmp out24
   
   etii19:
    
   mov matrice[33*4],1
   mov matrice[24*4],0
   draw_piece_macro 515,460,0a70a0ah
   stergepiesa 415,360 
   player1turn
   mov jucatorok,0  
   out24:
    
   ;patratul 26
   cmp matrice[26*4],1 ;daca nu este piesa neagra pe patrat 
   jne out26
   cmp x1,600   ;verif daca s-a dat click in patratul 42
   jl out26
   cmp x1,699 
   jg out26
   cmp y1,349
   jl out26
   cmp y1,449
   jg out26
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int18
   cmp x2,599
   jg int18
   cmp y2,449
   jl int18
   cmp y2,549
   jg int18
   cmp matrice[33*4],0 ;verif daca patratul e gol (stanga)
   jne capt20
   jmp etii20
capt20:
   cmp matrice[33*4],2
   jne out26
   cmp matrice[40*4],0
   jne out26
   mov matrice[40*4],1
   mov matrice[33*4],0
   mov matrice[26*4],0
   draw_piece_macro 415, 560,0a70a0ah
   stergepiesa 515,460
   stergepiesa 615, 360
   player2turn
   inc scor2
   jmp out26
   
   etii20:
   
   mov matrice[33*4],1
   mov matrice[26*4],0
   draw_piece_macro 515,460,0a70a0ah
   stergepiesa 615,360 
   player1turn
   mov jucatorok,0
   int18:
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out26
   cmp x2,799
   jg out26
   cmp y2,449
   jl out26
   cmp y2,549
   jg out26
   cmp matrice[35*4],0 ;verif daca patratul e gol (dreapta)
   jne capt21
   jmp etii21
capt21:
   cmp matrice[35*4],2
   jne out26
   cmp matrice[44*4],0
   jne out26
   mov matrice[44*4],1
   mov matrice[35*4],0
   mov matrice[26*4],0
   draw_piece_macro 815, 560,0a70a0ah
   stergepiesa 715,460
   stergepiesa 615, 360
   player2turn
   inc scor2
   jmp out26
   
   etii21:
   
   mov matrice[35*4],1
   mov matrice[26*4],0
   draw_piece_macro 715,460,0a70a0ah
   stergepiesa 615,360  
   player1turn
   mov jucatorok,0
     
   out26:
   
   ;patratul 28
   cmp matrice[28*4],1 ;daca nu este piesa neagra pe patrat 
   jne out28
   cmp x1,800   ;verif daca s-a dat click in patratul 42
   jl out28
   cmp x1,899 
   jg out28
   cmp y1,349
   jl out28
   cmp y1,449
   jg out28
      
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int17
   cmp x2,799
   jg int17
   cmp y2,449
   jl int17
   cmp y2,549
   jg int17
   cmp matrice[35*4],0 ;verif daca patratul e gol (stanga)
   jne capt22
   jmp etii22
capt22:
   cmp matrice[35*4],2
   jne out28
   cmp matrice[42*4],0
   jne out28
   mov matrice[42*4],1
   mov matrice[35*4],0
   mov matrice[28*4],0
   draw_piece_macro 615, 560,0a70a0ah
   stergepiesa 715,460
   stergepiesa 815, 360
   player2turn
   inc scor2
   jmp out28
   
   etii22:
    
   mov matrice[35*4],1
   mov matrice[28*4],0
   draw_piece_macro 715,460,0a70a0ah
   stergepiesa 815,360 
   player1turn
   mov jucatorok,0
   int17:
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out28
   cmp x2,999
   jg out28
   cmp y2,449
   jl out28
   cmp y2,549
   jg out28
   cmp matrice[37*4],0 ;verif daca patratul e gol (dreapta)
   jne capt23
   jmp etii23
capt23:
   cmp matrice[37*4],2
   jne out28
   cmp matrice[46*4],0
   jne out28
   mov matrice[46*4],1
   mov matrice[37*4],0
   mov matrice[28*4],0
   draw_piece_macro 1015, 560,0a70a0ah
   stergepiesa 915,460
   stergepiesa 815, 360
   player2turn
   inc scor2
   jmp out28
   
   etii23:
    
   
   mov matrice[37*4],1
   mov matrice[28*4],0
   draw_piece_macro 915,460,0a70a0ah
   stergepiesa 815,360  
   player1turn
   mov jucatorok,0
     
   out28:
   
   ;patratul 30
   cmp matrice[30*4],1 ;daca nu este piesa neagra pe patrat 
   jne out30
   cmp x1,1000   ;verif daca s-a dat click in patratul 42
   jl out30
   cmp x1,1099 
   jg out30
   cmp y1,349
   jl out30
   cmp y1,449
   jg out30
      
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int16
   cmp x2,999
   jg int16
   cmp y2,449
   jl int16
   cmp y2,549
   jg int16
   cmp matrice[37*4],0 ;verif daca patratul e gol (stanga)
   jne capt24
   jmp etii24
capt24:
   cmp matrice[37*4],2
   jne out30
   cmp matrice[44*4],0
   jne out30
   mov matrice[44*4],1
   mov matrice[37*4],0
   mov matrice[30*4],0
   draw_piece_macro 815, 560,0a70a0ah
   stergepiesa 915,460
   stergepiesa 1015, 360
   player2turn
   inc scor2
   jmp out30
   
   etii24:
    
   mov matrice[37*4],1
   mov matrice[30*4],0
   draw_piece_macro 915,460,0a70a0ah
   stergepiesa 1015,360 
   player1turn
   mov jucatorok,0
   int16:
   cmp x2,1100  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out30
   cmp x2,1199
   jg out30
   cmp y2,449
   jl out30
   cmp y2,549
   jg out30
   cmp matrice[39*4],0 ;verif daca patratul e gol (dreapta)
   jne out30
   mov matrice[39*4],1
   mov matrice[30*4],0
   draw_piece_macro 1115,460,0a70a0ah
   stergepiesa 1015,360  
   player1turn
   mov jucatorok,0
     
   out30:
   
  ;patratul 33
   cmp matrice[33*4],1 ;daca nu este piesa neagra pe patrat 
   jne out33
   cmp x1,500   ;verif daca s-a dat click in patratul 42
   jl out33
   cmp x1,599 
   jg out33
   
   cmp y1,449
   jl out33
   cmp y1,549
   jg out33
      
   cmp x2,400  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int21
   cmp x2,499
   jg int21
   cmp y2,549
   jl int21
   cmp y2,649
   jg int21
   cmp matrice[40*4],0 ;verif daca patratul e gol (stanga)
   jne int21
   mov matrice[40*4],1
   mov matrice[33*4],0
   draw_piece_macro 415,560,0a70a0ah
   stergepiesa 515,460 
   player1turn
   mov jucatorok,0
   int21:
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out33
   cmp x2,699
   jg out33
   cmp y2,549
   jl out33
   cmp y2,649
   jg out33
   cmp matrice[42*4],0 ;verif daca patratul e gol (dreapta)
   jne capt25
   jmp etii25
capt25:
   cmp matrice[42*4],2
   jne out33
   cmp matrice[51*4],0
   jne out33
   mov matrice[51*4],1
   mov matrice[42*4],0
   mov matrice[33*4],0
   draw_piece_macro 715, 660,0a70a0ah
   stergepiesa 615,560
   stergepiesa 515, 460
   player2turn
   inc scor2
   jmp out33
   
   etii25:
    
    
   mov matrice[42*4],1
   mov matrice[33*4],0
   draw_piece_macro 615,560,0a70a0ah
   stergepiesa 515,460  
   player1turn
   mov jucatorok,0
     
   out33:
   ;patratul 35
   cmp matrice[35*4],1 ;daca nu este piesa neagra pe patrat 
   jne out35
   cmp x1,700   ;verif daca s-a dat click in patratul 42
   jl out35
   cmp x1,799 
   jg out35
   cmp y1,449
   jl out35
   cmp y1,549
   jg out35
      
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int20
   cmp x2,699
   jg int20
   cmp y2,549
   jl int20
   cmp y2,649
   jg int20
   cmp matrice[42*4],0 ;verif daca patratul e gol (stanga)
   jne capt26
   jmp etii26
capt26:
   cmp matrice[42*4],2
   jne out35
   cmp matrice[49*4],0
   jne out35
   mov matrice[49*4],1
   mov matrice[42*4],0
   mov matrice[35*4],0
   draw_piece_macro 515, 660,0a70a0ah
   stergepiesa 615,560
   stergepiesa 715, 460
   player2turn
   inc scor2
   jmp out35
   
   etii26:
    
   jne int20
   mov matrice[42*4],1
   mov matrice[35*4],0
   draw_piece_macro 615,560,0a70a0ah
   stergepiesa 715,460 
   player1turn
   mov jucatorok,0
   int20:
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out35
   cmp x2,899
   jg out35
   cmp y2,549
   jl out35
   cmp y2,649
   jg out35
   cmp matrice[44*4],0 ;verif daca patratul e gol (dreapta)
   jne capt27
   jmp etii27
capt27:
   cmp matrice[44*4],2
   jne out35
   cmp matrice[53*4],0
   jne out35
   mov matrice[53*4],1
   mov matrice[44*4],0
   mov matrice[35*4],0
   draw_piece_macro 915, 660,0a70a0ah
   stergepiesa 815,560
   stergepiesa 715, 460
   player2turn
   inc scor2
   jmp out35
   
   etii27:
    
   mov matrice[44*4],1
   mov matrice[35*4],0
   draw_piece_macro 815,560,0a70a0ah
   stergepiesa 715,460  
   player1turn
   mov jucatorok,0
     
   out35:
   ;patratul 37
   cmp matrice[37*4],1 ;daca nu este piesa neagra pe patrat 
   jne out37
   cmp x1,900   ;verif daca s-a dat click in patratul 42
   jl out37
   cmp x1,999 
   jg out37
   cmp y1,449
   jl out37
   cmp y1,549
   jg out37
      
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int19
   cmp x2,899
   jg int19
   cmp y2,549
   jl int19
   cmp y2,649
   jg int19
   cmp matrice[44*4],0 ;verif daca patratul e gol (stanga)
   jne capt28
   jmp jumper1i
capt28:
   cmp matrice[44*4],2
   jne out37
   cmp matrice[51*4],0
   jne out37
   mov matrice[51*4],1
   mov matrice[44*4],0
   mov matrice[37*4],0
   draw_piece_macro 715, 660,0a70a0ah
   stergepiesa 815,560
   stergepiesa 915, 460
   player2turn
   inc scor2
   jmp out37
   
   jumper1i:
   
   mov matrice[44*4],1
   mov matrice[37*4],0
   draw_piece_macro 815,560,0a70a0ah
   stergepiesa 915,460 
   player1turn
   mov jucatorok,0
   int19:
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out37
   cmp x2,1099
   jg out37
   cmp y2,549
   jl out37
   cmp y2,649
   jg out37
   cmp matrice[46*4],0 ;verif daca patratul e gol (dreapta)
   jne capt29
   jmp jumper2i
capt29:
   cmp matrice[46*4],2
   jne out37
   cmp matrice[55*4],0
   jne out37
   mov matrice[55*4],1
   mov matrice[46*4],0
   mov matrice[37*4],0
   draw_piece_macro 1115, 660,0a70a0ah
   stergepiesa 1015,560
   stergepiesa 915, 460
   player2turn
   inc scor2
   jmp out37
   
   jumper2i:
   
   mov matrice[46*4],1
   mov matrice[37*4],0
   draw_piece_macro 1015,560,0a70a0ah
   stergepiesa 915,460  
   player1turn
   mov jucatorok,0
     
   out37:
   
   ;patratul 39
   cmp matrice[39*4],1 ;daca nu este piesa neagra pe patrat 
   jne out39
   cmp x1,1100   ;verif daca s-a dat click in patratul 42
   jl out39
   cmp x1,1199 
   jg out39
   cmp y1,449
   jl out39
   cmp y1,549
   jg out39
      
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out39
   cmp x2,1099
   jg out39
   cmp y2,549
   jl out39
   cmp y2,649
   jg out39
   cmp matrice[46*4],0 ;verif daca patratul e gol (stanga)
   jne capt30
   jmp jumper3i
capt30:
   cmp matrice[46*4],2
   jne out39
   cmp matrice[53*4],0
   jne out39
   mov matrice[53*4],1
   mov matrice[46*4],0
   mov matrice[39*4],0
   draw_piece_macro 915, 660,0a70a0ah
   stergepiesa 1015,560
   stergepiesa 1115, 460
   player2turn
   inc scor2
   jmp out39
   
   jumper3i:
    
   mov matrice[46*4],1
   mov matrice[39*4],0
   draw_piece_macro 1015,560,0a70a0ah
   stergepiesa 1115,460 
   player1turn
   mov jucatorok,0
   out39:
   
   
   ;patratul 40
   cmp matrice[40*4],1 ;daca nu este piesa neagra pe patrat 
   jne out40
   cmp x1,400   ;verif daca s-a dat click in patratul 42
   jl out40
   cmp y1,549
   jl out40
   cmp x1,499 
   jg out40
   cmp y1,649
   jg out40
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out40 ; jump pentru a 2 a verificare (interior jump )
   cmp x2,599
   jg out40
   cmp y2,649
   jl out40
   cmp y2,749
   jg out40
   cmp matrice[49*4],0 ;verif daca patratul e gol (stanga)
   jne capt31
   jmp jumper4i
capt31:
   cmp matrice[49*4],2
   jne out40
   cmp matrice[58*4],0
   jne out40
   mov matrice[58*4],1
   mov matrice[49*4],0
   mov matrice[40*4],0
   draw_piece_macro 615, 760,0a70a0ah
   stergepiesa 515,660
   stergepiesa 415, 560
   player2turn
   inc scor2
   jmp out40
   
   jumper4i:
    
   mov matrice[49*4],1
   mov matrice[40*4],0
   draw_piece_macro 515,660,0a70a0ah
   stergepiesa 415,560 
   player1turn
   mov jucatorok,0
     
   out40:
  
   ;patratul 42
   cmp matrice[42*4],1 ;daca nu este piesa neagra pe patrat 
   jne out42
   cmp x1,600   ;verif daca s-a dat click in patratul 42
   jl out42
   cmp y1,549
   jl out42
   cmp x1,699 
   jg out42
   cmp y1,649
   jg out42
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int22
   cmp x2,599
   jg int22
   cmp y2,649
   jl int22
   cmp y2,749
   jg int22
   cmp matrice[49*4],0 ;verif daca patratul e gol (stanga)
   jne capt32
   jmp jumper5i
capt32:
   cmp matrice[49*4],2
   jne out42
   cmp matrice[56*4],0
   jne out42
   mov matrice[56*4],1
   mov matrice[49*4],0
   mov matrice[42*4],0
   draw_piece_macro 415, 760,0a70a0ah
   stergepiesa 515,660
   stergepiesa 615, 560
   player2turn
   inc scor2
   jmp out42
   
   jumper5i:
    
   mov matrice[49*4],1
   mov matrice[42*4],0
   draw_piece_macro 515,660,0a70a0ah
   stergepiesa 615,560 
   player1turn
   mov jucatorok,0
   int22:
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out42
   cmp x2,799
   jg out42
   cmp y2,649
   jl out42
   cmp y2,749
   jg out42
   cmp matrice[51*4],0 ;verif daca patratul e gol (dreapta)
   jne captu33
   jmp jumper6i
captu33:
   cmp matrice[51*4],2
   jne out42
   cmp matrice[60*4],0
   jne out42
   mov matrice[60*4],1
   mov matrice[51*4],0
   mov matrice[42*4],0
   draw_piece_macro 815, 760,0a70a0ah
   stergepiesa 715,660
   stergepiesa 615, 560
   player2turn
   inc scor2
   jmp out42
   
   jumper6i:
    
   mov matrice[51*4],1
   mov matrice[42*4],0
   draw_piece_macro 715,660,0a70a0ah
   stergepiesa 615,560  
   player1turn
    mov jucatorok,0
     
   out42:
   
   ;patratul 44
   cmp matrice[44*4],1 ;daca nu este piesa neagra pe patrat 
   jne out44     ;verif daca s-a dat click in patratul 44
   cmp x1,800 
   jl out44
   cmp x1,899 
   jg out44   
   cmp y1,549
   jl out44
   cmp y1,649
   jg out44
      
   cmp x2,700 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int23
   cmp x2,799
   jg int23
   cmp y2,649
   jl int23 
   cmp y2,749
   jg int23
   cmp matrice[51*4],0 ;verif daca patratul e gol (stanga)
   jne captu34
   jmp jumper7i
captu34:
   cmp matrice[51*4],2
   jne out44
   cmp matrice[58*4],0
   jne out44
   mov matrice[58*4],1
   mov matrice[51*4],0
   mov matrice[44*4],0
   draw_piece_macro 615, 760,0a70a0ah
   stergepiesa 715,660
   stergepiesa 815, 560
   player2turn
   inc scor2
   jmp out44
   
   jumper7i:
    
   jnz int23
   mov matrice[51*4],1
   mov matrice[44*4],0    
   draw_piece_macro 715,660,0a70a0ah
   stergepiesa 815,560 
   player1turn
   mov jucatorok,0
   int23:
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out44
   cmp x2,999
   jg out44
   cmp y2,649
   jl out44
   cmp y2,749
   jg out44
   cmp matrice[53*4],0 ;verif daca patratul e gol (dreapta)
     jne captu35
    jmp jumper8i
 captu35:
     cmp matrice[53*4],2
     jne out44
     cmp matrice[62*4],0
     jne out44
     mov matrice[62*4],1
    mov matrice[53*4],0
     mov matrice[44*4],0
     draw_piece_macro 1015, 760,0a70a0ah
     stergepiesa 915,660
     stergepiesa 815, 560
	 player2turn
    inc scor2
     jmp out44
   
     jumper8i:
    
   
   mov matrice[53*4],1
   mov matrice[44*4],0
   draw_piece_macro 915,660,0a70a0ah
   stergepiesa 815,560  
   player1turn
   mov jucatorok,0
   
   out44:   
   
   ;patratul 46
   cmp matrice[46*4],1 ;daca nu este piesa neagra pe patrat 
   jne out46     ;verif daca s-a dat click in patratul 44
   cmp x1,1000 
   jl out46
   cmp x1,1099 
   jg out46   
   cmp y1,549
   jl out46
   cmp y1,649
   jg out46
      
   cmp x2,900 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int24
   cmp x2,999
   jg int24
   cmp y2,649
   jl int24 
   cmp y2,749
   jg int24
   cmp matrice[53*4],0 ;verif daca patratul e gol (stanga)
     jne int30
     jmp int31
 int30:
    cmp matrice[53*4],2
    jne out46
    cmp matrice[60*4],0
    jne out46
    mov matrice[60*4],1
    mov matrice[53*4],0
    mov matrice[46*4],0
    draw_piece_macro 815, 760,0a70a0ah
    stergepiesa 915,660
    stergepiesa 1015, 560
	player1turn
    inc scor2
    jmp out46
   
    int31:
   
   mov matrice[53*4],1
   mov matrice[46*4],0    
   draw_piece_macro 915,660,0a70a0ah
   stergepiesa 1015,560 
   player1turn
   mov jucatorok,0
   int24:
   cmp x2,1100  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out46
   cmp x2,1199
   jg out46
   cmp y2,649
   jl out46
   cmp y2,749
   jg out46
   cmp matrice[55*4],0 ;verif daca patratul e gol (dreapta)
   jne out46
   mov matrice[55*4],1
   mov matrice[46*4],0
   draw_piece_macro 1115,660,0a70a0ah
   stergepiesa 1015,560  
   player1turn
   mov jucatorok,0
   
   out46:  
   
   ;patratul 49
   cmp matrice[49*4],1 ;daca nu este piesa neagra pe patrat 
   jne out49     ;verif daca s-a dat click in patratul 44
   cmp x1,500
   jl out49
   cmp x1,599
   jg out49   
   cmp y1,649
   jl out49
   cmp y1,749
   jg out49
      
   cmp x2,400 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int25
   cmp x2,499
   jg int25
   cmp y2,749
   jl int25 
   cmp y2,849
   jg int25
   cmp matrice[56*4],0 ;verif daca patratul e gol (stanga)
   jnz int25
   mov matrice[56*4],1
   mov matrice[49*4],0    
   draw_piece_macro 415,760,0a70a0ah
   stergepiesa 515,660 
   
   mov jucatorok,0
   int25:
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out49
   cmp x2,699
   jg out49
   cmp y2,749
   jl out49
   cmp y2,849
   jg out49
   cmp matrice[58*4],0 ;verif daca patratul e gol (dreapta)
   jne out49
   mov matrice[58*4],1
   mov matrice[49*4],0
   draw_piece_macro 615,760,0a70a0ah
   stergepiesa 515,660  
   mov jucatorok,0
	
   out49: 
   
   ;patratul 51
   cmp matrice[51*4],1 ;daca nu este piesa neagra pe patrat 
   jne out51     ;verif daca s-a dat click in patratul 44
   cmp x1,700
   jl out51
   cmp x1,799
   jg out51  
   cmp y1,649
   jl out51
   cmp y1,749
   jg out51
      
   cmp x2,600 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int26
   cmp x2,699
   jg int26
   cmp y2,749
   jl int26 
   cmp y2,849
   jg int26
   cmp matrice[58*4],0 ;verif daca patratul e gol (stanga)
   jnz int26
   mov matrice[58*4],1
   mov matrice[51*4],0    
   draw_piece_macro 615,760,0a70a0ah
   stergepiesa 715,660 
   mov jucatorok,0
   int26:
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out51
   cmp x2,899
   jg out51
   cmp y2,749
   jl out51
   cmp y2,849
   jg out51
   cmp matrice[60*4],0 ;verif daca patratul e gol (dreapta)
   jne out51 
   mov matrice[60*4],1
   mov matrice[51*4],0
   draw_piece_macro 815,760,0a70a0ah
   stergepiesa 715,660  
   mov jucatorok,0
	
   out51: 
   
   ;patratul 53
   cmp matrice[53*4],1 ;daca nu este piesa neagra pe patrat 
   jne out53     ;verif daca s-a dat click in patratul 44
   cmp x1,900
   jl out53
   cmp x1,999
   jg out53  
   cmp y1,649
   jl out53
   cmp y1,749
   jg out53
      
   cmp x2,800 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int27
   cmp x2,899
   jg int27
   cmp y2,749
   jl int27 
   cmp y2,849
   jg int27
   cmp matrice[60*4],0 ;verif daca patratul e gol (stanga)
   jnz int27
   mov matrice[60*4],1
   mov matrice[53*4],0    
   draw_piece_macro 815,760,0a70a0ah
   stergepiesa 915,660 
   mov jucatorok,0
   int27:
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out53
   cmp x2,1099
   jg out53
   cmp y2,749
   jl out53
   cmp y2,849
   jg out53
   cmp matrice[62*4],0 ;verif daca patratul e gol (dreapta)
   jne out53
   mov matrice[62*4],1
   mov matrice[53*4],0
   draw_piece_macro 1015,760,0a70a0ah
   stergepiesa 915,660  
   mov jucatorok,0
	
   out53:

   ;patratul 55
   cmp matrice[55*4],1 ;daca nu este piesa neagra pe patrat 
   jne out55     ;verif daca s-a dat click in patratul 44
   cmp x1,1100
   jl out55
   cmp x1,1199
   jg out55  
   cmp y1,649
   jl out55
   cmp y1,749
   jg out55
      
   cmp x2,1000 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out55
   cmp x2,1099
   jg out55
   cmp y2,749
   jl out55 
   cmp y2,849
   jg out55
   cmp matrice[62*4],0 ;verif daca patratul e gol (stanga)
   jnz out55 
   mov matrice[62*4],1
   mov matrice[55*4],0    
   draw_piece_macro 1015,760,0a70a0ah
   stergepiesa 1115,660 
   mov jucatorok,0
   
	
   out55: 
   
   jmp evt_click
endm

testpiesaneagra macro x1,y1,x2,y2
local out1,out3,out5,out7,out8,out10,out12,out14,out16,out17,out19,out21,out23,out24,out26,out28,out30,out33,out35,out37,out39,out40,out42,out44,out46,out49,out51,out53,out55,out56,out58,out60,out62
local int11,int2,int33,int4,int5,int6,int7,int8,int9,int10,int11,int12,int13,int14,int15,int16,int17,int18,int19,int20,int21,int22,int23,int24,int25,int26,int27,int28,int29,int30,int31,int32
local capt1,capt2,capt3,capt4,capt5,capt6,capt7,capt8,capt9,capt10,capt11,capt12,capt13,capt14,capt15,capt16,capt17,capt18,capt19,capt20,capt21,capt22,capt23,capt24,capt25,capt26,capt27,capt28,capt29,capt30,capt31,capt32 
local etii1,etii2,etii3,etii4,etii5,etii6,etii7,etii8,etii9,etii10,etii11,etii12,etii13,etii14,etii15,etii16,etii17,etii18,etii19,etii20,etii21,etii22,etii23,etii24,etii25,etii26,etii27,etii28,etii29,etii30,etii31,etii32,etiii33,etii34,etiii35   
   ;patratul 8
   cmp matrice[8*4],2 ;daca nu este piesa neagra pe patrat 
   jne out8
   cmp x1,400   ;verif daca s-a dat click in patratul 8
   jl out8
   cmp x1,499 
   jg out8
   cmp y1,149
   jl out8
   cmp y1,249
   jg out8
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out8
   cmp x2,599
   jg out8
   cmp y2,49
   jl out8
   cmp y2,149
   jg out8
   cmp matrice[1*4],0 ;verif daca patratul e gol (dreapta)
   jne out8
   mov matrice[1*4],2
   mov matrice[8*4],0
   draw_piece_macro 515,60,0
   stergepiesa 415,160 
   mov jucatorok,1
     
   out8:
  
   ;patratul 10
   cmp matrice[10*4],2 ;daca nu este piesa neagra pe patrat 
   jne out10
   cmp x1,600   ;verif daca s-a dat click in patratul 10
   jl out10
   cmp x1,699 
   jg out10
   cmp y1,149
   jl out10
   cmp y1,249
   jg out10
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int12
   cmp x2,599
   jg int12
   cmp y2,49
   jl int12
   cmp y2,149
   jg int12
   cmp matrice[1*4],0 ;verif daca patratul e gol (stanga)
   jne int12
   mov matrice[1*4],2
   mov matrice[10*4],0
   draw_piece_macro 515,60,0
   stergepiesa 615,160 
    mov jucatorok,1
   int12:
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out10
   cmp x2,799
   jg out10
   cmp y2,49
   jl out10
   cmp y2,149
   jg out10
   cmp matrice[3*4],0 ;verif daca patratul e gol (dreapta)
   jne out10
   mov matrice[3*4],2
   mov matrice[10*4],0
   draw_piece_macro 715,60,0
   stergepiesa 615,160  
    mov jucatorok,1
     
   out10:
   
   ;patratul 12
   cmp matrice[12*4],2 ;daca nu este piesa neagra pe patrat 
   jne out12
   cmp x1,800   ;verif daca s-a dat click in patratul 12
   jl out12
   cmp x1,899 
   jg out12
   cmp y1,149
   jl out12
   cmp y1,249
   jg out12
      
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int11
   cmp x2,799
   jg int11
   cmp y2,49
   jl int11
   cmp y2,149
   jg int11
   cmp matrice[3*4],0 ;verif daca patratul e gol (stanga)
   jne int11
   mov matrice[3*4],2
   mov matrice[12*4],0
   draw_piece_macro 715,60,0
   stergepiesa 815,160 
    mov jucatorok,1
   int11:
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out12
   cmp x2,999
   jg out12
   cmp y2,49
   jl out12
   cmp y2,149
   jg out12
   cmp matrice[5*4],0 ;verif daca patratul e gol (dreapta)
   jne out12
   mov matrice[5*4],2
   mov matrice[12*4],0
   draw_piece_macro 915,60,0
   stergepiesa 815,160  
    mov jucatorok,1
     
   out12:
   
   ;patratul 14
   cmp matrice[14*4],2 ;daca nu este piesa neagra pe patrat 
   jne out14
   cmp x1,1000   ;verif daca s-a dat click in patratul 14
   jl out14
   cmp x1,1099 
   jg out14
   cmp y1,149
   jl out14
   cmp y1,249
   jg out14
      
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int10
   cmp x2,999
   jg int10
   cmp y2,49
   jl int10
   cmp y2,149
   jg int10
   cmp matrice[5*4],0 ;verif daca patratul e gol (stanga)
   jne int10
   mov matrice[5*4],2
   mov matrice[14*4],0
   draw_piece_macro 915,60,0
   stergepiesa 1015,160 
    mov jucatorok,1
   int10:
   cmp x2,1100  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out14
   cmp x2,1199
   jg out14
   cmp y2,49
   jl out14
   cmp y2,149
   jg out14
   cmp matrice[7*4],0 ;verif daca patratul e gol (dreapta)
   jne out14
   mov matrice[7*4],2
   mov matrice[14*4],0
   draw_piece_macro 1115,60,0
   stergepiesa 1015,160  
    mov jucatorok,1
     
   out14:
   
   ;patratul 17
   cmp matrice[17*4],2 ;daca nu este piesa neagra pe patrat 
   jne out17
   cmp x1,500   ;verif daca s-a dat click in patratul 17
   jl out17
   cmp x1,599 
   jg out17
   cmp y1,249
   jl out17
   cmp y1,349
   jg out17
      
   cmp x2,400  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int15
   cmp x2,499
   jg int15
   cmp y2,149
   jl int15
   cmp y2,249
   jg int15
   cmp matrice[8*4],0 ;verif daca patratul e gol (stanga)
   jne int15
   mov matrice[8*4],2
   mov matrice[17*4],0
   draw_piece_macro 415,160,0 
   stergepiesa 515,260 
   player2turn
    mov jucatorok,1
   int15:
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out17
   cmp x2,699
   jg out17
   cmp y2,149
   jl out17
   cmp y2,249
   jg out17
   cmp matrice[10*4],0 ;verif daca patratul e gol (dreapta)
   jne capt1
   jmp etii1
capt1:
   cmp matrice[10*4],1
   jne out17
   cmp matrice[3*4],0
   jne out17
   mov matrice[3*4],2
   mov matrice[10*4],0
   mov matrice[17*4],0
   draw_piece_macro 715, 60,0
   stergepiesa 515,260
   stergepiesa 615,160
   player1turn
   inc scor1
   jmp out17
   
   etii1: 
   mov matrice[10*4],2
   mov matrice[17*4],0
   draw_piece_macro 615,160,0
   stergepiesa 515,260  
   player2turn
    mov jucatorok,1
     
   out17:
   ;patratul 19
   cmp matrice[19*4],2 ;daca nu este piesa neagra pe patrat 
   jne out19
   cmp x1,700   ;verif daca s-a dat click in patratul 19
   jl out19
   cmp x1,799 
   jg out19
   cmp y1,249
   jl out19
   cmp y1,349
   jg out19
      
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int14
   cmp x2,699
   jg int14
   cmp y2,149
   jl int14
   cmp y2,249
   jg int14
   cmp matrice[10*4],0 ;verif daca patratul e gol (stanga)
   jne capt2
   jmp etii2
capt2:
   cmp matrice[10*4],1
   jne out19
   cmp matrice[1*4],0
   jne out19
   mov matrice[1*4],2
   mov matrice[10*4],0
   mov matrice[19*4],0
   draw_piece_macro 515, 60,0
   stergepiesa 715,260
   stergepiesa 615,160
   player1turn
   inc scor1
   jmp out19
   
   etii2: 
   mov matrice[10*4],2
   mov matrice[19*4],0
   draw_piece_macro 615,160,0
   stergepiesa 715,260 
   player2turn
   mov jucatorok,1
   int14:
   cmp matrice[12*4],0 ;verif daca patratul e gol (dreapta)
   jne capt3
   jmp etii3
capt3:
   cmp matrice[12*4],1
   jne out19
   cmp matrice[5*4],0
   jne out19
   mov matrice[5*4],2
   mov matrice[12*4],0
   mov matrice[19*4],0
   draw_piece_macro 915, 60,0
   stergepiesa 715,260
   stergepiesa 815,160
   player1turn
   inc scor1
   jmp out19
   
   etii3: 
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out19
   cmp x2,899
   jg out19
   cmp y2,149
   jl out19
   cmp y2,249
   jg out19
   cmp matrice[12*4],0 ;verif daca patratul e gol (dreapta)
   jne out17
   mov matrice[12*4],2
   mov matrice[19*4],0
   
   draw_piece_macro 815,160,0
   stergepiesa 715,260  
   player2turn
    mov jucatorok,1
     
   out19:
    
	;patratul 21
   cmp matrice[21*4],2 ;daca nu este piesa neagra pe patrat 
   jne out21
   cmp x1,900   ;verif daca s-a dat click in patratul 21
   jl out21
   cmp x1,999 
   jg out21
   cmp y1,249
   jl out21
   cmp y1,349
   jg out21
      
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int13
   cmp x2,899
   jg int13
   cmp y2,149
   jl int13
   cmp y2,249
   jg int13
   cmp matrice[12*4],0 ;verif daca patratul e gol (stanga)
   jne capt4
   jmp etii4
capt4:
   cmp matrice[12*4],1
   jne out21
   cmp matrice[3*4],0
   jne out21
   mov matrice[3*4],2
   mov matrice[12*4],0
   mov matrice[21*4],0
   draw_piece_macro 715, 60,0
   stergepiesa 915,260
   stergepiesa 815,160
    player1turn
   inc scor1
   jmp out21
  
   etii4: 
   
    
   mov matrice[12*4],2
   mov matrice[21*4],0
   draw_piece_macro 815,160,0
   stergepiesa 915,260
   player2turn
    mov jucatorok,1   
   int13:
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out21
   cmp x2,1099
   jg out21
   cmp y2,149
   jl out21
   cmp y2,249
   jg out21
   cmp matrice[14*4],0 ;verif daca patratul e gol (dreapta)
  
   jne capt5
   jmp etii5
capt5: ;eticheta pentru verificare captura
   cmp matrice[14*4],1
   jne out21
   cmp matrice[7*4],0
   jne out21
   mov matrice[7*4],2
   mov matrice[14*4],0
   mov matrice[21*4],0
   draw_piece_macro 1115, 60,0
   stergepiesa 915,260
   stergepiesa 1015,160
   player1turn
   inc scor1
   jmp out21
   
   etii5: 
    
   mov matrice[14*4],2
   mov matrice[21*4],0
   draw_piece_macro 1015,160,0
   stergepiesa 915,260  
   player2turn
    mov jucatorok,1
     
   out21:
   
   ;patratul 23
   cmp matrice[23*4],2 ;daca nu este piesa neagra pe patrat 
   jne out23
   cmp x1,1100   ;verif daca s-a dat click in patratul 23
   jl out23
   cmp x1,1199 
   jg out23
   cmp y1,249
   jl out23
   cmp y1,349
   jg out23
      
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out23
   cmp x2,1099
   jg out23
   cmp y2,149
   jl out23
   cmp y2,249
   jg out23
   cmp matrice[14*4],0 ;verif daca patratul e gol (stanga)
   jne capt6
   jmp etii6
capt6:
   cmp matrice[14*4],1
   jne out23
   cmp matrice[5*4],0
   jne out23
   mov matrice[5*4],2
   mov matrice[14*4],0
   mov matrice[23*4],0
   draw_piece_macro 915, 60,0
   stergepiesa 1115,260
   stergepiesa 1015,160
   player1turn
   inc scor1
   jmp out23
   
   etii6: 
    
   mov matrice[14*4],2
   mov matrice[23*4],0
   draw_piece_macro 1015,160,0
   stergepiesa 1115,260 
   player2turn
    mov jucatorok,1
     
   out23:

  ;patratul 24
   cmp matrice[24*4],2 ;daca nu este piesa neagra pe patrat 
   jne out24
   cmp x1,400   ;verif daca s-a dat click in patratul 24
   jl out24
   cmp x1,499 
   jg out24
   cmp y1,349
   jl out24
   cmp y1,449
   jg out24
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out24
   cmp x2,599
   jg out24
   cmp y2,249
   jl out24
   cmp y2,349
   jg out24
   cmp matrice[17*4],0 ;verif daca patratul e gol (stanga)
   jne capt71
   jmp etii71
capt71:
   cmp matrice[17*4],1
   jne out24
   cmp matrice[10*4],0
   jne out24
   mov matrice[10*4],2
   mov matrice[17*4],0
   mov matrice[24*4],0
   draw_piece_macro 615, 160,0
   stergepiesa 515,260
   stergepiesa 415,360
   player1turn
   inc scor1
   jmp out24
   
   etii71:   
    
   mov matrice[17*4],2
   mov matrice[24*4],0
   draw_piece_macro 515,260,0
   stergepiesa 415,360 
   player2turn
     mov jucatorok,1
   out24:
    
   ;patratul 26
   cmp matrice[26*4],2 ;daca nu este piesa neagra pe patrat 
   jne out26
   cmp x1,600   ;verif daca s-a dat click in patratul 26
   jl out26
   cmp x1,699 
   jg out26
   cmp y1,349
   jl out26
   cmp y1,449
   jg out26
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int18
   cmp x2,599
   jg int18
   cmp y2,249
   jl int18
   cmp y2,349
   jg int18
   cmp matrice[17*4],0 ;verif daca patratul e gol (stanga)
   jne capt7
   jmp etii7
capt7:
   cmp matrice[17*4],1
   jne out26
   cmp matrice[8*4],0
   jne out26
   mov matrice[8*4],2
   mov matrice[17*4],0
   mov matrice[26*4],0
   draw_piece_macro 415, 160,0
   stergepiesa 515,260
   stergepiesa 615,360
   player1turn
   inc scor1
   jmp out26
   
   etii7: 
    
   mov matrice[17*4],2
   mov matrice[26*4],0
   draw_piece_macro 515,260,0
   stergepiesa 615,360 
   player2turn
    mov jucatorok,1
   int18:
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out26
   cmp x2,799
   jg out26
   cmp y2,249
   jl out26
   cmp y2,349
   jg out26
   cmp matrice[19*4],0 ;verif daca patratul e gol (dreapta)
   jne capt8
   jmp etii8
capt8:
   cmp matrice[19*4],1
   jne out26
   cmp matrice[12*4],0
   jne out26
   mov matrice[12*4],2
   mov matrice[19*4],0
   mov matrice[26*4],0
   draw_piece_macro 815, 160,0
   stergepiesa 715,260
   stergepiesa 615,360
   player2turn
   inc scor1
   jmp out26
   
   etii8: 
    
   mov matrice[19*4],2
   mov matrice[26*4],0
   draw_piece_macro 715,260,0
   stergepiesa 615,360  
    mov jucatorok,1
     
   out26:
   
   ;patratul 28
   cmp matrice[28*4],2 ;daca nu este piesa neagra pe patrat 
   jne out28
   cmp x1,800   ;verif daca s-a dat click in patratul 28
   jl out28
   cmp x1,899 
   jg out28
   cmp y1,349
   jl out28
   cmp y1,449
   jg out28
      
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int17
   cmp x2,799
   jg int17
   cmp y2,249
   jl int17
   cmp y2,349
   jg int17
   cmp matrice[19*4],0 ;verif daca patratul e gol (stanga)
   jne capt9
   jmp etii9
capt9:
   cmp matrice[19*4],1
   jne out28
   cmp matrice[10*4],0
   jne out28
   mov matrice[10*4],2
   mov matrice[19*4],0
   mov matrice[28*4],0
   draw_piece_macro 615, 160,0
   stergepiesa 715,260
   stergepiesa 815,360
   player1turn
   inc scor1
   jmp out28
   
   etii9:
  
   mov matrice[19*4],2
   mov matrice[28*4],0
   draw_piece_macro 715,260,0
   stergepiesa 815,360 
   player2turn
    mov jucatorok,1
   int17:
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out28
   cmp x2,999
   jg out28
   cmp y2,249
   jl out28
   cmp y2,349
   jg out28
   cmp matrice[21*4],0 ;verif daca patratul e gol (dreapta)
   jne capt10
   jmp etii10
capt10:
   cmp matrice[21*4],1
   jne out28
   cmp matrice[14*4],0
   jne out28
   mov matrice[14*4],2
   mov matrice[21*4],0
   mov matrice[28*4],0
   draw_piece_macro 1015, 160,0
   stergepiesa 915,260
   stergepiesa 815,360
   player1turn
   inc scor1
   jmp out28
   
   etii10:
   jne out28
   mov matrice[21*4],2
   mov matrice[28*4],0
   draw_piece_macro 915,260,0
   stergepiesa 815,360  
   player2turn
    mov jucatorok,1
     
   out28:
   
   ;patratul 30
   cmp matrice[30*4],2 ;daca nu este piesa neagra pe patrat 
   jne out30
   cmp x1,1000   ;verif daca s-a dat click in patratul 30
   jl out30
   cmp x1,1099 
   jg out30
   cmp y1,349
   jl out30
   cmp y1,449
   jg out30
      
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int16
   cmp x2,999
   jg int16
   cmp y2,249
   jl int16
   cmp y2,349
   jg int16
   cmp matrice[21*4],0 ;verif daca patratul e gol (stanga)
   jne capt11
   jmp etii11
capt11:
   cmp matrice[21*4],1
   jne out30
   cmp matrice[12*4],0
   jne out30
   mov matrice[12*4],2
   mov matrice[21*4],0
   mov matrice[30*4],0
   draw_piece_macro 815, 160,0
   stergepiesa 915,260
   stergepiesa 1015,360
   player1turn
   inc scor1
   jmp out30
   
   etii11:
   mov matrice[21*4],2
   mov matrice[30*4],0
   draw_piece_macro 915,260,0
   stergepiesa 1015,360
   player2turn
   mov jucatorok,1   
   int16:
   cmp x2,1100  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out30
   cmp x2,1199
   jg out30
   cmp y2,249
   jl out30
   cmp y2,349
   jg out30
   cmp matrice[23*4],0 ;verif daca patratul e gol (dreapta)
   jne out30
   mov matrice[23*4],2
   mov matrice[30*4],0
   draw_piece_macro 1115,260,0
   stergepiesa 1015,360  
   player2turn
    mov jucatorok,1
     
   out30:
   
  ;patratul 33
   cmp matrice[33*4],2 ;daca nu este piesa neagra pe patrat 
   jne out33
   cmp x1,500   ;verif daca s-a dat click in patratul 33
   jl out33
   cmp x1,599 
   jg out33
   
   cmp y1,449
   jl out33
   cmp y1,549
   jg out33
      
   cmp x2,400  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int21
   cmp x2,499
   jg int21
   cmp y2,349
   jl int21
   cmp y2,449
   jg int21
   cmp matrice[24*4],0 ;verif daca patratul e gol (stanga)
   jne int21
   mov matrice[24*4],2
   mov matrice[33*4],0
   draw_piece_macro 415,360,0
   stergepiesa 515,460 
   player2turn
    mov jucatorok,1
   int21:
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out33
   cmp x2,699
   jg out33
   cmp y2,349
   jl out33
   cmp y2,449
   jg out33
   cmp matrice[26*4],0 ;verif daca patratul e gol (dreapta)
   jne capt12
   jmp etii12
capt12:
   cmp matrice[26*4],1
   jne out30
   cmp matrice[19*4],0
   jne out30
   mov matrice[19*4],2
   mov matrice[26*4],0
   mov matrice[33*4],0
   draw_piece_macro 715, 260,0
   stergepiesa 615,360
   stergepiesa 515,460
   player1turn
   inc scor1
   jmp out33
   
   etii12:
    
   mov matrice[26*4],2
   mov matrice[33*4],0
   draw_piece_macro 615,360,0
   stergepiesa 515,460  
   player2turn
    mov jucatorok,1
     
   out33:
   
   ;patratul 35
   cmp matrice[35*4],2 ;daca nu este piesa neagra pe patrat 
   jne out35
   cmp x1,700   ;verif daca s-a dat click in patratul 35
   jl out35
   cmp x1,799 
   jg out35
   cmp y1,449
   jl out35
   cmp y1,549
   jg out35
      
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int20
   cmp x2,699
   jg int20
   cmp y2,349
   jl int20
   cmp y2,449
   jg int20
   cmp matrice[26*4],0 ;verif daca patratul e gol (stanga)
  
   jne capt13
   jmp etii13
capt13:
   cmp matrice[26*4],1
   jne out35
   cmp matrice[17*4],0
   jne out35
   mov matrice[17*4],2
   mov matrice[26*4],0
   mov matrice[35*4],0
   draw_piece_macro 515, 260,0
   stergepiesa 615,360
   stergepiesa 715,460
   player1turn
   inc scor1
   jmp out35
   
   etii13:
    
   mov matrice[26*4],2
   mov matrice[35*4],0
   draw_piece_macro 615,360,0
   stergepiesa 715,460 
   player2turn
   mov jucatorok,1
   int20:
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out35
   cmp x2,899
   jg out35
   cmp y2,349
   jl out35
   cmp y2,449
   jg out35
   cmp matrice[28*4],0 ;verif daca patratul e gol (dreapta)
   jne capt14
   jmp etii14
capt14:
   cmp matrice[28*4],1
   jne out35
   cmp matrice[21*4],0
   jne out35
   mov matrice[21*4],2
   mov matrice[28*4],0
   mov matrice[35*4],0
   draw_piece_macro 915, 260,0
   stergepiesa 815,360
   stergepiesa 715,460
   player1turn
   inc scor1
   jmp out35
   
   etii14:
   
   mov matrice[28*4],2
   mov matrice[35*4],0
   draw_piece_macro 815,360,0
   stergepiesa 715,460  
   player2turn
    mov jucatorok,1
     
   out35:
   ;patratul 37
   cmp matrice[37*4],2 ;daca nu este piesa neagra pe patrat 
   jne out37
   cmp x1,900   ;verif daca s-a dat click in patratul 37
   jl out37
   cmp x1,999 
   jg out37
   cmp y1,449
   jl out37
   cmp y1,549
   jg out37
      
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int19
   cmp x2,899
   jg int19
   cmp y2,349
   jl int19
   cmp y2,449
   jg int19
   cmp matrice[28*4],0 ;verif daca patratul e gol (stanga)
   jne capt15
   jmp etii15
capt15:
   cmp matrice[28*4],1
   jne out37
   cmp matrice[19*4],0
   jne out37
   mov matrice[19*4],2
   mov matrice[28*4],0
   mov matrice[37*4],0
   draw_piece_macro 715, 260,0
   stergepiesa 815,360
   stergepiesa 915,460
   player1turn
   inc scor1
   jmp out37
   
   etii15:
    
   mov matrice[28*4],2
   mov matrice[37*4],0
   draw_piece_macro 815,360,0
   stergepiesa 915,460 
   player2turn
    mov jucatorok,1
   int19:
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out37
   cmp x2,1099
   jg out37
   cmp y2,349
   jl out37
   cmp y2,449
   jg out37
   cmp matrice[30*4],0 ;verif daca patratul e gol (dreapta)
   jne capt16
   jmp etii16
capt16:
   cmp matrice[30*4],1
   jne out37
   cmp matrice[23*4],0
   jne out37
   mov matrice[23*4],2
   mov matrice[30*4],0
   mov matrice[37*4],0
   draw_piece_macro 1115, 260,0
   stergepiesa 1015,360
   stergepiesa 915,460
   player1turn
   inc scor1
   jmp out37
   
   etii16:
    
   mov matrice[30*4],2
   mov matrice[37*4],0
   draw_piece_macro 1015,360,0
   stergepiesa 915,460  
   player2turn
    mov jucatorok,1
     
   out37:
   
   ;patratul 39
   cmp matrice[39*4],2 ;daca nu este piesa neagra pe patrat 
   jne out39
   cmp x1,1100   ;verif daca s-a dat click in patratul 39
   jl out39
   cmp x1,1199 
   jg out39
   cmp y1,449
   jl out39
   cmp y1,549
   jg out39
      
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out39
   cmp x2,1099
   jg out39
   cmp y2,349
   jl out39
   cmp y2,449
   jg out39
   cmp matrice[30*4],0 ;verif daca patratul e gol (stanga)
   jne capt17
   jmp etii17
capt17:
   cmp matrice[30*4],1
   jne out39
   cmp matrice[21*4],0
   jne out39
   mov matrice[21*4],2
   mov matrice[30*4],0
   mov matrice[39*4],0
   draw_piece_macro 915, 260,0
   stergepiesa 1015,360
   stergepiesa 1115,460
   player1turn
   inc scor1
   jmp out39
   
   etii17:
    
   mov matrice[30*4],2
   mov matrice[39*4],0
   draw_piece_macro 1015,360,0
   stergepiesa 1115,460 
   player2turn
    mov jucatorok,1
   out39:
   
   
   ;patratul 40
   cmp matrice[40*4],2 ;daca nu este piesa neagra pe patrat 
   jne out40
   cmp x1,400   ;verif daca s-a dat click in patratul 40
   jl out40
   cmp y1,549
   jl out40
   cmp x1,499 
   jg out40
   cmp y1,649
   jg out40
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out40 ; jump pentru a 2 a verificare (interior jump )
   cmp x2,599
   jg out40
   cmp y2,449
   jl out40
   cmp y2,549
   jg out40
   cmp matrice[33*4],0 ;verif daca patratul e gol (stanga)
   jne capt18
   jmp etii18
capt18:
   cmp matrice[33*4],1
   jne out40
   cmp matrice[26*4],0
   jne out40
   mov matrice[26*4],2
   mov matrice[33*4],0
   mov matrice[40*4],0
   draw_piece_macro 615, 360,0
   stergepiesa 515,460
   stergepiesa 415,560
   player1turn
   inc scor1
   jmp out40
   
   etii18:
    
   mov matrice[33*4],2
   mov matrice[40*4],0
   draw_piece_macro 515,460,0
   stergepiesa 415,560 
   player2turn
   mov jucatorok,1
     
   out40:
  
   ;patratul 42
   cmp matrice[42*4],2 ;daca nu este piesa neagra pe patrat 
   jne out42
   cmp x1,600   ;verif daca s-a dat click in patratul 42
   jl out42
   cmp y1,549
   jl out42
   cmp x1,699 
   jg out42
   cmp y1,649
   jg out42
      
   cmp x2,500  ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int22
   cmp x2,599
   jg int22
   cmp y2,449
   jl int22
   cmp y2,549
   jg int22
   cmp matrice[33*4],0 ;verif daca patratul e gol (stanga)
   jne capt19
   jmp etii19
capt19:
   cmp matrice[33*4],1
   jne out42
   cmp matrice[24*4],0
   jne out42
   mov matrice[24*4],2
   mov matrice[33*4],0
   mov matrice[42*4],0
   draw_piece_macro 415, 360,0
   stergepiesa 515,460
   stergepiesa 615,560
   player1turn
   inc scor1
   jmp out42
   
   etii19:
    
   mov matrice[33*4],2
   mov matrice[42*4],0
   draw_piece_macro 515,460,0
   stergepiesa 615,560 
   player2turn
    mov jucatorok,1
   int22:
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out42
   cmp x2,799
   jg out42
   cmp y2,449
   jl out42
   cmp y2,549
   jg out42
   cmp matrice[35*4],0 ;verif daca patratul e gol (dreapta)
   jne capt20
   jmp etii20
capt20:
   cmp matrice[35*4],1
   jne out42
   cmp matrice[28*4],0
   jne out42
   mov matrice[28*4],2
   mov matrice[35*4],0
   mov matrice[42*4],0
   draw_piece_macro 815, 360,0
   stergepiesa 715,460
   stergepiesa 615,560
   player1turn
   inc scor1
   jmp out42
   
   etii20:
    
   mov matrice[35*4],2
   mov matrice[42*4],0
   draw_piece_macro 715,460,0
   stergepiesa 615,560  
   player2turn
    mov jucatorok,1 
     
   out42:
   
   ;patratul 44
   cmp matrice[44*4],2 ;daca nu este piesa neagra pe patrat 
   jne out44     ;verif daca s-a dat click in patratul 44
   cmp x1,800 
   jl out44
   cmp x1,899 
   jg out44   
   cmp y1,549
   jl out44
   cmp y1,649
   jg out44
      
   cmp x2,700 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int23
   cmp x2,799
   jg int23
   cmp y2,449
   jl int23 
   cmp y2,549
   jg int23
   cmp matrice[35*4],0 ;verif daca patratul e gol (stanga)
   jne capt21
   jmp etii21
capt21:
   cmp matrice[35*4],1
   jne out44
   cmp matrice[26*4],0
   jne out44
   mov matrice[26*4],2
   mov matrice[35*4],0
   mov matrice[44*4],0
   draw_piece_macro 615, 360,0
   stergepiesa 715,460
   stergepiesa 815,560
   player1turn
   inc scor1
   jmp out44
   
   etii21:
    
   mov matrice[35*4],2
   mov matrice[44*4],0    
   draw_piece_macro 715,460,0
   stergepiesa 815,560 
   player2turn
    mov jucatorok,1
   int23:
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out44
   cmp x2,999
   jg out44
   cmp y2,449
   jl out44
   cmp y2,549
   jg out44
   cmp matrice[37*4],0 ;verif daca patratul e gol (dreapta)
    jne capt22
   jmp etii22
capt22:
   cmp matrice[37*4],1
   jne out44
   cmp matrice[30*4],0
   jne out44
   mov matrice[30*4],2
   mov matrice[37*4],0
   mov matrice[44*4],0
   draw_piece_macro 1015, 360,0
   stergepiesa 915,460
   stergepiesa 815,560
   player1turn
   inc scor1
   jmp out44
   
   etii22:
    
   mov matrice[37*4],2
   mov matrice[44*4],0
   draw_piece_macro 915,460,0
   stergepiesa 815,560  
   player2turn
    mov jucatorok,1
   
   out44:   
   
   ;patratul 46
   cmp matrice[46*4],2 ;daca nu este piesa neagra pe patrat 
   jne out46     ;verif daca s-a dat click in patratul 46
   cmp x1,1000 
   jl out46
   cmp x1,1099 
   jg out46   
   cmp y1,549
   jl out46
   cmp y1,649
   jg out46
      
   cmp x2,900 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int24
   cmp x2,999
   jg int24
   cmp y2,449
   jl int24 
   cmp y2,549
   jg int24
   cmp matrice[37*4],0 ;verif daca patratul e gol (stanga)
    jne capt23
   jmp etii23
capt23:
   cmp matrice[37*4],1
   jne out46
   cmp matrice[28*4],0
   jne out46
   mov matrice[28*4],2
   mov matrice[37*4],0
   mov matrice[46*4],0
   draw_piece_macro 815, 360,0
   stergepiesa 915,460
   stergepiesa 1015,560
   player1turn
   inc scor1
   jmp out46
   
   etii23:
    
   mov matrice[37*4],2
   mov matrice[46*4],0    
   draw_piece_macro 915,460,0
   stergepiesa 1015,560 
   player2turn
    mov jucatorok,1
   int24:
   cmp x2,1100  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out46
   cmp x2,1199
   jg out46
   cmp y2,449
   jl out46
   cmp y2,549
   jg out46
   cmp matrice[39*4],0 ;verif daca patratul e gol (dreapta)
   jne out46
   mov matrice[39*4],2
   mov matrice[46*4],0
   draw_piece_macro 1115,460,0
   stergepiesa 1015,560  
   player2turn
   mov jucatorok,1
   
   out46:  
   
   ;patratul 49
   cmp matrice[49*4],2 ;daca nu este piesa neagra pe patrat 
   jne out49     ;verif daca s-a dat click in patratul 49
   cmp x1,500
   jl out49
   cmp x1,599
   jg out49   
   cmp y1,649
   jl out49
   cmp y1,749
   jg out49
      
   cmp x2,400 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int25
   cmp x2,499
   jg int25
   cmp y2,549
   jl int25 
   cmp y2,649
   jg int25
   cmp matrice[40*4],0 ;verif daca patratul e gol (stanga)
   jnz int25
   mov matrice[40*4],2
   mov matrice[49*4],0    
   draw_piece_macro 415,560,0
   stergepiesa 515,660 
   player2turn
    mov jucatorok,1
   int25:
   cmp x2,600  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out49
   cmp x2,699
   jg out49
   cmp y2,549
   jl out49
   cmp y2,649
   jg out49
   cmp matrice[42*4],0 ;verif daca patratul e gol (dreapta)
    jne capt24
   jmp etii24
capt24:
   cmp matrice[42*4],1
   jne out49
   cmp matrice[35*4],0
   jne out49
   mov matrice[35*4],2
   mov matrice[42*4],0
   mov matrice[49*4],0
   draw_piece_macro 715, 460,0
   stergepiesa 615,560
   stergepiesa 515,660
   player1turn
   inc scor1
   jmp out49
   
   etii24:
   
   mov matrice[42*4],2
   mov matrice[49*4],0
   draw_piece_macro 615,560,0
   stergepiesa 515,660  
   player2turn
   mov jucatorok,1
	
   out49: 
   
   ;patratul 51
   cmp matrice[51*4],2 ;daca nu este piesa neagra pe patrat 
   jne out51     ;verif daca s-a dat click in patratul 51
   cmp x1,700
   jl out51
   cmp x1,799
   jg out51  
   cmp y1,649
   jl out51
   cmp y1,749
   jg out51
      
   cmp x2,600 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int26
   cmp x2,699
   jg int26
   cmp y2,549
   jl int26 
   cmp y2,649
   jg int26
   cmp matrice[42*4],0 ;verif daca patratul e gol (stanga)
   jne capt25
   jmp etii25
capt25:
   cmp matrice[42*4],1
   jne out51
   cmp matrice[33*4],0
   jne out51
   mov matrice[33*4],2
   mov matrice[42*4],0
   mov matrice[51*4],0
   draw_piece_macro 515, 460,0
   stergepiesa 615,560
   stergepiesa 715,660
   player1turn
   inc scor1
   jmp out51
   
   etii25:
    
   mov matrice[42*4],2
   mov matrice[51*4],0    
   draw_piece_macro 615,560,0
   stergepiesa 715,660 
   player2turn
    mov jucatorok,1
   int26:
   cmp x2,800  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out51
   cmp x2,899
   jg out51
   cmp y2,549
   jl out51
   cmp y2,649
   jg out51
   cmp matrice[44*4],0 ;verif daca patratul e gol (dreapta)
   jne capt26
   jmp etii26
capt26:
   cmp matrice[44*4],1
   jne out51
   cmp matrice[37*4],0
   jne out51
   mov matrice[37*4],2
   mov matrice[44*4],0
   mov matrice[51*4],0
   draw_piece_macro 915, 460,0
   stergepiesa 815,560
   stergepiesa 715,660
   player1turn
   inc scor1
   jmp out51
   
   etii26:
     
   mov matrice[44*4],2
   mov matrice[51*4],0
   draw_piece_macro 815,560,0
   stergepiesa 715,660  
   player2turn
   mov jucatorok,1
	
   out51: 
   
   ;patratul 53
   cmp matrice[53*4],2 ;daca nu este piesa neagra pe patrat 
   jne out53     ;verif daca s-a dat click in patratul 53
   cmp x1,900
   jl out53
   cmp x1,999
   jg out53  
   cmp y1,649
   jl out53
   cmp y1,749
   jg out53
      
   cmp x2,800 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int27
   cmp x2,899
   jg int27
   cmp y2,549
   jl int27 
   cmp y2,649
   jg int27
   cmp matrice[44*4],0 ;verif daca patratul e gol (stanga)
   jne capt27
   jmp etii27
capt27:
   cmp matrice[44*4],1
   jne out53
   cmp matrice[35*4],0
   jne out53
   mov matrice[35*4],2
   mov matrice[44*4],0
   mov matrice[53*4],0
   draw_piece_macro 715, 460,0
   stergepiesa 815,560
   stergepiesa 915,660
   player1turn
   inc scor1
   jmp out53
   
   etii27:
   
   mov matrice[44*4],2
   mov matrice[53*4],0    
   draw_piece_macro 815,560,0
   stergepiesa 915,660 
   player2turn
    mov jucatorok,1
   int27:
   cmp x2,1000  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out53
   cmp x2,1099
   jg out53
   cmp y2,549
   jl out53
   cmp y2,649
   jg out53
   cmp matrice[46*4],0 ;verif daca patratul e gol (dreapta)
    jne capt28
    jmp etiii30
capt28:
    cmp matrice[46*4],1
     jne out53
     cmp matrice[39*4],0
     jne out53
    mov matrice[39*4],2
     mov matrice[46*4],0
     mov matrice[53*4],0
     draw_piece_macro 1115, 460,0
     stergepiesa 1015,560
    stergepiesa 915,660
	player1turn
     inc scor1
     jmp out53
   
    etiii30:
    
   mov matrice[46*4],2
   mov matrice[53*4],0
   draw_piece_macro 1015,560,0
   stergepiesa 915,660  
   player2turn
    mov jucatorok,1
	
   out53:

   ;patratul 55
   cmp matrice[55*4],2 ;daca nu este piesa neagra pe patrat 
   jne out55     ;verif daca s-a dat click in patratul 55
   cmp x1,1100
   jl out55
   cmp x1,1199
   jg out55  
   cmp y1,649
   jl out55
   cmp y1,749
   jg out55
      
   cmp x2,1000 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl out55
   cmp x2,1099
   jg out55
   cmp y2,549
   jl out55 
   cmp y2,649
   jg out55
   cmp matrice[46*4],0 ;verif daca patratul e gol (stanga)
    jne capt29
    jmp etiii29
capt29:
    cmp matrice[46*4],1
     jne out55
     cmp matrice[37*4],0
     jne out55
    mov matrice[37*4],2
     mov matrice[46*4],0
     mov matrice[55*4],0
     draw_piece_macro 915, 460,0
     stergepiesa 1015,560
    stergepiesa 1115,660
	player1turn
     inc scor1
     jmp out55
   
    etiii29:
    
   mov matrice[46*4],2
   mov matrice[55*4],0    
   draw_piece_macro 1015,560,0
   stergepiesa 1115,660 
   player2turn
    mov jucatorok,1
   
	
   out55: 

   ;patratul 56
   cmp matrice[56*4],2 ;daca nu este piesa neagra pe patrat 
   jne out56     ;verif daca s-a dat click in patratul 56
   cmp x1,400
   jl out56
   cmp x1,499
   jg out56  
   cmp y1,749
   jl out56
   cmp y1,849
   jg out56
      
   cmp x2,500 ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out56
   cmp x2,599
   jg out56
   cmp y2,649
   jl out56 
   cmp y2,749
   jg out56
   cmp matrice[49*4],0 ;verif daca patratul e gol (dreapta)
   jne capt31
    jmp etiii31
capt31:
    cmp matrice[49*4],1
     jne out56
     cmp matrice[42*4],0
     jne out56
    mov matrice[42*4],2
     mov matrice[49*4],0
     mov matrice[56*4],0
     draw_piece_macro 615, 560,0
     stergepiesa 515,660
     stergepiesa 415,760
	 player1turn
     inc scor1
     jmp out56
   
    etiii31:
    
    
   mov matrice[49*4],2
   mov matrice[56*4],0    
   draw_piece_macro 515,660,0
   stergepiesa 415,760 
   player2turn
   mov jucatorok,1
	
   out56:  
   
   ;patratul 58
   cmp matrice[58*4],2 ;daca nu este piesa neagra pe patrat 
   jne out58     ;verif daca s-a dat click in patratul 58
   cmp x1,600
   jl out58
   cmp x1,699
   jg out58  
   cmp y1,749
   jl out58
   cmp y1,849
   jg out58
      
   cmp x2,500 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int28
   cmp x2,599
   jg int28
   cmp y2,649
   jl int28 
   cmp y2,749
   jg int28
   cmp matrice[49*4],0 ;verif daca patratul e gol (stanga)
   jne capt32
    jmp etiii32
capt32:
    cmp matrice[49*4],1
     jne out58
     cmp matrice[40*4],0
     jne out58
    mov matrice[40*4],2
     mov matrice[49*4],0
     mov matrice[58*4],0
     draw_piece_macro 415, 560,0
     stergepiesa 515,660
     stergepiesa 615,760
	 player1turn
     inc scor1
     jmp out58
   
    etiii32:
    
    
   mov matrice[49*4],2
   mov matrice[58*4],0    
   draw_piece_macro 515,660,0
   stergepiesa 615,760 
   player2turn
   mov jucatorok,1
   int28:
   cmp x2,700  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out58
   cmp x2,799
   jg out58
   cmp y2,649
   jl out58
   cmp y2,749
   jg out58
   cmp matrice[51*4],0 ;verif daca patratul e gol (dreapta)
   jne capt33
    jmp etiii33
capt33:
    cmp matrice[51*4],1
     jne out58
     cmp matrice[44*4],0
     jne out58
    mov matrice[44*4],2
     mov matrice[51*4],0
     mov matrice[58*4],0
     draw_piece_macro 815, 560,0
     stergepiesa 715,660
     stergepiesa 615,760
	 player1turn
     inc scor1
     jmp out58
   
    etiii33:
  
   mov matrice[51*4],2
   mov matrice[58*4],0
   draw_piece_macro 715,660,0
   stergepiesa 615,760
   player2turn   
    mov jucatorok,1
	
   out58:
   
   ;patratul 60
   cmp matrice[60*4],2 ;daca nu este piesa neagra pe patrat 
   jne out60     ;verif daca s-a dat click in patratul 60
   cmp x1,800
   jl out60
   cmp x1,899
   jg out60  
   cmp y1,749
   jl out60
   cmp y1,849
   jg out60
      
   cmp x2,700 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int29
   cmp x2,799
   jg int29
   cmp y2,649
   jl int29 
   cmp y2,749
   jg int29
   cmp matrice[51*4],0 ;verif daca patratul e gol (stanga)
   jne capt34
   jmp etiii34
capt34:
    cmp matrice[51*4],1
     jne out60
     cmp matrice[42*4],0
     jne out60
    mov matrice[42*4],2
     mov matrice[51*4],0
     mov matrice[60*4],0
     draw_piece_macro 615, 560,0
     stergepiesa 715,660
     stergepiesa 815,760
	 player1turn
     inc scor1
     jmp out60
   
    etiii34:
   
   mov matrice[51*4],2
   mov matrice[60*4],0    
   draw_piece_macro 715,660,0
   stergepiesa 815,760 
   player2turn
    mov jucatorok,1
   int29:
   cmp x2,900  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out60
   cmp x2,999
   jg out60
   cmp y2,649
   jl out60
   cmp y2,749
   jg out60
   cmp matrice[53*4],0 ;verif daca patratul e gol (dreapta)
   jne capt35
    jmp etiii35
capt35:
    cmp matrice[53*4],1
     jne out60
     cmp matrice[46*4],0
     jne out60
    mov matrice[46*4],2
     mov matrice[53*4],0
     mov matrice[60*4],0
     draw_piece_macro 1015, 560,0
     stergepiesa 915,660
     stergepiesa 815,760
	 player1turn
     inc scor1
     jmp out60
   
    etiii35:
  
   mov matrice[53*4],2
   mov matrice[60*4],0
   draw_piece_macro 915,660,0
   stergepiesa 815,760  
   player2turn
    mov jucatorok,1
	
   out60:
   
   ;patratul 62
   cmp matrice[62*4],2 ;daca nu este piesa neagra pe patrat 
   jne out62    ;verif daca s-a dat click in patratul 62
   cmp x1,1000
   jl out62
   cmp x1,1099
   jg out62  
   cmp y1,749
   jl out62
   cmp y1,849
   jg out62
      
   cmp x2,900 ;verif daca s-a dat click pe diagonala in patratul urmat (stanga)
   jl int30
   cmp x2,999
   jg int30
   cmp y2,649
   jl int30 
   cmp y2,749
   jg int30
   cmp matrice[53*4],0 ;verif daca patratul e gol (stanga)
   jne capt36
   jmp etiii36
capt36:
    cmp matrice[53*4],1
     jne out62
     cmp matrice[44*4],0
     jne out62
    mov matrice[44*4],2
     mov matrice[53*4],0
     mov matrice[62*4],0
     draw_piece_macro 815, 560,0
     stergepiesa 915,660
     stergepiesa 1015,760
	 player1turn
     inc scor1
     jmp out62
   
    etiii36:
   
   mov matrice[53*4],2
   mov matrice[62*4],0    
   draw_piece_macro 915,660,0
   stergepiesa 1015,760 
   player2turn
    mov jucatorok,1
   int30:
   cmp x2,1100  ;verif daca s-a dat click pe diagonala in patratul urmat (dreapta)
   jl out62
   cmp x2,1199
   jg out62
   cmp y2,649
   jl out62
   cmp y2,749
   jg out62
   cmp matrice[55*4],0 ;verif daca patratul e gol (dreapta)
   jne out62
   mov matrice[55*4],2
   mov matrice[62*4],0 
   draw_piece_macro 1115,660,0
   stergepiesa 1015,760 
   player2turn   
   mov jucatorok,1
	
   out62:
     
   jmp evt_click
  
endm

castigap1 macro 
local veriflinie,final,down1,down2
   cmp scor1,12
   jne down2
   mov winner1,1
   mov scormax1,1
   down2:
   mov esi,1
   mov ecx,5
   veriflinie:
   
   cmp matrice[esi*4],2
   jne down1
   mov winner1,1
   down1:
   add esi,2
   loop veriflinie	
   
   
   final:
endm
castigap2 macro 
local veriflinie,final,down1,down2
   cmp scor2,12 
   jne down2
   mov winner2,1
   mov scormax2,1
   down2:
   mov esi,56
   mov ecx,5
   veriflinie:
   
   cmp matrice[esi*4],1
   jne down1
   mov winner2,1
   down1:
   add esi,2
   loop veriflinie
    
   
   final:
endm
player1turn macro
make_text_macro 'P',area,85,700,colorfortext
make_text_macro 'L',area,95,700,colorfortext
make_text_macro 'A',area,105,700,colorfortext
make_text_macro 'Y',area,115,700,colorfortext
make_text_macro 'E',area,125,700,colorfortext
make_text_macro 'R',area,135,700,colorfortext
make_text_macro ' ',area,145,700,colorfortext
make_text_macro '1',area,155,700,colorfortext
make_text_macro ' ',area,165,700,colorfortext
make_text_macro 'T',area,175,700,colorfortext
make_text_macro 'U',area,185,700,colorfortext
make_text_macro 'R',area,195,700,colorfortext
make_text_macro 'N',area,205,700,colorfortext
make_text_macro ' ',area,215,700,colorfortext
make_text_macro 'B',area,125,720,colorfortext
make_text_macro 'L',area,135,720,colorfortext
make_text_macro 'A',area,145,720,colorfortext
make_text_macro 'C',area,155,720,colorfortext
make_text_macro 'K',area,165,720,colorfortext

color_text_macro 'P',area,85,700,0
color_text_macro 'L',area,95,700,0
color_text_macro 'A',area,105,700,0
color_text_macro 'Y',area,115,700,0
color_text_macro 'E',area,125,700,0
color_text_macro 'R',area,135,700,0
color_text_macro ' ',area,145,700,0
color_text_macro '1',area,155,700,0
color_text_macro ' ',area,165,700,0
color_text_macro 'T',area,175,700,0
color_text_macro 'U',area,185,700,0
color_text_macro 'R',area,195,700,0
color_text_macro 'N',area,205,700,0
color_text_macro ' ',area,215,700,0
color_text_macro 'B',area,125,720,0
color_text_macro 'L',area,135,720,0
color_text_macro 'A',area,145,720,0
color_text_macro 'C',area,155,720,0
color_text_macro 'K',area,165,720,0
 
endm
player2turn macro
make_text_macro 'P',area,85,700,colorfortext
make_text_macro 'L',area,95,700,colorfortext
make_text_macro 'A',area,105,700,colorfortext
make_text_macro 'Y',area,115,700,colorfortext
make_text_macro 'E',area,125,700,colorfortext
make_text_macro 'R',area,135,700,colorfortext
make_text_macro ' ',area,145,700,colorfortext
make_text_macro '2',area,155,700,colorfortext
make_text_macro ' ',area,165,700,colorfortext
make_text_macro 'T',area,175,700,colorfortext
make_text_macro 'U',area,185,700,colorfortext
make_text_macro 'R',area,195,700,colorfortext
make_text_macro 'N',area,205,700,colorfortext
make_text_macro ' ',area,215,700,colorfortext
make_text_macro 'R',area,125,720,colorfortext
make_text_macro 'E',area,135,720,colorfortext
make_text_macro 'D',area,145,720,colorfortext
 
color_text_macro 'P',area,85,700,0c52424h
color_text_macro 'L',area,95,700,0c52424h
color_text_macro 'A',area,105,700,0c52424h
color_text_macro 'Y',area,115,700,0c52424h
color_text_macro 'E',area,125,700,0c52424h
color_text_macro 'R',area,135,700,0c52424h
color_text_macro ' ',area,145,700,0c52424h
color_text_macro '2',area,155,700,0c52424h
color_text_macro ' ',area,165,700,0c52424h
color_text_macro 'T',area,175,700,0c52424h
color_text_macro 'U',area,185,700,0c52424h
color_text_macro 'R',area,195,700,0c52424h
color_text_macro 'N',area,205,700,0c52424h
color_text_macro ' ',area,215,700,0c52424h
color_text_macro 'R',area,125,720,0c52424h
color_text_macro 'E',area,135,720,0c52424h
color_text_macro 'D',area,145,720,0c52424h
color_text_macro ' ',area,155,720,0c52424h
color_text_macro ' ',area,165,720,0ffffffh  
 

endm

stopgamerun macro
local firstloop
	mov ecx,64
	mov esi,0
	firstloop:
	   mov matrice[esi*4],0
       inc esi
	loop firstloop
endm
draw proc
	push ebp
	mov ebp, esp
	pusha
	
    cmp winner1,1
	je castigator
	cmp winner2,1
	je castigator
	mov eax, [ebp+arg1]
	cmp eax,0
	jz inittabla
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	 	
	jmp final_draw

inittabla:
    cmp eax,0    ;init tabla 
	jne down3
	mov openprog,1 ;daca se face init sa se sara la evt_click
	down3:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
    drawtable
	initmat
	mov jucatorok,0
	player1turn
	mov scor1,0
	mov scor2,0
	mov scormax1,0
	mov scormax2,0
	mov winner1,0
	mov winner2,0
	cmp restartbut,1
	jne down1
	make_text_macro 'G', area, 1315,487,0  ;in caz de se da restart sa se afiseze mesaj
	make_text_macro 'A', area, 1325,487,0
	make_text_macro 'M', area, 1335,487,0
	make_text_macro 'E', area, 1345,487,0
	make_text_macro ' ', area, 1355,487,0
	make_text_macro 'R', area, 1365,487,0
	make_text_macro 'E', area, 1375,487,0
	make_text_macro 'S', area, 1385,487,0
	make_text_macro 'T', area, 1395,487,0
	make_text_macro 'A', area, 1405,487,0
	make_text_macro 'R', area, 1415,487,0
	make_text_macro 'T', area, 1425,487,0
	make_text_macro 'E', area, 1435,487,0
	make_text_macro 'D', area, 1445,487,0
	down1:
	mov restartbut,0 
	cmp openprog,0  ;daca se deschide prima oara programul atunci nu se sare la evt_click 
	je evt_click
	mov openprog,0
	jmp final_draw 
   
evt_click:
     
     cmp eax, button_x
	 jl button_fail
	 cmp eax,button_x+button_size
	 jg button_fail
	 mov eax,[ebp+arg3]
	 cmp eax,button_y
	 jl button_fail
	 cmp eax,button_y+button_size
	 jg button_fail
	 mov counterbut,0
	 mov restartbut,1
	 jmp inittabla
	 
	 
button_fail:	
     mov eax,[ebp+arg2]
	 mov ebx,[ebp+arg3]
     cmp clickok,0
	 jne click2
	 mov first_x,eax  ;s-a facut primul click
	 mov first_y,ebx
	 mov clickok,1
	 
	 jmp final_draw
	   
click2:
	 mov second_x,eax ;s-a facut al doilea click
	 mov second_y,ebx
	 mov clickok,0
	 
	 cmp jucatorok,0
	 jne jucator2
	 
	 testpiesaneagra first_x,first_y,second_x,second_y
	 
	 jmp final_Draw
	  
jucator2:
       
     testpiesarosie first_x,first_y,second_x,second_y
	 jmp final_draw
 
bucla_linii:

	mov eax, [ebp+arg2]
	and eax, 0FFh
	; provide a new (random) color
	mul eax
	mul eax
	add eax, ecx
	push ecx
	mov ecx, area_width
	
bucla_coloane:
	mov [edi], eax
	add edi, 4
	add eax, ebx
	loop bucla_coloane
	pop ecx
	loop bucla_linii
	jmp final_draw
	
evt_timer:
    
	inc counter
    inc counterbut
	cmp counterbut,25  ;stergere mesaj dupa 5 sec(game restarted)
	je clearmessage
	jmp final_draw
	
clearmessage:
    make_text_macro 'G', area, 1315,487,0FFFFFFh
 	make_text_macro 'A', area, 1325,487,0FFFFFFh
	make_text_macro 'M', area, 1335,487,0FFFFFFh
	make_text_macro 'E', area, 1345,487,0FFFFFFh
	make_text_macro ' ', area, 1355,487,0FFFFFFh
	make_text_macro 'R', area, 1365,487,0FFFFFFH
	make_text_macro 'E', area, 1375,487,0FFFFFFH
	make_text_macro 'S', area, 1385,487,0FFFFFFH
	make_text_macro 'T', area, 1395,487,0FFFFFFH
	make_text_macro 'A', area, 1405,487,0FFFFFFH
	make_text_macro 'R', area, 1415,487,0FFFFFFH
	make_text_macro 'T', area, 1425,487,0FFFFFFH
	make_text_macro 'E', area, 1435,487,0FFFFFFH
	make_text_macro 'D', area, 1445,487,0FFFFFFH
 
	
castigator:
     cmp winner1,1
	 jne castigator2
	 stergepieseinamic2
	 make_text_macro 'P',area,85,520,0
	 make_text_macro 'L',area,95,520,0
	 make_text_macro 'A',area,105,520,0
	 make_text_macro 'Y',area,115,520,0
     make_text_macro 'E',area,125,520,0
	 make_text_macro 'R',area,135,520,0
	 make_text_macro ' ',area,145,520,0
	 make_text_macro '1',area,155,520,0
	 make_text_macro ' ',area,165,520,0
	 make_text_macro 'W',area,175,520,0
	 make_text_macro 'O',area,185,520,0
	 make_text_macro 'N',area,195,520,0
	 cmp scormax1,1
	 jne testrestbut
	 stopgamerun
	 jmp testrestbut
	 
	 castigator2:
	 
	 cmp winner2,1
	 jne final_draw
	 stergepieseinamic1
	 make_text_macro 'P',area,85,520,0
	 make_text_macro 'L',area,95,520,0
	 make_text_macro 'A',area,105,520,0
	 make_text_macro 'Y',area,115,520,0
     make_text_macro 'E',area,125,520,0
	 make_text_macro 'R',area,135,520,0
	 make_text_macro ' ',area,145,520,0
	 make_text_macro '2',area,155,520,0
	 make_text_macro ' ',area,165,520,0
	 make_text_macro 'W',area,175,520,0
	 make_text_macro 'O',area,185,520,0
	 make_text_macro 'N',area,195,520,0
	 cmp scormax2,1
	 jne testrestbut
	 stopgamerun  
	 
	 testrestbut:
	 cmp eax, button_x
	 jl button_fail
	 cmp eax,button_x+button_size
	 jg button_fail
	 mov eax,[ebp+arg3]
	 cmp eax,button_y
	 jl button_fail
	 cmp eax,button_y+button_size
	 jg button_fail
	 mov counterbut,0
	 mov restartbut,1
	 jmp inittabla
	 
	 	 
	 jmp final_draw	 
final_draw:
    castigap1
	castigap2
    drawplayer1 85,400,scor1 
	drawplayer2 85,420,scor2 
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
