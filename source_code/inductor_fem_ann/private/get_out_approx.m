function out_approx = get_out_approx(model_type, geom, physics)

% approx
switch model_type
    case 'mf'
        out_approx = get_out_approx_mf(geom, physics);
    case 'ht'
        out_approx = get_out_approx_ht(geom, physics);
    otherwise
        error('invalid model')
end

end