        .ORIG x3000
        LEA R6, earray; R6 contains the Front pointer
        ADD R7, R6, #0; R7 contains the Rear pointer
        LEA R3, save; R3 points to the save

ldp     TRAP x20; load the new character into R0
        TRAP x21
        ADD R0, R0, #0
        BRz ending; check whether the string is over
        AND R1, R1, #0
        ADD R1, R1, #-16
        ADD R1, R1, #-16
        ADD R1, R1, #-11; R1 = -43
        ADD R2, R1, R0; judge whether the character is "+"
        BRz pul
        ADD R1, R1, #-2; R1 = -45
        ADD R2, R1, R0; judge whether the character is "-"
        BRz pol
        ADD R1, R1, #-16
        ADD R1, R1, #-16
        ADD R1, R1, #-14; R1 = -91
        ADD R2, R1, R0; judge whether the character is "["
        BRz pur
        ADD R1, R1, #-2; R1 = -93
        ADD R2, R1, R0; judge whther the character is "]"
        BRz por
        BR ending
        
pul     TRAP x20; load the letter to be pushed
        TRAP x21
        STR R0, R6, #0; store the input value into the deque
        ADD R6, R6, #-1; the Front pointer move one to the left
        BR ldp
        
pol     NOT R1, R6
        ADD R1, R1, #1; get the inverse of R6
        ADD R1, R1, R7
        BRz EM; check if the deque is empty
        ADD R6, R6, #1; carry out the pop operation
        LDR R0, R6, #0; R0 get the value poped
        STR R0, R3 ,#0
        ADD R3, R3, #1
        BR ldp
        
pur     TRAP x20; load the letter to be pushed
        TRAP x21
        ADD R7, R7, #1; the Rear pointer move one to the right
        STR R0, R7, #0; store the input value into the deque
        BR ldp
        
por     NOT R1, R6
        ADD R1, R1, #1; get the inverse of R7
        ADD R1, R1, R7
        BRz EM; check if the deque is empty
        LDR R0, R7, #0; R0 get the value to be poped
        ADD R7, R7, #-1; carry out the pop operation
        STR R0, R3, #0
        ADD R3, R3, #1
        BR ldp
        
ending  LDR R4, R3, #0
        AND R4, R4, #0
        STR R4, R3, #0
        LEA R0, save
        TRAP x22
        TRAP x25
        
EM      AND R0, R0, #0
        ADD R0, R0, #15
        ADD R0, R0, #15
        ADD R0, R0, #15
        ADD R0, R0, #15
        ADD R0, R0, #15
        ADD R0, R0, #15
        ADD R0, R0, #5; R0 = 95
        STR R0, R3, #0
        ADD R3, R3, #1
        BR ldp
        
        .BLKW 50
earray  .FILL #0
        .BLKW 50
save    .BLKW 100
        .END