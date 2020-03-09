classdef AnnEngineMatlabGa < ann_engine.AnnEngineAbstract
    %% properties
    properties (SetAccess = private, GetAccess = private)
        fct_fit
        fct_err
        x_value
        options
        ann_data
    end
    
    %% init
    methods (Access = public)
        function self = AnnEngineMatlabGa(fct_fit, fct_err, x_value, options)
            self = self@ann_engine.AnnEngineAbstract();
            self.fct_fit = fct_fit;
            self.fct_err = fct_err;
            self.x_value = x_value;
            self.options = options;
            self.ann_data = struct();
        end
                
        function [model, history] = train(self, tag_train, inp, out)
            % parse var
            n_inp = size(inp, 1);
            n_out = size(out, 1);
            n_sol_inp = size(inp, 2);
            n_sol_out = size(out, 2);
            
            % get size
            assert(n_sol_inp==n_sol_out, 'invalid size')
            assert(n_sol_out>0, 'invalid size')
            assert(n_sol_inp>0, 'invalid size')
            assert(n_inp>0, 'invalid size')
            assert(n_out>0, 'invalid size')

            % fit
            fct_err_tmp = @(x) self.fct_err(tag_train, x, inp, out);
            n = self.x_value.n;
            lb = self.x_value.lb;
            ub = self.x_value.ub;
            [x, fval, exitflag, output, population, scores] = ga(fct_err_tmp, n, [], [], [], [], lb, ub, [], self.options);
            
            % assign
            model = struct('tag_train', tag_train, 'x', x);
            history = struct('fval', fval, 'population', population, 'scores', scores, 'exitflag', exitflag, 'output', output);
        end
        
        function unload(self, name)
            self.ann_data = rmfield(self.ann_data, name);
        end
        
        function load(self, name, model, history)
            assert(isstruct(model), 'invalid model')
            assert(isstruct(history), 'invalid model')

            self.ann_data.(name) = struct('model', model, 'history', history);
        end
                
        function out = predict(self, name, inp)
            model = self.ann_data.(name).model;
            history = self.ann_data.(name).history;
            assert(isstruct(model), 'invalid model')
            assert(isstruct(history), 'invalid model')
            
            x = model.x;
            tag_train = model.tag_train;
            out = self.fct_fit(tag_train, x, inp);
            assert(size(inp, 2)==size(out, 2), 'invalid size')
        end
    end
end
