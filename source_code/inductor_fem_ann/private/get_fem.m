function get_fem(folder, n_sol, inp, const)

% compute
for i=1:n_sol
    fprintf('    %d / %d\n', i, n_sol)
    inp_tmp =  get_struct_idx(inp, i);

    get_out_sub(folder, inp_tmp, const);
end

end

function get_out_sub(folder, inp, const)

% get filename
hash = get_hash(inp);
filename = [folder filesep() hash '.mat'];
make_computation = exist(filename, 'file')~=2;

if make_computation==true
    % start timer
    tic = datetime('now');
    fprintf('        compute: start\n')
    
    % merge
    [is_valid, geom] = get_geom(inp, const.geom);
        
    % disp
    if is_valid==true
        fprintf('        compute: valid\n')
        out_fem = get_out_fem(inp, geom, const.model_type, const.fem, const.material);
    else
        fprintf('        compute: invalid\n')
        out_fem = struct();
    end    
    
    % end timer
    toc = datetime('now');
    diff = toc-tic;
    fprintf('        compute: %s\n', char(diff))
        
    % save
    save(filename, 'inp', 'is_valid', 'const', 'out_fem', 'diff')
end

end