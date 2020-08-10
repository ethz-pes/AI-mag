classdef AnnEngineMatlabGa < ann_engine.AnnEngineAbstract
    % Regression engine using MATLAB 'ga'.
    %
    %    Class implementing 'AnnEngineAbstract'.
    %    Fit, load, unload, and evaluate MATLAB genetic algorithm.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
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
        
        function load(self, name, model, history)
            % Load a regression to the memory.
            %
            %    Parameters:
            %        name (str): Name of the regression to be loaded
            %        model (various): regression parameters
            %        history (various): regression training/fitting record
            
            % check the data type
            assert(isnumeric(model), 'invalid model type')
            assert(isstruct(history), 'invalid history type')
            
            % load the data
            self.ann_data.(name) = struct('model', model, 'history', history);
        end
        
        function unload(self, name)
            % Remove an regression from the memory.
            %
            %    Parameters:
            %        name (str): Name of the regression to be removed
            
            % remove the entry (also if not existing)
            
            self.ann_data = rmfield(self.ann_data, name);
        end
        
        function [model, history] = train(self, inp, out)
            % Train/fit a regression and get the corresponding model.
            %
            %    Parameters:
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
            assert(n_sol_inp==n_sol_out, 'invalid number of samples')
            assert(n_sol_out>0, 'invalid number of samples')
            assert(n_sol_inp>0, 'invalid number of samples')
            assert(n_inp>0, 'invalid number of inputs')
            assert(n_out>0, 'invalid number of outputs')
            
            % fit with genetic algoritm
            fct_err_tmp = @(x) self.fct_err(x, inp, out);
            n = self.x_value.n;
            lb = self.x_value.lb;
            ub = self.x_value.ub;
            [x, fval, exitflag, output, population, scores] = ga(fct_err_tmp, n, [], [], [], [], lb, ub, [], self.options);
            
            % assign the fit and the fitting record
            model = x;
            history = struct('fval', fval, 'population', population, 'scores', scores, 'exitflag', exitflag, 'output', output);
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
            assert(isnumeric(model), 'invalid model type')
            assert(isstruct(history), 'invalid history type')
            
            % evaluate the model
            x = model;
            out = self.fct_fit(x, inp);
            assert(size(inp, 2)==size(out, 2), 'invalid number of samples')
        end
    end
end
