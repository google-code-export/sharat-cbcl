/***********************************************************************************************************************
* function hostName = GLHostName
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

#include "GLCommon.h"

/**********************************************************************************************************************/

#if defined(MEX_OS_LINUX)

#include <sys/unistd.h>

void GetHostNameOS(char *hostName) {

    if (gethostname(hostName, 512) != 0) hostName[0] = 0;

}

/**********************************************************************************************************************/

#elif defined(MEX_OS_WIN)

#include <winsock2.h>
#pragma comment(lib, "ws2_32")

void GetHostNameOS(char *hostName) {

    if (gethostname(hostName, 512) != 0) hostName[0] = 0;

}

/**********************************************************************************************************************/

#else

void GetHostNameOS(char *hostName) {

    GLErrMsg("unsupported architecture");

}

#endif

/**********************************************************************************************************************/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    if (nrhs != 0) GLErrMsg("incorrect number of rhs arguments");
    if (nlhs >  1) GLErrMsg("incorrect number of lhs arguments");

    char hostName[512];

    GetHostNameOS(hostName);

    plhs[0] = mxCreateString(hostName);

}
