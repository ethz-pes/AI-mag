function check_set(n_sol, var, data)

assert(isstruct(data), 'invalid data')

field_var = fieldnames(var);
field_data = fieldnames(data);
assert(length(field_var)==length(field_data), 'invalid data')
assert(all(strcmp(sort(field_var), sort(field_data))), 'invalid data')

field = fieldnames(data);
for i=1:length(field)
    data_tmp = data.(field{i});
    validateattributes(data_tmp, {'double', 'single'},{'row', 'nonempty', 'nonnan', 'real','finite'});
    assert(length(data_tmp)==n_sol, 'invalid data')
end

end
