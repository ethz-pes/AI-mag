function check_set(n_sol, var, data)

assert(isstruct(data), 'invalid data')

field_var = fieldnames(var);
field_data = fieldnames(data);
field_data = intersect(field_var, field_data);

assert(length(field_var)==length(field_data), 'invalid data')
assert(all(strcmp(sort(field_var), sort(field_data))), 'invalid data')

field = fieldnames(data);
for i=1:length(field)
    data_tmp = data.(field{i});
    assert(size(data_tmp, 1)==1, 'invalid data')
    assert(size(data_tmp, 2)==n_sol, 'invalid data')
end

end
