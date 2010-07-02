s=set()
fout=open("list.txt","w")
for line in open('tags.txt','r').readlines():
	line=line[:-1];
	for word in line.split(","):
		s.add(word)

for word in s:
	print word
	fout.write("%s\n"%word)
	
	
