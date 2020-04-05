function get_idx_split(self)
% Make the split of the samples between training and testing datasets.
%
%    Guarantee a minimum number of samples for the datasets
%    Test dataset with or without overlap with the training dataset.

% init random generator with random number
rng('shuffle');

% get the size of the training datasets
n_train = round(self.n_sol.*self.split_train_test.ratio_train);

% random permutation of the dataset
idx_perm = randperm(self.n_sol);

% select the splitting method
switch self.split_train_test.type
    case 'no_overlap'
        % test dataset excludes samples from the training dataset
        self.idx_train = idx_perm(1:n_train);
        self.idx_test = idx_perm(n_train+1:self.n_sol);
    case 'with_overlap'
        % test dataset contains samples from the training dataset
        self.idx_train = idx_perm(1:n_train);
        self.idx_test = idx_perm(1:self.n_sol);
    otherwise
        error('invalid type')
end

% check the size
assert(nnz(self.idx_test)>=self.split_train_test.n_test_min, 'invalid number of solutions')
assert(nnz(self.idx_train)>=self.split_train_test.n_train_min, 'invalid number of solutions')

end
