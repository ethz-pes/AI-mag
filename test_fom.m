function test_fom()

%% init
data_tmp = load('data\ht_ann.mat');
ann_ht = data_tmp;

data_tmp = load('data\mf_ann.mat');
ann_mf = data_tmp;

data_tmp = load('data\init.mat');
const = data_tmp.const;

eval_type = 'ann';

obj = AnnFem(const, ann_mf, ann_ht, eval_type);

%% geom
geom.z_core = 25e-3;
geom.t_core = 20e-3;
geom.x_window = 15e-3;
geom.y_window = 45e-3;
geom.d_gap = 1e-3;

n_sol = 1;
geom_type = 'abs';

obj.set_geom(geom_type, n_sol, geom);

obj.get_geom();

I_winding = 1.0;
P_core = 1;
P_winding = 1;

obj.get_mf(I_winding);

obj.get_ht(P_winding, P_core);

end