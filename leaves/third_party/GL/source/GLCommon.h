/***********************************************************************************************************************
* Common functionality for MEX functions.
************************************************************************************************************************
*
* Copyright (C) 2007  Jim Mutch  (www.jimmutch.com)
*
* This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later
* version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with this program.  If not, see
* <http://www.gnu.org/licenses/>.
*
***********************************************************************************************************************/

#include "mex.h"

#include <stdarg.h>

/**********************************************************************************************************************/

#define int8   INT8_T
#define uint8  UINT8_T
#define int16  INT16_T
#define uint16 UINT16_T
#define int32  INT32_T
#define uint32 UINT32_T

/**********************************************************************************************************************/

void *operator new(size_t size);
void *operator new[](size_t size);

void operator delete(void *ptr);
void operator delete[](void *ptr);

void GLErrMsg(const char *format, ...);
void GLOutMsg(const char *format, ...);

double GLRand();
int32  GLRand(int32 min, int32 max);

mxArray *GLGetField(const mxArray *structure, const char *fieldName);

void GLCopyToInt32(const mxArray *array, int32 maxM, int32 maxN, int32 *values, int32 adjust = 0);

/**********************************************************************************************************************/

void *operator new(size_t size) {

    return mxMalloc(size);

}

/**********************************************************************************************************************/

void *operator new[](size_t size) {

    return mxMalloc(size);

}

/**********************************************************************************************************************/

void operator delete(void *ptr) {

    mxFree(ptr);

}

/**********************************************************************************************************************/

void operator delete[](void *ptr) {

    mxFree(ptr);

}

/**********************************************************************************************************************/

void GLErrMsg(const char *format, ...) {

    va_list argList;
    char    msg[1024];

    va_start(argList, format);
    vsprintf(msg, format, argList);
    va_end(argList);

    mexErrMsgTxt(msg);

}

/**********************************************************************************************************************/

void GLOutMsg(const char *format, ...) {

    va_list argList;
    char    msg[1024];

    va_start(argList, format);
    vsprintf(msg, format, argList);
    va_end(argList);

    mxArray *array = mxCreateString(msg);
    mexCallMATLAB(0, NULL, 1, &array, "fprintf");
    mxDestroyArray(array);

    mexEvalString("drawnow");

}

/**********************************************************************************************************************/

double GLRand() {

    mxArray *out = mxCreateDoubleMatrix(1, 1, mxREAL);

    mexCallMATLAB(1, &out, 0, NULL, "rand");

    double random = mxGetScalar(out);

    mxDestroyArray(out);

    return random;

}

/**********************************************************************************************************************/

int32 GLRand(int32 min, int32 max) {

    if (min >= max) return min;

    int32 val = (int32)(GLRand() * (double)(max - min + 1)) + min;

    if (val < min) return min;
    if (val > max) return max;

    return val;

}

/**********************************************************************************************************************/

mxArray *GLGetField(const mxArray *structure, const char *fieldName) {

    mxArray *field = mxGetField(structure, 0, fieldName);

    if (field == NULL) GLErrMsg("field '%s' missing", fieldName);

    return field;

}

/**********************************************************************************************************************/

void GLCopyToInt32(const mxArray *array, int32 maxM, int32 maxN, int32 *values, int32 adjust) {

    int32 m = mxGetM(array);
    int32 n = mxGetN(array);

    if (maxN == 1) {
        m = m * n;
        n = 1;
        if (m > maxM) GLErrMsg("array contains %u elements, only %u allowed", m, maxM);
    } else {
        if (m > maxM) GLErrMsg("array contains %u rows, only %u allowed", m, maxM);
        if (n > maxN) GLErrMsg("array contains %u columns, only %u allowed", n, maxN);
    }

    double *ptr = mxGetPr(array);

    for (int32 i = 0; i < m; i++) {
        for (int32 j = 0; j < n; j++) {

            values[i * maxN + j] = (int32)ptr[j * m + i] + adjust;

        }
    }

}
