function [n_sol, inp, out_ref, out_nrm] = get_ann_data()
% Generate a dataset for training the regression methods (2 inputs, 2 outputs).
%
%    Returns:
%        n_sol (int): number of samples
%        inp (struct): input data
%        out_ref (struct): output reference data
%        out_nrm (struct): output normalization data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% number of samples
n_sol = 10000;

% input data
inp.x_1 = 7.0+3.0.*rand(1, n_sol);
inp.x_2 = 1.0+5.0.*rand(1, n_sol);

% output reference data: linear function and random noise
out_ref.y_1 = inp.x_1+inp.x_2+0.1.*rand(1, n_sol);
out_ref.y_2 = inp.x_1-inp.x_2+0.1.*rand(1, n_sol);

% output normalization data: average of the output reference values
out_nrm.y_1 = 12.0.*ones(1, n_sol);
out_nrm.y_2 = 5.0.*ones(1, n_sol);

end