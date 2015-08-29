TITLE Programming Assignment 5 - Designing Low Level I/O & Macros (assignment5-optionA-calhouna)

; Author: Andrew M. Calhoun
; Email: calhouna@onid.oregonstate.edu
; CS271-400 / Assignment 5A
; Due Date: August 2nd, 2015

	; Requirements:

;	Problem Definition:
;		• Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
;		• Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input from
;		the user, and WriteString to display output.
;		o getString should display a prompt, then get the user’s keyboard input into a memory location
;		o displayString should the string stored in a specified memory location.
;		o readVal should invoke the getString macro to get the user’s string of digits. It should then convert the
;		digit string to numeric, while validating the user’s input.
;		o writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to
;		produce the output.
;		• Write a small test program that gets 10 valid integers from the user and stores the numeric values in an
;		array. The program then displays the integers, their sum, and their average.


INCLUDE Irvine32.inc

; CONSTANTS

ARRAYSIZE		EQU		10
EC_LOWLIMIT		EQU		-2147483648
EC_HIGHLIMIT	EQU		2147483647
HIGHLIMIT		EQU		4294967286
LOWLIMIT		EQU		0

; MACROS

;-------------------------------------------------------------------------------
mDisplayString	MACRO	string
; Used to display messages instead of having to type in mov edx, OFFSET and call writeString 
; procedures a number of times.
; Receives: string
; Returns: string output to console
; Registers Used: edx
;---------------------------------------------------------


	push	edx
	mov		edx, OFFSET string
	call	WriteString
	pop		edx	
ENDM

;-------------------------------------------------------------------------------
mGetString	MACRO	var, string
; Used to get number to add to array for calculation.
; Receives: var, string
; Returns: Nothing
; Registers Used: edx, ecx
;---------------------------------------------------------

	push	ecx
	push	edx
	mDisplayString	string
	mov		edx, OFFSET var
	mov		ecx, (SIZEOF var) - 1
	call	ReadString
	pop		edx
	pop		ecx
ENDM

.data

; Arrays and Input Variables

array		DWORD	arraySize DUP(?)
userInput	BYTE	20 DUP(?)
inputLength	DWORD	0
userNum		DWORD	?
counter		DWORD	0
sum			DWORD	0
sbttl		DWORD	?

; Strings and Messages
introP1		BYTE	"I/O Low-Level Programming and Macros - Programmed by Andrew M. Calhoun", 0
introP2		BYTE	"You will be asked to enter 10 numbers. The number of the left hand side of your screen will tell you which one you're on.",0
introEC1	BYTE	"**EC: Numbered Entries for Numbers.", 0
introEC2	BYTE	"**EC: Character Based Entry for 'Go Again' protocol.", 0
introEC3	BYTE	"**EC: Showed Floating Point Average.", 0
goodbyeMSG	BYTE	"Results Verified By Andrew M. Calhoun, have a great day.", 0
instruct	BYTE	". Enter an unsigned number between (0-4,294,967,286): ", 0 
instructEC	BYTE	". Enter a signed number between (−2,147,483,648 to 2,147,483,647): ", 0
errorMsg	BYTE	"That is not a number or you are out of ranage,  please try again: ", 0
numberSum	BYTE	"Your sum is: ", 0
numberAvg	BYTE	"Your average is (rounded down): ", 0
AvgFloat	BYTE	"Your average is: ", 0
comma		BYTE	", ", 0
userNumbers	BYTE	"You entered the following numbers: ", 0
subTotal	BYTE	"Your running subtotal is: ", 0
goAgain		BYTE	"Would you like to play again? (Y/N) >> ", 0
errAgain	BYTE	"Please enter Y or N.", 0

; Extra Credit Stuff 
changeToF		REAL8	0.00		; used to change numbers to floaats
roundFloat1	REAL8	1000.0	; round the float during multiplication, round to int
roundFloat2	REAL8	1000.0	; used to div back into float when rounding
userFloat1	REAL8	?		; float of userNum1
userFloatRem	REAL8	?		; float version of remainder
floatDividend	DWORD	10


.code

main PROC
	
	FINIT			; for EC if time allows

	call introduction
	
	mov		ecx, ARRAYSIZE
	
	contVar:
	push	OFFSET array
	push	counter
	call	readVal
	inc		counter
	loop	contVar

	call	CrLF

	mDisplayString userNumbers
	push	OFFSET array
	push	arraySize
	call	writeVal

	call	CrLF

	push	OFFSET array	; 16
	push	arraySize		; 12
	push	sum				; 8
	call	calculateSum

	push	sum				
	push	arraySize
	call	calculateAvg

	call	CrLf
	call farewell
	exit
main	ENDP

;------------------------------------------------------------------------------------
introduction	PROC
; 
; Receives: array of values, userNumbers message
; Returns: writing out of said array in preperation of the sum and avg functions
; Registers Used: edx via macros mDisplay String
;---------------------------------------------------------

	mDisplayString	introP1
	call	CrLF
	mDisplayString	introP2
	call	CrLf
	mDisplayString	introEC1
	call	CrLf
	mDisplayString	introEC2
	call	CrLf
	mDisplayString	introEC3
	call CrLf
	call CrLf

	ret

introduction	ENDP

;---------------------------------------------------------
readVal			PROC
; Reads input values and adds them to the array
; Receives: array of values, userNumbers message
; Returns: reads values into the array and uses a macro to get n
; Registers Used: ebp, esi, edi, ecx, edx, ebx, eax, al
;---------------------------------------------------------

	pushad
	mov		ebp, esp

	readTop:

	mov		eax, [ebp+36]
	add		eax, 1
	call	WriteDec
	mGetString	userInput, instruct
		
	jmp		validate

	doAgain:
	mGetString	userInput, errorMSG

	validate:
	mov		inputLength, eax
	mov		ecx, eax
	mov		esi, OFFSET userInput
	mov		edi, OFFSET userNumbers

	count:
	lodsb
	
	;isNeg:
	;cmp		al, 45
	;je		truNeg		

	;isPos:		
	cmp		al, 48
	jl		badEntry
	cmp		al, 57
	jg		badEntry
	loop	count
	jmp		goodEntry

	badEntry:
	jmp	doAgain

	goodEntry:
	mov		edx, OFFSET userInput
	mov		ecx, inputLength
	call	ParseDecimal32		; to check and write out the decimal
	.IF		CARRY?				; if it has the carry flag -- EC: Overflow will be needed
	jmp		badEntry
	.ENDIF
	
	mov		edx, [ebp+40]				; move the array into edx
	mov		ebx, [ebp+36]				; move	ebx into the current count
	imul	ebx, 4						; multiply the count by TYPE DWORD to check placement.
	mov		[edx+ebx], eax			

	endRead:
	popad
	ret		8

readVal			ENDP

;---------------------------------------------------------
writeVal		PROC
; 
; Receives: array of values, userNumbers message
; Returns: writing out of said array in preperation of the sum and avg functions
; Registers Used: ebp, edi, ecx, eax
;---------------------------------------------------------
	
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]
	mov		ecx, [ebp+8]

	writeLoop:
	mov		eax, [edi]
	call	WriteDec
	cmp		ecx, 1
	je		noComma
	
	mDisplayString comma
	
	add		edi, 4
	noComma:
	loop	writeLoop

	pop		ebp
	ret		8

writeVal		ENDP

;--------------------------------------------------------
calculateSum PROC
; Calculates the Sum
; Receives: ebp, sum, and the array
; Returns: a calculation of the sum
; Registers Used: ebp, edi, ecx, eax
;---------------------------------------------------------


	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+16]
	mov		ecx, [ebp+12]
	mov		ebx, [ebp+8]

	calcLoop:
	mov		eax, [edi]
	add		ebx, eax
	add		edi, 4



	loop	calcLoop

	mDisplayString	numberSum
	mov		eax,	ebx
	call	WriteDec
	call	CrLf
	mov		sum,	ebx
	

	pop		ebp
	ret		8

calculateSum		ENDP

;---------------------------------------------------------
calculateAvg		PROC
; Calculates the Averge
; Receives: ebp, sum, and the array
; Returns: a calculation of the sum, also gives a float value average due to rounding issues with integers.
; Registers Used: ebp, edi, ecx, eax, esp
;---------------------------------------------------------
	
	push	ebp
	mov		ebp, esp
	mov		eax, [ebp+12]
	mov		ebx, [ebp+8]
	mov		edx, 0


	; converting the average to float
	fld		changeToF
	fiadd	sum
	fstp	userFloat1
	fld		userFloat1
	fidiv	floatDividend
	fstp	userFloatRem

	fld		userFloatRem
	fmul	roundFloat1
	frndint
	fdiv	roundFloat2
	fstp    userFloatRem

	fld		userFloatRem
	mDisplayString	AvgFloat
	call	WriteFloat
	

	call CrLf
	call CrLf

	; assignment parameter answer

	idiv	ebx
	mDisplayString	numberAvg
	call	WriteDec

	call	CrLf
	call	CrLf
	
	mov		sum,    0 ; Clear the Sum for the next run if the user opts for it.
	pop ebp
	ret 8

calculateAvg		ENDP

;---------------------------------------------------------
farewell		PROC
; Says goodbye to the user
; Receives: Nothing
; Returns: Nothing
;---------------------------------------------------------

topAgain:
	mDisplayString goAgain
	call ReadChar
	cmp	al, 89
	je	again
	cmp	al, 121
	je  again
	cmp	al, 78
	je	finished
	cmp	al, 110
	je	finished
	jmp err

err:
	mDisplayString errAgain
	call CrLf
	call CrLf
	jmp topAgain

again:
	call main

finished:
	call	CrLf
	mDisplayString	goodbyeMSG
	call	CrLF
	ret

farewell		ENDP

end main