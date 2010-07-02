import sha
import os.path
import shutil

DATA_FILE="files.txt"
OUT_FILE="files-cleaned.txt"
DATA_SRC="/cbcl/scratch01/sharat/databases/LabelMe"
DATA_DST="/cbcl/scratch01/sharat/databases/CF/labelme"

fout=open(OUT_FILE,'w')
for line in open(DATA_FILE).readlines():
	path=line[:-1].split(",")
	shlib=sha.new("/".join(path))
	(root,ext)=os.path.splitext(path[-1])
	fname=shlib.hexdigest()+ext
	print fname
	shutil.copyfile(os.path.join(DATA_SRC,path[0],path[1]),os.path.join(DATA_DST,fname))
	fout.write("%s\n"%(fname))
fout.close()	
	
