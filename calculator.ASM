format binary
org 100h

start:
	mov	ah, 9
	mov	dx, startStr
	int	21h		;Wypisanie tekstu
	mov	dx, number1Str
	int	21h		;Wypisanie tekstu

	call	loadNumber	;Wczytuje liczbe do eax
	push	eax

	mov	ah, 9
	mov	dx, number2Str
	int	21h		;Wypisanie tekstu

	call	loadNumber
	mov	ebx, eax
	pop	eax

	call	performOperation;Wykonanie dzialania, wynik w eax
	call	printNumber	;Wypisanie liczby z rej. eax na ekran

	jmp	_end

loadNumber:	;Laduje liczbe wczytywany z klawiatury do rejestru eax
	xor	esi, esi	;Liczba wczytanych cyfr
	call	loadDigitsToBuffer

	mov	[digitsCount], esi
	xor	ebx, ebx	;Z tego rejestru korzysta loadNumberFromBuffer
	xor	esi, esi
	mov	edi, 0ah	;10 - dzielnik/czynnik

	call	loadNumberFromBuffer
	mov	eax, ebx
	jmp	done

loadDigitsToBuffer:	;Wczytuje cyfry z klawiatury i zapisuje do bufora
	mov	ah, 0
	int	16h		;Wczytanie znaku

	mov	dl, al
	mov	ah, 2
	int	21h		;Wypisanie znaku

	cmp	dl, 0dh 	;10 - nowa linia (enter)
	je	checkFirstEnter ;Sprawdzenie czy to pierwszy enter czy
				;jakas cyfra zostala juz wczytana
	cmp	dl, 30h
	jb	invChar 	;<0

	cmp	dl, 39h
	ja	invChar 	;>9

	sub	dl, 30h 	;kod ascii cyfry - '0' = cyfra
	mov	[digitsBuffer + esi], dl  ;Zapisanie do bufora
	inc	esi		;Zwiekszenie licznika bufora
	jmp	loadDigitsToBuffer	;Wczytanie nastepnej cyfry

loadNumberFromBuffer:	     ;wczytuje liczbe z bufora cyfr do rejestru ebx
	xor	eax, eax
	mov	al, [digitsBuffer+esi]	;Wczytanie cyfry z bufora
	mov	ecx, [digitsCount]	;Wczytanie ilosci cyfr
	sub	ecx, esi		;Ile razy cyfra zostanie pomnozona przez 10
	call	multiply		;Mnozenie ecx-1 razy
	add	ebx, eax		;Dodanie wyniku mnozenia do koncowego wyniku
	jc	overflow

	inc	esi			;Zwiekszenie licznika na kolejna cyfre
	cmp	esi, [digitsCount]	;Czy juz wszystkie cyfry?
	jne	loadNumberFromBuffer	;Jesli nie to kolejna iteracja
	jmp	done			;Jesli tak to powrot z wywolania

performOperation:      ;Wczytuje znak dzialania
	push	eax		 ;liczba1
	push	ebx		 ;liczba2
	mov	ah, 9
	mov	dx, operationStr
	int	21h		 ;Wypisanie tekstu

	mov	ah, 0
	int	16h		 ;Wczytanie znaku

	mov	dl, al
	mov	ah, 2
	int	21h		 ;Wypisanie znaku

	push	dx
	mov	ah, 9
	mov	dx, resultStr
	int	21h		 ;Wypisanie tekstu
	pop	dx

	cmp	dl, 2ah 	 ;42(*) - mnozenie
	je	_mul

	cmp	dl, 2bh 	 ;43(+) - dodawanie
	je	_sum

	cmp	dl, 2dh 	 ;45(-) - odejmowanie
	je	_sub

	cmp	dl, 2fh 	 ;47(/) - dzielenie
	je	_div

	jmp	invChar 	 ;Uzytkownik podal zly znak dzialania

_sum:	;Wykonuje dzialanie dodawania 32-bitowego
	pop	ebx
	pop	eax
	add	eax, ebx
	jc	overflow	 ;Jesli nastapilo przeniesienie (CF==1)
	jmp	done

_sub:	;Wykonuje dzialanie odejmowania 32-bitowego (I czesc) odjemna>odjemnik
	pop	ebx
	pop	eax
	cmp	eax, ebx
	jb	_subb
	sub	eax, ebx
	jmp	done

_subb:	;Wykonuje dzialanie odejmowania 32-bitowego (II czesc) odjemna<odjemnik
	sub	ebx,eax 	;Zamiana odjemnej i odjemnika

	mov	dl, 2dh 	;ascii 45(-)
	mov	ah, 2
	int	21h		;Wypisanie znaku

	mov	eax,ebx
	jmp	done

_mul:
	pop	ebx
	pop	eax
	mul	ebx
	jo	overflow	;Jesli OF == 1 to nastapilo przepelnienie
	jmp	done

_div:
	pop	ebx
	pop	eax
	xor	edx, edx	;Zerowanie (reszty z dzielenia)

	cmp	ebx, 0
	je	divideByZero	;Uzytkownik probuje dzielic przez zero

	div	ebx
	mov	[remainder], edx;Zapisanie reszty z dzielenia

	jmp	done

divideByZero:
	mov	ah, 9
	mov	dx, divideByZeroStr
	int	21h		;Wypisanie tekstu
	jmp	_end

checkFirstEnter:	;Sprawdza czy enter podany przez uzytkownika jest
	cmp	esi, 0	;pierwszy czy wystapily przed nim cyfry
	je	loadDigitsToBuffer
	jmp	done

printNumber:
	xor	esi, esi

	call	loadNumberToBuffer	;Zapisanie liczby jako cyfr do bufora
	call	printNumberFromBuffer	;Wypisanie cyfr z bufora jako numeru

	cmp	[remainder], 0
	jne	printRemainder		;Wypisanie ulamka w przypadku dzielenia
	jmp	done

printRemainder:
	mov	dl, 20h 	;32( ) - spacja
	mov	ah, 2
	int	21h		;Wypisanie znaku
	;Wypisanie reszty z dzielenia
	mov	eax,[remainder]
	xor	esi,esi
	call	loadNumberToBuffer
	call	printNumberFromBuffer

	mov	dl, 2fh 	;47(/) - dzielenie
	mov	ah, 2
	int	21h		;Wypisanie znaku
	;Wypisanie dzielnika
	mov	eax,ebx
	xor	esi,esi
	call	loadNumberToBuffer
	call	printNumberFromBuffer
	jmp	done

loadNumberToBuffer:	;Wczytuje cyfry liczby z eax do buforu
	xor	edx,edx 		;Wyczyszczenie poprzedniej reszty z dzielenia
	div	edi			;eax/edi = eax r edx
	mov	[digitsBuffer+esi], dl	;Zapisanie cyfry do bufora

	inc	esi
	cmp	eax, 0			;Sprawdzenie czy cala liczba zostala podzielona
	jne	loadNumberToBuffer	;Jesli nie to kolejna iteracja
	jmp	done			;Jesli tak to powrot z wywolania

printNumberFromBuffer:

	mov	dl, [digitsBuffer+esi-1]
	add	dl, 30h
	mov	ah, 2
	int	21h		;Wypisanie znaku
	dec	esi
	cmp	esi, 0		;Czy wszystkie cyfry zostaly wypisane?
	jne	printNumberFromBuffer
	jmp	done

multiply:
	cmp	ecx, 1		;Pierwsza od lewej cyfre liczby n cyfrowej nalezy pomnozyc n-1 razy
	je	done		;Zakonczenie mnozenia cyfry, powrot z wywolania
	mul	edi		;eax*edi
	jo	overflow
	dec	ecx		;Licznik, ktorego wartosc wskazuje ile razy jeszcze pomnozyc cyfre
	jmp	multiply	;Kolejna iteracja

done:	;Powrot z wywolania (call)
	ret

overflow:	;Nastapilo przepelnienie - wypisanie bledu i zakonczenie programu
	mov	ah, 9
	mov	dx, overflowStr
	int	21h		;Wypisanie tekstu

	jmp	_errorEnd


invChar:	;Uzytkownik wprowadzil niepoprawny znak - wypisanie bledu i zakonczenie programu
	mov	ah, 9
	mov	dx, invCharStr
	int	21h

	jmp	_errorEnd

_errorEnd:

	mov	ah, 0
	int	16h		;Wczytanie znaku

	mov	ax, 4C01h	;return 1
	int	21h

_end:

	mov	ah, 0
	int	16h		;Wczytanie znaku

	mov	ax, 4C00h	;return 0
	int	21h

startStr	db "32b calculator, author: Damian Terlecki.",0Dh, 0Ah,"$"
number1Str	db 0Dh, 0Ah, "Please insert first number", 0Dh, 0Ah, "$"
number2Str	db 0Dh, 0Ah, "Please insert second number", 0Dh, 0Ah, "$"
operationStr	db 0dh, 0ah, "Please insert formula sign: +-*/", 0dh, 0ah, "$"
resultStr	db 0dh, 0ah, "Result = $"
divideByZeroStr db 0dh, 0ah, 0Dh,0Ah,"Error: Division by zero",0Dh,0Ah,"$"
overflowStr	db 0dh, 0ah, 0Dh,0Ah,"Error: Overflow",0Dh,0Ah,"$"
invCharStr	db 0dh, 0ah, 0dh, 0ah, "Error: Invalid sign", 0dh, 0ah, "$"
digitsBuffer:	TIMES 16     db 0
digitsCount	dd 0
remainder	dd 0