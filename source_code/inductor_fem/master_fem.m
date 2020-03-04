function master_fem(folder_fem, sweep, const, fct_extend_param, fct_out_fem)

% name
fprintf('master_fem:\n')

% sweep
fprintf('    sweep\n')
[n_sol, inp] = get_sweep(sweep);

% fem
get_fem(folder_fem, n_sol, inp, const, fct_extend_param, fct_out_fem);

end