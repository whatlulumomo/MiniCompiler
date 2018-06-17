
.data
_prompt: .asciiz "Enter an integer:"
_ret: .asciiz "\n"
.globl main
.text
read:
    li $v0,4
    la $a0,_prompt
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
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal read
	lw $ra,0($sp)
	move $t1,$v0
	addi $sp,$sp,4
	move $t2,$t1
	li $t1,1
	move $t3,$t1
	li $t1,1
	move $t4,$t1
	li $t1,0
	move $t5,$t1
label_0:
	slt $t1,$t5,$t2
	bne $t1,$zero,label_1
	j label_3
label_1:
	li $t1,0
	sub $t6,$t1,$t5
	beq $t6,$zero,label_4
	j label_5
label_4:
	li $t1,1
	move $t0,$a0
	move $a0,$t1
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal print
	lw $ra,0($sp)
	addi $sp,$sp,4
	j label_2
label_5:
	li $t1,1
	sub $t6,$t1,$t5
	beq $t6,$zero,label_6
	j label_7
label_6:
	li $t1,1
	move $t0,$a0
	move $a0,$t1
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal print
	lw $ra,0($sp)
	addi $sp,$sp,4
	j label_2
label_7:
	add $t1,$t3,$t4
	move $t7,$t1
	move $t3,$t4
	move $t4,$t7
	move $t0,$a0
	move $a0,$t4
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal print
	lw $ra,0($sp)
	addi $sp,$sp,4
label_2:
	li $t1,1
	add $t6,$t5,$t1
	move $t5,$t6
	j label_0
