/*!
*  
*
* sharat@mit.edu
*/
#ifndef __CBCL_MODEL_INC_H__
#define __CBCL_MODEL_INC_H__

#define IN 
#define OUT

/*!
  error definitions
*/
#define CBCL_ERR_NONE             0 
#define CBCL_ERR_INTERNAL_ERROR  -1 
#define CBCL_ERR_INVALID_PARAM   -2


typedef void* CBCL;

/*!
 */
CBCL cbcl_initalize();
/*!
  @function cbcl_extract_features
*/
int cbcl_get_features(CBCL IN model,unsigned char* IN img,int IN img_ht,int IN img_wt,int IN x,int y,int ht,int wt,double* ftr);

/*!
  @function cbcl_feature_length
  @abstract returns the feature length 
  @returns 
*/
int cbcl_feature_length(CBCL model);

/*!
  @function 
 */
int cbcl_classify_features(CBCL model, double* ftr,char* class_name);

/*!
 */
void cbcl_finalize(CBCL model);

#endif
