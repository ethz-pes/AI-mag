function y = get_var_trf(x, type, scale_unscale)

switch type
    case 'lin'
        y_scale = x;
        y_unscale = x;
    case 'rev'
        y_scale = 1./x;
        y_unscale = 1./x;
    case 'log'
        y_scale = log10(x);
        y_unscale = 10.^x;
    case 'exp'
        y_scale = 10.^x;
        y_unscale = log10(x);
    case 'square'
        y_scale = x.^2;
        y_unscale = sqrt(x);
    case 'sqrt'
        y_scale = sqrt(x);
        y_unscale = x.^2;
    otherwise
        error('invalid data')
end

switch scale_unscale
    case 'scale'
        y = y_scale;
    case 'unscale'
        y = y_unscale;
    otherwise
        error('invalid data')
end

end