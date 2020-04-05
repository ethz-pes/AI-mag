classdef AnnEnginePythonAnn < ann_engine.AnnEngineAbstract
    % Regression engine using Python TensorFlow ANN.
    %
    %    Class implementing ann_engine.AnnEngineAbstract.
    %    Train, load, unload, and evaluate Python TensorFlow ANN.
    %    Use and require a running Python ANN server over TCP/IP.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

    %% properties
    properties (SetAccess = private, GetAccess = public)
        tag_train % str: tag for enabling different training/fitting modes
        client_obj % ann_engine.MatlabPythonClient: manage the connection to the server
    end
    
    %% public
    methods (Access = public)
        function self = AnnEnginePythonAnn(hostname, port, timeout, tag_train)
            % Constructor.
            %
            %    Parameters:
            %        hostname (str): hostname of the Python server
            %        port (int): port of the Python server
            %        timeout (int): timeout for Python server requests
            %        tag_train (str): tag for enabling different training/fitting modes
            
            self = self@ann_engine.AnnEngineAbstract();
            self.tag_train = tag_train;
            self.client_obj = ann_engine.MatlabPythonClient(hostname, port, timeout);
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
            
            % request data
            data_inp.type = 'train';
            data_inp.tag_train = self.tag_train;
            data_inp.inp = inp;
            data_inp.out = out;
            
            % make request
            data_out = self.client_obj.run(data_inp);
            assert(data_out.status==true, 'train error')
            
            % response data
            model = data_out.model;
            history = data_out.history;
        end
        
        function unload(self, name)
            % Remove an regression from the memory.
            %
            %    Parameters:
            %        name (str): Name of the regression to be removed
            
            % request data
            data_inp.type = 'unload';
            data_inp.name = name;
            
            % make request
            data_out = self.client_obj.run(data_inp);
            assert(data_out.status==true, 'train error')
        end
        
        function load(self, name, model, history)
            % Load a regression to the memory.
            %
            %    Parameters:
            %        name (str): Name of the regression to be loaded
            %        model (various): regression parameters
            %        history (various): regression training/fitting record
            
            % request data
            data_inp.type = 'load';
            data_inp.name = name;
            data_inp.model = model;
            data_inp.history = history;
            
            % make request
            data_out = self.client_obj.run(data_inp);
            assert(data_out.status==true, 'train error')
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
            
            % request data
            data_inp.type = 'predict';
            data_inp.name = name;
            data_inp.inp = inp;
            
            % make request
            data_out = self.client_obj.run(data_inp);
            assert(data_out.status==true, 'train error')
            
            % response data
            out = data_out.out;
        end
    end
end
