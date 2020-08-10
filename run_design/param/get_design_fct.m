function fct = get_design_fct()
% Get the function handles for filtering invalid designs.
%
%    Returns:
%        fct (struct): struct with custom functions for filtering invalid designs
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% filter the valid designs from the input variables (without the figures of merit)
fct.fct_filter_var = @(var, n_sol) fct_filter_var(var, n_sol);

% filter the valid designs from the figures of merit (without the operating points)
fct.fct_filter_fom = @(var, fom, n_sol) fct_filter_fom(var, fom, n_sol);

% filter the valid designs from the figure of merit and the operating points
fct.fct_filter_operating = @(var, fom, operating, n_sol) fct_filter_operating(var, fom, operating, n_sol);

end

function is_filter = fct_filter_fom(var, fom, n_sol)
% Filter the design to be kept after the computation of the figures of merit.
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        fom (struct): figures of merit of the designs
%        n_sol (int): number of provided designs
%
%    Returns:
%        is_filter (vector): vector of logical with the design to be kept

% check size
assert(isstruct(var), 'invalid var data type')
assert(isstruct(fom), 'invalid var data type')
assert(isnumeric(n_sol), 'invalid number of samples')

% select the designs
is_filter = fct_filter_var(var, n_sol);

% check the validity of the figures of merit
is_filter = is_filter&fom.is_valid;

end

function is_filter = fct_filter_var(var, n_sol)
% Filter the design to be kept after the generation of the variables combinations.
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        n_sol (int): number of provided designs
%
%    Returns:
%        is_filter (vector): vector of logical with the design to be kept

% check
assert(isstruct(var), 'invalid var data type')
assert(isnumeric(n_sol), 'invalid number of samples')

% filter
is_filter = true(1, n_sol);

end

function is_filter = fct_filter_operating(var, fom, operating, n_sol)
% Filter the design to be saved.
%
%    Parameters:
%        var (struct): struct of vectors with the samples (all the combinations)
%        fom (struct): figures of merit of the designs
%        operating (struct): operating points of the designs
%        n_sol (int): number of provided designs
%
%    Returns:
%        is_filter (vector): vector of logical with the design to be saved

% check size
assert(isstruct(var), 'invalid var data type')
assert(isstruct(fom), 'invalid var data type')
assert(isstruct(operating), 'invalid var data type')
assert(isnumeric(n_sol), 'invalid number of samples')

% select the designs
is_filter = fct_filter_fom(var, fom, n_sol);

% check the validity of the operating points
is_filter = is_filter&operating.partial_load.is_valid;
is_filter = is_filter&operating.full_load.is_valid;

% filter the values
is_filter = is_filter&(operating.partial_load.losses.P_tot<=4.0);
is_filter = is_filter&(operating.full_load.losses.P_tot<=6.0);

end

