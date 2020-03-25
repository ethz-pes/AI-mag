function master_plot(file_compute, fct_data, plot_data)

% name
fprintf('################## master_plot\n')

% load
fprintf('load\n')
data_compute = load(file_compute);
id_design = data_compute.id_design;
fom = data_compute.fom;
operating = data_compute.operating;

fprintf('init\n')
inductor_pareto_obj = design.InductorPareto(id_design, fom, operating, fct_data, plot_data);

fprintf('plot\n')

inductor_pareto_obj.get_gui();

fprintf('################## master_plot\n')

end