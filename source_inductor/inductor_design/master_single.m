function master_single(file_single, file_export, eval_ann, data_compute)
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
%    Parameters:
%        file_compute (str): path of the file to be written with the computed designs
%        file_export (str): path of the file containing the exported data from the FEM/ANN
%        sweep (cell): data controlling the generation of the design combinations
%        n_split (int): number of vectorized designs per computation
%        fct (struct): struct with custom functions for filtering invalid designs
%        eval_ann (struct): data for controlling the evaluation of the ANN/regression
%        data_compute (struct): data for the inductor designs
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_single\n')

% load the FEM/ANN data
fprintf('load\n')
data_fem_ann = load(file_export);

% create the object for evaluating the geometry, thermal, and loss models with ANN/regression
fprintf('ann fem\n')
ann_fem_obj = AnnFem(data_fem_ann, eval_ann.geom_type, eval_ann.eval_type);

% compute the design in parallel
fprintf('run\n')
[fom, operating] = compute_design(ann_fem_obj, data_compute);

% save data
fprintf('save\n')
save(file_single, 'fom', 'operating')

fprintf('################## master_single\n')

end

function [fom, operating] = compute_design(ann_fem_obj, data_compute)
% Compute the figures of merit and the operating points of the inductors
%
%    Parameters:
%        var (struct): struct of vectors with the samples with all the combinations
%        idx_chunk (vector): indices of the designs belonging in the chunk
%        ann_fem_obj (AnnFEM): instance of the ANN/regression engine for thermal and magnetic model
%        data_compute (struct): data for the inductor designs
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
