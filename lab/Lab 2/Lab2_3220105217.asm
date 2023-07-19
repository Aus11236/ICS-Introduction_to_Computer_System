        .ORIG x3000
        LD R0, str1; load the first string into R0
        LD R1, str2; load the first string into R1
        LEA R2, array; pointer to the frequency array

        ; initialize the frequency array to 0
        AND R4, R4, #0
        ADD R4, R4, #11
        ADD R4, R4, #15
loop0   LDR R3, R2, #0
        AND R3, R3, #0
        STR R3, R2, #0
        ADD R2, R2, #1
        ADD R4, R4, #-1
        BRnp loop0
        AND R3, R3, #0
        ADD R3, R3, #1; initialize the character counter R3 to 0
        LEA R2, array; initialize the array pointer R2

        LDR R4, R0, #0; R4 points to the first character
        LDR R6, R4, #0; loop through each character of the first string and update the frequency array
loop1   ADD R5, R6, #-16
        ADD R5, R5, #-16
        BRz SKIP1; judge whether it's a space
        ADD R3, R3, #1; count the number of the first string
        ADD R5, R5, #-16
        ADD R5, R5, #-16
        ADD R5, R5, #-16
        ADD R5, R5, #-16
        BRn SKIP01
        ADD R6, R6, #-16
        ADD R6, R6, #-16; convert the character to uppercase
SKIP01  AND R5, R5, #0
        ADD R5, R5, #15
        ADD R5, R5, #15
        ADD R5, R5, #1
        AND R5, R6, R5 
        ADD R5, R5, #-1; convert the character to a 0-25 index, save it in R6
        ADD R5, R5, R2; R5 contains the address of the current element in the frequency array
        LDR R7, R5, #0; R7 contains the current frequency count
        ADD R7, R7, #1; increment the frequency count
        STR R7, R5, #0; store the updated frequency count back to the frequency array
SKIP1   ADD R4, R4, #1; move to the next character
        LDR R6, R4, #0
        BRz loop2; if we reached the end of the first string, then we move to the second
        BR loop1; otherwise, we continue the iteration

        LDR R4, R1, #0; R4 points to the first character
        LDR R6, R4, #0; loop through each character of the second string and update the frequency array
loop2   ADD R5, R6, #-16
        ADD R5, R5, #-16
        BRz SKIP2; judge whether it's a space
        ADD R3, R3, #-1; count the number of the second string
        ADD R5, R5, #-16
        ADD R5, R5, #-16
        ADD R5, R5, #-16
        ADD R5, R5, #-16
        BRn SKIP02
        ADD R6, R6, #-16
        ADD R6, R6, #-16; convert the character to uppercase
SKIP02  AND R5, R5, #0
        ADD R5, R5, #15
        ADD R5, R5, #15
        ADD R5, R5, #1
        AND R5, R6, R5
        ADD R5, R5, #-1; convert the character to a 0-25 index
        ADD R5, R5, R2; R5 contains the address of the current element in the frequency array
        LDR R7, R5, #0; R7 contains the current frequency count
        ADD R7, R7, #-1; decrement the frequency count
        STR R7, R5, #0; store the updated frequency count back to the frequency array
SKIP2   ADD R4, R4, #1; move to the next character
        LDR R6, R4, #0; R6 contains the next character
        BRz CHECK; if we've reached the end of the second string, check if all frequency counts in the array are zero
        BR loop2
        
CHECK   AND R4, R4, #0; R4 is the sum of the array
        AND R5, R5, #0
        ADD R5, R5, #15
        ADD R5, R5, #11
; check if the frequency array is all 0
loop3   LDR R6, R2, #0
        ADD R4, R4, R6
        ADD R2, R2, #1
        ADD R5, R5, #-1
        BRp loop3
CHECK2  ADD R4, R4, #0
        BRnp NO
; check if the character counter is 0
        ADD R3, R3, #0
        BRnp NO
; now we output yes
        LEA R0, yes
        TRAP x22
        BR a
NO      LEA R0, no1
        TRAP x22
a       TRAP x25
yes     .STRINGZ "YES\n"
no1     .STRINGZ "NO\n"
str1    .FILL x4000
str2    .FILL x4001
array   .BLKW 26
        .END


