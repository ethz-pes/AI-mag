function master_fem(file_init, folder_fem, file_model, model_type, var_type, sweep)
% Make many FEM simulations for different variable combinations.
%
%    Sweep different combinations.
%    Extract the FEM results and save them.
%
%    This function saves the results during the solving process:
%        - The results are stored with an hash
%        - If the hash already exists the simulation is skiped
%        - Therefore, this function can be interrupted and restarted
%
%    This function requires a running COMSOL MATLAB Livelink:
%        - use 'start_comsol_matlab.bat' on MS Windows
%        - use 'start_comsol_matlab.sh' on Linux
%
%    Parameters:
%        file_init (str): path of the file containing the constant data
%        folder_fem (str): path of the folder where the results are stored 
%        file_model (str): path of the COMSOL file to be used for the simulations
%        model_type (str): name of the physics to be solved
%        var_type (struct): type of the different variables used in the solver
%        sweep (struct): data controlling the samples generation
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_fem\n')

% load the constant data
fprintf('load\n')
const = load(file_init);

% generate the combinations to be computed
fprintf('sweep\n')
[n_sol, inp] = get_sweep(sweep);

% create the folder for storing the simulations
fprintf('folder\n')
[s, m] = mkdir(folder_fem);

% make the simulations
fprintf('fem\n')
fem_ann.get_fem(folder_fem, file_model, model_type, var_type, n_sol, inp, const);

% teardown
fprintf('################## master_fem\n')

end