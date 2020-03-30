function run_6_plot()

init_toolbox();

%% file
file_compute = 'data/compute.mat';

%% data
[fct_data, plot_param, fom_param] = get_design_data_plot();

%% save
master_plot(file_compute, fct_data, plot_param, fom_param)

end
