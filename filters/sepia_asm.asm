global sepia_asm

  section .rodata
  val050302: dd 0.2, 0.3, 0.5, 1.0

  DEFAULT REL

 %define SRC rdi
 %define DST rsi
 %define WIDTH rdx
 %define HEIGHT rcx
 %define ALPHA r8

section .text
;void sepia_asm(unsigned char *src,
;                  unsigned char *dst,
;                  int w, int h,
;                  int alpha);

%macro apply_sepia 0
  ; assumes that rbx has a pointer to SRC pixels
  ; assumes that rax has a pointer to DST pixels
  ; uses registers: rdi

  pxor xmm0, xmm0
  pxor xmm1, xmm1
  pxor xmm7, xmm7
  pxor xmm10, xmm10
  pxor xmm11, xmm11

  movdqu xmm0, [rbx] ; xmm0  = p0 | p1 | p2 | p3
  movdqu xmm15, xmm0 ; xmm15 = p0 | p1 | p2 | p3

  xor rdi, rdi
  mov rdi, 0xFF000000FF ; alpha mask FF | 00 | 00 | 00 | FF
  movq xmm10, rdi
  pslldq xmm10, 3 ; 00 | 00 | 00 | FF | 00 | 00 | 00 | FF | ...
  pand xmm15, xmm10
  movdqu xmm11, xmm15 ; xmm11 = 0 | 0 | 0 | a0 | 0 | 0 | 0 | a1 | ...

  movdqu xmm15, xmm0
  pslldq xmm10, 8
  pand xmm15, xmm10

  paddb xmm11, xmm15  ; xmm11 = 0 | 0 | 0 | a0 | ... | 0 | 0 | 0 | a3

  movdqu xmm15, xmm0

  ; punpck will allow us to use pixel data as floats later on
  punpcklbw xmm0, xmm7  ; xmm0  = R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1
  punpckhbw xmm15, xmm7 ; xmm15 = R2 | G2 | B2 | A2 | R3 | G3 | B3 | A3

  apply_sepia_2_pixels ; apply sepia to P0 and P1
  movdqu xmm9, xmm0 ; xmm9 = P0' | P1' | 0 | 0 

  pxor xmm0, xmm0
  movdqu xmm0, xmm15
  apply_sepia_2_pixels ; apply sepia to P2 and P3
  
  pslldq xmm0, 8    ; xmm0 = 0 | 0 | P2' | P3'
  addpd xmm0, xmm9  ; xmm0 = P0' | P1' | P2' | P3'
  paddb xmm0, xmm11 ; add unmodified alphas

  movdqu [rax], xmm0
%endmacro

%macro apply_sepia_2_pixels 0
  ; assumes that xmm0 has two pixels unpacked
  ; assumes that xmm4 has sepia constant (val050302)
  ; uses registers: rdi

  pxor xmm1, xmm1
  movups xmm1, xmm0

  psrldq xmm1, 2
  paddw xmm0, xmm1 ; xmm0 = R0+G0 | . | . | . | R1+G1 | . | . | .

  psrldq xmm1, 2
  paddw xmm0, xmm1 ; xmm0 = R0+G0+B0 | . | . | . | R1+G1+B1 | . | . | .

  pxor xmm7, xmm7
  mov rdi, 0xFFFF
  movq xmm7, rdi     ; xmm7 = 1 0 0 0 0 0 0 0
  movups xmm8, xmm7  ; xmm8 = 1 0 0 0 0 0 0 0
  pslldq xmm7, 8     ; xmm7 = 0 0 0 0 1 0 0 0
  addps xmm7, xmm8   ; xmm7 = 1 0 0 0 1 0 0 0

  pand xmm0, xmm7    ; xmm0 = R0+G0+B0 | 0 | 0 | 0 | R1+G1+B1 | 0 | 0 | 0
  movups xmm1, xmm0

  pslldq xmm0, 2
  paddw xmm0, xmm1
  pslldq xmm0, 2
  paddw xmm0, xmm1 ; xmm0 = SUM0 | SUM0 | SUM0 | 0 | SUM1 | SUM1 | SUM1 | 0

  movups xmm3, xmm0
  psrldq xmm3, 8 ; xmm3 = SUM1 | SUM1 | SUM1 | . | . | . | . | . |

  pxor xmm1, xmm1
  punpcklwd xmm0, xmm1 ; xmm0 = SUM0 | SUM0 | SUM0 | .  

  apply_value_and_pack
  movups xmm8, xmm0 ; xmm8 = R0' | G0' | B0' | . | ...

  pxor xmm1, xmm1
  punpcklwd xmm3, xmm1 ; xmm0 = SUM1 | SUM1 | SUM1 | .  

  pxor xmm0, xmm0
  movups xmm0, xmm3
  apply_value_and_pack

	pslldq xmm0, 4
	paddb xmm0, xmm8  ; xmm0 = P0' | P1' | 0 | 0
%endmacro

%macro apply_value_and_pack 0
  pxor xmm7, xmm7
  movdqu xmm7, xmm4 ; xmm7 = 0.2 | 0.3 | 0.5 | 1

  pxor xmm2, xmm2
  CVTDQ2PS xmm2, xmm0 ; xmm2 = SUM | SUM | SUM | . (where SUM is float)
  mulps xmm2, xmm7    ; xmm2 = SUM * 0.2 | SUM * 0.3 | SUM * 0.5 | .

  pxor xmm7, xmm7
  CVTPS2DQ xmm7, xmm2 ; xmm7 = SUM * 0.2 | SUM * 0.3 | SUM * 0.5 | . (where SUM is double).

  packusdw xmm7, xmm2 ; doubles -> words
  packuswb xmm7, xmm2 ; words -> bytes

  pxor xmm1, xmm1
  mov rdi, 0xFFFFFFFFFFFFFFFF ; REVISAR ACA. me guardo los primeros 8 numeros (bytes) el resto esta en 0
  movq xmm1, rdi  
  pand xmm7, xmm1
  movups xmm0, xmm7 ; xmm0 = R' | G' | B' | . | ...
%endmacro

sepia_asm:
  push rbp
  mov rbp, rsp
  push r12
  push r13
  push r14
  push r15
  push rbx
  sub rsp, 8

  mov r14, SRC
  mov r15, DST

  movupd xmm4, [val050302]

  mov rbx, [r14]
  mov rax, [r15]

  xor r13, r13
  
  .do:
    apply_sepia

    ; move both pointers 4 pixels ahead
    add rbx, 4*4  ; SRC += 4p
    add rax, 4*4  ; DST += 4p

    add r13, 4 ; r13 += 4

    ; if r13 != WIDTH goto .end
    cmp r13, WIDTH
    jne .while

    ; if not, then we finished a column
    add r14, 8 ; r14 += size of a pointer
    mov rbx, [r14] ; move pointer to beginning of next row

    add r15, 8 ; r15 += size of a pointer
    mov rax, [r15] ; move pointer to beginning of next row

    xor r13, r13 ; restart the column iterator
    dec HEIGHT ; decrease the row iterator

  .while:
  ; if HEIGHT != 0 goto .cicle
  cmp HEIGHT, 0
  jne .do

  add rsp, 8
  pop rbx
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
ret