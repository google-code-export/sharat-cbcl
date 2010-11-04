function params = DMReadParams(jobName, varargin)

% DMReadParams - Read the parameters of an existing job.
%
% TODO

%***********************************************************************************************************************

if ischar(jobName)

    if ismember(jobName, {'', '@'}), error 'invalid job name'; end

    if jobName(1) ~= '@'
        params = DMReadTask(jobName, 'params');
        return;
    end

    params = feval(jobName(2 : end), varargin{:});

elseif isa(jobName, 'function_handle')

    params = jobName(varargin{:});

elseif isstruct(jobName)

    params = jobName;

else

    error 'invalid job name';

end

params.date = datestr(now, 30);

if isfield(params, 'jobFunc')
    newParams = DMJobFunc(params.jobFunc, 'check', false, params);
    if ~isempty(newParams), params = newParams; end
end

return;
