/*!
*  
*
* sharat@mit.edu
*/
#include <image.h>
#include <exception>

using namespace std;
/*!
  @function image
  
 */
image::image()
{
  img = cvCreateImage(cvSize(1,1),IPL_DEPTH_32F,1);
  cvSetZero(img);
}

image::image(int ht,int wt)
{
  img = cvCreateImage(cvSize(wt,ht),IPL_DEPTH_32F,1);
  cvSetZero(img);
}

/*!
  copy constructor
 */
image::image(const image& rhs)
{
  img = cvCloneImage(rhs.img);
}

CvSize image::dim() const
{
  CvSize sz;
  sz.height = img->height;
  sz.width  = img->width;
  return sz;
}
/*!
  destructorOA
 */
image::~image()
{
  if(img)
    cvReleaseImage(&img);
}

/*!
 */
image& image::operator =(const image& rhs)
{
  if(this == &rhs)
    return *this;
  if(img) 
    cvReleaseImage(&img); 
  img = cvCloneImage(rhs.img);
  return *this;
}
/*!
 */
image& image::operator=(const float val)
{
  cvSet(img,cvRealScalar(val));  
  return *this;
}

/*!
 */
image::image(IplImage* img)
{
  this->img = cvCloneImage(img);
}


/*!
 */
float* image::operator[](int n)
{
  return (float*)(img->imageData+ n*img->widthStep);
}

/*!
 */
const float* image::operator[](int n) const
{
  return (const float*)(img->imageData+ n*img->widthStep);
}

float image::min() const
{
  CvPoint min_pos,max_pos;
  double  min_val,max_val;
  cvMinMaxLoc(img,&min_val,&max_val,&min_pos,&max_pos);
  return (float)min_val;
}

float image::norm() const
{
  return (float)cvNorm(img);
}

float image::max() const
{
  CvPoint min_pos,max_pos;
  double  min_val,max_val;
  cvMinMaxLoc(img,&min_val,&max_val,&min_pos,&max_pos);
  return (float)max_val;
}
 /*!
 */
image operator+(const image& lhs,const image& rhs)
{
  CvSize lhs_sz = lhs.dim();
  CvSize rhs_sz = rhs.dim();
  if((lhs_sz.width != rhs_sz.width) || (lhs_sz.height != rhs_sz.height))
    throw exception();
  image  result(lhs_sz.height,lhs_sz.width);
  cvAdd(lhs,rhs,result);
  return result;
}

/*!
 */
image operator-(const image& lhs,const image& rhs)
{
  CvSize lhs_sz = lhs.dim();
  CvSize rhs_sz = rhs.dim();
  if((lhs_sz.width != rhs_sz.width) || (lhs_sz.height != rhs_sz.height))
    throw exception();
  image  result(lhs_sz.height,lhs_sz.width);
  cvSub(lhs,rhs,result);
  return result;
}

/*!
 */
image operator*(const image& lhs,const image& rhs)
{
  CvSize lhs_sz = lhs.dim();
  CvSize rhs_sz = rhs.dim();
  if((lhs_sz.width != rhs_sz.width) || (lhs_sz.height != rhs_sz.height))
    throw exception();
  image  result = lhs;
  cvMul(lhs.img,rhs.img,result.img);
  return result;
}

/*!
 */
image operator /(const image& lhs,const image& rhs)
{
  CvSize lhs_sz = lhs.dim();
  CvSize rhs_sz = rhs.dim(); 
  if((lhs_sz.width != rhs_sz.width) || (lhs_sz.height !=rhs_sz.height))
    throw exception();
  image result = lhs;
  cvDiv(lhs,rhs,result);
  return result;
}

/*!
 */
image  max(const image& lhs,const image& rhs)
{
  CvSize lhs_sz = lhs.dim();
  CvSize rhs_sz = rhs.dim();
  if((lhs_sz.height != rhs_sz.height) || (lhs_sz.width != rhs_sz.width)) throw exception();
  image res = lhs;
  cvMax(lhs,rhs,res);
  return res;
}

/*!
 */
image  sqrt(const image& img)
{
  CvSize sz = img.dim();
  image res = img;
  for(int i=0;i<sz.height;i++)
    for(int j=0;j<sz.width;j++)
      res[i][j]=sqrt(img[i][j]+1e-14);
  return res;
}

/*!
 */
image abs(const image& img)
{
  CvSize sz = img.dim();
  image res(sz.height,sz.width);
  for(int i=0;i<sz.height;i++)
    for(int j=0;j<sz.width;j++)
      res[i][j] = fabs(img[i][j]);
  return res;
}


/*!
 */
image operator+(const image& lhs,float val)
{
  CvSize lhs_sz = lhs.dim();
  image  result(lhs_sz.height,lhs_sz.width);
  cvAddS(lhs,cvRealScalar(val),result);
  return result;
}


/*!
 */
image operator-(const image& lhs,float val)
{
  CvSize lhs_sz = lhs.dim();
  image  result(lhs_sz.height,lhs_sz.width);
  cvSubS(lhs,cvRealScalar(val),result);
  return result;
}

/*!
 */
image operator*(const image& lhs,float val)
{
  CvSize lhs_sz = lhs.dim();
  image  result(lhs_sz.height,lhs_sz.width);
  cvScale(lhs,result,val);
  return result;
}
 /*
 */
 image  imread(const char* file_name)
 {
   IplImage* img = cvLoadImage(file_name,0);
   image res(img->height,img->width);
   for(int i=0;i<img->height;i++)
     for(int j=0;j<img->width;j++)
       {
	 unsigned char val =  cvGetReal2D(img,i,j);
	 cvSetReal2D(res,i,j,(float)val/255);
       }
   if(!img) throw exception();
   cvReleaseImage(&img);
   return res;
	return image(1,1);
 }
 
/*!
 */
 
 void   imwrite(image& img,const char* file_name)
{
 CvSize sz       = img.dim();
  IplImage* dst   = cvCreateImage(sz,IPL_DEPTH_8U,1);
  cvConvertScale(imscale(img),dst,255);
  int ret         = cvSaveImage(file_name,dst);
  if(!ret) throw exception();
  cvReleaseImage(&dst);
}

 /*!
  */
image imscale(image& img)
{
  CvPoint min_pos;
  CvPoint max_pos;
  float  min_val  = 1e10;
  float  max_val  = -1e10;
  image  result    = img;
  /*get max and min*/
  CvSize sz = img.dim();
  for(int i=0;i<sz.height;i++)
    for(int j=0;j<sz.width;j++)
      {
	float pxval=img[i][j];
	if(pxval > max_val) max_val = pxval;
	if(pxval < min_val) min_val = pxval;
      }
  float scale     = 1.0/(max_val-min_val+1e-10); 
  cvConvertScale(img,result,scale,-min_val*scale);
  return result;
}

image imresize(const image& img,int ht,int wt)
{
  image res(ht,wt);
  cvResize(img,res);
  return res;
}

 /*!
  */
 void imdisplay(image& img,const char* title)
 {
  CvSize sz       = img.dim();
  IplImage* dst   = cvCreateImage(sz,IPL_DEPTH_8U,1);
  cvConvertScale(imscale(img),dst,255);
  cvNamedWindow(title,CV_WINDOW_AUTOSIZE);
  cvShowImage(title,dst);
  cvWaitKey(1);
  cvReleaseImage(&dst);
 }


/*!
 */
ostream& operator<<(ostream & out,const image& img)
{
  CvSize sz = img.dim();
  out<<sz.height<<" " <<sz.width<<endl;
  /*output dimensions*/
  for(int i=0;i<sz.height;i++)
    {
    for(int j=0;j<sz.width;j++)
      out<<img[i][j]<<"  ";
    out<<endl;
    }
  return out;
}

/*!
*/
istream& operator>>(istream& in,image& img)
{
  int height = 0;
  int width  = 0;
  in >> height >> width;
  /*create the image*/
  img = image(height,width);
  for(int i=0;i<height;i++)
    for(int j=0;j<width;j++)
      in>>img[i][j];
  return in;
}


