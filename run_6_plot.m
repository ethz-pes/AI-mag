function run_6_plot()
% Display inductors design in a GUI.
%
%    Start a GUI with several Pareto fronts.
%    Plots can be customized.
%    Design can be selected with the mouse.
%    Allow a multi-objective data exploration.
%    Details on a specific design (geometry, operating points, etc.).
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% path of the file contained the computed designs
file_compute = 'data/compute.mat';

% get the GUI parameters
[fct_data, plot_param, text_param] = get_design_data_plot();

% start the GUI
master_plot(file_compute, fct_data, plot_param, text_param)

end
