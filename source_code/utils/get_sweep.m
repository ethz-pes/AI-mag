function [n_sol, var] = get_sweep(sweep)

% init random generator
rng('shuffle');

% get the sweep
switch sweep.type
    case 'vector'
        [n_sol, var] = get_vector(sweep.var, sweep.n_sol);
    case 'matrix'
        [n_sol, var] = get_matrix(sweep.var);
    case 'random'
        [n_sol, var] = get_random(sweep.var, sweep.n_sol);
    otherwise
        error('invalid sweep type')
end

end

function [n_sol, var] = get_random(var, n_sol)

field = fieldnames(var);
for i=1:length(field)
    tmp = var.(field{i});
    vec = get_vec_random(tmp, n_sol);
    var.(field{i}) = vec;
end

end

function [n_sol, var] = get_vector(var, n_sol)

field = fieldnames(var);
for i=1:length(field)
    tmp = var.(field{i});
    vec = get_vec_vector(tmp, n_sol);
    var.(field{i}) = vec;
end

end

function [n_sol, var] = get_matrix(var)

field = fieldnames(var);
for i=1:length(field)
    tmp = var.(field{i});
    vec = get_vec_matrix(tmp);
    var.(field{i}) = vec;
end

[n_sol, var] = get_struct_combination(var);

end

function vec = get_vec_random(var, n)

if strcmp(var.var_trf, 'fixed')
    vec = var.vec;
    if length(vec)==1
        vec = repmat(vec, 1, n);
    end
    assert(length(vec)==n, 'invalid length')
else
    lb = get_var_trf(var.lb, var.var_trf, 'scale');
    ub = get_var_trf(var.ub, var.var_trf, 'scale');
    vec = lb+(ub-lb).*rand(1, n);
    vec = get_var_trf(vec, var.var_trf, 'unscale');
end

end

function vec = get_vec_vector(var, n)

if strcmp(var.var_trf, 'fixed')
    vec = var.vec;
    if length(vec)==1
        vec = repmat(vec, 1, n);
    end
    assert(length(vec)==n, 'invalid length')
else
    lb = get_var_trf(var.lb, var.var_trf, 'scale');
    ub = get_var_trf(var.ub, var.var_trf, 'scale');
    vec = linspace(lb, ub, n);
    vec = get_var_trf(vec, var.var_trf, 'unscale');
end

end

function vec = get_vec_matrix(var)

if strcmp(var.var_trf, 'fixed')
    vec = var.vec;
    assert(length(vec)>=1, 'invalid length')
else
    lb = get_var_trf(var.lb, var.var_trf, 'scale');
    ub = get_var_trf(var.ub, var.var_trf, 'scale');
    vec = linspace(lb, ub, var.n);
    vec = get_var_trf(vec, var.var_trf, 'unscale');
end

end

function [n, data] = get_struct_combination(data)

field = fieldnames(data);
for i=1:length(field)
    vec = data.(field{i});
    x_cell{i} =  vec;
    n_vec(i) = length(vec);
end

x_tmp = cell(1,length(x_cell));
[x_tmp{:}] = ndgrid(x_cell{:});
n = prod(n_vec);

for i=1:length(field)
    vec = x_tmp{i};
    data.(field{i}) =  vec(:).';
end

end

function y = get_var_trf(x, type, scale_unscale)

switch type
    case 'lin'
        y_scale = x;
        y_unscale = x;
    case 'rev'
        y_scale = 1./x;
        y_unscale = 1./x;
    case 'log'
        y_scale = log10(x);
        y_unscale = 10.^x;
    case 'exp'
        y_scale = 10.^x;
        y_unscale = log10(x);
    case 'square'
        y_scale = x.^2;
        y_unscale = sqrt(x);
    case 'sqrt'
        y_scale = sqrt(x);
        y_unscale = x.^2;
    otherwise
        error('invalid data')
end

switch scale_unscale
    case 'scale'
        y = y_scale;
    case 'unscale'
        y = y_unscale;
    otherwise
        error('invalid data')
end

end