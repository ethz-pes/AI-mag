function inp_mat = get_scale_inp(self, inp)

for i=1:length(self.var_inp)
    % extract
    name_tmp = self.var_inp{i}.name;
    var_trf_tmp = self.var_inp{i}.var_trf;
    norm_param_tmp = self.norm_param_inp{i};
    
    value_tmp = inp.(name_tmp);
    
    % transform and normalize
    value_tmp = AnnManager.get_var_trf(value_tmp, var_trf_tmp, 'scale');
    value_tmp = AnnManager.get_var_norm_value(value_tmp, norm_param_tmp, 'scale');
    
    % assign
    inp_mat(i,:) = value_tmp;
end

end
