function data = get_deserialize(bytes_array)
% Deserialize data from Python into a MATLAB struct.
%
%    This function can only serialize very specific MATLAB data:
%        - string
%        - array:
%            - multi-dimensional arrays are supported
%            - double, single, logical, int8, uint8, int32, uint32, int64, uint64
%        - struct:
%            - the values of the struct can be strings or array
%            - the values of the struct can be other structs
%            - all structs have to be scalar
%
%    The reasons of these limitation are:
%        - To keep this function as simple as possible
%        - The mismatch between the Python data types and the MATLAB data types
%
%    Warning: The serialization/deserialization routine have meant to be safe against malicious data.
%
%    Parameters:
%        bytes_array (bytes): data to be deserialized
%
%    Returns:
%        data (struct): deserialized data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check the type
assert(isa(bytes_array, 'uint8'), 'invalid data type')

% deserialize data, at the end the bytes_array array should be empty
[data, bytes_array] = deserialize_data(bytes_array);
assert(isempty(bytes_array), 'invalid data length')

end

function [data, bytes_array] = deserialize_data(bytes_array)
% Deserialize a MATLAB data.
%
%    Parameters:
%        bytes_array (bytes): data to be deserialized
%
%    Returns:
%        data (str/array): deserialized data
%        bytes_array (bytes): remaining data to be deserialized

% get the type
[bytes_array, bytes_tmp] = get_byte(bytes_array, 1);
cls = class_decode(bytes_tmp);

% decode the data
if strcmp(cls, 'char')
    [data, bytes_array] = deserialize_char(bytes_array, cls);
elseif strcmp(cls, 'struct')
    [data, bytes_array] = deserialize_struct(bytes_array);
elseif any(strcmp(cls, {'double', 'single', 'logical', 'int8', 'uint8', 'int32', 'uint32', 'int64', 'uint64'}))
    [data, bytes_array] = deserialize_matrix(bytes_array, cls);
else
    error('invalid data type');
end

end

function [data, bytes_array] = deserialize_struct(bytes_array)
% Deserialize a MATLAB struct.
%
%    Parameters:
%        bytes_array (bytes): data to be deserialized
%
%    Returns:
%        data (struct): deserialized data
%        bytes_array (bytes): remaining data to be deserialized

% get the number of keys
[bytes_array, bytes_tmp] = get_byte(bytes_array, 4);
n_field = double(typecast(bytes_tmp, 'uint32'));

% decode the keys and values
for i=1:n_field
    [v_field, bytes_array] = deserialize_data(bytes_array);
    [v_value, bytes_array] = deserialize_data(bytes_array);
    data.(v_field) = v_value;
end

end

function [data, bytes_array] = deserialize_char(bytes_array, cls)
% Deserialize a MATLAB string.
%
%    Parameters:
%        bytes_array (bytes): data to be deserialized
%
%    Returns:
%        data (str): deserialized data
%        bytes_array (bytes): remaining data to be deserialized

% get the length
[bytes_array, bytes_tmp] = get_byte(bytes_array, 4);
n_length = double(typecast(bytes_tmp, 'uint32'));

% decode the data
n_byte = class_size(cls);
[bytes_array, bytes_tmp] = get_byte(bytes_array, n_length.*n_byte);
data = char(bytes_tmp);

end

function [data, bytes_array] = deserialize_matrix(bytes_array, cls)
% Deserialize a MATLAB array.
%
%    Parameters:
%        bytes_array (bytes): data to be deserialized
%
%    Returns:
%        data (array): deserialized data
%        bytes_array (bytes): remaining data to be deserialized

% get number of dimension
[bytes_array, bytes_tmp] = get_byte(bytes_array, 4);
n_dim = double(typecast(bytes_tmp, 'uint32'));

% decode the number of element per dimension
[bytes_array, bytes_tmp] = get_byte(bytes_array, n_dim.*4);
size_vec = double(typecast(bytes_tmp, 'uint32'));

% get the data
n_byte = class_size(cls);
n_elem = prod(size_vec);
[bytes_array, bytes_tmp] = get_byte(bytes_array, n_elem.*n_byte);

% decode the data: warning MATLAB is using FORTRAN byte order, not the C one
if strcmp(cls, 'logical')
    data = logical(bytes_tmp);
else
    data = typecast(bytes_tmp, cls);
end

% if required, reshape the data
if n_dim>1
    data = reshape(data, size_vec);
end

end

function n_byte = class_size(cls)
% Get the number of bytes per element for a given data type.
%
%    Parameters:
%        cls (str): name of the data type
%
%    Returns:
%        n_byte (int): number of byte per element

switch cls
    case {'double', 'int64', 'uint64'}
        n_byte = 8;
    case {'single', 'int32', 'uint32'}
        n_byte = 4;
    case {'logical', 'char', 'int8', 'uint8'}
        n_byte = 1;
    otherwise
        error('invalid data type');
end

end

function cls = class_decode(b)
% Decode the data type from a byte.
%
%    Parameters:
%        b (byte): byte with the encoded type
%
%    Returns:
%        cls (str): name of the decoded data type

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
        error('invalid data type');
end

end

function [bytes_array, bytes_tmp] = get_byte(bytes_array, n)
% Get a number of bytes from a byte array and remove them.
%
%    Parameters:
%        bytes_array (bytes): byte array
%        n (int): bytes to be return and removed
%
%    Returns:
%        bytes_array (bytes): resulting byte array (with n bytes less)
%        bytes_tmp (bytes): read bytes (n bytes)


assert(length(bytes_array)>=n, 'invalid data length')
bytes_tmp = bytes_array(1:n);
bytes_array = bytes_array(n+1:end);

end