function struct_out = get_struct_size(struct_in, n)
% Expand a struct of vectors to a predefined size.
%
%    If the vector has dimension one, repeat it to the desired size.
%    If the vector has another dimension, check that it is the desired size.
%
%    The following data are accepted:
%        - The struct can contains other sub-structs
%        - The struct can contains numeric or logical vectors
%        - The vectors are row vectors
%
%    Parameters:
%        struct_in (struct): struct of vectors (input)
%        n (int): expected size of the vectors composing the struct
%
%    Returns:
%        struct_out (struct): struct of vectors (output)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check type
assert(isstruct(struct_in)==1, 'invalid data')
assert(numel(struct_in)==1, 'invalid data')

% handle data
struct_out = struct();
field = fieldnames(struct_in);
for i=1:length(field)
    struct_in_tmp = struct_in.(field{i});
    
    if isstruct(struct_in_tmp)
        % if struct, recursive call
        assert(numel(struct_in_tmp)==1, 'invalid data')
        struct_out.(field{i}) = get_struct_size(struct_in_tmp, n);
    elseif isnumeric(struct_in_tmp)||islogical(struct_in_tmp)
        % if vector, expand and check size
        assert(size(struct_in_tmp, 1)==1, 'invalid data')
        if length(struct_in_tmp)==1
            struct_out.(field{i}) = repmat(struct_in_tmp, 1, n);
        elseif length(struct_in_tmp)==n
            struct_out.(field{i}) = struct_in_tmp;
        else
        error('invalid data size')
        end
    else
        error('invalid data type')
    end
end

end