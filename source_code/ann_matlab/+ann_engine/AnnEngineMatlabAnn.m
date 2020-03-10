classdef AnnEngineMatlabAnn < ann_engine.AnnEngineAbstract
    %% properties
    properties (SetAccess = immutable, GetAccess = private)
        fct_model
        fct_train
    end
    properties (SetAccess = private, GetAccess = private)
        ann_data
    end
    
    %% init
    methods (Access = public)
        function self = AnnEngineMatlabAnn(fct_model, fct_train)
            self = self@ann_engine.AnnEngineAbstract();
            self.fct_model = fct_model;
            self.fct_train = fct_train;
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
            n_sol = mean([n_sol_inp n_sol_out]);
            
            % get model
            assert(n_sol>0, 'invalid size')
            assert(n_inp>0, 'invalid size')
            assert(n_out>0, 'invalid size')
            model = self.fct_model(tag_train, n_sol, n_inp, n_out);
            [model, history] = self.fct_train(tag_train, model, inp, out);
            
            assert(isa(model, 'network'), 'invalid model')
            assert(isstruct(history), 'invalid model')
        end
        
        function unload(self, name)
            self.ann_data = rmfield(self.ann_data, name);
        end
        
        function load(self, name, model, history)
            assert(isa(model, 'network'), 'invalid model')
            assert(isstruct(history), 'invalid model')
            
            self.ann_data.(name) = struct('model', model, 'history', history);
        end
        
        function out = predict(self, name, inp)
            model = self.ann_data.(name).model;
            history = self.ann_data.(name).history;
            assert(isa(model, 'network'), 'invalid model')
            assert(isstruct(history), 'invalid model')
            
            out = model(inp);
            assert(size(inp, 2)==size(out, 2), 'invalid size')
        end
    end
end
