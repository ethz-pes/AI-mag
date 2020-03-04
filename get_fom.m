function get_fom()

data_tmp = load('data\mf_ann.mat');

obj = AnnFemMf(data_tmp);

sweep = get_data_sweep('mf', 'random', 100);
[n_sol, inp] = get_sweep(sweep);

[is_valid, geom, fom] = obj.run_rel_geom(n_sol, inp);

end