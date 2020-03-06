function get_fem(folder, model_type, var_type, n_sol, inp, const)

% compute
for i=1:n_sol
    fprintf('    %d / %d\n', i, n_sol)
    inp_tmp =  get_struct_idx(inp, i);

    get_out_sub(folder, model_type, var_type, inp_tmp, const);
end

end

function get_out_sub(folder, model_type, var_type, inp, const)

% get filename
hash = get_hash_struct(inp);
filename = [folder filesep() hash '.mat'];
make_computation = exist(filename, 'file')~=2;

if make_computation==true
    % start timer
    tic = datetime('now');
    fprintf('        compute: start\n')
    
    % merge
    inp = get_struct_merge(inp, const);
    [is_valid, inp] = get_extend_inp(model_type, var_type, inp);
        
    % disp
    if is_valid==true
        fprintf('        compute: valid\n')
        out_fem = get_out_fem(model_type, inp);
    else
        fprintf('        compute: invalid\n')
        out_fem = struct();
    end    
    
    % end timer
    toc = datetime('now');
    diff = toc-tic;
    fprintf('        compute: %s\n', char(diff))
        
    % save
    save(filename, 'inp', 'is_valid', 'model_type', 'out_fem', 'diff')
end

end