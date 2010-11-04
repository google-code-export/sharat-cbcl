/***********************************************************************************************************************
* function DMSleep(seconds)
***********************************************************************************************************************/

#include "GLCommon.h"

/**********************************************************************************************************************/

#if defined(MEX_OS_LINUX)

#include <sys/unistd.h>

void SleepOS(uint32 seconds) {

    sleep(seconds);

}

/**********************************************************************************************************************/

#elif defined(MEX_OS_WIN)

#include <windows.h>

void SleepOS(uint32 seconds) {

    Sleep(seconds * 1000);

}

/**********************************************************************************************************************/

#else

void SleepOS(uint32 seconds) {

    GLErrMsg("unsupported architecture");

}

#endif

/**********************************************************************************************************************/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    if (nrhs != 1) GLErrMsg("incorrect number of rhs arguments");
    if (nlhs != 0) GLErrMsg("incorrect number of lhs arguments");

    uint32 seconds = (uint32)mxGetScalar(prhs[0]);

    SleepOS(seconds);

}
