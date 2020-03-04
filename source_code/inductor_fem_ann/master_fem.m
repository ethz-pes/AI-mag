function master_fem(folder_fem, sweep, const)

% name
fprintf('################## master_fem\n')

% sweep
fprintf('sweep\n')
[n_sol, inp] = get_sweep(sweep);

% fem
fprintf('fem\n')
get_fem(folder_fem, n_sol, inp, const);

fprintf('################## master_fem\n')

end