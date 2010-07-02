for line in open('database.txt','r').readlines():
	line=line[:-1]
	fields=line.split(",")
	if len(fields)>3:
		print line
	
