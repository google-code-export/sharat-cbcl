function path = startdir

path = fileparts(which('startup.m'));

if isempty(path)
    error('cannot find startup.m');
end

return;
