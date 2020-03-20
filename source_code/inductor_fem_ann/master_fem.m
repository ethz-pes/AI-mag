function master_fem(file_init, folder_fem, file_model, model_type, var_type, sweep)

% name
fprintf('################## master_fem\n')

% load
fprintf('load\n')
const = load(file_init);

% sweep
fprintf('sweep\n')
[n_sol, inp] = get_sweep(sweep);

% fem
fprintf('fem\n')
fem_ann.get_fem(folder_fem, file_model, model_type, var_type, n_sol, inp, const);

fprintf('################## master_fem\n')

end