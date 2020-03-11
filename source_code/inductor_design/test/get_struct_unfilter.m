function struct_out = get_struct_unfilter(struct_in, idx)

struct_out = struct();
field = fieldnames(struct_in);
for i=1:length(field)
    struct_in_tmp = struct_in.(field{i});
    if isstruct(struct_in_tmp)
        assert(numel(struct_in_tmp)==1, 'invalid data')
        struct_out.(field{i}) = get_struct_filter(struct_in_tmp, idx);
    elseif isnumeric(struct_in_tmp)
        assert(size(struct_in_tmp, 1)==1, 'invalid data')
        struct_in_tmp_new = NaN(1, length(idx));
        struct_in_tmp_new(idx) = struct_in_tmp;
        struct_out.(field{i}) = struct_in_tmp_new;
    elseif islogical(struct_in_tmp)
        assert(size(struct_in_tmp, 1)==1, 'invalid data')
        struct_in_tmp_new = false(1, length(idx));
        struct_in_tmp_new(idx) = struct_in_tmp;
        struct_out.(field{i}) = struct_in_tmp_new;
    elseif isa(struct_in_tmp, 'char')||isa(struct_in_tmp, 'function_handle')
        struct_out.(field{i}) = struct_in_tmp;
    end
end

end