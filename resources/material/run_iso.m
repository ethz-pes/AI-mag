function run_iso()
% Generate the insulation material data.
%
%    Map the different materials with a unique id.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% data
id = [1 2]; % unique id
rho = [1500 1600]; % volumetric density
kappa = [0.5 0.4]; % cost per mass

% parse data
data = {};
for i=1:length(id)
   material = get_data(rho(i), kappa(i));
   
   data{end+1} = struct('id', id(i), 'material', material);
end

% material type
type = 'iso';

% save material
save('data/iso_data.mat', 'data', 'type')

end

function material = get_data(rho, kappa)
% Generate the insulation material data.
%
%    Parameters:
%        rho (float): volumetric density
%        kappa (float): cost per mass
%
%    Returns:
%        material (struct): material data

material.rho = rho; % volumetric density
material.kappa = kappa; % cost per mass
material.T_max = 130.0; % maximum temperature
material.c_offset = 0.3; % cost offset

end