function norm_param = get_norm_var_inp(self, inp_train)
% Find the normalization of the input variables.
%
%    Use the training dataset to normalize.
%    First, appy the specified variable transformation.
%    Then, find the normalization on the resulting values.
%
%    Parameters:
%        inp_train (struct): training input data
%
%    Returns:
%        norm_param (cell): normalization data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

for i=1:length(self.var_inp)
    % extract variable
    name_tmp = self.var_inp{i}.name;
    var_trf_tmp = self.var_inp{i}.var_trf;
    var_norm_tmp = self.var_inp{i}.var_norm;
    
    % extract value
    value_tmp = inp_train.(name_tmp);
    
    % transform and normalize
    value_tmp = self.get_var_trf(value_tmp, var_trf_tmp, 'scale');
    norm_param_tmp = self.get_var_norm_param(value_tmp, var_norm_tmp);
    
    % assign result
    norm_param{i} = norm_param_tmp;
end

end
