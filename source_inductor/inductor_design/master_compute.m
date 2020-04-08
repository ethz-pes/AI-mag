function master_compute(file_compute, file_export, sweep, n_split, fct, eval_ann, data_compute)
% Compute many inductor inductor designs (properties, thermal, losses, etc.).
%
%    Load the ANN/regression obtained with the FEM/ANN worflow.
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
fprintf('################## master_compute\n')

% load the FEM/ANN data
fprintf('load\n')
data_fem_ann = load(file_export);

% time start
tic = datetime('now');

% create the object for evaluating the geometry, thermal, and loss models with ANN/regression
fprintf('ann fem\n')
ann_fem_obj = AnnFem(data_fem_ann, eval_ann.geom_type, eval_ann.eval_type);

% generate the combinations to be computed
fprintf('sweep\n')
[n_tot, var] = get_sweep_cell(sweep);

% split the design into chunks for parallel computing
fprintf('split\n')
[n_chunk, idx_chunk] = get_chunk(n_split, n_tot);

% compute the design in parallel
fprintf('run\n')
parfor i=1:n_chunk
    fprintf('    %d / %d\n', i, n_chunk)
    [id_design{i}, n_sol(i), n_compute(i), fom(i), operating(i)] = compute_chunk(var, idx_chunk{i}, fct, ann_fem_obj, data_compute);
end

% assemble the data computed in parallel
fprintf('assemble\n')
id_design = [id_design{:}];
n_sol = sum(n_sol);
n_compute = sum(n_compute);
fom = get_struct_assemble(fom);
operating = get_struct_assemble(operating);

% time out
toc = datetime('now');
diff = toc-tic;

% display information about the design
fprintf('info\n')
fprintf('    diff = %s\n', char(diff))
fprintf('    n_tot = %d\n', n_tot)
fprintf('    n_compute = %d\n', n_compute)
fprintf('    n_sol = %d\n', n_sol)

% save data
fprintf('save\n')
save(file_compute, 'diff', 'n_tot', 'n_compute', 'n_sol', 'id_design', 'fom', 'operating')

fprintf('################## master_compute\n')

end

function [n_sol, var] = get_sweep_cell(sweep)
% Generate samples combinations with different types of sweep (combined).
%
%    Parameters:
%        sweep (cell): data controlling the samples generation
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the samples

% get each sweep
for i=1:length(sweep)
    [n_tot_tmp, var_tmp] = get_sweep(sweep{i});
    n_sol_vec(i) = n_tot_tmp;
    var_vec(i) = var_tmp;
end

% assemble the data
n_sol = sum(n_sol_vec);
var = get_struct_assemble(var_vec);

end

function [idx_chunk, n_sol, n_compute, fom, operating] = compute_chunk(var, idx_chunk, fct, ann_fem_obj, data_compute)
% Compute a chunk of vectorized inductor designs
%
%    A two steps workflow is used:
%        - first, only the figures of merit are extracted (without evaluating the operating points) 
%        - filter the designs
%        - then,  the figures of merit and the of the operating points are extracted
%        - filter the designs
%        - with this worflow, it is possible to avoid the computation of operating points of rubbish designs
%
%    Parameters:
%        var (struct): struct of vectors with the samples with all the combinations
%        idx_chunk (vector): indices of the designs belonging in the chunk
%        fct (struct): struct with custom functions for filtering invalid designs
%        ann_fem_obj (AnnFEM): instance of the ANN/regression engine for thermal and magnetic model
%        data_compute (struct): data for the inductor designs
%
%    Returns:
%        idx_chunk (vector): indices of the valid designs (to keep track of their id)
%        n_sol (int): number of valid designs
%        n_compute (int): number of computed designs
%        fom (struct): figures of merit of the valid designs
%        operating (struct): operating points of the valid designs

% compute the figures of merit of the inductors (without evaluating the operating points)
fom = compute_fom(var, idx_chunk, ann_fem_obj, data_compute);

% filter the inductors with the obtained data
is_valid = fct.fct_filter_compute(fom, length(idx_chunk));
idx_chunk = idx_chunk(is_valid);
n_compute = length(idx_chunk);

% for the resulting designs, compute the figures of merit and the operating points
[fom, operating] = compute_operating(var, idx_chunk, ann_fem_obj, data_compute);

% filter the inductors with the obtained data
is_valid = fct.fct_filter_save(fom, operating, length(idx_chunk));
idx_chunk = idx_chunk(is_valid);
n_sol = length(idx_chunk);

% assign the results
fom = get_struct_filter(fom, is_valid);
operating = get_struct_filter(operating, is_valid);

end

function fom = compute_fom(var, idx_chunk, ann_fem_obj, data_compute)
% Compute the figures of merit of the inductors (without evaluating the operating points)
%
%    Parameters:
%        var (struct): struct of vectors with the samples with all the combinations
%        idx_chunk (vector): indices of the designs belonging in the chunk
%        ann_fem_obj (AnnFEM): instance of the ANN/regression engine for thermal and magnetic model
%        data_compute (struct): data for the inductor designs
%
%    Returns:
%        fom (struct): computed figures of merit

% get the selected designs
var =  get_struct_filter(var, idx_chunk);
n_sol = length(idx_chunk);

% get the inductor data
data_const = data_compute.data_const;
data_vec = data_compute.fct_data_vec(var);

% create the object and get the figures of merit
inductor_compute_obj = design_compute.InductorCompute(n_sol, data_vec, data_const, ann_fem_obj);
fom = inductor_compute_obj.get_fom();

end

function [fom, operating] = compute_operating(var, idx_chunk, ann_fem_obj, data_compute)
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

% get the selected designs
var =  get_struct_filter(var, idx_chunk);
n_sol = length(idx_chunk);

% get the inductor data
data_const = data_compute.data_const;
data_vec = data_compute.fct_data_vec(var);

% create the object and get the figures of merit
inductor_compute_obj = design_compute.InductorCompute(n_sol, data_vec, data_const, ann_fem_obj);
fom = inductor_compute_obj.get_fom();

% compute the operating points
excitation = data_compute.fct_excitation(var, fom);
operating = inductor_compute_obj.get_operating(excitation);

end
