# Realtime 64bit ascii mandelbrot zoomer in Common Lisp (sbcl)
```
.............../////////////////////..............
...........///////////////////0/////////..........
........//////////////////////0010/////////.......
......///////////////////////119300//////////.....
....////////////////////////00   300///////////...
...////////////////////0; 1^        10311///////..
..////////////////////01              40/////////.
.///////////000010//00=                 40////////
.///////////01 4   603                  3/////////
./////////600                           0/////////
.                     asciimandel!    10//////////
./////////600                           0/////////
.///////////01 4   603                  3/////////
.///////////000010//00=                 40////////
..////////////////////01              40/////////.
...////////////////////0; 1^        10311///////..
....////////////////////////00   300///////////...
......///////////////////////119300//////////.....
........//////////////////////0010/////////.......
...........///////////////////0/////////..........
```

## Usage
start.sh [startpoint] [iter] [threads]

This compiles and starts the ascii zoomer

- startpoint -  a startpoint from the list of nice locations (below), or `list` for a list
- iter       -  max iterations (Default 1000)
- threads    -  number of Threads. (Default 10)


## nice Startpoints

- spirals
- trunks
- starfish
- julia
- flower
- home
- seahorse
- sun
- tendrils

## Optimizations
Some optimized algorithm, with a lot of `(declares)` .
core calc loop is with double-precision floats instead of complex's.
This increases the speed by factor ~20.
Another factor of 10 is achieved by parallel rendering with 10 Threads (on hardware with cores>=10)

## TODO
Current Multiprocessing is starting n Threads per frame and joining them, which is working surprisingly good in sbcl, but could maybe be optimized longer lifecycle workers.

## GFX
create a video with mencoder like this:
`(make-movie-mp)`
This creates images of form: image0000.png.

Rendering will stop as soon as there is only one color in the whole image or after 8000 frames.
### Encode
`mencoder mf://image*.png -mf fps=25 -ovc x264 -oac copy -o output.avi`


# Optimize

## Benchmarks
Currently we are at ~7 cpu cycles per iteration, which is quite acceptable. (depends on workload and pipelining)

## For ASCII we are pretty much done

Currently rendering at 600fps in standard settings and normal terminal
	and still getting 60fps in a 612x160 terminal (smallest font possible here with gnome-terminal and hack)
	
## RGB Video rendering could need some more	

### Disassembly for further optimizations

 - MMX : check

```
; disassembly for M4NDE1-1T3R
; Size: 199 bytes. Origin: #x536B7137                         ; M4NDE1-1T3R
; 37:       F20F107B01       MOVSD XMM7, [RBX+1]
; 3C:       F20F107309       MOVSD XMM6, [RBX+9]
; 41:       660F57C9         XORPD XMM1, XMM1                 ;    1/1000 samples
; 45:       660F57D2         XORPD XMM2, XMM2
; 49:       660F57DB         XORPD XMM3, XMM3
; 4D:       660F57E4         XORPD XMM4, XMM4
; 51:       31C9             XOR ECX, ECX
; 53:       EB3C             JMP L1
; 55:       660F1F840000000000 NOP
; 5E:       6690             NOP
; 60: L0:   4839F9           CMP RCX, RDI                     ;    6/1000 samples
; 63:       7D40             JNL L2
; 65:       F20F58C9         ADDSD XMM1, XMM1
; 69:       F20F59D1         MULSD XMM2, XMM1                 ;    2/1000 samples
; 6D:       F20F58D6         ADDSD XMM2, XMM6
; 71:       660F28CB         MOVAPD XMM1, XMM3                ;   14/1000 samples
; 75:       F20F5CCC         SUBSD XMM1, XMM4
; 79:       F20F58CF         ADDSD XMM1, XMM7                 ;    5/1000 samples
; 7D:       660F28D9         MOVAPD XMM3, XMM1                ;   31/1000 samples
; 81:       F20F59D9         MULSD XMM3, XMM1                 ;   36/1000 samples
; 85:       660F28E2         MOVAPD XMM4, XMM2                ;  145/1000 samples
; 89:       F20F59E2         MULSD XMM4, XMM2                 ;    1/1000 samples
; 8D:       4883C102         ADD RCX, 2
; 91: L1:   660F28EB         MOVAPD XMM5, XMM3                ;    1/1000 samples
; 95:       F20F58EC         ADDSD XMM5, XMM4                 ;   41/1000 samples
; 99:       660F2F2DFFFEFFFF COMISD XMM5, [RIP-257]           ;  118/1000 samples
                                                              ; [#x536B70A0]
; A1:       7A02             JP L2                            ;   38/1000 samples
; A3:       72BB             JB L0                            ;   24/1000 samples
; A5: L2:   660F14CA         UNPCKLPD XMM1, XMM2              ;    4/1000 samples
; A9:       4D896D28         MOV [R13+40], R13                ; thread.pseudo-atomic-bits
; AD:       498B5548         MOV RDX, [R13+72]                ; thread.boxed-tlab
; B1:       4883C220         ADD RDX, 32
; B5:       493B5550         CMP RDX, [R13+80]                ;    1/1000 samples
; B9:       7736             JNBE L5
; BB:       49895548         MOV [R13+72], RDX                ; thread.boxed-tlab
; BF:       4883C2EF         ADD RDX, -17
; C3: L3:   66C742F12903     MOV WORD PTR [RDX-15], 809
; C9:       4D316D28         XOR [R13+40], R13                ;    1/1000 samples
                                                              ; thread.pseudo-atomic-bits
; CD:       7401             JEQ L4
; CF:       F1               ICEBP
; D0: L4:   660F294A01       MOVAPD [RDX+1], XMM1
; D5:       488BF9           MOV RDI, RCX
; D8:       488D5D10         LEA RBX, [RBP+16]
; DC:       B904000000       MOV ECX, 4
; E1:       BE17011050       MOV ESI, #x50100117              ; NIL
; E6:       F9               STC
; E7:       488BE5           MOV RSP, RBP                     ;    1/1000 samples
; EA:       5D               POP RBP
; EB:       C3               RET
; EC:       CC10             INT3 16                          ; Invalid argument count trap
; EE:       CC1A             INT3 26                          ; UNBOUND-SYMBOL-ERROR
; F0:       00               BYTE #X00                        ; RAX(d)
; F1: L5:   6A20             PUSH 32
; F3:       E8789234FF       CALL #x52A00470                  ; ALLOC-TRAMP
; F8:       5A               POP RDX                          ;    2/1000 samples
; F9:       80CA0F           OR DL, 15
; FC:       EBC5             JMP L3

```



```
.............................///////////////////////////////////////////............................
........................////////////////////////////////////0////////////////.......................
...................//////////////////////////////////////////20///////////////////..................
................////////////////////////////////////////////0002100//////////////////...............
............./////////////////////////////////////////////00016 9100////////////////////............
..........//////////////////////////////////////////////0005      =10//////////////////////.........
........///////////////////////////////////////////////0000F      30000//////////////////////.......
.......///////////////////////////////////////01711000352           <27550000010//////////////......
.....////////////////////////////////////////000G                        41   603///////////////....
....///////////////////////////////////////00712                            4200/////////////////...
.../////////////////////000//////////////000029                               B0000///////////////..
..//////////////////////012110001400300000014                                   700////////////////.
.///////////////////////0019  4      361003                                     30//////////////////
.//////////////////0000001              514                                     00//////////////////
./////////////////00031313                                                     0////////////////////
.                                                                           100/////////////////////
./////////////////00031313                                                     0////////////////////
.//////////////////0000001              514                                     00//////////////////
.///////////////////////0019  4      361003                                     30//////////////////
..//////////////////////012110001400300000014                                   700////////////////.
.../////////////////////000//////////////000029                               B0000///////////////..
....///////////////////////////////////////00712                            4200/////////////////...
.....////////////////////////////////////////000G                        41   603///////////////....
.......///////////////////////////////////////01711000352           <27550000010//////////////......
........///////////////////////////////////////////////0000F      30000//////////////////////.......
..........//////////////////////////////////////////////0005      =10//////////////////////.........
............./////////////////////////////////////////////00016 9100////////////////////............
................////////////////////////////////////////////0002100//////////////////...............
...................//////////////////////////////////////////20///////////////////..................
........................////////////////////////////////////0////////////////.......................
```
