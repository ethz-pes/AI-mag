function run_4_export()

init_toolbox();

%% file
file_init = 'data/init.mat';
file_ann_ht = 'data/ht_ann.mat';
file_ann_mf = 'data/mf_ann.mat';
file_export = 'data/export.mat';

%% run
ann_ht = load(file_ann_ht);
ann_mf = load(file_ann_mf);
const = load(file_init);

%% save
save(file_export, 'const', 'ann_ht', 'ann_mf')

end
