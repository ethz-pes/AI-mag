function run_winding()
% Generate the winding (litz wire) material data.
%
%    Map the different materials with a unique id.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% data
id = [50 71 100]; % unique id
fill = 0.7.*[0.47 0.49 0.51]; % fill factor
d_strand = [50e-6 71e-6 100e-6]; % strand diameter
d_skin_min = [50e-6 71e-6 100e-6]; % minimum skin depth
kappa_copper = [32.5 23.5 21.5]; % cost per mass for the copper

% parse data
data = {};
for i=1:length(id)
   material = get_data(fill(i), d_strand(i), d_skin_min(i), kappa_copper(i));
   
   data{end+1} = struct('id', id(i), 'material', material);
end

% material type
type = 'winding';

% save material
save('data/winding_data.mat', 'data', 'type')

end

function material = get_data(fill, d_strand, d_skin_min, kappa_copper)
% Generate the winding (litz wire) material data.
%
%    Parameters:
%        fill (float): fill factor
%        d_strand (float): strand diameter
%        d_skin_min (float): minimum skin depth
%        kappa_copper (float): cost per mass for the copper
%
%    Returns:
%        material (dict): material data

% conductivity interpolation
material.interp.T_vec = [20 46 72 98 124 150]; % temperature vector
material.interp.sigma_vec = 1e7.*[5.800 5.262 4.816 4.439 4.117 3.839]; % conductivity vector

% assign param
material.param.fill = fill; % fill factor
material.param.d_strand = d_strand; % strand diameter
material.param.delta_min = d_skin_min; % minimum skin depth

% assign density
rho_copper = 8960; % volumetric density for copper
rho_iso = 1500; % volumetric density for insulation
kappa_iso = 5.0; % cost per mass for the insulation
material.param.rho = rho_copper.*fill+rho_iso.*(1-fill); % volumetric density
material.param.lambda = rho_copper.*fill.*kappa_copper+rho_iso.*(1-fill).*kappa_iso; % cost per volume

% assign constant
material.param.n_harm = 10; % number of harmonics for PWM losses
material.param.P_max = 1000e3; % maximum loss density
material.param.J_rms_max = 15e6; % maximum rms current density
material.param.P_scale_lf = 1.3; % scaling factor for LF losses
material.param.P_scale_hf = 1.4; % scaling factor for HF losses
material.param.T_max = 140.0; % maximum temperature
material.param.c_offset = 0.3; % cost offset

end