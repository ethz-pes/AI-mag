function out_approx = get_out_approx(model_type, param)

% approx
switch model_type
    case 'mf'
        out_approx = get_out_approx_mf(param);
    case 'ht'
        out_approx = get_out_approx_ht(param);
    otherwise
        error('invalid model')
end

end