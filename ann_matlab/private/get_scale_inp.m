function inp_mat = get_scale_inp(var_inp, norm_param_inp, inp)

field = fieldnames(var_inp);
for i=1:length(field)
    % extract
    var_trf_tmp = var_inp.(field{i}).var_trf;
    norm_param_tmp = norm_param_inp.(field{i});
    
    value_tmp = inp.(field{i});
    
    % transform and normalize
    value_tmp = get_var_trf(value_tmp, var_trf_tmp, 'scale');
    value_tmp = get_var_norm_value(value_tmp, norm_param_tmp, 'scale');
    
    % assign
    inp_mat(i,:) = value_tmp;
end

end
