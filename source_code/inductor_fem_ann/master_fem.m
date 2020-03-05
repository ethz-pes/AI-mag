function master_fem(file_fem, folder_fem, model_type, sweep, const)

% name
fprintf('################## master_fem\n')

% sweep
fprintf('sweep\n')
[n_sol, inp] = get_sweep(sweep);

% save
fprintf('save\n')
save(file_fem, 'model_type', 'const')

% fem
fprintf('fem\n')
get_fem(folder_fem, model_type, n_sol, inp, const);

fprintf('################## master_fem\n')

end