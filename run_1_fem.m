function run_1_fem()
% Run the FEM simulations.
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
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% run the thermal model
run_sub('ht');

% run the magnetic model
run_sub('mf');

end

function run_sub(model_type)
% Run the FEM simulations for a specified physics.
%
%    Parameters:
%        model_type (str): name of the physics to be solved

% path of the file containing the constant data
file_init = 'data/init.mat';

% path of the folder where the results are stored
folder_fem = ['data/fem_' model_type];

% run the simulations with a regular grid with all the extreme cases
[file_model, var_type, sweep] = get_fem_ann_data_fem(model_type, 'extrema');
master_fem(file_init, folder_fem, file_model, model_type, var_type, sweep);

% run the simulations with a random samples
[file_model, var_type, sweep] = get_fem_ann_data_fem(model_type, 'random');
master_fem(file_init, folder_fem, file_model, model_type, var_type, sweep);

end
