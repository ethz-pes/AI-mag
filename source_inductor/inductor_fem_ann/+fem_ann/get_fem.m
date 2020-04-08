function get_fem(folder_fem, file_model, model_type, var_type, n_sol, inp, const)
% Make many FEM simulations for the given variable combinations.
%
%    The results are stored for every simulation with an hash as filename.
%    If the hash already exists the simulation is skiped.
%
%    Parameters:
%        folder_fem (str): path of the folder where the results are stored
%        file_model (str): path of the COMSOL file to be used for the simulations
%        model_type (str): name of the physics to be solved
%        var_type (struct): type of the different variables used in the solver
%        n_sol (int): number of simulations to be done
%        inp (struct): struct of vectors with the input combinations
%        const (struct): struct of with the constant data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

for i=1:n_sol
    fprintf('    %d / %d\n', i, n_sol)
    
    % get a specific combination
    inp_tmp =  get_struct_filter(inp, i);
    
    % simulate the selected input
    get_out_sub(file_model, folder_fem, model_type, var_type, inp_tmp, const);
end

end

function get_out_sub(file_model, folder_fem, model_type, var_type, inp, const)
% Make a FEM simulation for a given variable combination.
%
%    Parameters:
%        folder_fem (str): path of the folder where the results are stored
%        file_model (str): path of the COMSOL file to be used for the simulations
%        model_type (str): name of the physics to be solved
%        var_type (struct): type of the different variables used in the solver
%        inp (struct): struct of vectors with the selected input combination
%        const (struct): struct of with the constant data

% get filename with an hash
hash = get_struct_hash(inp);
filename = [folder_fem filesep() hash '.mat'];

% check if the simulation already exists, if not run it
make_computation = exist(filename, 'file')~=2;
if make_computation==true
    % start timer
    tic = datetime('now');
    fprintf('        compute: start\n')
    
    % merge the input and the constant data, extend the data with additional info
    n_sol = 1;
    [is_valid, inp] = fem_ann.get_extend_inp(const, model_type, var_type, n_sol, inp);
    
    % make the simulation if the combination is valid
    if is_valid==true
        fprintf('        compute: valid\n')
        out_fem = fem_ann.get_out_fem(file_model, model_type, inp);
    else
        fprintf('        compute: invalid\n')
        out_fem = struct();
    end
    
    % end timer
    toc = datetime('now');
    diff = toc-tic;
    fprintf('        compute: %s\n', char(diff))
    
    % save data with the hash
    save(filename, 'inp', 'is_valid', 'model_type', 'var_type', 'out_fem', 'diff')
end

end