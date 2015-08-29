TITLE Assignment 1    (assignment-1-calhouna.asm)

; Author: Andrew M. Calhoun
; Email: calhouna@onid.oregonstate.edu
; CS271-400 / Assignment 1
; Due Date: 07/5/2015
; Description: Program requests two numbers from user that will 
;			be calculated from each other. It will then produce
;			a sum, difference, product, and quotient.
;			I.e, num1 + num2, num1-num2, num1 * num2, num1 / num2,
;			and then output the result. 
;
;
;			EXTRA CREDIT: 
;			1. Repeat until the user chooses to quit.
;			2. Validate the second number to be less than the first.
;			3. Calculate and display the quotient as a floating-point number, rounded to the nearest .001.

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

userNum1		DWORD	?		; first integer input by user
userNum2		DWORD	?		; second integer input by user
intro_1		BYTE		"'Easy Arithmetic'	by Andrew M. Calhoun", 0
intro_2		BYTE		"Please enter two numbers, and I will show you the sum, difference, ", 0
intro_3		BYTE		"product, quotient, and remainder! ", 0

userSum		DWORD	?		; result of sum
userSub		DWORD	?		; result of difference
userProd		DWORD	?		; result of product
userQuot		DWORD	?		; result of quotient
userRem		DWORD	?		; result of remainder

prompt_1		BYTE		"First number: ", 0
prompt_2		BYTE		"Second number: ", 0

result_A		BYTE		" + ", 0
result_B		BYTE		" - ", 0
result_C		BYTE		" * ", 0
result_D		BYTE		" / ", 0
result_R		BYTE		"Quotient Remainder: ", 0
result_o		BYTE		" or ", 0
result_E		BYTE		" = ", 0

outro_1		BYTE		"Like what you saw? Have a great day.", 0


;Extra Credit
EC_Intro_1	BYTE		"**EC: Program will repeat until user opts to quit.", 0
EC_Intro_2	BYTE		"**EC: Program validates that second number is less than first.", 0
EC_Intro_3	BYTE		"**EC: Program calculates and shows numbers to nearest .001.", 0
EC_Instruction	BYTE		"**EC: Press 0 to quit loop when ready.", 0

whileQ		BYTE		"Do you wish to continue? Press 0 to quit.", 0
whileQ_2		BYTE		?

changeToF		REAL8	0.00		; used to change numbers to floaats
roundFloat1	REAL8	1000.0	; round the float during multiplication, round to int
roundFloat2	REAL8	1000.0	; used to div back into flow when rounding
userFloat1	REAL8	?		; float of userNum1
userFloatRem	REAL8	?		; float version of remainder
userEnd		DWORD	?		; decides if the while loop ends

loopStop		DWORD	0		; compared. Anything greater than 0 will continue loop.
error_1		BYTE		"Error!!! Your first number -must- be larger than the second.", 0	; Standard error message

.code
main PROC

; Introduce the program - displays programmer name, and a brief introduction to the program,
; as well as the extra credit portions.

	mov		edx, OFFSET intro_1
	call		WriteString
	call		CrLf

	mov		edx, OFFSET intro_2
	call		WriteString
	call		CrLf

	mov		edx, OFFSET intro_3
	call		WriteString
	call		CrLf
	call		CrLf

	mov		edx, OFFSET EC_Intro_1
	call		WriteString
	call		CrLF

	mov		edx, OFFSET EC_Intro_2
	call		WriteString
	call		CrLF

	mov		edx, OFFSET EC_Intro_3
	call		WriteString
	call		CrLF

; Get User Prompts
	mov		edx, OFFSET EC_Instruction
	call		WriteString
	call		CrLf

whileLoop:	;	Start the loop.
	
	mov		edx, OFFSET prompt_1	; ask user for num1
	call		WriteString
	call		ReadInt				; get num1
	mov		userNum1, eax
	mov		edx, OFFSET prompt_2	; ask user for num2
	call		WriteString
	call		ReadInt				; get num2
	mov		userNum2, eax

; Data Validation
	
	mov		eax, userNum1
	mov		ebx, userNum2
	cmp		eax, ebx
	jl		Error				; if num1 < num2, jump to error control
	

; Calculate Values

	; Sum
	mov		eax, userNum1
	mov		ebx, userNum2		
	add		ebx, eax				; num1 + num2
	mov		userSum, ebx

	; Difference / Subtraction
	mov		eax, userNum1
	mov		ebx, userNum2
	sub		eax, ebx				; num1 - num2
	mov		userSub, eax

	; Products
	mov		eax, userNum1
	mov		ebx, userNum2	
	mul		ebx					; num1 * num2 - multiples eax by ebx.
	mov		userProd, eax

	; Quotients
	mov		eax, userNum1
	mov		ebx, userNum2	
	div		ebx					; num1 / num2 - divides eax by ebx, edx becomes remainder. When divides by zero, it breaks the program.
	mov		userQuot, eax		
	mov		userRem, edx

	; Extra-Credit - FLOAT VALUES
	fld		changeToF
	fiadd	userNum1			; transforms num1 from int to flt
	fstp		userFloat1		
	fld		userFloat1	
	fidiv	userNum2			; generates a floating point quotient
	fstp		userFloatRem		

	fld		userFloatRem
	fmul		roundFloat1		; prepares for the rounding, multiples by 1000
	frndint	
	fdiv		roundFloat2
	fstp		userFloatRem		; divide float by 1000 to achieve float to closest .001

; Output 

	; Sum Output -- tells us what num1 + num2 is human readable language.
	mov		eax, userNum1
	call		WriteDec
	mov		edx, OFFSET result_A
	call		WriteString
	mov		eax, userNum2
	call		WriteDec
	mov		edx, OFFSET result_E
	call		WriteString
	mov		eax, userSum
	call		WriteDec
	call		CrLf

	; Difference Output -- tells us what num1 - num2 is human readable language.
	mov		eax, userNum1
	call		WriteDec
	mov		edx, OFFSET result_B
	call		WriteString
	mov		eax, userNum2
	call		WriteDec
	mov		edx, OFFSET result_E
	call		WriteString
	mov		eax, userSub
	call		WriteDec
	call		CrLf

	; Product Output -- tells us what num1 * num2 is human readable language.
	mov		eax, userNum1
	call		WriteDec
	mov		edx, OFFSET result_C
	call		WriteString
	mov		eax, userNum2
	call		WriteDec
	mov		edx, OFFSET result_E
	call		WriteString
	mov		eax, userProd
	call		WriteDec
	call		CrLf

	; Quotient Output -- tells us what num1 / num2 is human readable language.
	mov		eax, userNum1
	call		WriteDec
	mov		edx, OFFSET result_D
	call		WriteString
	mov		eax, userNum2
	call		WriteDec
	mov		edx, OFFSET result_E
	call		WriteString
	mov		eax, userQuot
	call		WriteDec
	call		CrLF
	mov		edx, OFFSET result_R
	call		WriteString
	mov		eax, userRem
	call		WriteDec
	mov		edx, OFFSET result_o
	call		WriteString
	fld		userFloatRem
	call		WriteFloat
	call		CrLf
	call		CrLf

; continue loop?
	mov		edx, OFFSET whileQ		; asks if the user if they want to continue
	call		WriteString
	call		CrLf
	mov		edx, OFFSET whileQ_2	; prompts the decision.
	call		WriteString
	call		ReadInt
	mov		ebx, loopStop
	jne		whileLoop
	je		EndProgram

; Good-Bye!
EndProgram:
	call		crLF
	mov		edx, OFFSET outro_1		; output the goodbye message
	call		WriteString		
	call		CrLF					
	exit							; exit to operating system

Error:
	mov		edx, OFFSET error_1		; error code. if the user does something wrong, they get sent here.
	call		WriteString
	call		CrLf
	jmp		WhileLoop

main ENDP

; (insert additional procedures here)

END main