function get_inductor

addpath(genpath('source_code'))
addpath(genpath('source_data'))
close all;

n_sol = 3;

ann_fem_obj = get_ann_fem();

data_vec = get_data();
data_const = get_data_const();

obj = InductorDesign(n_sol, data_vec, data_const, ann_fem_obj);
[is_valid, fom] = obj.get_fom();

excitation = get_excitation();
operating = obj.get_operating(excitation);

end

function excitation = get_excitation()

excitation.T_ambient = [40.0 40.0 400.0];
excitation.T_ambient = 40.0;
excitation.I_dc = 10.0;
excitation.f = 500e3;

excitation.I_ac_peak = 8.0;
excitation.d_c = 0.4;

end

function  data_vec = get_data()

geom.z_core = 25e-3;
geom.t_core = 20e-3;
geom.x_window = 15e-3;
geom.y_window = 45e-3;
geom.d_gap = [1e-3 1e-3 50e-3];
geom.n_turn = 6;

other.I_test = 60;
other.T_init = 80;

%% fom_data
fom_data.m_scale = 1.0;
fom_data.m_offset = 0.0;
fom_data.V_scale = 1.0;
fom_data.V_offset = 0.0;
fom_data.c_scale = 1.0;
fom_data.c_offset = 0.0;
fom_data.P_fraction = 0.0;
fom_data.P_offset = 0.0;

%% fom_limit
fom_limit.L = struct('min', 0.0, 'max', 1e9);
fom_limit.I_sat = struct('min', 0.0, 'max', 1e9);
fom_limit.I_rms = struct('min', 0.0, 'max', 1e9);

fom_limit.c_box = struct('min', 0.0, 'max', 1e9);
fom_limit.m_box = struct('min', 0.0, 'max', 1e9);
fom_limit.V_box = struct('min', 0.0, 'max', 1e9);

%% material
material.winding_id = 71;
material.core_id = 95;
material.iso_id = 1;

%% assign
data_vec.other = other;
data_vec.material = material;
data_vec.geom = geom;
data_vec.fom_data = fom_data;
data_vec.fom_limit = fom_limit;

end

function ann_fem_obj = get_ann_fem()

data_fem_ann = load('data\fem_ann\export.mat');

geom_type = 'abs';
eval_type = 'ann';

ann_fem_obj = AnnFem(data_fem_ann, geom_type, eval_type);

end

function data_const = get_data_const()

%% iter
data_const.iter.n_iter = 15;
data_const.iter.tol_losses = 5.0;
data_const.iter.tol_thermal = 2.0;
data_const.iter.relax_losses = 1.0;
data_const.iter.relax_thermal = 1.0;

data_const.waveform_type = 'sin';

data_const.material_core = load('source_data\material\core_data.mat');
data_const.material_winding = load('source_data\material\winding_data.mat');
data_const.material_iso = load('source_data\material\iso_data.mat');

end