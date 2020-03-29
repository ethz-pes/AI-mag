function [file_model, var_type, sweep] = get_fem_ann_data_fem(model_type, sweep_type, n)

assert(any(strcmp(model_type, {'ht', 'mf'})), 'invalid model_type')

% sweep
sweep.type = sweep_type;
sweep.n_sol = n;
if any(strcmp(model_type, {'ht', 'mf'}))
    sweep.var.fact_window = struct('var_trf', 'log', 'type', 'float', 'lb', 2.0, 'ub', 4.0, 'n', n);
    sweep.var.fact_core = struct('var_trf', 'log', 'type', 'float', 'lb', 1.0,  'ub', 3.0, 'n', n);
    sweep.var.fact_core_window = struct('var_trf', 'log', 'type', 'float', 'lb', 0.3,  'ub', 3.0, 'n', n);
    sweep.var.fact_gap = struct('var_trf', 'log', 'type', 'float', 'lb', 0.01,  'ub', 0.2, 'n', n);
    sweep.var.V_box = struct('var_trf', 'log', 'type', 'float', 'lb', 0.01e-3,  'ub', 1e-3, 'n', n);
end
if strcmp(model_type, 'mf')
    sweep.var.J_winding = struct('var_trf', 'log', 'type', 'float', 'lb', 0.01e6,  'ub', 20e6, 'n', n);
end
if strcmp(model_type, 'ht')
    sweep.var.p_density_tot = struct('var_trf', 'log', 'type', 'float', 'lb', 0.01e4,  'ub', 0.6e4, 'n', n);
    sweep.var.p_ratio_winding_core = struct('var_trf', 'log', 'type', 'float', 'lb', 0.05,  'ub', 20.0, 'n', n);
end

% file model
file_model = ['source_data/model/model_' model_type '.mph'];

% type
var_type.geom_type = 'rel';
var_type.excitation_type = 'rel';

end