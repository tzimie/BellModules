import sys

usr = sys.argv[1]
psw = sys.argv[2]
if psw != "root":
  exit("Wrong password!")

#line 1, return groups
print('RO;RW')

#returns root elements, always in the format: friendly name,class,type,tags
print('ROOT|ROOT|folder|')
                              