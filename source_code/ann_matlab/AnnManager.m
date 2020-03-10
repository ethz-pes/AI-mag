classdef AnnManager < handle
    %% properties
    properties (SetAccess = immutable, GetAccess = public)
        var_inp
        var_out
        split_train_test
        split_var
        ann_info
    end
    
    properties (SetAccess = private, GetAccess = public)
        n_sol
        inp
        out_ref
        out_nrm
        out_ann
        norm_param_inp
        norm_param_out
        idx_train
        idx_test
        is_train
        ann_data
        
        ann_engine_obj
    end
    
    %% init
    methods (Access = public)
        function self = AnnManager(ann_input)            
            % assign input
            self.var_inp = ann_input.var_inp;
            self.var_out = ann_input.var_out;
            self.split_train_test = ann_input.split_train_test;
            self.split_var = ann_input.split_var;
            self.ann_info = ann_input.ann_info;
            
            % set training
            self.is_train = false;
            
            % connect engine
            self.init_engine();
        end
        
        function [ann_input, ann_data] = dump(self)
            % ann_input data
            ann_input.var_inp = self.var_inp;
            ann_input.var_out = self.var_out;
            ann_input.split_train_test = self.split_train_test;
            ann_input.split_var = self.split_var;
            ann_input.ann_info = self.ann_info;
            
            % properties
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
        end
        
        function load(self, ann_data)
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
            
            % load the engine
            if self.is_train==true
                self.load_engine();
            end
        end
        
        function train(self, tag_train, n_sol, inp, out_ref, out_nrm)
            % assign
            self.n_sol = n_sol;
            self.inp = inp;
            self.out_ref = out_ref;
            self.out_nrm = out_nrm;
                        
            % check range
            is_valid = get_range_inp(self.var_inp, self.inp);
            assert(all(is_valid==true), 'invalid inp')
            
            % split the data
            [self.idx_train, self.idx_test] = get_idx_split(self.n_sol, self.split_train_test);
            
            % extract training data
            inp_train = get_struct_idx(self.inp, self.idx_train);
            out_ref_train = get_struct_idx(self.out_ref, self.idx_train);
            out_nrm_train = get_struct_idx(self.out_nrm, self.idx_train);
            
            % get normalization
            self.norm_param_inp = get_norm_var_inp(self.var_inp, inp_train);
            self.norm_param_out = get_norm_var_out(self.var_out, out_ref_train, out_nrm_train);
            
            % get training matrices
            inp_mat_train = get_scale_inp(self.var_inp, self.norm_param_inp, inp_train);
            out_mat_train = get_scale_out(self.var_out, self.norm_param_out, out_ref_train, out_nrm_train);
            
            % train the network
            self.train_engine(inp_mat_train, out_mat_train, tag_train);
            self.load_engine();
            
            % run the network
            inp_mat = get_scale_inp(self.var_inp, self.norm_param_inp, self.inp);
            out_mat = self.predict_engine(inp_mat);
                        
            % unscale the result
            self.out_ann = get_unscale_out(self.var_out, self.norm_param_out, self.out_nrm, out_mat);
            
            % check set
            check_set(self.n_sol, self.var_inp, self.inp)
            check_set(self.n_sol, self.var_out, self.out_ref)
            check_set(self.n_sol, self.var_out, self.out_nrm)
            check_set(self.n_sol, self.var_out, self.out_ann)
            self.is_train = true;
        end
        
        function disp(self)
            self.display_ann_input();
            self.display_properties();
        end
        
        function [is_valid_tmp, out_nrm_tmp] = predict_nrm(self, n_sol_tmp, inp_tmp, out_nrm_tmp)
            % check state
            assert(self.is_train==true, 'invalid state')
                                                
            % check validity
            is_valid_tmp = get_range_inp(self.var_inp, inp_tmp);
            
            % check set
            check_set(n_sol_tmp, self.var_inp, inp_tmp)
            check_set(n_sol_tmp, self.var_out, out_nrm_tmp)
        end

        function [is_valid_tmp, out_ann_tmp] = predict_ann(self, n_sol_tmp, inp_tmp, out_nrm_tmp)
            % check state
            assert(self.is_train==true, 'invalid state')
                        
            % run the network
            inp_mat_tmp = get_scale_inp(self.var_inp, self.norm_param_inp, inp_tmp);
            out_mat_tmp = self.predict_engine(inp_mat_tmp);
            
            % unscale the result
            out_ann_tmp = get_unscale_out(self.var_out, self.norm_param_out, out_nrm_tmp, out_mat_tmp);
            
            % check validity
            is_valid_tmp = get_range_inp(self.var_inp, inp_tmp);
            
            % check set
            check_set(n_sol_tmp, self.var_inp, inp_tmp)
            check_set(n_sol_tmp, self.var_out, out_nrm_tmp)
            check_set(n_sol_tmp, self.var_out, out_ann_tmp)
        end
        
        function delete(self)
            if self.is_train==true
                self.unload_engine();
            end
        end
    end
    
    methods (Access = public)
        function init_engine(self)
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
                    self.ann_engine_obj = ann_engine.AnnEnginePythonAnn(hostname, port, timeout);
                otherwise
                    error('invalid engine')
            end
        end
                
        function train_engine(self, inp_mat, out_mat, tag_train)
            if self.split_var==true
                self.ann_data = {};
                for i=1:length(self.var_out)
                    [model, history] = self.ann_engine_obj.train(tag_train, inp_mat, out_mat(i,:));
                    self.ann_data{i} = struct('model', model, 'history', history, 'name', ['ann_' num2str(i)]);
                end
            else
                [model, history] = self.ann_engine_obj.train(tag_train, inp_mat, out_mat);
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
    
    methods (Access = public)
        function display_ann_input(self)
            disp_data('var_inp', self.var_inp);
            disp_data('var_out', self.var_out);
            disp_data('split_train_test', self.split_train_test);
            disp_data('split_var', self.split_var);
            disp_data('ann_info', self.ann_info);
        end
        
        function display_properties(self)
            disp_data('is_train', self.is_train);
            
            if self.is_train==true
                disp_data('norm_param_inp', self.norm_param_inp);
                disp_data('norm_param_out', self.norm_param_out);
                disp_data('n_train', nnz(self.idx_train));
                disp_data('n_test', nnz(self.idx_test));
                
                disp_set_data('inp', self.var_inp, self.inp, self.idx_train, self.idx_test)
                disp_set_data('out_ref', self.var_out, self.out_ref, self.idx_train, self.idx_test)
                disp_set_data('out_nrm', self.var_out, self.out_nrm, self.idx_train, self.idx_test)
                disp_set_data('out_ann', self.var_out, self.out_ann, self.idx_train, self.idx_test)
                disp_set_error('out_nrm / out_ref', self.var_out, self.out_nrm, self.out_ref, self.idx_train, self.idx_test);
                disp_set_error('out_ann / out_ref', self.var_out, self.out_ann, self.out_ref, self.idx_train, self.idx_test);
            end
        end
    end
end
