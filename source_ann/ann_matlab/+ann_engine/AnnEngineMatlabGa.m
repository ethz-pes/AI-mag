classdef AnnEngineMatlabGa < ann_engine.AnnEngineAbstract
    % Regression engine using MATLAB 'ga'.
    %
    %    Class implementing ann_engine.AnnEngineAbstract.
    %    Fit, load, unload, and evaluate MATLAB genetic algorithm.
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        fct_fit % fct: definition of the considered fitting function
        fct_err % fct: definition of the considered error metric
        x_value % struct: control of the fitting parameters
        options % struct: options for the MATLAB 'lsqnonlin' function
        ann_data % struct: fit data storage
    end
    
    %% public
    methods (Access = public)
        function self = AnnEngineMatlabGa(fct_fit, fct_err, x_value, options)
            % Constructor.
            %
            %    Parameters:
            %        fct_fit (fct): definition of the considered fitting function
            %        fct_err (fct): definition of the considered error metric
            %        x_value (struct): control of the fitting parameters
            %        options (struct): options for the MATLAB 'lsqnonlin' function
            
            self = self@ann_engine.AnnEngineAbstract();
            self.fct_fit = fct_fit;
            self.fct_err = fct_err;
            self.x_value = x_value;
            self.options = options;
            self.ann_data = struct();
        end
        
        function [model, history] = train(self, tag_train, inp, out)
            % Train/fit a regression and get the corresponding model.
            %
            %    Parameters:
            %        tag_train (str): tag for enabling different training/fitting modes
            %        inp (matrix): matrix with the input data
            %        out (matrix): matrix with the output data
            %
            %    Returns:
            %        model (various): regression parameters
            %        history (various): regression training/fitting record
            
            % get the size of the samples
            n_inp = size(inp, 1);
            n_out = size(out, 1);
            n_sol_inp = size(inp, 2);
            n_sol_out = size(out, 2);
            
            % check the size
            assert(n_sol_inp==n_sol_out, 'invalid size')
            assert(n_sol_out>0, 'invalid size')
            assert(n_sol_inp>0, 'invalid size')
            assert(n_inp>0, 'invalid size')
            assert(n_out>0, 'invalid size')
            
            % fit with genetic algoritm
            fct_err_tmp = @(x) self.fct_err(tag_train, x, inp, out);
            n = self.x_value.n;
            lb = self.x_value.lb;
            ub = self.x_value.ub;
            [x, fval, exitflag, output, population, scores] = ga(fct_err_tmp, n, [], [], [], [], lb, ub, [], self.options);
            
            % assign the fit and the fitting record
            model = struct('tag_train', tag_train, 'x', x);
            history = struct('fval', fval, 'population', population, 'scores', scores, 'exitflag', exitflag, 'output', output);
        end
        
        function unload(self, name)
            % Remove an regression from the memory.
            %
            %    Parameters:
            %        name (str): Name of the regression to be removed
            
            % remove the entry (also if not existing)
            
            self.ann_data = rmfield(self.ann_data, name);
        end
        
        function load(self, name, model, history)
            % Load a regression to the memory.
            %
            %    Parameters:
            %        name (str): Name of the regression to be loaded
            %        model (various): regression parameters
            %        history (various): regression training/fitting record
            
            % check the data type
            assert(isstruct(model), 'invalid model')
            assert(isstruct(history), 'invalid model')
            
            % load the data
            self.ann_data.(name) = struct('model', model, 'history', history);
        end
        
        function out = predict(self, name, inp)
            % Evaluate a regression with given input data.
            %
            %    Parameters:
            %        name (str): Name of the regression to be evaluated
            %        inp (matrix): matrix with the input data
            %
            %    Returns:
            %        out (matrix): matrix with the output data
            
            % get and check the model
            model = self.ann_data.(name).model;
            history = self.ann_data.(name).history;
            assert(isstruct(model), 'invalid model')
            assert(isstruct(history), 'invalid model')
            
            % evaluate the model
            x = model.x;
            tag_train = model.tag_train;
            out = self.fct_fit(tag_train, x, inp);
            assert(size(inp, 2)==size(out, 2), 'invalid size')
        end
    end
end
