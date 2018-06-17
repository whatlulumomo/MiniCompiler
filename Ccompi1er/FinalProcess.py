# encoding: utf-8
# 提取中间树
intercode = []
with open("./MIPS/intercode.txt") as f:
    start = False
    for line in f:
        if "中间树" in line:
            start = True
        if start == False:
            continue
        if len(line) == 0:
            start = False
            continue
        intercode.append(line)
    with open("./AST.txt","w+") as t:
        for line in intercode:
            t.writelines(line)



count = 0
errornum = 0
errorlist = []
with open("./MIPS/intercode.txt") as f:
    for line in f:
        count += 1
        if "--error" in line:
            errornum += 1
            # print("%d: error syntax"%(count))
            errorlist.append("第%d行: error --syntax\n"%(count))

if errornum > 0:
    with open("Errorlog.txt","w+") as f:
        for s in errorlist:
            f.writelines(s)