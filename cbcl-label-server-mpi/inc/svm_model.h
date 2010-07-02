/*!
*  
*
* sharat@mit.edu
*/
#ifndef __svm_model_h__
#define __svm_model_h__

#include "rule.h"
#include <vector>
#include <string>

class svm_model
{
 public:
  int nrule;
  vector<string> labels;
  vector<rule> rules;
  void classify(const vector<double> & f,vector<double> & scores);
};

void load_model(const char* filename,svm_model& model);
#endif
