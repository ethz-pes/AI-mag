function master_compute(file_compute, file_export, sweep, n_split, fct_filter, data_ann, data_compute)

% name
fprintf('################## master_compute\n')

% load
fprintf('load\n')
data_fem_ann = load(file_export);

% ann_fem
fprintf('ann fem\n')
ann_fem_obj = AnnFem(data_fem_ann, data_ann.geom_type, data_ann.eval_type);

fprintf('sweep\n')
[n_tot, var] = get_sweep(sweep);

fprintf('split\n')
[n_chunk, idx_chunk] = get_chunk(n_split, n_tot);

fprintf('run\n')
parfor i=1:n_chunk
    fprintf('    %d / %d\n', i, n_chunk)
    [id_design{i}, fom(i), operating(i)] = compute_chunk(var, idx_chunk{i}, fct_filter, ann_fem_obj, data_compute);
end

fprintf('assemble\n')
id_design = [id_design{:}];
n_sol = length(id_design);
fom = get_struct_assemble(fom);
operating = get_struct_assemble(operating);

% disp
fprintf('size\n')
fprintf('    n_tot = %d\n', n_tot)
fprintf('    n_sol = %d\n', n_sol)

% save
fprintf('save\n')
save(file_compute, 'n_tot', 'n_sol', 'id_design', 'fom', 'operating')

fprintf('################## master_compute\n')

end

function [id_design, fom, operating] = compute_chunk(var, idx_chunk, fct_filter, ann_fem_obj, data_compute)

% slice
var =  get_struct_filter(var, idx_chunk);
n_sol = length(idx_chunk);

% get data
data_const = data_compute.data_const;
data_vec = data_compute.fct_data_vec(var);

% inductor
inductor_compute_obj = design.InductorCompute(n_sol, data_vec, data_const, ann_fem_obj);
fom = inductor_compute_obj.get_fom();

% operating
excitation = data_compute.fct_excitation(var, fom);
operating = inductor_compute_obj.get_operating(excitation);

% filter
is_valid = fct_filter(fom, operating, n_sol);

% assign
id_design = idx_chunk(is_valid);
fom = get_struct_filter(fom, is_valid);
operating = get_struct_filter(operating, is_valid);

end
