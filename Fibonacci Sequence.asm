TITLE Programming Assignment #2 - Fibonacci Sequence (program2-calhouna.asm)

; Author: Andrew M. Calhoun
; Email: calhouna@onid.oregonstate.edu
; CS271 / Program #2
; Description: A program that calculates numbers in the Fibonacci sequence.
; DUE DATE: 7/12/2015

INCLUDE Irvine32.inc

.data
; PROGRAM INTRO AND USER MESSAGES

welcome	BYTE		"------------------------------------------------------------", 13, 10,
				" CS271 Programming Assignment #2: Fibonacci Numbers", 13, 10,
				" Author: Andrew Michael Calhoun", 13, 10,
				" Calculate Fibonacci Numbers.", 13, 10,
				"------------------------------------------------------------",0

welcomeEC	BYTE		"************************************************************", 0
welcomeE2	BYTE		"  EC: Output the EC banner in blue and gold.		    ", 0
welcomeE4	BYTE		"  EC: Output the Fibonacci Series in Blue and White	    ", 0
welcomeE5	BYTE		"  EC: Put the numbers in columns. - Larger Numbers can      ", 0
welcomeE6	BYTE		"  get funny with the spacing though.			    ", 0
welcomeE7 BYTE		"************************************************************", 0

greeting	BYTE		"Hello! What is your name? ", 0
intro	BYTE		"Nice to meet you, ", 0	
buffer	BYTE		"	", 0	; Buffer stays column-compatible until term 35.
outro	BYTE		"Results certified by Andrew M. Calhoun",13, 10,
				"Goodbye ", 0
punct	BYTE		"!", 0

; VERIFICATION / VALIDATION / ERROR MESSAGES
verQuit	BYTE		"Are you sure you want to quit (1 to quit/0 to continue) ", 0
quitMsg	BYTE		"Going already? Ok... Have a great day!", 0
repeatMsg	BYTE		"Would you like to do another term? (1 to contiue/0 to quit)", 0
errorMsg	BYTE		"You are out of range. Can only be between [1..46].", 0	
; errorYN	BYTE		"Invalid Input, please input Y/N", 0	; Tried to use a string input.
errorYN	BYTE		"Invalid Input, please input 1 or 0", 0	; Virtually identical, except 1/0.



; INPUT MESSAGES

instructions		BYTE		"Enter the number of Fibonacci terms to display: ", 13, 10,
						"Range must be between [1..46]. (Enter -1 to Quit)", 0
numberPrompt		BYTE		"Enter number: ", 0


; ERROR MESSAGES

; USER INPUTS
userName	BYTE	36 DUP(0)	; Get the user's name
userNum	DWORD ?		; The depth of the Fibonacci Sequence the user wants.
fibNum	DWORD ?		; first variable, used in calculations (n-1)
columns	DWORD 0		; counter for each line and column.
;rptConf	BYTE	1 DUP(0)  ; Confirm Repeat
;quitCon	BYTE 1 DUP(0)	; Confirm Quit		- From String Input attempt.

rptConf	DWORD ?   ; Confirm Repeat
quitCon	DWORD ?	; Confirm Quit


; CONSTANTS - RANGE LIMITATION, UPPER AND LOWER, MAX COLUMNS
LOWER_LIMIT	EQU	 1			; Cannot be less than 1.
UPPER_LIMIT	EQU	46			; DWORD limitation - 46
COLUMN_MAX	EQU	 5			; Column Creation.
QUIT			EQU	-1			; If you want to quit without getting a number.
AFFIRMATIVE1	EQU	89, 0		; 'Y'	- Gotten from the ASCII code handbook
NEGATIVE1		EQU	78, 0		; 'N'	http://www.bibase.com/images/ascii.gif
AFFIRMATIVE2	EQU	121, 0		; 'y'
NEGATIVE2		EQU	110, 0		; 'n'

; Unfortunately, the constants for char inputs were not well liked by the AL register later in the program, so
; I could not use them. I left them in, however, to show my thought process as I went through
; this assignment and added bells and whistles. Decided to go with integer based inputs for verification.



.code
main PROC
	
	; Introductions
	mov	edx, OFFSET welcome
	call WriteString
	call CrLf
	call CrLf
	mov	eax, yellow + (blue * 16)	; No Orange, so went with blue and gold. Go Bears!
	call SetTextColor
	mov	edx, OFFSET welcomeEC
	call WriteString
	call CrLf
	mov	edx, OFFSET welcomeE2
	call WriteString
	call CrLf
	mov	edx, OFFSET welcomeE4
	call WriteString
	call CrLf
	mov	edx, OFFSET welcomeE5
	call WriteString
	call CrLf
	mov	edx, OFFSET welcomeE6
	call WriteString
	call CrLf
	mov	edx, OFFSET welcomeE7
	call WriteString
	call CrLf
	mov	eax, lightgray + (black * 16)
	call SetTextColor
	call CrLf
	call CrLf
	
	; Get User Name
	mov edx, OFFSET greeting
	call WriteString
	mov edx, OFFSET userName
	mov ecx, SIZEOF userName
	call ReadString
	
	;Say hello to [user]

	mov edx, OFFSET intro
	call WriteString
	mov edx, OFFSET userName
	call WriteString
	mov edx, OFFSET punct
	call WriteString
	call CrLf
	call CrLf
	
	; Instructions and User Data
	; While loops would generally be what is used in a high level language, so I'm
	; going to name my loop WhileLoop again.

	; Instructions Proper
	
	mov edx, OFFSET instructions
	call WriteString
	call CrLf

	whileLoop:
		mov	edx, OFFSET numberPrompt
		call WriteString
		call ReadInt
		cmp	eax, QUIT
		je	verify
		cmp	eax, LOWER_LIMIT
		jl	error
		cmp	eax, UPPER_LIMIT
		jg	error
		jmp	done


	; read off the error number - give a bad input? You're sent here.
 
	error:
		mov edx, OFFSET errorMsg
		call WriteString
		call CrLf
		jmp whileLoop

	done:
		call CrLf
		mov userNum, eax

	; Fibonacci Sequence Loop and parameters

	FiboSequence:			; In case I need to loop it.
		; Fibonacci is a sequence of number that sums up the previous two numbers in the
		; sequence. The first two numbers are 1, and once they are added up, they equal the
		; next number in the sequence. Formula: f(n) = f(n-1) + f(n-2) 

		; For example: 1 + 1 = 2, 1 + 2 = 3, 2 + 3 = 5, 3 + 5 = 8, 5 + 8 = 13, and so on.

		mov	ebx,	0		; Special case for low level numbers
		mov	fibNum,	1	; ""
		mov	ecx, userNum	; loop counter
		mov	columns,	1	; column counter


	FiboLoop:
		mov	eax, lightgray + (blue * 16)	; From example in book, pg 168, 7th Edition
		call SetTextColor
		mov	eax,	ebx
		add	eax, fibNum
		; Output the Term
		call WriteDec
		mov	fibNum, ebx
		mov	edx,	OFFSET buffer
		call WriteString	
		mov	ebx, eax
		cmp	columns, COLUMN_MAX
		jge	newLine
		inc	columns
		jmp	sameLine
	

		newLine:
			call	CrLf
			mov	columns, 1
		sameLine:
			loop FiboLoop
			mov eax, lightgray + (black * 16); Return the color.
			call SetTextColor
		

	goAgain:
		call CrLf
		mov edx, OFFSET repeatMsg
		call WriteString
		call CrLf
		call ReadInt
		cmp	eax, 1
		je	whileLoop
		cmp	eax, 0
		je	goodbye_msg	; If an invalid Integer or Character is given, it quits.
		jmp	error_go

	 verify:
		call CrLf
		mov edx, OFFSET verQuit
		call WriteString
		call CrLf
		call ReadInt
		cmp	eax, 1
		je	quit_msg
		cmp	eax, 0
		je	whileLoop
		jmp	error_quit

	error_go:
		mov edx, OFFSET errorYN
		call WriteString
		call CrLf
		jmp goAgain

	error_quit:
		mov edx, OFFSET errorYN
		call WriteString
		call CrLf
		jmp verify

	; Say Goodbye or Quit. 
	quit_msg:					; If you want to quit. 
		mov	edx,	OFFSET quitMsg
		call	WriteString
		call	CrLF
		mov	edx, OFFSET outro
		call WriteString
		mov edx, OFFSET userName
		call WriteString
		mov	edx, OFFSET punct
		call CrLf
	
	exit				; Exit to the operating system

	goodbye_msg:
		mov	edx, OFFSET outro
		call WriteString
		mov edx, OFFSET userName
		call WriteString
		mov edx, OFFSET punct
		call WriteString
		call CrLf
	
	exit				; Exit to the operating system
main ENDP

; Let's run a nested process, and display the Fibonacci Sequence up to the given terms.

END main
;