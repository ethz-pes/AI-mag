function run_8_plot_single()
% Plot a single inductor design in a GUI.
%
%    Start a GUI with the design.
%    Show the geometry.
%    Show the figures of merit.
%    Show the operating points.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% run model with ANN/regression
run_sub('ann')

% run model with analytical approximation
run_sub('approx')

% run model with FEM simulation
run_sub('fem')

end

function run_sub(eval_type)
% Run the FEM % Compute and plot a single inductor design (with different evaluation methods).
%
%    Parameters:
%        eval_type (str): type of the evaluation ('fem', 'ann', or approx')

% path of the file to be written with the computed single design
file_single = ['data/compute_single_' eval_type '.mat'];

% compute and plot the inductor design
master_plot_single(file_single)

end
