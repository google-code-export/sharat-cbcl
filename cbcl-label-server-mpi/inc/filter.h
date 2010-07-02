/*!
*  
*
* sharat@mit.edu
*/
#ifndef __filter_h__
#define __filter_h__

#include <image.h>
#include <iostream>
#include <vector>

using namespace std;

class filter:public image
{
 public: 
  filter():image(1,1){}
  filter(int height,int width):image(height,width){}
  filter(const filter& rhs);
  filter& operator=(const filter& rhs);
  filter& operator=(const image& rhs);
};

/*!
 */
 ostream & operator <<(ostream& out,const filter& filt);
 /*!
 */
 istream& operator >> (istream & in,filter & filt);
#endif
