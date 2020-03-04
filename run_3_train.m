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
file_fem = ['data/' model_type '_fem.mat'];
file_ann = ['data/' model_type '_ann.mat'];

% data
ann_input = get_data_ann_input(model_type, 'python');
tag_train = 'none';

% master_train
master_train(file_fem, file_ann, ann_input, tag_train)

end
