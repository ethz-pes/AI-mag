function get_idx_split(self)

% init generator
rng('shuffle');

% get size
n_train = round(self.n_sol.*self.split_train_test.ratio_train);

% generate indices
idx_perm = randperm(self.n_sol);

% select
switch self.split_train_test.type
    case 'no_overlap'
        self.idx_train = idx_perm(1:n_train);
        self.idx_test = idx_perm(n_train+1:self.n_sol);
    case 'with_overlap'
        self.idx_train = idx_perm(1:n_train);
        self.idx_test = idx_perm(1:self.n_sol);
    otherwise
        error('invalid type')
end

% check size
assert(nnz(self.idx_test)>=self.split_train_test.n_test_min, 'invalid number of solutions')
assert(nnz(self.idx_train)>=self.split_train_test.n_train_min, 'invalid number of solutions')

end
