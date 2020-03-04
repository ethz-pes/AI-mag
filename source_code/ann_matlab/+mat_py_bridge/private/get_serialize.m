function byte = get_serialize(data)

assert(isstruct(data), 'invalid data')
byte = serialize_struct(data);

end

function byte = serialize_struct(data)

byte = uint8([]);

% byte type
byte_add = class_encode(data);
byte = append_byte(byte, byte_add);

% field names
field = fieldnames(data);

% number of fields
byte_add = numel(field);
byte_add = typecast(uint32(byte_add), 'uint8');
byte = append_byte(byte, byte_add);

% add field and byte
for i=1:numel(field)
    byte_add = serialize_data(field{i});
    byte = append_byte(byte, byte_add);
    byte_add = serialize_data(data.(field{i}));
    byte = append_byte(byte, byte_add);
end

end

function byte = serialize_data(data)

byte = uint8([]);

% byte type
byte_add = class_encode(data);
byte = append_byte(byte, byte_add);

if ischar(data)
    byte = serialize_char(byte, data);
else
    byte = serialize_matrix(byte, data);
end

end

function byte = serialize_char(byte, data)

n_length = length(data);

% length
byte_add = typecast(uint32(n_length), 'uint8');
byte = append_byte(byte, byte_add);

byte_add = uint8(data(:));
byte = append_byte(byte, byte_add);

end

function byte = serialize_matrix(byte, data)

size_vec = size(data);

% number of dimensions
byte_add = typecast(uint32(length(size_vec)), 'uint8');
byte = append_byte(byte, byte_add);

% number of dimensions
byte_add = typecast(uint32(size_vec), 'uint8');
byte = append_byte(byte, byte_add);

% add byte
if islogical(data)
    byte_add = uint8(data(:));
    byte = append_byte(byte, byte_add);
else
    byte_add = typecast(data(:), 'uint8');
    byte = append_byte(byte, byte_add);
end

end


function b = class_encode(data)

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
        error('invalid type');
end

end

function byte = append_byte(byte, byte_add)

byte_add = byte_add(:).';
byte = [byte byte_add];

end