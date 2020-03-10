function master_train(file_ann, file_assemble, ann_input, tag_train)

% name
fprintf('################## master_train\n')

% load
fprintf('load\n')
data_tmp = load(file_assemble);
n_sol = data_tmp.n_sol;
inp = data_tmp.inp;
out_fem = data_tmp.out_fem;
out_approx = data_tmp.out_approx;
model_type = data_tmp.model_type;

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
save(file_ann, 'ann_input', 'ann_data', 'model_type')

fprintf('################## master_train\n')

end
