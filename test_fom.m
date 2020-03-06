function test_fom()

data_tmp_ht = load('data\ht_ann.mat');

obj_ht = AnnFem(data_tmp_ht);

sweep = get_data_sweep('ht', 'random', 100);
[n_sol, inp] = get_sweep(sweep);


var_type.geom = 'rel';
var_type.excitation = 'rel';

% [is_valid, fom] = obj_ht.run(var_type, n_sol, inp);


n_sol = 1;
inp_abs.z_core = 25e-3;
inp_abs.t_core = 20e-3;
inp_abs.x_window = 15e-3;
inp_abs.y_window = 45e-3;
inp_abs.d_gap = 1e-3;
inp_abs.P_winding = 2.2;
inp_abs.P_core = 2.0;


var_type.geom = 'abs';
var_type.excitation = 'abs';
[is_valid, fom] = obj_ht.run_ann(var_type, n_sol, inp_abs);
[is_valid, fom] = obj_ht.run_approx(var_type, n_sol, inp_abs);

is_valid
fom

end