
.data
_hint: .asciiz "Input:"
_ret: .asciiz "\n"
.globl main
.text
read:
    li $v0,4
    la $a0,_hint
    syscall
    li $v0,5
    syscall
    jr $ra
print:
    li $v0,1
    syscall
    li $v0,4
    la $a0,_ret
    syscall
    move $v0,$0
    jr $ra
main:
	addi $sp,$sp,-32
	sw $t0,0($sp)
	sw $t1,4($sp)
	sw $t2,8($sp)
	sw $t3,12($sp)
	sw $t4,16($sp)
	sw $t5,20($sp)
	sw $t6,24($sp)
	sw $s0,28($sp)
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal read
	lw $ra,0($sp)
	move $t5,$v0
	addi $sp,$sp,4
	move $t0,$t5
	li $t5,0
	move $t1,$t5
label_0:
	slt $t4,$t1,$t0
	bne $t4,$zero,label_1
	j label_3
label_1:
	li $t3,2
	li $t3,1
	sub $t2,$t3,$t2
	beq $t2,$zero,label_4
	j label_5
label_4:
	j label_2
label_5:
	move $a0,$t1
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal print
	lw $ra,0($sp)
	addi $sp,$sp,4
label_2:
	li $s0,1
	add $t6,$t1,$s0
	move $t1,$t6
	j label_0
label_3:
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $t2,8($sp)
	lw $t3,12($sp)
	lw $t4,16($sp)
	lw $t5,20($sp)
	lw $t6,24($sp)
	lw $s0,28($sp)
	addi $sp,$sp,32
