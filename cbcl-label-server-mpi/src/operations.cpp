/*!
*  
*
* sharat@mit.edu
*/
#include "image.h"
#include "filter.h"
#include "operations.h"
#include<functional>

using namespace std;

image conv2d::operator()(const image& img,const filter& filt) 
{
  CvSize   szimg = img.dim();
  CvSize   szfilt= filt.dim();
  image    result(szimg.height,szimg.width);
  image    pd_img(szimg.height+szfilt.height-1,szimg.width+szfilt.width-1);
  /*pad the image*/
  cvCopyMakeBorder(img,pd_img,cvPoint(szfilt.width/2-1,szfilt.height/2-1),IPL_BORDER_CONSTANT);
  cvMatchTemplate(pd_img,filt,result,CV_TM_CCORR);
  return abs(result);
} 

image xcorr2d::operator()(const image& img,const filter& filt) 
{
  CvSize szimg = img.dim();
  CvSize szfilt= filt.dim();
  image  tmp_result(szimg.height-szfilt.height+1,szimg.width-szfilt.width+1);
  image  result(szimg.height,szimg.width);
  cvMatchTemplate(img,filt,tmp_result,CV_TM_CCORR_NORMED);
  cvCopyMakeBorder(tmp_result,result,cvPoint(szfilt.width/2-1,szfilt.height/2-1),IPL_BORDER_CONSTANT);
  return abs(result);
}

image dist2d::operator()(const image& img,const filter& filt)
{
  CvSize szimg = img.dim();
  CvSize szfilt= filt.dim();
  image  pd_img(szimg.height+szfilt.height-1,szimg.width+szfilt.width-1);
  image  result(szimg.height,szimg.width);
  /*pad the image*/
  cvCopyMakeBorder(img,pd_img,cvPoint(szfilt.width/2-1,szfilt.height/2-1),IPL_BORDER_CONSTANT);
  cvMatchTemplate(pd_img,filt,result,CV_TM_SQDIFF);
  return result;
}

image hmax::operator()(const image& img,int pool,int shift)
{
  int i,j,k,l,u,v,x,y;
  double max_val,px_val;

  CvSize sz   = img.dim();
  image result((int)ceil((double)sz.height/shift),(int)ceil((double)sz.width/shift));
  for(i=0,y=0;i<sz.height;i+=shift,y++)
    {
      for(j=0,x=0;j<sz.width;j+=shift,x++)
	{
	  max_val = -1e6;
	  for(k=-pool/2;k<pool/2;k++)
	    {
	      u = (i+k);
	      if(u <0 || u >=sz.height) continue;
	    for(l=-pool/2;l<pool/2;l++)
	      {
		v = (l+j);
		if( v <0 || v >=sz.width) continue;
		px_val = img[u][v];
		if(px_val > max_val) 
		  max_val = px_val;
	      } /*end l*/
	    }/*end k*/
	  result[y][x]=(float) max_val;  
	}/*end j*/
    }/*end i*/
  return result;
}
