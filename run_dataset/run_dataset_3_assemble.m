function run_dataset_3_assemble()
% Assemble FEM simulations into a single file.
%
%    Load all the FEM results, assemble them.
%    Filter out the invalid simulations.
%    Compute the same samples with the analytical model.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% run the thermal model
run_sub('ht');

% run the magnetic model
run_sub('mf');

end

function run_sub(model_type)
% Assemble the results for a specified physics.
%
%    Parameters:
%        model_type (str): name of the physics to be solved

% path of the folder where the results are stored
folder_fem = ['dataset/fem_' model_type];

% path of the file to be written with the assembled data
file_assemble = ['dataset/' model_type '_assemble.mat'];

% make a zip file and remove the folder (or not)
make_zip = true;

% assemble the data
master_assemble(file_assemble, folder_fem, make_zip)

end