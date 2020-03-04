function data = get_deserialize(byte)

assert(isa(byte, 'uint8'), 'invalid byte')

[byte, byte_tmp] = get_byte(byte, 1);
cls = class_decode(byte_tmp);
assert(strcmp(cls, 'struct'), 'invalid type')

[data, byte] = deserialize_struct(byte);
assert(isempty(byte), 'invalid byte')

end

function [data, byte] = deserialize_struct(byte)

% get field number
[byte, byte_tmp] = get_byte(byte, 4);
n_field = double(typecast(byte_tmp, 'uint32'));

% get field and byte
for i =1:n_field
    [v_field, byte] = deserialize_data(byte);
    [v_value, byte] = deserialize_data(byte);
    data.(v_field) = v_value;
end

end

function [data, byte] = deserialize_data(byte)

[byte, byte_tmp] = get_byte(byte, 1);
cls = class_decode(byte_tmp);

if strcmp(cls, 'char')
    [data, byte] = deserialize_char(byte, cls);
else
    [data, byte] = deserialize_matrix(byte, cls);
end

end

function [data, byte] = deserialize_char(byte, cls)

% get dimensions
[byte, byte_tmp] = get_byte(byte, 4);
n_length = double(typecast(byte_tmp, 'uint32'));

% get data
n_byte = class_size(cls);
[byte, byte_tmp] = get_byte(byte, n_length.*n_byte);
data = char(byte_tmp);

end

function [data, byte] = deserialize_matrix(byte, cls)

% get dimensions
[byte, byte_tmp] = get_byte(byte, 4);
n_dim = double(typecast(byte_tmp, 'uint32'));

% get dimensions
[byte, byte_tmp] = get_byte(byte, n_dim.*4);
size_vec = double(typecast(byte_tmp, 'uint32'));

% get class size
n_byte = class_size(cls);
n_elem = prod(size_vec);
[byte, byte_tmp] = get_byte(byte, n_elem.*n_byte);

% data
if strcmp(cls, 'logical')
    data = logical(byte_tmp);
else
    data = typecast(byte_tmp, cls);
end

if n_dim>1
data = reshape(data, size_vec);
end

end

function n_byte = class_size(cls)

switch cls
    case {'double', 'int64', 'uint64'}
        n_byte = 8;
    case {'single', 'int32', 'uint32'}
        n_byte = 4;
    case {'logical', 'char', 'int8', 'uint8'}
        n_byte = 1;
    otherwise
        error('invalid type');
end

end

function cls = class_decode(b)

switch b
    case 0
        cls = 'double';
    case 1
        cls = 'single';
    case 2
        cls = 'logical';
    case 3
        cls = 'char';
    case 4
        cls = 'int8';
    case 5
        cls = 'uint8';
    case 8
        cls = 'int32';
    case 9
        cls = 'uint32';
    case 10
        cls = 'int64';
    case 11
        cls = 'uint64';
    case 12
        cls = 'struct';
    otherwise
        error('invalid type');
end

end

function [byte, byte_tmp] = get_byte(byte, n)

byte_tmp = byte(1:n);
byte = byte(n+1:end);

end