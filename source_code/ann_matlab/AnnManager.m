classdef AnnManager < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        name
        var_inp
        var_out
        fct_scl
        split_train_test
        split_var
        ann_info
        
        n_sol
        inp
        out_ref
        out_scl
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
        function self = AnnManager(name, input)
            % assign
            self.name = name;
            
            % assign input
            self.var_inp = input.var_inp;
            self.var_out = input.var_out;
            self.fct_scl = input.fct_scl;
            self.split_train_test = input.split_train_test;
            self.split_var = input.split_var;
            self.ann_info = input.ann_info;
            
            % set training
            self.is_train = false;
            
            % connect engine
            self.init_engine();
        end
        
        function [input, properties] = dump(self)
            % input data
            input.name = self.name;
            input.var_inp = self.var_inp;
            input.var_out = self.var_out;
            input.fct_scl = self.fct_scl;
            input.split_train_test = self.split_train_test;
            input.split_var = self.split_var;
            input.ann_info = self.ann_info;
            
            % properties
            properties.n_sol = self.n_sol;
            properties.inp = self.inp;
            properties.out_ref = self.out_ref;
            properties.out_scl = self.out_scl;
            properties.out_ann = self.out_ann;
            properties.norm_param_inp = self.norm_param_inp;
            properties.norm_param_out = self.norm_param_out;
            properties.idx_train = self.idx_train;
            properties.idx_test = self.idx_test;
            properties.is_train = self.is_train;
            properties.ann_data = self.ann_data;
        end
        
        function load(self, properties)
            self.n_sol = properties.n_sol;
            self.inp = properties.inp;
            self.out_ref = properties.out_ref;
            self.out_scl = properties.out_scl;
            self.out_ann = properties.out_ann;
            self.norm_param_inp = properties.norm_param_inp;
            self.norm_param_out = properties.norm_param_out;
            self.idx_train = properties.idx_train;
            self.idx_test = properties.idx_test;
            self.is_train = properties.is_train;
            self.ann_data = properties.ann_data;
            
            % load the engine
            if self.is_train==true
                self.load_engine();
            end
        end
        
        function train(self, n_sol, inp, out_ref, tag)
            % assign
            self.n_sol = n_sol;
            self.inp = inp;
            self.out_ref = out_ref;
            
            % get scaling set
            self.out_scl = self.fct_scl(self.n_sol, self.inp);
            
            % split the data
            [self.idx_train, self.idx_test] = get_idx_split(self.n_sol, self.split_train_test);
            
            % extract training data
            inp_train = get_struct_idx(self.inp, self.idx_train);
            out_ref_train = get_struct_idx(self.out_ref, self.idx_train);
            out_scl_train = get_struct_idx(self.out_scl, self.idx_train);
            
            % get normalization
            self.norm_param_inp = get_norm_var_inp(self.var_inp, inp_train);
            self.norm_param_out = get_norm_var_out(self.var_out, out_ref_train, out_scl_train);
            
            % get training matrices
            inp_mat_train = get_scale_inp(self.var_inp, self.norm_param_inp, inp_train);
            out_mat_train = get_scale_out(self.var_out, self.norm_param_out, out_ref_train, out_scl_train);
            
            % train the network
            self.train_engine(inp_mat_train, out_mat_train, tag);
            self.load_engine();
            
            % run the network
            inp_mat = get_scale_inp(self.var_inp, self.norm_param_inp, self.inp);
            out_mat = self.predict_engine(inp_mat);
            
            % unscale the result
            self.out_ann = get_unscale_out(self.var_out, self.norm_param_out, self.out_scl, out_mat);
            
            % check set
            check_set(self.n_sol, self.var_inp, self.inp)
            check_set(self.n_sol, self.var_out, self.out_ref)
            check_set(self.n_sol, self.var_out, self.out_scl)
            check_set(self.n_sol, self.var_out, self.out_ann)
            self.is_train = true;
        end
        
        function disp(self)
            fprintf('################## %s\n', self.name)

            self.display_input();
            self.display_properties();
            
            fprintf('################## %s\n', self.name)
        end
        
        function [out_ann_tmp, out_scl_tmp] = predict(self, n_sol_tmp, inp_tmp)
            % check state
            assert(self.is_train==true, 'invalid state')
            
            % get scaling set
            out_scl_tmp = self.fct_scl(self.n_sol, inp_tmp);
            
            % run the network
            inp_mat_tmp = get_scale_inp(self.var_inp, self.norm_param_inp, inp_tmp);
            out_mat_tmp = self.predict_engine(inp_mat_tmp);
            
            % unscale the result
            out_ann_tmp = get_unscale_out(self.var_out, self.norm_param_out, out_scl_tmp, out_mat_tmp);
            
            % check set
            check_set(n_sol_tmp, self.var_inp, inp_tmp)
            check_set(n_sol_tmp, self.var_out, out_scl_tmp)
            check_set(n_sol_tmp, self.var_out, out_ann_tmp)
        end
    end
    
    methods (Access = public)
        function init_engine(self)
            switch self.ann_info.type
                case 'matlab'
                    self.ann_engine_obj = ann_engine.AnnEngineMatlab(self.ann_info.fct_model, self.ann_info.fct_train);
                case 'python'
                    self.ann_engine_obj = ann_engine.AnnEnginePython(self.ann_info.hostname, self.ann_info.port);
                otherwise
                    error('invalid engine')
            end
            self.ann_engine_obj.clean()
        end
                
        function train_engine(self, inp_mat, out_mat, tag)
            n_var = length(fieldnames(self.var_out));
            if self.split_var==true
                self.ann_data = {};
                for i=1:n_var
                    [model, history] = self.ann_engine_obj.train(inp_mat, out_mat(i,:), tag);
                    self.ann_data{i} = struct('model', model, 'history', history);
                end
            else
                [model, history] = self.ann_engine_obj.train(inp_mat, out_mat, tag);
                self.ann_data = struct('model', model, 'history', history);
            end
        end
        
        function load_engine(self)
            self.ann_engine_obj.clean()

            n_var = length(fieldnames(self.var_out));
            if self.split_var==true
                for i=1:n_var
                    model = self.ann_data{i}.model;
                    history = self.ann_data{i}.history;
                    self.ann_engine_obj.load(['ann_' num2str(i)], model, history)
                end
            else
                model = self.ann_data.model;
                history = self.ann_data.history;
                self.ann_engine_obj.load('ann', model, history)
            end
        end
        
        function out_mat = predict_engine(self, in_mat)
            n_var = length(fieldnames(self.var_out));
            if self.split_var==true
                for i=1:n_var
                    out_mat(i,:) = self.ann_engine_obj.predict(['ann_' num2str(i)], in_mat);
                end
            else
                out_mat = self.ann_engine_obj.predict('ann', in_mat);
            end
        end
    end
    
    methods (Access = public)
        function display_input(self)
            disp_data('var_inp', self.var_inp);
            disp_data('var_out', self.var_out);
            disp_data('fct_scl', self.fct_scl);
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
                
                disp_set_data('inp', self.name, self.var_inp, self.inp, self.idx_train, self.idx_test)
                disp_set_data('out_ref', self.name, self.var_out, self.out_ref, self.idx_train, self.idx_test)
                disp_set_data('out_scl', self.name, self.var_out, self.out_scl, self.idx_train, self.idx_test)
                disp_set_data('out_ann', self.name, self.var_out, self.out_ann, self.idx_train, self.idx_test)
                disp_set_error('out_scl / out_ref', self.name, self.var_out, self.out_scl, self.out_ref, self.idx_train, self.idx_test);
                disp_set_error('out_ann / out_ref', self.name, self.var_out, self.out_ann, self.out_ref, self.idx_train, self.idx_test);
            end
        end
    end
end
