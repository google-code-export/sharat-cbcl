%-------------------------------------------------------------------------
%select_best_patches
%  selects the N most best patches based on conditional mutual
%  information
%  usage: [nu,dmi] = get_best_patches(pos,neg,thresh,mi,N)
%         thresh - (IN) optimal thresholds
%         mi     - (IN) corresponding mutual information
%         N      - (IN) maximum number of features to select
%         nu     - (OUT)indices of the best features (in order)
%         dmi    - (OUT)additional mutual information delivered 
%  the implementation is based on flueret's basic algorithm
% sharat@mit.edu
%-------------------------------------------------------------------------
function [nu,dmi] = get_best_patches(pos,neg,thresh,mi,N)
   dbg_flag     = 1;  %switch this on if you like
   [nptch,nftr] = size(pos);
   %discretize the features
   for i = 1:nptch
      pos(i,:) = (pos(i,:)>=thresh(i));
	  neg(i,:) = (neg(i,:)>=thresh(i));
   end;

   
   s        =   mi; %selected patches
   nu       =   [];
   dmi      =   [];
   while(length(nu)<N)
       fprintf('Current:%d\n',length(nu));
       if(dbg_flag)
        stem(s); pause(1);
       end;       
       kmax = find(s==max(s));
       kmax = kmax(1);
       nu   = [nu,kmax];
       dmi  = [dmi,s(kmax)];
       for k = 1:nptch
         cm   = fleuret_cmim(pos(k,:),neg(k,:),pos(kmax,:),neg(kmax,:)); %cmim(Xn given Xm)
    	 %cm  = vidal_cmim(pos(k,:),neg(k,:),pos(kmax,:),neg(kmax,:),mi(kmax));
         s(k) = min(s(k),cm);	  			  
       end;
   end;
%end function


%--------------------------------------------
%
%--------------------------------------------
function cmim = vidal_cmim(posx,negx,posy,negy,mi)
    cpos = [2*posx+posy]; %joint feature
    cneg = [2*negx+negy];
    %compute diff entropy
    hx    = entropy([cpos,cneg],[0:3]);
    p0    = length(cneg)/(length(cpos)+length(cneg));
    p1    = 1-p0;
    hx_0  = entropy(cneg,[0:3]);
    hx_1  = entropy(cpos,[0:3]);
    cmim  = hx-(p0*hx_0+p1*hx_1)-mi;
%end function cmim

%----------------------------------------------
%
%----------------------------------------------
function cm = fleuret_cmim(posx,negx,posy,negy)
  Y  = [ones(1,length(posx)),zeros(1,length(negx))];
  Xn = [posx,negx];
  Xm = [posy,negy];
  cm = entropy(2*Y+Xm,[0:3])-entropy(Xm,[0,1])-entropy(4*Y+2*Xn+Xm,[0:7])+entropy(2*Xn+Xm,[0:3]);
%end function


