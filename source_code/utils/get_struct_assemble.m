function data_out = get_struct_assemble(data_in)

field = fieldnames(data_in);
for i=1:length(field)
    tmp = [data_in.(field{i})];
    data_out.(field{i}) = tmp;
end

end
