function is_valid = get_range_inp(var_inp, inp)

is_valid = true;

for i=1:length(var_inp)
    % extract
    name_tmp = var_inp{i}.name;
    min_tmp = var_inp{i}.min;
    max_tmp = var_inp{i}.max;
    
    value_tmp = inp.(name_tmp);
    
    is_valid = is_valid&(value_tmp>=min_tmp);
    is_valid = is_valid&(value_tmp<=max_tmp);
end

end
