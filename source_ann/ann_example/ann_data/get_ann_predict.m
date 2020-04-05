function [n_sol, inp, out_nrm] = get_ann_predict()
% Generate a dataset for evaluating the regressions (2 inputs, 2 outputs).
%
%    Returns:
%        n_sol (int): number of samples
%        inp (struct): input data
%        out_nrm (struct): output normalization data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% number of samples
n_sol = 100000;

% input data
inp.x_1 = 7.0+3.0.*rand(1, n_sol);
inp.x_2 = 1.0+5.0.*rand(1, n_sol);

% output normalization data: average of the output reference values
out_nrm.y_1 = 12.0.*ones(1, n_sol);
out_nrm.y_2 = 5.0.*ones(1, n_sol);

end