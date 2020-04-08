function get_fom_train(self)
% Get the figures on merit of the datasets.
%
%    Get the size of the datasets (training and test).
%    Compute the different dataset and error metrics.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get size
self.fom.n_train = nnz(self.idx_train);
self.fom.n_test = nnz(self.idx_test);

% get dataset metrics
self.fom.inp = get_fom_set(self.var_inp, self.inp, self.idx_train, self.idx_test);
self.fom.out_ref = get_fom_set(self.var_out, self.out_ref, self.idx_train, self.idx_test);
self.fom.out_nrm = get_fom_set(self.var_out, self.out_nrm, self.idx_train, self.idx_test);
self.fom.out_ann = get_fom_set(self.var_out, self.out_ann, self.idx_train, self.idx_test);

% get error metrics
self.fom.err_ann_nrm = get_fom_err(self.var_out, self.out_nrm, self.out_ref, self.idx_train, self.idx_test);
self.fom.err_ann_ref = get_fom_err(self.var_out, self.out_ann, self.out_ref, self.idx_train, self.idx_test);

end

function fom = get_fom_set(var, data, idx_train, idx_test)
% Compute the metrics of a dataset (avg, rms, min, max, std_dev).
%
%    Parameters:
%        var (cell): description of the variables
%        data (struct): dataset to be analyzed
%        idx_train (vector): indices of the samples used for training/fitting
%        idx_test (vector): indices of the samples used for testing
%
%    Returns:
%        fom (struct): figures of merit of the dataset

for i=1:length(var)
    % extract a variable
    name_tmp = var{i}.name;
    vec = data.(name_tmp);
    
    % compute the figures of merit (training and testing)
    fom_tmp.train = get_var_set(vec, idx_train);
    fom_tmp.test = get_var_set(vec, idx_test);
    
    % assign the data
    fom.(name_tmp) = fom_tmp;
end

end


function fom = get_fom_err(var, data_cmp, data_ref, idx_train, idx_test)
% Compute the error between two datasets (avg, rms, min, max, std_dev).
%
%    Parameters:
%        var (cell): description of the variables
%        data_cmp (struct): first dataset (to be compared)
%        data_ref (struct): second dataset (reference)
%        idx_train (vector): indices of the samples used for training/fitting
%        idx_test (vector): indices of the samples used for testing
%
%    Returns:
%        fom (struct): figures of merit of the comparison between the datasets

for i=1:length(var)
    % extract a variable
    name_tmp = var{i}.name;
    var_err_tmp = var{i}.var_err;
    vec_cmp = data_cmp.(name_tmp);
    vec_ref = data_ref.(name_tmp);
    
    % compute the figures of merit (training and testing)
    fom_tmp.train = get_var_err(vec_cmp, vec_ref, idx_train, var_err_tmp);
    fom_tmp.test = get_var_err(vec_cmp, vec_ref, idx_test, var_err_tmp);
    
    % assign the data
    fom.(name_tmp) = fom_tmp;
end

end

function fom = get_var_set(vec, idx)
% Compute the metrics of a variable (avg, rms, min, max, std_dev).
%
%    Parameters:
%        vec (vector): vector with the variable data
%        idx (vector): indices of the samples to be considered
%
%    Returns:
%        fom (struct): figures of merit of the variable

% filter the variable
vec = vec(idx);

% get metrics
fom.vec = vec;
fom.v_avg = mean(vec);
fom.v_rms = rms(vec);
fom.v_std_dev = std(vec);
fom.v_max = max(vec);
fom.v_min = min(vec);

end

function fom = get_var_err(vec_cmp, vec_ref, idx, type)
% Compute the error between two variables (avg, rms, min, max, std_dev, 99% percentile).
%
%    Parameters:
%        vec_cmp (vector): first variable data (to be compared)
%        vec_ref (struct): second variable data (reference)
%        idx (vector): indices of the samples to be considered
%        type (str): type of the error ('abs' or 'rel')
%
%    Returns:
%        fom (struct): figures of merit of the comparison between the variables

% filter the variable
vec_cmp = vec_cmp(idx);
vec_ref = vec_ref(idx);

% compute the error
switch type
    case 'rel'
        vec = abs(vec_cmp-vec_ref)./vec_ref;
    case 'abs'
        vec = abs(vec_cmp-vec_ref);
    otherwise
        error('invalid data')
end

% get metrics
fom.vec = vec;
fom.v_avg = mean(vec);
fom.v_rms = rms(vec);
fom.v_std_dev = std(vec);
fom.v_max = max(vec);
fom.v_min = min(vec);
fom.v_prc_99 = prctile(vec, 99);

end

