STACK SEGMENT PARA STACK
    DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
    
DATA ENDS

CODE SEGMENT PARA 'CODE'

    MAIN PROC FAR
        
		; setting video mode to graphics mode
        MOV AH, 00h ; video mode for 10H interrupt
        MOV AL, 13h	; 13H is for graphics mode
        INT 10h 
		
		; set background color
		MOV AH, 0Bh ; set configuration
		MOV BH, 00h ; to the background color
		MOV BL, 00h ; setting the color attribute to light  cyan 
        INT 10h
		
		; write a pixel
		MOV AH, 0Ch ; set config to write a pixel
		MOV AL, 0Bh ; choose white as color
		MOV BH, 00h ; set page number
		MOV CX, 25 ; set the column or x postitions
		MOV DX, 25 ; set the line or y position 
		INT 10h
		
        RET
    MAIN ENDP

CODE ENDS
END