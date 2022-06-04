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
        y_scale = vec_input;
        y_unscale = vec_input;
    case 'rev'
        y_scale = 1./vec_input;
        y_unscale = 1./vec_input;
    case 'log'
        y_scale = log10(vec_input);
        y_unscale = 10.^vec_input;
    case 'exp'
        y_scale = 10.^vec_input;
        y_unscale = log10(vec_input);
    case 'square'
        y_scale = vec_input.^2;
        y_unscale = sqrt(vec_input);
    case 'sqrt'
        y_scale = sqrt(vec_input);
        y_unscale = vec_input.^2;
    otherwise
        error('invalid variable transformation method')
end

switch scale_unscale
    case 'scale'
        vec_output = y_scale;
    case 'unscale'
        vec_output = y_unscale;
    otherwise
        error('invalid scaling / unscaling choice')
end

end
