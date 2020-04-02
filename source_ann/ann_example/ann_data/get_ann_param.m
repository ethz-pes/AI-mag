function [ann_input, tag_train] = get_ann_param(ann_type)

% var_inp
var_inp = {};
var_inp{end+1} = struct('name', 'x_1', 'var_trf', 'lin', 'var_norm', 'min_max', 'min', 0.99.*7.0, 'max', 1.01.*10.0);
var_inp{end+1} = struct('name', 'x_2', 'var_trf', 'lin', 'var_norm', 'min_max', 'min', 0.99.*1.0, 'max', 1.01.*6.0);

% var_out
var_out = {};
var_out{end+1} = struct('name', 'y_1', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true, 'var_err', 'rel');
var_out{end+1} = struct('name', 'y_2', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true, 'var_err', 'rel');

% split_train_test
split_train_test.ratio_train = 0.5;
split_train_test.n_train_min = 5;
split_train_test.n_test_min = 5;
split_train_test.type = 'no_overlap';

% split the variable
split_var = false;

% ann_info
switch ann_type
    case 'matlab_ann'
        ann_info.type = ann_type;
        ann_info.fct_model = @fct_model;
        ann_info.fct_train = @fct_train;
    case 'python_ann'
        ann_info.type = ann_type;
        ann_info.hostname = 'localhost';
        ann_info.port = 10000;
        ann_info.timeout = 240;
    case 'matlab_lsq'
        ann_info.type = ann_type;
        ann_info.options = struct(...
            'Display', 'off',...
            'FunctionTolerance', 1e-6,...
            'StepTolerance', 1e-6,...
            'MaxIterations', 1e3,...
            'MaxFunctionEvaluations', 10e3);
        ann_info.x_value = struct(...
            'x0', [0.0 0.0 0.0 0.0 0.0 0.0],...
            'ub', [+20.0 +20.0 +20.0 +20.0 +20.0 +20.0],...
            'lb', [-20.0 -20.0 -20.0 -20.0 -20.0 -20.0]);
        ann_info.fct_fit = @fct_fit;
        ann_info.fct_err = @fct_err_vec;
    case 'matlab_ga'
        ann_info.type = ann_type;
        ann_info.options = struct(...
            'Display', 'off',...
            'TolFun', 1e-6,...
            'ConstraintTolerance', 1e-3,...
            'Generations', 40,...
            'PopulationSize', 1000);
        ann_info.x_value = struct(...
            'n', 6,...
            'ub', [+20.0 +20.0 +20.0 +20.0 +20.0 +20.0],...
            'lb', [-20.0 -20.0 -20.0 -20.0 -20.0 -20.0]);
        ann_info.fct_fit = @fct_fit;
        ann_info.fct_err = @fct_err_sum;
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

model = fitnet(4);
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

function out_mat_fit = fct_fit(tag_train, x, inp_mat)

assert(ischar(tag_train), 'invalid output');

x_1 = inp_mat(1, :);
x_2 = inp_mat(2, :);

y_1 = x(1)+x(2).*x_1+x(3).*x_2;
y_2 = x(4)+x(5).*x_1+x(6).*x_2;

out_mat_fit = [y_1 ; y_2];

end

function err_vec = fct_err_vec(tag_train, x, inp_mat, out_mat_ref)

assert(ischar(tag_train), 'invalid output')

out_mat_fit = fct_fit(tag_train, x, inp_mat);
err_vec = out_mat_ref-out_mat_fit;
err_vec = err_vec(:);

end

function err = fct_err_sum(tag_train, x, inp, out)

assert(ischar(tag_train), 'invalid output')

err_vec = fct_err_vec(tag_train, x, inp, out);
err = sum(err_vec.^2);

end
