function run_iso()
% Generate the insulation material data.
%
%    Map the different materials with a unique id.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% unique id
id_vec = [1 2];

% parse data
data = {};
for i=1:length(id_vec)
   material = get_data(id_vec(i));
   data{end+1} = struct('id', id_vec(i), 'material', material);
end

% material type
type = 'iso';

% save material
save('data/iso_data.mat', 'data', 'type')

end

function material = get_data(id)
% Generate the insulation material data.
%
%    Parameters:
%        id (int): material id
%
%    Returns:
%        material (struct): material data

% get values
switch id
    case 1
        rho = 1500;
        kappa = 0.5;
    case 2
        rho = 1600;
        kappa = 0.4;
    otherwise
        error('invalid id')
end

% assign
material.rho = rho; % volumetric density
material.kappa = kappa; % cost per mass
material.T_max = 130.0; % maximum temperature
material.c_offset = 0.3; % cost offset

end