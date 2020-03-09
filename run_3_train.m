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
file_assemble = ['data/' model_type '_assemble.mat'];
file_ann = ['data/' model_type '_ann.mat'];

% data
tag_train = 'none';
ann_input = get_data_ann_input(model_type, 'matlab_ga');

% master_train
master_train(file_ann, file_assemble, ann_input, tag_train)

end
