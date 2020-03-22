function master_compute(file_compute, file_export, sweep, n_split, data_ann, data_compute)

% name
fprintf('################## master_compute\n')

% load
fprintf('load\n')
data_fem_ann = load(file_export);

% ann_fem
fprintf('ann fem\n')
ann_fem_obj = AnnFem(data_fem_ann, data_ann.geom_type, data_ann.eval_type);

fprintf('sweep\n')
[n_sol, var] = get_sweep(sweep);

fprintf('split\n')
[n_chunk, idx_chunk] = get_chunk(n_split, n_sol);

fprintf('run\n')
parfor i=1:n_chunk
    fprintf('    %d / %d\n', i, n_chunk)
    [n_valid(i), fom(i), operating(i)] = compute_chunk(var, idx_chunk{i}, ann_fem_obj, data_compute);
end

fprintf('assemble\n')
n_valid = sum(n_valid);
fom = get_struct_assemble(fom);
operating = get_struct_assemble(operating);

% disp
fprintf('size\n')
fprintf('    n_sol = %d\n', n_sol)
fprintf('    n_valid = %d\n', n_valid)

% save
fprintf('save\n')
save(file_compute, 'n_valid', 'n_sol', 'fom', 'operating')

fprintf('################## master_compute\n')

end

function [n_valid, fom, operating] = compute_chunk(var, idx_chunk, ann_fem_obj, data_compute)

% slice
var_tmp =  get_struct_filter(var, idx_chunk);
n_sol_tmp = length(idx_chunk);

% get data
data_const = data_compute.data_const;
data_vec = data_compute.fct_data_vec(var_tmp);

% inductor
inductor_compute_obj = design.InductorCompute(n_sol_tmp, data_vec, data_const, ann_fem_obj);
[is_valid, fom] = inductor_compute_obj.get_fom();

% operating
excitation = data_compute.fct_excitation(var_tmp, fom);
operating = inductor_compute_obj.get_operating(excitation);

% assign
n_valid = nnz(is_valid);
fom = get_struct_filter(fom, is_valid);
operating = get_struct_filter(operating, is_valid);

end
