function out_approx = get_approx(model_type, n_sol, inp, const)

% geometry
const = get_struct_size(const, n_sol);
param = get_struct_merge(inp, const);

% geom
[is_valid, param] = get_extend_param(model_type, param);
assert(all(is_valid==true), 'invalid data');

% get approx
out_approx = get_out_approx(model_type, param);

end