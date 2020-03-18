classdef ThermalLoss < handle
    %% init
    properties (SetAccess = immutable, GetAccess = private)
        iter
        fct
    end
    
    %% init
    methods (Access = public)
        function self = ThermalLoss(iter, fct)
            % parse the data
            self.iter = iter;
            validateattributes(self.iter.n_iter, {'double', 'logical'},{'scalar', 'row', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.iter.tol_losses, {'double', 'logical'},{'scalar', 'row', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.iter.tol_thermal, {'double', 'logical'},{'scalar', 'row', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.iter.relax_losses, {'double', 'logical'},{'scalar', 'row', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.iter.relax_thermal, {'double', 'logical'},{'scalar', 'row', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.iter.relax_thermal, {'double', 'logical'},{'scalar', 'row', 'nonempty', 'nonnan', 'real','finite'});
            
            self.fct = fct;
            validateattributes(self.fct.operating_init, {'struct'}, {'scalar'});
            validateattributes(self.fct.get_thermal, {'function_handle'}, {'scalar'});
            validateattributes(self.fct.get_losses, {'function_handle'}, {'scalar'});
            validateattributes(self.fct.get_thermal_vec, {'function_handle'}, {'scalar'});
            validateattributes(self.fct.get_losses_vec, {'function_handle'}, {'scalar'});
        end
        
        function [operating, is_valid] = get_iter(self, excitation)
            % find the consistent solution with iterations
            i_iter = 1;
            should_stop = false;
            P_vec = [];
            T_vec = [];
            operating = self.fct.operating_init;
            while should_stop==false
                operating = self.get_iter_single(operating, excitation, i_iter);
                [T_new_vec, is_valid_T] = self.fct.get_thermal_vec(operating);
                [P_new_vec, is_valid_P] = self.fct.get_losses_vec(operating);
                
                % check the iteration
                ok_iter = i_iter>=self.iter.n_iter;
                ok_data = is_valid_T&is_valid_P;
                
                % check the data
                [P_vec, ok_tol_losses] = self.check_convergence(i_iter, P_vec, P_new_vec, self.iter.tol_losses, self.iter.relax_losses);
                [T_vec, ok_tol_thermal] = self.check_convergence(i_iter, T_vec, T_new_vec, self.iter.tol_thermal, self.iter.relax_thermal);
                ok_convergence = ok_tol_losses&ok_tol_thermal;

                % check the convergence
                should_stop = (ok_iter==true)||all((ok_data==false)|(ok_convergence==true));
                
                % update the iteration
                i_iter = i_iter+1;
            end
                       
            % iteration check          
            is_valid = ok_data&ok_convergence;
        end
    end
                
    %% private api / iter
    methods (Access = private)
        function operating = get_iter_single(self, operating, excitation, i_iter)
            if i_iter>1
                operating = self.fct.get_thermal(operating, excitation);
            end
            operating = self.fct.get_losses(operating, excitation);
        end
        
        function [vec, ok_tol] = check_convergence(self, i_iter, vec, new_vec, tol, relax)
            if i_iter==1
                ok_tol = false;
                vec = new_vec;
            else
                ok_tol = max(abs(vec-new_vec), [], 1)<tol;
                vec = relax.*new_vec+(1-relax).*vec;
            end
        end
    end
end