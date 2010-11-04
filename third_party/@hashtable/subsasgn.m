function hash = subsasgn(hash,index,val)

switch index.type
case '()'
if (length(index.subs) ~= 1)
error('Only single indexing is supported.');
end
hash = put(hash,index.subs{1},val);
case '.'
hash = put(hash,index.subs,val);
otherwise
error('Invalid type.')
end
