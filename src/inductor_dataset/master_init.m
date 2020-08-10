function master_init(file_init, const)
% Store the constant data.
%
%    These data are constant (no part of the sweep combinations).
%    These data are used for both magnetic and thermal model.
%
%    Parameters:
%        file_init (str): path of the file to be written with the constant data
%        const (struct): constant data to be saved
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_init\n')

% create the folder for storing the data
fprintf('folder\n')
[s, m] = mkdir(fileparts(file_init));

% save data
fprintf('save\n')
save(file_init, '-v7.3', '-struct', 'const')

% teardown
fprintf('################## master_init\n')

end