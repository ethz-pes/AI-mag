function test_fom()

%% init
data_fem_ann = load('data\fem_ann\export.mat');

geom_type = 'abs';
eval_type = 'ann';

obj = AnnFem(data_fem_ann, geom_type, eval_type);

%% geom
geom.z_core = 25e-3;
geom.t_core = 20e-3;
geom.x_window = 15e-3;
geom.y_window = 45e-3;
geom.d_gap = 1e-3;

n_sol = 1;

obj.set_geom(n_sol, geom);

obj.get_geom();

I_winding = 1.0;
P_core = 1;
P_winding = 1;

obj.get_mf(I_winding);

obj.get_ht(P_winding, P_core);

end