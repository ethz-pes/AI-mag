function master_plot(file_compute, plot_param, fct_data, plot_data)

% name
fprintf('################## master_plot\n')

% load
fprintf('load\n')
data_compute = load(file_compute);
n_sol = data_compute.n_sol;
fom = data_compute.fom;
operating = data_compute.operating;

fprintf('init\n')
inductor_pareto_obj = design.InductorPareto(n_sol, fom, operating, plot_param, fct_data);

% disp
fprintf('size\n')
fprintf('    n_sol = %d\n', inductor_pareto_obj.get_n_sol())
fprintf('    n_filter = %d\n', inductor_pareto_obj.get_n_plot())

fprintf('plot\n')
inductor_pareto_obj.get_plot(plot_data);

fprintf('################## master_plot\n')

end