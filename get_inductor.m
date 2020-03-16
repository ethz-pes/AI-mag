function get_inductor

addpath(genpath('source_code'))
addpath(genpath('source_input'))
close all;

n_sol = 1;

ann_fem_obj = get_ann_fem();

data_vec = get_material();
data_material = get_data();
data_const = get_data_const();

obj = inductor(n_sol, data_vec, data_material, data_const, ann_fem_obj);
obj.get_plot('test', 1)

end

function excitation = get_excitation()

excitation.T_ambient = 40.0;
excitation.I_dc = 10.0;
excitation.f = 500e3;

end

function  data_vec = get_data()

geom.z_core = 25e-3;
geom.t_core = 20e-3;
geom.x_window = 15e-3;
geom.y_window = 45e-3;
geom.d_gap = 1e-3;

n_turn = 6;
I_test = 60;

%% fom_data
fom_data.m_scale = 1.0;
fom_data.m_offset = 0.0;
fom_data.V_scale = 1.0;
fom_data.V_offset = 0.0;
fom_data.cost_scale = 1.0;
fom_data.cost_offset = 0.0;

%% losses
losses_add.P_fraction = 1.0;
losses_add.P_offset = 0.0;

%% fom_limit
fom_limit.L = struct('min', 0.0, 'max', 1e9);
fom_limit.I_peak = struct('min', 0.0, 'max', 1e9);
fom_limit.I_rms = struct('min', 0.0, 'max', 1e9);

fom_limit.c_box = struct('min', 0.0, 'max', 1e9);
fom_limit.m_box = struct('min', 0.0, 'max', 1e9);
fom_limit.V_box = struct('min', 0.0, 'max', 1e9);

thermal.T_init = 80;
thermal.T_ambient = 80;

%% assign
data_vec.winding_id = 71;
data_vec.core_id = 71;
data_vec.iso_id = 71;

data_vec.n_turn = n_turn;
data_vec.I_test = I_test;
data_vec.geom = geom;
data_vec.fom_data = fom_data;
data_vec.fom_limit = fom_limit;
data_vec.losses_add = losses_add;
data_vec.thermal = thermal;

end

function ann_fem_obj = get_ann_fem()

data = load('data\fem_ann\export.mat');

geom_type = 'abs';
eval_type = 'ann';

ann_fem_obj = AnnFem(const, ann_mf, ann_ht, geom_type, eval_type);

end

function data_const = get_data_const()

%% iter
data_const.iter.n_iter = 15;
data_const.iter.tol_losses = 5.0;
data_const.iter.tol_thermal = 2.0;
data_const.iter.relax_losses = 1.0;
data_const.iter.relax_thermal = 1.0;

data_const.excitation.waveform_type = 'sin';
data_const.excitation.excitation_type = 'voltage';

end

function data_material = get_material()

%% core
data_tmp = load('data\material\core_data.mat');
data_material.core = data_tmp.data;

%% winding
data_tmp = load('data\material\winding_data.mat');
data_material.winding = data_tmp.data;

%% iso
data_tmp = load('data\material\iso_data.mat');
data_material.iso = data_tmp.data;

end