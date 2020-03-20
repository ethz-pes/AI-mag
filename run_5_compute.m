function run_5_compute()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
file_export = 'data/export.mat';
file_compute = 'data/compute.mat';

%% data
[sweep, n_split, data_ann, data_compute] = get_design_data_compute('random', 10e3);

%% save
master_compute(file_compute, file_export, sweep, n_split, data_ann, data_compute)

end