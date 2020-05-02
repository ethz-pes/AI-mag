function struct_out = get_struct_merge(struct_in_1, struct_in_2)
% Merge two structs of vectors into one (handle duplicated field name).
%
%    The following data are accepted:
%        - The struct can contains other sub-structs
%        - The struct can contains numeric or logical vectors
%        - The vectors are row vectors
%        - The field name of numeric or logical vectors should be unique
%        - The field name of sub-structs can be duplicated
%
%    Parameters:
%        struct_in_1 (struct): first struct of vectors (input)
%        struct_in_2 (struct): second struct of vectors (input)
%
%    Returns:
%        struct_out (struct): struct of vectors (output)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check type
assert(isstruct(struct_in_1)==1, 'invalid data')
assert(isstruct(struct_in_2)==1, 'invalid data')
assert(numel(struct_in_1)==1, 'invalid data')
assert(numel(struct_in_2)==1, 'invalid data')

% get field and data
field_1 = fieldnames(struct_in_1);
field_2 = fieldnames(struct_in_2);
data_1 = struct2cell(struct_in_1);
data_2 = struct2cell(struct_in_2);

% handle duplicated fields
[field, idx, idx_rev] = unique([field_1 ; field_2]);
data = [data_1 ; data_2];

% assign the data
struct_out = struct();
for i=1:length(field)
    idx_tmp = idx_rev==i;
    data_tmp = data(idx_tmp);
    struct_out.(field{i}) = merge_data(data_tmp);
end

end

function data_out = merge_data(data_in)
% Merge cell data for created vectors and structs.
%
%    Parameters:
%        data_in (cell): data to be merged
%
%    Returns:
%        data_out (struct/array): merged data

if numel(data_in)==1
    % if no duplicate, it can be an array or a struct
    data_out = data_in{:};
    if isstruct(data_out)
        % if struct, it's already good
    elseif isnumeric(data_out)||islogical(data_out)
        % if vector, check the size
        assert(size(data_out, 1)==1, 'invalid data')
    else
        error('invalid data type or size')
    end
elseif length(data_in)==2
    % if duplicate, it should be structs, recursive call
    assert(all(cellfun(@isstruct, data_in)), 'invalid data')
    data_out = get_struct_merge(data_in{1}, data_in{2});
else
        error('invalid data type or size')
end

end