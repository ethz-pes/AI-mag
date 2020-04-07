function run_5_compute()

init_toolbox();

%% file
file_export = 'data/export.mat';
file_compute = 'data/compute.mat';

%% data
[sweep, n_split, fct, data_ann, data_compute] = get_design_data_compute('random');

%% save
master_compute(file_compute, file_export, sweep, n_split, fct, data_ann, data_compute)

end
