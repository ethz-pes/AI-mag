function test_plot()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
load('data/compute.mat')

fom = get_struct_filter(fom, 25);
operating = get_struct_filter(operating, 25);

keyboard



%% data
[sweep, n_split, data_ann, data_compute] = get_design_data_compute('random', 10e3);

%% save
master_compute(file_compute, file_export, sweep, n_split, data_ann, data_compute)

end
