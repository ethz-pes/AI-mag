function run_5_compute()
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
%    This function requires a running ANN Python Server (if this regression method is used):
%        - run 'run_ann_server.py' with Python
%        - use 'start_python_ann_server.bat' on MS Windows
%        - use 'start_python_ann_server.sh' on Linux
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

init_toolbox();

% path of the file containing the exported data from the FEM/ANN
file_export = 'data/export.mat';

% path of the file to be written with the computed designs
file_compute = 'data/compute.mat';

% get the design parameters for the inductors
[sweep, n_split, fct, eval_ann, data_compute] = get_design_data_compute();

% compute the inductor designs
master_compute(file_compute, file_export, sweep, n_split, fct, eval_ann, data_compute)

end
