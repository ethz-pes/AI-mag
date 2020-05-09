function run_6_compute_single()
% Compute a single inductor design.
%
%    Load the ANN/regression obtained with the FEM/ANN workflow.
%    Compute the specified design.
%
%    Use the ANN/regression (or FEM or analytical approximation) is used for predicting:
%        - the thermal model (hotspot and average temperatures)
%        - the magnetic model (inductance, current density, flux density, and magnetic field)
%
%    This function requires a running ANN Python Server (if this regression method is used):
%        - run 'run_ann_server.py' with Python
%        - use 'start_python_ann_server.bat' on MS Windows
%        - use 'start_python_ann_server.sh' on Linux
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

% path of the file containing the exported data from the FEM/ANN
file_export = 'data/export.mat';

% path of the file to be written with the computed single design
file_compute_single = ['data/compute_single_' eval_type '.mat'];

% get the design parameters for the inductor
[eval_ann, data_compute] = get_design_data_compute_single(eval_type);

% compute a single inductor design
master_compute_single(file_compute_single, file_export, eval_ann, data_compute)

end
