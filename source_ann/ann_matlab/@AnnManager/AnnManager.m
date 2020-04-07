classdef AnnManager < handle
    % Interface for regression/fitting, meant for ANN.
    %
    %    Offer many functionalities for ANN regression:
    %        - Scaling, variable transformation and normalization
    %        - Checking bounds on the datasets
    %        - Training/fitting the data
    %        - Displaying and plotting error metrics
    %        - Evaluating the fit for given input data
    %        - Dumping and reloading the data stored in the object
    %
    %    Can use different regression engine with the abtract class 'AnnEngineAbstract'.
    %    This class is primarily meant for regression with ANN but is also useful for other methods.
    %
    %    Several regression methods are implemented:
    %        - 'matlab_ann': ANN regression with MATLAB Deep Learning ('AnnEngineMatlabAnn')
    %        - 'python_ann': ANN regression with Python Keras and TensorFlow ('AnnEnginePythonAnn')
    %        - 'matlab_lsq': MATLAB regression with nonlinear least-squares, for benchmark with ANN ('AnnEngineMatlabLsq')
    %        - 'matlab_ga': regression with genetic algorithm, for benchmark with ANN ('AnnEngineMatlabGa')
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

    %% properties / immutable
    properties (SetAccess = immutable, GetAccess = public)
        var_inp % cell: description of the input variables
        var_out % cell: description of the output variables
        split_train_test % struct: control the splitting of the samples between training and testing
        split_var % logical: use (or not) not a separate regression for each output variable
        ann_info % struct: control the choice of the regression algoritm and defines the parameters
    end
    
    %% properties / private
    properties (SetAccess = private, GetAccess = public)
        n_sol % int: number of samples
        inp % struct: input data
        out_ref % struct: output reference data
        out_nrm % struct: output normalization data
        out_ann % struct: output ANN/fitted data
        norm_param_inp % cell: normalization data for the input data
        norm_param_out % cell: normalization data for the output data
        idx_train % vector: indices of the samples used for training/fitting
        idx_test % vector: indices of the samples used for testing
        is_train % logical: if the training/fitting has been done (or not)
        ann_data % struct: data of the ANN or fitting algorithm
        fom % struct: figures of merit for the regression quality
        ann_engine_obj % AnnEngineAbstract: manage the selected regression algorithm
    end
    
    %% public
    methods (Access = public)
        function self = AnnManager(ann_input)
            % Constructor.
            %
            %    Set the data.
            %    Start and init the regression engine.
            %    Do not make any fitting.
            %
            %    Parameters:
            %        ann_input (struct): input data (variables definition and algoritm parameters)
            
            % assign input
            self.var_inp = ann_input.var_inp;
            self.var_out = ann_input.var_out;
            self.split_train_test = ann_input.split_train_test;
            self.split_var = ann_input.split_var;
            self.ann_info = ann_input.ann_info;
            
            % the training/fitting is not yet done
            self.is_train = false;
            
            % init the regression engine
            self.init_engine();
        end
        
        function [ann_input, ann_data] = dump(self)
            % Dump all the data contained in the object.
            %
            %    Returns:
            %        ann_input (struct): input data (variables definition and algoritm parameters)
            %        ann_data (struct): training/fitting data (dataset, splitting, and normalization)
            
            % set the input data (data given to the constructor)
            ann_input.var_inp = self.var_inp;
            ann_input.var_out = self.var_out;
            ann_input.split_train_test = self.split_train_test;
            ann_input.split_var = self.split_var;
            ann_input.ann_info = self.ann_info;
            
            % set the training/fitting data
            ann_data.n_sol = self.n_sol;
            ann_data.inp = self.inp;
            ann_data.out_ref = self.out_ref;
            ann_data.out_nrm = self.out_nrm;
            ann_data.out_ann = self.out_ann;
            ann_data.norm_param_inp = self.norm_param_inp;
            ann_data.norm_param_out = self.norm_param_out;
            ann_data.idx_train = self.idx_train;
            ann_data.idx_test = self.idx_test;
            ann_data.is_train = self.is_train;
            ann_data.ann_data = self.ann_data;
            ann_data.fom = self.fom;
        end
        
        function load(self, ann_data)
            % Load the data from a dump.
            %
            %    Parameters:
            %        ann_data (struct): training/fitting data (dataset, splitting, and normalization)
            
            % set the training/fitting data
            self.n_sol = ann_data.n_sol;
            self.inp = ann_data.inp;
            self.out_ref = ann_data.out_ref;
            self.out_nrm = ann_data.out_nrm;
            self.out_ann = ann_data.out_ann;
            self.norm_param_inp = ann_data.norm_param_inp;
            self.norm_param_out = ann_data.norm_param_out;
            self.idx_train = ann_data.idx_train;
            self.idx_test = ann_data.idx_test;
            self.is_train = ann_data.is_train;
            self.ann_data = ann_data.ann_data;
            self.fom = ann_data.fom;
            
            % if required, load the data to the regression engine
            if self.is_train==true
                self.load_engine();
            end
        end
        
        function fom = get_fom(self)
            % Get the figures of merit of the regression (if available).
            %
            %    Returns:
            %        fom (struct): : figures of merit for the regression quality
            
            assert(self.is_train==true, 'invalid state')
            fom = self.fom;
        end
        
        function disp(self)
            % Display and plot the data of the object.
            %
            %    Display the input data.
            %    Display and plot the input and output datasets.
            %    This method override a standard MATLAB method.
            
            % display data
            AnnManager.disp_data('var_inp', self.var_inp);
            AnnManager.disp_data('var_out', self.var_out);
            AnnManager.disp_data('split_train_test', self.split_train_test);
            AnnManager.disp_data('split_var', self.split_var);
            AnnManager.disp_data('ann_info', self.ann_info);
            AnnManager.disp_data('is_train', self.is_train);
            
            % display input and out datasets
            if self.is_train==true
                AnnManager.disp_data('n_sol', self.n_sol);
                self.disp_fom_train()
            end
        end
        
        function delete(self)
            % Delete the class, unload the data from the engine.
            %
            %    Should be called when the object is not anymore required.
            %    This method override a standard MATLAB method.
            
            if self.is_train==true
                self.unload_engine();
            end
        end
        
        function train(self, n_sol, inp, out_ref, out_nrm)
            % Train/fit the regression with the provided data.
            %
            %    Scale the data.
            %    Make the regression.
            %    Compute the error metrics.
            %
            %    Parameters:
            %        n_sol (int): number of samples
            %        inp (struct): input data
            %        out_ref (struct): output reference data
            %        out_nrm (struct): output normalization data
            
            % assign the data
            self.n_sol = n_sol;
            self.inp = inp;
            self.out_ref = out_ref;
            self.out_nrm = out_nrm;
            
            % check the range, the provided data should be valid
            is_valid = self.get_range_inp(self.inp);
            assert(all(is_valid==true), 'invalid inp')
            
            % split the data between training and test set
            self.get_idx_split();
            
            % extract training data
            inp_train = AnnManager.get_struct_idx(self.inp, self.idx_train);
            out_ref_train = AnnManager.get_struct_idx(self.out_ref, self.idx_train);
            out_nrm_train = AnnManager.get_struct_idx(self.out_nrm, self.idx_train);
            
            % get normalization over the training data
            self.norm_param_inp = self.get_norm_var_inp(inp_train);
            self.norm_param_out = self.get_norm_var_out(out_ref_train, out_nrm_train);
            
            % scale, transform, normalize, and cast to matrix
            inp_mat_train = self.get_scale_inp(inp_train);
            out_mat_train = self.get_scale_out(out_ref_train, out_nrm_train);
            
            % train/fit with the training set
            self.train_engine(inp_mat_train, out_mat_train);
            
            % load the regression into the engine
            self.load_engine();
            
            % run the regression for all the data (training and test)
            inp_mat = self.get_scale_inp(self.inp);
            out_mat = self.predict_engine(inp_mat);
            
            % unscale the output
            self.out_ann = self.get_unscale_out(self.out_nrm, out_mat);
            
            % compute the figures of merit for the errors
            self.get_fom_train();
            
            % check the datasets
            AnnManager.check_set(self.n_sol, self.var_inp, self.inp)
            AnnManager.check_set(self.n_sol, self.var_out, self.out_ref)
            AnnManager.check_set(self.n_sol, self.var_out, self.out_nrm)
            AnnManager.check_set(self.n_sol, self.var_out, self.out_ann)
            
            % now the regression are done, set the flag
            self.is_train = true;
        end
        
        
        function [is_valid_tmp, out_nrm_tmp] = predict_nrm(self, n_sol_tmp, inp_tmp, out_nrm_tmp)
            % Dummy evaluation: check the data and return the provided normalization data.
            %
            %    Parameters:
            %        n_sol_tmp (int): number of samples to evaluate
            %        inp_tmp (struct): input data to evaluate
            %        out_nrm_tmp (struct): output normalization data to to evaluate
            %
            %    Returns:
            %        is_valid_tmp (vector): validity of the different evaluated samples
            %        out_nrm_tmp (struct): evaluated data (equal to the provided normalization data)
            
            % the regression has to be already trained/fitted
            assert(self.is_train==true, 'invalid state')
            
            % check validity of the input data
            is_valid_tmp = self.get_range_inp(inp_tmp);
            
            % check the datasets
            AnnManager.check_set(n_sol_tmp, self.var_inp, inp_tmp)
            AnnManager.check_set(n_sol_tmp, self.var_out, out_nrm_tmp)
        end
        
        function [is_valid_tmp, out_ann_tmp] = predict_ann(self, n_sol_tmp, inp_tmp, out_nrm_tmp)
            % Regression evaluation: check the data, evaluate the regression, and return the fitted data.
            %
            %    Parameters:
            %        n_sol_tmp (int): number of samples to evaluate
            %        inp_tmp (struct): input data to evaluate
            %        out_nrm_tmp (struct): output normalization data to to evaluate
            %
            %    Returns:
            %        is_valid_tmp (vector): validity of the different evaluated samples
            %        out_nrm_tmp (struct): evaluated data (obtained with the regression engine)
            
            % the regression has to be already trained/fitted
            assert(self.is_train==true, 'invalid state')
            
            % scale the input, run the regression, and unscale the output
            inp_mat_tmp = self.get_scale_inp(inp_tmp);
            out_mat_tmp = self.predict_engine(inp_mat_tmp);
            out_ann_tmp = self.get_unscale_out(out_nrm_tmp, out_mat_tmp);
            
            % check validity of the input data
            is_valid_tmp = self.get_range_inp(inp_tmp);
            
            % check the datasets
            AnnManager.check_set(n_sol_tmp, self.var_inp, inp_tmp)
            AnnManager.check_set(n_sol_tmp, self.var_out, out_nrm_tmp)
            AnnManager.check_set(n_sol_tmp, self.var_out, out_ann_tmp)
        end
    end
    
    %% private
    methods (Access = private)
        function init_engine(self)
            % Init the regression engine.
            %
            %    Extract the regression parameters.
            %    Create an instance of 'AnnEngineAbstract'.
            
            switch self.ann_info.type
                case 'matlab_ann'
                    fct_model = self.ann_info.fct_model;
                    fct_train = self.ann_info.fct_train;
                    self.ann_engine_obj = ann_engine.AnnEngineMatlabAnn(fct_model, fct_train);
                case 'matlab_lsq'
                    options = self.ann_info.options;
                    x_value = self.ann_info.x_value;
                    fct_fit = self.ann_info.fct_fit;
                    fct_err = self.ann_info.fct_err;
                    self.ann_engine_obj = ann_engine.AnnEngineMatlabLsq(fct_fit, fct_err, x_value, options);
                case 'matlab_ga'
                    options = self.ann_info.options;
                    x_value = self.ann_info.x_value;
                    fct_fit = self.ann_info.fct_fit;
                    fct_err = self.ann_info.fct_err;
                    self.ann_engine_obj = ann_engine.AnnEngineMatlabGa(fct_fit, fct_err, x_value, options);
                case 'python_ann'
                    hostname = self.ann_info.hostname;
                    port = self.ann_info.port;
                    timeout = self.ann_info.timeout;
                    tag_train = self.ann_info.tag_train;
                    self.ann_engine_obj = ann_engine.AnnEnginePythonAnn(hostname, port, timeout, tag_train);
                otherwise
                    error('invalid engine')
            end
        end
        
        function train_engine(self, inp_mat, out_mat)
            % Train/fit the regression with given data with the engine.
            %
            %    Make the regression.
            %    Store the resulting data into the memory.
            %    Do not load the data into the object.
            %
            %    Parameters:
            %        inp_mat (matrix): matrix with the input data
            %        out_mat (matrix): matrix with the output data
            
            if self.split_var==true
                % separate regression for each output variable
                self.ann_data = {};
                for i=1:length(self.var_out)
                    [model, history] = self.ann_engine_obj.train(inp_mat, out_mat(i,:));
                    self.ann_data{i} = struct('model', model, 'history', history, 'name', ['ann_' num2str(i)]);
                end
            else
                % single regression with all the output at once
                [model, history] = self.ann_engine_obj.train(inp_mat, out_mat);
                self.ann_data = struct('model', model, 'history', history, 'name', 'ann');
            end
        end
        
        function load_engine(self)
            % Load the trained/fitted regression in the engine.
            %
            %    Get the data from the object.
            %    Load the data into the engine.
            
            if self.split_var==true
                % separate regression for each output variable
                for i=1:length(self.var_out)
                    model = self.ann_data{i}.model;
                    history = self.ann_data{i}.history;
                    name = self.ann_data{i}.name;
                    self.ann_engine_obj.load(name, model, history)
                end
            else
                % single regression with all the output at once
                model = self.ann_data.model;
                history = self.ann_data.history;
                name = self.ann_data.name;
                self.ann_engine_obj.load(name, model, history)
            end
        end
        
        function unload_engine(self)
            % Remove a trained/fitted regression from the engine.
            %
            %    Remove the regression.
            %    Do not store the data in the object.
            
            if self.split_var==true
                % separate regression for each output variable
                for i=1:length(self.var_out)
                    name = self.ann_data{i}.name;
                    self.ann_engine_obj.unload(name)
                end
            else
                % single regression with all the output at once
                name = self.ann_data.name;
                self.ann_engine_obj.unload(name)
            end
        end
        
        function out_mat = predict_engine(self, in_mat)
            % Evaluate a regression with given input data with the engine.
            %
            %    Evaluate the regression.
            %    The regression has to be loaded in the engine.
            %
            %    Parameters:
            %        inp_mat (matrix): matrix with the input data
            %
            %    Returns:
            %        out_mat (matrix): matrix with the output data
            
            if self.split_var==true
                % separate regression for each output variable
                for i=1:length(self.var_out)
                    name = self.ann_data{i}.name;
                    out_mat(i,:) = self.ann_engine_obj.predict(name, in_mat);
                end
            else
                % single regression with all the output at once
                name = self.ann_data.name;
                out_mat = self.ann_engine_obj.predict(name, in_mat);
            end
        end
    end
    
    %% static / external
    methods (Static, Access = private)
        check_set(n_sol, var, data)
        disp_data(name, data)
        data = get_struct_idx(data, idx)
        norm_param = get_var_norm_param(x, type)
        y = get_var_norm_value(x, norm_param, scale_unscale)
        y = get_var_trf(x, type, scale_unscale)
    end
    
    %% private / external
    methods (Access = private)
        is_valid = get_range_inp(self, inp)
        get_idx_split(self)
        norm_param = get_norm_var_inp(self, inp_train);
        norm_param = get_norm_var_out(self, out_ref_train, out_nrm_train);
        inp_mat = get_scale_inp(self, inp)
        out_mat = get_scale_out(self, out_ref, out_nrm)
        out_ann = get_unscale_out(self, out_nrm, out_mat)
        disp_set_data(self, tag, var, data)
        disp_set_error(self, tag, var, data_cmp, data_ref)
    end
end
