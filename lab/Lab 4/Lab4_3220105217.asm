            .ORIG x200
            LD R6, OS_SP
            LD R0, USER_PSR
            ADD R6, R6, #-1
            STR R0, R6, #0
            LD R0, USER_PC
            ADD R6, R6, #-1
            STR R0, R6, #0
            LD R0, INKB; x0180
            LD R1, KBI; the start address of keyboard interrupt program is x2000
            STR R1, R0, #0; modify the value at the x0180 address to the start address of keyboard interrupt program
            LD R0, KBSR
            LD R1, ADDE
            STR R1, R0, #0; set the value of KBSR [14] to 1
            RTI
INKB        .FILL x0180
KBI         .FILL x2000
OS_SP       .FILL x3000
USER_PSR    .FILL x8002
USER_PC     .FILL x3000
KBSR        .FILL xFE00
ADDE        .FILL x4000
            .END
            
            .ORIG x2000
            ST R0, SAVE0
            ST R1, SAVE1
            LDI R0, KBDR; R0 get the input ASCII code
            LD R1, CHE
            ADD R1, R1, R0; check whether the input character is number or letter
            BRn NNUM; if it's a number
            STI R0, LET; LET contains the letter to become
            BR ENDI
NNUM        LD R1, NUM
            ADD R0, R0, R1
            LDI R1, HEIG
            ADD R0, R1, R0; R0 contains the height plus 1 after the number's input
            LD R1, MAX
            ADD R1, R1, R0; check whether it's too high
            BRp LIM
            STI R0, HEIG
ENDI        LD R0, SAVE0
            LD R1, SAVE1
            RTI
LIM         LD R0, MAXI
            STI R0, HEIG
            BR ENDI
KBDR        .FILL xFE02
CHE         .FILL #-58
NUM         .FILL #-47
MAX         .FILL #-18
MAXI        .FILL #18
LET         .FILL x5000
HEIG        .FILL x5001
SAVE0       .FILL #0
SAVE1       .FILL #0
            .END
            
            .ORIG x3000
            LD R0, ORI
            STI R0, HEIG1
            LD R0, LA
            STI R0, LET1
LOOPP       LDI R1, HEIG1
            ADD R1, R1, #-1; R1 contains the number of the air under the bird
            BRn INI
BA          STI R1, HEIG1
            NOT R2, R1
            ADD R2, R2, #1
            LD R3, CAIR
            ADD R3, R3, R2; R3 contains the number of the air above the bird
            LD R0, AIR
            ADD R1, R1, #0
AIR1        BRz BIRD
            OUT
            ADD R1, R1, #-1
            BR AIR1
BIRD        LDI R0, LET1
            OUT
            OUT
            OUT
            LD R0, AIR
            ADD R3, R3, #0
AIR2        BRz OVER
            OUT
            ADD R3, R3, #-1
            BR AIR2
OVER        LD R0, LF
            OUT
            JSR DELAY
            BR LOOPP
            
INI         AND R1, R1, #0
            BR BA

DELAY       ST R1, SAVER1 
            LD R1, COUNT 
LOOP        ADD R1, R1, #-1 
            BRnp LOOP
            LD R1, SAVER1 
            RET
COUNT       .FILL #10000
SAVER1      .BLKW #1            
LET1        .FILL x5000
HEIG1       .FILL x5001
ORI         .FILL #18
LA          .FILL #97; "a"
CAIR        .FILL #17
AIR         .FILL #46; "."
LF          .FILL #10; "LF"
            .END