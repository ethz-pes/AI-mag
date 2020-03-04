function [idx_train, idx_test] = get_idx_split(n_sol, split_train_test)

% init generator
rng('shuffle');

% check size
assert(n_sol>split_train_test.n_min, 'invalid number of solutions')

% get size
n_train = round(n_sol.*split_train_test.ratio_train);

% generate indices
idx_perm = randperm(n_sol);

% select
switch split_train_test.type
    case 'no_overlap'
        idx_train = idx_perm(1:n_train);
        idx_test = idx_perm(n_train+1:n_sol);
    case 'with_overlap'
        idx_train = idx_perm(1:n_train);
        idx_test = idx_perm(1:n_sol);
    otherwise
        error('invalid type')
end
end
