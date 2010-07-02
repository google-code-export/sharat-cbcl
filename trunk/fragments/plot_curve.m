%plot_curve
%plots Score distributions
%Usage plot_curve(frr_file,far_file)
%ex: plot_curve('frr_result.txt','far_result.txt');
%
function plot_far(frr_file,far_file)
frr = textread(frr_file);
far = textread(far_file);

[far_n,far_x]=hist(far,20);
[frr_n,frr_x]=hist(frr,20);
%far_n = far_n/length(far);
%frr_n = frr_n/length(frr);
figure,bar(far_x,far_n,'r');
hold on,bar(frr_x,frr_n,'b');
legend('impostor','genuine');

%plot the far and frr
thresh  =   unique([far;frr;0]);
far_y   =   zeros(1,length(thresh));
frr_y   =   zeros(1,length(thresh));
for i = 1:length(thresh)
    far_y(i) = sum((far >= thresh(i)))/length(far);
    frr_y(i) = sum((frr < thresh(i)))/length(frr);
end;
figure,plot(thresh,far_y,thresh,frr_y,thresh,frr_y+far_y);
legend('FAR','FRR');

figure,plot(far_y,1-frr_y,'b');xlabel('False accept rate'),ylabel('Genuine accept rate');
legend('After');
axis([1e-4 1 0.5 1]);
title('ROC');