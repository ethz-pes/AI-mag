function get_loop_time(n_sol, fct, diff_sim_max)

% simulation start time
tic = datetime('now');

for i=1:n_sol
    % compute elapsed time
    toc = datetime('now');
    diff = toc-tic;
    
    % check elapsed time, abort if required
    if diff<diff_sim_max
        % display design progression
        fprintf('    fem / %d / %d / %s\n', i, n_sol, char(diff))
        
        % run simulation
        fct(i);
    else
        % display time information
        fprintf('    fem / time elapsed / %s / %s\n', char(diff), char(diff_max))
        
        % abort
        break
    end
end

end