global cropflip_asm

 %define SRC rdi
 %define DST rsi
 %define SRC_W rdx
 %define SRC_H rcx
 %define DST_W r8
 %define DST_H r9
 %define OFFSET_X [rbp + 16]
 %define OFFSET_Y [rbp + 24]

section .text
;void cropflip_asm(unsigned char *src,
;                  unsigned char *dst,
;                  int src_w, int src_h,
;                  int dst_w, int dst_h,
;                  int offset_x, int offset_y);

cropflip_asm:
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

  mov rdx, OFFSET_X
  mov rcx, OFFSET_Y

  lea r14, [r14 + 8 * rcx] ; apply offset y
  mov rbx, [r14]
  lea rbx, [rbx + 4 * rdx] ; apply offset x

  dec DST_H
  lea r15, [r15 + 8 * DST_H] ; move dst to the last row
  inc DST_H
  mov rax, [r15]

  ; r13 is the column iterator
  xor r13, r13 ; r13 = 0

  .do:
    ; copy 4 pixels from SRC to DST
    movdqu xmm0, [rbx]
    movdqu [rax], xmm0

    ; move both pointers 4 pixels ahead
    add rbx, 4*4  ; SRC += 4p
    add rax, 4*4  ; DST += 4p

    add r13, 4 ; r13 += 4

    ; if r13 != DST_W goto .end
    cmp r13, DST_W
    jne .while

    ; if not, then we finished a column
    add r14, 8 ; r14 += size of a pointer
    mov rbx, [r14] ; move pointer to beginning of next row
    lea rbx, [rbx + 4*rdx] ; apply offset x

    sub r15, 8 ; r15 -= size of a pointer
    mov rax, [r15] ; move pointer to beginning of next row

    xor r13, r13 ; restart the column iterator
    dec DST_H ; decrease the row iterator

  .while:
  ; if DST_H != 0 goto .cicle
  cmp DST_H, 0
  jne .do


  add rsp, 8
  pop rbx
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
ret