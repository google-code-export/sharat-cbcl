import os.path
import os
import re
for folder in os.listdir('Raw'):
    for file in os.listdir(os.path.join('Raw',folder)):
        fid=open(os.path.join('Raw',folder,file),'r');
        for line in fid.readlines():
            print line
