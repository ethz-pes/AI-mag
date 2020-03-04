function is_valid = get_range_inp(var_inp, inp)

is_valid = true;

field = fieldnames(var_inp);
for i=1:length(field)
    % extract
    min_tmp = var_inp.(field{i}).min;
    max_tmp = var_inp.(field{i}).max;
    
    value_tmp = inp.(field{i});
    
    is_valid = is_valid&(value_tmp>=min_tmp);
    is_valid = is_valid&(value_tmp<=max_tmp);
end

end
