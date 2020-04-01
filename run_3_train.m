function run_3_train()

init_toolbox();

%% run
% run_sub('ht');
run_sub('mf');

end

function run_sub(model_type)

% sim_name
file_assemble = ['data/' model_type '_assemble.mat'];
file_ann = ['data/' model_type '_ann.mat'];

% data
[ann_input, tag_train] = get_fem_ann_data_train(model_type, 'matlab_ann');

% master_train
master_train(file_ann, file_assemble, ann_input, tag_train)

end
