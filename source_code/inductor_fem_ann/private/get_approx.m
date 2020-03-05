function out_approx = get_approx(model_type, n_sol, inp, const)

% geometry
geom = get_struct_size(const.geom, n_sol);
physics = get_struct_size(const.physics, n_sol);

% geom
[is_valid_geom, geom] = get_geom(inp, geom);
[is_valid_physics, physics] = get_physics(model_type, inp, physics);
is_valid = is_valid_geom&is_valid_physics;
assert(all(is_valid==true), 'invalid data');

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