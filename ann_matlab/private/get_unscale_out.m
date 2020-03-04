function out_ann = get_unscale_out(var_out, norm_param_out, out_scl, out_mat)

field = fieldnames(var_out);
for i=1:length(field)
    % extract
    var_trf_tmp = var_out.(field{i}).var_trf;
    use_scl_tmp = var_out.(field{i}).use_scl;
    norm_param_tmp = norm_param_out.(field{i});
    
    scale_tmp = out_scl.(field{i});
    value_tmp = out_mat(i,:);
    
    % reverse transform and denormalize
    value_tmp = get_var_norm_value(value_tmp, norm_param_tmp, 'unscale');
    value_tmp = get_var_trf(value_tmp, var_trf_tmp, 'unscale');
    
    % unscale
    if use_scl_tmp==true
        value_tmp = value_tmp.*scale_tmp;
    end
    
    % assign
    out_ann.(field{i}) = value_tmp;
end

end
