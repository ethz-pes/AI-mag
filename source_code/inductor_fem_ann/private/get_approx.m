function out_approx = get_approx(n_sol, inp, const, fct_extend_param, fct_approx_fem)

const = get_struct_size(const, n_sol);
param = get_struct_merge(inp, const);

[is_valid, param] = fct_extend_param(param);
assert(all(is_valid==true), 'invalid data');

out_approx = fct_approx_fem(param);

end