function run_winding()

%% data
id = [50 71 100];
fill = 0.7.*[0.47 0.49 0.51];
d_strand = [50e-6 71e-6 100e-6];
d_skin_min = [50e-6 71e-6 100e-6];
kappa_copper = [32.5 23.5 21.5];

%% parse
data = {};
for i=1:length(id)
   material = get_data(fill(i), d_strand(i), d_skin_min(i), kappa_copper(i));
   
   data{end+1} = struct('id', id(i), 'material', material);
end

%% assign
type = 'winding';

%% save
save('data/winding_data.mat', 'data', 'type')

end

function material = get_data(fill, d_strand, d_skin_min, kappa_copper)

%% sigma
material.interp.T_vec = [20 46 72 98 124 150];
material.interp.sigma_vec = 1e7.*[5.800 5.262 4.816 4.439 4.117 3.839];

%% param
material.param.fill = fill;
material.param.d_strand = d_strand;
material.param.delta_min = d_skin_min;

%% fom
rho_copper = 8960;
rho_iso = 1500;
kappa_iso = 5.0;
material.param.rho = rho_copper.*fill+rho_iso.*(1-fill);
material.param.lambda = rho_copper.*fill.*kappa_copper+rho_iso.*(1-fill).*kappa_iso;

%% param
material.param.n_harm = 10;
material.param.P_max = 1000e3;
material.param.J_rms_max = 20e6;
material.param.P_scale_lf = 1.3;
material.param.P_scale_hf = 1.4;
material.param.T_max = 140.0;
material.param.c_offset = 0.3;

end