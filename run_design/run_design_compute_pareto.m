function run_design_compute_pareto()
% Compute many inductor inductor designs (properties, thermal, losses, etc.).
%
%    Load the ANN/regression obtained with the FEM/ANN workflow.
%    Sweep different inductor designs.
%    Compute the inductor properties, thermal, losses, etc.
%
%    Use the ANN/regression are used for predicting:
%        - the thermal model (hotspot and average temperatures)
%        - the magnetic model (inductance, current density, flux density, and magnetic field)
%
%    The complete code is running:
%        - parallel: on different MATLAB workers
%        - vectorized: many designs at the same time
%
%    Warning: The code use functions that are internally (multithreaded).
%             Therefore, the speedup achieved with parallel MATLAB workers can be very low.
%
%    This function requires a running ANN Python Server (if this regression method is used).
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% get the type of regression to be done
fprintf('Select the simulation type:\n')
fprintf('    1 - ANN-based model\n')
fprintf('    2 - Analytical approximation\n')
idx = input('Enter your choice >> ');

% parse the user choice
choice_cell = {'ann', 'approx'};
choice = get_choice(choice_cell, idx);

% run the regression
if isempty(choice)
    fprintf('Invalid input\n')
else
    fprintf('\n')
    run_sub(choice)
    plot_sub(choice)
end

end

function run_sub(eval_type)
% Compute many inductor inductor designs (with different evaluation methods).
%
%    Parameters:
%        eval_type (str): type of the evaluation ('ann', or approx')

% path of the file containing the exported data from the FEM/ANN
file_export = 'dataset/export.mat';

% path of the file to be written with the computed designs
file_compute_pareto = ['design/compute_pareto_' eval_type '.mat'];

% get the design parameters for the inductors
[sweep, n_split, fct, eval_ann, data_compute] = get_design_param_compute_pareto(eval_type);

% compute the inductor designs
master_compute_pareto(file_compute_pareto, file_export, sweep, n_split, fct, eval_ann, data_compute)

end

function plot_sub(eval_type)
% Display inductors design in a GUI (with different evaluation methods).
%
%    Parameters:
%        eval_type (str): type of the evaluation ('ann', or approx')

% path of the file contained the computed designs
file_compute_pareto = ['design/compute_pareto_' eval_type '.mat'];

% get the GUI parameters
[fct_data, plot_param, text_param] = get_design_param_plot_pareto();

% start the GUI
master_plot_pareto(file_compute_pareto, fct_data, plot_param, text_param)

end
