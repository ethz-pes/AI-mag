function master_compute_pareto(file_compute_all, file_export, sweep, n_split, fct, eval_ann, data_compute)
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
%    Parameters:
%        file_compute_all (str): path of the file to be written with the computed designs
%        file_export (str): path of the file containing the exported data from the FEM/ANN
%        sweep (cell): data controlling the generation of the design combinations
%        n_split (int): number of vectorized designs per computation
%        fct (struct): struct with custom functions for filtering invalid designs
%        eval_ann (struct): data for controlling the evaluation of the ANN/regression
%        data_compute (struct): data for the inductor designs
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_compute_pareto\n')

% load the FEM/ANN data
fprintf('load\n')
data_ann_fem = load(file_export);

% time start
tic = datetime('now');

% create the object for evaluating the geometry, thermal, and loss models with ANN/regression
fprintf('ann fem\n')
ann_fem_obj = AnnFem(data_ann_fem, eval_ann.geom_type, eval_ann.eval_type);

% generate the combinations to be computed
fprintf('sweep\n')
[n_tot, var] = get_sweep_combine(sweep);

% split the designs into chunks for parallel computing
fprintf('split\n')
[n_chunk, idx_chunk] = get_chunk(n_split, n_tot);

% compute the designs in parallel
fprintf('run\n')
parfor i=1:n_chunk
    fprintf('    %d / %d\n', i, n_chunk)
    [track(i), fom(i), operating(i)] = compute_chunk(var, idx_chunk{i}, fct, ann_fem_obj, data_compute);
end

% assemble the data computed in parallel
fprintf('assemble\n')
id_design = [track.id_design];
n_sol = sum([track.n_sol]);
n_filter_var = sum([track.n_filter_var]);
n_filter_fom = sum([track.n_filter_fom]);
fom = get_struct_assemble(fom);
operating = get_struct_assemble(operating);

% time out
toc = datetime('now');
diff = toc-tic;

% display information about the design
fprintf('info\n')
fprintf('    diff = %s\n', char(diff))
fprintf('    n_tot = %d\n', n_tot)
fprintf('    n_filter_var = %d\n', n_filter_var)
fprintf('    n_filter_fom = %d\n', n_filter_fom)
fprintf('    n_sol = %d\n', n_sol)

% save data
fprintf('save\n')
save(file_compute_all, '-v7.3', 'diff', 'n_tot', 'n_filter_var', 'n_filter_fom', 'n_sol', 'id_design', 'fom', 'operating')

fprintf('################## master_compute_pareto\n')

end

function [track, fom, operating] = compute_chunk(var, idx_chunk, fct, ann_fem_obj, data_compute)
% Compute a chunk of vectorized inductor designs
%
%    A two steps workflow is used:
%        - first, only the figures of merit are extracted (without evaluating the operating points)
%        - filter the designs
%        - then,  the figures of merit and the of the operating points are extracted
%        - filter the designs
%
%    With this workflow, it is possible:
%        - to avoid the computation of operating points of rubbish designs
%        - to avoid the saving of invalid designs
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        idx_chunk (vector): indices of the designs belonging in the chunk
%        fct (struct): struct with custom functions for filtering invalid designs
%        ann_fem_obj (AnnFEM): instance of the ANN/regression engine for thermal and magnetic model
%        data_compute (struct): data for the inductor designs
%
%    Returns:
%        track (struct): struct with the indices of the valid designs and the number of designs(to keep track of their ids)
%        fom (struct): figures of merit of the valid designs
%        operating (struct): operating points of the valid designs

% get the chunk
var =  get_struct_filter(var, idx_chunk);

% apply the filter of the variables
is_valid = fct.fct_filter_var(var, length(idx_chunk));
var = get_struct_filter(var, is_valid);
idx_chunk = idx_chunk(is_valid);
n_filter_var = length(idx_chunk);

% compute the figures of merit of the inductors (without evaluating the operating points)
[var, fom] = compute_fom(var, n_filter_var, ann_fem_obj, data_compute);

% filter the inductors with the figures of merit
is_valid = fct.fct_filter_fom(var, fom, n_filter_var);
var = get_struct_filter(var, is_valid);
idx_chunk = idx_chunk(is_valid);
n_filter_fom = length(idx_chunk);

% for the resulting designs, compute the figures of merit and the operating points
[var, fom, operating] = compute_operating(var, n_filter_fom, ann_fem_obj, data_compute);

% filter the inductors with the operating points
is_valid = fct.fct_filter_operating(var, fom, operating, n_filter_fom);
fom = get_struct_filter(fom, is_valid);
operating = get_struct_filter(operating, is_valid);
idx_chunk = idx_chunk(is_valid);
n_sol = length(idx_chunk);

% assign tracking data
track.id_design = idx_chunk;
track.n_sol = n_sol;
track.n_filter_fom = n_filter_fom;
track.n_filter_var = n_filter_var;

end

function [var, fom] = compute_fom(var, n_sol, ann_fem_obj, data_compute)
% Compute the figures of merit of the inductors (without evaluating the operating points)
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        n_sol (integer): number of samples
%        ann_fem_obj (AnnFEM): instance of the ANN/regression engine for thermal and magnetic model
%        data_compute (struct): data for the inductor designs
%
%    Returns:
%        var (struct): struct of vectors with the samples (all the combinations)
%        fom (struct): computed figures of merit

% get the inductor data
data_const = data_compute.data_const;
data_vec = data_compute.fct_data_vec(var, n_sol);

% create the object and get the figures of merit
inductor_compute_obj = design_compute.InductorCompute(n_sol, data_vec, data_const, ann_fem_obj);
fom = inductor_compute_obj.get_fom();

end

function [var, fom, operating] = compute_operating(var, n_sol, ann_fem_obj, data_compute)
% Compute the figures of merit and the operating points of the inductors
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        n_sol (integer): number of samples
%        ann_fem_obj (AnnFEM): instance of the ANN/regression engine for thermal and magnetic model
%        data_compute (struct): data for the inductor designs
%
%    Returns:
%        var (struct): struct of vectors with the samples (all the combinations)
%        fom (struct): computed figures of merit
%        operating (struct): computed operating points

% get the inductor data
data_const = data_compute.data_const;
data_vec = data_compute.fct_data_vec(var, n_sol);

% create the object and get the figures of merit
inductor_compute_obj = design_compute.InductorCompute(n_sol, data_vec, data_const, ann_fem_obj);
fom = inductor_compute_obj.get_fom();

% compute the operating points
excitation = data_compute.fct_excitation(var, fom, n_sol);
operating = inductor_compute_obj.get_operating(excitation);

end
