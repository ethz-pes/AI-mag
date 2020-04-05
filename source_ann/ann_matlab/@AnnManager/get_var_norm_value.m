function vec_output = get_var_norm_value(vec_input, norm_param, scale_unscale)
% Apply a given normalization or denormalization to a vector.
%
%    Parameters:
%        vec_input (vector): vector with the input data
%        norm_param (struct): normalization data
%        scale_unscale (str): normalization or denormalization ('scale' or 'unscale')
%
%    Returns:
%        vec_output (vector): vector with the output data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

switch scale_unscale
    case 'scale'
        vec_output = (vec_input-norm_param.offset)./norm_param.scale;
    case 'unscale'
        vec_output = vec_input.*norm_param.scale+norm_param.offset;
    otherwise
        error('invalid type')
end

end
