function run_1_fem()

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
file_init = 'data/fem_ann/init.mat';
file_model = ['source_data/model/model_' model_type '.mph'];
folder_fem = ['data/fem_ann/fem_' model_type];

% type
var_type.geom_type = 'rel';
var_type.excitation_type = 'rel';

% master_fem
sweep = get_fem_ann_data_sweep(model_type, 'matrix', 2);
master_fem(file_init, file_model, folder_fem, model_type, var_type, sweep);

sweep = get_fem_ann_data_sweep(model_type, 'random', 6000);
master_fem(file_init, file_model, folder_fem, model_type, var_type, sweep);

end
