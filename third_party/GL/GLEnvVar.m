function var = GLEnvVar(name)

% GLEnvVar - Edit this function to provide needed settings (eg. paths).
%
% There are some settings (such as the paths of certain directories) that you
% must provide when you install the toolbox.  This is done by editing the
% GLEnvVar.m file, which contains these settings.
%
% You may want to move the GLEnvVar.m file to another location so that your
% settings are not overwritten when you download a new version of the toolbox.
% Another reason to move GLEnvVar.m is to allow multiple users to share the same
% copy of the toolbox while having different settings.  The only requirement is
% that GLEnvVar.m be on the MATLAB path.
%
% See also: GLSetPath, GLCompile.

%***********************************************************************************************************************

switch name
case 'glInputPath'

    % Base path under which input data directories (such as image datasets) reside.  Setting this path here lets you
    % avoid using absolute paths throughout your code; you can instead specify paths relative to this path.  For
    % example, the Caltech 101 dataset might be identified by "%i/cal101".

    % var = [getenv('HOME') '/???'];

case 'glTempPath'

    % A path for temporary files.  Sometimes temporary files are used for communication between processes running on
    % different machines.  Hence this directory should be located on a shared file system.

    % var = [getenv('HOME') '/???'];

end

return;
