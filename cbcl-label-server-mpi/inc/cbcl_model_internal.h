/*!
*  
*
* sharat@mit.edu
*/
#ifndef __cbcl_model_internal_h__
#define __cbcl_model_internal_h__

#include "image.h"
#include "filter.h"
#include "opts.h"
#include "operations.h"
#include <vector>

/*!
 */
void s1_baseline(const image& img,const vector<filter>& filt,const model_options& opts,vector<image>& s1);

/*!
*/
void c1_baseline(const vector<image>& s1,const model_options& opts,vector<image>& c1);

/*!
*/
void c2_baseline(const vector<image>& c1,vector<image>& s2,const vector<filter>& filt,const model_options& opts,vector<double>& c2);
#endif
