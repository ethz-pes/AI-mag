function ann_input = get_dataset_param_train(model_type, ann_type)
% Return the data required for the ANN/regression.
%
%    Define the variables used for the regression.
%    Define the splitting between the training and test sets.
%    Control the choice of the regression algoritm and defines the parameters.
%
%    Parameters:
%        model_type (str): name of the physics to be solved ('mf' or 'ht')
%        ann_type (str): method for the ANN/regression ('matlab_ann' or 'python_ann')
%    Returns:
%        ann_input (struct): input data for the 'AnnManager' class
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check the physics type
assert(any(strcmp(model_type, {'ht', 'mf'})), 'invalid physics type')

% description of the input variables:
%    - name: name of the variable
%    - var_trf: variable transformation applied to the variable (1st scaling)
%        - 'none': no transformation
%        - 'rev': '1/x' transformation
%        - 'log': 'log10(x)' transformation
%        - 'exp': '10^x' transformation
%        - 'square': 'x^2' transformation
%        - 'sqrt': 'sqrt(2)' transformation
%    - var_norm: variable normalization applied to the variable (2nd scaling)
%        - 'none': no transformation
%        - 'min_max': scale the variable between 0 and 1
%        - 'avg': scale the variable with a 0 mean value
%        - 'std_dev': scale the variable with a 1 standard deviation
%        - 'avg_std_dev': scale the variable with a 0 mean value and a 1 standard deviation
%    - min: minimum acceptable value
%    - max: maxmimum acceptable value
var_inp = {};
if any(strcmp(model_type, {'ht', 'mf'}))
    % ratio between the height and width and the winding window
    var_inp{end+1} = struct('name', 'fact_window', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*2.0, 'max', 1.01.*4.0);
    
    % ratio between the length and width of the core cross section
    var_inp{end+1} = struct('name', 'fact_core', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*1.0, 'max', 1.01.*3.0);
    
    % ratio between the core cross section and the winding window cross section
    var_inp{end+1} = struct('name', 'fact_core_window', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.3, 'max', 1.01.*3.0);
    
    % ratio between the air gap length and the square root of the core cross section
    var_inp{end+1} = struct('name', 'fact_gap', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.005, 'max', 1.01.*0.3);
    
    % inductor box volume
    var_inp{end+1} = struct('name', 'V_box', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*10e-6, 'max', 1.01.*1000e-6);
end
if strcmp(model_type, 'mf')
    % ratio between the inductor current and the saturation current
    var_inp{end+1} = struct('name', 'r_sat', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.001, 'max', 1.01.*1.0);
    
    % permeability of the core for the FEM simulation
    var_inp{end+1} = struct('name', 'mu_core', 'var_trf', 'none', 'var_norm', 'min_max', 'min', 0.99.*1500.0, 'max', 1.01.*3000.0);
    
    % beta (Steinmetz parameter) of the core for the FEM simulation
    var_inp{end+1} = struct('name', 'beta_core', 'var_trf', 'none', 'var_norm', 'min_max', 'min', 0.99.*2.0, 'max', 1.01.*2.8);
end
if strcmp(model_type, 'ht')
    % total losses (core and winding) divided by the area of the boxed inductor
    var_inp{end+1} = struct('name', 'p_surface', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.001e4, 'max', 1e4);
    
    % ratio between the winding losses and core losses
    var_inp{end+1} = struct('name', 'r_winding_core', 'var_trf', 'log', 'var_norm', 'min_max', 'min', 0.99.*0.02, 'max', 1.01.*50.0);
    
    % convection coefficient reference value
    var_inp{end+1} = struct('name', 'h_convection', 'var_trf', 'none', 'var_norm', 'min_max', 'min', 0.99.*15.0, 'max', 1.01.*30.0);
    
    % ambient temperature
    var_inp{end+1} = struct('name', 'T_ambient', 'var_trf', 'none', 'var_norm', 'min_max', 'min', 0.99.*25.0, 'max', 1.01.*65.0);
end

% description of the output variables:
%    - name: name of the variable
%    - use_nrm: use (or not) the provided normalization output data for scaling (1st scaling)
%    - var_trf: variable transformation applied to the variable (2nd scaling)
%        - 'none': no transformation
%        - 'rev': '1/x' transformation
%        - 'log': 'log10(x)' transformation
%        - 'exp': '10^x' transformation
%        - 'square': 'x^2' transformation
%        - 'sqrt': 'sqrt(2)' transformation
%    - var_norm: variable normalization applied to the variable (3rd scaling)
%        - 'none': no transformation
%        - 'min_max': scale the variable between 0 and 1
%        - 'avg': scale the variable with a 0 mean value
%        - 'std_dev': scale the variable with a 1 standard deviation
%        - 'avg_std_dev': scale the variable with a 0 mean value and a 1 standard deviation
%    - var_err: metric for computing the regression accuracy during post-processing
%        - 'abs_abs': absolute error (absolute value)
%        - 'abs_sign': absolute error (with sign)
%        - 'rel_abs': relative error (absolute value)
%        - 'rel_sign': relative error (with sign)
var_out = {};
if strcmp(model_type, 'mf')
    % inductance (for a single turn)
    var_out{end+1} = struct('name', 'L_norm', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
    
    % quasi-RMS flux density, integral of B^beta, normalized for one turn and 1A, for the core losses
    var_out{end+1} = struct('name', 'B_norm', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
    
    % RMS current density, integral of J^2, normalized for one turn and 1A, for the LF winding losses
    var_out{end+1} = struct('name', 'J_norm', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
    
    % RMS magnetic density, integral of H^2, normalized for one turn and 1A, for the HF winding losses
    var_out{end+1} = struct('name', 'H_norm', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
end
if strcmp(model_type, 'ht')
    % maximum temperature elevation of the core, for the thermal limit
    var_out{end+1} = struct('name', 'dT_core_max', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
    
    % average temperature elevation of the core, for the losses
    var_out{end+1} = struct('name', 'dT_core_avg', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
    
    % maximum temperature elevation of the winding, for the thermal limit
    var_out{end+1} = struct('name', 'dT_winding_max', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
    
    % average temperature elevation of the winding, for the losses
    var_out{end+1} = struct('name', 'dT_winding_avg', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
    
    % maximum temperature elevation of the insulation, for the thermal limit
    var_out{end+1} = struct('name', 'dT_iso_max', 'use_nrm', true, 'var_trf', 'none', 'var_norm', 'min_max', 'var_err', 'rel_abs');
end

% control the splitting of the samples between training and testing:
%    - ratio_train: ratio of the samples used for training
%    - n_train_min: minimum number of training samples
%    - n_test_min: minimum number of testing samples
%    - type: method used for selected the testing sample:
%        - 'with_overlap': all the sample are in the testing dataset
%        - 'no_overlap': the training sample are not in the testing dataset
split_train_test.ratio_train = 0.8;
split_train_test.n_train_min = 5;
split_train_test.n_test_min = 5;
split_train_test.type = 'no_overlap';

% use (or not) not a separate regression for each output variable
split_var = false;

% control the choice of the regression algoritm
%    - 'matlab_ann': ANN regression with MATLAB Deep Learning
%    - 'python_ann': ANN regression with Python Keras and TensorFlow
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
        
        % tag to be passed for the training/fitting method (not used in this example)
        ann_info.tag_train = 'none';
    otherwise
        error('invalid evaluation method')
end

% assign the data
ann_input.var_inp = var_inp;
ann_input.var_out = var_out;
ann_input.split_train_test = split_train_test;
ann_input.split_var = split_var;
ann_input.ann_info = ann_info;

end

function model = fct_model(n_sol, n_inp, n_out)
% Function that create and return a MATLAB ANN.
%
%    Parameters:
%        n_sol (int): number of samples that will be used for training
%        n_inp (int): number of input variables
%        n_out (int): number of output variables
%
%    Returns:
%        model (model): creating MATLAB ANN

% check the data, the size information are not used in this example
assert(isfinite(n_sol), 'invalid number of samples')
assert(isfinite(n_inp), 'invalid number of inputs')
assert(isfinite(n_out), 'invalid number of outputs')

% generate and parametrize the ANN
model = fitnet([10 10]);
model.trainParam.min_grad = 1e-8;
model.trainParam.epochs = 200;
model.trainParam.max_fail = 25;
model.divideParam.trainRatio = 0.8;
model.divideParam.valRatio = 0.2;
model.divideParam.testRatio = 0.0;

end

function [model, history] = fct_train(model, inp_mat, out_mat)
% Function that train a MATLAB ANN with given data.
%
%    Parameters:
%        model (model): MATLAB ANN (to be trained)
%        inp_mat (matrix): input data
%        out_mat (matrix): output data
%
%    Returns:
%        model (model): MATLAB ANN (trained)
%        history (history): training record information

% train the ANN
[model, history] = train(model, inp_mat, out_mat);

end