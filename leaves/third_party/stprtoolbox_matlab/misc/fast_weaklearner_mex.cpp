/*---------------------------------------------------------------------------
% WEAKLEARNER Produce classifier thresholding single feature.
%
% Synopsis:
%  model = weaklearner(data)
%
% Description:
%  This function produce a weak binary classifier which assigns
%  input vector x to classes [1,2] based on thresholding a single 
%  feature. The output is a model which defines the threshold 
%  and feature index such that the weighted error is minimized.
%  This weak learner can be used with the AdaBoost classifier
%  (see 'help adaboost') as a feature selection method.
%  
% Input:
%  data [struct] Training data:
%   .X [dim x num_data] Training vectors.
%   .y [1 x num_data] Binary labels (1 or 2).
%   .D [1 x num_data] Weights of training vectors (optional).
%    If not given then D is set to be uniform distribution.
% 
% Output:
%  model [struct] Binary linear classifier:
%   .W [dim x 1] Normal vector of hyperplane.
%   .b [1x1] Bias of the hyperplane.
%   .fun = 'linclass'.
%
% Example:
%  help adaboost
%
% See also: 
%  ADABOOST, ADACLASS.
% 

% About: Statistical Pattern Recognition Toolbox
% (C) 1999-2004, Written by Vojtech Franc and Vaclav Hlavac
% <a href="http://www.cvut.cz">Czech Technical University Prague</a>
% <a href="http://www.feld.cvut.cz">Faculty of Electrical Engineering</a>
% <a href="http://cmp.felk.cvut.cz">Center for Machine Perception</a>

% Modifications:
% 25-aug-2004, VF
% 11-aug-2004, VF
% 14-Jun-2010, SC , sharat@mit.edu
-------------------------------------------------------------------- */
 
#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <iostream>
#include <vector>
#include <algorithm>

#define USETHREAD 0
#define NTHREADS 16

using namespace std;

struct data
{
  int start;
  int end;
  double* pX;
  double* pY;
  double* pD;
  int npts;
  int ndim;
  double* perr;
  double* pthresh;
  int* psign; 
}; 

struct dpoint
{
    double x;
    double y;
    double d;
};

bool operator<(const dpoint& a,const dpoint& b)
{
    return a.x<b.x;
}


/*@function getScore
  @desc     gets called for every feature dimension
  @param    pX [IN] corresponds to a single dimension 
  @param    pY [IN] label for all the points
  @param    pD [IN] weight for all the points
  @param   len[IN] number of points
  @param   pT [OUT] threshold selected
  @param   pSign [OUT] sign 
  @param   perr  [OUT] minimum error for the given dimension
*/
void getScore(const double* pX,const double* pY,const double* pD,const int len,double* pT,int* pSign,double* perr)
{
  int i=0;
  const double EPS=2.2204e-16;
  vector<double> sp(len),sn(len),errp(len),errn(len);
  double tp=0,tn=0;
  vector<dpoint> xdata(len);

  for(i=0;i<len;i++)
  {
      xdata[i].x=pX[i];
      xdata[i].y=pY[i];
      xdata[i].d=pD[i];
  }
  /*presort the data*/
  sort(xdata.begin(),xdata.end());

  for(i=0;i<len;i++)
	{
	  if(xdata[i].y>1) //negative is labeled as 2
		sn[i]=xdata[i].d;
	  else
		sp[i]=xdata[i].d;
	}
  /*cumulative*/
  for(i=1;i<len;i++)
	{
	  sp[i]+=sp[i-1];
	  sn[i]+=sn[i-1];
	}
  tp=sp[len-1]; /*total weight*/
  tn=sn[len-1]; 

  /*determine errors*/
  for(i=0;i<len;i++)
  {
	errp[i]=sp[i]+tn-sn[i]; /*if sign=1*/
	errn[i]=sn[i]+tp-sp[i]; /*if sign=-1*/
  }
  /*find minimum errors*/
  int pidx,nidx;
  double sval;

  for(i=1,pidx=0,sval=errp[0];i<len;i++)
	{
	  if(errp[i]<sval)
		{
		  sval=errp[i];
		  pidx=i;
		}
	}
  for(i=1,nidx=0,sval=errn[0];i<len;i++)
	{
	  if(errn[i]<sval)
		{
		  sval=errn[i];
		  nidx=i;
		}
	}
  /*return index and sign*/
  if(errp[pidx]<errn[nidx]) /*sign=1*/
	{
	  *pSign=1;
	  *pT=-xdata[pidx].x-EPS;
	  *perr=errp[pidx];
	}
  else
	{
	  *pSign=-1;
	  *pT=xdata[nidx].x+EPS;
	  *perr=errn[nidx];
	}
}

void* dowork(void* ptr)
{
  
  data* pdata=(data*)ptr;
  double* x = new double[pdata->npts];
  for(int t=pdata->start;t<pdata->end;t++)
	{
	  for(int i=0;i<pdata->npts;i++)
		{
		  x[i]=pdata->pX[i*pdata->ndim+t];
		}

	  getScore(x,pdata->pY,pdata->pD,pdata->npts,&(pdata->pthresh[t]),&(pdata->psign[t]),&(pdata->perr[t]));
	  //mexPrintf("Doing task:%d--%f,%d,%f\n",t,pdata->pthresh[t],pdata->psign[t],pdata->perr[t]);
	}
  delete [] x;
  return NULL;
}

/* ==============================================================
 Main MEX function - interface to Matlab.
============================================================== */
void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray*prhs[] )
{
  double* err=NULL;
  double* thresh=NULL;
  int* sign=NULL;

  double* pX=NULL;
  double* pY=NULL;
  double* pD=NULL;
  int npts=0;
  int ndim=0;
  bool allocatedD=false;

  mxArray* model=NULL;

  if(nrhs<1)
	{
	  mexErrMsgTxt("requires data");
	  return;
	}
  /*get dimensions*/
  mxArray* arrX=mxGetField(prhs[0],0,"X");
  mxArray* arrY=mxGetField(prhs[0],0,"y");
  mxArray* arrD=mxGetField(prhs[0],0,"D");
  if(arrX==NULL || arrY==NULL)
	{
	  mexErrMsgTxt("Data cannot be null\n");
	  return;
	}
  npts=mxGetN(arrX);
  ndim=mxGetM(arrX);
  if(mxGetN(arrY)!=npts || mxGetM(arrY)!=1)
  {
      mexErrMsgTxt("Y should be 1x Npts");
      return;
  }
  pX=mxGetPr(arrX);
  pY=mxGetPr(arrY);
  if(arrD==NULL) /*not specified*/
	{
	  pD=new double[npts];
	  for(int i=0;i<npts;i++)
		pD[i]=1.0/npts;
	  allocatedD=true;
	}
  else
	{
	  pD=mxGetPr(arrD);
	}
  /*allocate memory*/
  int blkSize=(ndim+NTHREADS-1)/NTHREADS;
  int ntask=(ndim+blkSize-1)/blkSize;

  //mexPrintf("nTask:%d,blkSize:%d\n",ntask,blkSize);
  data *task_data=new data[ntask];

  sign=new int[npts];
  err=new double[npts];
  thresh=new double[npts];

  for(int t=0;t<ntask;t++)
  {
      task_data[t].pX=pX;
      task_data[t].pY=pY;
      task_data[t].pD=pD;
	  task_data[t].npts=npts;
	  task_data[t].ndim=ndim;
	  task_data[t].perr=err;
	  task_data[t].pthresh=thresh;
	  task_data[t].psign=sign;
	  task_data[t].start=t*blkSize;
	  task_data[t].end=min(ndim,task_data[t].start+blkSize);
  }

#if USETHREAD
      pthread_t threads[NTHREADS];
	  int rc;
	  long t;

	  /*dispatch work*/
	  for(int t=0;t<ntask;t++)
		{
		  //printf("In main: creating thread %ld\n", t);
		  rc = pthread_create(&threads[t], NULL, dowork, (void *)&task_data[t]);
		}
	  /*wait for threads to finish*/
	  for(int t=0;t<ntask;t++)
		{
		  pthread_join(threads[t],NULL);
		}
#else
	  for(int t=0;t<ntask;t++)
		{
		  dowork(&task_data[t]);
		}
#endif
  /*create model*/
  const char* field_names[]={"W","b","fun","dim"};
  if(!(model=mxCreateStructMatrix(1,1,4,field_names)))
	  {
		mexErrMsgTxt("Failed to create model structure");
		return;
	  }
  mxArray* pW=mxCreateDoubleMatrix(ndim,1,mxREAL);
  mxArray* pb=mxCreateDoubleScalar(0);
  mxArray* pfun=mxCreateString("linclass");
  mxArray* pdim=mxCreateDoubleScalar(0);

  /*determine minimum*/
  double sval=err[0];
  int    midx=0;
  for(int d=0;d<ndim;d++)
  {
	  //mexPrintf("Error,%d--%f\n",d,err[d]);
	  if(err[d]<sval)
		midx=d,sval=err[d];
  }
  /*set matrix*/
  double* ptrw=mxGetPr(pW);
  double* ptrb=mxGetPr(pb);
  ptrw[midx]=sign[midx];
  *ptrb     =thresh[midx];
  *mxGetPr(pdim)=midx+1;

  /*set the fields*/
  mxSetField(model,0,field_names[0],pW);
  mxSetField(model,0,field_names[1],pb);
  mxSetField(model,0,field_names[2],pfun);
  mxSetField(model,0,field_names[3],pdim);
  plhs[0]=model;
  delete[] task_data;
  delete[] sign;
  delete[] err;
  delete[] thresh;
  if(allocatedD)
	delete[] pD;
}
