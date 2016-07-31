format binary
org 100h


start:
	mov	si, 80h
	mov	al, [si]

	cmp	al, 0	; brak parametrow (ciagu do posortowania)
	je	_end

	inc	si	; pominiecie pierwszego, standardowego znaku spacji
	dec	al
	mov	[size], al	; zapisanie liczby znakow

	xor	edx, edx
	xor	ecx, ecx
	call	loadToBuffer	; zaladowanie ciagu do bufora

	mov	[size], dl
	xor	ax, ax		; czyszczenie przed wrzuceniem na stos al (ax)
	call	outerSort	; sortowanie przez wybor
	; wypisanie ciagu posortowanego rosnaca a nastepnie malejaco
	xor	cl, cl
	call	print
	call	_enter
	call	printInv

	jmp	_end

loadToBuffer:	;Laduje znaki przekazane przez parametry (z PSP)
	inc	si
	mov	al, [si]
	mov	[charBuffer + edx], al
	inc	cl
	cmp	al, 32
	jb	ignore	;Ignorowanie znakow systemowych/bialych
	inc	dl
	cmp	[size], cl
	je	done
	jmp	loadToBuffer

ignore: 	;Ignorowanie znakow systemowych/bialych oprocz spacji (<32)
	cmp	[size], cl
	je	done
	jmp	loadToBuffer

; Sortowanie przez wybor - od konca wybor najwiekszego elementu
outerSort:   ; for (dl = N; dl > 1; dl--)
	cmp	dl, 1
	jna	done
	dec	dl
	mov	cl, dl
	dec	cl

	sort:	; for (cl = dl - 1; dl >= 0; dl--)
		mov	al, [charBuffer + edx]
		cmp	al, [charBuffer + ecx]
		jb	swap		; if (cB[edx] < cB[ecx])
		cmp	cl, 0
		je	outerSort
		dec	cl
		jmp	sort

		swap:	; swap(cB[edx], cB[ecx])
			push	ax
			mov	al, [charBuffer + ecx]
			mov	[charBuffer + edx], al
			pop	ax
			mov	[charBuffer + ecx], al
			cmp	cl, 0
			je	outerSort
			dec	cl
			jmp	sort

print:	;Wypisuje znaki z bufora
	cmp	[size], cl
	je	done
	mov	ah, 2h
	mov	dl, [charBuffer + ecx]
	inc	cl
	int	21h	;Wypisanie znaku
	jmp	print

printInv:	;Wypisuje znaki w kolejnosci odwrotnej
	cmp	cl, 0
	je	done
	mov	ah, 2h
	mov	dl, [charBuffer + ecx - 1]
	int	21h	;Wypisanie znaku
	dec	cl
	jmp	printInv

done:
	ret

_enter:
	mov	ah, 2
	mov	dl, 10
	int	21h	; new line
	mov	dl, 13
	int	21h	; carriage return
	ret

_end:
	mov	ax, 4C00h
	int	21h


charBuffer: TIMES 127 db 0	;Bufor na znaki przekazane przez linie polecen
size	db    0 		;Liczba bajtow linii komend