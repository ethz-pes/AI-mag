function master_assemble(file_assemble, file_init, folder_fem)

% name
fprintf('################## master_assemble\n')

% load
fprintf('load\n')
const = load(file_init);

% run
fprintf('assemble\n')
[n_tot, n_sol, model_type, inp, out_fem] = get_assemble(folder_fem);

fprintf('approx\n')
out_approx = get_out_approx(model_type, inp);

% disp
fprintf('size\n')
fprintf('    n_tot = %d\n', n_tot)
fprintf('    n_sol = %d\n', n_sol)

% save
fprintf('save\n')
save(file_assemble, 'n_sol', 'inp', 'out_fem', 'out_approx', 'model_type')

fprintf('################## master_assemble\n')

end
