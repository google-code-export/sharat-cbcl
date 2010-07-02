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
  vector<filter>   patches;
  vector<image>    s1;
  vector<image>    c1;
  vector<image>    s2;
  vector<double>   c2;
  model_options    opt;
  /*initialize*/
  init_opts(&opt);
  load_filter("gabor_bank.txt",fb);

  /*get buffer*/
  if(nrhs!=2 || nlhs!= 1)
  {
    mexErrMsgTxt("Need a single input image!\n");
    return;
  }
  /*read the image*/
  mwSize ndim = mxGetNumberOfDimensions(prhs[0]);
  if(ndim!=2 || !mxIsDouble(prhs[0]))
  {
      mexErrMsgTxt("Need 2D uint8 image\n");
      return;
  }
  image img = buf2img(mxGetPr(prhs[0]),mxGetM(prhs[0]),mxGetN(prhs[0]));
  /*read the patches*/
  if(mxGetM(prhs[1])!=1)
  {
     mexErrMsgTxt("Needs 1D structure array");
     return;
   }
  mwSize npatches=mxGetNumberOfElements(prhs[1]);
  cout<<"number of patches:"<<npatches<<endl;
  patches.resize(npatches*opt.ndirs);
  for(int i=0;i<npatches;i++)
  {
    mxArray* pF      = mxGetField(prhs[1],i,"patch");
    const int* pdim  = mxGetDimensions(pF);
    double*  p       = mxGetPr(pF);
    
    for(int d=0;d<opt.ndirs;d++)
    {
      patches[i*opt.ndirs+d] = buf2img(p,pdim[0],pdim[1]);
      p                      +=pdim[0]*pdim[1];
    }
  }

  /*initialize opencv*/
  s1_baseline(img,fb,opt,s1);
  c1_baseline(s1,opt,c1);
  c2_baseline(c1,s2,patches,opt,c2);
  cout<<s2.size()<<endl;
  /*resize s2 arrays*/
  vector<image> s2max(npatches);
  for(int i=0;i<npatches;i++)
  {
      s2max[i]  = s2[i*opt.nbands];
      CvSize sz = s2max[i].dim();
      for(int b=1;b<opt.nbands;b++)
	    s2max[i]=max(s2max[i],imresize(s2[i*opt.nbands+b],sz.height,sz.width));
  }
  /*put everything in a cell array*/
  plhs[0]           = mxCreateCellMatrix(1,2); /*first has vector second has actual image*/
  mexPrintf("done extracting s2 c2\n");
  /*put s2 into 3D matrices*/
  mwSize dims[3];
  CvSize s2sz   = s2max[0].dim();
  dims[0]       = s2sz.height;
  dims[1]       = s2sz.width;
  dims[2]       = npatches;
  mxArray*s2vec = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
  double* p     = mxGetPr(s2vec);
  for(int i=0;i<npatches;i++)
  {
    img2buf(s2max[i],p);
     p         += s2sz.height*s2sz.width;
  }


  /*put c2 in 1D matrix*/
  mxArray* c2vec    = mxCreateDoubleMatrix(c2.size(),1,mxREAL);
  p                 = mxGetPr(c2vec);
  for(int i=0;i<c2.size();i++)
    p[i] = c2[i];
  /*set the first cell*/
  mxSetCell(plhs[0],0,s2vec);
  /*populate cell matrix*/
  mxSetCell(plhs[0],1,c2vec);
}
