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
fct_extend_param_tmp = @(param) fct_extend_param(model_type, param);
fct_out_fem_tmp = @(param) fct_out_fem(model_type, param);

% master_fem
sweep = get_data_sweep(model_type, 'random', 1000);
master_fem(folder_fem, sweep, const, fct_extend_param_tmp, fct_out_fem_tmp);

end
