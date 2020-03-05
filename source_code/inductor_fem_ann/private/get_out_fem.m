function out_fem = get_out_fem(model_type, param)

% get expression
switch model_type
    case 'mf'
        expr = {'L_norm', 'B_norm', 'J_norm', 'H_norm'};
    case 'ht'
        expr = {'T_core_max', 'T_core_avg', 'T_winding_max', 'T_winding_avg'};
    otherwise
        error('invalid type')
end
       
% load
path = fileparts(mfilename('fullpath'));
switch model_type
    case 'mf'
        model = mphload([path filesep() 'model_mf.mph']);
    case 'ht'
        model = mphload([path filesep() 'model_ht.mph']);
    otherwise
        error('invalid type')
end

% tag
tag_sol = 'sol1';
tag_param = 'default';

% mesh
param = get_mesh(param);

% set param
set_parameter(model, tag_param, param)

% run the model
model.sol(tag_sol).runAll;

% extract the results
out_fem = get_global(model, expr);

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

function param = get_mesh(param)

% fem
d_char_all = max([param.x_box param.y_box param.z_box]);
d_char_core = min([param.t_core param.z_core]);
d_char_winding = min([param.x_window param.y_window param.z_core]);
d_char_min = min([param.d_gap param.d_iso param.r_fill]);
d_char_air = min([param.x_box param.y_box param.z_box]);
d_char_iso = min([d_char_core d_char_winding]);

% assign
param.d_air = d_char_all.*param.fact_air;
param.d_mesh_core = d_char_core./param.n_mesh_max;
param.d_mesh_winding = d_char_winding./param.n_mesh_max;
param.d_mesh_air = d_char_air./param.n_mesh_max;
param.d_mesh_iso = d_char_iso./param.n_mesh_max;
param.d_mesh_min = d_char_min./param.n_mesh_min;

end