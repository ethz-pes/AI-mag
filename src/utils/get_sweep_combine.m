function [n_sol, var] = get_sweep_combine(sweep)
% Generate samples combinations with different types of sweep (combined).
%
%    Parameters:
%        sweep (cell): data controlling the samples generation
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the samples
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

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
