function DMDiffParams(jobName1, jobName2, same, varargin)

% DMDiffParams - Compare the parameters of two jobs.
%
% TODO

%***********************************************************************************************************************

if nargin < 3, same = false; end

p1 = DMReadParams(jobName1, varargin{:});
p2 = DMReadParams(jobName2, varargin{:});

fprintf('\n');

vdiff(p1, p2, same);

fprintf('\n');

return;
