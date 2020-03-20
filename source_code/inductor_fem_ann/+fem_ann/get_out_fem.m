function out_fem = get_out_fem(file_model, model_type, inp)

% get expression
switch model_type
    case 'mf'
        expr = {'L_norm', 'B_norm', 'J_norm', 'H_norm'};
    case 'ht'
        expr = {'dT_core_max', 'dT_core_avg', 'dT_winding_max', 'dT_winding_avg', 'dT_iso_max'};
    otherwise
        error('invalid type')
end

% load
model = mphload(file_model);

% tag
tag_sol = 'sol1';
tag_param = 'default';

% mesh
inp = get_mesh(inp);

% set param
set_parameter(model, tag_param, inp)

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

function inp = get_mesh(inp)

% fem
d_char_all = max([inp.x_box inp.y_box inp.z_box]);
d_char_core = min([inp.t_core inp.z_core]);
d_char_winding = min([inp.x_window inp.y_window inp.z_core]);
d_char_min = min([inp.d_gap inp.d_iso inp.r_fill]);
d_char_air = min([inp.x_box inp.y_box inp.z_box]);
d_char_iso = min([d_char_core d_char_winding]);

% assign
inp.d_air = d_char_all.*inp.fact_air;
inp.d_mesh_core = d_char_core./inp.n_mesh_max;
inp.d_mesh_winding = d_char_winding./inp.n_mesh_max;
inp.d_mesh_air = d_char_air./inp.n_mesh_max;
inp.d_mesh_iso = d_char_iso./inp.n_mesh_max;
inp.d_mesh_min = d_char_min./inp.n_mesh_min;

end