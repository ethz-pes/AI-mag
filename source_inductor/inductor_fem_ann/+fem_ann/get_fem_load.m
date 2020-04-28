function [model, is_ok, i_reload] = get_fem_load(file_model, timing, model, is_ok, i_reload)
% Load a COMSOL model (retry if license not available, with timeout).
%
%    Load the model with the following rules:
%        - load the model is not model is provided (init)
%        - reload the model every given number of load call ('n_reload')
%
%    For loading the model, the following procedure is used:
%        - try to load the model many times in case of license failure ('n_trial')
%        - wait some times between the trials ('diff_trial')
%
%    Parameters:
%        file_model (str): path of the COMSOL file to be loaded
%        timing (struct): struct controlling simulation time (for batching systems)
%        model (model): provided COMSOL model
%        is_ok (logical): if the provided model is successfully loaded
%        i_reload (integer): provided counter for determining if a reload is required
%
%    Returns:
%        model (model): loaded COMSOL model
%        is_ok (logical): if the model is successfully loaded
%        i_reload (integer): updated counter for determining if a reload is required
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get timing data
diff_trial = timing.diff_trial;
n_trial = timing.n_trial;
n_reload = timing.n_reload;

% check if load is required
if isempty(model)||isempty(is_ok)||isempty(i_reload)
    % init, load is required
    fprintf('        license / load\n')
    [model, is_ok] = get_load(file_model, diff_trial, n_trial);
    i_reload = 1;
elseif i_reload==0
    % n_trial runs have been made, reload is required
    fprintf('        license / load\n')
    [model, is_ok] = get_load(file_model, diff_trial, n_trial);
    i_reload = i_reload+1;
else
    % n_trial runs have not been made, reload is not required
    fprintf('        license / pass\n')
    i_reload = i_reload+1;
    i_reload = mod(i_reload, n_reload);
end

end

function [model, is_ok] = get_load(file_model, diff_trial, n_trial)
% Load a COMSOL model (retry if license not available, with timeout).
%
%    Parameters:
%        file_model (str): path of the COMSOL file to be loaded
%        diff_trial (duration): time between two COMSOL license trials
%        n_trial (integer): maximum number if COMSOL license trials
%
%    Returns:
%        model (model): loaded COMSOL model
%        is_ok (logical): if the model is successfully loaded

% load start time
tic = datetime('now');

% try to load the model
for i=1:n_trial
    % display
    fprintf('        license / try / %d / %d / %s\n', i, n_trial, get_diff(tic))
    
    % try to load a model
    try
        model = mphload(file_model);
        is_ok = true;
    catch
        model = [];
        is_ok = false;
    end
    
    % check for abort, success, or repeat
    if is_ok==true
        break
    else
        pause(seconds(diff_trial));
    end
end

% status
if is_ok==true
    fprintf('        license / success / %d / %s\n', n_trial, get_diff(tic))
else
    fprintf('        license / failure / %d / %s\n', n_trial, get_diff(tic))
end

end

function str = get_diff(tic)
% Get elapsed time.
%
%    Parameters:
%        tic (datetime): start time of the simulation
%
%    Returns:
%        str (str): string with the elapsed time

toc = datetime('now');
diff = toc-tic;
str = char(diff);

end