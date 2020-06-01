function get_fem_file(filename, file_model, model, model_type, var_type, inp, const)
% Make a FEM simulation for a given variable combination and write the result in a file.
%
%    Parameters:
%        filename (str): path of the file to be created with the results
%        file_model (str): path of the COMSOL file
%        model (model): COMSOL model containing the physics
%        model_type (str): name of the physics to be solved
%        var_type (struct): type of the different variables used in the solver
%        inp (struct): struct of scalars with the selected input combination
%        const (struct): struct of with the constant data

% start timer
tic = datetime('now');
fprintf('        compute: start\n')

% merge the input and the constant data, extend the data with additional info
n_sol = 1;
[is_valid, inp] = fem_ann.get_extend_inp(const, model_type, var_type, n_sol, inp);

% make the simulation if the combination is valid
if is_valid==true
    fprintf('        compute: valid\n')
    out_fem = fem_ann.get_out_fem(model, model_type, inp);
else
    fprintf('        compute: invalid\n')
    out_fem = struct();
end

% end timer
toc = datetime('now');
diff = toc-tic;
fprintf('        compute: %s\n', char(diff))

% save data with the hash
save(filename, '-v7.3', 'inp', 'file_model', 'is_valid', 'model_type', 'var_type', 'out_fem', 'diff')

end