classdef WindingData < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        idx
        param
        interp
        volume
    end
    
    %% public
    methods (Access = public)
        function self = WindingData(material, id, volume)
            assert(strcmp(material.type, 'winding'), 'invalid length')

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
        
        function J_rms_max = get_current_density(self)
            J_rms_max = self.param.J_rms_max;
        end
        
        function [is_valid, P, P_dc, P_ac_lf, P_ac_hf] = get_losses_sin(self, f, J_dc, J_ac_peak, H_ac_peak, T)            
            [fact_lf, fact_hf] = self.get_fact_sin();
            [is_valid, P, P_dc, P_ac_lf, P_ac_hf] = self.get_losses(f, J_dc, J_ac_peak, H_ac_peak, T, fact_lf, fact_hf);
        end
        
        function [is_valid, P, P_dc, P_ac_lf, P_ac_hf] = get_losses_tri(self, f, d_c, J_dc, J_ac_peak, H_ac_peak, T)
            [fact_lf, fact_hf] = self.get_fact_tri(d_c);
            [is_valid, P, P_dc, P_ac_lf, P_ac_hf] = self.get_losses(f, J_dc, J_ac_peak, H_ac_peak, T, fact_lf, fact_hf);
        end
    end
    
    %% private
    methods (Access = private)        
        function interp = parse_interp(self, interp)
            %% load
            T_vec = interp.T_vec;
            sigma_vec = interp.sigma_vec;
            
            %% interp
            fct_interp = griddedInterpolant(T_vec, sigma_vec, 'linear', 'linear');
                                    
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
                
        function [is_valid, P, P_dc, P_ac_lf, P_ac_hf] = get_losses(self, f, J_dc, J_ac_peak, H_ac_peak, T, fact_lf, fact_hf)            
            [is_valid, sigma] = self.get_interp(T);
                 
            delta = self.get_delta(sigma, f);
            P_dc = self.compute_lf_losses(sigma, J_dc);
            P_ac_lf = self.compute_lf_losses(sigma, J_ac_peak.*fact_lf);
            P_ac_hf = self.compute_hf_losses(sigma, delta, f, H_ac_peak.*fact_hf);
                       
            P = P_dc+P_ac_lf+P_ac_hf;
            J_rms_tot = hypot(J_ac_peak.*fact_lf, J_dc);
            is_valid = self.parse_losses(is_valid, P, J_rms_tot, delta);
            
            P = self.volume.*P;
            P_dc = self.volume.*P_dc;
            P_ac_lf = self.volume.*P_ac_lf;
            P_ac_hf = self.volume.*P_ac_hf;
        end

        function is_valid = parse_losses(self, is_valid, P, J_rms_tot, delta)
            P_max = self.param.P_max;
            J_rms_max = self.param.J_rms_max;
            delta_min = self.param.delta_min;
            
            is_valid = is_valid&(P<=P_max);
            is_valid = is_valid&(J_rms_tot<=J_rms_max);
            is_valid = is_valid&(delta>=delta_min);
        end
                
        function P = compute_lf_losses(self, sigma, J_rms)
            fact_tmp = self.param.P_scale_lf./(self.param.fill.*sigma);
            P = fact_tmp.*(J_rms.^2);
        end
        
        function delta = get_delta(self, sigma, f)
            mu0_const = 4.*pi.*1e-7;
            delta = 1./sqrt(pi.*mu0_const.*sigma.*f);
        end

        function P = compute_hf_losses(self, sigma, delta, f, H_rms)
            gr = (pi.^2.*self.param.d_strand.^6)./(128.*delta.^4);
            fact_tmp = self.param.P_scale_hf.*gr.*(32.*self.param.fill)./(sigma.*pi.^2.*self.param.d_strand.^4);
            P = fact_tmp.*(H_rms.^2);
        end

        function [fact_lf, fact_hf] = get_fact_sin(self)
            fact_lf = 1./sqrt(2);
            fact_hf = 1./sqrt(2);
        end
        
        function [fact_lf, fact_hf] = get_fact_tri(self, d_c)
            m = 1./d_c;
            n = 1:self.param.n_harm;

            [n, m] = ndgrid(n, m);
            coeff = -(2.*(-1).^n.*m.^2)./(n.^2.*(m-1).*pi.^2).*sin((n.*(m-1).*pi)./m);
            
            sum_lf = sum(coeff.^2, 1);
            sum_hf = sum(n.^2.*coeff.^2, 1);
            
            fact_lf = sqrt(sum_lf)./sqrt(2);
            fact_hf = sqrt(sum_hf)./sqrt(2);
        end

        function [is_valid, sigma] = get_interp(self, T)
            sigma = NaN(1, length(self.idx));
            is_valid = false(1, length(self.idx));
            
            for i=1:length(self.interp)
                idx_select = self.idx==i;
                
                [is_valid_tmp, P_tmp] = self.get_interp_sub(self.interp{i}, idx_select, T);
                
                sigma(idx_select) = P_tmp;
                is_valid(idx_select) = is_valid_tmp;
            end
        end
        
        function [is_valid, sigma] = get_interp_sub(self, interp, idx_select, T)
            T = T(idx_select);
            
            is_valid = true;
            [is_valid, T] = self.clamp(is_valid, T, interp.T_vec);
            
            sigma = interp.fct_interp(T);
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
