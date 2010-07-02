ta=load('td_001')
tb=load('td_002')

for i=1:43;
    colormap('gray')
    fprintf('Processing:%d\n',i)
    subplot(2,2,1);imagesc(ta.imgSeq(:,:,i));axis image off;
    subplot(2,2,2);imagesc(ta.salSeq(:,:,i),[0 0.2]);axis image off;
    
    subplot(2,2,3);imagesc(tb.imgSeq(:,:,i));axis image off;
    subplot(2,2,4);imagesc(tb.salSeq(:,:,i),[0 0.2]);axis image off;
    saveas(gcf,sprintf('td/td_%03d.jpg',i)) 
end
