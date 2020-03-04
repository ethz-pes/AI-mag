function norm_param_inp = get_norm_var_inp(var_inp, inp)

field = fieldnames(var_inp);
for i=1:length(field)
    % extract
    var_trf_tmp = var_inp.(field{i}).var_trf;
    var_norm_tmp = var_inp.(field{i}).var_norm;
    
    % value
    value_tmp = inp.(field{i});
    
    % transform and normalize
    value_tmp = get_var_trf(value_tmp, var_trf_tmp, 'scale');
    norm_param_tmp = get_var_norm_param(value_tmp, var_norm_tmp);
    
    % assign
    norm_param_inp.(field{i}) = norm_param_tmp;
end

end
