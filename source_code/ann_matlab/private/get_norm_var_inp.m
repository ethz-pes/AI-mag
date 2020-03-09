function norm_param_inp = get_norm_var_inp(var_inp, inp)

for i=1:length(var_inp)
    % extract
    name_tmp = var_inp{i}.name;
    var_trf_tmp = var_inp{i}.var_trf;
    var_norm_tmp = var_inp{i}.var_norm;
    
    % value
    value_tmp = inp.(name_tmp);
    
    % transform and normalize
    value_tmp = get_var_trf(value_tmp, var_trf_tmp, 'scale');
    norm_param_tmp = get_var_norm_param(value_tmp, var_norm_tmp);
    
    % assign
    norm_param_inp{i} = norm_param_tmp;
end

end
