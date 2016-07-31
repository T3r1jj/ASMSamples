format binary
org 100h

start:
	call	loadParameters
	mov	[filenameCounter], cl
	call	loadSearchParameters
	call	findFirstFile	 ;znalezienie pierwszego pliku
	call	printDTA	 ;wypisanie danych o pliku
	call	listFiles	 ;petla, podobnie do 2 w/w instrukcji
	jmp	_end

findFirstFile:	;znalezienie pierwszego pliku i zapisanie
	mov	ax, 714Eh	;long filename - find first matching file
	xor	cx, cx
	mov	cl, 11111111b	;szukanie pliku o dowolnym typie
	cmp	[attributes], byte 0
	je	findFirstFileb	;standardowo wszystkie atrybuty
	       ; mov	 cl, [attributes]      ;allowable
		mov	ch, [attributes]       ;required
	findFirstFileb:
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
	mov	eax, [dataBuffer]
	test	[pAttributes], byte 64	;parametr -s
	jz	listFilesb     ;rekurencyjne wywolania nowego wyszukiwania
		test	eax, 16
		jz	listFilesb
		cmp	[dataBuffer + 2ch], byte 46	;.
		je	listFilesb
		mov	bx, [filefindHandle]
		push	bx
		xor	ebx, ebx
		mov	bl, [filefindHandleCounter]
		inc	bl
		mov	[filefindHandleCounter], bl
		mov	bl, [filenameCounter]
		mov	ecx, 2ch		 ;nazwa kolejnego katalogu
		call	anotherDirectory
		call	findFirstFile
	listFilesb:
	call	printDTA	;wypisanie DTA
	jmp	listFiles	;petla - zatrzymuje sie przy jc error, ax = 18

anotherDirectory:
	mov	[buffer + ebx - 2], byte 92	    ;/
	dec	ebx
	anotherDirectoryLoop:
	mov	dl, [dataBuffer + ecx]
	inc	ecx
	cmp	ecx, 130h
	je	addAll
	mov	[buffer + ebx], dl
	cmp	dl, 0
	je	addAll
	inc	ebx
	jmp	anotherDirectoryLoop
addAll: ;dodanie \*0
	mov	[buffer + ebx], byte 92   ;\
	mov	[buffer + ebx + 1], byte 42   ;*
	mov	[buffer + ebx + 2], byte 0
	add	bl, 2
	mov	[filenameCounter], bl
	ret

printDTA:	;wypisanie DTA, atrybuty pliku, czas mod., data mod., rozmiar, nazwa

	test	byte[pAttributes], byte 10011111b
	jnz	printParametrizedDTA
		or	[pAttributes], byte 10011111b
	printParametrizedDTA:
	test	[pAttributes], byte 1
	jz	afterPrintAttributes
		call	printAttributes
		call	_tab
	afterPrintAttributes:
	test	[pAttributes], byte 2
	jz	afterPrintTime
		call	printTime
		call	_tab
	afterPrintTime:
	test	[pAttributes], byte 4
	jz	afterPrintDate
		call	printDate
		call	_tab
	afterPrintDate:
	test	[pAttributes], byte 16
	jz	afterPrintFileSize
		call	printFileSize
		call	_tab
	afterPrintFileSize:
	test	[pAttributes], byte 8
	jz	afterPrintFileName
		test	[pAttributes], byte 64
		jz	afterPrintFilePath
			call	printFilePath  ;wypisanie sciezki rekurencyjnej
		afterPrintFilePath:
		call	printFileName
	afterPrintFileName:
	test	[pAttributes], byte 32
	jz	afterPrintWait
		mov	cl, [counter]
		inc	cl
		cmp	cl, 24
		jne	afterPrintWaitElse
			mov	ah, 9
			mov	dx, continueStr ;Press any key to continue . . .
			int	21h
			mov	ah, 0
			int	16h		;wczytanie znaku
			cmp	al, 101
			je	_end
			xor	cl, cl
		afterPrintWaitElse:
		mov	[counter], cl
	afterPrintWait:
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

printFilePath:
	mov	ecx, 0
	jmp	printBufferFilePath

closeFilefindHandle:	;zamkniecie uchwytu otrzymanego z funkcji wyszukujacej pierwszy plik
	mov	ax, 71A1h
	mov	bx, [filefindHandle]
	jc	error
	cmp	[filefindHandleCounter], 0	;jesli pozostaly jeszcze otwarte
	je	done				;uchwyty to wczytaj i przejdz do
	pop	ax				;wyswietlania
	mov	[filefindHandle], ax
	mov	cl, [filefindHandleCounter]
	dec	cl
	mov	[filefindHandleCounter], cl
	call	loadPreviousPath		;powrot do poprzedniej sciezki z
	jmp	listFiles			;wywolania rekurencyhnego

loadPreviousPath:	;wczytuje poprzednia sciezka (powrot do przedostatniego \)
	xor	ebx, ebx
	mov	bl, [filenameCounter]
	sub	ebx, 3
	prevPath:
		cmp	[buffer + ebx], byte 92 ;/
		je	savePrevPath
		dec	ebx
		jmp	prevPath
	savePrevPath:
	inc	ebx
	mov	[buffer + ebx], byte 42 ;*
	inc	ebx
	mov	[buffer + ebx], byte 0
	mov	[filenameCounter], bl
	xor	ecx,ecx
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
	cmp	byte[si], 45
	je	currentDir
	call	chooseLoadParameter  ;sprawdzenie czy wystepuje "/'
	cmp	[buffer + ecx - 1], byte 47
	je	addAllAfterSlash
	cmp	[buffer + ecx - 1], byte 92
	je	addAllAfterSlash
	ret

currentDir:
	mov	[buffer], byte 46	;.
	mov	[buffer + 1], byte 92	;\
	mov	[buffer + 2], byte 42	;*
	add	ecx, 3
	cmp	byte[si], 45
	jne	done
	dec	si
	ret

addAllAfterSlash:;np dir C:\ = dir C:\*
	mov	[buffer + ecx], byte 42 ;*
	mov	[buffer + ecx + 1], byte 0
	inc	ecx
	cmp	byte[si], 13
	ret

loadSearchParameters:
	cmp	[si], byte 13
	je	done
	call	ignoreSpace
	cmp	[si], byte 13
	je	done
	cmp	[si], byte 45		;-
	jne	wrongArgs
	inc	si
	cmp	[si], byte 13
	je	wrongArgs
	cmp	[si], byte 32
	je	wrongArgs
	cmp	[si], byte 97		;znak a
	je	loadAttributes
	cmp	[si], byte 102		;znak f
	je	loadPrintAttributes
	cmp	[si], byte 112		;znak p
	je	loadScrollAttribute
	cmp	[si], byte 115		;znak s
	je	loadRecursiveAttribute
	jmp	wrongDirParameters

loadAttributes:
	inc	si
	cmp	[si], byte 13
	je	done
	cmp	[si], byte 32
	je	loadSearchParameters
	cmp	[si], byte 65		;znak A
	je	addArchiveAttribute
	cmp	[si], byte 68		;znak D
	je	addDirectoryAttribute
	cmp	[si], byte 72		;znak H
	je	addHiddenAttribute
	cmp	[si], byte 82		;znak R
	je	addReadAttribute
	cmp	[si], byte 83		;znak S
	je	addSystemAttribute
	jmp	wrongDirParameters

addReadAttribute:
	or	[attributes], byte 1
	jmp	loadAttributes
addHiddenAttribute:
	or	[attributes], byte 2
	jmp	loadAttributes
addSystemAttribute:
	or	[attributes], byte 4
	jmp	loadAttributes
addDirectoryAttribute:
	or	[attributes], byte 16
	jmp	loadAttributes
addArchiveAttribute:
	or	[attributes], byte 32
	jmp	loadAttributes

loadPrintAttributes:
	inc	si
	cmp	[si], byte 13
	je	done
	cmp	[si], byte 32
	je	loadSearchParameters
	cmp	[si], byte 65		;znak A
	je	addAttributesAttribute
	cmp	[si], byte 67		;znak C
	je	addTimeAttribute
	cmp	[si], byte 68		;znak D
	je	addDateAttribute
	cmp	[si], byte 78		;znak N
	je	addNameAttribute
	cmp	[si], byte 82		;znak R
	je	addSizeAttribute
	jmp	wrongDirParameters

addAttributesAttribute:
	or	byte[pAttributes], 1
	jmp	loadPrintAttributes
addTimeAttribute:
	or	byte[pAttributes], 2
	jmp	loadPrintAttributes
addDateAttribute:
	or	byte[pAttributes], 4
	jmp	loadPrintAttributes
addNameAttribute:
	or	byte[pAttributes], 8
	jmp	loadPrintAttributes
addSizeAttribute:
	or	byte[pAttributes], 16
	jmp	loadPrintAttributes
loadScrollAttribute:
	or	byte[pAttributes], 32
	jmp	loadPrintAttributes
loadRecursiveAttribute:
	or	byte[pAttributes], 64
	jmp	loadPrintAttributes

done:
	ret

wrongArgs:	;niepoprawna liczba argumentow - wypisanie tekstu i zakonczenie
	mov	ah, 9
	mov	dx, wrongArgsStr
	int	21h
	jmp	_endError

wrongDirParameters:	;niepoprawne parametry wyszukiwania/wypisywania
	mov	ah, 9
	mov	dx, wrongDirParametersStr
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

printBufferFilePath:  ;wypisanie nazwy pliku zaladowanej do bufora DTA
	mov	dl, [buffer + ecx]
	inc	ecx
	cmp	ecx, 130h
	je	done
	cmp	dl, 0
	je	done
	cmp	dl, 46		;.
	je	printBufferFilePath
	cmp	dl, 42		;*
	je	printBufferFilePath
	mov	ah, 2
	int	21h
	jmp	printBufferFilePath

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
attributes	   db	   0		;zapisuje atrybuty szukanych plikow
pAttributes	   db	   0		;zapisuje atrybuty wg ktorych wypisywane beda dane plikow
counter 	   db	   1		;licznik do wypisywania pelnego ekranu informacji
filenameCounter    db	   0		;dlugosc nazwy i sciezki pliku do wywolania rekucyjnego
filefindHandleCounter	   db	0	;liczba otwartych uchwytow przeszukiwania
buffer: 	   times   129	db 0	;Bufor na nazwy plikow
dataBuffer:	   times   318	db 0	;Bufor na DTA
digitsBuffer:	   times   16	db 0	;wypisywanie liczby z eax
errorStr:	   db	   10, 13, "Error: Unknown error", 10, 13, "$"
error02Str:	   db	   10, 13, "Error: File not found", 10, 13, "$"
error03Str:	   db	   10, 13, "Error: Path not found", 10, 13, "$"
error18Str:	   db	   10, 13, "Error: No more files to be found", 10, 13, "$"
wrongArgsStr:	   db	   10, 13, "Wrong arguments for listing files [drive:][path][filename] [-a[ADHRS]] [-f[ACDNR]] [-p] [-s]", 10, 13, "$"
wrongDirParametersStr:	    db	    10, 13, "Wrong parameters for listing files [drive:][path][filename] [-a[ADHRS]] [-f[ACDNR]] [-p] [-s]", 10, 13, "$"
error7100Str:	   db	   10, 13, "Error: This function is not supported", 10, 13, "$"
continueStr	   db	   10, 13, "Press any key (e to exit) to continue . . .$"