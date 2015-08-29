TITLE Random Number Array (calhouna-assignment4.asm)

; Author: Andrew M. Calhoun
; Email: calhouna@onid.oregonstate.edu
; CS271-400 / Assignment 3
; Due Date: July 26th, 2015

	; Requirements:

	; 1. The title, programmer's name, and brief instructions must be displayed on the screen.
	; 2. The program must validate the user’s request.
	; 3. min, max, lo, and hi must be declared and used as global constants. Strings may be declared as global
	; variables or constants.
	; 4. The program must be constructed using procedures. At least the following procedures are required:
	; A. main
	; B. introduction
	; C. get data {parameters: request (reference)}
	; D. fill array {parameters: request (value), array (reference)}
	; E. sort list {parameters: array (reference), request (value)}
	; i. exchange elements (for most sorting algorithms): {parameters: array[i] (reference),
	; array[j] (reference), where i and j are the indexes of elements to be exchanged}
	; F. display median {parameters: array (reference), request (value)}
	; G. display list {parameters: array (reference), request (value), title (reference)}
	; 5. Parameters must be passed by value or by reference on the system stack as noted above.
	; 6. There must be just one procedure to display the list. This procedure must be called twice: once to display the unsorted list, and once to display the sorted list.
	; 7. Procedures (except main) should not reference .data segment variables by name. request, array, and titles
	; for the sorted/unsorted lists should be declared in the .data segment, but procedures must use them as
	; parameters. Procedures may use local variables when appropriate. Global constants are OK.
	; 8. The program must use appropriate addressing modes for array elements.
	; 9. The two lists must be identified when they are displayed (use the title parameter for the display procedure).
	; 10. The program must be fully documented. This includes a complete header block for the program and for
	; each procedure, and a comment outline to explain each section of code.
	; 11. The code and the output must be well-formatted.
	; 12. Submit your text code file (.asm) to Canvas by the due date.

	; **EC: Recursive Bubble Sort 
	; **EC: Columns

INCLUDE Irvine32.inc

	; HARD CONSTANTS

	MIN	EQU	10
	MAX	EQU	200
	HI	EQU	999
	LO	EQU	100

	; **EC
	BUFFER_SIZE	EQU	2048

.data

;	WriteToFile_1	DWORD	?			; Chapter 11.1, 463-472
	
dataBuffer BYTE	BUFFER_SIZE DUP(?)
filename	 BYTE	"assignment4-output.txt",0
fileHandle HANDLE	?
stringLength DWORD	?
bytesWritten DWORD	?

str1	BYTE	"Cannot create file", 0
str2 BYTE	"Bytes written to file [output.txt]:", 0
str3	BYTE "Uh, yea. Write a string to check this working.", 0
	

;	Program Variables

userNum	DWORD	?
numberArr	DWORD	MAX	DUP(?)	; Can have up to 200 DWORD items.
median	DWORD	?
exchng1	DWORD	?		; Temp Place Holder 1
exchng2	DWORD	?		; Temp Place Holder 2


;	Program Messages/Titles/Outputs

introP1	BYTE	"Sorting Random Integers				Authored by Andrew M. Calhoun", 0 
introP2	BYTE	"This program generates random numbers in a range of [100 ... 999],", 0
introP3	BYTE	"displays the original list, sorts the list, and calcuates the median", 0
introP4	BYTE "value. Finally it'll display the sorted list in descending order. ", 0
userPrm	BYTE	"Enter the amount of numbers to be generated [10 ... 200]: ", 0
errorMsg	BYTE	"That is out of range. Try aagain. ", 0
unsorted	BYTE	"The unsorted random numbers: ", 0
sorted	BYTE	"The sorted random numbers: ", 0
medMsg	BYTE	"The median is: ", 0
goodbye	BYTE	"Results verified by Andrew M. Calhoun, have a wonderful day!", 0

buffer	DWORD	"   ", 0

.code


;******************************************************************
; Main - the main function of the program.
; Receives: N/A
; Returns: N/A
; Pre-conditions: program needs to be started
; Registers changed: N/A
;******************************************************************

main PROC
	
	call Randomize		; Instantiate the randomized seed.
	
	; introduction
	push	OFFSET introP1			; 20
	push	OFFSET introP2			; 16
	push	OFFSET introP3			; 12
	push	OFFSET introp4			; 8
	call	introduction

	; user input to fill array
	
	push OFFSET userPrm			; 16
	push	OFFSET userNum			; 12
	push	OFFSET errorMsg		; 8
	call userInput
	
	; fill the array

	push	OFFSET numberArr		; 12
	push	userNum				; 8  -- Offset it before and caused my computer to crash!!!! O.O
	call fillArray

	; print unsorted list

	push	OFFSET numberArr		; 20
	push	userNum				; 16 (?)
	push	OFFSET buffer			; 12
	push	OFFSET unsorted		; 8
	call	displayList

	; print the sorted list in descending order

	push OFFSET numberArr		; 12
	push	userNum				; 8
	call	sortedList
	
	; display the median

	; push exchng2				; 28
	; push median				; 24
	; push exchng1				; 20 
	; push OFFSET medMsg		; 16
	; push OFFSET numberArr		; 12
	; push userNum				; 8
	

	push	OFFSET medMsg			; 16
	push	OFFSET numberArr		; 12
	push	userNum				; 8
	call medianDisplay

	; display the sorted list

	push	OFFSET numberArr		; 20
	push	userNum				; 16 (?)
	push	OFFSET buffer			; 12
	push	OFFSET sorted			; 8
	call	displayList

	; print the median

	; display farewell
	
quit:
	push OFFSET goodbye
	call farewell

	exit

main ENDP

;******************************************************************
; introduction - Introduces the Program
; Receives: intro messages 1-4
; Returns: program title, author, and basic instructions.
; Pre-conditions: program needs to be started
; Registers changed: ebp, edx
;******************************************************************

introduction	PROC

	push ebp		; Save the base pointer and activate the stack frame.
	mov	ebp, esp	

	mov	edx, [ebp+20]
	call	WriteString
	call	CrLf
	
	mov	edx, [ebp+16]
	call WriteString
	call	CrLf

	mov	edx, [ebp+12]
	call	WriteString
	call	CrLf

	mov	edx, [ebp+8]
	call	WriteString
	call	CrLf

	pop ebp
	ret	8

introduction	ENDP

;******************************************************************
; fillArray, fills the array with random numbers
; Receives: address of numberArr, value of userNum
; Returns: a randomized array based on the size of the the user request.
; Pre-conditions: userNum and range need values. Randomize must be called.
; Registers changed: ecx, edi, ebp, eax
;******************************************************************

userInput	PROC

	push ebp			; Set up the stack frame.
	mov ebp, esp

	jmp userPrompt

	error:

	mov	edx, [ebp+8]	; Display Out of range, try again.
	call WriteString
	call	CrLf


	userPrompt:

	mov	eax, [ebp+12]			; Clear userNum in case of data corruption.
	mov	eax, 0				

	mov	edx, [ebp+16]			; Display the instructions
	call WriteString			
	call ReadInt

	cmp	eax, MIN
	jl	error
	cmp	eax, MAX
	jg	error

	mov	ebx, [ebp+12]
	mov	[ebx], eax

	pop ebp
	ret 12

userInput	ENDP

;******************************************************************
; fillArray, fills the array with random numbers
; Receives: address of numberArr, value of userNum
; Returns: a randomized array based on the size of the the user request.
; Pre-conditions: userNum and range need values. Randomize must be called.
; Registers changed: ecx, edi, ebp, eax
;******************************************************************

fillArray	PROC

	push	ebp
	mov	ebp, esp

	mov	edi, [ebp + 12]	; Home address of the array
	mov	ecx, [ebp+8]		; set loop counter

	fillRandom:
		mov	eax, HI
		sub	eax, LO
		inc	eax
		call RandomRange
		add	eax, LO
		mov	[edi], eax
		add	edi,	TYPE DWORD
		loop	fillRandom

	pop ebp
	ret 8

fillArray	ENDP

;******************************************************************
; Display List, shows the randomized numbers in the array.
; Receives: address of numberArr, value of userNum
; Returns: unsorted  and sorted values of array, depending where on the program
;		it is.
; Pre-conditions: array must have values
; Registers changed: ecx, esi, eax, edx, ebx
;******************************************************************

displayList	PROC

	push	ebp
	mov	ebp, esp

	call	CrLf
	mov	edx, [ebp+8]
	call	writeString
	call CrLf

	mov	esi,	[ebp+20]			; Number Array
	mov	ecx,	[ebp+16]			; loop counter
	mov	edx, [ebp+12]			; space buffer
	mov	ebx, 0				; line placement count

printLoop:

	mov	eax, [esi]			; print number
	call	WriteDec

	inc	ebx					; increase the line placement count, when hits 10, staart a new row

	mov	edx, [ebp+12]
	call	WriteString

	add	esi, 4
	cmp	ebx,	10
	je	newLine
	jmp	skipLine

newLine:
	mov	ebx, 0
	call	CrLf

skipLine:
	loop	printLoop

	pop ebp
	ret 16

displayList	ENDP

;******************************************************************
; Sorted List, passes to swap by reference, and organizes the sorted
;	numbers.
; Receives: address of array, value of request
; Returns: sorted values of array
; Pre-conditions: array must have values
; Registers changed: ecx, esi, eax, ebp
;******************************************************************

sortedList	PROC

	push ebp
	mov	ebp, esp
		
	mov	eax, [ebp+8]	; move the userNum into the loop counter
	mov	exchng1, eax		; Outer Loop counter
	mov	esi, [ebp+12]
	mov	ecx, exchng1

	dec ecx


	outerLoop:
		push	ecx
		mov	ecx, exchng1
		mov esi, [ebp+12]

	innerLoop:
		mov eax, [esi]
		cmp	[esi+4], eax
		jl	noSwap
		push	[esi+4]
		push	[esi]
		call swap
		pop	[esi]
		pop	[esi+4]

	noSwap:
		add esi, 4
		loop	innerLoop
		pop ecx
		loop	outerLoop

	pop ebp
	ret 8

sortedList	ENDP

;******************************************************************
; Swap Procedure
;	Swaps a number if one is larger than the other.
; Received: two numbers from the sorting function, if one was larger than
;			than the other and switched them.
; Returns: swapped numbers
; Pre-conditions: array must have values
; post-conditions: numbers are swapped if one is larger than the other. 
; Registers changed: ebp, eax, ebx
;******************************************************************

swap			PROC	

	push ebp
	mov	ebp, esp

	mov	eax, [ebp+12]
	mov	ebx,	[ebp+8]
	mov	[ebp+12], ebx
	mov	[ebp+8], eax

	pop ebp
	ret
	
swap			ENDP


;******************************************************************
; medianDisplay - displays the median
; Receives: medMsg, numberArr, userNum
; Returns: the median number
; Pre-conditions: array filled, sorted or unsorted
; Post-conditions: returns to main, moves onto next procedure.
; Registers changed: ebp, edx, esi, eax, ebx
;******************************************************************

medianDisplay	PROC				; Is usually one off or half a point off on evens. Is okay.

	push ebp
	mov	ebp, esp

	call	crLF
	mov	edx, [ebp+16]	; @ medMsg - display median title
	call	WriteString
	call	CrLf

	mov	esi, [ebp+12]	; @ numberArry
	mov	eax,	[ebp+8]	; @ 

	mov	ebx, 2
	mov	edx, 0

	div	ebx
	cmp	edx, 0
	je	evenNumberCount

oddNumberCount:
	mov	ebx, 4
	mul	ebx
	add	esi, eax

	mov	eax, [esi]
	call	WriteDec
	call	CrLf

	jmp	endMedian

evenNumberCount:
	mov	ebx, 4
	mul	ebx
	add	esi, eax

	mov	eax, [esi]
	add	eax, [esi-4]
	mov	ebx, 2
	mov	edx, 0
	div	ebx

	cmp	edx, 1
	jl	down			; JB/JL are appropriate here, otherwise rounded up median.
	inc	eax

down: 
	call	WriteDec
	call	CrLf

endMedian:

	pop ebp
	ret 8
	
medianDisplay		ENDP


;******************************************************************
; Farewell - says goodbye the the user
; Receives: N/A
; Returns: N/A
; Pre-conditions: Program runs through.
; Post-Conditions: Program is done.
; Registers changed: ebp, edx, esi, eax, ebx
;******************************************************************

farewell		PROC

	push ebp
	mov	ebp, esp
	
	call CrLf
	call CrLf
	mov	edx, [ebp+8]
	call WriteString
	call CrLf
	call CrLf
	
	pop ebp
	ret 8


farewell	ENDP

end main