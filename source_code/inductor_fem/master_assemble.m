function master_assemble(folder_fem, file_fem)

% name
fprintf('master_assemble\n')

% run
fprintf('    assemble\n')
[n_tot, n_sol, inp, param, out_fem] = get_assemble(folder_fem);

% disp
fprintf('    size\n')
fprintf('        n_tot = %d\n', n_tot)
fprintf('        n_sol = %d\n', n_sol)

% save
fprintf('    save\n')
save(file_fem, 'n_sol', 'inp', 'param', 'out_fem')

end
