function [n_sol, var] = get_sweep(sweep)
% Generate samples combinations (deterministic or random).
%
%    Different sample generation methods are available:
%        - Generates samples by combining vectors with only the provided combinations (deterministic or random)
%        - Generates samples by combining vectors with all possible combinations (deterministic or random)
%
%    Three different methods are available for generating the variable samples:
%        - Given fixed vector
%        - Randompicks (with a given length) from a given discrete set
%        - Regularly spaced span
%            -  Variables can be float or integer
%            -  Variable transformations (e.g., logarithmic, quadratic) are available
%
%    Parameters:
%        sweep (struct): data controlling the samples generation
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the samples
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get the vector for the different variables
var = get_vector(sweep.var);

% get the sweep
switch sweep.type
    case 'specified_combinations'
        [n_sol, var] = get_specified(var, sweep.n_sol_max);
    case 'all_combinations'
        [n_sol, var] = get_all(var, sweep.n_sol_max);
    otherwise
        error('invalid sweep combination method')
end

end

function var = get_vector(var)
% Generates samples by combining vectors with only the provided combinations.
%
%    Parameters:
%        var (struct): data controlling the samples generation
%
%    Returns:
%        var (struct): struct of vectors with the samples

field = fieldnames(var);
for i=1:length(field)
    tmp = var.(field{i});
    vec = get_vec_vector(tmp);
    var.(field{i}) = vec;
end

end

function vec = get_vec_vector(var)
% Generates a vector with samples (fixed, random picks from a set, or regularly spaced span).
%
%    Parameters:
%        var (struct): data controlling the samples generation
%
%    Returns:
%        vec (vector): generated samples for the variable

switch var.type
    case 'fixed'
        % the vector is given: nothing to do
        vec = var.vec;
    case 'randset'
        % get the indices of the random picks within the set
        idx = randi(length(var.set), 1, var.n);
        
        % get the values from the indices
        vec = var.set(idx);
    case 'span'
        % make the variable transformation of the bounds
        lb = get_var_trf(var.lb, var.var_trf, 'scale');
        ub = get_var_trf(var.ub, var.var_trf, 'scale');
        
        % span the data in the transformed coordinate
        switch var.span
            case 'lin'
                vec = linspace(lb, ub, var.n);
            case 'random'
                vec = lb+(ub-lb).*rand(1, var.n);
            case 'normal'
                vec = (ub+lb)./2+(ub-lb)./2.*randn(1, var.n);
            otherwise
                error('invalid variable spanning method')
        end
        
        % unscale the variable (bounds were scaled)
        vec = get_var_trf(vec, var.var_trf, 'unscale');
        
        % make the type casting
        vec = get_type(vec, var.var_type);
    otherwise
        error('invalid variable generation method')
end

end

function [n_sol, var] = get_specified(var, n_sol_max)
% Generates generating all the specified combinations with the vectors.
%
%    The maximum number of samples can be controlled to:
%        - Avoid to long simulations
%        - Avoid memory saturation
%
%    Parameters:
%        var (struct): struct of vectors with the variables
%        n_sol_max (int): maximum number of samples to be of generated
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the combined variables

% get all the vector sizes
field = fieldnames(var);
for i=1:length(field)
    vec = var.(field{i});
    n_sol_vec(i) = length(vec);
end

% check the size
n_sol = unique(n_sol_vec);
assert(length(n_sol)==1, 'invalid sweep size (unequal variable size)')
assert(n_sol<=n_sol_max, 'invalid sweep size (too many samples)')

end

function [n_sol, var] = get_all(var, n_sol_max)
% Generates generating all the possible combinations between vectors.
%
%    The maximum number of samples can be controlled to:
%        - Avoid to long simulations
%        - Avoid memory saturation
%
%    Parameters:
%        var (struct): struct of vectors with the variables
%        n_sol_max (int): maximum number of samples to be of generated
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the combined variables

% get all the vectors
field = fieldnames(var);
for i=1:length(field)
    vec = var.(field{i});
    x_cell{i} =  vec;
    n_sol_vec(i) = length(vec);
end

% check the size
n_sol = prod(n_sol_vec);
assert(n_sol<=n_sol_max, 'invalid sweep size (too many samples)')

% get all combinations
x_tmp = cell(1,length(x_cell));
[x_tmp{:}] = ndgrid(x_cell{:});

% assign the results
for i=1:length(field)
    vec = x_tmp{i};
    var.(field{i}) =  vec(:).';
end

end

function vec_output = get_var_trf(vec_input, type, scale_unscale)
% Apply a given variable transformation or inverse transformation to a vector.
%
%    Parameters:
%        vec_input (vector): vector with the input data
%        type (str): type of transformation to perform
%        scale_unscale (str): transformation or inverse transformation ('scale' or 'unscale')
%
%    Returns:
%        vec_output (vector): vector with the output data

switch type
    case 'none'
        y_scl = vec_input;
        y_unscale = vec_input;
    case 'rev'
        y_scl = 1./vec_input;
        y_unscale = 1./vec_input;
    case 'log'
        y_scl = log10(vec_input);
        y_unscale = 10.^vec_input;
    case 'exp'
        y_scl = 10.^vec_input;
        y_unscale = log10(vec_input);
    case 'square'
        y_scl = vec_input.^2;
        y_unscale = sqrt(vec_input);
    case 'sqrt'
        y_scl = sqrt(vec_input);
        y_unscale = vec_input.^2;
    otherwise
        error('invalid variable transformation method')
end

switch scale_unscale
    case 'scale'
        vec_output = y_scl;
    case 'unscale'
        vec_output = y_unscale;
    otherwise
        error('invalid scaling / unscaling choice')
end

end

function vec_output = get_type(vec_input, type)
% Convert a given variable with different types.
%
%    Parameters:
%        vec_input (vector): vector with the input data
%        type (str): type of cast to perform ('float' or 'int')
%
%    Returns:
%        vec_output (vector): vector with the casted output data

switch type
    case 'float'
        vec_output = vec_input;
    case 'int'
        vec_output = round(vec_input);
    otherwise
        error('invalid data type')
end

end