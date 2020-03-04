function fom_fem = fct_out_fem(model_type, param)

% get expression
switch model_type
    case 'mf'
        expr = {'L_norm', 'B_norm', 'J_norm', 'H_norm'};
    case 'ht'
        expr = {'T_core_max', 'T_core_avg', 'T_winding_max', 'T_winding_avg'};
    otherwise
        error('invalid type')
end
       
% compute
fom_fem = get_solve_fem(model_type, param, expr);

end

function fom_fem = get_solve_fem(model_type, param, expr)

% load
path = fileparts(mfilename('fullpath'));
switch model_type
    case 'mf'
        model = mphload([path '/../model/model_mf.mph']);
    case 'ht'
        model = mphload([path '/../model/model_ht.mph']);
    otherwise
        error('invalid type')
end

% tag
tag_sol = 'sol1';
tag_param = 'default';

% set param
set_parameter(model, tag_param, param)

% run the model
model.sol(tag_sol).runAll;

% extract the results
fom_fem = get_global(model, expr);

end

function set_parameter(model, tag_param, param)

str = model.param(tag_param).varnames();
for i=1:length(str)
    str_tmp = char(str(i));
    model.param(tag_param).set(str_tmp, param.(str_tmp));
end

end

function data = get_global(model, expr)

data_tmp = cell(1,length(expr));
[data_tmp{:}] = model.mphglobal(expr, 'Complexout','on');

for i=1:length(expr)
    data.(expr{i}) = data_tmp{i}.';
end

end

