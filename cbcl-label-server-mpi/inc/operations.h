/*!
*  
*
* sharat@mit.edu
*/
#ifndef __oper_h__
#define __oper_h__

#include "image.h"
#include "filter.h"
#include <functional>

  /*!
    @class    conv
    @abstract functor
   */
class conv2d
  {
  public:
    image operator()(const image&, const  filter & filt);
  };

/*!
  @class xcorr
  @abstract functor that performs normalized cross correlation
 */
class xcorr2d
{
 public:
  image operator() (const image& img,const filter & filt);
};

class dist2d
{
public:
    image operator() (const image& img,const filter & filt);
};

 /*!
 */
class hmax
   {
   public:
     image operator()(const image& img,const int pool,const int shift);
   };
#endif
