function [sweep, n_split, fct, eval_ann, data_compute] = get_design_data_compute_all(eval_type)
% Return the data required for the computation of inductor designs.
%
%    Define the variables and how to generate the samples.
%    How to evaluate the ANN/regression.
%    How to filter the invalid design.
%    Data required for the inductor evaluation.
%
%    Parameters:
%        eval_type (str): type of the evaluation ('ann', or approx')
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
sweep{1} = get_sweep('grid');
sweep{2} = get_sweep('random');

% number of vectorized designs per computation
n_split = 100e3;

% struct with custom functions for filtering invalid designs:
%    - fct_filter_var: filter the valid designs from the input variables (without the figures of merit)
%    - fct_filter_fom: filter the valid designs from the figures of merit (without the operating points)
%    - fct_filter_operating: filter the valid designs from the figure of merit and the operating points
fct.fct_filter_var = @(var, n_sol) fct_filter_var(var, n_sol);
fct.fct_filter_fom = @(var, fom, n_sol) fct_filter_fom(var, fom, n_sol);
fct.fct_filter_operating = @(var, fom, operating, n_sol) fct_filter_operating(var, fom, operating, n_sol);

% data for controlling the evaluation of the ANN/regression:
%    - geom_type: type of the geometry input variables
%        - 'rel': boxed volume, geometrical aspect ratio, and relative air gap length
%        - 'abs': absolute core, winding, and air gap length
%    - eval_type: type of the ANN/regression evaluation
%        - 'ann': get the result of the ANN/regression
%        - 'fem': get the FEM solution without the ANN/regression
%        - 'approx': get the analytical solution without the ANN/regression
eval_ann.geom_type = 'rel';
eval_ann.eval_type = eval_type;

% inductor data (data which are not only numeric and common for all the sample)
data_compute.data_const = get_design_data_const();

% function for getting the inductor data (struct of vectors with one value per sample)
data_compute.fct_data_vec = @(var, n_sol) get_data_vec(var, n_sol);

% function for getting the operating points data (struct containing the operating points)
data_compute.fct_excitation = @(var, fom, n_sol) get_excitation(var, fom, n_sol);

end

function sweep = get_sweep(sweep_mode)
% Data for generating the variable combinations with different methods.
%
%    Parameters:
%        sweep_mode (str): method for generating the variable combinations ('grid' or 'random')
%
%    Returns:
%        sweep (struct): data controlling the generation of the design combinations

% control the samples generation
switch sweep_mode
    case 'grid'
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
        error('invalid sweep method')
end

% struct with the description of a variable with a given fixed vector
%    - type: type of the variable ('fixed')
%    - vec: vector with the values
% struct with the description of a variable with random picks from a given discrete set
%    - type: type of the variable ('randset')
%    - set: values of the discrete set for the picks
%    - n: number of samples to be generated for the variable
% struct with the description of a variable with a regularly spaced span
%    - type: type of the variable ('span')
%    - var_trf: variable transformation applied to the variable
%        - none: no transformation
%        - rev: '1/x' transformation
%        - log: 'log10(x)' transformation
%        - exp: '10^x' transformation
%        - square: 'x^2' transformation
%        - sqrt: 'sqrt(2)' transformation
%    - var_type: variable type
%        - int: integer variable
%        - float: real variable
%    - span: generation method
%        - 'linear': linear span (after variable transformation)
%        - 'random': random span (after variable transformation)
%    - lb: variable lower bound
%    - ub: variable upper bound
%    - n: number of samples to be generated for the variable
sweep.var = struct();

% ratio between the height and width and the winding window
sweep.var.fact_window = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 2.0, 'ub', 4.0, 'n', n);

% ratio between the length and width of the core cross section
sweep.var.fact_core = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 1.0,  'ub', 3.0, 'n', n);

% ratio between the core cross section and the winding window cross section
sweep.var.fact_core_window = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.3,  'ub', 3.0, 'n', n);

% ratio between the air gap length and the square root of the core cross section
sweep.var.fact_gap = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.01,  'ub', 0.2, 'n', n);

% inductor box volume
sweep.var.V_box = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 10e-6,  'ub', 200e-6, 'n', n);

% inductor operating frequency
sweep.var.f = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 50e3,  'ub', 500e3, 'n', n);

% inductor number of turns
sweep.var.n_turn = struct('type', 'span', 'var_trf', 'log', 'var_type', 'int', 'span', span, 'lb', 2, 'ub', 75, 'n', n);

end

function data_vec = get_data_vec(var, n_sol)
% Function for getting the inductor data (struct of vectors with one value per sample).
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
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

% get the all the data (with the selected frequency)
data_vec = get_design_data_vec(geom, var.f);

end

function excitation = get_excitation(var, fom, n_sol)
% Function for getting the operating points data (struct of struct of vectors with one value per sample).
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        fom (struct): computed inductor figures of merit
%        n_sol (int): number of designs
%
%    Returns:
%        excitation (struct): struct containing the operating points (e.g., full load, partial load)

% check size
assert(isnumeric(n_sol), 'invalid number of samples')

% extract inductance
L = fom.circuit.L;

% extract the frequency
f = var.f;

% load conditions
load_full_load = 1.0;
load_partial_load = 0.5;

% data for full load operation
excitation.full_load = get_design_excitation(L, f, load_full_load);

% data for partial load operation
excitation.partial_load = get_design_excitation(L, f, load_partial_load);

end

function is_filter = fct_filter_var(var, n_sol)
% Filter the design to be kept after the generation of the variables combinations.
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        n_sol (int): number of provided designs
%
%    Returns:
%        is_filter (vector): vector of logical with the design to be kept

% check
assert(isstruct(var), 'invalid var data type')
assert(isnumeric(n_sol), 'invalid number of samples')

% filter
is_filter = true(1, n_sol);

end

function is_filter = fct_filter_fom(var, fom, n_sol)
% Filter the design to be kept after the computation of the figures of merit.
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        fom (struct): figures of merit of the designs
%        n_sol (int): number of provided designs
%
%    Returns:
%        is_filter (vector): vector of logical with the design to be kept

% check size
assert(isstruct(var), 'invalid var data type')
assert(isstruct(fom), 'invalid var data type')
assert(isnumeric(n_sol), 'invalid number of samples')

% select the designs
is_filter = fct_filter_var(var, n_sol);

% check the validity of the figures of merit
is_filter = is_filter&fom.is_valid;

% extract the properties
f = var.f;
L = fom.circuit.L;
I_sat = fom.circuit.I_sat;
I_rms = fom.circuit.I_rms;

% param
I_dc = 10.0;
V_pwm = 200.0;

% get the peak to peak current
I_peak_peak = V_pwm./(2.*f.*L);

% get the peak current (DC+AC)
I_peak_tot = I_dc+V_pwm./(4.*f.*L);

% get the RMS current (DC+AC)
I_rms_tot = hypot(I_dc, V_pwm./(sqrt(3).*4.*f.*L));

% select the designs
is_filter = is_filter&(I_peak_tot<=I_sat);
is_filter = is_filter&(I_rms_tot<=I_rms);
is_filter = is_filter&(I_peak_peak<=3.*I_dc);

end

function is_filter = fct_filter_operating(var, fom, operating, n_sol)
% Filter the design to be saved.
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        fom (struct): figures of merit of the designs
%        operating (struct): operating points of the designs
%        n_sol (int): number of provided designs
%
%    Returns:
%        is_filter (vector): vector of logical with the design to be saved

% check size
assert(isstruct(var), 'invalid var data type')
assert(isstruct(fom), 'invalid var data type')
assert(isstruct(operating), 'invalid var data type')
assert(isnumeric(n_sol), 'invalid number of samples')

% select the designs
is_filter = fct_filter_fom(var, fom, n_sol);

% check the validity of the operating points
is_filter = is_filter&operating.partial_load.is_valid;
is_filter = is_filter&operating.full_load.is_valid;

% filter the values
is_filter = is_filter&(operating.partial_load.losses.P_tot<=4.0);
is_filter = is_filter&(operating.full_load.losses.P_tot<=6.0);

end