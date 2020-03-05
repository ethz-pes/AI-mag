function get_fom()

data_tmp_mf = load('data\mf_ann.mat');
data_tmp_ht = load('data\ht_ann.mat');

obj = AnnFem(data_tmp_mf, data_tmp_ht);

% sweep = get_data_sweep('geom', 'random', 100);
% [n_sol, geom_rel] = get_sweep(sweep);
% 
% 
% 
% [is_valid, geom, fom] = obj.run_mf(n_sol, geom_rel);








end