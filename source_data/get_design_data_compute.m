function [sweep, n_split, data_ann, data_compute] = get_design_data_compute(sweep_type, n)

% sweep
sweep = get_sweep(sweep_type, n);

% n_split
n_split = 50e3;

% data_ann
data_ann.geom_type = 'abs';
data_ann.eval_type = 'ann';

% data_compute
data_compute.data_vec = get_data();
data_compute.data_const = get_data_const();
data_compute.excitation = get_excitation();

end

function sweep = get_sweep(sweep_type, n)

sweep.type = sweep_type;
sweep.n_sol = n;
sweep.var.fact_window = struct('var_trf', 'log', 'type', 'float', 'lb', 2.0, 'ub', 4.0, 'n', n);
sweep.var.fact_core = struct('var_trf', 'log', 'type', 'float', 'lb', 1.0,  'ub', 3.0, 'n', n);
sweep.var.fact_core_window = struct('var_trf', 'log', 'type', 'float', 'lb', 0.3,  'ub', 3.0, 'n', n);
sweep.var.fact_gap = struct('var_trf', 'log', 'type', 'float', 'lb', 0.01,  'ub', 0.2, 'n', n);
sweep.var.V_box = struct('var_trf', 'log', 'type', 'float', 'lb', 0.01e-3,  'ub', 1e-3, 'n', n);
sweep.var.n_turn = struct('var_trf', 'log', 'type', 'int', 'lb', 3,  'ub', 50, 'n', n);

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

% geom
geom.z_core = 25e-3;
geom.t_core = 20e-3;
geom.x_window = 15e-3;
geom.y_window = 45e-3;
geom.d_gap = [1e-3 1e-3 50e-3];
geom.n_turn = 6;

% other
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