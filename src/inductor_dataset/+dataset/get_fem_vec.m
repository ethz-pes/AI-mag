function get_fem_vec(folder_fem, file_model, model_type, timing, var_type, n_sol, inp, const)
% Make many FEM simulations for the given variable combinations.
%
%    The results are stored for every simulation with an hash as filename.
%    If the hash already exists the simulation is skiped.
%
%    Parameters:
%        folder_fem (str): path of the folder where the results are stored
%        file_model (str): path of the COMSOL file to be used for the simulations
%        model_type (str): name of the physics to be solved
%        timing (struct): struct controlling simulation time (for batching systems)
%        var_type (struct): type of the different variables used in the solver
%        n_sol (int): number of simulations to be done
%        inp (struct): struct of vectors with the input combinations
%        const (struct): struct of with the constant data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% simulation start time
tic = datetime('now');

% run all the designs
i_reload = [];
is_ok = [];
model = [];
for i=1:n_sol
    % iteration
    fprintf('    %d / %d / %s\n', i, n_sol, get_diff(tic))
    
    % get combination
    [inp_tmp, is_hash_tmp, filename_tmp] = dataset.get_fem_idx(folder_fem, inp, i);
    
    % if the combination does not exist, run it
    if is_hash_tmp==false
        [model, is_ok, i_reload] = dataset.get_fem_load(file_model, timing, model, is_ok, i_reload);
        if is_ok==true
            dataset.get_fem_file(filename_tmp, file_model, model, model_type, var_type, inp_tmp, const);
        else
            fprintf('    model failure / %s\n', get_diff(tic))
            break;
        end
    end
end

end

function str = get_diff(tic)
% Get elapsed time.
%
%    Parameters:
%        tic (datetime): start time of the simulation
%
%    Returns:
%        str (str): string with the elapsed time

toc = datetime('now');
diff = toc-tic;
str = char(diff);

end