function run_2_assemble()

addpath(genpath('source_code'))
addpath(genpath('source_input'))
close('all')

%% run
% run_sub('ht');
run_sub('mf');

end

function run_sub(model_type)

% sim_name
folder_fem = ['data/fem_' model_type];
file_fem = ['data/' model_type '_fem.mat'];
file_assemble = ['data/' model_type '_assemble.mat'];

% master_assemble_fem
master_assemble(file_assemble, file_fem, folder_fem)

end