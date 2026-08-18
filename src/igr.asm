constant v0(2)
constant t5(13)
constant t6(14)
constant t7(15)
constant s0(16)
constant s1(17)
constant s2(18)
constant s3(19)
constant s4(20)
constant s5(21)
constant s6(22)
constant s7(23)

scope IGR {

constant MENU_STAGE_PI(0x12000000)
constant MENU_STAGE_HI(0xB200)
constant MENU_STAGE_CART_HI(0x1200)
constant DEST_CART_HI(0x1000)
constant SCRATCH_HI(0x0030)
constant COPY_END_HI(0x0010)
constant ROM_MAGIC(0x80371240)
constant SC64_BASE_HI(0xBFFF)
constant D_IDX_WBINVAL(1|(0<<2))
constant I_IDX_INVAL(0|(0<<2))
macro piw() {
  lui t2, PI_BASE
  lui t4, 0x0002
-
  lw t3, PI_STATUS (t2)
  andi t3, 0b11
  beqz t3,+
  addiu t4, -1
  bnez t4,-
  nop
+
}
ccmd:
  lui t0, SC64_BASE_HI
  piw()
  sw r0, 0x0010 (t0)
  piw()
  li t1, 0x5F554E4C
  sw t1, 0x0010 (t0)
  piw()
  li t1, 0x4F434B5F
  sw t1, 0x0010 (t0)
  piw()
  sw a0, 0x0004 (t0)
  piw()
  sw a1, 0x0008 (t0)
  piw()
  lli t1, 0x43
  sw t1, 0x0000 (t0)
  lui t7, 0x0020
-
  lw t1, 0x0000 (t0)
  srl t1, t1, 31
  beqz t1,+
  addiu t7, -1
  bnez t7,-
  nop
+
  jr ra
  nop

Reboot:
  lui t0, SP_BASE
  lli t1, 0x0002
  sw t1, SP_STATUS (t0)
  lui t2, 0x0020
-
  lw t1, SP_STATUS (t0)
  andi t1, 1
  bnez t1,+
  addiu t2, -1
  bnez t2,-
  nop
+
  li t1, 0x00AAAAAE
  sw t1, SP_STATUS (t0)
  sw r0, SP_SEMAPHORE (t0)
  lui t1, SP_PC_BASE
  sw r0, SP_PC (t1)
  lui t2, 0x0020
-
  lw t1, SP_DMA_BUSY (t0)
  andi t1, 1
  beqz t1,+
  addiu t2, -1
  bnez t2,-
  nop
+
  lui t0, 0xA410
  lw t1, 0x000C (t0)
  andi t1, 1
  beqz t1, rdp_done
  nop
  lui t2, 0x0020
-
  lw t1, 0x000C (t0)
  andi t1, 0x20
  beqz t1, rdp_done
  addiu t2, -1
  bnez t2,-
  nop
rdp_done:
  lui t0, MENU_STAGE_HI
  lw t0, 0x0000 (t0)
  li t1, ROM_MAGIC
  bne t0, t1, do_quiesce
  nop

  lli a0, 1
  jal ccmd
  lli a1, 1
  move t7, r0
menu_copy:
  lui t0, PI_BASE
  lui t1, SCRATCH_HI
  sw t1, PI_DRAM_ADDR (t0)
  lui t1, MENU_STAGE_CART_HI
  addu t1, t1, t7
  sw t1, PI_CART_ADDR (t0)
  lli t1, 0xFFFF
  sw t1, PI_WR_LEN (t0)
  lui t2, 0x0020
-
  lw t1, PI_STATUS (t0)
  andi t1, 3
  beqz t1,+
  addiu t2, -1
  bnez t2,-
  nop
+
  lui t1, SCRATCH_HI
  sw t1, PI_DRAM_ADDR (t0)
  lui t1, DEST_CART_HI
  addu t1, t1, t7
  sw t1, PI_CART_ADDR (t0)
  lli t1, 0xFFFF
  sw t1, PI_RD_LEN (t0)
  lui t2, 0x0020
-
  lw t1, PI_STATUS (t0)
  andi t1, 3
  beqz t1,+
  addiu t2, -1
  bnez t2,-
  nop
+
  lui t1, 0x0001
  addu t7, t7, t1
  lui t1, COPY_END_HI
  bne t7, t1, menu_copy
  nop
  lli a0, 1
  jal ccmd
  move a1, r0

do_quiesce:
  lui t0, 0xA410
  lli t1, 0x0015
  sw t1, 0x000C (t0)
  lui t0, PI_BASE
  lli t1, 0x0003
  sw t1, PI_STATUS (t0)
  lui t0, VI_BASE
  lui t2, 0x0020
-
  lw t1, VI_V_CURRENT_LINE (t0)
  andi t1, 0x03FE
  beqz t1,+
  addiu t2, -1
  bnez t2,-
  nop
+
  lli t1, 0x03FF
  sw t1, VI_V_INTR (t0)
  sw r0, VI_H_VIDEO (t0)
  sw r0, VI_V_CURRENT_LINE (t0)
  lui t0, AI_BASE
  sw r0, AI_DRAM_ADDR (t0)
  sw r0, AI_LEN (t0)
  lui t0, SI_BASE
  lui t2, 0x0020
-
  lw t1, SI_STATUS (t0)
  andi t1, 0b11
  beqz t1,+
  addiu t2, -1
  bnez t2,-
  nop
+
  lui t0, 0xA000
  sw r0, 0x030C (t0)
  lw t2, 0x0318 (t0)
  sw t2, 0x0318 (t0)
  sw t2, 0x03F0 (t0)
  move t4, r0
dmem_clr:
  lui t5, SP_MEM_BASE
  addu t5, t5, t4
  sw r0, 0 (t5)
  addiu t4, 4
  slti t6, t4, 0x40
  bnez t6, dmem_clr
  nop
  lli t7, 0x40
ipl3_cpy:
  lui t5, 0xB000
  addu t5, t5, t7
  lw t6, 0 (t5)
  lui t5, SP_MEM_BASE
  addu t5, t5, t7
  sw t6, 0 (t5)
  addiu t7, 4
  slti t5, t7, 0x1000
  bnez t5, ipl3_cpy
  nop
  lui t3, SP_MEM_BASE
  ori t3, SP_IMEM
  la t7, imem_stub
  move t4, r0
imem_stub_cpy:
  addu t5, t7, t4
  lw t6, 0 (t5)
  addu t5, t3, t4
  sw t6, 0 (t5)
  addiu t4, 4
  slti t5, t4, 32
  bnez t5, imem_stub_cpy
  nop
imem_zero:
  addu t5, t3, t4
  sw r0, 0 (t5)
  addiu t4, 4
  slti t5, t4, 0x1000
  bnez t5, imem_zero
  nop
  li t0, 0xBFC007E4
  li t1, 0x00003F3F
  sw t1, 0 (t0)
  lui t0, 0x8000
  ori t1, t0, 0x2000
dflush:
  cache D_IDX_WBINVAL, 0 (t0)
  addiu t0, 16
  bne t0, t1, dflush
  nop
  lui t0, 0x8000
  ori t1, t0, 0x4000
iflush:
  cache I_IDX_INVAL, 0 (t0)
  addiu t0, 32
  bne t0, t1, iflush
  nop
  lui s4, 0xA000
  lw s4, 0x0300 (s4)
  lli s6, 0x3F
  li t0, 0x34000000
  mtc0 t0, Status
  move v0, r0
  move v1, r0
  move a0, r0
  move a1, r0
  move a2, r0
  move a3, r0
  move t0, r0
  move t1, r0
  move t2, r0
  li t3, 0xA4000040
  move t4, r0
  move t5, r0
  move t6, r0
  move t7, r0
  move t8, r0
  move t9, r0
  move s0, r0
  move s1, r0
  move s2, r0
  move s3, r0
  move s5, r0
  move s7, r0
  move s8, r0
  move gp, r0
  move k0, r0
  move k1, r0
  li sp, 0xA4001FF0
  li ra, 0xA4001550
  bnez s4, ipl3_go
  nop
  li ra, 0xA4001554
ipl3_go:
  move at, r0
  jr t3
  nop
align(4)
imem_stub:
  dw 0x3C0DBFC0, 0x8DA807FC, 0x25AD07C0, 0x31080080
  dw 0x5500FFFC, 0x3C0DBFC0, 0x8DA80024, 0x3C0BB000
align(4)
hold:
  dw 0
align(4)

}
