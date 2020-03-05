function out_approx = get_approx(model_type, n_sol, inp, const)

% geometry
geom = get_struct_size(const.geom, n_sol);
physics = get_struct_size(const.physics, n_sol);

% geom
[is_valid_geom, geom] = get_geom(inp, geom);
[is_valid_physics, physics] = get_physics(model_type, inp, physics);
is_valid = is_valid_geom&is_valid_physics;
assert(all(is_valid==true), 'invalid data');

% get approx
out_approx = get_out_approx(model_type, geom, physics);

end