function sweep = get_data_sweep(model_type, sweep_type)

switch sweep_type
    case 'matrix'
        sweep.type = 'matrix';
        sweep.n_sol_max = 20e3;
        if any(strcmp(model_type, {'ht', 'mf'}))
            sweep.var.fact_window = struct('var_trf', 'log', 'lb', 2.0, 'ub', 4.0, 'n', 2);
            sweep.var.fact_core = struct('var_trf', 'log', 'lb', 1.0,  'ub', 3.0, 'n', 2);
            sweep.var.fact_core_window = struct('var_trf', 'log', 'lb', 0.3,  'ub', 3.0, 'n', 2);
            sweep.var.fact_gap = struct('var_trf', 'log', 'lb', 0.01,  'ub', 0.2, 'n', 2);
            sweep.var.volume_target = struct('var_trf', 'log', 'lb', 0.01e-3,  'ub', 1.0e-3, 'n', 2);
        end
        if strcmp(model_type, 'ht')
            sweep.var.ht_stress = struct('var_trf', 'log', 'lb', 0.01e4,  'ub', 0.5e4, 'n', 2);
            sweep.var.ht_sharing = struct('var_trf', 'log', 'lb', 0.1,  'ub', 10.0, 'n', 2);
        end
    case 'random'
        sweep.type = 'random';
        sweep.n_sol = 20e3;
        if any(strcmp(model_type, {'ht', 'mf'}))
            sweep.var.fact_window = struct('var_trf', 'log', 'lb', 2.0, 'ub', 4.0);
            sweep.var.fact_core = struct('var_trf', 'log', 'lb', 1.0,  'ub', 3.0);
            sweep.var.fact_core_window = struct('var_trf', 'log', 'lb', 0.3,  'ub', 3.0);
            sweep.var.fact_gap = struct('var_trf', 'log', 'lb', 0.01,  'ub', 0.2);
            sweep.var.volume_target = struct('var_trf', 'log', 'lb', 0.01e-3,  'ub', 1.0e-3);
        end
        if strcmp(model_type, 'ht')
            sweep.var.ht_stress = struct('var_trf', 'log', 'lb', 0.02e4,  'ub', 0.2e4);
            sweep.var.ht_sharing = struct('var_trf', 'log', 'lb', 0.1,  'ub', 10.0);
        end
    otherwise
        error('invalid data')
end

end