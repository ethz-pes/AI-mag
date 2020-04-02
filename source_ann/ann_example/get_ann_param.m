function [ann_input, tag_train] = get_ann_param(ann_type)

% var_inp
var_inp = {};
var_inp{end+1} = struct('name', 'x_1', 'var_trf', 'lin', 'var_norm', 'min_max', 'min', 0.99.*6.0, 'max', 1.01.*9.0);
var_inp{end+1} = struct('name', 'x_2', 'var_trf', 'lin', 'var_norm', 'min_max', 'min', 0.99.*1.0, 'max', 1.01.*6.0);

% var_out
var_out = {};
var_out{end+1} = struct('name', 'y_1', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true, 'var_err', 'rel');
var_out{end+1} = struct('name', 'y_2', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true, 'var_err', 'rel');

% split_train_test
split_train_test.ratio_train = 0.5;
split_train_test.n_min = 4;
split_train_test.type = 'no_overlap';

% split the variable
split_var = false;

% ann_info
switch ann_type
    case 'matlab_ann'
        ann_info.type = 'matlab_ann';
        ann_info.fct_model = @fct_model;
        ann_info.fct_train = @fct_train;
    case 'python_ann'
        ann_info.type = 'python_ann';
        ann_info.hostname = 'localhost';
        ann_info.port = 10000;
        ann_info.timeout = 240;
    otherwise
        error('invalid data')
end

% assign
ann_input.var_inp = var_inp;
ann_input.var_out = var_out;
ann_input.split_train_test = split_train_test;
ann_input.split_var = split_var;
ann_input.ann_info = ann_info;

% tag_train
tag_train = 'none';

end

function model = fct_model(tag_train, n_sol, n_inp, n_out)

assert(ischar(tag_train), 'invalid output')
assert(isfinite(n_sol), 'invalid input')
assert(isfinite(n_inp), 'invalid input')
assert(isfinite(n_out), 'invalid output')

model = fitnet(8);
model.trainParam.min_grad = 1e-8;
model.trainParam.epochs = 300;
model.trainParam.max_fail = 25;
model.divideParam.trainRatio = 0.8;
model.divideParam.valRatio = 0.2;
model.divideParam.testRatio = 0.0;

end

function [model, history] = fct_train(tag_train, model, inp, out)

assert(ischar(tag_train), 'invalid output')
[model, history] = train(model, inp, out);

end