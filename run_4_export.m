function run_4_export()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
file_init = 'data/fem_ann/init.mat';
file_ann_ht = 'data/fem_ann/ht_ann.mat';
file_ann_mf = 'data/fem_ann/mf_ann.mat';
file_export = 'data/fem_ann/export.mat';

%% run
ann_ht = load(file_ann_ht);
ann_mf = load(file_ann_mf);
const = load(file_init);

%% save
save(file_export, 'const', 'ann_ht', 'ann_mf')

end
