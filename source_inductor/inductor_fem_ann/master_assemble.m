function master_assemble(file_assemble, folder_fem)
% Assemble FEM simulations into a single file.
%
%    Load all the FEM results, assemble them.
%    Filter out the invalid simulations.
%    Compute the same samples with the analytical model.
%
%    Parameters:
%        file_assemble (str): path of the file to be written with the assembled data
%        folder_fem (str): path of the folder to stored the results
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_assemble\n')

% load, assemble, and filter the FEM simulations
fprintf('assemble\n')
[diff, n_tot, n_sol, model_type, file_model, inp, out_fem] = fem_ann.get_assemble(folder_fem);

% compute the analytical results
fprintf('approx\n')
out_approx = fem_ann.get_out_approx(model_type, inp);

% display information about the dataset
fprintf('info\n')
fprintf('    diff = %s\n', char(diff))
fprintf('    n_tot = %d\n', n_tot)
fprintf('    n_sol = %d\n', n_sol)

% save data
fprintf('save\n')
save(file_assemble, 'diff', 'n_sol', 'n_tot', 'inp', 'out_fem', 'out_approx', 'model_type', 'file_model')

% teardown
fprintf('################## master_assemble\n')

end
