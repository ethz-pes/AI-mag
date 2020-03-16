function master_fem(file_init, file_model, folder_fem, model_type, var_type, sweep)

% name
fprintf('################## master_fem\n')

% load
fprintf('load\n')
data_tmp = load(file_init);
const = data_tmp.const;

% sweep
fprintf('sweep\n')
[n_sol, inp] = get_sweep(sweep);

% fem
fprintf('fem\n')
get_fem(file_model, folder_fem, model_type, var_type, n_sol, inp, const);

fprintf('################## master_fem\n')

end