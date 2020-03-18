function struct_out = get_struct_size(struct_in, n)

struct_out = struct();
field = fieldnames(struct_in);
for i=1:length(field)
    struct_in_tmp = struct_in.(field{i});
    if isstruct(struct_in_tmp)
        assert(numel(struct_in_tmp)==1, 'invalid data')
        struct_out.(field{i}) = get_struct_size(struct_in_tmp, n);
    elseif isnumeric(struct_in_tmp)||islogical(struct_in_tmp)
        assert(size(struct_in_tmp, 1)==1, 'invalid data')
        if length(struct_in_tmp)==1
            struct_out.(field{i}) = repmat(struct_in_tmp, 1, n);
        elseif length(struct_in_tmp)==n
            struct_out.(field{i}) = struct_in_tmp;
        else
            error('invalid size')
        end
    end
end

end