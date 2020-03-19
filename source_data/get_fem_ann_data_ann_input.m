function ann_input = get_fem_ann_data_ann_input(model_type, ann_type)

assert(any(strcmp(model_type, {'ht', 'mf'})), 'invalid model_type')

% var_inp
var_inp = {};
if any(strcmp(model_type, {'ht', 'mf'}))
    var_inp{end+1} = struct('name', 'fact_window', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*2.0, 'max', 1.01.*4.0);
    var_inp{end+1} = struct('name', 'fact_core', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*1.0, 'max', 1.01.*3.0);
    var_inp{end+1} = struct('name', 'fact_core_window', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.3, 'max', 1.01.*3.0);
    var_inp{end+1} = struct('name', 'fact_gap', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.01, 'max', 1.01.*0.2);
    var_inp{end+1} = struct('name', 'V_box', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.01e-3, 'max', 1.01.*1e-3);
end
if strcmp(model_type, 'mf')
    var_inp{end+1} = struct('name', 'J_winding', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.1e6, 'max', 1.01.*20e6);
end
if strcmp(model_type, 'ht')
    var_inp{end+1} = struct('name', 'p_density_tot', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.01e4, 'max', 1.01.*0.6e4);
    var_inp{end+1} = struct('name', 'p_ratio_winding_core', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.1, 'max', 1.01.*10.0);
end

% var_out
var_out = {};
if strcmp(model_type, 'mf')
    var_out{end+1} = struct('name', 'L_norm', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
    var_out{end+1} = struct('name', 'B_norm', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
    var_out{end+1} = struct('name', 'J_norm', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
    var_out{end+1} = struct('name', 'H_norm', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
end
if strcmp(model_type, 'ht')
    var_out{end+1} = struct('name', 'dT_core_max', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
    var_out{end+1} = struct('name', 'dT_core_avg', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
    var_out{end+1} = struct('name', 'dT_winding_max', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
    var_out{end+1} = struct('name', 'dT_winding_avg', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
    var_out{end+1} = struct('name', 'dT_iso_max', 'var_trf', 'lin', 'var_norm', 'min_max', 'use_nrm', true);
end

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