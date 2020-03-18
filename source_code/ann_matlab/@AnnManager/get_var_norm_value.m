function y = get_var_norm_value(x, norm_param, scale_unscale)

switch scale_unscale
    case 'scale'
        y = (x-norm_param.offset)./norm_param.scale;
    case 'unscale'
        y = x.*norm_param.scale+norm_param.offset;
    otherwise
        error('invalid type')
end
end
