function hash = get_struct_hash(data)
% Compute a MD5 hash of a struct of vectors.
%
%    Warning: MD5 hash are not anymore cryptographically secure.
%             This function should not be used for cryptographic purposes.
%
%    The following data are accepted:
%        - The struct can contains other sub-structs
%        - The struct can contains numeric or logical vectors
%        - The vectors are row vectors
%
%    Parameters:
%        data (struct): struct of vectors
%
%    Returns:
%        hash (str): computed hash (hexadecimal format)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init the hash engine
engine = java.security.MessageDigest.getInstance('MD5');
hash = double(typecast(engine.digest, 'uint8'));

% get the hash
hash = get_hash_struct(hash, engine, data);

% transform the hash the hexadecimal string
hash = sprintf('%.2x', hash);

end

function hash = get_hash_struct(hash, engine, data)
% Compute a MD5 hash of a struct of vectors with a hash engine.
%
%    The following data are accepted:
%        - The struct can contains other sub-structs
%        - The struct can contains numeric or logical vectors
%        - The vectors are row vectors
%
%    Parameters:
%        hash (vector): computed hash (vector format)
%        engine (java): hash engine (JAVA object)
%        data (struct): struct of vectors to be hashed
%
%    Returns:
%        hash (vector): computed hash (vector format)

% check type
assert(isstruct(data), 'invalid data type')
assert(numel(data)==1, 'invalid data size')

% hash field and values, ignore order of fields
field = sort(fieldnames(data));
for i=1:length(field)
    % hash field name
    hash = get_hash_value(hash, engine, field{i});
    
    % hash values
    value = data.(field{i});
    if isstruct(value)
        % if struct, recursive call
        assert(numel(value)==1, 'invalid data size')
        hash = get_hash_struct(hash, engine, value);
    elseif isnumeric(value)||islogical(value)
        % if struct, hash it
        assert(size(value, 1)==1, 'invalid data size')
        hash = get_hash_value(hash, engine, value);
    end
end

end

function hash = get_hash_value(hash, engine, data)
% Compute a MD5 hash of a str or array.
%
%    Parameters:
%        hash (vector): computed hash (vector format)
%        engine (java): hash engine (JAVA object)
%        data (str/array): data to be hashed
%
%    Returns:
%        hash (vector): computed hash (vector format)

% cast everything to double and then uint8
data = double(data);
engine.update(typecast(data(:), 'uint8'));

% run the hash, make the xor operation between the provided hash and the new one
hash_tmp = double(typecast(engine.digest, 'uint8'));
hash = bitxor(hash, hash_tmp);

end