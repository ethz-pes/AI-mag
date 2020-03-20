function run_2_assemble()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% run
run_sub('ht');
run_sub('mf');

end

function run_sub(model_type)

% sim_name
folder_fem = ['data/fem_' model_type];
file_assemble = ['data/' model_type '_assemble.mat'];

% master_assemble_fem
master_assemble(file_assemble, folder_fem)

end