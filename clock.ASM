format binary
org 100h

start:
	mov	ah, 9		;wypisanie tekstu
	mov	dx, press_e_Str ;Press e to exit
	int	21h		;DOS call 21h
	mov	bh, 61		;bh jest porownywane z liczba sekund otrzymanych
	call	printLoop	;jesli liczby sie rozna to nastepuje wypisanie
	jmp	_end

printLoop:	;petla glowna - sprawdza czy koniec programu/wypisuje zegar
	call	checkForKeystroke ;sprawdzenie czy uzytkownik nacisnal klawisz
	call	getSystemTime
	cmp	bh, dh		  ;jesli pobrana liczba sekund rozni sie od
	je	printLoop	  ;poprzedniej - wypisanie, w przeciwnym wypadku ponowne wywolanie
	mov	ah, 2h		  ;wypisanie znaku
	mov	dl, 13		  ;carriage return - nadpisanie nowym czasem
	int	21h		  ;DOS call 21h
	call	printSystemTime   ;wypisanie zegaru HH:MM:SS
	jmp	printLoop

checkForKeystroke:	;sprawdzenie czy uzytkownik nacisnal klawisz
	mov	ah, 01h ;CHECK FOR KEYSTROKE
	int	16h	;BIOS int 16h
	jz	done	;zf = 1 jesli brak wcisnietego klawisza
	mov	ah, 00h ;GET KEYSTROKE
	int	16h	;BIOS int 16h
	cmp	al, 101 ;sprawdzenie czy wcisniety klawisz to e
	je	_end	;jesli tak to zakonczenie programu
	ret

getSystemTime:
	mov	ah, 2ch ;GET SYSTEM TIME
	int	21h	;DOS int 21h
	ret

printSystemTime:	;wypisuje zegar na ekranie w formie HH:MM:SS
	mov	bh, dh	;liczby jednocyfrowe dopelniane sa zerami

	cmp	ch, 9	;sprawdzenie czy liczba jednocyfrowa
	ja	beforeHours	;tak - przejscie dalej, nie - dopelnienie 0
		mov	ah, 2h	;wypisanie znaku
		mov	dl, 48	;0
		int	21h
	beforeHours:
	xor	eax, eax
	mov	al, ch		;godzina
	call	printNumber
	mov	ah, 2h		;wypisanie znaku
	mov	dl, 58		;:
	int	21h

	cmp	cl, 9
	ja	beforeMinutes
		mov	ah, 2h
		mov	dl, 48	;0
		int	21h
	beforeMinutes:
	xor	eax, eax
	mov	al, cl		;minuty
	call	printNumber
	mov	ah, 2h		;wypisanie znaku
	mov	dl, 58		;:
	int	21h

	cmp	bh, 9
	ja	beforeSeconds
		mov	ah, 2h	;wypisanie znaku
		mov	dl, 48	;0
		int	21h
	beforeSeconds:
	xor	eax, eax
	mov	al, bh		;sekundy
	call	printNumber

	ret

printNumber:	;wypisuje liczbe 32b z rejestru eax na ekran
	xor	esi, esi
	mov	edi, 10 		;dzielnik 10
	call	loadNumberToBuffer	;Zapisanie liczby jako cyfr do bufora
	call	printNumberFromBuffer	;Wypisanie cyfr z bufora jako numeru
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

done:
	ret

_end:
	mov	ax, 4C00h
	int	21h

digitsBuffer:	   times   16	db 0	;wypisywanie liczby z eax
press_e_Str db "Program - Clock, Author - Damian Terlecki, <press e to exit>", 10, 13, "$"