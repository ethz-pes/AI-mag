function run_design_compute_single()
% Compute a single inductor design.
%
%    Load the ANN/regression obtained with the FEM/ANN workflow.
%    Compute the specified design.
%
%    Use the ANN/regression (or FEM or analytical approximation) is used for predicting:
%        - the thermal model (hotspot and average temperatures)
%        - the magnetic model (inductance, current density, flux density, and magnetic field)
%
%    This function requires a running ANN Python Server (if this regression method is used).
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% get the type of regression to be done
fprintf('Select the simulation type:\n')
fprintf('    1 - ANN-based model\n')
fprintf('    2 - Analytical approximation\n')
fprintf('    2 - FEM simulation (require COMSOL Livelink)\n')
idx = input('Enter your choice >> ');

% parse the user choice
choice_cell = {'ann', 'approx', 'fem'};
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
% Run the FEM % Compute and plot a single inductor design (with different evaluation methods).
%
%    Parameters:
%        eval_type (str): type of the evaluation ('fem', 'ann', or approx')

% path of the file containing the exported data from the FEM/ANN
file_export = 'dataset/export.mat';

% path of the file to be written with the computed single design
file_compute_single = ['design/compute_single_' eval_type '.mat'];

% get the design parameters for the inductor
[eval_ann, data_compute] = get_design_param_compute_single(eval_type);

% compute a single inductor design
master_compute_single(file_compute_single, file_export, eval_ann, data_compute)

end

function plot_sub(eval_type)
% Run the FEM % Compute and plot a single inductor design (with different evaluation methods).
%
%    Parameters:
%        eval_type (str): type of the evaluation ('fem', 'ann', or approx')

% path of the file to be written with the computed single design
file_compute_single = ['design/compute_single_' eval_type '.mat'];

% plot a single inductor design
master_plot_single(file_compute_single)

end
