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

; Error strings
OperationInvalidError DB 'Selected operation is invalid: ', 0
DivideZeroError DB 'Cannot divide by zero.', 13, 10, 13, 10, 0
OverflowError DB 'Integer overflow.', 13, 10, 13, 10, 0

; Calculation memory
MEMORY_LENGTH EQU 4 * 30
CalcMemory DWORD MEMORY_LENGTH DUP(0)
MemIndex DWORD 0

; Operations
OpAddition DB '+'
OpSubtraction DB '-'
OpMultiplication DB '*'
OpDivision DB '/'
OpExponent DB '^'
CharSpace BYTE ' '
CharEqual BYTE '='

; Calculation variables
Operation BYTE 0
NumOne DWORD 0
NUMTwo DWORD 0
Result DWORD 0

.code
; Only prints sign if negative
PrintInt PROC USES EAX,
	X:DWORD

	MOV EAX, X

	CMP X, 0
	JL PrintSigned

PrintUnsigned:
	CALL WriteDec
	JMP EndPrint
PrintSigned:
	CALL WriteInt
EndPrint:

	RET
PrintInt ENDP

; Print char parameter instead of changing EAX... Still modifies EAX somehow anyways.
PrintChar PROC,
	X:BYTE

	PUSHAD
	MOV AL, X
	CALL WriteChar
	POPAD

	RET
PrintChar ENDP


; Add numbers, store in EAX
AddNum PROC
	PUSH EBP
	MOV EBP, ESP

	MOV EBX, [EBP + 12]
	ADD EBX, [EBP + 8]

	JO AdditionOverflow
	JMP ReturnAddition

AdditionOverflow:
	MOV EDX, OFFSET OverflowError
	CALL WriteString

ReturnAddition:
	POP EBP
	MOV EAX, EBX
	RET
AddNum ENDP


; Subtract numbers, store in EAX
SubtractNum PROC,
	X:DWORD, Y:DWORD

	MOV EBX, X
	SUB EBX, Y

	JO SubtractionOverflow
	JMP ReturnSubtraction

SubtractionOverflow:
	MOV EDX, OFFSET OverflowError
	CALL WriteString
ReturnSubtraction:

	MOV EAX, EBX
	RET
SubtractNum ENDP


; Multiply numbers, store in EAX
MultiplyNum PROC,
	X:DWORD, Y:DWORD

	MOV EAX, X
	CDQ
	IMUL EAX, Y

	JO MultiplicationOverflow
	JMP ReturnMultiplication

MultiplicationOverflow:
	MOV ECX, EAX
	MOV EDX, OFFSET OverflowError
	CALL WriteString
	MOV EAX, ECX
	
ReturnMultiplication:
	RET

MultiplyNum ENDP


; Divide numbers, store in EAX
DivideNum PROC,
	X:DWORD, Y:DWORD
	
	MOV EAX, X

	CDQ	; reduce probablity of overflow
	CMP Y, 0; Checks for Zero
	JE ZeroDivision

	IDIV Y

	JMP ReturnSubtraction ; No Zero

	;If the User divides by 0
ZeroDivision:
	MOV ECX, EAX
	MOV EDX, OFFSET DivideZeroError
	CALL WriteString
	MOV EAX, ECX

ReturnSubtraction:
	RET
DivideNum ENDP


; Multiply numbers, store in EAX
ExponentNum PROC,
	X:DWORD, Y:DWORD

	MOV EAX, 1
	MOV ECX, Y

	; Repeat multiplication
LoopExp:
	IMUL EAX, X
	JO ExponentOverflow	
	LOOP LoopExp

	JMP ReturnExponent

ExponentOverflow:
	MOV EBX, EAX
	MOV EDX, OFFSET OverflowError
	CALL WriteInt
	MOV EAX, EBX

ReturnExponent:
	RET
ExponentNum ENDP


main PROC
	; Ask for desired operation
ProgramStart:
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

	; If program reached this point then an invalid operator has been selected
	MOV EDX, OFFSET OperationInvalidError
	CALL WriteString
	MOV AL, Operation
	CALL WriteChar
	CALL Crlf
	CALL Crlf
	JMP ProgramStart ; HANDLE USER ERROR: Operation invalid

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
	; Store result in Result
	MOV Result, EAX

	; Store calculation memory
	MOV EBX, MemIndex

	MOV [CalcMemory + EBX * DWORD], EAX

	INC EBX
	MOV MemIndex, EBX

	; Print calculation
	INVOKE PrintInt, NumOne
	INVOKE PrintChar, CharSpace
	INVOKE PrintChar, Operation
	INVOKE PrintChar, CharSpace
	INVOKE PrintInt, NumTwo
	INVOKE PrintChar, CharSpace
	INVOKE PrintChar, CharEqual
	INVOKE PrintChar, CharSpace
	INVOKE PrintInt, Result
	CALL Crlf
	CALL Crlf

	; Loop through and display calculation memory
	MOV EBX, 0 ; CalcMemory Iterator
	MOV ECX, MemIndex
DisplayMemory:
	MOV ESI, [CalcMemory + EBX * DWORD]
	INVOKE PrintInt, ESI
	INVOKE PrintChar, CharSpace

	INC EBX
	LOOP DisplayMemory

	CALL Crlf

	; Begin another calculation
	JMP ProgramStart

	exit
main ENDP
END main