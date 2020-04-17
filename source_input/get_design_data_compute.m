function [sweep, n_split, fct, eval_ann, data_compute] = get_design_data_compute()
% Return the data required for the computation of inductor designs.
%
%    Define the variables and how to generate the samples.
%    How to evaluate the ANN/regression.
%    How to filter the invalid design.
%    Data required for the inductor evaluation.
%
%    Returns:
%        sweep (cell): data controlling the generation of the design combinations
%        n_split (int): number of vectorized designs per computation
%        fct (struct): struct with custom functions for filtering invalid designs
%        eval_ann (struct): data for controlling the evaluation of the ANN/regression
%        data_compute (struct): data for the inductor designs
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% data controlling the generation of the design combinations
sweep{1} = get_sweep('extrema');
sweep{2} = get_sweep('random');

% number of vectorized designs per computation
n_split = 100e3;

% struct with custom functions for filtering invalid designs:
%    - fct_filter_compute: filter the valid designs from the figure of merit (without the operating points)
%    - fct_filter_save: filter the valid designs from the figure of merit and the operating points
fct.fct_filter_compute = @(fom, n_sol) fom.is_valid;
fct.fct_filter_save = @(fom, operating, n_sol) operating.half_load.is_valid&operating.full_load.is_valid;

% data for controlling the evaluation of the ANN/regression:
%    - geom_type: type of the geometry input variables
%        - 'rel': boxed volume, geometrical aspect ratio, and relative air gap length
%        - 'abs': absolute core, winding, and air gap length
%    - eval_type: type of the ANN/regression evaluation
%        - 'ann': get the result of the ANN/regression
%        - 'fem': get the FEM solution without the ANN/regression
%        - 'approx': get the analytical solution without the ANN/regression
eval_ann.geom_type = 'rel';
eval_ann.eval_type = 'ann';

% inductor data (data which are not only numeric and common for all the sample)
data_compute.data_const = get_data_const();

% function for getting the inductor data (struct of vectors with one value per sample)
data_compute.fct_data_vec = @(var, n_sol) get_data_vec(var, n_sol);

% function for getting the operating points data (struct containing the operating points)
data_compute.fct_excitation = @(var, fom, n_sol) get_excitation(var, fom, n_sol);

end

function sweep = get_sweep(sweep_mode)
% Data for generating the variable combinations with different methods.
%
%    Parameters:
%        sweep_mode (str): method for generating the variable combinations ('extrema' or 'random')
%
%    Returns:
%        sweep (struct): data controlling the generation of the design combinations

% control the samples generation
switch sweep_mode
    case 'extrema'
        % regular grid sweep (all combinations)
        sweep.type = 'all_combinations';
        
        % maximum sumber of resulting sample
        sweep.n_sol_max = 10e6;
        
        % two samples per variables (extreme case)
        n = 5;
        
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

% ratio between the height and width and the winding window
sweep.var.fact_window = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 2.0, 'ub', 4.0, 'n', n);

% ratio between the length and width of the core cross section
sweep.var.fact_core = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 1.0,  'ub', 3.0, 'n', n);

% ratio between the core cross section and the winding window cross section
sweep.var.fact_core_window = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.3,  'ub', 3.0, 'n', n);

% ratio between the air gap length and the square root of the core cross section
sweep.var.fact_gap = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.01,  'ub', 0.2, 'n', n);

% inductor box volume
sweep.var.V_box = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 20e-6,  'ub', 200e-6, 'n', n);

% inductor operating frequency
sweep.var.f = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 50e3,  'ub', 500e3, 'n', n);

% inductor number of turns
sweep.var.n_turn = struct('type', 'span', 'var_trf', 'log', 'var_type', 'int', 'span', span, 'lb', 2, 'ub', 75, 'n', n);

end

function data_vec = get_data_vec(var, n_sol)
% Function for getting the inductor data (struct of vectors with one value per sample)
%
%    Parameters:
%        var (struct): struct of vectors with the samples with all the combinations
%        n_sol (int): number of designs
%
%    Returns:
%        data_vec (struct:) struct of vectors with one value per sample

% check size
assert(isnumeric(n_sol), 'invalid number of samples')

% inductor geometry
%    - fact_window: ratio between the height and width and the winding window
%    - fact_core: ratio between the length and width of the core cross section
%    - fact_core_window: ratio between the core cross section and the winding window cross section
%    - fact_gap: ratio between the air gap length and the square root of the core cross section
%    - V_box: inductor box volume
%    - n_turn: inductor number of turns
%    - fill_pack: fill factor of the packing (not of the litz wire)
geom.fact_window = var.fact_window;
geom.fact_core = var.fact_core;
geom.fact_core_window = var.fact_core_window;
geom.fact_gap = var.fact_gap;
geom.V_box = var.V_box;
geom.n_turn = var.n_turn;
geom.fill_pack = 0.7;

% inductor physical parameters
%    - I_test: test current for computing the magnetic circuit
%    - T_init: initial guess for the component temperature
other.I_test = 10.0;
other.T_init = 80.0;

% inductor scaling factor for the figures of merit
%    - m_scale: scaling factor for the total mass
%    - m_offset: offset for the total mass
%    - V_scale: scaling factor for the box volume
%    - V_offset: offset for the box volume
%    - c_scale: scaling factor for the total cost
%    - c_offset: offset for the total cost
%    - P_scale: scaling factor for the total losses
%    - P_offset: offset for the total losses
fom_data.m_scale = 1.0;
fom_data.m_offset = 0.0;
fom_data.V_scale = 1.0;
fom_data.V_offset = 0.0;
fom_data.c_scale = 1.0;
fom_data.c_offset = 0.0;
fom_data.P_scale = 1.0;
fom_data.P_offset = 0.0;

% bounds for the geometry figures of merit
%    - c_tot: total cost
%    - m_tot: total mass
%    - V_box: box volume
fom_limit.c_tot = struct('min', 0.0, 'max', 20.0);
fom_limit.m_tot = struct('min', 0.0, 'max', 800e-3);
fom_limit.V_box = struct('min', 0.0, 'max', 200e-6);

% bounds for the circuit figures of merit
%    - L: inductance
%    - V_t_area: saturation voltage time product
%    - I_sat: maximum saturation current
%    - I_rms: maximum RMS current
fom_limit.L = struct('min', 0, 'max', Inf);
fom_limit.V_t_area = struct('min', 0, 'max', Inf);
fom_limit.I_sat = struct('min', 0.0, 'max', Inf);
fom_limit.I_rms = struct('min', 0.0, 'max', Inf);

% bounds for the inductor utilization
%    - stress: stress applied to the inductor for evaluating the utilization
%        - I_dc: applied DC current
%        - V_t_area: applied voltage time product
%        - fact_rms: factor between the peak current and the RMS current
%    - I_rms_tot: total RMS current (AC and DC)
%    - I_peak_tot: total peak current (AC and DC)
%    - r_peak_peak: peak to peak ripple
%    - fact_sat: total peak current with respect to the maximum saturation current
%    - fact_rms: total RMS current with respect to the maximum RMS current
fom_limit.stress = struct('I_dc', 10.0, 'V_t_area', 200./(2.*var.f), 'fact_rms', 1./sqrt(3));
fom_limit.I_rms_tot = struct('min', 0.0, 'max', Inf);
fom_limit.I_peak_tot = struct('min', 0.0, 'max', Inf);
fom_limit.r_peak_peak = struct('min', 0.0, 'max', 0.3);
fom_limit.fact_sat = struct('min', 0.0, 'max', 0.9);
fom_limit.fact_rms = struct('min', 0.0, 'max', 0.9);

% inductor geometry
%    - winding_id: id of the winding material
%    - core_id: id of the core material
%    - iso_id: id of the insulation material
material.winding_id = 71;
material.core_id = 95;
material.iso_id = 1;

% assign the data
data_vec.other = other;
data_vec.material = material;
data_vec.geom = geom;
data_vec.fom_data = fom_data;
data_vec.fom_limit = fom_limit;

end

function excitation = get_excitation(var, fom, n_sol)
% Function for getting the operating points data (struct of struct of vectors with one value per sample)
%
%    Parameters:
%        var (struct): struct of vectors with the samples with all the combinations
%        fom (struct): computed inductor figures of merit
%        n_sol (int): number of designs
%
%    Returns:
%        excitation (struct): struct containing the operating points (e.g., full load, half load)

% data for full load operation
excitation.full_load = get_excitation_load(var, fom, n_sol, 1.0);

% data for half load operation
excitation.half_load = get_excitation_load(var, fom, n_sol, 0.5);

end

function excitation = get_excitation_load(var, fom, n_sol, load)
% Function for getting the operating point for a specific load condition.
%
%    Parameters:
%        var (struct): struct of vectors with the samples with all the combinations
%        fom (struct): computed inductor figures of merit
%        n_sol (int): number of designs
%        load (float): operating point load (relative to full load)
%
%    Returns:
%        excitation (struct): struct containing the operating point

% check size and extract data
assert(isnumeric(n_sol), 'invalid number of samples')
L = fom.circuit.L;
f = var.f;

% excitation data
%    - T_ambient: ambient temperature
%    - is_pwm: is the waveform are sinus or PWM (triangular)
%    - d_c: duty cycle
%    - f: operating frequency
%    - I_dc: DC current
%    - I_ac_peak: AC peak current
excitation.T_ambient = 40.0;
excitation.is_pwm = true;
excitation.d_c = 0.5;
excitation.f = f;
excitation.I_dc = load.*10.0;
excitation.I_ac_peak = 200./(4.*f.*L);

end

function data_const = get_data_const()
% Get the inductor data which are common for all the sample (not only numeric, any data type).
%
%    Returns:
%        data_const (struct): inductor data common for all the sample

% data controlling the thermal/loss iteration:
%     - n_iter: maximum number of iterations
%     - losses.tol_abs: absolute tolerance on the losses
%     - losses.tol_rel: relative tolerance on the losses
%     - losses.relax: relaxation parameter for the losses
%     - thermal.tol_abs: absolute tolerance on the temperatures
%     - thermal.tol_rel: relative tolerance on the temperatures
%     - thermal.relax: relaxation parameter for the temperatures
data_const.iter.n_iter = 15;
data_const.iter.losses.tol_abs = 0.5;
data_const.iter.losses.tol_rel = 0.05;
data_const.iter.losses.relax = 1.0;
data_const.iter.thermal.tol_abs = 2.0;
data_const.iter.thermal.tol_rel = 0.05;
data_const.iter.thermal.relax = 1.0;

% data containing the material (core, winding, and insulation) data:
%    - each material has a unique id
%    - the material data is generated by 'resources/material'
data_const.material_core = load('source_input/material/core_data.mat');
data_const.material_winding = load('source_input/material/winding_data.mat');
data_const.material_iso = load('source_input/material/iso_data.mat');

end