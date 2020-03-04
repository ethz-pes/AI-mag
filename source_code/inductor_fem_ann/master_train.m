function master_train(file_fem, file_ann, ann_input, tag_train)

% name
fprintf('################## master_train\n')

% fem
fprintf('load\n')
data_tmp = load(file_fem);
n_sol = data_tmp.n_sol;
inp = data_tmp.inp;
out_fem = data_tmp.out_fem;
out_approx = data_tmp.out_approx;
const = data_tmp.const;
fct_param = data_tmp.fct_param;
fct_out_approx = data_tmp.fct_out_approx;

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
save(file_ann, 'ann_input', 'ann_data', 'const', 'fct_param', 'fct_out_approx')

fprintf('################## master_train\n')

end
