function master_export(file_export, file_init, file_ann_ht, file_ann_mf)
% Store the constant data.
%
%    These data are constant (no part of the sweep combinations).
%    These data are used for both magnetic and thermal model.
%
%    Parameters:
%        file_export (str): path of the file to be written with the exported data
%        file_init (str): path of the file containing the constant data
%        file_ann_ht (str): path of the file containing the thermal ANN/regression data
%        file_ann_mf (str): path of the file containing the magnetic ANN/regression data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_export\n')

% load the ANN/regression data
fprintf('load\n')
ann_ht = load(file_ann_ht);
ann_mf = load(file_ann_mf);
const = load(file_init);

% save data
fprintf('save\n')
save(file_export, '-v7.3', 'const', 'ann_ht', 'ann_mf')

% teardown
fprintf('################## master_export\n')

end