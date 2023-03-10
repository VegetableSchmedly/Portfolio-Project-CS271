TITLE Project 6     (Proj6_dalyer.asm)

; Author: Eric Daly
; Last Modified: 3/7/2023
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

INCLUDE Irvine32.inc

; (insert macro definitions here)
; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Purpose: Display a prompt then get the user's keyboard input into a memory location.
;
; Receives:
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
; Purpose:
;
; Receives:
;
; ---------------------------------------------------------------------------------
mDisplayString		MACRO	stringReference
	PUSH		EDX

	MOV			EDX, stringReference
	CALL		WriteString

	POP			EDX
ENDM

; (insert constant definitions here)


PLUS			EQU		<"+",0>
MINUS			EQU		<"-",0>
MAXCHAR			=		21

.data

; (insert variable definitions here)


program				BYTE		"Programming Assignment 6: Designing low-level I/O Procedures",13,10,0
myName				BYTE		"Eric Daly",0
by					BYTE		"Written by: ",0
directions1			BYTE		"Please provide 10 signed decimal integers.",13,10,0
description1		BYTE		"Each number needs to be small enough to fit inside a 32 bit register. ",13,10,0
description2		BYTE		"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,0
prompt				BYTE		"Please enter a signed number: ",0
userNum				byte		20 DUP(?)
error				BYTE		"ERROR: You did not enter a signed number or your number was too big. Try again!",0
currentNum			SDWORD		?
numArray			SDWORD		10 DUP(?)
closingDisplay		BYTE		"You entered the following numbers:",13,10,0
numString			BYTE		20 DUP (?)
revString			BYTE		20 DUP (?)
sum					SDWORD		?
sumString			BYTE		"The sum of these numbers is: ",13,10,0
truncatedAverage	SDWORD		?
avgString			BYTE		"The truncated average is ",13,10,0
countValue			SDWORD		32		; Should it be 12 to account for -2147483648 and null terminator?
bytesRead			DWORD		0
isNeg				DWORD		0		; assumed positive -- BOOLEAN 0 if popsitive, 1 if negative


.code
main PROC

; (insert executable instructions here)
	PUSH		OFFSET program
	PUSH		OFFSET by
	PUSH		OFFSET myName
	PUSH		OFFSET directions1
	PUSH		OFFSET description1
	PUSH		OFFSET description2
	CALL		Introduction

	; Set up ReadVal loop
	MOV			EDX, OFFSET numArray
	MOV			ECX, 10
	MOV			EBX, 4
	MOV			EAX, 0
	_ReadValLoop:				; convert strings to integers until 10 valid are captured.
		PUSH		OFFSET isNeg
		PUSH		OFFSET prompt
		PUSH		OFFSET userNum
		PUSH		countValue
		PUSH		OFFSET bytesRead
		PUSH		OFFSET error
		PUSH		OFFSET currentNum
		CALL		ReadVal
		MOV			EDI, currentNum
		MOV			[EDX], EDI			; put currentNum into proper location in array
		ADD			EDX, EBX			; increment SDWORD array by 4 (SDWORD)
		ADD			EAX, currentNum		; ADD to sum
	LOOP		_ReadValLoop	
	MOV			sum, EAX			; capture sum
	CALL		CrLf
	CALL		CrLf


	; Print out array as strings
	MOV			EDX, OFFSET closingDisplay
	CALL		WriteString
	MOV			ECX, 10
	MOV			EBX, 0
	MOV			EAX, 0
	_PrintArrayLoop:
		MOV			EAX, OFFSET numArray	
		MOV			isNeg, 0				; assume positive

		PUSH		OFFSET revString
		PUSH		OFFSET isNeg
		PUSH		OFFSET numString
		PUSH		[EAX + EBX]
		CALL		WriteVal
		ADD			EBX, 4
		PUSH		EAX
		MOV			EAX, 0
		MOV			AL, ','
		CALL		WriteChar
		MOV			AL, ' '
		CALL		WriteChar
		POP			EAX
				
	LOOP		_PrintArrayLoop


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)


; ---------------------------------------------------------------------------------
; Name: findSmallest
;
; Invokes mGetString to get user input and converts it to its numeric value SDWORD. 
;	Then validates it is a number and stores it in an array.
;
; Preconditions: the array contains only positive values.
;
; Postconditions: none.
;
; Receives:
; [ebp+16] = type of array element
; [ebp+12] = length of array
; [ebp+8] = address of array
; arrayMsg, arrayError are global variables
;
; returns: eax = smallest integer
; ---------------------------------------------------------------------------------

Introduction PROC
; Writes all of the instructions to the screen
	PUSH		EBP
	MOV			EBP, ESP
	PUSH		EDX

	MOV			EDX, [EBP+28]
	CALL		WriteString

	MOV			EDX, [EBP+24]
	CALL		WriteString

	MOV			EDX, [EBP+20]
	CALL		WriteString
	CALL		CrLf
	CALL		CrLf

	MOV			EDX, [EBP+16]
	CALL		WriteString

	MOV			EDX, [EBP+12]
	CALL		WriteString

	MOV			EDX, [EBP+8]
	CALL		WriteString


	POP			EDX
	POP			EBP
	RET			24


Introduction ENDP



; ---------------------------------------------------------------------------------
; Name: findSmallest
;
; Invokes mGetString to get user input and converts it to its numeric value SDWORD. 
;	Then validates it is a number and stores it in an array.
;
; Preconditions: the array contains only positive values.
;
; Postconditions: none.
;
; Receives:
; [ebp+32] = OFFSET isNeg
; [ebp+28] = OFFSET prompt
; [ebp+24] = OFFSET userNum
; [ebp+20] = countValue
; [ebp+16] = OFFFSET bytesRead
; [ebp+12] = OFFSET error
; [ebp+8] = OFFSET currentNum
; arrayMsg, arrayError are global variables
;
; returns: eax = smallest integer
; ---------------------------------------------------------------------------------
ReadVal PROC
;  Invokes mGetString to get user input and converts it to its numeric value SDWORD. Then validates it is a number and stores it in an array.
	PUSH		EBP
	MOV			EBP, ESP
	PUSH		EAX
	PUSH		EBX
	PUSH		ECX
	PUSH		EDX
	PUSH		ESI
	PUSH		EDI	
	MOV			EBX, [EBP+16]			; BYTES READ
	MOV			EDI, 0					; accumulator
	_start:

	mGetString	[EBP + 28], [EBP + 24], MAXCHAR, EBX

	MOV			EAX, [EBX]
	CMP			EAX, [ebp+20]			; compared bytes read to max allowable length
	JG			_error
	CMP			EAX, 0
	JE			_error

	MOV			ECX, EAX				; BYTES READ
	CLD									;Clear direction Flag - move forwards
	MOV			ESI, [EBP + 24]			; userNum input string location
	MOV			EAX, 0
	_conversionLoop:
		LODSB
		CMP			AL, '+'
		JE			_endLoop				; skip positive sign
		CMP			AL, '-'
		JE			_minusSign				; handle negative number
		CMP			AL, '+'
		JE			_plusSign
		CMP			AL, '0'
		JB			_error
		CMP			AL, '9'
		JA			_error
							
											; Otherwise, number is good, convert and add to integer array.

		MOV			EBX, 10	
		PUSH		EAX
		MOV			EAX, EDI				; multiply accumulator by 10 for each digit
		IMUL		EBX
		MOV			EDI, EAX				; move product back to accumulator
		MOV			EAX, 0
		POP			EAX						; add next digit to accumulator
		SUB			EAX, 48
		ADD			EDI, EAX				; Use same sized register

		_endLoop:
	LOOP		_conversionLoop
	JMP			_endOfProc


	_error:
	; The string values are not ASCII for a number or a +/- sign.
	PUSH		EDX
	MOV			EDX, [EBP+12]
	CALL		WriteString
	POP			EDX
	CALL		CrLf
	JMP			_start



	_minusSign:
	PUSH		EBX
	PUSH		ECX
	MOV			EBX, [EBP+32]
	MOV			ECX, 1
	MOV			[EBX], ECX
	POP			ECX
	POP			EBX
	JMP			_endLoop

	_plusSign:
	PUSH		EBX
	PUSH		ECX
	MOV			EBX, [EBP+32]
	MOV			ECX, 0
	MOV			[EBX], ECX
	POP			ECX
	POP			EBX
	JMP			_endLoop

	_endOfProc:
	; IF [EBP+32] IS 1, NEG THE NUMBER.
	MOV			EBX, [EBP+32]
	MOV			ECX, [EBX]
	CMP			ECX, 0
	JE			_notNeg
	NEG			EDI
	MOV			ECX, 0
	MOV			[EBX], ECX
	_notNeg:			; avoid NEG
	MOV			EAX, [EBP+8]
	MOV			[EAX], EDI

	POP			EDI
	POP			ESI
	POP			EDX
	POP			ECX
	POP			EBX
	POP			EAX
	POP			EBP
	RET			28

ReadVal ENDP



; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Finds the smallest integer in an array and returns it in the eax register.
;
; Preconditions: the array contains only positive values.
;
; Postconditions: none.
;
; Receives:
; [ebp+32] = OFFSET isNeg
; [ebp+28] = OFFSET prompt
; [ebp+24] = OFFSET userNum					; STILL NEEDS CHANGING
; [ebp+20] = countValue
; [ebp+16] = OFFFSET bytesRead
; [ebp+12] = OFFSET error
; [ebp+8] = OFFSET currentNum
; arrayMsg, arrayError are global variables
;
; returns: eax = smallest integer
; ---------------------------------------------------------------------------------
WriteVal PROC
; 
	PUSH		EBP
	MOV			EBP, ESP
	PUSH		EAX
	PUSH		EBX
	PUSH		ECX
	PUSH		EDX
	PUSH		ESI
	PUSH		EDI	
	MOV			EBX, [EBP+16]			; offset isNeg
	MOV			EDI, [EBP+20]			; Reverse numstring offset
	MOV			ECX, 0				; count for string reversal
	; CHeck if neg.
	MOV			EAX, [EBP + 8]		; OFFSET of Num
	CMP			EAX, 0
	JB			_isNegative

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
	JMP			_reverse



	_isNegative:
	; set neg flag and go back
	PUSH		EAX
	PUSH		EBX
	MOV			EAX, 1				; set negative flag
	MOV			[EBX], EAX
	MOV			EBX, [EDI]
	NEG			EBX					; make integer positive for translation
	MOV			[EDI], EBX
	POP			EBX
	POP			EAX
	STOSB
	INC			ECX
	JMP			_divideLoop

	

	_reverse:
	MOV			EAX, 0
	MOV			AL, '-'
	STOSB
	_notNeg:
	MOV			ESI, [EBP+20]
	MOV			EDI, [EBP+12]
	ADD			ESI, ECX
	DEC			ESI

	_revLoop:
		STD
		LODSB
		CLD
		STOSB
	LOOP		_revLoop
	
	
	MOV			AL, 0
	STOSB				; null terminator


	mDisplayString [EBP+12]

	POP			EDI
	POP			ESI
	POP			EDX
	POP			ECX
	POP			EBX
	POP			EAX
	POP			EBP
	RET			16
WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: findSmallest
;
; Finds the smallest integer in an array and returns it in the eax register.
;
; Preconditions: the array contains only positive values.
;
; Postconditions: none.
;
; Receives:
; [ebp+16] = type of array element
; [ebp+12] = length of array
; [ebp+8] = address of array
; arrayMsg, arrayError are global variables
;
; returns: eax = smallest integer
; ---------------------------------------------------------------------------------
CalcAvg PROC
; 
	PUSH		EBP
	MOV			EBP, ESP

CalcAvg ENDP


END main