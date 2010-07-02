/*!
*  
*
* sharat@mit.edu
*/
#include "rule.h"

double rule::classify(const vector<double> &ftr)
{
  double res = bias;
  int    sz  = (int)ftr.size();
  for(int i=0;i<sz;i++)
  {
    res += w[i]*ftr[i];
  }
  return res;
}

ostream& operator <<(ostream& out,const rule& rl)
{
  out<<rl.bias<<endl; 
  out<<rl.w.size()<<endl;
  for(unsigned int i=0;i<rl.w.size();i++)
    out<<rl.w[i]<<" ";
  out<<endl;
  return out;
}

istream& operator >>(istream &in,rule& rl)
{
  int sz;
  in >> rl.bias;
  in >> sz; 
  rl.w.resize(sz);
  for(int i=0;i<sz;i++)
    in >> rl.w[i];
	return in;
}
