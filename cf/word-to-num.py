INPUT_FILE="tags-cleaned.txt"
NUM_FILE="numeric-tags.txt"
MAP_FILE="tag-map.txt"

tags=dict()
cmap=dict()
#get unique words
for line in open(INPUT_FILE).readlines():
	words=line[:-1].split(",")
	cmap[words[0]]=0
	for w in words[1:]:
		tags[w]=0

#assign numbers to tags
count=1
for k in tags:
	tags[k]=count
	count=count+1
count=1
#assign numbers to class
for k in cmap:
	cmap[k]=count
	count=count+1
	
print "number of tags:%d\n"%len(tags)
print "number of class:%d\n"%len(cmap)

fout=open(NUM_FILE,'w')
#get unique words
for line in open(INPUT_FILE).readlines():
	words=line[:-1].split(",")
	for t in cmap:
		if t==words[0]:
			fout.write("1\t")
		else:
			fout.write("0\t")
			
	for t in tags:
		if t in words[1:]:
			fout.write("1\t")
		else:
			fout.write("0\t")
	fout.write("\n")
fout.close()
