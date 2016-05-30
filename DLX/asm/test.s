main:	    addui r1, r0, 1     ; r1: Konstante 1             00000000 24010001
            lw    r2, N(r0)     ; r2: N                       00000004 8c0200a0

            sb    1(r2), r0     ; A[1] = 0                    00000010 a0600001

            trap  0             ;                             0000009c 44000000
            
N:	    .word   100         ;                             000000a0 00000064
            .align  10

