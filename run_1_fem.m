function run_1_fem()

addpath(genpath('source_code'))
addpath(genpath('source_input'))
close('all')

%% run
run_sub('ht');
% run_sub('mf');

end

function run_sub(model_type)

% sim_name
folder_fem = ['data/fem_' model_type];

% data
const = get_data_const(model_type);

% master_fem
sweep = get_data_sweep(model_type, 'random', 1000);
master_fem(folder_fem, sweep, const);

end
