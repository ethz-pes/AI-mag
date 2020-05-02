function int = get_map_str_to_int(str)
% Convert a string (up to eight characters) to a integer (uint64).
%
%    Parameters:
%        str (str): input string
%
%    Returns:
%        int (int): output int (uint64)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check string
assert(ischar(str), 'invalid data type')
assert(length(str)<=8, 'invalid string length')

% cast to bytes
bytes_nb = uint8(str(:));
bytes_pad = int8(zeros(8-length(str), 1));
bytes = [bytes_nb ; bytes_pad];

% cast to int
int = typecast(bytes, 'uint64');

end