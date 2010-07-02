function scriptEvaluate
close all;
clr={'r','g','b'};
scales=logspace(log10(0.5),log10(4),16);
n=1;
for noise=linspace(0,1,8)
    figure;
    for nsigma=1:16
        subplot(4,4,nsigma);
        result=doEvaluate(noise,nsigma);
		for cond=1:3
		  res=squeeze(result(:,cond,:));
		  errorbar(1:11,mean(res,2),std(res,[],2)/sqrt(16),'lineWidth',2,'color',clr{cond});
		  set(gca,'YLim',[0 1.1]);
		  set(gca,'XLim',[0 12]);
		  hold on;
		end;
        %legend('iso','clutter','attn')
		title(sprintf('Noise:%f,Sigma:%f',noise,scales(nsigma)));
   drawnow;
   end;
   saveas(gcf,sprintf('res_%03d.fig',n));
   n=n+1;
end;
%averaged across position?
%averaged across objects?

function result=doEvaluate(noise,nsigma)
SETTINGS='settings';
files=dir(fullfile(SETTINGS,'set-*'));
result=[];
for f=1:11 %length(files)
    fprintf('Processing:%d\n',f);
    setFile=fullfile(SETTINGS,files(f).name);
    tstCond=[];
    try
	%load file
	load(setFile,'trnX','trnY','tstX','tstY','tstTag','tstMX');
	%get cond
	for i=1:length(tstTag)
	  num=sscanf(tstTag{i},'%1d%02d%02d%02d');
	  tstCond(i)=num(1);
	end;
    attnIdx=find(tstCond);
    isoIdx=find(tstCond==0);
 	%test 
    %tstX - without attention
    %tstMX- cell array with attention
    %tstAX- attention
    tstAX=zeros(size(tstX));
    for n=1:size(tstX,1)
        if(tstCond(n)==0) continue;end;
        tstAX(n,:)=tstMX{tstCond(n),nsigma}(n,:);
    end;
    %-------------------------------------------------
    %add noise
    sigma=std(trnX(:))*noise;
    tstX=tstX+randn(size(tstX))*sigma;
    tstAX=tstAX+randn(size(tstX))*sigma;
    %-------------------------------------------------
    %classification without attention
	dist=-negdist(trnX(:,1:end-1),tstX(:,1:end-1)');
    [val,yhat]=min(dist);
    tstY=tstY(:);
    yhat=yhat(:);
    tstCond=tstCond(:);
    for obj=1:16
        result(f,1,obj)=[mean(tstY(~tstCond & tstY==obj)==yhat(~tstCond & tstY==obj))];
        result(f,2,obj)=[mean(tstY(tstCond & tstY==obj)==yhat(tstCond & tstY==obj))];
    end;
    %-------------------------------------------------
    %classification with attention
	dist=-negdist(trnX(:,1:end-1),tstAX(:,1:end-1)');
    [val,yhat]=min(dist);
    tstY=tstY(:);
    yhat=yhat(:);
     for obj=1:16
        result(f,3,obj)=[mean(tstY(tstCond & tstY==obj)==yhat(tstCond & tstY==obj))];
    end;
   catch
	err=lasterror
	keyboard;
  end;%end try
end; %end f
