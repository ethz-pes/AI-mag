function master_plot(file_compute, fct_data, plot_param, fom_param)

% name
fprintf('################## master_plot\n')

% load
fprintf('load\n')
data_compute = load(file_compute);
id_design = data_compute.id_design;
fom = data_compute.fom;
operating = data_compute.operating;

fprintf('gui\n')
design_display.ParetoGui(id_design, fom, operating, fct_data, plot_param, fom_param);

fprintf('################## master_plot\n')

end