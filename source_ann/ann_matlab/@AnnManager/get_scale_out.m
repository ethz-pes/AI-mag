function out_mat = get_scale_out(self, out_ref, out_nrm)
% Scale the output data and transform them into matrix.
%
%    First, scale the dataset with the normalization output data (if asked).
%    Secondly, appy the specified variable transformation.
%    Then, normalize on the resulting values.
%    Finally, transform the struct into a matrix
%
%    Parameters:
%        out_ref (struct): output data
%        out_nrm (struct): output reference data
%
%    Returns:
%        out_mat (matrix): scaled output data

for i=1:length(self.var_out)
    % extract variable
    name_tmp = self.var_out{i}.name;
    var_trf_tmp = self.var_out{i}.var_trf;
    use_nrm_tmp = self.var_out{i}.use_nrm;
    norm_param_tmp = self.norm_param_out{i};
    
    % extract value
    value_tmp = out_ref.(name_tmp);
    scale_tmp = out_nrm.(name_tmp);
    
    % if asked, scale with the normalization data
    if use_nrm_tmp==true
        value_tmp = value_tmp./scale_tmp;
    end
    
    % transform and normalize
    value_tmp = AnnManager.get_var_trf(value_tmp, var_trf_tmp, 'scale');
    value_tmp = AnnManager.get_var_norm_value(value_tmp, norm_param_tmp, 'scale');
    
    % assign result
    out_mat(i,:) = value_tmp;
end

end
