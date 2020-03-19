function get_norm_var_inp(self)

for i=1:length(self.var_inp)
    % extract
    name_tmp = self.var_inp{i}.name;
    var_trf_tmp = self.var_inp{i}.var_trf;
    var_norm_tmp = self.var_inp{i}.var_norm;
    
    % value
    value_tmp = self.inp.(name_tmp);
    
    % transform and normalize
    value_tmp = AnnManager.get_var_trf(value_tmp, var_trf_tmp, 'scale');
    norm_param_tmp = AnnManager.get_var_norm_param(value_tmp, var_norm_tmp);
    
    % assign
    self.norm_param_inp{i} = norm_param_tmp;
end

end
