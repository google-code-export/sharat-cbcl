/*!
*  
*
* sharat@mit.edu
*/

#include "svm_model.h"
#include <iostream>
#include <fstream>
#include <vector>

using namespace std;

void svm_model::classify(const vector<double>& ftr,vector<double>& scores)
{
  int len = (int)ftr.size();
  scores.clear();scores.resize(nrule);
  for(int i=0;i<nrule;i++)
  {
    scores[i] = rules[i].classify(ftr);
  }
}

void load_model(const char* fname,svm_model &model)
{
  ifstream fin;
  int len;
  string lbl;
  fin.open(fname,ifstream::in);
  fin >> model.nrule;
  model.labels.clear();
  for(int i=0;i<model.nrule;i++)
  {
    fin>>lbl;
    model.labels.push_back(lbl);
  }
  model.labels.push_back("none");

  model.rules.resize(model.nrule);
  for(int i=0;i<model.nrule;i++)
    fin >> model.rules[i];
  fin.close();
}
