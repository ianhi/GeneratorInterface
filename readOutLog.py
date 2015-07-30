import sys
f = open('out.txt', 'w')
minFile=0
maxFile=11
skipSix=True
SUMString=""
QCDString=""

for fileNum in range(minFile,maxFile):
    SUM=0
    if skipSix and fileNum==6:
        SUMString+="-1,"
        continue
    print "\n\n\nFILE   :"+str(fileNum)+""
    File = open(str(fileNum)+'_25K.log')
    #104 gets first one
    #109 gets last one
    for i in range(0,103):
        File.readline()
    for i in range(0,6):
        line=File.readline().replace('D','E')
        if i==0:
            QCDString+=str(float(line[55:-2]))+","

        SUM+=float(line[55:-2])
        print float(line[55:-2])
    SUMString+=str(SUM)+","
print "SUM cross sections:"
print SUMString[:-1]#slice removes final comma
print "QCD cross sections:"
print QCDString[:-1]#slice removes final comma
