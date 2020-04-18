function run_iso()
% Generate the insulation material data.
%
%    Map the different materials with a unique id.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
addpath(genpath('utils'))

% parse data
data = {};
data{end+1} = get_data('default');

% material type
type = 'iso';

% save material
save('data/iso_data.mat', '-v7.3', 'data', 'type')

end

function data = get_data(id)
% Generate the insulation material data.
%
%    Parameters:
%        id (str): material id
%
%    Returns:
%        data (struct): material id and data

% assign
material.rho = 1500; % volumetric density
material.kappa = 0.5; % cost per mass
material.T_max = 130.0; % maximum temperature
material.c_offset = 0.3; % cost offset

% assign
id = get_map_str_to_int(id);
data = struct('id', id, 'material', material);

end