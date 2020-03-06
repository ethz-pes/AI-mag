function master_assemble(file_assemble, file_fem, folder_fem)

% name
fprintf('################## master_assemble\n')

% load
fprintf('load\n')
data_tmp = load(file_fem);
const = data_tmp.const;
model_type = data_tmp.model_type;
var_type = data_tmp.var_type;

% run
fprintf('assemble\n')
[n_tot, n_sol, inp, out_fem] = get_assemble(folder_fem);

fprintf('approx\n')
out_approx = get_out_approx(model_type, inp);

% disp
fprintf('size\n')
fprintf('    n_tot = %d\n', n_tot)
fprintf('    n_sol = %d\n', n_sol)

% save
fprintf('save\n')
save(file_assemble, 'n_sol', 'inp', 'out_fem', 'out_approx', 'model_type', 'var_type', 'const')

fprintf('################## master_assemble\n')

end
