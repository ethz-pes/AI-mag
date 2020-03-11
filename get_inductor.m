function get_inductor

addpath('tmp')

n_sol = 1;

data = get_data();
ann_fem_obj = get_ann_fem();

obj = inductor(n_sol, data, ann_fem_obj);


end

function  data = get_data()

geom.z_core = 25e-3;
geom.t_core = 20e-3;
geom.x_window = 15e-3;
geom.y_window = 45e-3;
geom.d_gap = 1e-3;

n_turn = 6;

%% winding
winding = get_fct_transformer_winding(71);

%% core
core = get_fct_transformer_core(95);

%% iso
iso.rho = 1500.0;
iso.lambda = 1500.0.*5;
iso.T_max = 130.0;
iso.T_init = 130.0;

%% fom_data
fom_data.m_scale = 1.0;
fom_data.m_offset = 0.0;
fom_data.V_scale = 1.0;
fom_data.V_offset = 0.0;
fom_data.cost_scale = 1.0;
fom_data.cost_offset = 0.0;

%% losses
losses_add.P_fraction = 1.0;
losses_add.P_offset = 0.0;

%% fom_limit
fom_limit.L = struct('min', 0.0, 'max', 1e9);
fom_limit.I_peak = struct('min', 0.0, 'max', 1e9);
fom_limit.I_rms = struct('min', 0.0, 'max', 1e9);
fom_limit.cost = struct('min', 0.0, 'max', 1e9);
fom_limit.m = struct('min', 0.0, 'max', 1e9);
fom_limit.V = struct('min', 0.0, 'max', 1e9);

%% iter
iter.n_iter = 15;
iter.tol_losses = 5.0;
iter.tol_thermal = 2.0;
iter.relax_losses = 1.0;
iter.relax_thermal = 1.0;

%% assign
data.winding = winding;
data.iso = iso;
data.n_turn = n_turn;
data.core = core;
data.geom = geom;
data.fom_data = fom_data;
data.fom_limit = fom_limit;
data.losses_add = losses_add;
data.iter = iter;

end

function ann_fem_obj = get_ann_fem()

data_tmp = load('data\ht_ann.mat');
ann_ht = data_tmp;

data_tmp = load('data\mf_ann.mat');
ann_mf = data_tmp;

data_tmp = load('data\init.mat');
const = data_tmp.const;

geom_type = 'abs';
eval_type = 'ann';

ann_fem_obj = AnnFem(const, ann_mf, ann_ht, geom_type, eval_type);

end