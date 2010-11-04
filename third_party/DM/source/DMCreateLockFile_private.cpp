/***********************************************************************************************************************
* function created = DMCreateLockFile(lockFilePath, existingFilePath)
***********************************************************************************************************************/

#include "GLCommon.h"

/**********************************************************************************************************************/

#if defined(MEX_OS_LINUX)

#include <sys/unistd.h>

bool CreateLockFileOS(const char *lockFilePath, const char *existingFilePath) {

    if (existingFilePath[0] == 0) GLErrMsg("existing file required to create lock");

    return (link(existingFilePath, lockFilePath) == 0);

}

/**********************************************************************************************************************/

#elif defined(MEX_OS_WIN)

#define _WIN32_WINNT 0x0500
#include <windows.h>

bool CreateLockFileOS(const char *lockFilePath, const char *existingFilePath) {

    if (existingFilePath[0] == 0) GLErrMsg("existing file required to create lock");

    return CreateHardLink(lockFilePath, existingFilePath, NULL);

}

/**********************************************************************************************************************/

#else

bool CreateLockFileOS(const char *lockFilePath, const char *existingFilePath) {

    GLErrMsg("unsupported architecture");

    return false;

}

#endif

/**********************************************************************************************************************/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    if (nrhs != 2) GLErrMsg("incorrect number of rhs arguments");
    if (nlhs >  1) GLErrMsg("incorrect number of lhs arguments");

    char lockFilePath[512], existingFilePath[512];

    mxGetString(prhs[0], lockFilePath    , 512);
    mxGetString(prhs[1], existingFilePath, 512);

    bool created = CreateLockFileOS(lockFilePath, existingFilePath);

    plhs[0] = mxCreateLogicalScalar(created);

}
