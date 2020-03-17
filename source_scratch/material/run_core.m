function run_core()

close('all');
addpath(genpath('utils'))

%% data
id = [97 87 49 95];
rho = [4850 4850 4750 4900];
kappa = [7.5 7.0 12.5 9.5];

%% parse
data = {};
for i=1:length(id)
   [tol, add, material] = get_data(rho(i), kappa(i));
   
   data_mat = load(['data/N' num2str(id(i)) '_map.txt']);
   data_map = extract_map(data_mat, tol, add);

   data_bias = load('data/dc_bias.mat');
   
   material = get_material(data_map, data_bias, material);

   data{end+1} = struct('id', id(i), 'material', material);
end

%% assign
type = 'core';

%% save
save('data/core_data.mat', 'data', 'type')

end

function [tol, add, material] = get_data(rho, kappa)

%% map
tol = 1e-6;

%% pts
add.pts_grid = {};
add.pts_grid{end+1} = struct('B_ac_peak', 13e-3, 'f', 300e3, 'f_other', 500e3, 'B_ac_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 13e-3, 'f', 200e3, 'f_other', 300e3, 'B_ac_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 13e-3, 'f', 100e3, 'f_other', 200e3, 'B_ac_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 25e-3, 'f', 50e3, 'f_other', 100e3, 'B_ac_peak_other', 50e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 25e-3, 'f', 25e3, 'f_other', 50e3, 'B_ac_peak_other', 50e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 13e-3, 'f', 50e3, 'f_other', 100e3, 'B_ac_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 13e-3, 'f', 25e3, 'f_other', 50e3, 'B_ac_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 300e-3, 'f', 100e3, 'f_other', 50e3, 'B_ac_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 200e-3, 'f', 500e3, 'f_other', 300e3, 'B_ac_peak_other', 100e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 300e-3, 'f', 200e3, 'f_other', 100e3, 'B_ac_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 300e-3, 'f', 300e3, 'f_other', 200e3, 'B_ac_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 300e-3, 'f', 500e3, 'f_other', 300e3, 'B_ac_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 200e-3, 'f', 700e3, 'f_other', 500e3, 'B_ac_peak_other', 100e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 300e-3, 'f', 700e3, 'f_other', 500e3, 'B_ac_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 200e-3, 'f', 1000e3, 'f_other', 700e3, 'B_ac_peak_other', 100e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_ac_peak', 300e-3, 'f', 1000e3, 'f_other', 700e3, 'B_ac_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);

add.temperature = {};
add.temperature{end+1} = struct('B_ac_peak', 13e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 25e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 50e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 100e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 200e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 300e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 13e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.2907, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 25e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.2907, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 50e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.3801, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 100e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.2555, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 200e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.1498, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_ac_peak', 300e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.1498, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);

add.frequency = {};

%% material
material.interp.f_vec = logspace(log10(25e3), log10(1e6), 20);
material.interp.B_ac_peak_vec = logspace(log10(2.5e-3), log10(250e-3), 20);
material.interp.B_dc_vec = 0e-3:10e-3:250e-3;
material.interp.T_vec = 20:10:140;

material.param.fact_igse = 0.1;
material.param.B_sat = 300e-3;
material.param.P_max = 1000e3;
material.param.P_scale = 1.3;
material.param.T_max = 130.0;
material.param.rho = rho;
material.param.lambda = rho.*kappa;

end
