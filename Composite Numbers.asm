TITLE Composite Numbers (assignment3-calhouna.asm)

; Author: Andrew M. Calhoun
; Email: calhouna@onid.oregonstate.edu
; CS271-400 / Assignment 3
; Due Date: July 26th, 2015

	; Requirements:
		; Write a program to calculate the composite numbers. First the user is instructed to enter the number of 
		; composite numbers to be displayed, and is prompter to enter an integer in the range of [1..400]. The user
		; enters the number, n, and the program verifies that for any number that is greater than or equal to 1
		; or less than or equal to 400. If n is out of range, the user is reprompted to put a number in until they
		; hit the specified range. The progrma then calculates and displays all of the composite numbers up to and including
		; the nth composite. The results should be displayed 10 composites per line with at least 3 spaces between the numbers.

INCLUDE Irvine32.inc

.data 

; Hard Constaants

	UPPER_LIMIT	EQU	400
	LOWER_LIMIT	EQU	1
	PAGE_MAX		EQU	50
	COL_MAX		EQU	10		; 5 Worked better for pagination and column alignment, but the assignment did
							; request 10.

	; Introduction

	intro	BYTE		"Composite Numbers", 13, 10,
					"Authored by Andrew M. Calhoun", 0
	intro_EC	BYTE		"------------------------------------------------------", 13, 10,
					"**EC: Align output columns.", 0											; Partially aligned, goes by number size, odd things occur when displaying them one page at a time.
	intro_EC2	BYTE		"**EC: Display more composites but display them only one page at a time.", 13, 10,
					"**EC: Increase Program Efficiency by using prime number divisors.", 13, 10,   
					"------------------------------------------------------", 0

					

	; User Instructions and Inputs
	instructions	BYTE	"Enter the amount of composite numbers you would like to see.", 13, 10,
					"I will accept orders up to 400 composites.", 0
	userNumPrompt	BYTE	"Enter the number of composite numbers you would like to display.", 13, 10,
					"[1...400]: ", 0
	rangeError	BYTE	"You are out of bounds. Try again. [1..400]", 0
	newPagePrompt	BYTE "Press any key for the next page.", 0

	userNum		DWORD	?

	; Farwell Message
	exitMsg		BYTE	"Results certified by Andrew M. Calhoun. Have a great day.", 0

	; Variables for the isComposite/showComposite procedures

	columns		DWORD	0	; width per line
	testValue		DWORD	4	; Begins at number 4. 
	compCount		DWORD	?	
	paging		DWORD	?	; to assist with pagination
	primes		DWORD	2, 3, 5, 7, 0 ; check for prime divisors
	
	colBuffer1	BYTE	"   ", 0 ; single digit numbers - gives three spaces to help them line up to double and triple dig nums
	colBuffer2	BYTE	"  ", 0 ; double digit numbers - gives two spaces to help them line up to single and triple digit nums
	colBuffer3	BYTE	" ", 0 ; triple digit numbers - gives them one space to line them up with single and double digit nums


.code

; **************** INTRODUCTION *******************
;
; introduction
;	Displays an introduction to greet the user
;	Receives: N/A
;	Returns:  N/A
;**************************************************

introduction	PROC	; Greet the User.

	mov	edx, OFFSET intro
	call WriteString
	call CrLf
	call CrLf
	
	mov edx, OFFSET intro_EC
	call WriteString
	call CrLf

	mov edx, OFFSET intro_EC2
	call WriteString
	call CrLf
	call CrLf

	mov	edx, OFFSET instructions
	call	WriteString
	call CrLf
	call CrLf

	ret

introduction	ENDP
; **************************************************

; ************* GET USER INPUT *********************
;
; getUserData
;	Takes the user's number for desired number of composites.
;	Receives: eax into userNum and validates
;	Returns:  N/A
;**************************************************


getUserData	PROC

	mov	edx, OFFSET userNumPrompt	; Get the user number.
	call	WriteString
	call ReadInt
	mov	userNum, eax				; move the EAX register into the userNum variable.
	call validate					; Let's make sure that we are getting a good range.
	ret

getUserData	ENDP

; ****************************************************

; ******** ERROR PROTECTION / USER VALIDATION ********
;
; validate
;	Receives the eax (userNum) parameter from the user input
;	and verifies if it is within bounds.
;	Receives: userNum
;	Returns:  Validated number, and if outside of bounds
;	a warning message.
;**************************************************

validate		PROC

	cmp	eax,	LOWER_LIMIT			; Compare it to the lower limit, this case 1.
	jl	rangeErrorMsg
	cmp	eax,	UPPER_LIMIT			; Compare it to the upper limit, this case 400.
	jg	rangeErrorMsg
	jmp	validated

	rangeErrorMsg:
		mov	edx,	OFFSET rangeError
		call WriteString
		call	CrLf
		call GetUserData
			
	validated:
		
		mov	compCount, 0
		mov	columns,	0
		mov	paging,	0
		ret						; If good, go to show composite.

validate		ENDP

;*************************************************

;*********** SHOW COMPOSITE NUMBERS **************
; showComposites
;	Begins a loop to show the user composite numbers
;	also has the capability to start new pages after
;	a certain number of numbers. 
;	
;	Redid this algorithm given there were problems 
;	with the jumps being too far in distance bytewise
;	and it causing problems with formatting.
;
;	Receives: userNum and puts it into ecx
;	Returns:  N/A
;**************************************************

showComposites	PROC
	
		printComposites:
		mov	eax,	paging
		cmp	eax, PAGE_MAX
		je	newPage
		mov	eax, userNum
		cmp	eax, compCount
		je	leaveLoop

		call isComposite
		inc	testValue
		mov	eax, columns
		cmp	eax, COL_MAX
		je	newLine
		jmp	printComposites

		newLine:
		call CrLf
		mov	columns, 0
		jmp	printComposites

		newPage:
		mov	edx, OFFSET newPagePrompt
		call	WriteString

		lookForKey:
		mov	eax,  50
		call Delay
		call	ReadKey
		jz	lookForKey

		mov	paging, 0
		;call ClrScr	; Everytime there is a new page, clear the screen.
		call CrLf
		call CrLf		; On Testing, clearing the screen made it difficult to tell if results were correct.
		jmp	printComposites

		leaveLoop:
		ret	

showComposites	ENDP


;*************** IS COMPOSITE ********************
; 
; isComposite
;	Takes the user's number and calculates composites. 
;	Makes use of eax, ebx, esi, and edx register.
;
;	Receives: composite number counter in testValue
;	Returns:  value in eax, esi
;	EC:	Use stack and prime numbers to make compositing more
;		efficient
;**************************************************
isComposite	PROC
	pushad	; push all the registers to the stack.
	    
    mov	eax, testValue
    cmp	eax, 5
    je	foundComplete
    cmp	eax, 7
    je	foundComplete
    mov	ebx, 0   
    mov	esi, OFFSET primes

    divisible:
    mov	edx, 0
    mov	eax, testValue	; Move the testValue (composite number check) into eax to be checked against
						; ebx and divisor.
    mov     ebx, [esi]		; move the ESI register into ebx, divide eax by ebx, if edx is 0, then we can
						; jump to the composite
    div     ebx
    cmp     edx, 0  
    jz      composites 
    inc     esi
    mov     ebx, [esi]	
    cmp     ebx, 0
    je      foundComplete
    jmp     divisible

    composites:
    mov     eax, testValue
    call    numPadding
    call    WriteDec
    inc     compCount
    inc     columns
    inc     paging
    
    foundComplete:
    popad
    ret
	
isComposite	ENDP

; **********************************************************************

; ***************************** NUM PADDING *******************************
;
; **EC: numPadding
;	**EC: Checks the size of the numbers and helps align the columns.
;	**Single digit numbers are still a bit wonky, but the other items work
;	almost perfectly.
;	Receives: eax to compare against compCount
;	Returns:  eax
;**************************************************

numPadding PROC
	pushad

	; check numbers in compCount

	mov	eax, compCount
	cmp	eax, 10
	jl	singleDigit
	cmp	eax, 100
	jl	doubleDigit
	cmp	eax, 1000
	jl	tripleDigit

	singleDigit:
	mov	edx, OFFSET colBuffer1
	call WriteString
	jmp	endPadding

	doubleDigit:
	mov	edx,	OFFSET colBuffer2
	call	WriteString
	jmp	endPadding

	tripleDigit:
	mov	edx, OFFSET colBuffer3
	call WriteString
	jmp	endPadding

	endPadding:
	popad
	ret

numPadding ENDP

; ***************************** FAREWELL *******************************
;
; farwell
;	Prints verifiation by programmer and then bids the
;	user farewell.
;	Receives: N/A
;	Returns:  N/A
;**************************************************

farewell	PROC

	call CrLF
	call CrLF
	mov	edx,	OFFSET exitMsg
	call	WriteString
	call	CrLF
	ret

farewell	ENDP

; ***************************** MAIN *******************************
;
; main
;	Main function / driver of the program.
;	Receives: N/A
;	Returns:  N/A
;**************************************************


main		PROC

	call introduction
	call getUserData
	call showComposites
	call farewell
	exit

main		ENDP

END main