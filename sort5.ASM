format binary
org 100h


start:
	xor	edx, edx
	xor	ebx, ebx
	mov	edi, 10
	mov	di, 10
	mov	si, 80h
	mov	al, [si]

	cmp	al, 0	; brak parametrow (ciagu do posortowania)
	je	_end

	inc	si	; pominiecie pierwszego, standardowego znaku spacji
			; kolejna funkcja zacznie od 82h
	xor	ecx, ecx
	xor	edx, edx
	call	loadToBuffer	; zaladowanie liczb do bufora

	mov	dl, [counter]
	call	outerSort	; sortowanie liczb (met. babelkowa)
	;Wypisanie liczb posortowanych rosnacao a nastepnie malejaco
	xor	ecx, ecx
	call	printNumbers
	call	_enter
	call	printNumbersInv
	jmp	_end

loadToBuffer:
	inc	si
	inc	dl
	mov	al, [si]

	cmp	al, 13
	je	checkEnd	;Koniec (carriage return)?
	cmp	al, 32
	je	checkSpace	;Spacja? (ignorowanie powtorzen)
	cmp	al, 48
	jb	checkChar	;Sprawdzenie czy pojedynczy znak
	cmp	al, 57
	ja	checkChar

	jmp	loadToBuffer

checkEnd:	;Sprawdzenie czy trzeba zapisac liczbe czy ostatni znak to spacja
	cmp	dl, 1	     ;jeden znak koncowy - spacja, nie trzeba zapisywac
	jna	done
	jmp	initLoadLoop

checkSpace:	;Ignorowanie powtarzajacych sie spacji
	cmp	dl, 1
	jna	clear
	jmp	initLoadLoop

checkChar:	;Sprawdzenie czy pojedynczy znak (zamieniany na kod ascii)
	xor	dl, dl
	xor	eax, eax
	xor	ecx, ecx
	mov	al, [si]
	mov	cl, [counter]
	mov	[numbersBuffer + 4*ecx], eax
	inc	cl
	mov	[counter], cl
	cmp	byte[si - 1], 32
	jne	invChar
	cmp	byte[si + 1], 32
	je	loadToBuffer
	cmp	byte[si + 1], 13
	je	done
	jmp	invChar

clear:		;Wyczyszczenie licznika i skok do ponownego rozpoczecia wczytywania
	xor	dl, dl
	jmp	loadToBuffer

initLoadLoop:	;Inicjalizacja petli, cofniecie do pierwszej cyfry wczytywanej liczby
	sub	si, dx
	inc	si
	mov	[digitsCount], dl
	xor	ebx, ebx

loadToReg:	;Petla dla kazdej cyfry
	cmp	[digitsCount], 1
	je	saveNumber     ;Wszyctkie cyfry przetworzone - zapisanie liczby
	xor	eax, eax
	xor	edx, edx
	mov	cl, [digitsCount]	;licznik
	dec	cl
	mov	[digitsCount], cl
	mov	al, [si]
	sub	al, 48			;Wartosc cyfry ascii - '0'
	inc	si
	call	multiply		;Mnozenie cyfr przez 10 n,n-1,...,0 razy
	add	ebx, eax
	jc	overflow		;przepelnienie
	jmp	loadToReg

saveNumber:
	mov	cl, [counter]		;Licznik ilosci liczb
	mov	[numbersBuffer + 4*ecx], ebx
	inc	cl
	mov	[counter], cl

	mov	al, [si]
	cmp	al, 13
	je	done			;Koniec parametrow

	jmp	loadToBuffer		;Wczytanie kolejnej liczby


multiply:
	cmp	cl, 1		;Pierwsza od lewej cyfre liczby n cyfrowej nalezy pomnozyc n-1 razy
	je	done		;Zakonczenie mnozenia cyfry, powrot z wywolania
	mul	edi		;eax*edi
	jo	overflow
	dec	cl		;Licznik, ktorego wartosc wskazuje ile razy jeszcze pomnozyc cyfre
	jmp	multiply	;Kolejna iteracja


printNumbers:	;Wypisuje bufor liczb
	mov	eax, [numbersBuffer + 4*ecx]
	inc	ecx
	push	ecx
	call	printNumber
	call	_space
	pop	ecx
	cmp	cl, [counter]
	je	done
	jmp	printNumbers

printNumbersInv:	;Wypisuje bufor liczb w odwrotnej kolejnosci
	dec	ecx
	mov	eax, [numbersBuffer + 4*ecx]
	push	ecx
	call	printNumber
	call	_space
	pop	ecx
	cmp	cl, 0
	je	done
	jmp	printNumbersInv

printNumber:	;Wypisuje liczbe 32b z rejestru na ekran
	xor	ecx, ecx

	call	loadNumberToBuffer	;Zapisanie liczby jako cyfr do bufora
	call	printNumberFromBuffer	;Wypisanie cyfr z bufora jako numeru

	jmp	done


loadNumberToBuffer:	;Wczytuje cyfry liczby z eax do buforu
	xor	edx,edx 		;Wyczyszczenie poprzedniej reszty z dzielenia
	div	edi			;eax/edi = eax r edx
	mov	[digitsBuffer+ecx], dl	;Zapisanie cyfry do bufora

	inc	ecx
	cmp	eax, 0			;Sprawdzenie czy cala liczba zostala podzielona
	jne	loadNumberToBuffer	;Jesli nie to kolejna iteracja
	jmp	done			;Jesli tak to powrot z wywolania

printNumberFromBuffer:

	mov	dl, [digitsBuffer+ecx-1]
	add	dl, 30h
	mov	ah, 2
	int	21h		;Wypisanie znaku
	dec	ecx
	cmp	ecx, 0		;Czy wszystkie cyfry zostaly wypisane?
	jne	printNumberFromBuffer
	jmp	done


; Sortowanie liczb metoda babelkowa
outerSort:	; for(dl = N - 1; dl > 0; dl--)
	dec	dl
	cmp	dl, 0
	je	done
	xor	cl, cl
	jmp	sort

	sort:		; for(cl = 0; cl < dl; cl++)
		cmp	cl, dl
		je	outerSort
		mov	eax, [numbersBuffer + 4*ecx]
		cmp	eax, [numbersBuffer + 4*ecx + 4]
		ja	swap	; if (d[ecx + 1] > d[ecx])
		inc	cl
		jmp	sort

		swap:		; swap(d[ecx], d[ecx + 1]
			push	eax
			mov	eax, [numbersBuffer + 4*ecx + 4]
			mov	[numbersBuffer + 4*ecx], eax
			pop	eax
			mov	[numbersBuffer + 4*ecx + 4], eax
			inc	cl
			jmp	sort

done:
	ret

invChar:	;Podano niepoprawny znak
	mov	ah, 9
	mov	dx, invCharStr
	int	21h		;Wypisanie tekstu
	jmp	_errorEnd

overflow:	;Nastapilo przepelnienie - wypisanie bledu i zakonczenie programu
	mov	ah, 9
	mov	dx, overflowStr
	int	21h		;Wypisanie tekstu
	jmp	_errorEnd

_space:
	mov	ah, 2
	mov	dl, 32
	int	21h
	ret

_print:
	mov	ah, 2
	int	21h		;Wypisanie tekstu
	ret

_enter:
	mov	ah, 2
	mov	dl, 10
	int	21h	; new line
	mov	dl, 13
	int	21h	; carriage return
	ret

_end:
	mov	ax, 4C00h	  ;return 0
	int	21h

_errorEnd:
	mov	ax, 4C01h	  ;return 1
	int	21h

invCharStr	db 0dh, 0ah, "Blad: Przekazane przez parametry liczby zawieraja niepoprawne znaki",0Dh,0Ah,"$"
overflowStr	db 0dh, 0ah, "Blad: Nastapilo przepelnienie (liczby 32-b)",0Dh,0Ah,"$"
digitsBuffer:	TIMES 16 db 0	  ;Bufor na cyfry w celu ich wypisania na podstawie liczby
numbersBuffer:	TIMES 64 dd 0	  ;Bufor na liczby
digitsCount	db    0 	  ;Ilosc cyfr w danej liczbie
counter 	db    0 	  ;Ilosc liczb w buforze