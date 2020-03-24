function master_plot(file_compute, fct_data, plot_data)

% name
fprintf('################## master_plot\n')

% load
fprintf('load\n')
data_compute = load(file_compute);
n_sol = data_compute.n_sol;
fom = data_compute.fom;
operating = data_compute.operating;

fprintf('init\n')
inductor_pareto_obj = design.InductorPareto(n_sol, fom, operating, fct_data, plot_data);

fprintf('plot\n')
inductor_pareto_obj.get_gui();

fprintf('################## master_plot\n')

end