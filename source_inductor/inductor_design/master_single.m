function master_single(file_single, file_export, eval_ann, data_compute)
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
%    Parameters:
%        file_single (str): path of the file to be written with the computed single design
%        file_export (str): path of the file containing the exported data from the FEM/ANN
%        eval_ann (struct): data for controlling the evaluation of the ANN/regression
%        data_compute (struct): data for the inductor design
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_single\n')

% load the FEM/ANN data
fprintf('load\n')
data_fem_ann = load(file_export);

% time start
tic = datetime('now');

% create the object for evaluating the geometry, thermal, and loss models with ANN/regression
fprintf('ann fem\n')
ann_fem_obj = AnnFem(data_fem_ann, eval_ann.geom_type, eval_ann.eval_type);

% compute the design
fprintf('run\n')
[fom, operating] = compute_design(ann_fem_obj, data_compute);

% time out
toc = datetime('now');
diff = toc-tic;

% display information about the design
fprintf('info\n')
fprintf('    single design\n')
fprintf('    diff = %s\n', char(diff))

% save data
fprintf('save\n')
save(file_single, 'fom', 'operating')

% gui
fprintf('gui\n')
plot_design(fom, operating)

fprintf('################## master_single\n')

end

function [fom, operating] = compute_design(ann_fem_obj, data_compute)
% Compute the figures of merit and the operating points of the single inductor design
%
%    Parameters:
%        ann_fem_obj (AnnFEM): instance of the ANN/regression engine for thermal and magnetic model
%        data_compute (struct): data for the inductor design
%
%    Returns:
%        fom (struct): computed figures of merit
%        operating (struct): computed operating points

% get the inductor data
data_const = data_compute.data_const;
data_vec = data_compute.data_vec;

% single design is required
n_sol = 1;

% create the object and get the figures of merit
inductor_compute_obj = design_compute.InductorCompute(n_sol, data_vec, data_const, ann_fem_obj);
fom = inductor_compute_obj.get_fom();

% compute the operating points
excitation = data_compute.fct_excitation(fom);
operating = inductor_compute_obj.get_operating(excitation);

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
