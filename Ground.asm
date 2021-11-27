INCLUDE emu8086.inc

org 100h


    MAIN PROC
            
        GOTOXY 23,5 ;Move Cursor Pointer to Display Welcome message
        MOV SI, OFFSET INTROMSG ;Setting Print Message Address to the SI register
        CALL PRINT_STRING ;Printing Welcome Message by character
        GOTOXY 23,8
        CALL PTHIS
        DB "Please Enter your name:",0
        LEA DI, PLAYERNAME
        MOV DX, PLAYERNAMESIZE
        CALL GET_STRING ;Getting Player name from user
        
        GOTOXY 0,12 ; printing game rules
        LEA DX, GAMERULES1 ;Loading EA of GAMERULES variable
        MOV AH, 09H   
        INT 21H
        GOTOXY 0,13
        LEA DX, GAMERULES2 ;Loading EA of GAMERULES variable
        MOV AH, 09H   
        INT 21H
        GOTOXY 0,14
        LEA DX, GAMERULES3 ;Loading EA of GAMERULES variable
        MOV AH, 09H   
        INT 21H
        GOTOXY 0,15
        LEA DX, GAMERULES4 ;Loading EA of GAMERULES variable
        MOV AH, 09H   
        INT 21H
        
        ;ask player to start the game
        GOTOXY 15,20
        LEA DX, MENUINPUT ;Loading EA of GAMERULES variable
        MOV AH, 09H   
        INT 21H
        
        isSTART:    
            MOV AH, 7
            INT 21H
            CMP AL, 'Y'
            JE GAMESCREEN
            CMP AL, 'y'
            JE GAMESCREEN
            CMP AL, 'T'
            JE exitGAME
            CMP AL, 't'
            JE exitGAME
            JMP isSTART
        
        
         
         
        GAMESCREEN: 
            CALL CLEAR_SCREEN ;clear the menu screen on game start
            
            ; Player statistics like name and score
            GOTOXY 0,0
            CALL PTHIS
            DB "Player:",0
            GOTOXY 8,0            
            LEA SI, PLAYERNAME
            CALL PRINT_STRING 
                 
            GOTOXY 0,20 ;Moving Cursor Pointer to the ground location
            LEA DX, GROUND ;Loading EA of Ground variable
            MOV AH, 09H   
            INT 21H ;Print the ground string at once
            
            
            
            CALL DRAWPLAYER
            
            gameLOOP:
            
                ;Check function for player death
                CALL DEATH
                
                ;call gravity function so player falls back down after jumping
                CALL GRAVITY
                MOV AL, GROUNDHEIGHT
                CMP ROW, AL
                JNE setJUMP
                MOV ISJUMP, 'F'
                returnJump:           
                
                ;get user char input
                MOV AH, 6
                MOV DL, 255
                INT 21H
                
                ;game termination if input is "X"
                CMP AL, "X"
                JE exitGAME
                CMP AL, "x"
                JE exitGAME
                
                ;movement of player
                CMP AL, "W"
                JE jumpUP
                CMP AL, "A"
                JE moveLEFT
                CMP AL, "D"
                JE moveRIGHT
                CMP AL, "w"
                JE jumpUP
                CMP AL, "a"
                JE moveLEFT
                CMP AL, "d"
                JE moveRIGHT
                 
            JMP gameLOOP
                
                 
            
            ;label too exit game
            exitGAME:
                MOV AH, 0
                INT 21H
            
            ;label to make player jump
            jumpUP:
                CMP ISJUMP, 'T'
                JE skipJUMP 
                CALL UPDATEPLAYER
                DEC ROW
                DEC ROW
                DEC ROW 
                CALL DRAWPLAYER
                skipJUMP:
                MOV AH, 0CH
                INT 21H
                JMP gameLOOP
            ;label to make player move left and right
            moveLEFT:
                CALL UPDATEPLAYER
                DEC COL
                CALL DRAWPLAYER
                MOV AH, 0CH
                INT 21H
                JMP gameLOOP
            moveRIGHT:
                CALL UPDATEPLAYER
                INC COL
                CALL DRAWPLAYER
                MOV AH, 0CH
                INT 21H
                JMP gameLOOP
                
            setJUMP:
                MOV ISJUMP, 'T'
                JMP returnJUMP 
                
                                       
        RET
    MAIN ENDP
    
    
    DRAWPLAYER PROC ;this procedure draws the player on the ground at (COL,ROW)
       GOTOXY COL,ROW
       ;MOV AH, 2
       ;MOV DL, 'X'
       ;INT 21H
       MOV AH, 09H
       MOV AL, 'X'
       MOV BL, 1110b 
       MOV CX, 1
       INT 10H
       RET     
    DRAWPLAYER ENDP
    
    UPDATEPLAYER PROC ;this procedure updates previous player position with a blank character
       GOTOXY COL,ROW 
       PUTC " "   
       RET         
    UPDATEPLAYER ENDP
    
    GRAVITY PROC ;this procedure is used to apply gravity if the player is in the air or above ground
        MOV AL, GROUNDHEIGHT
        CMP ROW, AL ;this compare checks if the current row position is Not equal to ground level
        JE skipGRAVITY
        CALL UPDATEPLAYER
        INC ROW
        CALL DRAWPLAYER        
        skipGRAVITY:
        RET     
    GRAVITY ENDP
    
    DEATH PROC
        MOV AL, ROW
        INC AL
        GOTOXY COL, AL
        MOV AH, 08H
        INT 10H
        MOV DEATHVARIABLE, AL
        CMP AL, "_"
        JE exitGAME
        RET            
    DEATH ENDP    
    
; define the VARIABLES
STATUS DB 'M'
INTROMSG DB "Welcome to PLATFORMASTER GAME", 0
PLAYERNAME DB 20 DUP(?)
PLAYERNAMESIZE DW 15 
GAMERULES1 DB "Welcome to PLATFORMASTER!$"
GAMERULES2 DB "The rules are as follows:$"
GAMERULES3 DB "Use these keys to: W (Jump), A (Move Left), D (Move Right), X (Exit).$" 
GAMERULES4 DB "Jump over the potholes to live, its gameover if you jump into a pothole$"
MENUINPUT DB "Please press 'Y' to start the game or 'T' to terminate$"
GROUND DB '===_==============_=====================_================_===================||$'
COL DB 0
ROW DB 19
GROUNDHEIGHT DB 19
ISJUMP DB 'F'
DEATHVARIABLE DB ?
INPUTCHAR DB ? 

DEFINE_PRINT_STRING
DEFINE_GET_STRING
DEFINE_PTHIS
DEFINE_CLEAR_SCREEN

END 