function [model, has_license] = get_license(file_model, diff_license_max, diff_license_trial)

% simulation start time
tic = datetime('now');

% try to get a license
is_wait = true;
n_trial = 1;
while is_wait==true
    % compute elapsed time
    toc = datetime('now');
    diff = toc-tic;
    
    % try to load a file
    try
        model = mphload(file_model);
        has_license = true;
    catch
        model = [];
        has_license = false;
    end
    
    % check for abort
    if has_license==true
        fprintf('    license / success / %d / %s\n', n_trial, char(diff))
        is_wait = false;
    elseif diff>diff_license_max
        fprintf('    license / timeout / %d / %s\n', n_trial, char(diff))
        is_wait = false;
    else
        fprintf('    license / retry / %d / %s\n', n_trial, char(diff))
        pause(seconds(diff_license_trial));
        n_trial = n_trial+1;
    end
end

end