function [sweep, n_split, fct, data_ann, data_compute] = get_design_data_compute(sweep_mode)

% sweep
sweep = get_sweep(sweep_mode);

% n_split
n_split = 100e3;

% filter
fct.fct_filter_compute = @(fom, n_sol) fom.is_valid;
fct.fct_filter_save = @(fom, operating, n_sol) operating.half_load.is_valid&operating.full_load.is_valid;

% data_ann
data_ann.geom_type = 'rel';
data_ann.eval_type = 'ann';

% data_compute
data_compute.data_const = get_data_const();
data_compute.fct_data_vec = @(var) get_data(var);
data_compute.fct_excitation = @(var, fom) get_excitation(var, fom);

end

function sweep = get_sweep(sweep_mode)

switch sweep_mode
    case 'extrema'
        % regular grid sweep (all combinations)
        sweep.type = 'all_combinations';
        
        % maximum sumber of resulting sample
        sweep.n_sol_max = 10e6;
        
        % two samples per variables (extreme case)
        n = 8;
        
        % samples generation: linear
        span = 'linear';
    case 'random'
        % regular vector sweep (specified combinations)
        sweep.type = 'specified_combinations';
        
        % maximum sumber of resulting sample
        sweep.n_sol_max = 10e6;
        
        % samples per variables
        n = 1e6;
        
        % samples generation: linear
        span = 'random';
    otherwise
        error('invalid sweep_type')
end

sweep.var.fact_window = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 2.0, 'ub', 4.0, 'n', n);
sweep.var.fact_core = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 1.0,  'ub', 3.0, 'n', n);
sweep.var.fact_core_window = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.3,  'ub', 3.0, 'n', n);
sweep.var.fact_gap = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.01,  'ub', 0.2, 'n', n);
sweep.var.V_box = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 20e-6,  'ub', 200e-6, 'n', n);
sweep.var.f = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 50e3,  'ub', 500e3, 'n', n);
sweep.var.n_turn = struct('type', 'span', 'var_trf', 'log', 'var_type', 'int', 'span', span, 'lb', 2, 'ub', 75, 'n', n);

end

function excitation = get_excitation(var, fom)

excitation_tmp.T_ambient = 40.0;
excitation_tmp.is_pwm = true;
excitation_tmp.d_c = 0.5;
excitation_tmp.f = var.f;
excitation_tmp.I_ac_peak = 200./(4.*var.f.*fom.circuit.L);

excitation_tmp.I_dc = 10.0;
excitation.full_load = excitation_tmp;

excitation_tmp.I_dc = 5.0;
excitation.half_load = excitation_tmp;

end

function data_vec = get_data(var)

% geom
geom.fact_window = var.fact_window;
geom.fact_core = var.fact_core;
geom.fact_core_window = var.fact_core_window;
geom.fact_gap = var.fact_gap;
geom.V_box = var.V_box;
geom.n_turn = var.n_turn;

% other
other.I_test = 10.0;
other.T_init = 80.0;

%% fom_data
fom_data.m_scale = 1.0;
fom_data.m_offset = 0.0;
fom_data.V_scale = 1.0;
fom_data.V_offset = 0.0;
fom_data.c_scale = 1.0;
fom_data.c_offset = 0.0;
fom_data.P_scale = 1.0;
fom_data.P_offset = 0.0;

%% fom_limit
fom_limit.L = struct('min', 0, 'max', Inf);
fom_limit.V_t_area = struct('min', 0, 'max', Inf);
fom_limit.I_sat = struct('min', 0.0, 'max', Inf);
fom_limit.I_rms = struct('min', 0.0, 'max', Inf);

fom_limit.stress = struct('I_dc', 10.0, 'V_t_area', 200./(2.*var.f), 'fact_rms', 1./sqrt(3));
fom_limit.I_rms_tot = struct('min', 0.0, 'max', Inf);
fom_limit.I_peak_tot = struct('min', 0.0, 'max', Inf);
fom_limit.r_peak_peak = struct('min', 0.0, 'max', 0.3);
fom_limit.fact_sat = struct('min', 0.0, 'max', 0.9);
fom_limit.fact_rms = struct('min', 0.0, 'max', 0.9);

fom_limit.c_tot = struct('min', 0.0, 'max', 20.0);
fom_limit.m_tot = struct('min', 0.0, 'max', 800e-3);
fom_limit.V_box = struct('min', 0.0, 'max', 200e-6);

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
data_const.iter.losses.tol_abs = 0.5;
data_const.iter.losses.tol_rel = 0.05;
data_const.iter.losses.relax = 1.0;
data_const.iter.thermal.tol_abs = 2.0;
data_const.iter.thermal.tol_rel = 0.05;
data_const.iter.thermal.relax = 1.0;

data_const.material_core = load('source_data\material\core_data.mat');
data_const.material_winding = load('source_data\material\winding_data.mat');
data_const.material_iso = load('source_data\material\iso_data.mat');

end