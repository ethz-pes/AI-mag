function run_1_fem()

addpath(genpath('source_code'))
addpath(genpath('source_input'))
close('all')

%% run
run_sub('ht');
run_sub('mf');

end

function run_sub(model_type)

% sim_name
folder_fem = ['data/fem_' model_type];
file_fem = ['data/' model_type '_fem.mat'];

% data
const = get_data_const();

% type
var_type.geom = 'rel';
var_type.excitation = 'rel';

% master_fem
sweep = get_data_sweep(model_type, 'random', 6000);
master_fem(file_fem, folder_fem, model_type, var_type, sweep, const);

sweep = get_data_sweep(model_type, 'matrix', 2);
master_fem(file_fem, folder_fem, model_type, var_type, sweep, const);

end
