format binary
org 100h

start:
	call	loadFileNames	;wczytanie nazw/sciezek plikow
	call	openFiles	;otwarcie plikow
	call	printCopyingStr ;wypisanie tekstu o kopiowaniu pliku
	call	readWrite	;kopiowanie zawartosci pliku
	call	closeFiles	;zamkniecie plikow
	jmp	_end

openFiles:
	xor	ecx, ecx
	call	printAction	;tekst informujacy o otwieraniu pliku
	mov	ax, 716Ch	;kod funkcji otwierajacej plik, extended (long filename)
	mov	si, buffer	;nazwa pliku/sciezka - pierwszy param. programu
	xor	bx, bx		;tryb dostepu, 0 - tylko odczyt
	xor	cx, cx		;tryb zgodnosci - 0
	mov	dx, 1		;otwiera istniejacy plik - 1
	int	21h
	jc	error
	mov	[readFH], ax	;zapisanie uchwytu do pliku

	xor	ecx, ecx
	mov	cl, [offset]	;indeks rozpoczecia nazwy #2 pliku potrzebny do printAction
	call	printAction	;tekst informujacy o otwieraniu pliku
	mov	ax, 716Ch	;funkcja otwierajaca plik, extended (long filename)
	xor	cx, cx		;atrybut, 0 - tryb zgodnosci
	xor	ebx, ebx
	mov	bl, [offset]	;przesuniecie na nazwe #2 pliku w buforze
	lea	si, [buffer + ebx] ;zaladowanie adresu z przesunieciem
	mov	bx, 2		;r/w
	mov	dx, 12h 	;create or truncate
	int	21h
	jc	error
	mov	[writeFH], ax	;zapisanie uchwytu do pliku
	ret

closeFiles:
	call	printClosingStr ;wypisanie tekstu o zamknieciu plikow
	mov	bx, [writeFH]	;wczytanie uchwytu do pliku
	mov	ah, 3eh 	;kod funkcji zamykajacej plik
	int	21h
	jc	error
	mov	bx, [readFH]    ;wczytanie uchwytu do pliku
	int	21h
	jc	error		
	ret

ignoreSpace:	;ignorowanie znakow spacji w parametrach
	inc	si
	cmp	byte[si], 13
	je	done
	cmp	byte[si], 32
	je	ignoreSpace
	ret

chooseLoadName: ;sprawdzenie czy nazwa pliku jest w ""/'' lub '"/"'
	cmp	byte[si], 34
	je	loadNameQuotation
	cmp	byte[si], 39
	je	loadNameQuotation
	jmp	loadNameNoSpaces

loadNameNoSpaces:	;wczytanie nazwy pliku z psp
	cmp	byte[si], 32
	je	done
	cmp	byte[si], 13
	je	done
	mov	al, [si]
	mov	[buffer + ecx], al
	inc	ecx
	inc	si
	jmp	loadNameNoSpaces

loadNameQuotation:	 ;wczytanie nazwy pliku z psp
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
	jmp	loadNameQuotation

loadDone:
	inc	si
	ret

loadFileNames:	;wczytanie nazw obu plikow z psp
	xor	si, si
	mov	si, 80h
	call	ignoreSpace
	cmp	byte[si], 13
	je	wrongArgs
	xor	ecx, ecx
	call	chooseLoadName	;sprawdzenie czy wystepuje "/'
	dec	si
	inc	ecx
	mov	[offset], cl
	call	ignoreSpace
	cmp	byte[si], 13
	je	wrongArgs
	call	chooseLoadName
	dec	si
	call	ignoreSpace
	cmp	byte[si], 13
	jne	wrongArgs
	ret

readWrite:	;kopiowanie zawartosci pliku
	mov	ah, 3Fh        ;kod funkcji odczytujacej zawartosc pliku
	mov	cx, 1024       ;liczba wczytanych bajtow
	mov	dx, dataBuffer ;bufor do ktorego wczytywana bedzie zawartosc
	mov	bx, [readFH]   ;wczytanie uchwytu do pliku
	int	21h
	jc	error
	cmp	ax, 0	       ;0 wczytanych bajtow - eof, koniec
	je	done

	mov	cx, ax	       ;liczba bajtow do zapisania
	mov	ah, 40h        ;kod funkcji zapisujacej do pliku
	mov	bx, [writeFH]  ;wczytanie uchwytu do pliku
	mov	dx, dataBuffer ;bufor z ktorego odbywac sie bedzie pisanie do pliku
	int	21h
	jc	error
	jmp	readWrite      ;petla po 1KB

done:
	ret

wrongArgs:	;niepoprawna liczba argumentow - wypisanie tekstu i zakonczenie
	mov	ah, 9
	mov	dx, wrongArgsStr
	int	21h
	jmp	_endError

error:		;obsluga bledow funkcji na plikach (na podstafie CF - sygn bl i AX - kod bl)
	cmp	ax, 2
	je	error02
	cmp	ax, 3
	je	error03
	cmp	ax, 4
	je	error04
	cmp	ax, 5
	je	error05
	cmp	ax, 6
	je	error06
	cmp	ax, 0ch
	je	error0C
	cmp	ax, 56
	je	error56
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

error04:
	mov	ah, 9
	mov	dx, error04Str
	int	21h
	jmp	_endError

error05:
	mov	ah, 9
	mov	dx, error05Str
	int	21h
	jmp	_endError

error06:
	mov	ah, 9
	mov	dx, error06Str
	int	21h
	jmp	_endError

error0C:
	mov	ah, 9
	mov	dx, error0CStr
	int	21h
	jmp	_endError

error56:
	mov	ah, 9
	mov	dx, error56Str
	int	21h
	jmp	_endError

printAction:	;wypisanie "Opening file: filename"
	mov	ah, 9		;kod funkcji wypisujacej tekst
	mov	dx, openingStr
	int	21h
	call	printFileName	;wypisanie nazwy pliku, kod funkcji pozostaje
	mov	dl, 10
	int	21h
	mov	dl, 13
	int	21h
	ret

printFileName:	;wypisanie nazwy pliku zaladowanej do bufora
	mov	dl, [buffer + ecx]
	cmp	dl, 0		;0 - koniec nazwy
	je	done
	mov	ah, 2
	int	21h
	inc	ecx
	jmp	printFileName

printCopyingStr:	;wypisanie tekstu o kopiowaniu zawartosci pliku
	mov	ah, 9
	mov	dx, copyingStr
	int	21h
	ret

printClosingStr:	;wypisanie tekstu o zamknieciu plikow
	mov	ah, 9
	mov	dx, closingStr
	int	21h
	ret

_end:
	mov	ax, 4C00h
	int	21h

_endError:
	mov	ax, 4C01h
	int	21h

readFH		   dw	   0		;Uchwyt pliku z ktorego nastepuje czytanie
writeFH 	   dw	   0		;Uchwyt pliku do ktorego nastepuje pisanie
buffer: 	   times   129	db 0	;Bufor na nazwy plikow
dataBuffer:	   times   1024 db 0	;Bufor na kopiowanie pliku 1KB
offset		   db	   0		;Przesuniecie w buforze na druga nazwe pliku
errorStr:	   db	   10, 13, "Error: Unknown error", 10, 13, "$"
openingStr:	   db	   "Opening file: $"
copyingStr:	   db	   "Copying from file #1 to #2...", 10, 13, "$"
closingStr:	   db	   "Closing files$"
error02Str:	   db	   10, 13, "Error: File not found", 10, 13, "$"
error03Str:	   db	   10, 13, "Error: Path not found", 10, 13, "$"
error04Str:	   db	   10, 13, "Error: Too many open files (no handles left)", 10, 13, "$"
error05Str:	   db	   10, 13, "Error: Access denied", 10, 13, "$"
error06Str:	   db	   10, 13, "Error: Invalid handler", 10, 13, "$"
error0CStr:	   db	   10, 13, "Error: Invalid access mode (open mode is invalid)", 10, 13, "$"
error56Str:	   db	   10, 13, "Error: Invalid password", 10, 13, "$"
wrongArgsStr:	   db	   10, 13, "Wrong arguments for copying files (1st file to read, 2nd file to write)", 10, 13, "$"