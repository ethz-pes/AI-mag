function out_ann = get_unscale_out(self, out_nrm, out_mat)
% Unscale the output matrix and transform it into struct.
%
%    First, denormalize on the resulting values.
%    Secondly, appy the specified variable inverse transformation.
%    Then, unscale the values with the normalization output data (if asked).
%    Finally, transform the matrix into a struct
%
%    Parameters:
%        out_nrm (struct): output reference data
%        out_mat (matrix): scaled output data
%
%    Returns:
%        out_ann (struct): regression output data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

for i=1:length(self.var_out)
    % extract variable
    name_tmp = self.var_out{i}.name;
    var_trf_tmp = self.var_out{i}.var_trf;
    use_nrm_tmp = self.var_out{i}.use_nrm;
    norm_param_tmp = self.norm_param_out{i};
    
    % extract value
    scale_tmp = out_nrm.(name_tmp);
    value_tmp = out_mat(i,:);
    
    % denormalize and reverse transform
    value_tmp = AnnManager.get_var_norm_value(value_tmp, norm_param_tmp, 'unscale');
    value_tmp = AnnManager.get_var_trf(value_tmp, var_trf_tmp, 'unscale');
    
    % if asked, unscale with the normalization data
    if use_nrm_tmp==true
        value_tmp = value_tmp.*scale_tmp;
    end
    
    % assign result
    out_ann.(name_tmp) = value_tmp;
end

end
