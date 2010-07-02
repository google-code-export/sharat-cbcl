/*!
*  
*
* sharat@mit.edu
*/
#include  <image.h>
#include  <filter.h>
#include <iostream>
#include <fstream>

using namespace std;

/*!
 */
filter::filter(const filter& rhs)
{
  img = cvCloneImage(rhs.img);
}

filter& filter::operator=(const image& rhs)
{
  if(img)
    cvReleaseImage(&img);
  img = cvCloneImage(rhs.img);
  return *this;
}

/*!
 */
filter& filter::operator =(const filter&rhs)
{
  if(&rhs == this)
    return *this;
  if(img)
    cvReleaseImage(&img);
  img = cvCloneImage(rhs.img);
  return *this;
}


/*!
 */
ostream& operator<<(ostream & out,const filter& filt)
{
  CvSize sz = filt.dim();
  out<<sz.height<<" " <<sz.width<<endl;
  /*output dimensions*/
  for(int i=0;i<sz.height;i++)
    {
    for(int j=0;j<sz.width;j++)
      out<<filt[i][j]<<"  ";
    out<<endl;
    }
  return out;
}

/*!
*/
istream& operator>>(istream& in,filter& filt)
{
  int height = 0;
  int width  = 0;
  in >> height >> width;
  /*create the filter*/
  filt = filter(height,width);
  float tVal = 0.;
  for(int i=0;i<height;i++)
	  for(int j=0;j<width;j++) {
		in>>tVal;
		filt[i][j] = tVal;

	  }
  return in;
}

