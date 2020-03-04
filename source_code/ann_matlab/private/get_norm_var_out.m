function norm_param_out = get_norm_var_out(var_out, out_ref, out_scl)

field = fieldnames(var_out);
for i=1:length(field)
    % extract
    var_trf_tmp = var_out.(field{i}).var_trf;
    var_norm_tmp = var_out.(field{i}).var_norm;
    use_scl_tmp = var_out.(field{i}).use_scl;
    
    value_tmp = out_ref.(field{i});
    scale_tmp = out_scl.(field{i});
    
    % scale
    if use_scl_tmp==true
        value_tmp = value_tmp./scale_tmp;
    end
    
    % transform and normalize
    value_tmp = get_var_trf(value_tmp, var_trf_tmp, 'scale');
    norm_param_tmp = get_var_norm_param(value_tmp, var_norm_tmp);
    
    % assign
    norm_param_out.(field{i}) = norm_param_tmp;
end

end
