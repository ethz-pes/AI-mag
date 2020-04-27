function run_3_train()
% Create a ANN/regression and train/fit it with the assembled simulation data.
%
%    Load the simulation data.
%    Train/fit the ANN/regression with the data.
%    Obtain, display, and plot the dataset and error metrics.
%
%    This function requires a running ANN Python Server (if this regression method is used):
%        - run 'run_ann_server.py' with Python
%        - use 'start_python_ann_server.bat' on MS Windows
%        - use 'start_python_ann_server.sh' on Linux
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% run the thermal model
run_sub('ht');

% run the magnetic model
run_sub('mf');

end

function run_sub(model_type)
% Make the ANN/regression for a specified physics.
%
%    Parameters:
%        model_type (str): name of the physics to be solved

% path of the file with the assembled data
file_assemble = ['data/' model_type '_assemble.mat'];

% path of the file to be written with the ANN/regression data
file_ann = ['data/' model_type '_ann.mat'];

% get the ANN/regression parameters
ann_input = get_fem_ann_data_train(model_type, 'matlab_ann');

% make the ANN/regression
master_train(file_ann, file_assemble, ann_input)

end
