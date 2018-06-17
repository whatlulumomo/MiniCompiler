# encoding: utf-8
import os
import re

regs=['$t0','$t1','$t2','$t3','$t4','$t5','$t6','$s0','$s1','$s2','$s3','$s4','$s5','$s6','s7'] # 't8' 't9'
# regs=['$t0','$t1'] # 't7' 't8' 't9'
regspecial = ['$t7', '$t8', '$t9']
specialindex = 0 # 3个特殊寄存器，主要负责导入导出内存溢出变量
specialrecord = {} # 记录这三个寄存器存的东西

table={}
reg_ok={}
variables=[]
blocks = []

Obj=[]

def Load_Var(Inter):
    global variables
    temp_re='(Temp\d+)'
    for line in Inter:
        temps=re.findall(temp_re,' '.join(line))
        variables+=temps

def Load_Inter(filename):
    lines=[]
    block = []
    flag = False
    for line in open(filename,'r'):
        line=line.replace('\r','').replace('\n','')
        if line =='':
            flag = False
            continue
        if flag == False:
            if "中间树" in line:
                flag = True
            continue
        
        linelist = line.split(' ')
        lines.append(linelist)
        if linelist[0] == "FUNCTION":
            if len(block) > 0:
                blocks.append(block)
            block = []
            block = [line]
        else:
            block.append(line)
    blocks.append(block)
    return lines


GlobalRecord = {}
spillBook = {}

def getfromSpillReg(string):
    global specialindex,specialrecord
    for i in specialrecord: # 如果该内存变量正好和该寄存器匹配
        if string == specialrecord[i]:
            return i

    sreg = regspecial[specialindex]
    if sreg in specialrecord:
        print("\tsw %s,%d($sp)"%(sreg, spillBook[specialrecord[sreg]]))
        Obj.append("\tsw %s,%d($sp)"%(sreg, spillBook[specialrecord[sreg]]))

    specialrecord[sreg] = string
    print("\tlw %s,%d($sp)"%(sreg, spillBook[string]))
    Obj.append("\tlw %s,%d($sp)"%(sreg, spillBook[string]))
    specialindex = (specialindex+1)%3
    return sreg

def GetRegFromRecord(string):
    if string in spillBook:
        return getfromSpillReg(string)
    return GlobalRecord[string][0]


def get_R(string):
    if string in table:
        return table[string]
    for reg in regs:
        if reg_ok[reg] == 1:
            reg_ok[reg] = 0
            table[string] = reg
            return table[string]
    return None




def translate(line):
    if line[0]=='LABEL':
        return line[1]+':'
    if line[1]=='=':
        if len(line)==3:
            if line[-1][0]=='#':
                return '\tli %s,%s'%(GetRegFromRecord(line[0]), line[-1].replace('#', ''))
            else:
                return '\tmove %s,%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[2]))
        if len(line)==5:
            if line[3]=='+':
                if line[-1][0]=='#':
                    return '\taddi %s,%s,%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[2]), line[-1].replace('#', ''))
                else:
                    return '\tadd %s,%s,%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[2]), GetRegFromRecord(
                        line[-1]))
            elif line[3]=='-':
                if line[-1][0]=='#':
                    return '\taddi %s,%s,-%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[2]), line[-1].replace('#', ''))
                else:
                    return '\tsub %s,%s,%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[2]), GetRegFromRecord(
                        line[-1]))
            elif line[3]=='*':
                return '\tmul %s,%s,%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[2]), GetRegFromRecord(
                    line[-1]))
            elif line[3]=='/':
                return '\tdiv %s,%s\n\tmflo %s'%(GetRegFromRecord(line[2]), GetRegFromRecord(line[-1]), GetRegFromRecord(
                    line[0]))
            elif line[3]=='<':
                return '\tslt %s,%s,%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[2]), GetRegFromRecord(
                    line[-1]))
            elif line[3]=='>':
                return '\tslt %s,%s,%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[-1]), GetRegFromRecord(
                    line[2]))
            elif line[3]=='==':
                return '\tsub %s,%s,%s'%(GetRegFromRecord(line[0]), GetRegFromRecord(line[-1]), GetRegFromRecord(
                    line[2]))

        if line[2]=='CALL':
            if line[3]=='read' or line[3]=='print':
                return '\taddi $sp,$sp,-4\n\tsw $ra,0($sp)\n\tjal %s\n\tlw $ra,0($sp)\n\tmove %s,$v0\n\taddi $sp,$sp,4'%(line[-1], GetRegFromRecord(
                    line[0]))
            else:
                return '\taddi $sp,$sp,-24\n\tsw $t0,0($sp)\n\tsw $ra,4($sp)\n\tsw $t1,8($sp)\n\tsw $t2,12($sp)\n\tsw $t3,16($sp)\n\tsw $t4,20($sp)\n\tjal %s\n\tlw $a0,0($sp)\n\tlw $ra,4($sp)\n\tlw $t1,8($sp)\n\tlw $t2,12($sp)\n\tlw $t3,16($sp)\n\tlw $t4,20($sp)\n\taddi $sp,$sp,24\n\tmove %s $v0'%(line[-1], GetRegFromRecord(
                    line[0]))
    if line[0]=='GOTO':
        return '\tj %s'%line[1]
    if line[0]=='RETURN':
            return '\tmove $v0,%s\n\tjr $ra' % GetRegFromRecord(line[1])
    if line[0]=='IF':
        if line[2]=='!=':
            return '\tbne %s,%s,%s'%(GetRegFromRecord(line[1]), "$zero", line[-1])
        if line[2] == '==':
            return '\tbeq %s,%s,%s' % (GetRegFromRecord(line[1]), "$zero", line[-1])
    if line[0]=='FUNCTION':
        return '%s:'%line[1]
    if line[0]=='CALL':
        if line[-1]=='read' or line[-1]=='print':
            return '\taddi $sp,$sp,-4\n\tsw $ra,0($sp)\n\tjal %s\n\tlw $ra,0($sp)\n\taddi $sp,$sp,4'%(line[-1])
        else:
            return '\taddi $sp,$sp,-24\n\tsw $t0,0($sp)\n\tsw $ra,4($sp)\n\tsw $t1,8($sp)\n\tsw $t2,12($sp)\n\tsw $t3,16($sp)\n\tsw $t4,20($sp)\n\tjal %s\n\tlw $a0,0($sp)\n\tlw $ra,4($sp)\n\tlw $t1,8($sp)\n\tlw $t2,12($sp)\n\tlw $t3,16($sp)\n\tlw $t4,20($sp)\n\taddi $sp,$sp,24\n\tmove %s $v0'%(line[-1], GetRegFromRecord(
                line[0]))
    if line[0]=='ARG':
        return '\tmove $a0,%s' % GetRegFromRecord(line[-1])
    if line[0]=='PARAM':
        return '\tmove %s,$a0'% GetRegFromRecord(line[1])
    return ''





def write_to_txt(Obj):
    f=open('./MIPS/objectcode.asm','w')
    template='''
.data
_hint: .asciiz "Input:"
_ret: .asciiz "\\n"
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
'''
    f.write(template)
    for line in Obj:
        f.write(line+'\n')
    f.close()


def init_reg():
    global table,reg_ok,spillBook,spill_record,specialrecord
    specialrecord = {}
    spill_record = []
    spillBook = {}
    table = {}
    reg_ok = {}
    for reg in regs:
        reg_ok[reg] = 1  # 初始化，所有寄存器都可用


def findTime(reglist, regname):
    time = 0
    for i in range(len(reglist)):
        reg = reglist[i]
        if reg == regname:
            time += 1
    return time


def findMinUse(record):
    min = 100000
    variname = ""
    for i in record:
        if record[i][1] <= min:
            min = record[i][1]
            variname = i
    return variname


def parser():
    Inter=Load_Inter('./MIPS/intercode.txt')  #读取中间代码
    Load_Var(Inter)    #第一遍扫描，记录所有变量


 

    for block in blocks:
        init_reg()
        reguse = []
        for line in block:
            pattern = re.compile(r'Temp\d+|var\d+')
            list = re.findall(pattern, line)
            reguse += list
        regbook = {}
        for i in range(len(reguse)):
            thisreg = reguse[i]
            if thisreg not in regbook:
                time = findTime(reguse, thisreg)
                regbook[thisreg] = [thisreg, time]
        global GlobalRecord
        GlobalRecord = regbook


        while len(regbook) > len(regs):
            minreg = findMinUse(regbook)
            spillBook[minreg] = len(spillBook)*4
            regbook.pop(minreg)

        for reg in regbook:
            regbook[reg] = [get_R(reg), regbook[reg][1]]

        # print("RegUse", reguse)
        # print("RegBook", regbook)
        # print("RegSpill", spillBook)

        for line in block:
            linelist = line.split(" ")
            s = translate(linelist) # 翻译该句

            if len(s) > 0: # 长度大于0 ， 打印， 避免空行
                Obj.append(s)

            if len(linelist) == 3 and linelist[2] == ":" and "label" not in line: # callee save , store regs to be used in this block
                count = len(regbook) + len(spillBook)
                print("\taddi $sp,$sp," + str(-count * 4))
                Obj.append("\taddi $sp,$sp," + str(-count * 4))

                count = len(spillBook)

                for i in regbook:
                    print("\tsw %s,%d($sp)"%(regbook[i][0],count*4))
                    Obj.append("\tsw %s,%d($sp)"%(regbook[i][0],count*4))
                    count += 1
        # 块结束后恢复寄存器

        count = len(spillBook)

        for i in regbook:
            print("\tlw %s,%d($sp)" % (regbook[i][0], count * 4))
            Obj.append("\tlw %s,%d($sp)" % (regbook[i][0], count * 4))
            count += 1
        print("\taddi $sp,$sp," + str(count * 4))
        Obj.append("\taddi $sp,$sp," + str(count * 4))

    write_to_txt(Obj)

parser()
