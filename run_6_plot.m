function run_6_plot()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
file_compute = 'data/compute.mat';

%% data
[fct_data, plot_param] = get_design_data_plot();

%% save
master_plot(file_compute, fct_data, plot_param)

end
