function struct_out = get_struct_merge(struct_in_1, struct_in_2)

assert(numel(struct_in_1)==1, 'invalid data')
assert(numel(struct_in_2)==1, 'invalid data')

field_1 = fieldnames(struct_in_1);
field_2 = fieldnames(struct_in_2);
data_1 = struct2cell(struct_in_1);
data_2 = struct2cell(struct_in_2);

[field, idx, idx_rev] = unique([field_1 ; field_2]);
data = [data_1 ; data_2];

struct_out = struct();
for i=1:length(field)
    idx_tmp = idx_rev==i;
    data_tmp = data(idx_tmp);
    struct_out.(field{i}) = merge_data(data_tmp);
end

end

function data_out = merge_data(data_in)

if numel(data_in)==1
    data_out = data_in{:};
    if isnumeric(data_out)||islogical(data_out)
        assert(size(data_out, 1)==1, 'invalid data')
    else
        error('invalid size')
    end
elseif length(data_in)==2
    assert(all(cellfun(@isstruct, data_in)), 'invalid data')
    data_out = get_struct_merge(data_in{1}, data_in{2});
else
    error('invalid data')
end

end