classdef WindingData < handle
    %% properties
    properties (SetAccess = immutable, GetAccess = public)
        data
        id
    end
    properties (SetAccess = private, GetAccess = public)
        idx
        param
        interp
    end
    
    %% init
    methods (Access = public)
        function self = WindingData(data, id)
            % assign input
            self.data = data;
            self.id = id;
            
            for i=1:length(self.data)
                ix_vec(i) = i;
                id_vec(i) = self.data{i}.id;
                
                param_tmp{i} = self.data{i}.material.param;
                self.interp{i} = self.get_interp(self.data{i}.material.interp);
            end
            
            
            self.idx = get_integer_map(id_vec, ix_vec, id);
            
            param_tmp = [param_tmp{:}];
            param_tmp = get_struct_assemble(param_tmp);
            self.param = get_struct_filter(param_tmp, self.idx);
        end
        
        function interp = get_interp(self, interp)
            %% load
            T = interp.T;
            sigma = interp.sigma;
            
            %% interp
            fct_interp = griddedInterpolant(T, sigma, 'linear', 'linear');
                        
            %% interp
            interp.fct_interp = fct_interp;
        end
        
        function [is_valid, data] = clamp(self, is_valid, data, range)
            
            v_max = max(range);
            v_min = min(range);
            
            is_valid = is_valid&(data>=v_min)&(data<=v_max);
            
            data(data>v_max) = v_max;
            data(data<v_min) = v_min;
            
        end
        
        function [is_valid, P] = get_losses(self, J_rms, H_rms, T)
            P = NaN(1, length(self.idx));
            is_valid = false(1, length(self.idx));

            for i=1:length(self.interp)
                idx_select = self.idx==i;
                
                [is_valid_tmp, P_tmp] = self.get_losses_sub(self.interp{i}, idx_select, f, B_peak, B_dc, T);
                
                P(idx_select) = P_tmp;
                is_valid(idx_select) = is_valid_tmp;
            end
        end
        
        function [is_valid, P] = get_losses_sub(self, interp, idx_select, f, B_peak, B_dc, T)
            f = f(idx_select);
            B_peak = B_peak(idx_select);
            B_dc = B_dc(idx_select);
            T = T(idx_select);
            
            P_scale = self.param.P_scale(idx_select);
            P_max = self.param.P_max(idx_select);
            B_sat = self.param.B_sat(idx_select);
            
            is_valid = true;
            [is_valid, f] = self.clamp(is_valid, f, interp.f);
            [is_valid, B_peak] = self.clamp(is_valid, B_peak, interp.B_peak);
            [is_valid, B_dc] = self.clamp(is_valid, B_dc, interp.B_dc);
            [is_valid, T] = self.clamp(is_valid, T, interp.T);
                        
            P = 10.^interp.fct_interp(log10(f), log10(B_peak), B_dc, T);
            P = P_scale.*P;
            is_valid = is_valid&(P<=P_max);
            is_valid = is_valid&((B_peak+B_dc)<=B_sat);            
        end
        
        function m = get_mass(self)
            m = self.param.rho;
        end
        
        function cost = get_cost(self)
            cost = self.param.lambda;
        end

        function T_max = get_temperature(self)
            T_max = self.param.T_max;
        end
    end
end
