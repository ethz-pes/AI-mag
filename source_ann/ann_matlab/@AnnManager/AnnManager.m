classdef AnnManager < handle
    % Interface for regression/fitting, meant for ANN.
    %
    %    Offer many functionalities for ANN regression:
    %        - Advanced scaling, variable transformation and normalization
    %        - Checking bounds on the datasets
    %        - Training/fitting the data
    %        - Getting and displaying error metrics
    %        - Evaluating the fit for given input data
    %        - Dumping and reloading the data stored in the object
    %
    %    Can use different regression engine with the abtract class ann_engine.AnnEngineAbstract.
    %    This class is primarily meant for regression with ANN but is also useful for other methods.
    %
    %    Several regression methods are implemented:
    %        - matlab_ann: ANN regression with MATLAB Deep Learning (ann_engine.AnnEngineMatlabAnn)
    %        - python_ann: ANN regression with Python Keras and TensorFlow (ann_engine.AnnEnginePythonAnn)
    %        - matlab_lsq: MATLAB regression with nonlinear least-squares (ann_engine.AnnEngineMatlabLsq)
    %        - matlab_ga regression with genetic algorithm (ann_engine.AnnEngineMatlabGa)
    
    %% properties / immutable
    properties (SetAccess = immutable, GetAccess = public)
        var_inp % cell: description of the input variables
        var_out % cell: description of the output variables
        split_train_test % struct: control the splitting of the samples between training and testing
        split_var % logical: use (or not) not a separate regression for each output variable
        ann_info % struct: control the choice of the regression algoritm
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
        ann_engine_obj % ann_engine.AnnEngineAbstract: manage the selected regression algorithm
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
        
        function train(self, n_sol, inp, out_ref, out_nrm)
            % Train/fit the regression with the provided data.
            %
            %    Set the data.
            %    Start and init the regression engine.
            %    Do not make any fitting.
            %
            %    Parameters:
            %        ann_input (struct): input data (variables definition and algoritm parameters)
            
            
%             n_sol % int: number of samples
%         inp % struct: input data
%         out_ref % struct: output reference data
%         out_nrm % struct: output normalization data
%         out_ann % struct: output ANN/fitted data

            
            
            % assign
            self.n_sol = n_sol;
            self.inp = inp;
            self.out_ref = out_ref;
            self.out_nrm = out_nrm;
            
            % check range
            is_valid = self.get_range_inp(self.inp);
            assert(all(is_valid==true), 'invalid inp')
            
            % split the data
            self.get_idx_split();
            
            % extract training data
            inp_train = AnnManager.get_struct_idx(self.inp, self.idx_train);
            out_ref_train = AnnManager.get_struct_idx(self.out_ref, self.idx_train);
            out_nrm_train = AnnManager.get_struct_idx(self.out_nrm, self.idx_train);
            
            % get normalization
            self.get_norm_var_inp();
            self.get_norm_var_out();
            
            % get training matrices
            inp_mat_train = self.get_scale_inp(inp_train);
            out_mat_train = self.get_scale_out(out_ref_train, out_nrm_train);
            
            % train the network
            self.train_engine(inp_mat_train, out_mat_train);
            self.load_engine();
            
            % run the network
            inp_mat = self.get_scale_inp(self.inp);
            out_mat = self.predict_engine(inp_mat);
            
            % unscale the result
            self.out_ann = self.get_unscale_out(self.out_nrm, out_mat);
            
            % fet fom
            self.get_fom_train();
            
            % check set
            AnnManager.check_set(self.n_sol, self.var_inp, self.inp)
            AnnManager.check_set(self.n_sol, self.var_out, self.out_ref)
            AnnManager.check_set(self.n_sol, self.var_out, self.out_nrm)
            AnnManager.check_set(self.n_sol, self.var_out, self.out_ann)
            self.is_train = true;
        end
        
        function disp(self)
            AnnManager.disp_data('var_inp', self.var_inp);
            AnnManager.disp_data('var_out', self.var_out);
            AnnManager.disp_data('split_train_test', self.split_train_test);
            AnnManager.disp_data('split_var', self.split_var);
            AnnManager.disp_data('ann_info', self.ann_info);
            AnnManager.disp_data('is_train', self.is_train);
            
            if self.is_train==true
                AnnManager.disp_data('n_sol', self.n_sol);
                self.disp_fom_train()
            end
        end
        
        function [is_valid_tmp, out_nrm_tmp] = predict_nrm(self, n_sol_tmp, inp_tmp, out_nrm_tmp)
            % check state
            assert(self.is_train==true, 'invalid state')
            
            % check validity
            is_valid_tmp = self.get_range_inp(inp_tmp);
            
            % check set
            AnnManager.check_set(n_sol_tmp, self.var_inp, inp_tmp)
            AnnManager.check_set(n_sol_tmp, self.var_out, out_nrm_tmp)
        end
        
        function [is_valid_tmp, out_ann_tmp] = predict_ann(self, n_sol_tmp, inp_tmp, out_nrm_tmp)
            % check state
            assert(self.is_train==true, 'invalid state')
            
            % run the network
            inp_mat_tmp = self.get_scale_inp(inp_tmp);
            out_mat_tmp = self.predict_engine(inp_mat_tmp);
            
            % unscale the result
            out_ann_tmp = self.get_unscale_out(out_nrm_tmp, out_mat_tmp);
            
            % check validity
            is_valid_tmp = self.get_range_inp(inp_tmp);
            
            % check set
            AnnManager.check_set(n_sol_tmp, self.var_inp, inp_tmp)
            AnnManager.check_set(n_sol_tmp, self.var_out, out_nrm_tmp)
            AnnManager.check_set(n_sol_tmp, self.var_out, out_ann_tmp)
        end
        
        function delete(self)
            if self.is_train==true
                self.unload_engine();
            end
        end
    end
    
    %% private
    methods (Access = private)
        function init_engine(self)
            % Init the regression engine.
            %
            %    Extract the regression parameters.
            %    Create an instance of ann_engine.AnnEngineAbstract.

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
            if self.split_var==true
                self.ann_data = {};
                for i=1:length(self.var_out)
                    [model, history] = self.ann_engine_obj.train(inp_mat, out_mat(i,:));
                    self.ann_data{i} = struct('model', model, 'history', history, 'name', ['ann_' num2str(i)]);
                end
            else
                [model, history] = self.ann_engine_obj.train(inp_mat, out_mat);
                self.ann_data = struct('model', model, 'history', history, 'name', 'ann');
            end
        end
        
        function load_engine(self)
            if self.split_var==true
                for i=1:length(self.var_out)
                    model = self.ann_data{i}.model;
                    history = self.ann_data{i}.history;
                    name = self.ann_data{i}.name;
                    self.ann_engine_obj.load(name, model, history)
                end
            else
                model = self.ann_data.model;
                history = self.ann_data.history;
                name = self.ann_data.name;
                self.ann_engine_obj.load(name, model, history)
            end
        end
        
        function unload_engine(self)
            if self.split_var==true
                for i=1:length(self.var_out)
                    name = self.ann_data{i}.name;
                    self.ann_engine_obj.unload(name)
                end
            else
                name = self.ann_data.name;
                self.ann_engine_obj.unload(name)
            end
        end
        
        function out_mat = predict_engine(self, in_mat)
            if self.split_var==true
                for i=1:length(self.var_out)
                    name = self.ann_data{i}.name;
                    out_mat(i,:) = self.ann_engine_obj.predict(name, in_mat);
                end
            else
                name = self.ann_data.name;
                out_mat = self.ann_engine_obj.predict(name, in_mat);
            end
        end
    end
    
    %% static
    methods (Static, Access = private)
        check_set(n_sol, var, data)
        disp_data(name, data)
        data = get_struct_idx(data, idx)
        norm_param = get_var_norm_param(x, type)
        y = get_var_norm_value(x, norm_param, scale_unscale)
        y = get_var_trf(x, type, scale_unscale)
    end
    
    %% private
    methods (Access = private)
        is_valid = get_range_inp(self, inp)
        get_idx_split(self)
        get_norm_var_inp(self)
        get_norm_var_out(self)
        inp_mat = get_scale_inp(self, inp)
        out_mat = get_scale_out(self, out_ref, out_nrm)
        out_ann = get_unscale_out(self, out_nrm, out_mat)
        disp_set_data(self, tag, var, data)
        disp_set_error(self, tag, var, data_cmp, data_ref)
    end
end
