main:	    addui r1, r0, 1     ; r1: Konstante 1             00000000 24010001
            lw    r2, N(r0)     ; r2: N                       00000004 8c02009c
            addui r3, r0, A     ; r3: Adresse von A]0]        00000008 24030400
            addui r5, r0, (A+2) ; r5: Basisadresse von A[2]   0000000c 24050402


; Initialisierungsschleife
; ========================
;  for( a[1]=0, i=2; i<= N; i++ ) 
;    a[i] = 1;  

            addui r4, r0, 3     ; r4: i = 3                   00000010 24040003
            sb    1(r3), r0     ; A[1] = 0                    00000014 a0600001
init_loop:  sb    0(r5), r1     ; A[i] = 1                    00000018 a0a10000
            sle   r6, r4, r2    ; r6: i <= N ?                0000001c 0082302c
            addu  r5, r3, r4    ; r5 : Adresse von A[i]       00000020 00642821
            addui r4, r4, 1     ; i++                         00000024 24840001
            bnez  r6, init_loop ; if r6 == 1  loop init_loop  00000028 14c0ffec
            nop                 ;                             0000002c 0000003f
                                                                
                                                                
; Hauptschleife                                                 
; =============                                                 
; for( i=2; i<=N/2; i++ )                                       
;   for( j=i+i; j<=N; j+=i )                                    
;     a[j] = 0;

            addui r7, r0, (A+4) ; r7: Basisadresse von A[4]   00000030 24070404
            addui r6, r0, 4     ; r6: j = 4 (= 2*i)           00000034 24060004
            addui r4, r0, 2     ; r4: i = 2                   00000038 24040002
            srai  r5, r2, 1     ; r5: N/2                     0000003c 5c450001
inner:      sb    0(r7), r0     ; A[j] = 0                    00000040 a0e00000
            sle   r8, r6, r2    ; r8: j <= N ?                00000044 00c2402c
            addu  r7, r3, r6    ; r7 : Adresse von A[j]       00000048 00663821
            addu  r6, r6, r4    ; j = j + i                   0000004c 00c43021
            bnez  r8, inner     ; if r8 == 1 loop inner       00000050 1500ffec
            nop                 ;                             00000054 0000003f
            addui r4, r4, 1     ; i++                         00000058 24840001
            nop                 ;                             0000005c 0000003f
            nop                 ;                             00000060 0000003f
            sle   r8, r4, r5    ; r6: i <= N ?                00000064 0085402c
            slli  r6, r4, 1     ; r6; j = 2*i;                00000068 50860001
            nop                 ;                             0000006c 0000003f
            nop                 ;                             00000070 0000003f
            addu  r7, r3, r6    ; r7 : Adresse von A[j]       00000074 00663821
            nop                 ;                             00000078 0000003f
            bnez  r8, inner     ; if r8 == 1  loop inner      0000007c 1500ffc0
            nop                 ;                             00000080 0000003f
            nop                 ;                             00000084 0000003f
            nop                 ;                             00000088 0000003f
            nop                 ;                             0000008c 0000003f
            nop                 ;                             00000090 0000003f
            nop                 ;                             00000094 0000003f
            trap  0             ;                             00000098 44000000

N:	    .word   100         ;                             0000009c 00000064

            .align  10
A:	    .space  101
