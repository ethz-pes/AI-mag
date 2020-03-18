function hash = get_struct_hash(data)

engine = java.security.MessageDigest.getInstance('MD5');
hash = get_hash_sub(data, engine);
hash = sprintf('%.2x', hash);

end

function hash = get_hash_sub(data, engine)

% init hash
hash = double(typecast(engine.digest, 'uint8'));

% hash felds
assert(isstruct(data), 'invalid data')
field = sort(fieldnames(data));  % ignore order of fields
for i=1:length(field)    
    hash = get_value(hash, engine, field{i});
    hash = get_value(hash, engine, data.(field{i}));
end

end

function hash = get_value(hash, engine, data)

assert(isnumeric(data)||islogical(data)||ischar(data), 'invalid data')

data = double(data);
engine.update(typecast(data(:), 'uint8'));
hash = bitxor(hash, double(typecast(engine.digest, 'uint8')));

end