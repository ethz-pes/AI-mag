function struct_out = get_struct_filter(struct_in, idx)
% Filter a struct of vectors with respect to indices.
%
%    The following data are accepted:
%        - The struct can contains other sub-structs
%        - The struct can contains numeric or logical vectors
%        - The vectors are row vectors
%
%    Parameters:
%        struct_in (struct): struct of vectors (input)
%        idx (vector): indices to be kept
%
%    Returns:
%        struct_out (struct): struct of vectors (output)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check type
assert(isstruct(struct_in)==1, 'invalid data')
assert(numel(struct_in)==1, 'invalid data')

% filter data
struct_out = struct();
field = fieldnames(struct_in);
for i=1:length(field)
    struct_in_tmp = struct_in.(field{i});
    
    if isstruct(struct_in_tmp)
        % if struct, recursive call
        assert(numel(struct_in_tmp)==1, 'invalid data')
        struct_out.(field{i}) = get_struct_filter(struct_in_tmp, idx);
    elseif isnumeric(struct_in_tmp)||islogical(struct_in_tmp)
        % if vector, filter
        assert(size(struct_in_tmp, 1)==1, 'invalid data')
        struct_out.(field{i}) = struct_in_tmp(idx);
    else
        error('invalid data type')
    end
end

end