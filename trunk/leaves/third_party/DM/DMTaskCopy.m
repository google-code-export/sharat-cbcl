function r = DMTaskCopy(varargin)

% DMTaskCopy - Task function for copying or renaming the result of another task.
%
% TODO

%***********************************************************************************************************************

r.build = @stage_build;

return;

%***********************************************************************************************************************

function r = stage_build(p, input)

r = input;

return;
