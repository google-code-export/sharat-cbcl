/*!
*  
*
* sharat@mit.edu
*/
#ifndef __rule_h__
#define __rule_h__
#include <vector>
#include <iostream>
using namespace std;
class rule
{
 public:
  int    lbl;
  double bias;
  vector<double> w;
  double classify(const vector<double> &ftr);
};

ostream& operator <<(ostream& out,const rule& rule);
istream& operator >>(istream& in,rule& rule);
#endif
