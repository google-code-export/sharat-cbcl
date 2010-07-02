#include "nv2_common.h"
#include "nv2_label_server.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#if 0
#include "image.h"
#include "filter.h"
#include "operations.h"
#include "cbcl_model_internal.h"
#include "svm_model.h"
#endif
#include "opts.h"
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <string>
#include <vector>
#include <deque>
#include "nv2_common.h"
#include <getopt.h>
#include <mpi.h> 
#include <pthread.h>

using namespace std;
/************************
* GLOBAL
* *********************/
int   __mpi_rank;
int   __mpi_size; 
#define SZ_OFF   0
#define DATA_OFF 1000000
#define RES_OFF  2000000
#define RES2_OFF 3000000
#define ID_OFF   4000000

#define MAX_SZ      512
typedef struct __tag_out
{
public:
  double score; 
  string lbl;
  int    cls;
}output_t;

class compare_outputs:binary_function<output_t,output_t,bool>
{
public:
  bool operator()(const output_t& lhs,const output_t& rhs)
  {
    return lhs.score < rhs.score;
  }
};

#if 0
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
  opt->nbands     = 8;
  opt->nscales    = 8;
  opt->ndirs      = 4;
  for(int i=0;i<opt->nbands;i++)
    {
      opt->scale_sum.push_back(start_stop[2*i]);
      opt->scale_sum.push_back(start_stop[2*i+1]);
      opt->space_sum.push_back(space_sum[i]);
    }
} 

image buf2img(const unsigned char* buf,int ht,int wt)
{
   image res(ht,wt);
   for(int i=0;i<ht;i++)
   {
     for(int j=0;j<wt;j++)
       res[i][j] = (double)buf[i*wt+j]/255;
   } 
   return res;
}
#endif 

void* sender_thread(void* thread_data)
{
  struct nv2_label_server* s  =    (struct nv2_label_server*)thread_data;
  int curr                    =    0;
  int psz[3]                  =    {0,0,0};
  unsigned char *pdata        =    new unsigned char[100];
  int dest					  =    0;
   MPI_Status status;
  /*process the patches*/
  while (1)
  {
        struct     nv2_image_patch patch;
        const enum nv2_image_patch_result res = nv2_label_server_get_current_patch(s, &patch);
        if (res == NV2_IMAGE_PATCH_END)
        {
           fprintf(stdout, "ok, quitting\n");
           break;
        }
        else if (res == NV2_IMAGE_PATCH_NONE)
        {
          usleep(100);
		  fprintf(stdout, ".");
          continue;
        }
		dest = curr%(__mpi_size-1)+1;
		/*send the patch size*/
		psz[0]=patch.id; psz[1]=patch.height;psz[2]=patch.width;
		//psz[0]=curr; psz[1]=10;psz[2]=10;
		MPI_Send(psz,3,MPI_INT,dest,SZ_OFF+curr,MPI_COMM_WORLD);
		MPI_Send(pdata,psz[1]*psz[2],MPI_UNSIGNED_CHAR,dest,DATA_OFF+curr,MPI_COMM_WORLD);
	    /*send the patch data*/ 
        nv2_image_patch_destroy(&patch);
		curr++;
  }//end while
  /*kill every other process*/
  psz[0]  =	-1;
  int stop= dest;
  for(dest++;dest<__mpi_size;dest++,curr++)
	MPI_Send(psz,3,MPI_INT,dest,SZ_OFF+curr,MPI_COMM_WORLD);
  for(dest=1;dest<=stop;dest++,curr++)
	MPI_Send(psz,3,MPI_INT,dest,SZ_OFF+curr,MPI_COMM_WORLD);
  return 0;
}

void* receiver_thread(void* thread_data)
{
  struct nv2_label_server* s =    (struct nv2_label_server*)thread_data;
  int curr                   =    0;
  int psize[2]               =    {0,0};
  int patch_id               =    1;
  int dead_workers           =    0;
  MPI_Status status;
  char result[64];
  char result2[64];
  /*process the patches*/
  while(1)
  {
		int src   = curr%(__mpi_size-1)+1;
		/*receive the result*/
		MPI_Recv(&patch_id,1,MPI_INT,src,curr+ID_OFF,MPI_COMM_WORLD,&status);
		printf("got:%d from %d\n",patch_id,src);
		/*continue only after test*/
		if(patch_id< 0) 
		{
			dead_workers++;
			if(dead_workers == (__mpi_size-1)) break;
			++curr;
			continue;
		}
	   	MPI_Recv(result,64,MPI_CHAR,src,RES_OFF+curr,MPI_COMM_WORLD,&status);
		MPI_Recv(result2,64,MPI_CHAR,src,RES2_OFF+curr,MPI_COMM_WORLD,&status);
#if 1 		
		//----------------------------------------------------
	    //write the labels
    	//---------------------------------------------------
	    struct nv2_patch_label l;
    	l.protocol_version = NV2_LABEL_PROTOCOL_VERSION;
	    l.patch_id         = patch_id;
    	l.extra_info[0]    = 0;
		l.confidence       = 1;//(uint32_t)(NV2_MAX_LABEL_CONFIDENCE*tanh(out[NCLASS-1].score));
    	snprintf(l.source, sizeof(l.source), "%s","CBCL");
	    snprintf(l.name,64,result);
    	snprintf(l.extra_info,64,result2);
    	nv2_label_server_send_label(s, &l);
    	fprintf(stdout, "sent label '%s'\n", l.name);
#endif
		curr++;
	}
	printf("exiting receiver thread\n");
	return 0;
}

void process_patch()
{
 	/*initialize output vector*/
	vector<image>           s1;
	vector<image>           c1;
	vector<image>           s2;
	vector<double>          c2;
	vector<double>          scores;
	vector<output_t>        out;
	typedef vector<double>  vec_double_t;
	deque<vec_double_t>   qout;
 
  	const int NCLASS = model.labels.size();
  	out.resize(NCLASS);
  	for(int j=0;j<NCLASS;j++)
  	{
    	 out[j].lbl   = model.labels[j];
  	}
 #if 0
	s1_baseline(img,fb,opt,s1);
    c1_baseline(s1,opt,c1);
    c2_baseline(c1,s2,patches,opt,c2);
    model.classify(c2,scores);
    scores.push_back(threshold);
    //---------------------------------------------------
    //process the scores
    //---------------------------------------------------
    qout.push_back(scores);
    if(qout.size()>(memory+1))
    {
       qout.pop_front();
    }
    for(int j=0;j<out.size();j++)
    {
       out[j].score = 0;
       out[j].lbl   = model.labels[j];
	   out[j].cls   = j;
    }
    //----------------------------------------------------
    //add confidence levels
    //----------------------------------------------------
    for(int i=0;i<qout.size();i++)
    {
       for(int j=0;j<qout[i].size();j++)
       {
          out[j].score += qout[i][j];
       }
    }
    sort(out.begin(),out.end(),comp_func);
#endif
} 

int main(int argc,char* argv[])
{
  using namespace std;
  vector<filter>          fb;
  vector<filter>          patches;
  svm_model               model;
#endif
  compare_outputs         comp_func;
  /*command line options*/
  string id                   = "CBCL";
  int    in_port              = NV2_PATCH_READER_PORT;
  string patch_server         = "127.0.0.1";
  int    out_port             = NV2_LABEL_READER_PORT;
  int    interval             = 1;
  double threshold            = 0;
  int    memory               = 0;

  /*get overriding options*/
  static struct option long_options[]= {
          {"in-port",1,0,0},
          {"out-port",1,0,0},
          {"patch-server",1,0,0},
          {"interval",1,0,0},
          {"memory",1,0,0},
          {"threshold",1,0,0},
          {0,0,0,0}
  };
  int     param;
  int     long_opt_index;

  if(argc<2)
    {
      printf("Usage is %s --in-port=<listen> --out-port=<send> --patch-server=<server name> --interval=<skip_interval> --memory=<accumulate len> --threshold=<background threshold>\n",argv[0]);
      return 1;
    }
 /*program arguments*/
  MPI_Init(&argc,&argv); 
  MPI_Comm_rank(MPI_COMM_WORLD,&__mpi_rank);
  MPI_Comm_size(MPI_COMM_WORLD,&__mpi_size);
  cout<<"MPI Size"<<__mpi_size<<",MPI_Rank"<<__mpi_rank<<endl;
  while((param= getopt_long(argc,argv,"m:t:",long_options,&long_opt_index))!=-1)
  {
          switch(long_opt_index)
          {
          case 0:
                  in_port    = atoi(optarg);
                  break;
          case 1:
                  out_port   = atoi(optarg);
                  break;
          case 2:
                  patch_server=optarg;
                  break;
          case 3:
                  interval    = atoi(optarg);
                  break;
          case 4:
                  memory      = atoi(optarg);
                  break;
          case 5: 
                  threshold   = atof(optarg);
                  break;
          }
  }
  /*dump options*/
  cout<<"Identity    : "<<id<<endl;
  cout<<"Patch Server: "<<patch_server<<endl;
  cout<<"IN  port    : "<<in_port<<endl;
  cout<<"OUT port    : "<<out_port<<endl;
  cout<<"Memory      : "<<memory<<endl;
  cout<<"Threshold   : "<<threshold<<endl;
  if(__mpi_rank == 0)
  {
	 /*create server*/
  	 struct nv2_label_server* s =    nv2_label_server_create(in_port,
                                     patch_server.c_str(),
                                     out_port);
  	/*create receive thread*/
  	pthread_t *  threads = new pthread_t[2];
  	pthread_create(&threads[0],NULL,sender_thread,s);
  	pthread_create(&threads[1],NULL,receiver_thread,s);
	/*wait for the threads*/
	int status;
	pthread_join(threads[0],(void**)&status);
	pthread_join(threads[1],(void**)&status);
    /*clean up the server*/
	nv2_label_server_destroy(s);
  }
  else
  {
	unsigned char* buff = new unsigned char[MAX_SZ*MAX_SZ]; //max image size
	int curr    = (__mpi_rank-1);
	int patch_id= 1;
	/*read patches*/
	char result[64];
	char result2[64];
  	image img; 
  	model_options opt;
  	init_opts(&opt);
  	load_filter("gabor_bank.txt",fb);
  	load_filter("patches.txt",patches);
  	load_model("svm_model.txt",model);
    //---------------------------------------------------
    //classify the image
    //----------------------------------------------------
    img = buf2img(p.data,p.height,p.width);
	img=imresize(img,128,(float)p.width/p.height*128);
	
	while(1)
	{
		MPI_Status status;
		int sz[3];
		/*receive patch id & size*/
		MPI_Recv(sz,3,MPI_INT,0,SZ_OFF+curr,MPI_COMM_WORLD,&status);
		MPI_Send(sz,1,MPI_INT,0,ID_OFF+curr,MPI_COMM_WORLD);
		if(*sz<0) break; /*halt condition*/
	    /*receive patch data*/
		MPI_Recv(buff,sz[1]*sz[2],MPI_UNSIGNED_CHAR,0,DATA_OFF+curr,MPI_COMM_WORLD,&status);
		/*process patch*/
		/*process_image(img,fp,patches,model,opt,result,result2);*/
	   	/*stub for now*/
	   	sprintf(result,"%d",curr);
		sprintf(result2,"%d",curr);	
		/*send the result back to receiver thread*/
		printf("worker:%d, processing patch : %d\n",__mpi_rank,sz[0]);
	    MPI_Send(result,64,MPI_CHAR,0,RES_OFF+curr,MPI_COMM_WORLD);
	    MPI_Send(result2,64,MPI_CHAR,0,RES2_OFF+curr,MPI_COMM_WORLD);	
		curr += (__mpi_size-1);	
	 }/*end while*/
	}/*end if*/
	printf("worker:%d going home\n",__mpi_rank);
    MPI_Barrier(MPI_COMM_WORLD);	
	MPI_Finalize();
	return 0;
}


