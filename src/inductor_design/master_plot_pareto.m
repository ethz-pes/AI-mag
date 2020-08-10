function master_plot_pareto(file_compute_all, fct_data, plot_param, text_param)
% Display many inductors design in a GUI.
%
%    Start a GUI with several Pareto fronts.
%    Plots can be customized.
%    Design can be selected with the mouse.
%    Allow a multi-objective data exploration.
%    Details on a specific design (geometry, operating points, etc.).
%
%    Parameters:
%        file_compute_all (str): path of the file contained the computed designs
%        fct_data (fct): function for getting the designs be plotted and getting the user defined custom figures of merit
%        plot_param (struct): definition of the different plots
%        text_param (struct): definition of variable to be shown in the text field
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_plot_pareto\n')

% load the designs
fprintf('load\n')
data_compute = load(file_compute_all);
id_design = data_compute.id_design;
fom = data_compute.fom;
operating = data_compute.operating;

% start the GUI
fprintf('gui\n')
design_display.ParetoGui(id_design, fom, operating, fct_data, plot_param, text_param);

% teardown
fprintf('################## master_plot_pareto\n')

end