function run_5_design()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
file_export = 'data/export.mat';
file_design = 'data/design.mat';

%% run
ann_ht = load(file_ann_ht);
ann_mf = load(file_ann_mf);
const = load(file_init);

%% save
save(file_export, 'const', 'ann_ht', 'ann_mf')

end
