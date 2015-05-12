main:	    addui r1, r0, 1    ; r1: Konstante 1               00000000 24010001
            lw   r2, N(r0)     ; r2: N                         00000004 8c020060
            addui r3, r0, A    ; r3: Basisadresse von A        00000008 24030400

; Bubblesort
; ==========
;  for( i=N; i>=1; i-- ) 
;    for( j=1; j<i; j++ )
;    {
;      if( a[j-1] > a[j] )
;      {
;        temp   = a[j];
;        a[j]   = a[j-1];
;        a[j-1] = temp;
;      }
;    } 

            subui r4, r2, 1    ; r4: i = N                     0000000c 2c440001
outer:      addui r5, r0, 1    ; r5: j = 1                     00000010 24050001
            addu  r6, r3, 4    ; r6: Adresse von A[j]          00000014 24660004
inner:      lw    r7, -4(r6)   ; r7: A[j-1]                    00000018 8cc7fffc
            lw    r8, 0(r6)    ; r8: A[j]                      0000001c 8cc80000
            slt   r9, r5, r4   ; r9: j < i ?                   00000020 00a4482a
            sgt   r10, r7, r8  ; r10: A[j-1] > A[j]            00000024 00e8502b
            addui r5, r5, 1    ; r5: j++                       00000028 24a50001
            beqz  r10, noswap  ; if A[j-1] <= A[j] goto noswap 0000002c 1140000c
            nop                ;                               00000030 0000003f
            sw    -4(r6), r8   ; A[j-1] = r8                   00000034 acc8fffc
            sw    0(r6), r7    ; A[j]   = r7                   00000038 acc70000
noswap:     bnez  r9, inner    ; if j < i goto inner           0000003c 1520ffd8
            addui r6, r6, 4    ; r6: Adresse von A[j+1]        00000040 24c60004
            bnez  r4, outer    ; if i > 0 goto outer           00000044 1480ffc8
            subui r4, r4, 1    ; i--                           00000048 2c840001
            nop                ;                               0000004c 0000003f
            nop                ;                               00000050 0000003f
            nop                ;                               00000054 0000003f
            nop                ;                               00000058 0000003f
            trap  0            ;                               0000005c 44000000
            
N:	    .word   256        ;                               00000060 00000100
            .align  10
A:	    .word   248
            .word   118
            .word   183
            .word   53
            .word   1
            .word   27
            .word   66
            .word   92
            .word   157
            .word   235
            .word   131
            .word   105
            .word   170
            .word   222
            .word   40
            .word   14
            .word   209
            .word   79
            .word   196
            .word   144
            .word   249
            .word   128
            .word   189
            .word   54
            .word   6
            .word   37
            .word   72
            .word   97
            .word   167
            .word   236
            .word   136
            .word   115
            .word   176
            .word   227
            .word   46
            .word   15
            .word   219
            .word   85
            .word   197
            .word   154
            .word   251
            .word   121
            .word   192
            .word   56
            .word   10
            .word   30
            .word   75
            .word   101
            .word   160
            .word   238
            .word   140
            .word   108
            .word   179
            .word   231
            .word   49
            .word   17
            .word   212
            .word   88
            .word   199
            .word   147
            .word   255
            .word   122
            .word   187
            .word   60
            .word   8
            .word   31
            .word   70
            .word   99
            .word   161
            .word   242
            .word   138
            .word   109
            .word   174
            .word   229
            .word   44
            .word   21
            .word   213
            .word   83
            .word   203
            .word   148
            .word   250
            .word   120
            .word   191
            .word   55
            .word   9
            .word   29
            .word   74
            .word   100
            .word   159
            .word   237
            .word   139
            .word   107
            .word   178
            .word   230
            .word   48
            .word   16
            .word   211
            .word   87
            .word   198
            .word   146
            .word   253
            .word   124
            .word   193
            .word   58
            .word   2
            .word   33
            .word   76
            .word   93
            .word   163
            .word   240
            .word   132
            .word   111
            .word   180
            .word   223
            .word   50
            .word   19
            .word   215
            .word   89
            .word   201
            .word   150
            .word   129
            .word   194
            .word   64
            .word   12
            .word   38
            .word   77
            .word   103
            .word   168
            .word   246
            .word   142
            .word   116
            .word   181
            .word   233
            .word   51
            .word   25
            .word   220
            .word   90
            .word   207
            .word   155
            .word   119
            .word   188
            .word   63
            .word   7
            .word   28
            .word   71
            .word   98
            .word   158
            .word   245
            .word   137
            .word   106
            .word   175
            .word   228
            .word   45
            .word   24
            .word   210
            .word   84
            .word   206
            .word   145
            .word   126
            .word   185
            .word   61
            .word   3
            .word   35
            .word   68
            .word   94
            .word   165
            .word   243
            .word   133
            .word   113
            .word   172
            .word   224
            .word   42
            .word   22
            .word   217
            .word   81
            .word   204
            .word   152
            .word   252
            .word   125
            .word   190
            .word   57
            .word   5
            .word   34
            .word   73
            .word   96
            .word   164
            .word   239
            .word   135
            .word   112
            .word   177
            .word   226
            .word   47
            .word   18
            .word   216
            .word   86
            .word   200
            .word   151
            .word   127
            .word   186
            .word   62
            .word   4
            .word   36
            .word   69
            .word   95
            .word   166
            .word   244
            .word   134
            .word   114
            .word   173
            .word   225
            .word   43
            .word   23
            .word   218
            .word   82
            .word   205
            .word   153
            .word   254
            .word   123
            .word   184
            .word   59
            .word   11
            .word   32
            .word   67
            .word   102
            .word   162
            .word   241
            .word   141
            .word   110
            .word   171
            .word   232
            .word   41
            .word   20
            .word   214
            .word   80
            .word   202
            .word   149
            .word   247
            .word   117
            .word   182
            .word   52
            .word   256
            .word   26
            .word   65
            .word   91
            .word   156
            .word   234
            .word   130
            .word   104
            .word   169
            .word   221
            .word   39
            .word   13
            .word   208
            .word   78
            .word   195
            .word   143
