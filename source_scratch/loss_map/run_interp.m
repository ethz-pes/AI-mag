function run_interp()

close('all');
addpath(genpath('utils'))

%% pts
f_vec = logspace(log10(25e3), log10(1e6), 20);
B_peak_vec = logspace(log10(2.5e-3), log10(250e-3), 20);
B_dc_vec = 0e-3:10e-3:250e-3;
T_vec = 20:10:140;

%% limit
B_sat = 300e-3;
P_max = 600e3;

%% obj
interp_map_bias('N97', 'N97', 'dc', f_vec, B_peak_vec, B_dc_vec, T_vec, B_sat, P_max);
interp_map_bias('N49', 'N49', 'dc', f_vec, B_peak_vec, B_dc_vec, T_vec, B_sat, P_max);
interp_map_bias('N95', 'N95', 'dc', f_vec, B_peak_vec, B_dc_vec, T_vec, B_sat, P_max);
interp_map_bias('N87', 'N87', 'dc', f_vec, B_peak_vec, B_dc_vec, T_vec, B_sat, P_max);

end