classdef CoreData < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        idx
        param
        interp
        volume
    end
    
    %% init
    methods (Access = public)
        function self = CoreData(material, id, volume)
            assert(strcmp(material.type, 'core'), 'invalid length')

            % assign input
            for i=1:length(material.data)
                ix_vec(i) = i;
                id_vec(i) = material.data{i}.id;
                
                param_tmp{i} = material.data{i}.material.param;
                interp_tmp{i} = self.parse_interp(material.data{i}.material.interp);
            end
            
            self.parse_data(ix_vec, id_vec, id, param_tmp, interp_tmp);
                        self.volume = volume;
        end
        
        function m = get_mass(self)
            m = self.volume.*self.param.rho;
        end
        
        function cost = get_cost(self)
            cost = self.param.c_offset+self.volume.*self.param.lambda;
        end
        
        function T_max = get_temperature(self)
            T_max = self.param.T_max;
        end

        function B_sat_max = get_flux_density(self)
            B_sat_max = self.param.B_sat_max;
        end

        function [is_valid, P] = get_losses_sin(self, f, B_ac_peak, B_dc, T)
            [is_valid, P] = self.get_interp(f, B_ac_peak, B_dc, T);
            
            is_valid = self.parse_losses(is_valid, P, B_ac_peak+B_dc);
            P = self.volume.*P;
        end
        
        function [is_valid, P] = get_losses_tri(self, f, d_c, B_ac_peak, B_dc, T)
            [is_valid, k, alpha, beta] = compute_steinmetz(self, f, B_ac_peak, B_dc, T);
            P = self.compute_steinmetz_losses(k, alpha, beta, f, d_c, B_ac_peak);
            
            is_valid = self.parse_losses(is_valid, P, B_ac_peak+B_dc);
            P = self.volume.*P;
        end
    end
    
    methods (Access = private)        
        function interp = parse_interp(self, interp)
            %% load
            f_vec = interp.f_vec;
            B_ac_peak_vec = interp.B_ac_peak_vec;
            B_dc_vec = interp.B_dc_vec;
            T_vec = interp.T_vec;
            P_mat = interp.P_mat;
            
            %% interp
            [f_mat, B_ac_peak_mat, B_dc_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, B_dc_vec, T_vec);
            fct_interp = griddedInterpolant(log10(f_mat), log10(B_ac_peak_mat), B_dc_mat, T_mat, log10(P_mat), 'linear', 'linear');
            
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
        
        function is_valid = parse_losses(self, is_valid, P, B_ac_peak_tot)
            P_max = self.param.P_max;
            B_sat_max = self.param.B_sat_max;
            
            is_valid = is_valid&(P<=P_max);
            is_valid = is_valid&(B_ac_peak_tot<=B_sat_max);
        end
        
        function [is_valid, k, alpha, beta] = compute_steinmetz(self, f, B_ac_peak, B_dc, T)
            is_valid = true(1, length(self.idx));
            
            fact_igse = self.param.fact_igse;
            f_1 = f.*(1+fact_igse);
            f_2 = f./(1+fact_igse);
            B_ac_peak_1 = B_ac_peak.*(1+fact_igse);
            B_ac_peak_2 = B_ac_peak./(1+fact_igse);
            
            [is_valid_tmp, P_ref] = self.get_interp(f, B_ac_peak, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            [is_valid_tmp, P_f_1] = self.get_interp(f_1, B_ac_peak, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            [is_valid_tmp, P_f_2] = self.get_interp(f_2, B_ac_peak, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            [is_valid_tmp, P_B_ac_peak_1] = self.get_interp(f, B_ac_peak_1, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            [is_valid_tmp, P_B_ac_peak_2] = self.get_interp(f, B_ac_peak_2, B_dc, T);
            is_valid = is_valid&is_valid_tmp;
            
            alpha = log(P_f_1./P_f_2)./log(f_1./f_2);
            beta = log(P_B_ac_peak_1./P_B_ac_peak_2)./log(B_ac_peak_1./B_ac_peak_2);
            k = P_ref./((f.^alpha).*(B_ac_peak.^beta));
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
        
        function P = compute_steinmetz_losses(self, k, alpha, beta, f, d_c, B_ac_peak)
            ki = self.compute_steinmetz_ki(k, alpha, beta);

            % peak to peak flux density
            t_1 = d_c./f;
            t_2 = (1-d_c)./f;
            B_ac_peak_ac_peak = 2.*B_ac_peak;
            
            % apply IGSE
            v_1 = (abs(B_ac_peak_ac_peak./t_1).^alpha).*t_1;
            v_2 = (abs(B_ac_peak_ac_peak./t_2).^alpha).*t_2;
            v_cst = f.*ki.*B_ac_peak_ac_peak.^(beta-alpha);
            P = v_cst.*(v_1+v_2);
        end
        
        function [is_valid, P] = get_interp(self, f, B_ac_peak, B_dc, T)
            P = NaN(1, length(self.idx));
            is_valid = false(1, length(self.idx));
            
            for i=1:length(self.interp)
                idx_select = self.idx==i;
                
                [is_valid_tmp, P_tmp] = self.get_interp_sub(self.interp{i}, idx_select, f, B_ac_peak, B_dc, T);
                
                P(idx_select) = P_tmp;
                is_valid(idx_select) = is_valid_tmp;
            end
            
            P = self.param.P_scale.*P;
        end
        
        function [is_valid, P] = get_interp_sub(self, interp, idx_select, f, B_ac_peak, B_dc, T)
            f = f(idx_select);
            B_ac_peak = B_ac_peak(idx_select);
            B_dc = B_dc(idx_select);
            T = T(idx_select);
            
            is_valid = true;
            [is_valid, f] = self.clamp(is_valid, f, interp.f_vec);
            [is_valid, B_ac_peak] = self.clamp(is_valid, B_ac_peak, interp.B_ac_peak_vec);
            [is_valid, B_dc] = self.clamp(is_valid, B_dc, interp.B_dc_vec);
            [is_valid, T] = self.clamp(is_valid, T, interp.T_vec);
            
            P = 10.^interp.fct_interp(log10(f), log10(B_ac_peak), B_dc, T);
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
