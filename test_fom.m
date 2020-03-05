function test_fom()

data_tmp_mf = load('data\mf_ann.mat');
data_tmp_ht = load('data\ht_ann.mat');

obj_mf = AnnFemMf(data_tmp_mf);
obj_ht = AnnFemHt(data_tmp_ht);

sweep = get_data_sweep('geom', 'random', 1);
[n_sol, geom_rel] = get_sweep(sweep);

[is_valid, fom] = obj_mf.run(n_sol, geom_rel, 'rel');

P_winding = 1.5.*ones(1, n_sol);
P_core = 1.2.*ones(1, n_sol);

[is_valid, fom] = obj_ht.run(n_sol, geom_rel, 'rel', P_winding, P_core);

n_sol = 1;
geom_abs.z_core = 20e-3;
geom_abs.t_core = 20e-3;
geom_abs.x_window = 20e-3;
geom_abs.y_window = 30e-3;
geom_abs.d_gap = 1e-3;

geom_rel = obj_ht.run(n_sol, geom_abs, 'abs', P_winding, P_core);


end