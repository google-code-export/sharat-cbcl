%-------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------
function patches=read_patches(filename)
    fid=fopen(filename,'r');
    if(fid==-1)
        error('Cannot open destination');
    end;
    nbands = fscanf(fid,'%d',1);
    patches= cell(nbands,1);
    for b=1:length(patches)
        depth = fscanf(fid,'%d',1);
        height= fscanf(fid,'%d',1);
        width = fscanf(fid,'%d',1);
        patches{b}=zeros(height,width,depth);
        for d=1:depth
            for y=1:height
                patches{b}(y,:,d)=fscanf(fid,'%f ',width);
            end;%y
        end;%d
    end;%b
%end function
