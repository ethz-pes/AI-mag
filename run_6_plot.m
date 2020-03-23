function run_6_plot()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
file_compute = 'data/compute.mat';

%% data
[plot_param, fct_data, plot_data] = get_design_data_plot();

%% save
master_plot(file_compute, plot_param, fct_data, plot_data)

end
