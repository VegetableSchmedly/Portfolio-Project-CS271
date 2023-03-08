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

;;		Must use Register Indirect addressing or string primitives for integer elemnts, 
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
	PUSH		EBP
	MOV			EBP, ESP
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
	POP			EBP
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
	PUSH		EBP
	MOV			EBP, ESP
	PUSH		EDX

	MOV			EDX, stringReference
	CALL		WriteString

	POP			EDX
	POP			EBP
ENDM

; (insert constant definitions here)


PLUS			EQU		<"+",0>
MINUS			EQU		<"-",0>

.data

; (insert variable definitions here)


program				BYTE		"Programming Assignment 6: Designing low-level I/O Procedures",13,10,0
myName				BYTE		"Eric Daly",0
by					BYTE		"Written by: ",0
directions1			BYTE		"Please provide 10 signed decimal integers.",13,10,0
description1		BYTE		"Each number needs to be small enough to fit inside a 32 bit register. ",13,10,0
description2		BYTE		"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,0
prompt				BYTE		"Please enter a signed number: ",0
userNum				SDWORD		?
error				BYTE		"ERROR: You did not enter a signed number or your number was too big. Try again!",0
numArray			SDWORD		10 DUP(?)
closingDisplay		BYTE		"You entered the following numbers:",13,10,0
sum					SDWORD		?
sumString			BYTE		"The sum of these numbers is: ",13,10,0
truncatedAverage	SDWORD		?
avgString			BYTE		"The truncated average is ",13,10,0
countValue			DWORD		32		; Should it be 12 to account for -2147483648 and null terminator?
bytesRead			DWORD		?

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
; [ebp+16] = type of array element
; [ebp+12] = length of array
; [ebp+8] = address of array
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

;	CALL		mGetString








ReadVal ENDP



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
WriteVal PROC
; 
	PUSH		EBP
	MOV			EBP, ESP





WriteVal ENDP
END main



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



