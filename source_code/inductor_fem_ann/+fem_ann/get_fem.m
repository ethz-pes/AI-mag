function get_fem(folder_fem, file_model, model_type, geom_type, n_sol, inp, const)

% compute
for i=1:n_sol
    fprintf('    %d / %d\n', i, n_sol)
    inp_tmp =  get_struct_filter(inp, i);

    get_out_sub(file_model, folder_fem, model_type, geom_type, inp_tmp, const);
end

end

function get_out_sub(file_model, folder_fem, model_type, var_type, inp, const)

% get filename
hash = get_struct_hash(inp);
filename = [folder_fem filesep() hash '.mat'];
make_computation = exist(filename, 'file')~=2;

if make_computation==true
    % start timer
    tic = datetime('now');
    fprintf('        compute: start\n')
    
    % merge
    n_sol = 1;
    [is_valid, inp] = fem_ann.get_extend_inp(const, model_type, var_type, n_sol, inp);
        
    % disp
    if is_valid==true
        fprintf('        compute: valid\n')
        out_fem = fem_ann.get_out_fem(file_model, model_type, inp);
    else
        fprintf('        compute: invalid\n')
        out_fem = struct();
    end    
    
    % end timer
    toc = datetime('now');
    diff = toc-tic;
    fprintf('        compute: %s\n', char(diff))
        
    % save
    save(filename, 'inp', 'is_valid', 'model_type', 'var_type', 'out_fem', 'diff')
end

end