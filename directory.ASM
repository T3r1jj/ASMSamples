format binary
org 100h

start:
	call	loadParameters	 ;wczytanie sciezki plikow
	call	findFirstFile	 ;znalezienie pierwszego pliku
	call	printDTA	 ;wypisanie danych o pliku
	call	listFiles	 ;petla, podobnie do 2 w/w instrukcji
	jmp	_end

findFirstFile:	;znalezienie pierwszego pliku i zapisanie
	mov	ax, 714Eh	;long filename - find first matching file
	xor	cx, cx
	mov	cl, 11111111b	;szukanie pliku o dowolnym typie
	mov	si, 01h 	;32b date/time format
	mov	di, dataBuffer	;wskaznik na bufor DTA
	mov	dx, buffer	;sciezka wyszukiwania
	int	21h
	jc	error
	mov	[filefindHandle], ax	;zapisanie uchwytu
	ret

listFiles:
	mov	ax, 714Fh	;long filename - find next matching file
	mov	bx, [filefindHandle]	;wczytanie uchwytu
	mov	si, 1		;32b date/time format
	mov	di, dataBuffer	;wskaznik na bufor DTA
	int	21h
	jc	error
	call	printDTA	;wypisanie DTA
	jmp	listFiles	;petla - zatrzymuje sie przy jc error, ax = 18

printDTA:	;wypisanie DTA, atrybuty pliku, czas mod., data mod., rozmiar, nazwa
	call	printAttributes
	call	_tab
	call	printTime
	call	_tab
	call	printDate
	call	_tab
	call	printFileSize
	call	_tab
	call	printFileName
	call	_enter
	ret

printAttributes:	;wypisuje atrybuty: N-normal file, R-read only, H-hidden.
			;S-system, D-directory, A-Archive, T-temporary
	cmp	[dataBuffer], word 0
	jne	afterNormal
		mov	ah, 2h
		mov	dl, 78
		int	21h
	afterNormal:
	test	[dataBuffer], word 1
	jz	afterRead
		mov	ah, 2h
		mov	dl, 82
		int	21h
	afterRead:
	test	[dataBuffer], word 2
	jz	afterHidden
		mov	ah, 2h
		mov	dl, 72
		int	21h
	afterHidden:
	test	[dataBuffer], word 4
	jz	afterSystem
		mov	ah, 2h
		mov	dl, 83
		int	21h
	afterSystem:
	test	[dataBuffer], word 16
	jz	afterDirectory
		mov	ah, 2h
		mov	dl, 68
		int	21h
	afterDirectory:
	test	[dataBuffer], word 32
	jz	afterArchive
		mov	ah, 2h
		mov	dl, 65
		int	21h
	afterArchive:
	test	[dataBuffer], word 256
	jz	done
		mov	ah, 2h
		mov	dl, 84
		int	21h
	ret

printTime:	;wypisanie czasu ostatniej modyfikacji hh:mm
	xor	eax, eax
	mov	si, 96h
	mov	ax, [dataBuffer + 20]
	push	ax
	shr	ax, 11
	cmp	ax, 9
	ja	printTimeb

	push	ax
	mov	ah, 2h
	mov	dl, 48
	int	21h
	pop	ax
	printTimeb:
	call	printNumber
	mov	ah, 2h
	mov	dl, 58
	int	21h
	pop	ax
	shl	ax, 5
	shr	ax, 10
	cmp	ax, 9
	ja	printTimec

	push	ax
	mov	ah, 2h
	mov	dl, 48
	int	21h
	pop	ax
	printTimec:
	call	printNumber
	ret

printDate:	;wypisanie daty modyfikacji dd/mm/yyyy
	xor	eax, eax
	mov	ax, [dataBuffer + 22]
	shr	ax, 9
	push	ax
	mov	ax, [dataBuffer + 22]
	shl	ax, 7
	shr	ax, 12
	push	ax
	mov	ax, [dataBuffer + 22]
	shl	ax, 11
	shr	ax, 11
	cmp	ax, 9
	ja	printDateb

	push	ax
	mov	ah, 2h
	mov	dl, 48
	int	21h
	pop	ax
	printDateb:
	call	printNumber
	mov	ah, 2h
	mov	dl, 47
	int	21h
	pop	ax
	cmp	ax, 9
	ja	printDatec

	push	ax
	mov	ah, 2h
	mov	dl, 48
	int	21h
	pop	ax
	printDatec:
	call	printNumber
	mov	ah, 2h
	mov	dl, 47
	int	21h
	pop	ax
	add	ax, 1980
	call	printNumber
	ret

printFileSize:	;wypisanie rozmiaru pliku w bajtach
	mov	eax, [dataBuffer + 32]
	push	eax
	call	printNumber
	pop	eax
	cmp	eax, 10000000
	jb	_tab
	ret

printFileName:	;wypiasnie nazwy pliku (long filename)
	mov	ecx, 2Ch
	jmp	printBufferFileName

closeFilefindHandle:	;zamkniecie uchwytu otrzymanego z funkcji wyszukujacej pierwszy plik
	mov	ax, 71A1h
	mov	bx, [filefindHandle]
	jc	error
	ret

ignoreSpace:	;ignorowanie znakow spacji w parametrach PSP
	inc	si
	cmp	byte[si], 13
	je	done
	cmp	byte[si], 32
	je	ignoreSpace
	ret

chooseLoadParameter:	     ;sprawdzenie czy nazwa pliku jest w ""/'' lub '"/"'
	cmp	byte[si], 34
	je	loadParameterQuotation
	cmp	byte[si], 39
	je	loadParameterQuotation
	jmp	loadParameterNoSpaces

loadParameterNoSpaces:	     ;wczytanie sciezki z PSP
	cmp	byte[si], 32
	je	done
	cmp	byte[si], 13
	je	done
	mov	al, [si]
	mov	[buffer + ecx], al
	inc	ecx
	inc	si
	jmp	loadParameterNoSpaces

loadParameterQuotation:       ;wczytanie sciezki z ""/'', "'/'"
	inc	si
	cmp	byte[si], 34
	je	loadDone
	cmp	byte[si], 39
	je	loadDone
	cmp	byte[si], 13
	je	wrongArgs
	mov	al, [si]
	mov	[buffer + ecx], al
	inc	ecx
	jmp	loadParameterQuotation

loadDone:
	inc	si
	ret

loadParameters:  ;wczytanie nazw obu plikow z psp
	xor	si, si
	mov	si, 80h
	call	ignoreSpace
	xor	ecx, ecx
	cmp	byte[si], 13
	je	currentDir
	call	chooseLoadParameter  ;sprawdzenie czy wystepuje "/'
	cmp	[buffer + ecx - 1], byte 47
	je	addAllAfterSlash
	cmp	[buffer + ecx - 1], byte 92
	je	addAllAfterSlash
	cmp	byte[si], 13
	je	done
	cmp	byte[si], 32
	jne	wrongArgs
	call	ignoreSpace
	cmp	byte[si], 13
	jne	wrongArgs
	ret

currentDir:
	mov	[buffer + ecx], byte 46
	mov	[buffer + ecx + 1], byte 92
	mov	[buffer + ecx + 2], byte 42
	ret

addAllAfterSlash:;np dir C:\ = dir C:\*
	mov	[buffer + ecx], byte 42      ;*
	cmp	byte[si], 13
	je	done
	cmp	byte[si], 32
	jne	wrongArgs
	call	ignoreSpace
	cmp	byte[si], 13
	jne	wrongArgs
	ret

done:
	ret

wrongArgs:	;niepoprawna liczba argumentow - wypisanie tekstu i zakonczenie
	mov	ah, 9
	mov	dx, wrongArgsStr
	int	21h
	jmp	_endError

error:		;obsluga bledow funkcji wyszukujacych pliki (na podstafie CF - sygn bl i AX - kod bl)
	cmp	ax, 2
	je	error02
	cmp	ax, 3
	je	error03
	cmp	ax, 18	;znaleziono juz wszystkie pliki
	je	closeFilefindHandle
	cmp	ax, 7100h
	je	error7100
	mov	ah, 9
	mov	dx, errorStr
	int	21h
	jmp	_endError

error02:
	mov	ah, 9
	mov	dx, error02Str
	int	21h
	jmp	_endError

error03:
	mov	ah, 9
	mov	dx, error03Str
	int	21h
	jmp	_endError

error7100:
	mov	ah, 9
	mov	dx, error7100Str
	int	21h
	jmp	_endError

printBufferFileName:  ;wypisanie nazwy pliku zaladowanej do bufora DTA
	mov	dl, [dataBuffer + ecx]
	inc	ecx
	cmp	ecx, 130h
	je	done
	cmp	dl, 0
	je	done
	mov	ah, 2
	int	21h
	jmp	printBufferFileName

_tab:
	mov	dl, 9
	mov	ah, 2h
	int	21h
	ret

_enter:
	mov	dl, 10
	mov	ah, 2h
	int	21h
	mov	dl, 13
	int	21h
	ret

_end:
	mov	ax, 4C00h
	int	21h

_endError:
	mov	ax, 4C01h
	int	21h


printNumber:
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


filefindHandle	   dw	   0		;uchwyt z rozszerzonej funkcji szukania plikow
buffer: 	   times   129	db 0	;Bufor na nazwy plikow
dataBuffer:	   times   318	db 0	;Bufor na DTA
digitsBuffer:	   times   16	db 0	;wypisywanie liczby z eax
errorStr:	   db	   10, 13, "Error: Unknown error", 10, 13, "$"
error02Str:	   db	   10, 13, "Error: File not found", 10, 13, "$"
error03Str:	   db	   10, 13, "Error: Path not found", 10, 13, "$"
error18Str:	   db	   10, 13, "Error: No more files to be found", 10, 13, "$"
wrongArgsStr:	   db	   10, 13, "Wrong arguments for listing files (1st - path to file/directory)", 10, 13, "$"
error7100Str:	   db	   10, 13, "Error: This function is not supported", 10, 13, "$"