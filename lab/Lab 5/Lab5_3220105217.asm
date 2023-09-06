        .ORIG x3000
        LD R6, STACK; R6 is the stack pointer
        AND R2, R2, #0; initialize R0 to 0
        LD R0, CHE; R0 points to each point in the skiing field
        LDI R4, INI1; R4 contains n
        LDI R5, INI0; R5 contains m
        AND R3, R3, #0
TOT     ADD R3, R3, R4
        ADD R5, R5, #-1
        BRp TOT; R3 contains the quantity of points
        LD R4, INI1
        ADD R3, R3, R4; R3 points to the last point
        NOT R3, R3
        ADD R3, R3, #1; inverse
LOOP    AND R5, R5, #0; initialize R5 to 0
        JSR FIND
        ADD R0, R0, #1
        ADD R4, R3, R0
        BRnz LOOP
        HALT

        
FIND    ADD R6, R6, #-1
        STR R3, R6, #0; PUSH R3
        ADD R6, R6, #-1
        STR R7, R6, #0; PUSH R7
        ADD R6, R6, #-1
        STR R4, R6, #0; PUSH R4
        ADD R6, R6, #-1
        STR R1, R6, #0; PUSH R1
        ADD R6, R6, #-1
        STR R5, R6, #0; PUSH R5
        ADD R6, R6, #-1
        STR R2, R6, #0; PUSH R2
        ADD R5, R5, #1
        LDR R1, R0, #0; R1 gets the altitude of the point
        LDI R3, INI1
        NOT R3, R3
        ADD R3, R3, #1; inverse of N
        LD R4, CHE
        ADD R3, R3, R0; R3 points to the previous row 
        NOT R4, R4
        ADD R4, R4, #1; inverse of x4002
        ADD R4, R4, R3
        BRn DOWN; in the first row
        LDR R4, R3, #0; R4 gets the altitude of previous row
        NOT R4, R4
        ADD R4, R4, #1; inverse
        ADD R4, R4, R1
        BRnz DOWN; if the upper point is not lower
        LDR R2, R6, #0; POP R2
        STR R0, R6, #0; PUSH R0
        ADD R0, R3, #0
        JSR FIND
        LDR R0, R6, #0; POP R0
        STR R2, R6, #0; PUSH R2
        
DOWN    LDI R4, INI1; R4 gets the value of N
        LDI R2, INI0; R2 gets the value of M
        AND R3, R3, #0
MUL     ADD R3, R4, R3
        ADD R2, R2, #-1
        BRp MUL; R3 gets the value of N*M
        LDI R4, INI1
        ADD R4, R4, R0; R4 points to the point next row
        LD R2, INI1
        ADD R3, R2, R3; R3 points to the last point
        NOT R3, R3
        ADD R3, R3, #1
        ADD R3, R3, R4
        BRp LEFT; if the point is in the last row
        LDR R3, R4, #0; R3 gets the altitude of R4
        NOT R3, R3
        ADD R3, R3, #1; inverse
        ADD R3, R3, R1
        BRnz LEFT
        LDR R2, R6, #0; POP R2
        STR R0, R6, #0; PUSH R0
        ADD R0, R4, #0
        JSR FIND
        LDR R0, R6, #0; POP R0
        STR R2, R6, #0; PUSH R2
        
LEFT    LDI R4, INI1; R4 gets the value of N
        NOT R4, R4
        ADD R4, R4, #1; inverse
        LD R3, CHE; R3 points to the first point
        NOT R3, R3
        ADD R3, R3, #1; inverse
        ADD R2, R0, #0
        ADD R2, R2, R3
MIN     BRz RIGHT; if the point is on the far left
        BRn DONEL
        ADD R2, R2, R4
        BR MIN
DONEL   ADD R3, R0, #-1; R3 points to the point left
        LDR R4, R3, #0; R4 contains the altitude of R3
        NOT R4, R4
        ADD R4, R4, #1
        ADD R4, R4, R1
        BRnz RIGHT
        LDR R2, R6, #0; POP R2
        STR R0, R6, #0; PUSH R0
        ADD R0, R3, #0
        JSR FIND
        LDR R0, R6, #0; POP R0
        STR R2, R6, #0; PUSH R2
        
RIGHT   LDI R4, INI1; R4 gets the value of N
        LDI R2, INI0; R2 gets the value of M
        AND R3, R3, #0
MULR    ADD R3, R3, R4
        ADD R2, R2, #-1
        BRp MULR; R3 contains the quantity of points
        LD R2, INI1
        ADD R3, R2, R3; R3 points to the last point
        NOT R3, R3
        ADD R3, R3, #1; inverse
        ADD R2, R3, R0
PLU     BRz OVER; if the point is on the far right
        BRp DONER
        ADD R2, R2, R4
        BR PLU
DONER   ADD R3, R0, #1; R3 points to the point right
        LDR R4, R3, #0; R4 contians the altitude of R3
        NOT R4, R4
        ADD R4, R4, #1
        ADD R4, R4, R1
        BRnz OVER
        LDR R2, R6, #0; POP R2
        STR R0, R6, #0; PUSH R0
        ADD R0, R3, #0
        JSR FIND
        LDR R0, R6, #0; POP R0
        STR R2, R6, #0; PUSH R2
        
OVER    LDR R2, R6, #0
        ADD R6, R6, #1; POP R2
        NOT R3, R5
        ADD R3, R3, #1
        ADD R3, R3, R2
        BRzp OVE; not larger than original R2
        ADD R2, R5, #0
OVE     
        LDR R5, R6, #0
        ADD R6, R6, #1; POP R5
        LDR R1, R6, #0
        ADD R6, R6, #1; POP R1
        LDR R4, R6, #0
        ADD R6, R6, #1; POP R4
        LDR R7, R6, #0
        ADD R6, R6, #1; POP R7
        LDR R3, R6, #0
        ADD R6, R6, #1; POP R3
        RET
        
        
INI1    .FILL x4001; N
INI0    .FILL x4000; M
CHE     .FILL x4002
STACK   .FILL xFE00
        .END

.ORIG x4000
.FILL #3 ; N
.FILL #4 ; M
.FILL #89 ; the map 
.FILL #88
.FILL #86
.FILL #83
.FILL #79
.FILL #73
.FILL #90
.FILL #80
.FILL #60
.FILL #69
.FILL #73
.FILL #77
.END