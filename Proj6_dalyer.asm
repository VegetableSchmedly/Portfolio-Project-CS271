TITLE Project 6     (Proj6_dalyer.asm)

; Author: Eric Daly
; Last Modified: 3/12/2023
; OSU email address: dalyer@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6              Due Date: 3/19/2023
; Description: Uses 2 macros for string processing. One that gets input from the user and one that dispalys the output.
;		Has two test procedures for signed integers which use string primitive instructions. ReadVal will use mGetString to convert the string of ASCII
;		digits to its numeric value, and validate the user's input. It then stores the value. WriteVal will convert a numeric SDWORD to a string of ASCII
;		digits and use mDisplayString to print the ASCII representation of the SDWORD.
;		Then, MAIN will use ReadVal and WriteVal to get 10 integers from a user, looping in MAIN, store these values in array format, then display
;		the integers and their sum and truncated average.

;;		Must use Register Indirect addressing or string primitives for integer elements, 
;;		and base+offset addresing for accessing parameters on the stack!!!

;; **EC: First EC, numbers the input lines using WriteVal and display a running total.

INCLUDE Irvine32.inc

; (insert macro definitions here)
; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Purpose: Display a prompt then get the user's keyboard input into a memory location.
;
; Preconditions: Dont use EDX, ECX, EAX as arguments
;
; Receives: OFFSETS for prompt, userinput, and bytes read variables. Value of max length accomadatable.
;
; ---------------------------------------------------------------------------------
mGetString			MACRO	promptReference, userInputReference, countValue, bytesReadReference
; Displays a prompt, and then gets the user's input and stores in in a specific memory location.
	PUSH		ECX
	PUSH		EDX
	PUSH		EAX
	
	MOV			EDX, promptReference
	CALL		WriteString					; Writes Prompt

	MOV			ECX, countValue				; Length of input string macro can accomodate
	MOV			EDX, userInputReference
	CALL		ReadString				; stores userInput to userInputReference memory location. Should be OFFSET userNum.

	MOV			[bytesReadReference], EAX	; Stores number of bytes entered into bytesRead.

	POP			EAX
	POP			EDX
	POP			ECX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Purpose: Uses WriteString to display a string to the console
;
; Preconditions: Dont use EDX as an argument
;
; Receives: OFFSET for the string to be printed.
;
; ---------------------------------------------------------------------------------
mDisplayString		MACRO	stringReference
	PUSH		EDX

	MOV			EDX, stringReference
	CALL		WriteString

	POP			EDX
ENDM

; (insert constant definitions here)


MAXCHAR			=		50			; Max value accomodatable in mGetString

.data

; (insert variable definitions here)


program				BYTE		"Programming Assignment 6: Designing low-level I/O Procedures",13,10,0
myName				BYTE		"Eric Daly",0
by					BYTE		"Written by: ",0
directions1			BYTE		"Please provide 10 signed decimal integers.",13,10,0
description1		BYTE		"Each number needs to be small enough to fit inside a 32 bit register. ",13,10,0
description2		BYTE		"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,0
prompt				BYTE		"Please enter a signed number: ",0
error				BYTE		"ERROR: You did not enter a signed number or your number was too big. Try again!",0
currentNum			SDWORD		?
numArray			SDWORD		10 DUP(?)
closingDisplay		BYTE		"You entered the following numbers:",13,10,0
numString			BYTE		MAXCHAR DUP (?)
revString			BYTE		MAXCHAR DUP (?)
sum					SDWORD		?
sumString			BYTE		"The sum of these numbers is: ",0
truncatedAverage	SDWORD		?
avgString			BYTE		"The truncated average is: ",0
countValue			SDWORD		13		; Should it be >12 to account for -2147483648 and null terminator?
bytesRead			DWORD		0
isNeg				DWORD		0		; assumed positive -- BOOLEAN 0 if popsitive, 1 if negative
goodbye				BYTE		"Thanks for all the help this quarter! This class was amazing!",13,10,0
comma				BYTE		",",0
space				BYTE		" ",0
count				DWORD		0
currentTotal		BYTE		"The running subtotal of your numbers is: ",0
extraCredit1		BYTE		"**EC: First EC, numbers the input lines using WriteVal and display a running total.",13,10,0
userNum				BYTE		MAXCHAR DUP(?)		

.code
main PROC 

; (insert executable instructions here)
	PUSH			OFFSET extraCredit1
	PUSH			OFFSET program
	PUSH			OFFSET by
	PUSH			OFFSET myName
	PUSH			OFFSET directions1
	PUSH			OFFSET description1
	PUSH			OFFSET description2
	CALL			Introduction

	; Set up ReadVal loop
	MOV				EDX, OFFSET numArray
	MOV				ECX, 10
	MOV				EBX, 4
	MOV				EAX, 0
	_ReadValLoop:				; convert strings to integers until 10 valid are captured.
		; current total
		mDisplayString	OFFSET currentTotal
		PUSH			OFFSET revString
		PUSH			OFFSET isNeg
		PUSH			OFFSET numString
		PUSH			sum
		CALL			WriteVal
		CALL			CrlF
		; Line numbers
		PUSH			OFFSET revString
		PUSH			OFFSET isNeg
		PUSH			OFFSET numString
		PUSH			count
		CALL			WriteVal
		INC				count
		mDisplayString	OFFSET space
		;current total
		PUSH			OFFSET isNeg
		PUSH			OFFSET prompt
		PUSH			OFFSET userNum
		PUSH			countValue
		PUSH			OFFSET bytesRead
		PUSH			OFFSET error
		PUSH			OFFSET currentNum
		CALL			ReadVal
		MOV				EDI, currentNum
		MOV				[EDX], EDI			; put currentNum into proper location in array
		ADD				EDX, EBX			; increment SDWORD array by 4 (SDWORD)
		ADD				EAX, currentNum		; ADD to sum
		MOV				sum, EAX
		CMP				ECX, 0
		DEC				ECX
	JA				_ReadValLoop			; 18 bytes too large for LOOP 
	CALL			CrLf
	CALL			CrLf


	; Print out array as strings
	mDisplayString	OFFSET closingDisplay
	MOV				ECX, 10
	MOV				EBX, 0
	MOV				EAX, 0
	_PrintArrayLoop:
		MOV				EAX, OFFSET numArray	
		MOV				isNeg, 0
		; assume positive
		PUSH			OFFSET revString
		PUSH			OFFSET isNeg
		PUSH			OFFSET numString
		PUSH			[EAX + EBX]			; Value in num array, incremented forward by EBX
		CALL			WriteVal
		ADD				EBX, 4
		CMP				ECX, 1				; Last value doesnt need a comma
		JA				_addComma
		_endOfPrintLoop:
	LOOP			_PrintArrayLoop
	CALL			CrLf
	CALL			CrLf
	JMP				_sum



	_addComma:
  ; Add comma and space if ECX>1
	mDisplayString	OFFSET comma
	mDisplayString	OFFSET space
	JMP				_endOfPrintLoop

	_sum:
	; Set up for WriteVal to display sum, which was calculated during the user input loop.
	mDisplayString	OFFSET sumString		; sum display string

	PUSH			OFFSET revString
	PUSH			OFFSET isNeg
	PUSH			OFFSET numString
	PUSH			sum
	CALL			WriteVal
	CALL			CrLf
	CALL			CrLf

	; AVG CALCULATION
	MOV				EAX, sum			
	MOV				EDX, 0
	MOV				EBX, 10
	CDQ										; sign extend to EDX:EAX for IDIV
	IDIV			EBX						; IDIV sum / 10
	MOV				truncatedAverage, EAX

	mDisplayString	OFFSET avgString		; Average display string

	; set up WriteVal for printing the truncated average
	PUSH			OFFSET revString
	PUSH			OFFSET isNeg
	PUSH			OFFSET numString
	PUSH			truncatedAverage
	CALL			WriteVal
	CALL			CrLf
	CALL			CrLf

	mDisplayString	OFFSET goodbye			; Thanks for the (hopefully good) grade!


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)


; ---------------------------------------------------------------------------------
; Name: Introduction
;
; Uses mDisplayString to print out the title, introduction, and description of the program
;
; Preconditions: The offsets of program, by, myname, directions1, and description1-2 are passed as parameters
;
; Postconditions: EBP is used and restored to previous value.
;
; Receives:
; [ebp+32] = OFFSET extraCredit1
; [ebp+28] = OFFSET program
; [ebp+24] = OFFSET by
; [ebp+20] = OFFSET myName
; [ebp+16] = OFFSET directions1
; [ebp+12] = OFFSET description1
; [ebp+8] = OFFSET description2
; arrayMsg, arrayError are global variables
;
; returns: Prints strings to the console for the user to view.
; ---------------------------------------------------------------------------------

Introduction PROC
; Writes all of the instructions to the screen
	PUSH		EBP
	MOV			EBP, ESP

	mDisplayString [EBP+28]	; title
	mDisplayString [EBP+24] ; by
	mDisplayString [EBP+20] ; my name
	CALL		CrLf
	CALL		CrLf
	mDisplayString [EBP+16] ; directions1
	mDisplayString [EBP+12] ; description1
	mDisplayString [EBP+8]  ; description2
	mDisplaystring [EBP+32] ; EC1
	CALL		CrLf
	CALL		CrLf

	POP			EBP
	RET			24
Introduction ENDP



; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Invokes mGetString to get user input and converts it to its numeric value SDWORD. 
;	Then validates it is a number and stores it in an array. If invalid input, the procedure will print an error
;	and repeatedly prompt the user until valid data is entered.
;
; Preconditions: mGetString is a predefined macro. MAXCHAR is a predefined constant.
;
; Postconditions: Uses PUSHAD/POPAD to restore all registers to their previous values.
;
; Receives:
; [ebp+32] = OFFSET isNeg
; [ebp+28] = OFFSET prompt
; [ebp+24] = OFFSET userNum
; [ebp+20] = countValue
; [ebp+16] = OFFFSET bytesRead
; [ebp+12] = OFFSET error
; [ebp+8] = OFFSET currentNum
; MAXCHAR is a defined constant - passed to mGetString
;
; returns: numeric value is stored in currentNum 
; ---------------------------------------------------------------------------------
ReadVal PROC 
;  Invokes mGetString to get user input and converts it to its numeric value SDWORD. Then validates it is a number and stores it in an array.
	PUSH		EBP
	MOV			EBP, ESP				; Base pointer
	PUSHAD
	CLD									; moving forward in strings
	
	_start:
	MOV			EBX, [EBP+16]			; BYTES READ
	MOV			EDX, 0					; accumulator
	MOV			EAX, [EBP+32]			; Make sure number is assumed positive
	MOV			[EAX], EDX				; EDI at 0, so using it to clear Neg

	
	mGetString	[EBP + 28], [EBP + 24], MAXCHAR, EBX

	MOV			EAX, [EBX]
	CMP			EAX, [ebp+20]			; compared bytes read to max allowable length
	JG			_error
	CMP			EAX, 0					; Nothing entered
	JE			_error
	MOV			EBX, [EBP+24]
	MOV			ECX, [EBX]

	MOV			ECX, EAX				; BYTES READ
	CLD									;Clear direction Flag - move forwards
	MOV			ESI, [EBP + 24]			; userNum input string location
	MOV			EAX, 0
	_conversionLoop:
		LODSB								; Load byte by byte into AL
		CMP			AL, '-'
		JE			_minusSign				; handle negative number
		CMP			AL, '+'
		JE			_plusSign
		CMP			AL, '0'
		JB			_error
		CMP			AL, '9'
		JA			_error
							
											; Otherwise, number is good, convert and add to integer array
		MOV			EBX, 10	
		PUSH		EAX
		MOV			EAX, EDX				; multiply accumulator by 10 for each digit
		IMUL		EBX
		MOV			EDX, EAX				; move product back to accumulator
		MOV			EAX, 0
		POP			EAX						; add next digit to accumulator
		JO			_overFlow
		SUB			EAX, 48
		JO			_overFlow
		ADD			EDX, EAX				; Use same sized register
		JO			_overFlow			; 3 JO due to OF flag being raised at different times if the values are close to the max.
		_endLoop:
	LOOP		_conversionLoop
	JMP			_endOfProc


	_error:
	; Prints the error message and jumps back to the start to reprompt for valid input
	mDisplayString	[EBP+12]
	CALL			CrLf
	JMP				_start


	_overFlow:
  ; Overflow flag was raised in conversion loop. 
	CMP			EDX, 2147483648
	JE			_minValCheck
	JMP			_error

	_minValCheck:
	; Check if the value is -2147483648, otherwise it is either too large or too small.
	MOV			EBX, [EBP+32]
	MOV			ECX, [EBX]
	CMP			ECX, 0	
	JE			_error
	JMP			_endOfProc

	_minusSign:
	; adds minus sign to string
	PUSH		EBX
	PUSH		ECX
	PUSH		EAX	
	PUSH		EDX
	MOV			EAX, [ebp+16]	
	MOV			EDX, [EAX]
	CMP			EDX, 1
	JE			_signError
	MOV			EBX, [EBP+32]
	MOV			ECX, [EBX]
	INC			ECX
	MOV			[EBX], ECX
	POP			EDX
	POP			EAX
	POP			ECX
	POP			EBX
	JMP			_midString	; increment forwards

	_plusSign:
	; skip the plus sign, as it is not relevant
	PUSH		EBX
	PUSH		ECX
	PUSH		EAX
	PUSH		EDX
	MOV			EAX, [ebp+16]	
	MOV			EDX, [EAX]
	CMP			EDX, 1
	JE			_signError
	MOV			EBX, [EBP+32]
	MOV			ECX, [EBX]
	MOV			ECX, 0
	MOV			[EBX], ECX
	POP			EDX
	POP			EAX
	POP			ECX
	POP			EBX
	JMP			_midString	; increment forwards


	_midString:
  ; Check if the +/- sign was entered mid string.
	PUSH		EBX
	PUSH		ECX
	PUSH		EAX
	PUSH		EDX
	MOV			EAX, [EBP+24]			; offset of userNum
	INC			EAX						; increments pointer to match ESI, since LODSB increments after moving to AL
	CMP			EAX, ESI				
	JNE			_signError
	POP			EDX
	POP			EAX
	POP			ECX
	POP			EBX
	JMP			_endLoop


	_signError:
  ; Error due to just -/+ being entered. Fixes registers and jumps to error.
	POP			EDX
	POP			EAX
	POP			ECX
	POP			EBX
	JMP			_error

	_endOfProc:
	; IF [EBP+32] IS 1, NEG THE NUMBER.
	MOV			EBX, [EBP+32]
	MOV			ECX, [EBX]
	CMP			ECX, 0
	JE			_notNeg
	CMP			ECX, 1
	JA			_error
	NEG			EDX			; twos complement for SDWORD
	MOV			ECX, 0
	MOV			[EBX], ECX
	_notNeg:				; avoid NEG
	MOV			EDI, [EBP+8]
	MOV			EAX, EDX
	STOSD					; Store DWORD in EDI, which points to OFFSET of currentNum

	POPAD
	POP			EBP
	RET			28

ReadVal ENDP



; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts an SDWORD value into a string and prints it using mDisplayString.
;
; Preconditions: mDisplayString is a predefined constant.
;
; Postconditions: All registers are used, but PUSHAD/POPAD restores the stack frame.
;
; Receives:
; [ebp+20] = OFFSET revNumString
; [ebp+16] = OFFFSET isNeg
; [ebp+12] = OFFSET numString
; [ebp+8] = value to be converted
; arrayMsg, arrayError are global variables
;
; returns: Uses mDisplayString to display the converted SDWORD as a string, 
; ---------------------------------------------------------------------------------
WriteVal PROC
; Converts an SDWORD value into a string and prints it using mDisplayString.
	PUSH		EBP
	MOV			EBP, ESP			; Base pointer
	PUSHAD

	MOV			EBX, [EBP+16]		; offset isNeg
	MOV			EDI, [EBP+20]		; Reverse numstring offset
	MOV			ECX, 0				; count for string reversal
	; CHeck if neg.
	MOV			EAX, [EBP + 8]		; Num value
	CMP			EAX, 0
	JL			_isNegative

	;; convert back to string
	CLD								; Move forwards through string
	MOV			EAX, [EBP + 8]		; OFFSET of Num
	PUSH		EBX
	_divideLoop:
	MOV			EDX, 0
	MOV			EBX, 10	
	DIV			EBX
	ADD			EDX, 48				; add ascii conversion
	PUSH		EAX
	MOV			EAX, EDX			; move remainder to store it.
	STOSB
	POP			EAX
	INC			ECX	
	CMP			EAX, 0
	JNE			_divideLoop			; repeat until there is no quotient.
	POP			EBX
	MOV			EAX, [EBX]
	CMP			EAX, 0
	JE			_notNeg
	JMP			_reverse			; If neg, add a '-' at the end of the reverse string



	_isNegative:
	; set neg flag and go back to loop
	PUSH		EBX
	MOV			EAX, 1				; set negative flag
	MOV			[EBX], EAX
	MOV			EAX, [EBP+8]
	NEG			EAX
	INC			ECX
	JMP			_divideLoop

	

	_reverse:
 ; add '-' at end of string
	MOV			EAX, 0
	MOV			AL, '-'
	STOSB
	_notNeg:
 ; set up for string reversal
	MOV			ESI, [EBP+20]			; offset reverse string
	MOV			EDI, [EBP+12]			; offset numstring
	ADD			ESI, ECX				; start at end of reverse string
	DEC			ESI						; remove null terminator

	_revLoop:
	; flips the direction flag between loading and storing to reverse the string and place the forward string in [ebp+12]
		STD
		LODSB
		CLD
		STOSB
	LOOP		_revLoop
	
	
	MOV			AL, 0
	STOSB						; null terminator at end of good string


	mDisplayString [EBP+12]		; display newly converted string

	POPAD
	POP			EBP
	RET			16
WriteVal ENDP


END main