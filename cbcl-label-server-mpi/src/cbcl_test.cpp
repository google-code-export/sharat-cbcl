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
#include <pthread.h>
#include "cbcl_model_internal.h"
#include "opts.h"
#include <string>
#include "svm_model.h"
#include "highgui.h"
#include <unistd.h> /*to use getopt*/
#include <algorithm>

using namespace std;

#define DO_DEBUG 1

typedef struct __tag_out
{
public:
  double score; 
  string lbl;
}output_t;

class compare_outputs:binary_function<output_t,output_t,bool>
{
public:
  bool operator()(const output_t& lhs,const output_t& rhs)
  {
    return lhs.score < rhs.score;
  }
};

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

void init_opts(model_options* opt)
{
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

/*program arguments*/
typedef enum{IN_IMG,IN_VIDEO} in_mode_t;
typedef enum{OUT_FILE,OUT_TEXT,OUT_VIDEO} out_mode_t;
typedef enum{DISP_ON,DISP_OFF} disp_mode_t;

int main(int argc,char* argv[])
{
  using namespace std;
  vector<filter>   fb;
  vector<filter>   patches;
  vector<image>    s1;
  vector<image>    c1;
  vector<image>    s2;
  vector<double>   c2;
  vector<double>   scores;
  vector<output_t> out;
  svm_model        model;
  int              display  = 0;
  model_options    opt         ;
  char             param     =0;


  /*options*/
  in_mode_t   input_mode = IN_IMG;
  out_mode_t  output_mode= OUT_TEXT;
  disp_mode_t disp_mode  = DISP_ON;
  int         delay      = 0;
  double      threshold  = 0;

  /*initialize*/
  init_opts(&opt);
  load_filter("gabor_bank.txt",fb);
  load_filter("patches.txt",patches);
  load_model("svm_model.txt",model);

  if(argc<9)
    {
      printf("Usage: %s -i <image|video> -o <text|file> -d <on|off> -t <time>\n -h <threshold>",*argv);
      exit(1);
    }
  /*process program arguments*/
  while((param=getopt(argc,argv,"i:o:d:t:h:"))!=-1)
    {
      switch(param)
	{
	case 'h':
	  threshold = atof(optarg);
	  cout<<"Threshold:"<<threshold<<endl;
	  break;
	case 'i':
	  if(strcmp(optarg,"image")==0)
	    input_mode = IN_IMG;
	  else if(strcmp(optarg,"video")==0)
	    input_mode = IN_VIDEO;
	  else
	  {
	    printf("Invalid option for input\n");
	    exit(1);
	  }
	  break;
	case 'o':
	  if(strcmp(optarg,"text")==0)
	    output_mode = OUT_TEXT;
	  else if(strcmp(optarg,"file")==0)
	    output_mode = OUT_FILE;
	  else
	  {
	    printf("Invalid option for output\n");
	    exit(1);
	  }
	  break;
	case 'd':
	  if(strcmp(optarg,"on")==0)
	    disp_mode = DISP_ON;
	  else if(strcmp(optarg,"off")==0)
	    disp_mode = DISP_OFF;
	  else
	    {
	      printf("Invalid display mode\n");
	      exit(1);
	    }
	  break;
	case 't':
	  delay = atoi(optarg);
	  break;
	default:
	  printf("Unknown options:%c\n.exiting",param);
          exit(1);
	}
    }

  /*initialize opencv*/
  //cvInitSystem(argc,argv);
  //CvFont font;
  //cvInitFont(&font,CV_FONT_HERSHEY_PLAIN,1,1,0.0);
  /*CvVideoWriter* pvdo= cvCreateVideoWriter("out.avi",CV_FOURCC('I','4','2','0'),5,cvSize(128,128),0);*/
  //if(disp_mode == DISP_ON)
  //  cvNamedWindow("result",CV_WINDOW_AUTOSIZE);

  if(input_mode == IN_VIDEO)
   {
      printf("Sorry. Video input currently not supported\n");
      exit(1);
   }
  image img;
  const int nclass = model.nrule;
  out.resize(nclass+1);
  compare_outputs comp;

  for(int i = optind;i<(argc);i++)
    {
      if(input_mode == IN_IMG)
      {
	img = imread(argv[i]);
      }
      CvSize sz = img.dim();
      long start_time = clock();
      s1_baseline(img,fb,opt,s1);
      c1_baseline(s1,opt,c1);
      //c2_baseline(c1,s2,patches,opt,c2);
      long end_time   = clock();
      printf("Time:%f\n",(double)(end_time-start_time)/CLOCKS_PER_SEC);
#if DO_DEBUG
	  return 0;
      for(int _i=0;_i<c2.size();_i++)
        cout<<c2[_i]<<endl;
#endif
      model.classify(c2,scores);

      for(int k=0;k<nclass;k++)
      {
	  out[k].lbl   = model.labels[k];
	  out[k].score = scores[k];
      }
      out[nclass].lbl  = model.labels[nclass];
      out[nclass].score= threshold;


      sort(out.begin(),out.end(),comp);
      string str_result = out[nclass].lbl;
      //if(disp_mode   == DISP_ON)
      //{
   	  //cvPutText(img,str_result.c_str(),cvPoint(1,10),&font,CV_RGB(255,255,255));
	  //cvShowImage("result",img);
      //    cvWaitKey(delay);
      //}
      if(output_mode == OUT_TEXT)
      {
	cout<<argv[i]<<":"<<str_result<<endl;
      }
      else if(output_mode == OUT_FILE)
      {
	char file_name[256];
	sprintf(file_name,"out%04d.jpg",(i-optind));
	//cvPutText(img,str_result.c_str(),cvPoint(1,10),&font,CV_RGB(1,1,1));
	imwrite(img,file_name);
	cout<<argv[i]<<":"<<str_result<<endl;
      }
    }
  //cvDestroyAllWindows();
  /*cvReleaseVideoWriter(&pvdo);*/
  return 0;
}
