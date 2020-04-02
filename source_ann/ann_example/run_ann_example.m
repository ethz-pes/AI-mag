function run_ann_example()

addpath('../ann_matlab');

% master_train
master_train('matlab_ann')

end

function master_train(ann_type)

% name
fprintf('################## master_train\n')

% data
[ann_input, tag_train] = get_ann_param(ann_type);
[n_sol, inp, out_ref, out_nrm] = get_ann_data();

% test class
fprintf('constructor\n')
obj = AnnManager(ann_input);

fprintf('train\n')
obj.train(tag_train, n_sol, inp, out_ref, out_nrm);

fprintf('get_fom\n')
fom = obj.get_fom();
assert(isstruct(fom), 'invalid fom')

fprintf('disp\n')
obj.disp();

fprintf('dump\n')
[ann_input, ann_data] = obj.dump();

fprintf('delete\n')
obj.delete();

fprintf('predict\n')
predict(ann_input, ann_data, n_sol, inp, out_nrm)

fprintf('################## master_train\n')

end

function predict(ann_input, ann_data, n_sol, inp, out_nrm)

obj = AnnManager(ann_input);
obj.load(ann_data);

[is_valid_tmp, out_nrm_tmp] = obj.predict_nrm(n_sol, inp, out_nrm);
assert(islogical(is_valid_tmp), 'invalid fom')
assert(isstruct(out_nrm_tmp), 'invalid fom')

[is_valid_tmp, out_nrm_tmp] = obj.predict_ann(n_sol, inp, out_nrm);
assert(islogical(is_valid_tmp), 'invalid fom')
assert(isstruct(out_nrm_tmp), 'invalid fom')

obj.delete();

end
