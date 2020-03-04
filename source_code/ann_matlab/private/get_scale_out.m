function out_mat = get_scale_out(var_out, norm_param_out, out_ref, out_scl)

field = fieldnames(var_out);
for i=1:length(field)
    % extract
    var_trf_tmp = var_out.(field{i}).var_trf;
    use_scl_tmp = var_out.(field{i}).use_scl;
    norm_param_tmp = norm_param_out.(field{i});
    
    value_tmp = out_ref.(field{i});
    scale_tmp = out_scl.(field{i});
    
    % scale
    if use_scl_tmp==true
        value_tmp = value_tmp./scale_tmp;
    end
    
    % transform and normalize
    value_tmp = get_var_trf(value_tmp, var_trf_tmp, 'scale');
    value_tmp = get_var_norm_value(value_tmp, norm_param_tmp, 'scale');
    
    % assign
    out_mat(i,:) = value_tmp;
end

end
