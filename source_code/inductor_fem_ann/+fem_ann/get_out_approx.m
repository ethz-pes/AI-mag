function out_approx = get_out_approx(model_type, inp)

% approx
switch model_type
    case 'mf'
        out_approx = fem_ann.get_out_approx_mf(inp);
    case 'ht'
        out_approx = fem_ann.get_out_approx_ht(inp);
    otherwise
        error('invalid model')
end

end