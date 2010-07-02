/*!
*  
*
* sharat@mit.edu
*/
#include "image.h"
#include "filter.h"
#include "operations.h"
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <time.h>
#include "cbcl_model_internal.h"
#include "opts.h"
#include <string>
#include <sstream>
#include <unistd.h> /*to use getopt*/
#include "mex.h"
#include "gabor_bank.h"

using namespace std;

#define DO_DEBUG 0

#if 0
void load_filter(vector<filter>& filt)
{
  int ncount;
  istringstream ssin(_str_gabor);
  ssin>>ncount;
  filt.clear();filt.resize(ncount);
  for(int i=0;i<ncount;i++)
    ssin>>filt[i];
}
#else
void load_filter(const char* filename,vector<filter>& filt)
{
  int ncount;
  ifstream fin;
  fin.open(filename,ifstream::in);
  fin>>ncount;
  filt.clear();filt.resize(ncount);
  for(int i=0;i<ncount;i++)
    fin>>filt[i];
  fin.close();
}
#endif

void init_opts(model_options* opt)
{
  /*{0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7};*/
  int start_stop[]={0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7};
  int space_sum[] ={8,10,12,14,16,18,20,22};
  opt->nbands = 8;
  opt->nscales= 8;
  opt->ndirs  = 4;
  for(int i=0;i<opt->nbands;i++)
    {
      opt->scale_sum.push_back(start_stop[2*i]);
      opt->scale_sum.push_back(start_stop[2*i+1]);
      opt->space_sum.push_back(space_sum[i]);
    }
}

image buf2img(const double* buf,int ht,int wt,int col_aligned=1)
{
   image res(ht,wt);
   for(int i=0;i<ht;i++)
   {
     for(int j=0;j<wt;j++)
       if(col_aligned)
	 res[i][j] = (double)buf[j*ht+i];
       else
	 res[i][j] = (double)buf[i*wt+j];
   }
   return res;
}

void img2buf(const image& img,double* buf,int col_aligned=1)
{
   CvSize sz = img.dim();
   for(int i=0;i<sz.height;i++)
   {
     for(int j=0;j<sz.width;j++)
       if(col_aligned)
	 buf[j*sz.height+i] = img[i][j];
       else
	 buf[i*sz.width+j] = img[i][j];
   }
}

/*program arguments*/
void mexFunction(int nlhs,mxArray* plhs[],int nrhs,const mxArray* prhs[])
{
  using namespace std;
  vector<filter>   fb;
  vector<image>    s1;
  vector<image>    c1;
  model_options    opt;
  /*initialize*/
  init_opts(&opt);
  load_filter("gabor_bank.txt",fb);

  /*get buffer*/
  if(nrhs!=1 || nlhs!= 1)
  {
    mexErrMsgTxt("Need a single input image!\n");
    return;
  }
  mwSize ndim = mxGetNumberOfDimensions(prhs[0]);

  if(ndim!=2 || !mxIsDouble(prhs[0]))
  {
      mexErrMsgTxt("Need 2D uint8 image\n");
      return;
  }
  image img = buf2img(mxGetPr(prhs[0]),mxGetM(prhs[0]),mxGetN(prhs[0]));
  /*initialize opencv*/
  s1_baseline(img,fb,opt,s1);
  c1_baseline(s1,opt,c1);
  mexPrintf("done extracting c1\n");
  /*put everything in a cell array*/
  plhs[0]           = mxCreateCellMatrix(1,2); /*first has vector second has actual image*/
  mxArray* c1_cell  = mxCreateCellMatrix(1,opt.nbands);

  /*get the array size first*/
  int      len      = 0;
  for(int i =0;i<c1.size();i++)
  {
    CvSize sz = c1[i].dim();
    len       += sz.height*sz.width;
  }
  /*now copy the values*/
  mxArray* c1vec    = mxCreateDoubleMatrix(len,1,mxREAL);
  double*  p        = mxGetPr(c1vec);
  for(int i=0;i<c1.size();i++)
  {
    CvSize sz = c1[i].dim();
    img2buf(c1[i],p);
    p         += sz.height*sz.width;
  }
  /*set the first cell*/
  mxSetCell(plhs[0],0,c1vec);

  /*populate cell matrix*/
  mwSize dims[3];
  for(int b=0;b<opt.nbands;b++)
    {
      CvSize sz   = c1[b*opt.ndirs].dim();
      dims[0]     = sz.height;
      dims[1]     = sz.width;
      dims[2]     = opt.ndirs;
      c1vec       = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
      p           = mxGetPr(c1vec);
      for(int d=0;d<opt.ndirs;d++)
      {
	img2buf(c1[b*opt.ndirs+d],p);
	p         += sz.height*sz.width;
      }
      mxSetCell(c1_cell,b,c1vec);
    }
  mxSetCell(plhs[0],1,c1_cell);
}
