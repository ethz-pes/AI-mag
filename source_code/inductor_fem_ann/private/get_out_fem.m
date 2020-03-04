function out_fem = get_out_fem(inp, geom, model_type, fem, material)

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
        inp_tmp = struct();
    case 'ht'
        model = mphload([path filesep() 'model_ht.mph']);
        inp_tmp.P_tot = inp.ht_stress.*geom.S_box;
        inp_tmp.P_core = sqrt(inp_tmp.P_tot./inp.ht_sharing);
        inp_tmp.P_winding = sqrt(inp_tmp.P_tot.*inp.ht_sharing);
    otherwise
        error('invalid type')
end

% tag
tag_sol = 'sol1';
tag_param = 'default';

% fem
fem = get_mesh(fem, geom);

% set param
param = get_struct_merge(geom, inp_tmp, fem, material);
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

function fem = get_mesh(fem, geom)

% fem
d_char_all = max([geom.x_box geom.y_box geom.z_box]);
d_char_core = min([geom.t_core geom.z_core]);
d_char_winding = min([geom.x_window geom.y_window geom.z_core]);
d_char_min = min([geom.d_gap geom.d_iso geom.r_fill]);
d_char_air = min([geom.x_box geom.y_box geom.z_box]);
d_char_iso = min([d_char_core d_char_winding]);

% assign
fem.d_air = d_char_all.*fem.fact_air;
fem.d_mesh_core = d_char_core./fem.n_mesh_max;
fem.d_mesh_winding = d_char_winding./fem.n_mesh_max;
fem.d_mesh_air = d_char_air./fem.n_mesh_max;
fem.d_mesh_iso = d_char_iso./fem.n_mesh_max;
fem.d_mesh_min = d_char_min./fem.n_mesh_min;

end