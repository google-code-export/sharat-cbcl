function DMCreateJob(jobDir, params, varargin)

% DMCreateJob - Generate and save a set of parameters for a distributed job.
%
% TODO

%    JOBDIR - the job directory.  This is a relative path; the actual locations
%    at which parameter/result files and work files will be stored is determined
%    by the 'resdir' and 'workdir' environment variables.

%***********************************************************************************************************************

if DMReadTask(jobDir, 'params', 'exist'), error 'job already exists'; end

if ischar(params)

    if ismember(params, {'', '@'}), error 'invalid params'; end

    if params(1) ~= '@', params = ['@' params]; end

elseif isa(params, 'function_handle')
elseif isstruct(params)
else

    error 'invalid params';

end

params = DMReadParams(params, varargin{:});

DMWriteTask(jobDir, 'params', params, 'p');

return;
