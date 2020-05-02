function [file_model, timing, var_type, sweep] = get_fem_ann_data_fem(model_type, sweep_mode)
% Return the data required for the FEM simulations.
%
%    Define the variables and how to generate the samples.
%    Get the COMSOL file path and the type of the variables.
%
%    Parameters:
%        model_type (str): name of the physics to be solved ('mf' or 'ht')
%        sweep_mode (str): method for generating the variable combinations ('extrema' or 'random')
%
%    Returns:
%        file_model (str): path of the COMSOL file to be used for the simulations
%        timing (struct): struct controlling simulation time (for batching systems)
%        var_type (struct): type of the different variables used in the solver
%        sweep (struct): data controlling the samples generation
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check the input data
assert(any(strcmp(model_type, {'ht', 'mf'})), 'invalid model_type')

% struct controlling the COMSOL license and model loading (for batching systems)
%    - diff_trial: time between two COMSOL license trials
%    - n_trial: maximum number if COMSOL license trials
%    - n_reload: how often the COMSOL model is reloaded (trade-off between speed, license, and memory)
timing.diff_trial = duration('00:30', 'InputFormat', 'mm:ss');
timing.n_trial = 120;
timing.n_reload = 10;

% control the samples generation
switch sweep_mode
    case 'extrema'
        % regular grid sweep (all combinations)
        sweep.type = 'all_combinations';
        
        % maximum sumber of resulting sample
        sweep.n_sol_max = 10e3;
        
        % two samples per variables (extreme case)
        n = 2;
        
        % samples generation: linear
        span = 'linear';
    case 'random'
        % regular vector sweep (specified combinations)
        sweep.type = 'specified_combinations';
        
        % maximum sumber of resulting sample
        sweep.n_sol_max = 10e3;
        
        % samples per variables
        n = 6000;
        
        % samples generation: linear
        span = 'random';
    otherwise
        error('invalid sweep method')
end

% struct with the description of a fixed variable
%    - type: type of the variable ('fixed')
%    - vec: vector with the values
% struct with the description of a variable with generation of the samples
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
%    - n: number of samples for the variable
if any(strcmp(model_type, {'ht', 'mf'}))
    % ratio between the height and width and the winding window
    sweep.var.fact_window = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 2.0, 'ub', 4.0, 'n', n);
    
    % ratio between the length and width of the core cross section
    sweep.var.fact_core = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 1.0,  'ub', 3.0, 'n', n);
    
    % ratio between the core cross section and the winding window cross section
    sweep.var.fact_core_window = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.3,  'ub', 3.0, 'n', n);
    
    % ratio between the air gap length and the square root of the core cross section
    sweep.var.fact_gap = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.005,  'ub', 0.3, 'n', n);
    
    % inductor box volume
    sweep.var.V_box = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 10e-6,  'ub', 1000e-6, 'n', n);
end
if strcmp(model_type, 'mf')
    % current density in the winding for the magnetic FEM simulation
    sweep.var.J_winding = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.001e6,  'ub', 20e6, 'n', n);
    
    % permeability of the core for the FEM simulation
    sweep.var.mu_core = struct('type', 'span', 'var_trf', 'none', 'var_type', 'float', 'span', span, 'lb', 1500.0,  'ub', 3000.0, 'n', n);
    
    % beta (Steinmetz parameter) of the core for the FEM simulation
    sweep.var.beta_core = struct('type', 'span', 'var_trf', 'none', 'var_type', 'float', 'span', span, 'lb', 2.0,  'ub', 2.8, 'n', n);
end
if strcmp(model_type, 'ht')
    % total losses (core and winding) divided by the area of the boxed inductor
    sweep.var.p_density_tot = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.001e4,  'ub', 1e4, 'n', n);
    
    % ratio between the winding losses and core losses
    sweep.var.p_ratio_winding_core = struct('type', 'span', 'var_trf', 'log', 'var_type', 'float', 'span', span, 'lb', 0.02,  'ub', 50.0, 'n', n);
    
    % convection coefficient reference value
    sweep.var.h_convection = struct('type', 'span', 'var_trf', 'none', 'var_type', 'float', 'span', span, 'lb', 15.0,  'ub', 30.0, 'n', n);
end

% COMSOL model path
file_model = ['source_input/model/model_' model_type '.mph'];

% type of the different variables used in the solver
%    - geom_type: type of the geometry input variables
%        - 'rel': boxed volume, geometrical aspect ratio, and relative air gap length
%        - 'abs': absolute core, winding, and air gap length
%    - excitation_type: type of the excitation input variables
%        - 'rel': relative excitation (current density, losses per surface, etc.)
%        - 'abs': absolute excitation (current value, loss values, etc.)
var_type.geom_type = 'rel';
var_type.excitation_type = 'rel';

end