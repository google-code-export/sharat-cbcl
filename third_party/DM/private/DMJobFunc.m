function varargout = DMJobFunc(func, op, req, p, varargin)

% DMJobFunc - Internal function.

%***********************************************************************************************************************

a = feval(func, p);

if isfield(a, op)
    [varargout{1 : nargout}] = feval(a.(op), p, varargin{:});
elseif ~req
    [varargout{1 : nargout}] = deal([]);
else
    if isa(func, 'function_handle'), func = func2str(func); end
    error('function "%s": operation "%s" not supported', func, op);
end

return;
