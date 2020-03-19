function run_3_train()

addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% run
run_sub('ht');
run_sub('mf');

end

function run_sub(model_type)

% sim_name
file_assemble = ['data/fem_ann/' model_type '_assemble.mat'];
file_ann = ['data/fem_ann/' model_type '_ann.mat'];

% data
tag_train = 'none';
ann_input = get_fem_ann_data_ann_input(model_type, 'matlab_ann');

% master_train
master_train(file_ann, file_assemble, ann_input, tag_train)

end
