classdef AnnFem < handle
    % Interface to evaluate ANN/regression for inductors.
    %
    %    Offer many unified interface to evaluate the ANN/regression:
    %        - Set the basic geometry
    %        - Get the all the figures of merit of the geometry
    %        - Get the magnetic simulation regression results
    %        - Get the thermal simulation regression results
    %
    %    This class is meant to make the interface between:
    %        - The FEM simulations and the corresponding trained/fitted regression
    %        - The inductor design code, which query the simulation results of different designs
    %
    %    Three type of evaluation are available:
    %        - Get the result of the ANN/regression (main method)
    %        - Get the FEM solution without the ANN/regression (mainly for verification)
    %        - Get the analytical solution without the ANN/regression (mainly for verification)
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        const % struct: contain the constant data for the model
        geom_type % str: type of the geometry variables ('abs' or 'rel')
        eval_type % str: get the result of the ANN/regression, FEM or, just the analytical solution ('ann', 'fem', or 'approx')
        file_model_ht % str: path of the COMSOL file to be used for the thermal simulations
        file_model_mf % str: path of the COMSOL file to be used for the magnetic simulations
        ann_manager_ht_obj % AnnManager: object managing the ANN/regression for the thermal data
        ann_manager_mf_obj % AnnManager: object managing the ANN/regression for the magnetic data
        is_geom % logical: if the a geometry has been set (or not)
        n_sol % int: number of samples of the given geometry
        geom % struct: data of the given geometry
    end
    
    %% public
    methods (Access = public)
        function self = AnnFem(data_fem_ann, geom_type, eval_type)
            % Constructor.
            %
            %    Set the data.
            %    Create the regression engine.
            %    Load the data into the regression engine.
            %
            %    Parameters:
            %        data_fem_ann (struct): contain the results of the magnetic and thermal ANN/regression
            %        geom_type (str): type of the geometry variables ('abs' or 'rel')
            %        eval_type (str): get the result of the ANN/regression, FEM or, just the analytical solution ('ann', 'fem', or 'approx')
            
            % assign input
            self.geom_type = geom_type;
            self.eval_type = eval_type;
            self.const = data_fem_ann.const;
            
            % create the regression engine and load the data
            [self.file_model_mf, self.ann_manager_mf_obj] = self.get_ann_manager(data_fem_ann.ann_mf, 'mf');
            [self.file_model_ht, self.ann_manager_ht_obj] = self.get_ann_manager(data_fem_ann.ann_ht, 'ht');
            
            % the geometry is not set yet
            self.is_geom = false;
        end
        
        function set_geom(self, n_sol, geom)
            % Set the basic geometry of inductors (many samples).
            %
            %    Parameters:
            %        n_sol (int): number of samples of the given geometry
            %        geom (struct): data of the given geometry
            
            self.n_sol = n_sol;
            self.geom = geom;
            self.is_geom = true;
        end
        
        function [is_valid, geom] = get_geom(self)
            % Get the figures of merit of the geometry and the validity of the designs.
            %
            %    Returns:
            %        is_valid (vector): validity of the different evaluated samples
            %        geom (struct): data of the parsed geometry with extra data
            
            % check the state
            assert(self.is_geom==true, 'invalid state')
            
            % extend the data, get the validity
            [is_valid, geom] = self.get_extend_inp_wrapper('none', self.geom);
        end
        
        function [is_valid, fom] = get_mf(self, excitation)
            % Get the ANN/regression simulation results for the magnetic model.
            %
            %    Parameters:
            %        excitation (struct): input data for the simulations
            %
            %    Returns:
            %        is_valid (vector): validity of the different evaluated samples
            %        fom (struct): data with the ANN/regression simulation results
            
            % check the state
            assert(self.is_geom==true, 'invalid state')
            
            % extend the results, get the validity
            [is_valid, fom] = self.get_model_type(excitation, 'mf');
        end
        
        function [is_valid, fom] = get_ht(self, excitation)
            % Get the ANN/regression simulation results for the thermal model.
            %
            %    Parameters:
            %        excitation (struct): input data for the simulations
            %
            %    Returns:
            %        is_valid (vector): validity of the different evaluated samples
            %        fom (struct): data with the ANN/regression simulation results
            
            % check the state
            assert(self.is_geom==true, 'invalid state')
            
            % extend the results, get the validity
            [is_valid, fom] = self.get_model_type(excitation, 'ht');
        end
    end
    
    methods (Access = private)
        function [file_model, ann_manager_obj] = get_ann_manager(self, data, model_type)
            % Create the ANN/regression engine and load the data.
            %
            %    Parameters:
            %        excitation (struct): input data for the simulations
            %        model_type (str): expected type of the simulation
            %
            %    Returns:
            %        file_model (str): path of the COMSOL file to be used for the simulations
            %        ann_manager_obj (AnnManager): object managing the ANN/regression
            
            % create ANN object
            assert(strcmp(data.model_type, model_type), 'invalid type')
            ann_manager_obj = AnnManager(data.ann_input);
            ann_manager_obj.load(data.ann_data);
            
            % get file name for COMSOL
            file_model = data.file_model;
        end
        
        function [is_valid, fom] = get_model_type(self, excitation, model_type)
            % Get the ANN/regression simulation results.
            %
            %    Parameters:
            %        data (struct): input data for the ANN/regression engine
            %        model_type (str): type of the simulation
            %
            %    Returns:
            %        is_valid (vector): validity of the different evaluated samples
            %        fom (struct): data with the ANN/regression simulation results
            
            % get data, merge the geometry and the provided excitation
            inp = get_struct_merge(self.geom, excitation);
            
            % extend the input with additional data (without making any regression)
            [is_valid, inp] = self.get_extend_inp_wrapper(model_type, inp);
            
            % get the ANN/regression results
            [is_valid, fom] = self.get_fom_wapper(model_type, is_valid, inp);
        end
        
        function [is_valid, inp] = get_extend_inp_wrapper(self, model_type, inp)
            % Extend the parameters provided by the user with additional data (without making any regression).
            %
            %    Parameters:
            %        model_type (str): type of the simulation
            %        inp (struct): input data (provided)
            %
            %    Returns:
            %        is_valid (vector): validity of the different evaluated samples
            %        inp (struct): merged data with additional info
            
            % set the type of the excitation
            switch model_type
                case 'none'
                    excitation_type = [];
                case {'mf', 'ht'}
                    excitation_type = 'abs';
                otherwise
                    error('invalid type')
            end
            
            % extend the input with additional data (without making any regression)
            var_type = struct('geom_type', self.geom_type, 'excitation_type', excitation_type);
            [is_valid, inp] = fem_ann.get_extend_inp(self.const, model_type, var_type, self.n_sol, inp);
        end
        
        function [is_valid, fom] = get_fom_wapper(self, model_type, is_valid, inp)
            % Evaluate the ANN/regression with the provided data.
            %
            %    Parameters:
            %        model_type (str): type of the simulation
            %        is_valid (vector): validity of the different evaluated samples
            %        inp (struct): input data (extended)
            %
            %    Returns:
            %        is_valid (vector): validity of the different evaluated samples
            %        fom (struct): data with the ANN/regression simulation results
            
            % get the selected model
            switch model_type
                case 'mf'
                    ann_manager_obj = self.ann_manager_mf_obj;
                    file_model = self.file_model_mf;
                case 'ht'
                    ann_manager_obj = self.ann_manager_ht_obj;
                    file_model = self.file_model_ht;
                otherwise
                    error('invalid type')
            end
            
            % get the a first solution without ANN/regression
            switch self.eval_type
                case 'fem'
                    % FEM does not support vector evaluation, loop throught the designs
                    for i=1:length(self.n_sol)
                        inp_tmp = get_struct_filter(inp, i);
                        fom(i) = fem_ann.get_out_fem(file_model, model_type, inp_tmp);
                    end
                    fom = get_struct_assemble(fom);
                case {'ann', 'approx'}
                    % analytical approximation supports vector evaluation
                    fom = fem_ann.get_out_approx(model_type, inp);
                otherwise
                    error('invalid data')
            end
            
            % evaluate the ANN/regression
            switch self.eval_type
                case 'ann'
                    [is_valid_tmp, fom] = ann_manager_obj.predict_ann(self.n_sol, inp, fom);
                case {'fem', 'approx'}
                    [is_valid_tmp, fom] = ann_manager_obj.predict_nrm(self.n_sol, inp, fom);
                otherwise
                    error('invalid data')
            end
            
            % combine validity of the parameters and of the regression
            is_valid = is_valid&is_valid_tmp;
        end
    end
end
