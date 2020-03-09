function norm_param_out = get_norm_var_out(var_out, out_ref, out_nrm)

for i=1:length(var_out)
    % extract
    name_tmp = var_out{i}.name;
    var_trf_tmp = var_out{i}.var_trf;
    var_norm_tmp = var_out{i}.var_norm;
    use_nrm_tmp = var_out{i}.use_nrm;
    
    value_tmp = out_ref.(name_tmp);
    scale_tmp = out_nrm.(name_tmp);
    
    % scale
    if use_nrm_tmp==true
        value_tmp = value_tmp./scale_tmp;
    end
    
    % transform and normalize
    value_tmp = get_var_trf(value_tmp, var_trf_tmp, 'scale');
    norm_param_tmp = get_var_norm_param(value_tmp, var_norm_tmp);
    
    % assign
    norm_param_out{i} = norm_param_tmp;
end

end
