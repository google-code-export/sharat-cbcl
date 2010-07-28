function val = subsref(hash,index)

switch index.type
case '()'
if (length(index.subs) ~= 1)
error('Only single indexing is supported.');
end
val = get(hash,index.subs{1});
case '.'
val = get(hash,index.subs);
otherwise
error('Invalid type.')
end
