function run_extract_map()

close('all');
addpath(genpath('utils'))

%% map
tol = 1e-6;

%% pts
add.pts_grid = {};
add.pts_grid{end+1} = struct('B_peak', 13e-3, 'f', 300e3, 'f_other', 500e3, 'B_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 13e-3, 'f', 200e3, 'f_other', 300e3, 'B_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 13e-3, 'f', 100e3, 'f_other', 200e3, 'B_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 25e-3, 'f', 50e3, 'f_other', 100e3, 'B_peak_other', 50e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 25e-3, 'f', 25e3, 'f_other', 50e3, 'B_peak_other', 50e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 13e-3, 'f', 50e3, 'f_other', 100e3, 'B_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 13e-3, 'f', 25e3, 'f_other', 50e3, 'B_peak_other', 25e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 300e-3, 'f', 100e3, 'f_other', 50e3, 'B_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 200e-3, 'f', 500e3, 'f_other', 300e3, 'B_peak_other', 100e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 300e-3, 'f', 200e3, 'f_other', 100e3, 'B_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 300e-3, 'f', 300e3, 'f_other', 200e3, 'B_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 300e-3, 'f', 500e3, 'f_other', 300e3, 'B_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 200e-3, 'f', 700e3, 'f_other', 500e3, 'B_peak_other', 100e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 300e-3, 'f', 700e3, 'f_other', 500e3, 'B_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 200e-3, 'f', 1000e3, 'f_other', 700e3, 'B_peak_other', 100e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);
add.pts_grid{end+1} = struct('B_peak', 300e-3, 'f', 1000e3, 'f_other', 700e3, 'B_peak_other', 200e-3, 'fact', 1.0, 'T', [25 30 40 50 60 70 80 90 100 110 120]);

add.temperature = {};
add.temperature{end+1} = struct('B_peak', 13e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 25e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 50e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 100e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 200e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 300e-3, 'T', 20, 'T_other_1', 25, 'T_other_2', 30, 'fact', 1.0, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 13e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.2907, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 25e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.2907, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 50e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.3801, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 100e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.2555, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 200e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.1498, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);
add.temperature{end+1} = struct('B_peak', 300e-3, 'T', 140, 'T_other_1', 110, 'T_other_2', 120, 'fact', 1.1498, 'f', [25e3 50e3 100e3 200e3 300e3 500e3 700e3 1000e3]);

add.frequency = {};

extract_map('N97', tol, add);
extract_map('N87', tol, add);
extract_map('N95', tol, add);
extract_map('N49', tol, add);

end
