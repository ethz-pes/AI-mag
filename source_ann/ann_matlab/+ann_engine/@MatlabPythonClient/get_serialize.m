function bytes_array = get_serialize(data)
% Serialize a MATLAB struct to be transferred to Python.
%
%    This function can only serialize very specific MATLAB data:
%        - The data has to be a struct
%        - The values of the struct can be strings
%        - The values of the struct can be arrays:
%            - Multi-dimensional arrays are supported
%            - double, single, logical, int8, uint8, int32, uint32, int64, uint64
%
%    The reasons of these limitation are:
%        - To keep this function as simple as possible
%        - The mismatch between the Pythpn data types and the MATLAB data types
%
%    Parameters:
%        data (struct): data to be serialized
%
%    Returns:
%        bytes_array (bytes): serialized data

% check the type
assert(isstruct(data), 'invalid data')

% serialize data
bytes_array = serialize_struct(data);

end

function bytes_array = serialize_struct(data)
% Serialize a MATLAB struct.
%
%    Parameters:
%        data (struct): data to be serialized
%
%    Returns:
%        bytes_array (bytes): serialized data

% init array
bytes_array = uint8([]);

% encode the data type: dict
bytes_add = class_encode(data);
bytes_array = append_byte(bytes_array, bytes_add);

% field names
field = fieldnames(data);

% encode the number of fields
bytes_add = numel(field);
bytes_add = typecast(uint32(bytes_add), 'uint8');
bytes_array = append_byte(bytes_array, bytes_add);

% serialize the keys and values
for i=1:numel(field)
    bytes_add = serialize_data(field{i});
    bytes_array = append_byte(bytes_array, bytes_add);
    bytes_add = serialize_data(data.(field{i}));
    bytes_array = append_byte(bytes_array, bytes_add);
end

end

function bytes_array = serialize_data(data)
% Serialize a MATLAB string or an array.
%
%    Parameters:
%        data (str/array): data to be serialized
%
%    Returns:
%        bytes_array (bytes): serialized data

% init array
bytes_array = uint8([]);

% encode the data type: string or numpy array
bytes_add = class_encode(data);
bytes_array = append_byte(bytes_array, bytes_add);

% encode the data
if ischar(data)
    bytes_array = serialize_char(bytes_array, data);
else
    bytes_array = serialize_matrix(bytes_array, data);
end

end

function bytes_array = serialize_char(bytes_array, data)
% Serialize a MATLAB string.
%
%    Parameters:
%        bytes_array (bytes): bytes array to add the new data
%        data (str): data to be serialized
%
%    Returns:
%        bytes_array (bytes): bytes array with the new serialized data

% encode the length
n_length = length(data);
bytes_add = typecast(uint32(n_length), 'uint8');
bytes_array = append_byte(bytes_array, bytes_add);

% encode the data
bytes_add = uint8(data(:));
bytes_array = append_byte(bytes_array, bytes_add);

end

function bytes_array = serialize_matrix(bytes_array, data)
% Serialize a MATLAB array.
%
%    Parameters:
%        bytes_array (bytes): bytes array to add the new data
%        data (array): data to be serialized
%
%    Returns:
%        bytes_array (bytes): bytes array with the new serialized data

% get the shape of the array (size along dimensions)
size_vec = size(data);

% encode the number of dimensions
bytes_add = typecast(uint32(length(size_vec)), 'uint8');
bytes_array = append_byte(bytes_array, bytes_add);

% encode the number of element per dimension
bytes_add = typecast(uint32(size_vec), 'uint8');
bytes_array = append_byte(bytes_array, bytes_add);

% encode the data: warning MATLAB is using FORTRAN byte order, not the C one
if islogical(data)
    bytes_add = uint8(data(:));
    bytes_array = append_byte(bytes_array, bytes_add);
else
    bytes_add = typecast(data(:), 'uint8');
    bytes_array = append_byte(bytes_array, bytes_add);
end

end

function b = class_encode(data)
% Encode the data type with a byte.
%
%    Parameters:
%        data (various): data to be encoded
%
%    Returns:
%        byte (byte): byte with the encoded type

cls = class(data);
switch cls
    case 'double'
        b = 0;
    case 'single'
        b = 1;
    case 'logical'
        b = 2;
    case 'char'
        b = 3;
    case 'int8'
        b = 4;
    case 'uint8'
        b = 5;
    case 'int32'
        b = 8;
    case 'uint32'
        b = 9;
    case 'int64'
        b = 10;
    case 'uint64'
        b = 11;
    case 'struct'
        b = 12;
    otherwise
        error('invalid data type');
end

end

function bytes_array = append_byte(bytes_array, bytes_add)
% Append bytes to a byte array.
%
%    Parameters:
%        bytes_array (bytes): byte array
%        bytes_add (bytes): bytes to be added
%
%    Returns:
%        bytes_array (bytes): resulting byte array

bytes_add = bytes_add(:).';
bytes_array = [bytes_array bytes_add];

end