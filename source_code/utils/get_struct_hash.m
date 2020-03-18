function hash = get_struct_hash(data)

engine = java.security.MessageDigest.getInstance('MD5');
hash = double(typecast(engine.digest, 'uint8'));
hash = get_hash_struct(hash, engine, data);
hash = sprintf('%.2x', hash);

end

function hash = get_hash_struct(hash, engine, data)

assert(isstruct(data), 'invalid data')
assert(numel(data)==1, 'invalid data')

% hash felds
field = sort(fieldnames(data));  % ignore order of fields
for i=1:length(field)    
    hash = get_hash_value(hash, engine, field{i});
    
    value = data.(field{i});
    if isstruct(value)
        assert(numel(value)==1, 'invalid data')
        hash = get_hash_struct(hash, engine, value);
    elseif isnumeric(value)||islogical(value)
        assert(size(value, 1)==1, 'invalid data')
        hash = get_hash_value(hash, engine, value);
    end
end

end

function hash = get_hash_value(hash, engine, data)

data = double(data);
engine.update(typecast(data(:), 'uint8'));
hash = bitxor(hash, double(typecast(engine.digest, 'uint8')));

end