classdef CoreData < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        idx
        param
        interp
    end
    
    %% init
    methods (Access = public)
        function self = CoreData(data, id)
            % assign input
            for i=1:length(data)
                ix_vec(i) = i;
                id_vec(i) = data{i}.id;
                
                param_tmp{i} = data{i}.material.param;
                interp_tmp{i} = self.parse_interp(data{i}.material.interp);
            end
            
            self.parse_data(ix_vec, id_vec, id, param_tmp, interp_tmp);
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
        
        function [is_valid, P] = get_losses_sin(self, f, B_peak, B_dc, T)
            [is_valid, P] = self.get_interp(f, B_peak, B_dc, T);
            
            [is_valid, P] = self.parse_losses(is_valid, P, B_peak, B_dc);
        end
        
        function [is_valid, P] = get_losses_tri(self, f, d_c, B_peak, B_dc, T)
            [is_valid, k, alpha, beta] = compute_steinmetz(self, f, B_peak, B_dc, T);
            ki = self.compute_steinmetz_ki(k, alpha, beta);
            P = self.compute_steinmetz_losses(ki, alpha, beta, f, d_c, B_peak);
                        
            [is_valid, P] = self.parse_losses(is_valid, P, B_peak, B_dc);
            
        end
    end
    
    methods (Access = private)        
        function interp = parse_interp(self, interp)
            %% load
            f = interp.f;
            B_peak = interp.B_peak;
            B_dc = interp.B_dc;
            T = interp.T;
            P_f_B_peak_B_dc_T = interp.P_f_B_peak_B_dc_T;
            
            %% interp
            [f_mat, B_peak_mat, B_dc_mat, T_mat] = ndgrid(f, B_peak, B_dc, T);
            fct_interp = griddedInterpolant(log10(f_mat), log10(B_peak_mat), B_dc_mat, T_mat, log10(P_f_B_peak_B_dc_T), 'linear', 'linear');
            
            %% interp
            interp.fct_interp = fct_interp;
        end
        
        function parse_data(self, ix_vec, id_vec, id, param_tmp, interp_tmp)
            self.idx = get_integer_map(id_vec, ix_vec, id);
            
            param_tmp = [param_tmp{:}];
            param_tmp = get_struct_assemble(param_tmp);
            self.param = get_struct_filter(param_tmp, self.idx);
            self.interp = interp_tmp;
        end
                
        function [is_valid, P] = parse_losses(self, is_valid, P, B_peak, B_dc)
            P_scale = self.param.P_scale;
            P_max = self.param.P_max;
            B_sat = self.param.B_sat;
            
            P = P_scale.*P;
            is_valid = is_valid&(P<=P_max);
            is_valid = is_valid&((B_peak+B_dc)<=B_sat);
            
        end
        
        function [is_valid, k, alpha, beta] = compute_steinmetz(self, f, B_peak, B_dc, T)
            is_valid = true(1, length(self.idx));
            
            fact_igse = self.param.fact_igse;
            f_1 = (1-fact_igse).*f;
            f_2 = (1+fact_igse).*f;
            B_peak_1 = (1-fact_igse).*B_peak;
            B_peak_2 = (1+fact_igse).*B_peak;
            
            [is_valid_tmp, P_ref] = self.get_interp(f, B_peak, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            [is_valid_tmp, P_f_1] = self.get_interp(f_1, B_peak, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            [is_valid_tmp, P_f_2] = self.get_interp(f_2, B_peak, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            [is_valid_tmp, P_B_peak_1] = self.get_interp(f, B_peak_1, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            [is_valid_tmp, P_B_peak_2] = self.get_interp(f, B_peak_2, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            alpha = log(P_f_1./P_f_2)./log(f_1./f_2);
            beta = log(P_B_peak_1./P_B_peak_2)./log(B_peak_1./B_peak_2);
            k = P_ref./((f.^alpha).*(B_peak.^beta));
        end
        
        function ki = compute_steinmetz_ki(self, k, alpha, beta)
            % get the IGSE parameter ki
            %     - alpha - GSE parameter
            %     - beta - GSE parameter
            %     - k - GSE parameter
            %     - ki - IGSE parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            t1 = (2.*pi).^(alpha-1);
            t2 = 2.*sqrt(pi).*gamma(1./2+alpha./2)./gamma(1+alpha./2);
            t3 = 2.^(beta-alpha);
            ki = k./(t1.*t2.*t3);
        end
        
        function P = compute_steinmetz_losses(self, ki, alpha, beta, f, d_c, B_peak)
            % peak to peak flux density
            t_1 = d_c./f;
            t_2 = (1-d_c)./f;
            B_peak_peak = 2.*B_peak;
            
            % apply IGSE
            v_1 = (abs(B_peak_peak./t_1).^alpha).*t_1;
            v_2 = (abs(B_peak_peak./t_2).^alpha).*t_2;
            v_cst = f.*ki.*B_peak_peak.^(beta-alpha);
            P = v_cst.*(v_1+v_2);
        end
        
        function [is_valid, P] = get_interp(self, f, B_peak, B_dc, T)
            P = NaN(1, length(self.idx));
            is_valid = false(1, length(self.idx));
            
            for i=1:length(self.interp)
                idx_select = self.idx==i;
                
                [is_valid_tmp, P_tmp] = self.get_interp_sub(self.interp{i}, idx_select, f, B_peak, B_dc, T);
                
                P(idx_select) = P_tmp;
                is_valid(idx_select) = is_valid_tmp;
            end
        end
        
        function [is_valid, P] = get_interp_sub(self, interp, idx_select, f, B_peak, B_dc, T)
            f = f(idx_select);
            B_peak = B_peak(idx_select);
            B_dc = B_dc(idx_select);
            T = T(idx_select);
            
            is_valid = true;
            [is_valid, f] = self.clamp(is_valid, f, interp.f);
            [is_valid, B_peak] = self.clamp(is_valid, B_peak, interp.B_peak);
            [is_valid, B_dc] = self.clamp(is_valid, B_dc, interp.B_dc);
            [is_valid, T] = self.clamp(is_valid, T, interp.T);
            
            P = 10.^interp.fct_interp(log10(f), log10(B_peak), B_dc, T);
        end
        
        function [is_valid, data] = clamp(self, is_valid, data, range)
            v_max = max(range);
            v_min = min(range);
            
            is_valid = is_valid&(data>=v_min)&(data<=v_max);
            
            data(data>v_max) = v_max;
            data(data<v_min) = v_min;
        end
    end
end
