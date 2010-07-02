%----------------------------------------------------------------------
%image_response
% computes the response of the hierarchy to a given image
% the hierarchy has to be properly trained before using this
% function.
% usage:
% [res,S]  = image_response(root,img)
%     root - (IN) properly initialized hierarchy
%     img  - (IN) image for which response is sought
%     S    - (OUT)vector of leave node responses. These responses
%                 form the input to the neural network
%     res  - (OUT)final result of the hierarchy 
%                 >0 -> detected, <=0 - not detected
%     
% sharat@mit.edu
%----------------------------------------------------------------------
function [fres,S] = image_response(root,img)
        dbg_flag=   0; %you can turn this on if you want
        sum     =   0;
        S       =   []; 
        [ht,wt] = size(img);
        for i = 1:length(root.h)
    	    fprintf('image response:%d of %d\n',i,length(root.h));
            root.h(i).res   = [];
            root.h(i)       = get_response_map(root.h(i),img);
            res             = root.h(i).res;
            %extract the roi
            msk             = roi_mask(ht,wt,root.h(i).roi);
            res(msk==0)     = -1;
            %find maximum
            [im,jm]         = find(res==max(max(res))); 
            im              = im(1);  
     	    jm              = jm(1);
            score           = res(im,jm);
            [htp,wtp]       = size(root.h(i).img);
	    
            %show context
            if(dbg_flag)
    	      nimg                          =  img;
              nimg(im:im+htp-1,jm:jm+wtp-1) =  root.h(i).img;
              subplot(1,2,1),imshow(root.h(i).img);
       	      subplot(1,2,2),imagesc(nimg),colormap('gray'); 
              h= rectangle('Position',[jm,im,wtp,htp]);
              title('context');pause;
            end;
            %weighted sum
            sum             = sum+ root.w(i)*score;            
    	    %get node scores
            S               = [S,extract_node_scores(root.h(i),jm,im,img)];
        end;
        fres                = evaluate(root,S);
%end function image_response

%----------------------------------------------
%extract_node_scores
%
%----------------------------------------------
function S = extract_node_scores(root,x,y,img)
      S        = [];
      dbg_flag = 0;
      [ht,wt] = size(img); %same for all
      if(isempty(root.h))
        S = [root.res(y,x)];
        return;
      end;
      for i = 1:length(root.h)
        roi         = root.h(i).roi;
    	roi.x       = roi.x + x;
        roi.y       = roi.y + y;
        msk         = roi_mask(ht,wt,roi);
        res         = root.h(i).res;
        res(msk==0) = -1;
    	[im,jm]     = find(res==max(max(res)));
        im          = im(1);
    	jm          = jm(1);
        if(dbg_flag) %show context
    	    fprintf('Response:%f\n',res(im,jm));
            [htp,wtp] = size(root.h(i).img);
            nimg      = img;
            nimg(im:im+htp-1,jm:jm+wtp-1)=root.h(i).img;
            subplot(1,2,1),imagesc(double(img).*msk);
            subplot(1,2,2),imagesc(nimg),colormap('gray');
            h= rectangle('Position',[jm,im,wtp,htp]);  pause;
        end;
        S     = [S,extract_node_scores(root.h(i),jm,im,img)];
      end;
%end function


%---------------------------------------------
%get_response_map
%
%---------------------------------------------
function root   =   get_response_map(root,img)
    dbg_flag    =   0; 
    [ht,wt]     =   size(img);
    [htp,wtp]   =   size(root.img);
    if(isempty(root.h))
        root.res    = corr_image(root.img,img);
        return; 
    end;
    %compute response of children
    for i = 1:length(root.h)
        root.h(i).res = [];
        root.h(i)     = get_response_map(root.h(i),img);
        if(dbg_flag)
    	  subplot(1,2,1),imshow(root.h(i).img);
          subplot(1,2,2),imagesc(root.h(i).res);
          pause;
    	end;
    end;
    %compute response map of parent
    %heuristics
    patch = root.img;
    cor   = corr_image(patch,img);
    cor   = imresize(cor,0.5,'bicubic');
    res   = -ones(ht,wt);
    [im,jm]=find(cor>=root.thresh*0.8); %how did I come up with this?!
    %subsample response
    if(dbg_flag == 1)
        wb = waitbar(0);
        imagesc(cor);pause(3);
    end;
    
    for i = 1:length(im)
        if(dbg_flag==1)
            waitbar(i/length(im),wb);
        end;
        y = im(i)*2;
        x = jm(i)*2;
        sum         = 0;
        for i = 1:length(root.h)
            roi          = root.h(i).roi;
            roi.x        = roi.x + x;
            roi.y        = roi.y + y;
            msk          = roi_mask(ht,wt,roi);
            tres         = root.h(i).res;
            tres(msk==0) = -1;
            s    = max(max(tres)); s = s(1);
            sum  = sum+ root.w(i)* s;
        end;
        res(y,x) = tansig((sum+root.bias));
    end;
    if(dbg_flag)
        close(wb);
    end;
    root.res = res;
%end function get_response_map

%----------------------------------------
%
%----------------------------------------
function out = evaluate(root,S)
   [S,out] = do_eval(root,S);
%end 

%----------------------------------------
%
%----------------------------------------
function [S,y] = do_eval(root,S)
   if(isempty(root.h))
     y   = S(1);
     S(1)= [];
     return;
   end;
   sum = 0;
   for i = 1:length(root.h)
     [S,y] = do_eval(root.h(i),S);
     sum   = sum+root.w(i)*y;
   end;
   y = tansig(sum+root.bias);
%end function
