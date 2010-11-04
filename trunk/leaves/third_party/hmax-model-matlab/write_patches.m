%-------------------------------------------------------------------
%usage: write_patches(patches,filename)
%format in the file
% <num_bands>
% [<depth> <height> <width>
% <image data> (ordered by x,y,z)]
% 
%sharat@mit.edu
%------------------------------------------------------------------
function write_patches(patches,filename)
    fout=fopen(filename,'w');
    if(fout==-1)
        error('Cannot open source file');
    end;
    nbands  =length(patches);
    fprintf(fout,'%d\n \n',nbands);
    for b=1:nbands
        [ht,wt,depth]=size(patches{b})
        fprintf(fout,'%d %d %d\n',depth,ht,wt);
        for d=1:depth
            for y=1:ht
                fprintf(fout,'%.4f ',patches{b}(y,:,d));
                fprintf(fout,'\n');
            end;
        end;
    end;
    fclose(fout);
%end function
