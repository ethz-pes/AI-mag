function master_train(file_ann, file_assemble, ann_input)
% Create a ANN/regression and train/fit it with the assembled simulation data.
%
%    Load the simulation data.
%    Train/fit the ANN/regression with the data.
%    Obtain, display, and plot the dataset and error metrics.
%
%    This function requires a running ANN Python Server (if this regression method is used):
%        - run 'run_ann_server.py' with Python
%        - use 'start_python_ann_server.bat' on MS Windows
%        - use 'start_python_ann_server.sh' on Linux
%
%    Parameters:
%        file_ann (str): path of the file to be written with the ANN/regression data
%        file_assemble (str): path of the file with the assembled data
%        ann_input (struct): input data for the ANN/regression (variables definition and algoritm parameters)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
fprintf('################## master_train\n')

% load the simulation data
fprintf('load\n')
data_tmp = load(file_assemble);
n_sol = data_tmp.n_sol;
inp = data_tmp.inp;
out_fem = data_tmp.out_fem;
out_approx = data_tmp.out_approx;
model_type = data_tmp.model_type;
file_model = data_tmp.file_model;

% init the ANN/regression interface
fprintf('create ann\n')
obj = AnnManager(ann_input);

% train/fit the ANN/regression with the data
fprintf('train ann\n')
obj.train(n_sol, inp, out_fem, out_approx);

% get the figures of merit of the regression
fom = obj.get_fom();

% display and plot the data and error metrics
obj.disp();

% dump all the data from the ANN/regression interface
fprintf('dump ann\n')
[ann_input, ann_data] = obj.dump();

% close the ANN/regression interface
fprintf('delete ann\n')
obj.delete();

% save data
fprintf('save\n')
save(file_ann, '-v7.3', 'ann_input', 'ann_data', 'fom', 'model_type', 'file_model')

% teardown
fprintf('################## master_train\n')

end
