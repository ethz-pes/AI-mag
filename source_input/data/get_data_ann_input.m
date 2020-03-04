function ann_input = get_data_ann_input(model_type, ann_type)

assert(any(strcmp(model_type, {'ht', 'mf'})), 'invalid model_type')

% var_inp
if any(strcmp(model_type, {'ht', 'mf'}))
    var_inp.fact_window = struct('var_trf', 'log', 'var_norm', 'avg');
    var_inp.fact_core = struct('var_trf', 'log', 'var_norm', 'avg');
    var_inp.fact_core_window = struct('var_trf', 'log', 'var_norm', 'avg');
    var_inp.fact_gap = struct('var_trf', 'log', 'var_norm', 'avg');
    var_inp.volume_target = struct('var_trf', 'log', 'var_norm', 'avg');
end
if strcmp(model_type, 'ht')
    var_inp.ht_stress = struct('var_trf', 'log', 'var_norm', 'avg');
    var_inp.ht_sharing = struct('var_trf', 'log', 'var_norm', 'avg');
end

% var_out
if strcmp(model_type, 'mf')
    var_out.L_norm = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
    var_out.B_norm = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
    var_out.J_norm = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
    var_out.H_norm = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
end
if strcmp(model_type, 'ht')
    var_out.T_core_max = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
    var_out.T_core_avg = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
    var_out.T_winding_max = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
    var_out.T_winding_avg = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
end

% split_train_test
split_train_test.ratio_train = 0.5;
split_train_test.n_min = 4;
split_train_test.type = 'no_overlap';

% split_var
split_var = false;

% ann_info
switch ann_type
    case 'matlab'
        ann_info.type = 'matlab';
        ann_info.fct_model = @get_model;
        ann_info.fct_train = @get_train;
    case 'python'
        ann_info.type = 'python';
        ann_info.hostname = 'localhost';
        ann_info.port = 10000;
        ann_info.timeout = 120;
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

function model = get_model(tag_train, n_sol, n_inp, n_out)

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

function [model, history] = get_train(tag_train, model, inp, out)

assert(ischar(tag_train), 'invalid output')
[model, history] = train(model, inp, out);

end