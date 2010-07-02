/*!
*  
*
* sharat@mit.edu
*/
#ifndef __opts_h__
#define __opts_h__

using namespace std;
#include <iostream>
#include <string>
#include <vector>
#include <string>
typedef struct 
{
  int nscales;
  int nbands;
  int ndirs; 
  vector<string> classes;
  vector<int> scale_sum;
  vector<int> space_sum;
}model_options;

#endif
