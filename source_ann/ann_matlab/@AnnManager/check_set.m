function check_set(n_sol, var, data)
% Check the validity of a provided dataset.
%
%    Parameters:
%        n_sol (int): number of samples
%        var (cell): description of the variables
%        data (struct): struct with the dataset

% check data type
assert(isstruct(data), 'invalid data')

% check that the required variables are present
field_data = fieldnames(data);
for i=1:length(var)
    field_var = var{i}.name;
    assert(any(strcmp(field_var, field_data)), 'invalid data')
end

% check the size of the data
field = fieldnames(data);
for i=1:length(field)
    data_tmp = data.(field{i});
    assert(size(data_tmp, 1)==1, 'invalid data')
    assert(size(data_tmp, 2)==n_sol, 'invalid data')
end

end
