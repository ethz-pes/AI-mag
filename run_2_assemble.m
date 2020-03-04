function run_2_assemble()

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
file_fem = ['data/' model_type '_fem.mat'];

% data
const = get_data_const(model_type);
fct_extend_param_tmp = @(param) fct_extend_param(model_type, param);
fct_approx_fem_tmp = @(param) fct_out_approx(model_type, param);

% master_assemble_fem
master_assemble(folder_fem, file_fem, const, fct_extend_param_tmp, fct_approx_fem_tmp)

end