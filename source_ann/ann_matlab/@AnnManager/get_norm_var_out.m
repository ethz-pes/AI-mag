function norm_param = get_norm_var_out(self, out_ref_train, out_nrm_train)
% Find the normalization of the output variables.
%
%    Use the training dataset to normalize.
%    First, scale the dataset with the normalization output data.
%    Secondly, appy the specified variable transformation.
%    Then, find the normalization on the resulting values.
%
%    Parameters:
%        out_ref_train (struct): training normalization output data
%        out_nrm_train (struct): training output reference data
%
%    Returns:
%        norm_param (cell): normalization data

for i=1:length(self.var_out)
    % extract variable
    name_tmp = self.var_out{i}.name;
    var_trf_tmp = self.var_out{i}.var_trf;
    var_norm_tmp = self.var_out{i}.var_norm;
    use_nrm_tmp = self.var_out{i}.use_nrm;
    
    % extract value
    value_tmp = out_ref_train.(name_tmp);
    scale_tmp = out_nrm_train.(name_tmp);
    
    % if asked, scale with the normalization data
    if use_nrm_tmp==true
        value_tmp = value_tmp./scale_tmp;
    end
    
    % transform and normalize
    value_tmp = self.get_var_trf(value_tmp, var_trf_tmp, 'scale');
    norm_param_tmp = self.get_var_norm_param(value_tmp, var_norm_tmp);
    
    % assign result
    norm_param{i} = norm_param_tmp;
end

end
