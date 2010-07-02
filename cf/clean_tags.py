TRANSLATE_FILE="list.txt"
INPUT_FILE="tags.txt"
OUTPUT_FILE="tags-cleaned.txt"
TMP_FILE="tmp.txt"
FREQ_FILE="freq.txt"
MAP_FILE="tag-map.txt"
NUM_FILE="numeric-tags.txt"

#build dictionary
d=dict()
freq=dict()
for line in open(TRANSLATE_FILE,'r').readlines():
	words=line[:-1].split(",")
	words=map(lambda x:x.strip(),words) 
	d[words[0]]=words[1:] #translation list

#translate
fout=open(TMP_FILE,"w")
for line in open(INPUT_FILE,'r').readlines():
	#split the words and strip them
	words=line[:-1].split(",")
	words=map(lambda x:x.strip(),words)
	#first tag remains
	first_tag=d[words[0]][0];
	fout.write("%s,"%first_tag) #because its a list
	#maintain unique list for the rest
	s  =dict()
	for w in words[1:]:
		#get the map word
		mwords=d.get(w.strip(),["_"])
		for m in mwords:
			s[m]=0 #trick to maintain uniqueness
			freq[m]=freq.get(m,0)+1
	fout.write(",".join(filter(lambda x:x!=first_tag,s.keys())))
	fout.write("\n")
fout.close()

#filter based on count
invalid=filter(lambda x:freq[x]<3,freq.keys())
invalid.append("_")

fout=open(OUTPUT_FILE,"w")
for line in open(TMP_FILE,'r').readlines():
	words=line[:-1].split(",")
	first_tag=words[0]
	words=filter(lambda x:x not in invalid,words[1:])
	fout.write("%s,"%first_tag)
	fout.write(",".join(words))
	fout.write("\n")
fout.close()	

fout=open(FREQ_FILE,"w")
for k in freq:
	if k not in invalid:
		fout.write("%s,%d\n"%(k,freq[k]))
fout.close()

