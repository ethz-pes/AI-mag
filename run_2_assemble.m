function run_2_assemble()

addpath(genpath('source_code'))
addpath(genpath('source_input'))
close('all')

%% run
run_sub('ht');
run_sub('mf');

end

function run_sub(model_type)

% sim_name
file_init = 'data/fem_ann/init.mat';
folder_fem = ['data/fem_ann/fem_' model_type];
file_assemble = ['data/fem_ann/' model_type '_assemble.mat'];

% master_assemble_fem
master_assemble(file_assemble, file_init, folder_fem)

end