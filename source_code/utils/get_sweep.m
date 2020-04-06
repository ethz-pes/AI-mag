function [n_sol, var] = get_sweep(sweep)
% Generate samples combinations (deterministic or random).
%
%    Different sample generation methods are available:
%        - Generates samples by combining vectors with only the provided combinations (deterministic or random)
%        - Generates samples by combining vectors with all possible combinations (deterministic or random)
%        - Generates samples completely randomly
%
%    For all the variables, different variable transformations are available.
%
%    Parameters:
%        sweep (struct): data controlling the samples generation
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the samples
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init random generator
rng('shuffle');

% get the sweep
switch sweep.type
    case 'vector'
        [n_sol, var] = get_vector(sweep.var, sweep.n_sol);
    case 'matrix'
        [n_sol, var] = get_matrix(sweep.var, sweep.n_sol);
    case 'random'
        [n_sol, var] = get_random(sweep.var, sweep.n_sol);
    otherwise
        error('invalid sweep type')
end

end

function [n_sol, var] = get_random(var, n_sol)
% Generate random samples with a given size.
%
%    Parameters:
%        var (struct): data controlling the samples generation
%        n_sol (int): number of samples to be generated
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the samples

field = fieldnames(var);
for i=1:length(field)
    tmp = var.(field{i});
    vec = get_vec_random(tmp, n_sol);
    var.(field{i}) = vec;
end

end

function [n_sol, var] = get_vector(var, n_sol)
% Generates samples by combining vectors with only the provided combinations.
%
%    Parameters:
%        var (struct): data controlling the samples generation
%        n_sol (int): number of samples to be generated
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the samples

field = fieldnames(var);
for i=1:length(field)
    tmp = var.(field{i});
    vec = get_vec_vector(tmp, n_sol);
    var.(field{i}) = vec;
end

end

function [n_sol, var] = get_matrix(var, n_sol)
% Generates samples by combining vectors with all possible combinations.
%
%    Parameters:
%        var (struct): data controlling the samples generation
%        n_sol (int): maximum number of samples to be of generated
%
%    Returns:
%        n_sol (int): number of generated samples
%        var (struct): struct of vectors with the samples

% get the vectors
field = fieldnames(var);
for i=1:length(field)
    tmp = var.(field{i});
    vec = get_vec_matrix(tmp);
    var.(field{i}) = vec;
end

% combine the vectors
[n_sol, var] = get_struct_combination(var, n_sol);

end

function vec = get_vec_random(var, n_sol)
% Generates a random vector return a fixed vector.
%
%    Parameters:
%        var (struct): data controlling the samples generation
%        n_sol (int): maximum number of samples to be of generated
%
%    Returns:
%        vec (vector): generated samples for the variable

if strcmp(var.var_trf, 'fixed')
    % the vector is given: has the right size or is a scalar
    vec = var.vec;
    if length(vec)==1
        vec = repmat(vec, 1, n_sol);
    end
    assert(length(vec)==n_sol, 'invalid length')
else
    % random vector generation (no only in linear coordinate)
    lb = get_var_trf(var.lb, var.var_trf, 'scale');
    ub = get_var_trf(var.ub, var.var_trf, 'scale');
    vec = lb+(ub-lb).*rand(1, n_sol);
    vec = get_var_trf(vec, var.var_trf, 'unscale');
    vec = get_type(vec, var.type);
end

end

function vec = get_vec_vector(var, n_sol)
% Generates a evenly spaced vector or return a fixed vector (size fixed).
%
%    Parameters:
%        var (struct): data controlling the samples generation
%        n_sol (int): maximum number of samples to be of generated
%
%    Returns:
%        vec (vector): generated samples for the variable

if strcmp(var.var_trf, 'fixed')
    % the vector is given: has the right size or is a scalar
    vec = var.vec;
    if length(vec)==1
        vec = repmat(vec, 1, n_sol);
    end
    assert(length(vec)==n_sol, 'invalid length')
else
    % evenly spaced vector (no only in linear coordinate)
    lb = get_var_trf(var.lb, var.var_trf, 'scale');
    ub = get_var_trf(var.ub, var.var_trf, 'scale');
    vec = linspace(lb, ub, n_sol);
    vec = get_var_trf(vec, var.var_trf, 'unscale');
    vec = get_type(vec, var.type);
end

end

function vec = get_vec_matrix(var)
% Generates a evenly spaced vector or return a fixed vector (size free).
%
%    Parameters:
%        var (struct): data controlling the samples generation
%
%    Returns:
%        vec (vector): generated samples for the variable

if strcmp(var.var_trf, 'fixed')
    % the vector is given
    vec = var.vec;
    assert(length(vec)>=1, 'invalid length')
else
    % evenly spaced vector (no only in linear coordinate)
    lb = get_var_trf(var.lb, var.var_trf, 'scale');
    ub = get_var_trf(var.ub, var.var_trf, 'scale');
    vec = linspace(lb, ub, var.n);
    vec = get_var_trf(vec, var.var_trf, 'unscale');
    vec = get_type(vec, var.type);
end

end

function [n_sol, var] = get_struct_combination(var, n_sol_max)
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

% get all the vectorss
field = fieldnames(var);
for i=1:length(field)
    vec = var.(field{i});
    x_cell{i} =  vec;
    n_sol_vec(i) = length(vec);
end

% check the size
n_sol = prod(n_sol_vec);
assert(n_sol<=n_sol_max, 'invalid length')

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
        error('invalid type')
end

switch scale_unscale
    case 'scale'
        vec_output = y_scl;
    case 'unscale'
        vec_output = y_unscale;
    otherwise
        error('invalid type')
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
        error('invalid type')
end

end