close all;
if(~exist('shapevis'))
    mkdir('shapevis');
end;

for i=1:length(img_set)
    img=imread(img_set{i});
    if(isrgb(img))
        img=rgb2gray(img);
    end;    
    img=im2double((img));
    img=rescaleHeight(img,800);
    [out,shape,fg]=cleanup(img);
    subplot(1,2,1);imagesc(img);axis image off;colormap('gray');
    boundaries=bwboundaries(fg);
    subplot(1,2,2);imagesc(fg);axis image off;colormap('gray');
    hold on;
    for b=1:length(boundaries)
        bnd=boundaries{b};
        plot(bnd(:,2),bnd(:,1),'r','LineWidth',3)
    end;
    hold off;
    [path,file,ext]=fileparts(img_set{i});
    outfile=fullfile('shapevis',[file '.fig']);
    saveas(gcf,outfile);
    pause(1);
end;    
