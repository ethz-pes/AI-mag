function out_ann = get_unscale_out(self, out_nrm, out_mat)

for i=1:length(self.var_out)
    % extract
    name_tmp = self.var_out{i}.name;
    var_trf_tmp = self.var_out{i}.var_trf;
    use_nrm_tmp = self.var_out{i}.use_nrm;
    norm_param_tmp = self.norm_param_out{i};
    
    scale_tmp = out_nrm.(name_tmp);
    value_tmp = out_mat(i,:);
    
    % reverse transform and denormalize
    value_tmp = AnnManager.get_var_norm_value(value_tmp, norm_param_tmp, 'unscale');
    value_tmp = AnnManager.get_var_trf(value_tmp, var_trf_tmp, 'unscale');
    
    % unscale
    if use_nrm_tmp==true
        value_tmp = value_tmp.*scale_tmp;
    end
    
    % assign
    out_ann.(name_tmp) = value_tmp;
end

end
