function get_ann_manager(ann_type)
% Function for testing the 'AnnManager' class in a systematic way.
%
%    Parameters:
%        ann_type (str): type of the regression method to be used
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_train : %s\n', ann_type)

% get the data
fprintf('get data\n')
ann_input = get_ann_param(ann_type);
[n_sol, inp, out_ref, out_nrm] = get_ann_data();

% create a AnnManager instance 
fprintf('create object\n')
obj = AnnManager(ann_input);

% train the ANN or fit the regression
fprintf('train and fit\n')
obj.train(n_sol, inp, out_ref, out_nrm);

% get the figures of merit of the regression
fprintf('get figures of merit\n')
fom = obj.get_fom();
assert(isstruct(fom), 'invalid fom')

% display and plot the figures of merit of the regression
fprintf('display information\n')
obj.disp();

% dump all the data contained in the object
fprintf('dump\n')
[ann_input, ann_data] = obj.dump();

% delete the object
fprintf('delete\n')
obj.delete();

% used the dump data to reconstruct the object and evaluate the data
fprintf('predict\n')
predict(ann_input, ann_data)

% teardown
fprintf('################## master_train : %s\n', ann_type)

end

function predict(ann_input, ann_data)
% Function for testing the AnnManager class in a systematic way.
%
%    Parameters:
%        ann_input (struct): input data for the AnnManager class
%        ann_data (struct): internal dumped data for the AnnManager class

% create the object and load the dumped data
obj = AnnManager(ann_input);
obj.load(ann_data);

% get the data
[n_sol, inp, out_nrm] = get_ann_predict();

% dummy evaluation with the normalization data, just check the data
[is_valid_tmp, out_nrm_tmp] = obj.predict_nrm(n_sol, inp, out_nrm);
assert(islogical(is_valid_tmp), 'invalid predict data')
assert(isstruct(out_nrm_tmp), 'invalid predict data')

% evaluation of the regression
[is_valid_tmp, out_ann_tmp] = obj.predict_ann(n_sol, inp, out_nrm);
assert(islogical(is_valid_tmp), 'invalid predict data')
assert(isstruct(out_ann_tmp), 'invalid predict data')

% delete the object
obj.delete();

end
