function get_norm_var_out(self)

for i=1:length(self.var_out)
    % extract
    name_tmp = self.var_out{i}.name;
    var_trf_tmp = self.var_out{i}.var_trf;
    var_norm_tmp = self.var_out{i}.var_norm;
    use_nrm_tmp = self.var_out{i}.use_nrm;
    
    value_tmp = self.out_ref.(name_tmp);
    scale_tmp = self.out_nrm.(name_tmp);
    
    % scale
    if use_nrm_tmp==true
        value_tmp = value_tmp./scale_tmp;
    end
    
    % transform and normalize
    value_tmp = AnnManager.get_var_trf(value_tmp, var_trf_tmp, 'scale');
    norm_param_tmp = AnnManager.get_var_norm_param(value_tmp, var_norm_tmp);
    
    % assign
    self.norm_param_out{i} = norm_param_tmp;
end

end
