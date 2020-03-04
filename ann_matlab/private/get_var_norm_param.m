function norm_param = get_var_norm_param(x, type)

switch type
    case 'none'
        norm_param.offset = 0;
        norm_param.scale = 1;
    case 'min_max'
        norm_param.offset = min(x);
        norm_param.scale = max(x)-min(x);
    case 'avg'
        norm_param.offset = mean(x);
        norm_param.scale = 1;
    case 'std_dev'
        norm_param.offset = 0;
        norm_param.scale = std(x);
    case 'avg_std_dev'
        norm_param.offset = mean(x);
        norm_param.scale = std(x);
    otherwise
        error('invalid type')
end

end
