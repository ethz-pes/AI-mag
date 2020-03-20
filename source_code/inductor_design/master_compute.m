function master_compute(file_compute, file_export, sweep, n_split, data_ann, data_compute)

% name
fprintf('################## master_compute\n')

% load
fprintf('load\n')
data_fem_ann = load(file_export);

keyboard



% init
fprintf('create ann\n')
obj = AnnManager(ann_input);

% train
fprintf('train ann\n')
obj.train(tag_train, n_sol, inp, out_fem, out_approx);

% disp
obj.disp();

% dump
fprintf('dump ann\n')
[ann_input, ann_data] = obj.dump();

fprintf('delete ann\n')
obj.delete();

% save
fprintf('save\n')
save(file_compute, 'ann_input', 'ann_data', 'model_type')

fprintf('################## master_compute\n')

end
