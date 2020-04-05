classdef AnnEngineAbstract < handle
    % Abstract class defining a regression engine.
    %
    %    Define the required methods.
    %    Train, load, unload, and evaluate.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

    %% public
    methods (Access = public)
        function self = AnnEngineAbstract()
            % Dummy abstract constructor.
        end
    end
    
    %% public abstract
    methods (Abstract, Access=public)
        [model, history] = train(self, inp, out)
        % Train/fit a regression and get the corresponding model.
        %
        %    Parameters:
        %        inp (matrix): matrix with the input data
        %        out (matrix): matrix with the output data
        %
        %    Returns:
        %        model (various): regression parameters
        %        history (various): regression training/fitting record
                
        unload(self, name)
        % Remove an regression from the memory.
        %
        %    Parameters:
        %        name (str): Name of the regression to be removed
        
        load(self, name, model, history)
        % Load a regression to the memory.
        %
        %    Parameters:
        %        name (str): Name of the regression to be loaded
        %        model (various): regression parameters
        %        history (various): regression training/fitting record

        out = predict(self, name, inp)
        % Evaluate a regression with given input data.
        %
        %    Parameters:
        %        name (str): Name of the regression to be evaluated
        %        inp (matrix): matrix with the input data
        %
        %    Returns:
        %        out (matrix): matrix with the output data
    end
end