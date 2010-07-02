/*!
*  
*
* sharat@mit.edu
*/
#include "cbcl_model_internal.h"
#include <pthread.h>
#define THREAD 1
#define NUMT   16

typedef struct
{
  const image*          pimg;
  const vector<filter>* pfilt;
  vector<image>*        ps1;
  int start_idx;
  int end_idx;
}sdata;

/*!
 */
void* do_s1(void* data_ptr)
{
  sdata* data                  = (sdata*)data_ptr;
  const image& img             = *(data->pimg);
  const vector<filter>& filt   = *(data->pfilt);
  vector<image>& s1            = *(data->ps1);
  xcorr2d oper;
  for(int i=data->start_idx;i<=data->end_idx;i++)
  {
    /*cout<<"filter:"<<i<<"("<<data->start_idx<<"--"<<data->end_idx<<")"<<endl;*/
    s1[i] = oper(img,filt[i]);
  }
	return 0;
}

/*!
 */
void s1_baseline(const image& img,const vector<filter>& filt,const model_options& opts,vector<image>& s1)
{

  int filt_sz        = (int)filt.size();
  s1.resize(filt_sz);

  pthread_t *threads = new pthread_t[NUMT];
  sdata*    data     = new sdata[NUMT];

  int batch_sz       = filt_sz/NUMT+1;
  batch_sz           = batch_sz?batch_sz:1;

  for(int i=0;i<NUMT;i++)
    {
      int start      = i*batch_sz;
      int stop       = (i+1)*batch_sz-1;
      if(stop >= filt_sz)
	stop       = filt_sz-1;
      data[i].pimg      = &img;
      data[i].pfilt     = &filt;
      data[i].ps1       = &s1;
      data[i].start_idx = start;
      data[i].end_idx   = stop;
#if THREAD
      pthread_create(&threads[i],NULL,do_s1,&data[i]);
#else
      do_s1(&data[i]);
#endif
    }
  for(int i=0;i<NUMT;i++)
    {
      int status;
#if THREAD
      pthread_join(threads[i],(void**)&status);
#endif
    }
  delete[] threads;
  delete[] data;
}


typedef struct
{
  int                  start_idx;
  int                  end_idx;
  const model_options* popt;  
  const vector<image>* ps1;
  vector<image>*       pc1;
}cdata;

void* do_c1(void* data_ptr)
{
  cdata* data              =  (cdata*)data_ptr;
  vector<image>& c1        =  *(data->pc1);
  const vector<image>& s1  =  *(data->ps1);
  const model_options& opts=  *(data->popt);
  hmax oper;
  for(int b = data->start_idx; b <= data->end_idx && b< opts.nbands;b++)
    {
      for(int d=0;d<opts.ndirs;d++)
	{
	  int scale_start    = opts.scale_sum[2*b];
	  int scale_stop     = opts.scale_sum[2*b+1];
	  c1[b*opts.ndirs+d] = oper(s1[scale_start*opts.ndirs+d],opts.space_sum[b],opts.space_sum[b]/2);
	  for(int scale=scale_start+1;scale<scale_stop;scale++)
	    c1[b*opts.ndirs+d]= max(c1[b*opts.ndirs+d],oper(s1[scale*opts.ndirs+d],opts.space_sum[b],opts.space_sum[b]/2));
	}
    }
  return 0;
}
/*!
 */
void c1_baseline(const vector<image>& s1,const model_options& opts,vector<image>& c1)
{
  const int nbands = opts.nbands;
  c1.resize(nbands*opts.ndirs);
  
  pthread_t * threads = new pthread_t[NUMT];
  cdata*      data    = new cdata[NUMT];
  int         batch_sz= nbands/NUMT+1;

  for(int i=0;i<NUMT;i++)
    {
      int start    = i*batch_sz;
      int stop     = (i+1)*batch_sz-1;
      if(stop <= nbands)
	stop       = nbands-1;
      data[i].start_idx  = start;
      data[i].end_idx    = stop;
      data[i].popt       = &opts;
      data[i].ps1        = &s1;
      data[i].pc1        = &c1;
#if THREAD
      pthread_create(&threads[i],NULL,do_c1,&data[i]);
#else
      do_c1(&data[i]);
#endif
    }

  for(int i=0;i<NUMT;i++)
    {
      int status;
#if THREAD
      pthread_join(threads[i],(void**)&status);
#endif
    }
  delete [] threads;
  delete [] data;
}


/*!
 */
typedef struct
{
  const vector<image>* pc1;  
  const vector<filter>* ppatches;
  const model_options* popts;
  vector<image>* ps2;
  vector<double>* pc2;
  int    start_idx;
  int    end_idx;
}c2data;

/*!
 */
void* do_c2(void* data_ptr)
{
  c2data* data = (c2data*)data_ptr;
  dist2d oper;
  const double EPS             = 2.220446049250313e-16;
  const vector<image>& c1      = *(data->pc1);
  const vector<filter>& patches= *(data->ppatches);
  vector<image>& s2            = *(data->ps2);
  vector<double>& c2           = *(data->pc2);
  const model_options& opts    = *(data->popts);
  double  maxval                 = 0;
  double  patch_norm             = 0;
  double  max_norm               = 0;
  for(int i=data->start_idx;i<=data->end_idx;i++)
  {
      c2[i]      = 0;
      maxval     = 0;
      for(int b=0;b<opts.nbands;b++)
      {
        image res = oper(c1[b*opts.ndirs],patches[i*opts.ndirs]);
	patch_norm= pow(patches[i*opts.ndirs].norm(),2);
        for(int d=1;d<opts.ndirs;d++)
	  {
		res        = res + oper(c1[b*opts.ndirs+d],patches[i*opts.ndirs+d]);
		patch_norm+= pow(patches[i*opts.ndirs+d].norm(),2);
	  }
	double sigma        = sqrt(patch_norm+EPS)/3;
	/*convert distances to 0-1*/
	CvSize sz           = res.dim();
	for(int y=0;y<sz.height;y++)
	  for(int x=0;x<sz.width;x++)
	    res[y][x] = exp(-res[y][x]/(2*sigma*sigma));
	s2[i*opts.nbands+b] = res;
        maxval              = res.max();
        if(c2[i]<maxval)
	  {
	    c2[i]    = maxval; 
	  }
      }
  }
}

/*!
 */
void c2_baseline(const vector<image>& c1, vector<image>& s2,const vector<filter>& patches,const model_options & opts,vector<double>& c2)
{
  int nftr = (int) patches.size()/opts.ndirs;
  c2.resize(nftr);
  pthread_t* threads = new pthread_t[NUMT];
  c2data*    data    = new c2data[NUMT];
  int   batch_sz     = nftr/NUMT+1;
  batch_sz           = batch_sz?batch_sz:1;
  s2.resize(nftr*opts.nbands);
  for(int i=0;i<NUMT;i++)
    {
      int start        = i*batch_sz;
      int stop         = (i+1)*batch_sz-1;
      if(stop >=nftr)
	stop = nftr-1;
      data[i].pc1      = &c1;
      data[i].ppatches = &patches;
      data[i].popts    = &opts;
      data[i].ps2      = &s2;
      data[i].pc2      = &c2;
      data[i].start_idx= start;
      data[i].end_idx  = stop;
#if THREAD
      pthread_create(&threads[i],NULL,do_c2,&data[i]);
#else
      do_c2(&data[i]);
#endif      
    }
  for(int i=0;i<NUMT;i++)
    {
      int status;
#if THREAD
      pthread_join(threads[i],(void**)&status);
#endif
    }
 
  delete [] threads;
  delete [] data;
}
