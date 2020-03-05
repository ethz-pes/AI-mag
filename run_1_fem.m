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
file_fem = ['data/' model_type '_fem.mat'];

% data
const = get_data_const();
sweep = get_data_sweep('random', 6000);

type.model = 'model_type';
type.model = 'model_type';
type.model = 'model_type';

% master_fem
master_fem(file_fem, folder_fem, model_type, sweep, const);

end
