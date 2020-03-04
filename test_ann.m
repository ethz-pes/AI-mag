function test_ann()

%% name
addpath('ann_matlab')

name = 'test';

%% var_inp
var_inp.fact_window = struct('var_trf', 'log', 'var_norm', 'avg');
var_inp.fact_core = struct('var_trf', 'log', 'var_norm', 'avg');

%% var_out
var_out.L_norm = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
var_out.J_norm = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);
var_out.H_norm = struct('var_trf', 'lin', 'var_norm', 'avg', 'use_scl', true);

%% split_train_test
split_train_test.ratio_train = 0.5;
split_train_test.n_min = 4;
split_train_test.type = 'no_overlap';

%% split_var
split_var = false;

%% ann_info
% ann_info.type = 'matlab';
% ann_info.fct_model = @get_model;
% ann_info.fct_train = @get_train;

ann_info.type = 'python';
ann_info.hostname = 'localhost';
ann_info.port = 10000;

%% init
input.var_inp = var_inp;
input.var_out = var_out;
input.fct_scl = @fct_scl;
input.split_train_test = split_train_test;
input.split_var = split_var;
input.ann_info = ann_info;

obj = AnnManager('test', input);

%% train
n_sol = 200;

inp.fact_window = rand(1, n_sol);
inp.fact_core = rand(1, n_sol);

out_ref.L_norm = rand(1, n_sol);
out_ref.J_norm = rand(1, n_sol);
out_ref.H_norm = rand(1, n_sol);

tag = 'test';
obj.train(n_sol, inp, out_ref, tag)

%% disp
obj.disp();

%% predict
n_sol = 200;

inp.fact_window = rand(1, n_sol);
inp.fact_core = rand(1, n_sol);

[out_ann, out_scl] = obj.predict(n_sol, inp);

%% dump
[input, properties] = obj.dump();
obj.delete();

%% load
obj = AnnManager('test', input);
obj.load(properties);

[out_ann, out_scl] = obj.predict(n_sol, inp);

end

function model = get_model(n_sol, n_inp, n_out, tag)

assert(isfinite(n_sol), 'invalid input')
assert(isfinite(n_inp), 'invalid input')
assert(isfinite(n_out), 'invalid output')
assert(ischar(tag), 'invalid output')

model = fitnet(8);
model.trainParam.min_grad = 1e-8;
model.trainParam.epochs = 300;
model.trainParam.max_fail = 25;
model.divideParam.trainRatio = 0.8;
model.divideParam.valRatio = 0.2;
model.divideParam.testRatio = 0.0;

end

function [model, history] = get_train(model, inp, out, tag)

assert(ischar(tag), 'invalid output')
[model, history] = train(model, inp, out);

end

function out_scale = fct_scl(n_sol, inp)

out_scale.L_norm = rand(1, n_sol);
out_scale.J_norm = rand(1, n_sol);
out_scale.H_norm = rand(1, n_sol);

end