function [ann_input, tag_train] = get_ann_param(ann_type)
% Return the data for the AnnManager class for different regression types.
%
%    Parameters:
%        ann_type (str): type of the regression method to be used
%
%    Returns:
%        ann_input (struct): input data for the AnnManager class
%        tag_train (str): tag to be passed for the training/fitting method of the AnnManager class

% description of the input variables:
%    - name: name of the variable
%    - var_trf: variable transformation applied to the variable (1st scaling)
%         - none: no transformation
%         - rev: '1/x' transformation
%         - log: 'log10(x)' transformation
%         - exp: '10^x' transformation
%         - square: 'x^2' transformation
%         - sqrt: 'sqrt(2)' transformation
%    - var_norm: variable normalization applied to the variable (2nd scaling)
%         - none: no transformation
%         - min_max: scale the variable between 0 and 1
%         - avg: scale the variable with a 0 mean value
%         - std_dev: scale the variable with a 1 standard deviation
%         - avg_std_dev: scale the variable with a 0 mean value and a 1 standard deviation
%    - min: minimum acceptable value
%    - max: maxmimum acceptable value
var_inp = {};
var_inp{end+1} = struct('name', 'x_1', 'var_trf', 'none', 'var_norm', 'min_max', 'min', 0.99.*7.0, 'max', 1.01.*10.0);
var_inp{end+1} = struct('name', 'x_2', 'var_trf', 'none', 'var_norm', 'min_max', 'min', 0.99.*1.0, 'max', 1.01.*6.0);

% description of the output variables:
%    - name: name of the variable
%    - use_nrm: use (or not) the provided normalization output data for scaling (1st scaling)
%    - var_trf: variable transformation applied to the variable (2nd scaling)
%         - none: no transformation
%         - rev: '1/x' transformation
%         - log: 'log10(x)' transformation
%         - exp: '10^x' transformation
%         - square: 'x^2' transformation
%         - sqrt: 'sqrt(2)' transformation
%    - var_norm: variable normalization applied to the variable (3rd scaling)
%         - none: no transformation
%         - min_max: scale the variable between 0 and 1
%         - avg: scale the variable with a 0 mean value
%         - std_dev: scale the variable with a 1 standard deviation
%         - avg_std_dev: scale the variable with a 0 mean value and a 1 standard deviation
%    - var_err: metric for computing the regression accuracy during post-processing
%         - abs: absolute error
%         - rel: relative error
var_out = {};
var_out{end+1} = struct('name', 'y_1', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel');
var_out{end+1} = struct('name', 'y_2', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel');

% control the splitting of the samples between training and testing:
%    - ratio_train: ratio of the samples used for training
%    - n_train_min: minimum number of training samples
%    - n_test_min: minimum number of testing samples
%    - type: method used for selected the testing sample:
%        - with_overlap: all the sample are in the testing dataset
%        - no_overlap: the training sample are not in the testing dataset
split_train_test.ratio_train = 0.5;
split_train_test.n_train_min = 5;
split_train_test.n_test_min = 5;
split_train_test.type = 'no_overlap';

% use (or not) not a separate regression for each output variable
split_var = false;

% control the choice of the regression algoritm
%    - matlab_ann: ANN regression with MATLAB Deep Learning
%    - python_ann: ANN regression with Python Keras and TensorFlow
%    - matlab_lsq: MATLAB regression with nonlinear least-squares
%    - matlab_ga regression with genetic algorithm
ann_info.type = ann_type;

% specific data used by the different algoritms
switch ann_type
    case 'matlab_ann'
         % function for creating the ANN
        ann_info.fct_model = @fct_model;
        
         % function for training the ANN
        ann_info.fct_train = @fct_train;
    case 'python_ann'
        % hostname of the Python ANN server
        ann_info.hostname = 'localhost';
        
        % port of the Python ANN server
        ann_info.port = 10000;
        
        % timeout for Python ANN server requests
        ann_info.timeout = 240;
    case 'matlab_lsq'
        % options for the MATLAB 'lsqnonlin' function
        ann_info.options = struct(...
            'Display', 'off',...
            'FunctionTolerance', 1e-6,...
            'StepTolerance', 1e-6,...
            'MaxIterations', 1e3,...
            'MaxFunctionEvaluations', 10e3);
        
        % control of the fitting parameters
        %    - x0: initial value for the fitting variables
        %    - ub: upper bound for the fitting variables
        %    - lb: lower bound for the fitting variables
        ann_info.x_value = struct(...
            'x0', [0.0 0.0 0.0 0.0 0.0 0.0],...
            'ub', [+20.0 +20.0 +20.0 +20.0 +20.0 +20.0],...
            'lb', [-20.0 -20.0 -20.0 -20.0 -20.0 -20.0]);
        
        % definition of the considered fitting function
        ann_info.fct_fit = @fct_fit;
        
        % definition of the considered error metric
        ann_info.fct_err = @fct_err_vec;
    case 'matlab_ga'
        % options for the MATLAB 'ga' function
        ann_info.options = struct(...
            'Display', 'off',...
            'TolFun', 1e-6,...
            'ConstraintTolerance', 1e-3,...
            'Generations', 40,...
            'PopulationSize', 1000);
        
        % control of the fitting parameters
        %    - n: number of fitting variables
        %    - ub: upper bound for the fitting variables
        %    - lb: lower bound for the fitting variables
        ann_info.x_value = struct(...
            'n', 6,...
            'ub', [+20.0 +20.0 +20.0 +20.0 +20.0 +20.0],...
            'lb', [-20.0 -20.0 -20.0 -20.0 -20.0 -20.0]);
        
        % definition of the considered fitting function
        ann_info.fct_fit = @fct_fit;
        
        % definition of the considered error metric
        ann_info.fct_err = @fct_err_sum;
    otherwise
        error('invalid regression algorithm')
end

% assign the data
ann_input.var_inp = var_inp;
ann_input.var_out = var_out;
ann_input.split_train_test = split_train_test;
ann_input.split_var = split_var;
ann_input.ann_info = ann_info;

% tag to be passed for the training/fitting method (not used in this example) 
tag_train = 'none';

end

function model = fct_model(tag_train, n_sol, n_inp, n_out)
% Function that create and return a MATLAB ANN.
%
%    Parameters:
%        tag_train (str): tag that can be used to control the algorithm
%        n_sol (int): number of samples that will be used for training
%        n_inp (int): number of input variables
%        n_out (int): number of output variables
%
%    Returns:
%        model (model): creating MATLAB ANN

% check the data, the tag and the size information are not used in this example
assert(ischar(tag_train), 'invalid tag_train')
assert(isfinite(n_sol), 'invalid number of samples')
assert(isfinite(n_inp), 'invalid input')
assert(isfinite(n_out), 'invalid output')

% generate and parametrize the ANN
model = fitnet(4);
model.trainParam.min_grad = 1e-8;
model.trainParam.epochs = 300;
model.trainParam.max_fail = 25;
model.divideParam.trainRatio = 0.8;
model.divideParam.valRatio = 0.2;
model.divideParam.testRatio = 0.0;

end

function [model, history] = fct_train(tag_train, model, inp_mat, out_mat)
% Function that train a MATLAB ANN with given data.
%
%    Parameters:
%        tag_train (str): tag that can be used to control the algorithm
%        model (model): MATLAB ANN (to be trained)
%        inp_mat (matrix): input data
%        out_mat (matrix): output data
%
%    Returns:
%        model (model): MATLAB ANN (trained)
%        history (history): training record information

% check the tag, the tag is not used in this example
assert(ischar(tag_train), 'invalid tag_train')

% train the ANN
[model, history] = train(model, inp_mat, out_mat);

end

function out_mat_fit = fct_fit(tag_train, x, inp_mat)
% Function that define the fitting function.
%
%    Parameters:
%        tag_train (str): tag that can be used to control the algorithm
%        x (vector): fitting parameters
%        inp_mat (matrix): input data
%
%    Returns:
%        out_mat_fit (matrix): fitted output data

% check the tag, the tag is not used in this example
assert(ischar(tag_train), 'invalid tag_train');

% extract the input
x_1 = inp_mat(1, :);
x_2 = inp_mat(2, :);

% define the function, a linear fitting is used in this example
y_1 = x(1)+x(2).*x_1+x(3).*x_2;
y_2 = x(4)+x(5).*x_1+x(6).*x_2;

% assemble the output
out_mat_fit = [y_1 ; y_2];

end

function err_vec = fct_err_vec(tag_train, x, inp_mat, out_mat_ref)
% Function that define the error (vector) for the fitting function.
%
%    Parameters:
%        tag_train (str): tag that can be used to control the algorithm
%        x (vector): fitting parameters
%        inp_mat (matrix): input data
%        out_mat_ref (matrix): reference output data
%
%    Returns:
%        err_vec (vector): error vector


% check the tag, the tag is not used in this example
assert(ischar(tag_train), 'invalid tag_train')

% get the fit
out_mat_fit = fct_fit(tag_train, x, inp_mat);

% compute the error
err_vec = out_mat_ref-out_mat_fit;
err_vec = err_vec(:);

end

function err = fct_err_sum(tag_train, x, inp_mat, out_mat_ref)
% Function that define the error (scalar) for the fitting function.
%
%    Parameters:
%        tag_train (str): tag that can be used to control the algorithm
%        x (vector): fitting parameters
%        inp_mat (matrix): input data
%        out_mat_ref (matrix): reference output data
%
%    Returns:
%        err (scalar): error vector

% check the tag, the tag is not used in this example
assert(ischar(tag_train), 'invalid tag_train')

% get the error vector
err_vec = fct_err_vec(tag_train, x, inp_mat, out_mat_ref);

% compute a scalar error metric, sum of square in this example
err = sum(err_vec.^2);

end
