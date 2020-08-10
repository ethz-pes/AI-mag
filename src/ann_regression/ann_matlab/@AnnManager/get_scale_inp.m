function inp_mat = get_scale_inp(self, inp)
% Scale the input data and transform them into matrix.
%
%    First, appy the specified variable transformation.
%    Then, normalize on the resulting values.
%    Finally, transform the struct into a matrix
%
%    Parameters:
%        inp (struct): input data
%
%    Returns:
%        inp_mat (matrix): scaled input data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

for i=1:length(self.var_inp)
    % extract variable
    name_tmp = self.var_inp{i}.name;
    var_trf_tmp = self.var_inp{i}.var_trf;
    norm_param_tmp = self.norm_param_inp{i};
    
    % extract value
    value_tmp = inp.(name_tmp);
    
    % transform and normalize
    value_tmp = AnnManager.get_var_trf(value_tmp, var_trf_tmp, 'scale');
    value_tmp = AnnManager.get_var_norm_value(value_tmp, norm_param_tmp, 'scale');
    
    % assign result
    inp_mat(i,:) = value_tmp;
end

end
