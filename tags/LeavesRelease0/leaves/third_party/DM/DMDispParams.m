function r = DMDispParams(jobName, varargin)

% DMDispParams - Display the parameters of a job.
%
% TODO

%***********************************************************************************************************************

params = DMReadParams(jobName, varargin{:});

if isfield(params, 'jobFunc')
    jobFunc = params.jobFunc;
else
    jobFunc = '';
end

output = sprintf('\n');

fields = {'desc', 'date', 'jobFunc'};
temp = GLCopyFields(struct, params, fields);
output = [output evalc('disp(temp)')];
params = GLRemoveFields(params, fields);
params = GLRemoveFields(params, 'tasks');

if isempty(jobFunc)
    newOutput = [];
else
    newOutput = DMJobFunc(jobFunc, 'disp', false, params);
end

if isempty(newOutput)
    newOutput = evalc('disp(orderfields(params))');
end

output = [output newOutput];

if nargout == 0
    GLDispText(output);
else
    r = output;
end

return;
