function master_plot_single(file_compute_single)
% Plot a single inductor design in a GUI.
%
%    Start a GUI with the design.
%    Show the geometry.
%    Show the figures of merit.
%    Show the operating points.
%
%    Parameters:
%        file_compute_single (str): path of the file to be written with the computed single design
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_plot_single\n')

% load the FEM/ANN data
fprintf('load\n')
data_tmp = load(file_compute_single);
fom = data_tmp.fom;
operating = data_tmp.operating;

% gui
fprintf('gui\n')
plot_design(fom, operating)

fprintf('################## master_plot_single\n')

end

function plot_design(fom, operating)
% Display the computed design with a GUI.
%
%    Parameters:
%        fom (struct): computed figures of merit
%        operating (struct): computed operating points

% single design is required
id_design = 1;

% create GUI object
inductor_gui = design_display.InductorGui(id_design, fom, operating);

% set design
inductor_gui.set_id_select(id_design)

% launch gui
inductor_gui.open_gui()

end
