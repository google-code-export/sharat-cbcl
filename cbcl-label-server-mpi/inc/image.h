/*!
*  
*
* sharat@mit.edu
*/
#ifndef __image_h__
#define __image_h__
#include <iostream>
#include <cxcore.h>
#include <cv.h>
#include <cvaux.h>
#include <highgui.h>

using namespace std;
 /*!
   @class image
   @abstract a wrapper for the openCV image structure 
 */
 class image
   {
     /*private iplImgehandle*/
   public:
     image();
     IplImage* img;
     image(int ht,int wt);
     image(IplImage* img);
     ~image();
     image(const image& rhs);
     image& operator = (const image& rhs); 
     image& operator = (const float val);
     operator CvArr*() {return (CvArr*)img;}
     operator const CvArr*() const {return (CvArr*)img;} 
     operator const IplImage*() const {return img;}
     float* operator[](int n);
     const float* operator[](int n) const;
     float min() const;
     float max() const;
     CvSize dim() const;
     float norm() const;
   };


 /*!
  */
 image operator +(const image& lhs,const image& rhs);
 /*!
  */
 image operator - (const image& lhs,const image& rhs);
 /*!
  */
 image operator *(const image& lhs,const image& rhs);
 /*!
  */
 image operator /(const image& lhs,const image& rhs);
 /*!
  */
 image  max(const image& lhs,const image& rhs);

/*!
 */
 image abs(const image& img);
/*!
 */
image  sqrt(const image& img);

 /*!
  */
 image operator + (const image& lhs, float val);
 /*!
  */
 image operator *(const image& lhs,float val);
 /*!
  */
 image operator -(const image& lhs,float val);
 /*!
  */
 image  imread(const char* file_name);
  /*!
 */
 void   imwrite(image& img,const char* file_name);
 /*!
  */
 image imscale(image& img);
 /*!
  */
 void imdisplay(image& img,const char* title);

 /*!
  */
 image imresize(const image& img,int ht,int wt);
/*!
 */
 ostream & operator <<(ostream& out,const image& img);
 /*!
 */
 istream& operator >> (istream & in,image & img);

#endif
