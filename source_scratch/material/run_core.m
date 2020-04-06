function run_core()
% Generate the core (ferrite) material data.
%
%    Map the different materials with a unique id.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
addpath(genpath('utils'))
close('all');

% data
id = [97 87 49 95]; % unique id
rho = [4850 4850 4750 4900]; % volumetric density
kappa = [7.5 7.0 12.5 9.5]; % cost per mass

% parse data
data = {};
for i=1:length(id)
    % get the data
   material = get_data(rho(i), kappa(i));
   
   % load the loss map for (frequency, AC flux density, and temperature, from TDK-EPCOS)
   data_ac = load(['data/N' num2str(id(i)) '_map.txt']);
   
   % get the DC bias data (measured for N87, from PES ETHZ)
   data_dc = load('data/dc_bias.mat');
   
   % parse and extrapolate the AC loss data
   [tol, add_pts] = get_extrapolate();
   data_ac = extract_map_ac(data_ac,tol, add_pts);
      
   % combine all the data together
   material = extract_map_ac_dc(data_ac, data_dc, material);
   data{end+1} = struct('id', id(i), 'material', material);
end

% material type
type = 'core';

% save material
save('data/core_data.mat', 'data', 'type')

end

function material = get_data(rho, kappa)
% Generate the core (ferrite) material data.
%
%    Parameters:
%        rho (float): volumetric density
%        kappa (float): cost per mass
%
%    Returns:
%        material (struct): material data

% loss interpolation
material.interp.f_vec = logspace(log10(25e3), log10(1e6), 20);  % frequency vector
material.interp.B_ac_peak_vec = logspace(log10(2.5e-3), log10(250e-3), 20); % AC flux density vector
material.interp.B_dc_vec = 0e-3:10e-3:250e-3; % DC flux density vector
material.interp.T_vec = 20:10:140;  % temperature vector

% assign param
material.param.rho = rho; % volumetric density
material.param.lambda = rho.*kappa; % cost per volume

% assign constant
material.param.fact_igse = 0.1; % factor for computing alpha and beta for IGSE (gradient in log scale)
material.param.B_sat_max = 300e-3; % saturation flux density
material.param.P_max = 1000e3; % maximum loss density
material.param.P_scale = 1.3; % scaling factor for losses
material.param.T_max = 130.0; % maximum temperature
material.param.c_offset = 0.3; % cost offset

end

function [tol, add_pts] = get_extrapolate()
% Generate the loss points to be extrapolated.
%
%    Parameters:
%        rho (float): volumetric density
%        kappa (float): cost per mass
%
%    Returns:
%        tol (float): duplicated points tolerance
%        add_pts (cell): points to extrapolate

% tolerance for considering points as duplicates
tol = 1e-6;

% add frequency and AC flux density points to make a complete grid:
%    - B_ac_peak and f: point to be added
%    - B_ac_peak_other and f_other: point to used for the exterpolation
%    - the following points are used to extrapolate:
%        - f_other and B_ac_peak
%        - f and B_ac_peak_other
%        - f_other and B_ac_peak_other
add_pts = {};
add_pts{end+1} = struct('B_ac_peak', 13e-3, 'f', 300e3, 'f_other', 500e3, 'B_ac_peak_other', 25e-3);
add_pts{end+1} = struct('B_ac_peak', 13e-3, 'f', 200e3, 'f_other', 300e3, 'B_ac_peak_other', 25e-3);
add_pts{end+1} = struct('B_ac_peak', 13e-3, 'f', 100e3, 'f_other', 200e3, 'B_ac_peak_other', 25e-3);
add_pts{end+1} = struct('B_ac_peak', 25e-3, 'f', 50e3, 'f_other', 100e3, 'B_ac_peak_other', 50e-3);
add_pts{end+1} = struct('B_ac_peak', 25e-3, 'f', 25e3, 'f_other', 50e3, 'B_ac_peak_other', 50e-3);
add_pts{end+1} = struct('B_ac_peak', 13e-3, 'f', 50e3, 'f_other', 100e3, 'B_ac_peak_other', 25e-3);
add_pts{end+1} = struct('B_ac_peak', 13e-3, 'f', 25e3, 'f_other', 50e3, 'B_ac_peak_other', 25e-3);
add_pts{end+1} = struct('B_ac_peak', 300e-3, 'f', 100e3, 'f_other', 50e3, 'B_ac_peak_other', 200e-3);
add_pts{end+1} = struct('B_ac_peak', 200e-3, 'f', 500e3, 'f_other', 300e3, 'B_ac_peak_other', 100e-3);
add_pts{end+1} = struct('B_ac_peak', 300e-3, 'f', 200e3, 'f_other', 100e3, 'B_ac_peak_other', 200e-3);
add_pts{end+1} = struct('B_ac_peak', 300e-3, 'f', 300e3, 'f_other', 200e3, 'B_ac_peak_other', 200e-3);
add_pts{end+1} = struct('B_ac_peak', 300e-3, 'f', 500e3, 'f_other', 300e3, 'B_ac_peak_other', 200e-3);
add_pts{end+1} = struct('B_ac_peak', 200e-3, 'f', 700e3, 'f_other', 500e3, 'B_ac_peak_other', 100e-3);
add_pts{end+1} = struct('B_ac_peak', 300e-3, 'f', 700e3, 'f_other', 500e3, 'B_ac_peak_other', 200e-3);
add_pts{end+1} = struct('B_ac_peak', 200e-3, 'f', 1000e3, 'f_other', 700e3, 'B_ac_peak_other', 100e-3);
add_pts{end+1} = struct('B_ac_peak', 300e-3, 'f', 1000e3, 'f_other', 700e3, 'B_ac_peak_other', 200e-3);

end