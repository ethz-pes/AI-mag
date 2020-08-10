function run_dataset_1_init()
% Store the constant data.
%
%    These data are constant (no part of the sweep combinations).
%    These data are used for both magnetic and thermal model.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% path of the file to be written with the constant data
file_init = 'dataset/init.mat';

% get the constant data
const = get_dataset_param_init();

% save the data
master_init(file_init, const);

end
