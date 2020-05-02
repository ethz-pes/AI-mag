function str = get_map_int_to_str(int)
% Convert an int (uint64) to a string.
%
%    Parameters:
%        int (int): input int (uint64)
%
%    Returns:
%        str (str): output string
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check int
assert(isa(int, 'uint64'), 'invalid data type')
assert(length(int)==1, 'invalid data type')

% cast to bytes
bytes = typecast(int, 'uint8');
bytes = bytes(bytes~=0);

% cast to string
str = char(bytes);

end