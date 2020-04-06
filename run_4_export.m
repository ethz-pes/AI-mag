function run_4_export()
% Assemble the constant data, the magnetic regression, and the thermal regression.
%
%    Assemble the following datasets:
%        - The constant data
%        - The dataset from the thermal simulations and the corresponding regression
%        - The dataset from the magnetic simulations and the corresponding regression
%
%    The resulting data contains all the information for evaluating inductor designs with the ANN/regression.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% path of the file containing the constant data
file_init = 'data/init.mat';

% path of the file containing the thermal ANN/regression data
file_ann_ht = 'data/ht_ann.mat';

% path of the file containing the magnetic ANN/regression data
file_ann_mf = 'data/mf_ann.mat';

% path of the file to be written with the assembled data
file_export = 'data/export.mat';

% load the data
ann_ht = load(file_ann_ht);
ann_mf = load(file_ann_mf);
const = load(file_init);

% save the data
save(file_export, 'const', 'ann_ht', 'ann_mf')

end
