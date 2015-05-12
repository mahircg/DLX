main:	    addui r1, r0, 1     ; r1: Konstante 1             00000000 24010001
            lw    r2, N(r0)     ; r2: N                       00000004 8c0200a0
            addui r3, r0, A     ; r3: Basisadresse von A      00000008 24030400

; Initialisierungsschleife
; ========================
;  for( a[1]=0, i=2; i<= N; i++ ) 
;    a[i] = 1;  

            addui r4, r0, 2     ; r4: i = 2                   0000000c 24040002
            sb    1(r3), r0     ; A[1] = 0                    00000010 a0600001
init_loop:  addu  r5, r3, r4    ; r5 : Adresse von A[i]       00000014 00642821
            sb    0(r5), r1     ; A[i] = 1                    00000018 a0a10000
            addui r4, r4, 1     ; i++                         0000001c 24840001
            sle   r6, r4, r2    ; r6: i <= N ?                00000020 0082302c
            bnez  r6, init_loop ; if r6 == 1  loop init_loop  00000024 14c0ffec
            nop                 ;                             00000028 0000003f

; Hauptschleife
; =============
; for( i=2; i<=N/2; i++ )
;   for( j=i+i; j<=N; j+=i )
;     a[j] = 0;
           
            addui r4, r0, 2     ; r4: i = 2                   0000002c 24040002
            srai  r5, r2, 1     ; r5: N/2                     00000030 5c450001
outer:      slli  r6, r4, 1     ; r6; j = 2*i;                00000034 50860001
inner:      addu  r7, r3, r6    ; r7 : Adresse von A[j]       00000038 00663821
            sb    0(r7), r0     ; A[j] = 0                    0000003c a0e00000
            addu  r6, r6, r4    ; j = j + i                   00000040 00c43021
            sle   r8, r6, r2    ; r8: j <= N ?                00000044 00c2402c
            bnez  r8, inner     ; if r8 == 1 loop inner       00000048 1500ffec
            nop                 ;                             0000004c 0000003f
            addui r4, r4, 1     ; i++                         00000050 24840001
            sle   r8, r4, r5    ; r8: i <= N/2 ?              00000054 0085402c
            bnez  r8, outer     ; if r8 == 1 loop outer       00000058 1500ffd8
            nop                 ;                             0000005c 0000003f

; Ausgabe der Primzahlen ab Adresse 256
;=======================================

            addui r4, r0, 2     ; r4: i = 2                   00000060 24040002
            addui r7, r0, B     ; &B                          00000064 24070800

out_loop:   addu  r6, r3, r4    ; r6 = &A[i]                  00000068 00643021
            lbu   r8, 0(r6)     ; r8 = A[i]                   0000006c 90c80000
            beqz  r8, continue  ;                             00000070 1100000c
            nop                 ;                             00000074 0000003f
            sw    0(r7), r4     ;                             00000078 ace40000
            addui r7, r7, 4     ; r7 += 4                     0000007c 24e70004
            
continue:   addui r4, r4, 1     ; r4 += 1                     00000080 24840001
            sle   r5, r4, r2    ; r5 = (i <= N)               00000084 0082282c
            bnez  r5, out_loop  ;                             00000088 14a0ffdc
            
            nop                 ;                             0000008c 0000003f
            nop                 ;                             00000090 0000003f
            nop                 ;                             00000094 0000003f
            nop                 ;                             00000098 0000003f
            trap  0             ;                             0000009c 44000000
            
N:	    .word   100         ;                             000000a0 00000064
            .align  10
A:	    .space  101
            .align  10
B:	    .space  101
