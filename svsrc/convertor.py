'''Python script converts MIPS assembly code to binary encoded values uses regular expressions to extract integer reg names''' 
import re

#program.txt is the file with MIPS Assembly code
f=open('program.txt','r')

#file with binary values has a max of 64 instructions
f1=open("mem.dat",'w')

instruction=[]
#Type of instructions with their corresponding opcodes  
R_Type=["ADD","ADDU","SUB","SUBU","AND","OR","XOR","NOR","SLT"]
I_Type=["ADDI","SUBI","SLTI","ANDI","ORI","XORI","LUI","BEQZ","LW","SW"]
R_Type_Converted=['100000','100001','100010','100011','100100','100101','100110','101001','101010']
I_Type_Converted=['001000','001010','011010','001100','001101','001110','001111','000100','100011','101011']
J_Type=["J"]
J_Type_Converted=["000010"]

count=0
#while loop reads and parses codes
while 1:
  instruction=f.readline().split()
  if not instruction:
    break	
  #check R-type
  if instruction[0] in R_Type:
    print "R-Type"
    in1=R_Type.index(instruction[0])
    rs=re.findall(r'\d+', instruction[1])
    rt=re.findall(r'\d+', instruction[2])
    rd=re.findall(r'\d+', instruction[3])	
    f1.write('000000')
    rsints=map(int,rs)
    f1.write(str("{0:05b}".format(rsints[0])))
    rtints=map(int ,rt)
    f1.write(str("{0:05b}".format(rtints[0])))
    rdints=map(int,rd)
    f1.write(str("{0:05b}".format(rdints[0])))
    f1.write('00000')
    f1.write(R_Type_Converted[in1])
    f1.write('\n')
  #check I-Type
  if instruction[0] in I_Type:
	    print "I-Type"
            in1=I_Type.index(instruction[0])
	    f1.write(I_Type_Converted[in1])
            rs=re.findall(r'\d+', instruction[1])
            rt=re.findall(r'\d+', instruction[2])
	    rsints=map(int,rs)
            f1.write(str("{0:05b}".format(rsints[0])))
            rtints=map(int ,rt)
            f1.write(str("{0:05b}".format(rtints[0])))
            imm=re.findall(r'\d+', instruction[3])
            immint=map(int,imm)        
            f1.write(str("{0:016b}".format(immint[0])))
            f1.write('\n')
    #check J-Type
  if instruction[0] in J_Type:
         print "J-Type"
         in1=J_Type.index(instruction[0])
         f1.write(J_Type_Converted[in1])
         addr=re.findall(r'\d+', instruction[1])
         addrint=map(int,addr)
	 f1.write(str("{0:026b}".format(addrint[0])))
	 f1.write('\n')
  print instruction[0]
  print  len(instruction)
  count+=1
'''if number of instructions less than 64 fill remaining with zeros'''
if(count<64):
   count=64-count
   for i in range(0,count):
     for j in range(32):
        f1.write('0')
     f1.write('\n')
f.close() 
f1.close() 
