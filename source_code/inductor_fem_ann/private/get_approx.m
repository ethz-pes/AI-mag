function out_approx = get_approx(n_sol, inp, const, fct_param, fct_out_approx)

const = get_struct_size(const, n_sol);
param = get_struct_merge(inp, const);

[is_valid, param] = fct_param(param);
assert(all(is_valid==true), 'invalid data');

out_approx = fct_out_approx(param);

end