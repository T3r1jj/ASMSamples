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
	mov	dl, [size]
	call	outerSort	; sortowanie (met. babelkowa)
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

; Sortowanie metoda babelkowa
outerSort:	; for(dl = N - 1; dl > 0; dl--)
	dec	dl
	cmp	dl, 0
	je	done
	xor	cl, cl
	jmp	sort

	sort:		; for(cl = 0; cl < dl; cl++)
		cmp	cl, dl
		je	outerSort
		mov	al, [charBuffer + ecx]
		cmp	al, [charBuffer + ecx + 1]
		ja	swap	; if (d[ecx + 1] > d[ecx])
		inc	cl
		jmp	sort

		swap:		; swap(d[ecx], d[ecx + 1]
			push	ax
			mov	al, [charBuffer + ecx + 1]
			mov	[charBuffer + ecx], al
			pop	ax
			mov	[charBuffer + ecx + 1], al
			inc	cl
			jmp	sort

print:
	cmp	[size], cl
	je	done
	mov	ah, 2h
	mov	dl, [charBuffer + ecx]
	inc	ecx
	int	21h	;Wypisanie znaku
	jmp	print

printInv:
	cmp	cl, 0
	je	done
	mov	ah, 2h
	mov	dl, [charBuffer + ecx - 1]
	int	21h	;Wypisanie znaku
	dec	ecx
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