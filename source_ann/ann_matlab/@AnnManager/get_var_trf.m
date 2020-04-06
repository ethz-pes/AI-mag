function vec_output = get_var_trf(vec_input, type, scale_unscale)
% Apply a given variable transformation or inverse transformation to a vector.
%
%    Parameters:
%        vec_input (vector): vector with the input data
%        type (str): type of transformation to perform
%        scale_unscale (str): transformation or inverse transformation ('scale' or 'unscale')
%
%    Returns:
%        vec_output (vector): vector with the output data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

switch type
    case 'none'
        y_scl = vec_input;
        y_unscale = vec_input;
    case 'rev'
        y_scl = 1./vec_input;
        y_unscale = 1./vec_input;
    case 'log'
        y_scl = log10(vec_input);
        y_unscale = 10.^vec_input;
    case 'exp'
        y_scl = 10.^vec_input;
        y_unscale = log10(vec_input);
    case 'square'
        y_scl = vec_input.^2;
        y_unscale = sqrt(vec_input);
    case 'sqrt'
        y_scl = sqrt(vec_input);
        y_unscale = vec_input.^2;
    otherwise
        error('invalid type')
end

switch scale_unscale
    case 'scale'
        vec_output = y_scl;
    case 'unscale'
        vec_output = y_unscale;
    otherwise
        error('invalid type')
end

end
