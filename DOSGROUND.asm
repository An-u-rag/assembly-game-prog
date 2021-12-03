STACK SEGMENT PARA STACK
    DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'

	WINDOW_WIDTH DW 13Bh   ; width of window (320 px)
	WINDOW_HEIGHT DW 0C3h  ; height of the window (200 px)

	GROUND_HEIGHT DW 06h   ; Height of ground in pixels - > 5 px
	GROUND_WIDTH DW 13Bh   ; Width of ground in pixels - > 320 px (width of screen)
	GROUND_Y DW 0AAh       ; Absolute Y pixel position of the ground -> 170 px

	DEBUG_FILE DB "debuglog.txt", 0
	DEBUG_HANDLE DW ?
	TIME_AUX DB 0          ; Previous value of 1/100 seconds to check if time has passed

	;INITIAL BALL/PLAYER VALUES
	BALL_X DW 05h 		   ; X spawn pos of the ball (col)
	BALL_Y DW 60h          ; Y spawn pos of the ball (row)
	BALL_BASE_POS DW ?     ; Position of the base of ball
	BALL_SIZE DW 06h       ; 06h -> 6x6 pixels size of the ball
	BALL_VELOCITY_X DW 04h ; the velocity of ball travelling in the horizontal component
	BALL_VELOCITY_Y DW 02h ; the velocity of ball travelling in the vertical component 
	
	BALL_JUMP_VELOCITY DW 04h ; the velocity of the jump vertically
	BALL_JUMP_HEIGHT DW 20h   ; Jump 20 pixels over time per one press
	BALL_JUMP_ROOF DW 80h     ; Dynamic roof for jumps
	BALL_JUMP_CHECK DW 00h    ; 0 - Ball is currently not going up 
							  ; 1 - Ball is currently going 

	; Player scoring variables and logic
	; Player gets 1 point for every coin he collects. Game ends when timer reaches 0 or when all coins in the level are collected
	SCOREBOARD_TEXT DB 'SCORE', '$'
	SCOREBOARD_SCORE DB '0', '$'
	PLAYER_SCORE DB 0

	; Coins for level 1
	COIN_SIZE DW 04h                  ; The size of all the coins
	COIN_HALF_SIZE DW 02h             ; The half size for easier comparison
	NO_OF_COINS DW 01h 				  ; The number of coins in total

		; Coin 1
		COIN1_X DW 64h                 ; X and Y coordinates of the coin position
		COIN1_Y DW 9Ah
		COIN1_COLLECTED_CHECK DW 00h    ; When player collects this coin, the check becomes 1 and turns off its pixels 

		; Coin 2
		COIN2_X DW 73h                 ; X and Y coordinates of the coin position
		COIN2_Y DW 8Eh
		COIN2_COLLECTED_CHECK DW 00h    ; When player collects this coin, the check becomes 1 and turns off its pixels 

		; Coin 3
		COIN3_X DW 83h                 ; X and Y coordinates of the coin position
		COIN3_Y DW 84h
		COIN3_COLLECTED_CHECK DW 00h    ; When player collects this coin, the check becomes 1 and turns off its pixels 

		; Coin 4
		COIN4_X DW 74h                 ; X and Y coordinates of the coin position
		COIN4_Y DW 75h
		COIN4_COLLECTED_CHECK DW 00h    ; When player collects this coin, the check becomes 1 and turns off its pixels 

	; Platforms for level 1 -> Same height as ground
	PLATFORM_WIDTH DW 14h      
	PLATFORM_HEIGHT DW 03h

		; Platform 1 to hold coin 1
		PLATFORM1_X DW 5Ch
		PLATFORM1_Y DW 0A0h

		; Platform 2 to hold coin 2
		PLATFORM2_X DW 6Bh
		PLATFORM2_Y DW 94h

		; Platform 3 to hold coin 3
		PLATFORM3_X DW 7Bh
		PLATFORM3_Y DW 8Ah

		; Platform 4 to hold coin 4
		PLATFORM4_X DW 6Ch
		PLATFORM4_Y DW 7Bh

DATA ENDS

CODE SEGMENT PARA 'CODE'

    MAIN PROC FAR
	ASSUME CS: CODE, DS: DATA, SS: STACK ;assume the code, data and stack segments
    PUSH DS                              ;push to the stack the DS segment
	SUB AX, AX							 ;clean the AX register
	PUSH AX								 ;push AX to the stakc
	MOV AX, DATA                         ;save on the AX register the contents of the DATA segment
	MOV DS, AX                           ;save on the DS segment the contents of AX
	POP AX                               ;release the top item from the stack to the AX reg
	POP AX                               ;release the top item from the stack to the AX reg

		;File for Debugging and status
		;MOV AH, 3Ch
		;MOV CX, 0
		;MOV DX, OFFSET DEBUG_FILE
		;INT 21h
		
		;MOV AL, 2
		;MOV DX, OFFSET DEBUG_FILE
		;MOV AH, 3Dh
		;INT 21h
		;MOV DEBUG_HANDLE, AX

		CALL SET_BACKGROUND

		CHECK_TIME_PASS:
			; get the system time
			MOV AH, 2Ch
			INT 21h ; CH = hour. CL = minute. DH = second. DL = 1/100 seconds.

		 	; check if the current time is equal to the previous time - TIME_AUX
			CMP DL, TIME_AUX
			JE CHECK_TIME_PASS  ; if time has not passed, check again. 

			; if time has passed then do the frame render
			MOV TIME_AUX, DL    ; update time

			CALL SET_BACKGROUND ; To reset the screen background to delete trails

			CALL DRAW_COIN1     ; Procedure to draw all the coins in the level

			CALL DRAW_PLATFORM1 ; Procedure to draw all the platforms in this level

			CALL DRAW_COIN2     ; Procedure to draw all the coins in the level

			CALL DRAW_PLATFORM2 ; Procedure to draw all the platforms in this level

			CALL DRAW_COIN3     ; Procedure to draw all the coins in the level

			CALL DRAW_PLATFORM3 ; Procedure to draw all the platforms in this level

			CALL DRAW_COIN4     ; Procedure to draw all the coins in the level

			CALL DRAW_PLATFORM4 ; Procedure to draw all the platforms in this level

			CALL DRAW_GROUND    ; To draw the ground

			CALL DRAW_UI        ; TO draw all UI elements like strings

			CALL DRAW_BALL      ; Draw the player ball which is controllable

			CALL BALL_GRAVITY   ; Check for gravity in every loop to pull ball to ground or continue jump if player has jumped

			CMP COIN1_COLLECTED_CHECK, 00h
			JE CHECK_COIN1
			AFTER_COIN1_COLLIDE: 

			CMP COIN2_COLLECTED_CHECK, 00h
			JE CHECK_COIN2
			AFTER_COIN2_COLLIDE:

			CMP COIN3_COLLECTED_CHECK, 00h
			JE CHECK_COIN3
			AFTER_COIN3_COLLIDE:

			CMP COIN4_COLLECTED_CHECK, 00h
			JE CHECK_COIN4
			AFTER_COIN4_COLLIDE:

			MOV AH, 01h         ; Check for keystroke availability
			INT 16h
			JZ CHECK_TIME_PASS

			MOV AH, 00h
			INT 16h

			CMP AL, 77h         ; Check if the keystroke is "W"
			JE BALL_MOVE_JUMP

			CMP AL, 61h         ; Check if the keystoke is "A"
			JE BALL_MOVE_LEFT

			CMP AL, 64h         ; Check if the keystoke is "D"
			JE BALL_MOVE_RIGHT

			JMP CHECK_TIME_PASS ; after the frame render, check the time again.

			; Move bar up upon pressing up arrow key
			BALL_MOVE_JUMP:
				MOV AH, 0Ch
				INT 21h               ; Clear input buffer from keyboard
				
				CALL BALL_JUMP        ; Procedure to make ball jump x spaces by applying -ve velocity
				JMP CHECK_TIME_PASS
			
			BALL_MOVE_LEFT:
				MOV AH, 0Ch
				INT 21h               ; Clear input buffer from keyboard
				CALL BALL_LEFT        
				JMP CHECK_TIME_PASS 
			
			BALL_MOVE_RIGHT:
				MOV AH, 0Ch
				INT 21h               ; Clear input buffer from keyboard
				CALL BALL_RIGHT
				JMP CHECK_TIME_PASS

			CHECK_COIN1:
				CALL CHECK_COIN1_COLLIDE ; Check if the current pos of ball is colliding with coin
				JMP AFTER_COIN1_COLLIDE
			
			CHECK_COIN2:
				CALL CHECK_COIN2_COLLIDE ; Check if the current pos of ball is colliding with coin
				JMP AFTER_COIN2_COLLIDE
			
			CHECK_COIN3:
				CALL CHECK_COIN3_COLLIDE ; Check if the current pos of ball is colliding with coin
				JMP AFTER_COIN3_COLLIDE
			
			CHECK_COIN4:
				CALL CHECK_COIN4_COLLIDE ; Check if the current pos of ball is colliding with coin
				JMP AFTER_COIN4_COLLIDE

        RET
    MAIN ENDP

	; Procedure to reset screen to black background / erase the screen
	SET_BACKGROUND PROC NEAR
		; setting video mode to graphics mode
        MOV AH, 00h ; video mode for 10H interrupt
        MOV AL, 13h	; 13H is for graphics mode
        INT 10h 
		
		RET
	SET_BACKGROUND ENDP 

	; Procedure to draw the ball with custom size
	DRAW_BALL PROC NEAR

		MOV CX, BALL_X ; set the column or (x) initial postitions
		MOV DX, BALL_Y ; set the line or initial (y) position 

		DRAW_BALL_ROW_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 04h ; choose RED as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX      ; CX = CX + 1
			MOV AX, CX  ; CX - BALL_X > BALL_SIZE (YES: next row, NO: next col)
			SUB AX, BALL_X ; Get the offset of the current location from initial
			CMP AX, BALL_SIZE ; compare the offset with the ball size boundary
			JNG DRAW_BALL_ROW_VERTICALLY ; Jump to redraw on the same line if NO

			MOV CX, BALL_X ; Reset pos of the col
			INC DX ; increment the offset of the row/height
			MOV BX, DX ; Temp store for the offset for row/height
			SUB BX, BALL_Y ; Get the offset for the height or row
			CMP BX, BALL_SIZE ; Check if the vertical offset is greater that the ball size boundary
			JNG DRAW_BALL_ROW_VERTICALLY ; If no, then repeat on another row
			
			; Set the absolute value of the base of the ball everytime the ball is drawn
			MOV AX, BALL_Y
			ADD AX, BALL_SIZE
			INC AX
			MOV BALL_BASE_POS, AX 
		
		RET
	DRAW_BALL ENDP

	; Procedure to draw coin1
	DRAW_COIN1 PROC NEAR
		
		; Checking if coin has already been collected then don't draw the coin
		CMP COIN1_COLLECTED_CHECK, 00h 
		JNE EXIT_DRAW_COIN1

		MOV CX, COIN1_X ; set the column or (x) initial postitions
		MOV DX, COIN1_Y ; set the line or initial (y) position 	

		DRAW_COIN1_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Eh ; choose YELLOW as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX      ; CX = CX + 1
			MOV AX, CX  ; CX - COIN1_X > COIN_SIZE (YES: next row, NO: next col)
			SUB AX, COIN1_X ; Get the offset of the current location from initial
			CMP AX, COIN_SIZE ; compare the offset with the COIN size boundary
			JNG DRAW_COIN1_VERTICALLY ; Jump to redraw on the same line if NO

			MOV CX, COIN1_X ; Reset pos of the col
			INC DX ; increment the offset of the row/height
			MOV BX, DX ; Temp store for the offset for row/height
			SUB BX, COIN1_Y ; Get the offset for the height or row
			CMP BX, COIN_SIZE ; Check if the vertical offset is greater that the COIN size boundary
			JNG DRAW_COIN1_VERTICALLY ; If no, then repeat on another row
			
		RET

		EXIT_DRAW_COIN1:
			RET
			
	DRAW_COIN1 ENDP

	; Procedure to draw COIN2
	DRAW_COIN2 PROC NEAR
		
		; Checking if coin has already been collected then don't draw the coin
		CMP COIN2_COLLECTED_CHECK, 00h 
		JNE EXIT_DRAW_COIN2

		MOV CX, COIN2_X ; set the column or (x) initial postitions
		MOV DX, COIN2_Y ; set the line or initial (y) position 	

		DRAW_COIN2_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Eh ; choose YELLOW as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX      ; CX = CX + 1
			MOV AX, CX  ; CX - COIN2_X > COIN_SIZE (YES: next row, NO: next col)
			SUB AX, COIN2_X ; Get the offset of the current location from initial
			CMP AX, COIN_SIZE ; compare the offset with the COIN size boundary
			JNG DRAW_COIN2_VERTICALLY ; Jump to redraw on the same line if NO

			MOV CX, COIN2_X ; Reset pos of the col
			INC DX ; increment the offset of the row/height
			MOV BX, DX ; Temp store for the offset for row/height
			SUB BX, COIN2_Y ; Get the offset for the height or row
			CMP BX, COIN_SIZE ; Check if the vertical offset is greater that the COIN size boundary
			JNG DRAW_COIN2_VERTICALLY ; If no, then repeat on another row
			
		RET

		EXIT_DRAW_COIN2:
			RET
			
	DRAW_COIN2 ENDP

	; Procedure to draw COIN3
	DRAW_COIN3 PROC NEAR
		
		; Checking if coin has already been collected then don't draw the coin
		CMP COIN3_COLLECTED_CHECK, 00h 
		JNE EXIT_DRAW_COIN3

		MOV CX, COIN3_X ; set the column or (x) initial postitions
		MOV DX, COIN3_Y ; set the line or initial (y) position 	

		DRAW_COIN3_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Eh ; choose YELLOW as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX      ; CX = CX + 1
			MOV AX, CX  ; CX - COIN3_X > COIN_SIZE (YES: next row, NO: next col)
			SUB AX, COIN3_X ; Get the offset of the current location from initial
			CMP AX, COIN_SIZE ; compare the offset with the COIN size boundary
			JNG DRAW_COIN3_VERTICALLY ; Jump to redraw on the same line if NO

			MOV CX, COIN3_X ; Reset pos of the col
			INC DX ; increment the offset of the row/height
			MOV BX, DX ; Temp store for the offset for row/height
			SUB BX, COIN3_Y ; Get the offset for the height or row
			CMP BX, COIN_SIZE ; Check if the vertical offset is greater that the COIN size boundary
			JNG DRAW_COIN3_VERTICALLY ; If no, then repeat on another row
			
		RET

		EXIT_DRAW_COIN3:
			RET
			
	DRAW_COIN3 ENDP

	; Procedure to draw COIN4
	DRAW_COIN4 PROC NEAR
		
		; Checking if coin has already been collected then don't draw the coin
		CMP COIN4_COLLECTED_CHECK, 00h 
		JNE EXIT_DRAW_COIN4

		MOV CX, COIN4_X ; set the column or (x) initial postitions
		MOV DX, COIN4_Y ; set the line or initial (y) position 	

		DRAW_COIN4_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Eh ; choose YELLOW as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX      ; CX = CX + 1
			MOV AX, CX  ; CX - COIN4_X > COIN_SIZE (YES: next row, NO: next col)
			SUB AX, COIN4_X ; Get the offset of the current location from initial
			CMP AX, COIN_SIZE ; compare the offset with the COIN size boundary
			JNG DRAW_COIN4_VERTICALLY ; Jump to redraw on the same line if NO

			MOV CX, COIN4_X ; Reset pos of the col
			INC DX ; increment the offset of the row/height
			MOV BX, DX ; Temp store for the offset for row/height
			SUB BX, COIN4_Y ; Get the offset for the height or row
			CMP BX, COIN_SIZE ; Check if the vertical offset is greater that the COIN size boundary
			JNG DRAW_COIN4_VERTICALLY ; If no, then repeat on another row
			
		RET

		EXIT_DRAW_COIN4:
			RET
			
	DRAW_COIN4 ENDP

	DRAW_PLATFORM1 PROC NEAR

		MOV CX, PLATFORM1_X  ; set the column to the left most column 
		MOV DX, PLATFORM1_Y  ; set the row to the absolute value of the ground initial point

		DRAW_PLATFORM1_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Dh ; choose MAGENTA as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX                           
			MOV AX, CX
			SUB AX, PLATFORM1_X
			CMP AX, PLATFORM_WIDTH
			JNG DRAW_PLATFORM1_VERTICALLY

			MOV CX, PLATFORM1_X
			INC DX
			MOV BX, DX
			SUB BX, PLATFORM1_Y
			CMP BX, PLATFORM_HEIGHT
			JNG DRAW_PLATFORM1_VERTICALLY

		RET
	DRAW_PLATFORM1 ENDP

	DRAW_PLATFORM2 PROC NEAR

		MOV CX, PLATFORM2_X  ; set the column to the left most column 
		MOV DX, PLATFORM2_Y  ; set the row to the absolute value of the ground initial point

		DRAW_PLATFORM2_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Dh ; choose MAGENTA as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX                           
			MOV AX, CX
			SUB AX, PLATFORM2_X
			CMP AX, PLATFORM_WIDTH
			JNG DRAW_PLATFORM2_VERTICALLY

			MOV CX, PLATFORM2_X
			INC DX
			MOV BX, DX
			SUB BX, PLATFORM2_Y
			CMP BX, PLATFORM_HEIGHT
			JNG DRAW_PLATFORM2_VERTICALLY

		RET
	DRAW_PLATFORM2 ENDP

	DRAW_PLATFORM3 PROC NEAR

		MOV CX, PLATFORM3_X  ; set the column to the left most column 
		MOV DX, PLATFORM3_Y  ; set the row to the absolute value of the ground initial point

		DRAW_PLATFORM3_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Dh ; choose MAGENTA as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX                           
			MOV AX, CX
			SUB AX, PLATFORM3_X
			CMP AX, PLATFORM_WIDTH
			JNG DRAW_PLATFORM3_VERTICALLY

			MOV CX, PLATFORM3_X
			INC DX
			MOV BX, DX
			SUB BX, PLATFORM3_Y
			CMP BX, PLATFORM_HEIGHT
			JNG DRAW_PLATFORM3_VERTICALLY

		RET
	DRAW_PLATFORM3 ENDP

	DRAW_PLATFORM4 PROC NEAR

		MOV CX, PLATFORM4_X  ; set the column to the left most column 
		MOV DX, PLATFORM4_Y  ; set the row to the absolute value of the ground initial point

		DRAW_PLATFORM4_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Dh ; choose MAGENTA as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX                           
			MOV AX, CX
			SUB AX, PLATFORM4_X
			CMP AX, PLATFORM_WIDTH
			JNG DRAW_PLATFORM4_VERTICALLY

			MOV CX, PLATFORM4_X
			INC DX
			MOV BX, DX
			SUB BX, PLATFORM4_Y
			CMP BX, PLATFORM_HEIGHT
			JNG DRAW_PLATFORM4_VERTICALLY

		RET
	DRAW_PLATFORM4 ENDP

	DRAW_GROUND PROC NEAR

		MOV CX, 00h       ; set the column to the left most column 
		MOV DX, GROUND_Y  ; set the row to the absolute value of the ground initial point

		DRAW_GROUND_VERTICALLY:
			MOV AH, 0Ch ; set config to write a pixel
			MOV AL, 0Bh ; choose BLUE as color
			MOV BH, 00h ; set page number
			INT 10h     ; execute the draw

			INC CX
			MOV AX, CX
			SUB AX, 00h
			CMP AX, GROUND_WIDTH
			JNG DRAW_GROUND_VERTICALLY

			MOV CX, 00h
			INC DX
			MOV BX, DX
			SUB BX, GROUND_Y
			CMP BX, GROUND_HEIGHT
			JNG DRAW_GROUND_VERTICALLY

		RET
	DRAW_GROUND ENDP

	BALL_JUMP PROC NEAR
		MOV AH, 0Dh ; set config to read a pixel
		MOV CX, BALL_X ; Set Column
		MOV BX, BALL_BASE_POS
		MOV DX, BX ; set Row = BALL_BASE_POS + 1 px
		INT 10h     ; execute the read
		CMP AL, 0Bh ; check if the color of the collision pixel is LIGHT CYAN (GROUND)
		JE APPLY_JUMP
		CMP AL, 0Dh
		JE APPLY_JUMP
		RET

		APPLY_JUMP: ; jump if the ball is on the ground
			MOV BALL_JUMP_CHECK, 01h ; Ball going up
			MOV AX, BALL_JUMP_VELOCITY
			SUB BALL_Y, AX

		RET
	BALL_JUMP ENDP

	BALL_LEFT PROC NEAR

		MOV AX, BALL_VELOCITY_X
		SUB BALL_X, AX 

		RET
	BALL_LEFT ENDP

	BALL_RIGHT PROC NEAR

		MOV AX, BALL_VELOCITY_X
		ADD BALL_X, AX 
		
		RET
	BALL_RIGHT ENDP

	BALL_GRAVITY PROC NEAR

		;MOV AX, BALL_Y
		;ADD AX, BALL_SIZE
		;CMP AX, GROUND_Y             ; Check if ball is above ground : if yes -> pull ball down
		;JL APPLY_GRAVITY
		;RET

		; Check collision with pixels
		; check for base collision with ground
		MOV AH, 0Dh ; set config to read a pixel
		MOV CX, BALL_X ; Set Column
		MOV BX, BALL_BASE_POS
		MOV DX, BX ; set Row = BALL_BASE_POS + 1 px
		INT 10h     ; execute the read
		CMP AL, 0Bh ; check if the color of the collision pixel is LIGHT CYAN (GROUND)
		JE EXIT_GRAVITY


		APPLY_GRAVITY:               ; check if the ball has jumped
			CMP BALL_JUMP_CHECK, 00h
			JE CONTINUE_GRAVITY
			MOV BX, BALL_JUMP_VELOCITY
			SUB BALL_Y, BX

			MOV BX, BALL_JUMP_ROOF
			CMP BX, BALL_Y
			JGE REVERSE_DIRECTION
			RET

			REVERSE_DIRECTION:
				MOV BALL_JUMP_CHECK, 00h
				RET

			CONTINUE_GRAVITY:  ;Apply downward velocity to the ball by adding the gravity
				CMP AL, 0Dh
				JE EXIT_GRAVITY
				MOV AX, BALL_VELOCITY_Y
				ADD BALL_Y, AX           ; Y POS = Y POS + BALL_VELOCITY_X (GRAVITY)
			
		RET

		EXIT_GRAVITY:
			MOV AX, BALL_BASE_POS
			SUB AX, BALL_JUMP_HEIGHT
			MOV BALL_JUMP_ROOF, AX
			RET
	BALL_GRAVITY ENDP

	DRAW_UI PROC NEAR
		; Draw the score counter
		; Set the cursor position
		MOV AH, 02h
		MOV BH, 00h
		MOV DH, 00h
		MOV DL, 00h
		INT 10h

		;Print the number using INT 21h
		MOV AH, 09h
		LEA DX, SCOREBOARD_TEXT
		INT 21h

		;Print the number using INT 21h
		MOV AH, 09h
		LEA DX, SCOREBOARD_SCORE
		INT 21h
 
	DRAW_UI ENDP

	CHECK_COIN1_COLLIDE PROC NEAR
	; Check if the pixel around the coin is blue in color (ball)
	; check in 1 pixel border of the coin on the left, right and top.
	; If yes -> Ball has collided with the coin -> make the coin dissapear -> COIN1_COLLECTED_CHECK = 01h
	; If no -> Continue to draw the ball

		MOV CX, COIN1_X ; set Row
		SUB CX, COIN_HALF_SIZE
		MOV DX, COIN1_Y; set Column
		ADD DX, COIN_HALF_SIZE
		MOV BH, 00h ; page number
		MOV AH, 0Dh
		INT 10h

		CMP AL, 04h
		JE SET_COLLECTED_COIN1

		RET
		SET_COLLECTED_COIN1:
			MOV COIN1_COLLECTED_CHECK, 01h
			INC PLAYER_SCORE
			XOR AX, AX
			MOV AL, PLAYER_SCORE
			ADD AL, 30h              
			MOV [SCOREBOARD_SCORE], AL
		RET

		EXIT_COIN1_COLLIDE:
			RET
	CHECK_COIN1_COLLIDE ENDP

	CHECK_COIN2_COLLIDE PROC NEAR
	; Check if the pixel around the coin is blue in color (ball)
	; check in 1 pixel border of the coin on the left, right and top.
	; If yes -> Ball has collided with the coin -> make the coin dissapear -> COIN2_COLLECTED_CHECK = 01h
	; If no -> Continue to draw the ball

		MOV CX, COIN2_X ; set Row
		SUB CX, COIN_HALF_SIZE
		MOV DX, COIN2_Y; set Column
		ADD DX, COIN_HALF_SIZE
		MOV BH, 00h ; page number
		MOV AH, 0Dh
		INT 10h

		CMP AL, 04h
		JE SET_COLLECTED_COIN2

		RET
		SET_COLLECTED_COIN2:
			MOV COIN2_COLLECTED_CHECK, 01h
			INC PLAYER_SCORE
			XOR AX, AX
			MOV AL, PLAYER_SCORE
			ADD AL, 30h              
			MOV [SCOREBOARD_SCORE], AL
		RET

		EXIT_COIN2_COLLIDE:
			RET
	CHECK_COIN2_COLLIDE ENDP

	CHECK_COIN3_COLLIDE PROC NEAR
	; Check if the pixel around the coin is blue in color (ball)
	; check in 1 pixel border of the coin on the left, right and top.
	; If yes -> Ball has collided with the coin -> make the coin dissapear -> COIN3_COLLECTED_CHECK = 01h
	; If no -> Continue to draw the ball

		MOV CX, COIN3_X ; set Row
		SUB CX, COIN_HALF_SIZE
		MOV DX, COIN3_Y; set Column
		ADD DX, COIN_HALF_SIZE
		MOV BH, 00h ; page number
		MOV AH, 0Dh
		INT 10h

		CMP AL, 04h
		JE SET_COLLECTED_COIN3

		RET
		SET_COLLECTED_COIN3:
			MOV COIN3_COLLECTED_CHECK, 01h
			INC PLAYER_SCORE
			XOR AX, AX
			MOV AL, PLAYER_SCORE
			ADD AL, 30h              
			MOV [SCOREBOARD_SCORE], AL
		RET

		EXIT_COIN3_COLLIDE:
			RET
	CHECK_COIN3_COLLIDE ENDP

	CHECK_COIN4_COLLIDE PROC NEAR
	; Check if the pixel around the coin is blue in color (ball)
	; check in 1 pixel border of the coin on the left, right and top.
	; If yes -> Ball has collided with the coin -> make the coin dissapear -> COIN4_COLLECTED_CHECK = 01h
	; If no -> Continue to draw the ball

		MOV CX, COIN4_X ; set Row
		SUB CX, COIN_HALF_SIZE
		MOV DX, COIN4_Y; set Column
		ADD DX, COIN_HALF_SIZE
		MOV BH, 00h ; page number
		MOV AH, 0Dh
		INT 10h

		CMP AL, 04h
		JE SET_COLLECTED_COIN4

		RET
		SET_COLLECTED_COIN4:
			MOV COIN4_COLLECTED_CHECK, 01h
			INC PLAYER_SCORE
			XOR AX, AX
			MOV AL, PLAYER_SCORE
			ADD AL, 30h              
			MOV [SCOREBOARD_SCORE], AL
		RET

		EXIT_COIN4_COLLIDE:
			RET
	CHECK_COIN4_COLLIDE ENDP

CODE ENDS
END