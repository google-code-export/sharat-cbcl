%------------------------------------------------------
%detect_object
%Uses a sliding window for detecting the object within
%the scene
%sharat@mit.edu
%-----------------------------------------------------
function s = detect_object(root,img)
  s       = -1;
  %search window size
  [rh,rw] = size(root.img);
  %search at multiple scales
  for scale = 0.5:0.25:1.5
    image   = imresize(img,scale);
    [ht,wt] = size(image);
    if(ht < rh | wt < rw) continue; end;
    for y = 1:rh/5:ht-rh+1
      for x = 1:rw/5:wt-rw+1
	wnd_img = image(y:y+rh-1,x:x+rw-1);
	[res,S] = image_response(root,wnd_img);
	fprintf('Finding at (scale:%.2f,x:%d,y:%d-->%f)\n',scale,x,y,res);
	s       = max(res,s);
	if(s>0) return;end;
      end;
    end;
  end;
%end
