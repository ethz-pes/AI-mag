function run_3_train()

addpath(genpath('source_code'))
addpath(genpath('source_input'))
close('all')

%% run
run_sub('ht');
% run_sub('mf');

end

function run_sub(model_type)

% sim_name
file_fem = ['data/' model_type '.mat'];

% data
[var_inp, var_out] = get_data_var(model_type);
[fct_net, split_var] = get_data_ann(model_type);

% master_train
master_train(file_fem, var_inp, var_out, fct_net, split_var)

end
