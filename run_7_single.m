function run_7_single()
% Compute and plot a single inductor design.
%
%    Load the ANN/regression obtained with the FEM/ANN workflow.
%    Compute the specified design.
%    Show the design with a GUI.
%    
%    Use the ANN/regression are used for predicting:
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

% path of the file containing the exported data from the FEM/ANN
file_export = 'data/export.mat';

% path of the file to be written with the computed single design
file_single = 'data/single.mat';

% get the design parameters for the inductor
[eval_ann, data_compute] = get_design_data_single();

% compute and plot the inductor design
master_single(file_single, file_export, eval_ann, data_compute)

end
