classdef ThermalLoss < handle
    % Class for controlling iteration between thermal model and loss model.
    %
    %    The thermal model and loss model are typically coupled.
    %    In order to reach a consistent (steady-state) solution, iterations are required.
    %
    %    The iteration can be controlled:
    %        - maximum number of iterations
    %        - absolute and relative tolerance
    %        - relaxation parameters
    %
    %    The code is completely vectorized:
    %        - many designs (samples) are iterated together
    %        - advantage: in MATLAB vector operation are fast
    %        - sisadvantage: some samples are waiting for other to converge
    %        - summary: the trade-off is massively in favour of vector iteration
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        iter % struct: contains the control parameters
        fct % struct: contains the function handle for the thermal and loss models
    end
    
    %% public
    methods (Access = public)
        function self = ThermalLoss(iter, fct)
            % Constructor.
            %
            %    Parameters:
            %        iter (struct): contains the control parameters
            %        fct (struct): contains the function handle for the thermal and loss models
            
            self.iter = iter;
            self.fct = fct;
        end
        
        function [operating, is_valid] = get_iter(self, operating)
            % Make a thermal iteration between the thermal and loss models.
            %
            %    Parameters:
            %        operating (struct): data with the operating points to be computed
            %
            %    Returns:
            %        operating (struct): data with the computed operating points
            %        is_valid (vector): if the iteration was succesful for the different points
            
            % init the iteration
            i_iter = 1;
            should_stop = false;
            P_vec = [];
            T_vec = [];
            operating = self.fct.fct_init(operating);
            
            % run the iteration
            while should_stop==false
                [operating, should_stop, is_valid, P_vec, T_vec] = self.get_iter_sub(operating, i_iter, P_vec, T_vec);
                i_iter = i_iter+1;
            end
        end
    end
    
    %% private
    methods (Access = private)
        function [operating, should_stop, is_valid, P_vec, T_vec] = get_iter_sub(self, operating, i_iter, P_vec, T_vec)
            % Make a thermal iteration between the thermal and loss models.
            %
            %    Parameters:
            %        operating (struct): data with the operating points
            %        i_iter (int): iteration number
            %        P_vec (matrix): vector with the losses
            %        T_vec (matrix): vector with the temperatures
            %
            %    Returns:
            %        operating (struct): data with the operating points
            %        should_stop (logical): if the iteration should stop (succesful or not)
            %        is_valid (vector): if the iteration was succesful for the different points
            %        P_vec (matrix): vector with the losses
            %        T_vec (matrix): vector with the temperatures
            
            
            % for the first iteration, don't compute the thermal model
            if i_iter>1
                operating = self.fct.get_thermal(operating);
            end
            
            % compute the loss model
            operating = self.fct.get_losses(operating);
            
            % convert the loss and thermal data into matrices (number of loss/thermal data x number of samples)
            [T_new_vec, is_valid_T] = self.fct.get_thermal_vec(operating);
            [P_new_vec, is_valid_P] = self.fct.get_losses_vec(operating);
            
            % check the data
            [P_vec, ok_tol_losses] = self.check_convergence(i_iter, P_vec, P_new_vec, self.iter.losses);
            [T_vec, ok_tol_thermal] = self.check_convergence(i_iter, T_vec, T_new_vec, self.iter.thermal);
            ok_convergence = ok_tol_losses&ok_tol_thermal;
            
            % check the iteration
            ok_iter = i_iter>=self.iter.n_iter;
            ok_data = is_valid_T&is_valid_P;
            
            % check the validity of the samples
            is_valid = (ok_data==true)&(ok_convergence==true);
            
            % check if the iteration should continue
            should_stop = (ok_iter==true)||all((ok_data==false)|(ok_convergence==true));
        end
        
        function [vec, ok_tol] = check_convergence(self, i_iter, vec_old, vec_new, update)
            % Check the convergence and update the matrices (with relaxation).
            %
            %    Parameters:
            %        i_iter (int): iteration number
            %        vec_old (matrix): vector from the previous iteration
            %        vec_new (matrix): vector from the current iteration
            %        update (struct): convergence and update information
            %
            %    Returns:
            %        vec (matrix): updated vector
            %        ok_tol (vector): if the vector has converged
            
            if i_iter==1
                % fist iteration, no convergence possible
                ok_tol = false;
                vec = vec_new;
            else
                % compute the errors
                err_abs_vec = abs(vec_old-vec_new);
                err_rel_vec = abs((vec_old-vec_new)./vec_new);
                
                % check the errors
                ok_tol_abs = max(err_abs_vec, [], 1)<update.tol_abs;
                ok_tol_rel = max(err_rel_vec, [], 1)<update.tol_rel;
                ok_tol = ok_tol_abs&ok_tol_rel;
                
                % update the vector with relaxation
                %    - the new value is a mix between the new and the old value
                %    - with relax=1, only the new value is used
                %    - with relax<1, the iteration is damped and typically more stable
                %    - with relax>1, the iteration is more aggressive
                vec = update.relax.*vec_new+(1-update.relax).*vec_old;
            end
        end
    end
end