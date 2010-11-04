function var = envvar(name, dflt)

if ~isempty(which(name))
    var = feval(name);
elseif nargin == 2
    var = dflt;
else
    error('environment variable "%s" not found', name);
end    

return;
