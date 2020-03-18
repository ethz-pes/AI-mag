function struct_out = get_struct_assemble(struct_in)

struct_out = struct();
field = fieldnames(struct_in);
for i=1:length(field)    
    struct_in_tmp = [struct_in.(field{i})];
        
    if isstruct(struct_in_tmp)
        struct_out.(field{i}) = get_struct_assemble(struct_in_tmp);
    else
        assert(isnumeric(struct_in_tmp)||islogical(struct_in_tmp), 'invalid data')
        assert(size(struct_in_tmp, 1)==1, 'invalid data')
        struct_out.(field{i}) = struct_in_tmp;
    end
end

end