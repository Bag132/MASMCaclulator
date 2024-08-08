TITLE Add and Subtract, Version 2         (AddSub2.asm)

; This program adds and subtracts 32-bit integers
; and stores the sum in a variable.

INCLUDE Irvine32.inc

.data

NewLine DB 13, 10, 0
; Prompts
PromptOperation DB 'Please select which operation to compute: + - * / ^', 13, 10, 0
PromptNumOne DB 'Enter first number: ', 0
PromptNumTwo DB 'Enter second number: ', 0

; Operations
OpAddition DB '+'
OpSubtraction DB '-'
OpMultiplication DB '*'
OpDivision DB '/'
OpExponent DB '^'

Operation BYTE 0
NumOne DWORD 0
NUMTwo DWORD 0

.code

AddNum PROC
	X:DWORD, Y:DWORD
	PUSH EBP
	MOV EBP, ESP

	MOV EAX, [EBP + 12]
	ADD EAX, [EBP + 8]

	POP EBP
AddNum ENDP

SubtractNum PROC
	X:DWORD, Y:DWORD
	PUSH EBP
	MOV EBP, ESP

	POP EBP
SubtractNum ENDP

MultiplyNum PROC
	PUSH EBP
	MOV EBP, ESP

	POP EBP
MultiplyNum ENDP

DivideNum PROC
DivideNum ENDP

main PROC
	; Ask for desired operation
	MOV EDX, OFFSET PromptOperation
	CALL WriteString

	; Read operation character from user
	CALL ReadChar
	MOV Operation, AL

	; (Debug) Print out selected operation number
	;MOVZX EAX, Operation
	;CALL WriteInt
	;MOV EDX, OFFSET NewLine
	;CALL WriteString

	; Ask for desired first number
	MOV EDX, OFFSET PromptNumOne
	CALL WriteString
	
	; Read first number from user
	CALL ReadInt
	MOV NumOne, EAX
	
	; (Debug) Print NumOne
	; CALL WriteInt
	
	; Ask for desired second number
	MOV EDX, OFFSET PromptNumTwo
	CALL WriteString
	
	; Read second number from user
	CALL ReadInt
	MOV NumTwo, EAX

	; (Debug) Print NumTwo
	;CALL WriteInt

	; Comparison for operation jump
	
	MOV AL, Operation

	; Determine which operation was selected and jump to the correct label
	CMP AL, OpAddition
	JE SelectedAddition

	CMP AL, OpSubtraction
	JE SelectedSubtraction

	CMP AL, OpMultiplication
	JE SelectedMultiplication

	CMP AL, OpDivision
	JE SelectedDivision

	CMP AL, OpExponent
	JE SelectedExponent

	JMP EndSelected ; TODO, HANDLE USER ERROR: Operation invalid

SelectedAddition:
	PUSH NumOne
	PUSH NumTwo

	CALL AddNum

	JMP EndSelected
SelectedSubtraction:
	INVOKE SubtractNum, NumOne, NumTwo
	JMP EndSelected
SelectedMultiplication:
	INVOKE MultiplyNum, NumOne, NumTwo
	JMP EndSelected
SelectedDivision:
	INVOKE DivideNum, NumOne, NumTwo
	JMP EndSelected
SelectedExponent:
	INVOKE ExponentNum, NumOne, NumTwo
EndSelected:

	exit
main ENDP
END main