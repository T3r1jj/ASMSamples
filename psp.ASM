format binary
org 100h

start:
	mov	ah, 9h
	mov	dx, startStr
	int	21h	;wypisanie tekstu
	call	_enter
	mov	ah, 9h	;wypisanie tekstu
	mov	dx, psp00to01Str
	int	21h

	xor	si, si
	jmp	print1

printChar:		;Wypisanie znaku z [si]
	mov	dl, [si]
	inc	si
	cmp	dl, 0
	je	done
	add	bl, dl
	cmp	dl, 13	;Ignorowany znak powrotu do poczatku linii
	je	done
	cmp	dl, 7	;Ignorowanie dzwieku dzwonka (bell - 07)
	je	done
	mov	ah, 2h
	int	21h
	ret

printCharNumber:	;Wypisanie numeru znaku z [si]
	xor	edx, edx
	mov	dl, [si]
	inc	si
	cmp	dl, 0

	mov	eax, edx
	call	printNumber

	mov	ah, 2h
	mov	dl, 32
	int	21h	;Wypisanie spacji przed nastepnym bajtem
	ret

done:
	ret

tab:
	mov	ah, 2
	mov	dl, 09
	int	21h
	int	21h
	ret

_enter:
	mov	ah, 2
	mov	dl, 10
	int	21h
	mov	dl, 13
	int	21h
	ret

print1: 	;petla wypisuje znaki
	call	printChar
	cmp	si, 01h
	jna	print1

	call	tab
	mov	si, 0h
print1b:	;czesc b - petla wypisuje numery znakow
	call	printCharNumber
	cmp	si, 01h
	jna	print1b

	call	_enter
	mov	ah, 9
	mov	dx, psp02to03Str
	int	21h

print2:
	call	printChar
	cmp	si, 03h
	jna	print2

	call	tab
	mov	si, 2h
print2b:
	call	printCharNumber
	cmp	si, 03h
	jna	print2b

	call	_enter
	mov	 ah, 9
	mov	 dx, psp04Str
	int	 21h

print3:
	call	printChar
	call	tab
	dec	si
print3b:
	call	printCharNumber

	call	_enter
	mov	ah, 9
	mov	dx, psp05to09Str
	int	21h

print4:
	call	printChar
	cmp	si, 09h
	jna	print4

	call	tab
	mov	si, 5h
print4b:
	call	printCharNumber
	cmp	si, 09h
	jna	print4b

	call	_enter
	mov	ah, 9
	mov	dx, psp0Ato0DStr
	int	21h

print5:
	call	printChar
	cmp	si, 0Dh
	jna	print5

	call	tab
	mov	si, 0Ah
print5b:
	call	printCharNumber
	cmp	si, 0Dh
	jna	print5b

	call	_enter
	mov	ah, 9
	mov	dx, psp0Eto11Str
	int	21h

print6:
	call	printChar
	cmp	si, 11h
	jna	print6

	call	tab
	mov	si, 0Eh

print6b:
	call printCharNumber
	cmp	si, 11h
	jna	print6b

	call	_enter
	mov	ah, 9
	mov	dx, psp12to15Str
	int	21h

print7:
	call	printChar
	cmp	si, 15h
	jna	print7

	call	tab
	mov	si, 12h
print7b:
	call	printCharNumber
	cmp	si, 15h
	jna	print7b

	call	_enter
	mov	ah, 9
	mov	dx, psp16to17Str
	int	21h

print8:
	call	printChar
	cmp	si, 17h
	jna	print8

	call	tab
	mov	si, 16h
print8b:
	call	printCharNumber
	cmp	si, 17h
	jna	print8b

	call	_enter
	mov	ah, 9
	mov	dx, psp18to2BStr
	int	21h

print9:
	call	printChar
	cmp	si, 2Bh
	jna	print9
	mov	si, 18h
print9b:
	call	printCharNumber
	cmp	si, 2bh
	jna	print9b

	call	_enter
	mov	ah, 9
	mov	dx, psp2Cto2DStr
	int	21h

print10:
	call	printChar
	cmp	si, 2Dh
	jna	print10

	call	tab
	mov	si, 2ch
print10b:
	call	printCharNumber
	cmp	si, 2dh
	jna	print10b

	call	_enter
	mov	ah, 9
	mov	dx, psp2Eto31Str
	int	21h

print11:
	call	printChar
	cmp	si, 31h
	jna	print11

	call	tab
	mov	si, 2eh
print11b:
	call	printCharNumber
	cmp	si, 31h
	jna	print11b

	call	_enter
	mov	ah, 9
	mov	dx, psp32to33Str
	int	21h
print12:
	call	printChar
	cmp	si, 33h
	jna	print12

	call	tab
	mov	si, 32h
print12b:
	call	printCharNumber
	cmp	si, 33h
	jna	print12b

	call	_enter
	mov	ah, 9
	mov	dx, psp34to37Str
	int	21h
print13:
	call	printChar
	cmp	si, 37h
	jna	print13

	call	tab
	mov	si, 34h
print13b:
	call	printCharNumber
	cmp	si, 37h
	jna	print13b

	call	_enter
	mov	ah, 9
	mov	dx, psp38to3BStr
	int	21h

print14:
	call	printChar
	cmp	si, 3Bh
	jna	print14

	call	tab
	mov	si, 38h
print14b:
	call	printCharNumber
	cmp	si, 3bh
	jna	print14b

	call	_enter
	mov	ah, 9
	mov	dx, psp3Cto3FStr
	int	21h

print15:
	call	printChar
	cmp	si, 3Fh
	jna	print15

	call	tab
	mov	si, 3ch
print15b:
	call	printCharNumber
	cmp	si, 3fh
	jna	print15b

	call	_enter
	mov	ah, 9
	mov	dx, psp40to41Str
	int	21h

print16:
	call	printChar
	cmp	si, 41h
	jna	print16

	call	tab
	mov	si, 40h
print16b:
	call	printCharNumber
	cmp	si, 41h
	jna	print16b

	call	_enter
	mov	ah, 9
	mov	dx, psp42to4FStr
	int	21h

print17:
	call	printChar
	cmp	si, 4Fh
	jna	print17

	call	tab
	mov	si, 42h
print17b:
	call	printCharNumber
	cmp	si, 4fh
	jna	print17b

	call	_enter
	mov	ah, 9
	mov	dx, psp50to52Str
	int	21h

print18:
	call	printChar
	cmp	si, 52h
	jna	print18

	call	tab
	mov	si, 50h
print18b:
	call	printCharNumber
	cmp	si, 52h
	jna	print18b

	call	_enter
	mov	ah, 9
	mov	dx, psp53to54Str
	int	21h

print19:
	call	printChar
	cmp	si, 54h
	jna	print19

	call	tab
	mov	si, 53h
print19b:
	call	printCharNumber
	cmp	si, 54h
	jna	print19b

	call	_enter
	mov	ah, 9
	mov	dx, psp55to5BStr
	int	21h

print20:
	call	printChar
	cmp	si, 5Bh
	jna	print20

	call	tab
	mov	si, 55h
print20b:
	call	printCharNumber
	cmp	si, 5Bh
	jna	print20b

	call	_enter
	mov	ah, 9
	mov	dx, psp5Cto6BStr
	int	21h

print21:
	call	printChar
	cmp	si, 6Bh
	jna	print21

	call	tab
	mov	si, 5ch
print21b:
	call	printCharNumber
	cmp	si, 6bh
	jna	print21b

	call	_enter
	mov	ah, 9
	mov	dx, psp6Cto7FStr
	int	21h

print22:
	call	printChar
	cmp	si, 7Fh
	jna	print22

	call	tab
	mov	si, 6ch
print22b:
	call	printCharNumber
	cmp	si, 7fh
	jna	print22b

	call	_enter
	mov	ah, 9
	mov	dx, psp80Str
	int	21h

print23:
	call	printChar

	call	tab
	dec	si
print23b:
	call	printCharNumber

	mov	ah, 9
	mov	dx, psp81toFFStr
	int	21h
	mov	dx, cmdTextStr
	int	21h

print24:
	call	printChar
	cmp	si, 0FFh
	jna	print24

	mov	si, 81h
	mov	ah, 9
	mov	dx, cmdNumberStr
	int	21h

print24b:
	call	printCharNumber
	cmp	si, 0FFh
	jna	print24b

	call	_enter
	call	_enter
	mov	ah, 9
	mov	dx, pspEnvStr
	int	21h
	call	_enter

	mov	ds, [ds:2ch]	; Ustawienie adresu segmentu ENV
	xor	si, si		; Wyzerowanie offsetu
	jmp	printEnv

checkDouble0:
	cmp	byte [si + 1], 0
	je	_end
	call	_enter

printEnv:
	inc	si
	cmp	si, 8000h	; 32KB max - koniec w przybadku wyst. 00
	ja	_end

	mov	dl, [si]
	cmp	dl, 0
	je	checkDouble0	; sprawdzenie czy koniec seg env

	mov	ah, 2h
	int	21h		; wypisanie znaku
	jmp	printEnv

_end:
	call	_enter
	mov	ah, 0
	int	16h

	mov	ax, 4C00h
	int	21h

printNumber:
	xor	ecx, ecx
	mov	edi, 0ah

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

printNumberFromBuffer:	;Wypisuje cyfry z bufora na ekran

	mov	dl, [digitsBuffer+ecx-1]
	add	dl, 30h
	mov	ah, 2
	int	21h		;Wypisanie znaku
	dec	ecx
	cmp	ecx, 0		;Czy wszystkie cyfry zostaly wypisane?
	jne	printNumberFromBuffer
	jmp	done

startStr	db	"Author: Damian Terlecki, PSP+env print:", 10, 13, 10, 13, "PSP", 09, 09, 09, "Start", 09, "Size [B]", 09, "Data string", 09, "Data number", 10, 13, "$"
psp00to01Str	db	"CP/M exit", 09, 09, "00h", 09, "2", 09, 09, "$"
psp02to03Str	db	10, 13, "Program ending adr", 09, "02h", 09, "2", 09, 09, "$"
psp04Str	db	10, 13, "Reserved", 09, 09, "04h", 09, "1", 09, 09, "$"
psp05to09Str	db	10, 13, "DOS func dispatcher", 09, "05h", 09, "5", 09, 09, "$"
psp0Ato0DStr	db	10, 13, "Old INT 22h", 09, 09, "0Ah", 09, "4", 09, 09, "$"
psp0Eto11Str	db	10, 13, "Old INT 23h", 09, 09, "0Eh", 09, "4", 09, 09, "$"
psp12to15Str	db	10, 13, "Old INT 24h", 09, 09, "12h", 09, "4", 09, 09, "$"
psp16to17Str	db	10, 13, "Caller's PSP segm", 09, "16h", 09, "2", 09, 09, "$"
psp18to2BStr	db	10, 13, "Job File Table", 09, 09, "18h", 09, "20", 09, 09, "$"
psp2Cto2DStr	db	10, 13, "Environment segm", 09, "2Ch", 09, "2", 09, 09, "$"
psp2Eto31Str	db	10, 13, "SS:SP en-last INT 21h", 09, "2Eh", 09, "4", 09, 09, "$"
psp32to33Str	db	10, 13, "JFT size", 09, 09, "32h", 09, "2", 09, 09, "$"
psp34to37Str	db	10, 13, "Pointer to JFT", 09, 09, "34h", 09, "4", 09, 09, "$"
psp38to3BStr	db	10, 13, "Pointer to prev PSP", 09, "38h", 09, "4", 09, 09, "$"
psp3Cto3FStr	db	10, 13, "Reserved", 09, 09, "3Ch", 09, "4", 09, 09, "$"
psp40to41Str	db	10, 13, "DOS version to return", 09, "40h", 09, "2", 09, 09, "$"
psp42to4FStr	db	10, 13, "Reserved", 09, 09, "42h", 09, "14", 09, 09, "$"
psp50to52Str	db	10, 13, "Far call to DOS", 09, 09, "50h", 09, "3", 09, 09, "$"
psp53to54Str	db	10, 13, "Reserved", 09, 09, "53h", 09, "2", 09, 09, "$"
psp55to5BStr	db	10, 13, "Reserved", 09, 09, "55h", 09, "7", 09, 09, "$"
psp5Cto6BStr	db	10, 13, "Unopened Default FCB 1", 09, "5Ch", 09, "16", 09, 09, "$"
psp6Cto7FStr	db	10, 13, "Unopened Default FCB 2", 09, "6Ch", 09, "20", 09, 09, "$"
psp80Str	db	10, 13, "Number of B on cmd-line", 09, "80h", 09, "1", 09, 09, "$"
psp81toFFStr	db	10, 13, 10, 13, "Command-line", 09, 09, "81h", 09, "127", 09, 09, "$"
cmdTextStr	db	10, 13, "CMD data string: $"
cmdNumberStr	db	10, 13, "CMD data numbers: $"
pspEnvStr	db	10, 13, "Environment variables: $"
digitsBuffer:	TIMES	16     db 0