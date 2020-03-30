classdef InductorCompute < handle
    %% init
    properties (SetAccess = immutable, GetAccess = private)
        n_sol
        data_vec
        data_const
        ann_fem_obj
    end
    properties (SetAccess = private, GetAccess = private)
        fom
        core_obj
        winding_obj
        iso_obj
        thermal_losses_obj
    end
    
    %% init
    methods (Access = public)
        function self = InductorCompute(n_sol, data_vec, data_const, ann_fem_obj)
            % parse the data
            self.n_sol = n_sol;
            self.data_vec = data_vec;            
            self.data_const = data_const;            
            self.ann_fem_obj = ann_fem_obj;
            
            % init
            self.data_vec = get_struct_size(self.data_vec, self.n_sol);
            
            self.init_geom_material()
            self.init_magnetic()
            self.init_thermal_loss()            
        end
        
        function fom = get_fom(self)
            fom = self.fom;
        end
        
        function operating = get_operating(self, excitation)
            field = fieldnames(excitation);
            for j=1:length(field)
                excitation_pts = excitation.(field{j});                
                operating_pts = self.get_operating_pts(excitation_pts);
                operating.(field{j}) = operating_pts;
            end
        end
    end
    
    %% private api / init
    methods (Access = private)
        function init_geom_material(self)
            % set
            self.ann_fem_obj.set_geom(self.n_sol, self.data_vec.geom);
            [is_valid_geom, geom] = self.ann_fem_obj.get_geom();
            
            self.fom.is_valid_geom = is_valid_geom;
            
            self.core_obj = design.CoreData(self.data_const.material_core, self.data_vec.material.core_id, geom.V_core);
            self.winding_obj = design.WindingData(self.data_const.material_winding, self.data_vec.material.winding_id, geom.V_winding);
            self.iso_obj = design.IsoData(self.data_const.material_iso, self.data_vec.material.iso_id, geom.V_iso);
            
            self.fom.material.core_id = self.data_vec.material.core_id;
            self.fom.material.winding_id = self.data_vec.material.winding_id;
            self.fom.material.iso_id = self.data_vec.material.iso_id;

            self.fom.geom.z_core = geom.z_core;
            self.fom.geom.t_core = geom.t_core;
            self.fom.geom.x_window = geom.x_window;
            self.fom.geom.y_window = geom.y_window;
            self.fom.geom.d_gap = geom.d_gap;
            self.fom.geom.d_iso = geom.d_iso;
            self.fom.geom.r_curve = geom.r_curve;
            self.fom.geom.n_turn = geom.n_turn;
            
            self.fom.area.A_core = geom.A_core;
            self.fom.area.A_winding = geom.A_winding;
            self.fom.area.A_box = geom.A_box;
            
            V_offset = self.data_vec.fom_data.V_offset;
            V_scale = self.data_vec.fom_data.V_scale;
            self.fom.volume.V_iso = geom.V_iso;
            self.fom.volume.V_core = geom.V_core;
            self.fom.volume.V_winding = geom.V_winding;
            self.fom.volume.V_box = V_offset+V_scale.*geom.V_box;
            
            m_offset = self.data_vec.fom_data.m_offset;
            m_scale = self.data_vec.fom_data.m_scale;
            self.fom.mass.m_iso = self.iso_obj.get_mass();
            self.fom.mass.m_core = self.core_obj.get_mass();
            self.fom.mass.m_winding = self.winding_obj.get_mass();
            self.fom.mass.m_tot = m_offset+m_scale.*(self.fom.mass.m_iso+self.fom.mass.m_core+self.fom.mass.m_winding);
            
            c_offset = self.data_vec.fom_data.c_offset;
            c_scale = self.data_vec.fom_data.c_scale;
            self.fom.cost.c_iso = self.iso_obj.get_cost();
            self.fom.cost.c_core = self.core_obj.get_cost();
            self.fom.cost.c_winding = self.winding_obj.get_cost();
            self.fom.cost.c_tot = c_offset+c_scale.*(self.fom.cost.c_iso+self.fom.cost.c_core+self.fom.cost.c_winding);
        end
        
        function init_magnetic(self)
            excitation_tmp = struct('I_winding', self.fom.geom.n_turn.*self.data_vec.other.I_test);
            [is_valid_mf, fom_mf] = self.ann_fem_obj.get_mf(excitation_tmp);
            
            self.fom.is_valid_mf = is_valid_mf;
            
            self.fom.circuit.B_norm = self.fom.geom.n_turn.*fom_mf.B_norm;
            self.fom.circuit.J_norm = self.fom.geom.n_turn.*fom_mf.J_norm;
            self.fom.circuit.H_norm = self.fom.geom.n_turn.*fom_mf.H_norm;
            self.fom.circuit.L = self.fom.geom.n_turn.^2.*fom_mf.L_norm;
            
            B_sat_max = self.core_obj.get_flux_density();
            J_rms_max = self.winding_obj.get_current_density();
            self.fom.circuit.I_sat = B_sat_max./self.fom.circuit.B_norm;
            self.fom.circuit.I_rms = J_rms_max./self.fom.circuit.J_norm;
            self.fom.circuit.V_t_area = self.fom.circuit.L.*self.fom.circuit.I_sat;
            
            [r_peak_peak, fact_sat, fact_rms] = self.get_current(self.data_vec.fom_limit.stress, self.fom.circuit);
            self.fom.circuit.r_peak_peak = r_peak_peak;
            self.fom.circuit.fact_sat = fact_sat;
            self.fom.circuit.fact_rms = fact_rms;
                        
            is_valid_limit = true(1, self.n_sol);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.volume.V_box, self.data_vec.fom_limit.V_box);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.cost.c_tot, self.data_vec.fom_limit.c_tot);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.mass.m_tot, self.data_vec.fom_limit.m_tot);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.L, self.data_vec.fom_limit.L);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.I_sat, self.data_vec.fom_limit.I_sat);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.I_rms, self.data_vec.fom_limit.I_rms);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.V_t_area, self.data_vec.fom_limit.V_t_area);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.r_peak_peak, self.data_vec.fom_limit.r_peak_peak);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.fact_sat, self.data_vec.fom_limit.fact_sat);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.fact_rms, self.data_vec.fom_limit.fact_rms);
            self.fom.is_valid_limit = is_valid_limit;
            
            self.fom.is_valid = self.fom.is_valid_geom&self.fom.is_valid_mf&self.fom.is_valid_limit;
        end
        
        function init_thermal_loss(self)
            fct.fct_init = @(operating) self.get_thermal_init(operating);
            fct.get_thermal = @(operating) self.get_thermal(operating);
            fct.get_losses = @(operating) self.get_losses(operating);
            fct.get_thermal_vec = @(operating) self.get_thermal_vec(operating);
            fct.get_losses_vec = @(operating) self.get_losses_vec(operating);
            self.thermal_losses_obj = design.ThermalLoss(self.data_const.iter, fct);
        end

        function is_valid_tmp = init_is_valid_check(self, vec, limit)
            % check the validity
            is_valid_min = vec>=limit.min;
            is_valid_max = vec<=limit.max;
            is_valid_tmp = is_valid_min&is_valid_max;
        end
        
        function [r_peak_peak, fact_sat, fact_rms] = get_current(self, stress, circuit)
            V_t_area = stress.V_t_area;
            I_dc = stress.I_dc;
            fact_rms = stress.fact_rms;
            
            L = circuit.L;
            I_sat = circuit.I_sat;
            I_rms = circuit.I_rms;
            
            I_ac_peak = (1./(2.*L)).*V_t_area;
            I_ac_rms = I_ac_peak.*fact_rms;
            
            I_peak_tot = I_dc+I_ac_peak;
            I_rms_tot = hypot(I_dc, I_ac_rms);
            
            r_peak_peak = (2.*I_ac_peak)./I_dc;
            fact_sat = I_peak_tot./I_sat;
            fact_rms = I_rms_tot./I_rms;
        end
    end
    
    methods (Access = private)
        function operating = get_operating_pts(self, excitation)
            % parse
            operating.excitation = get_struct_size(excitation, self.n_sol);
            
            % iter
            [operating, is_valid_iter] = self.thermal_losses_obj.get_iter(operating);
            
            is_valid_fom = self.fom.is_valid;
            is_valid_thermal = operating.is_valid_thermal;
            is_valid_core = operating.is_valid_core;
            is_valid_winding = operating.is_valid_winding;
            
            operating.is_valid_iter = is_valid_iter;
            operating.is_valid = is_valid_fom&is_valid_iter&is_valid_thermal&is_valid_core&is_valid_winding;
        end
        
        function operating = get_thermal_init(self, operating)
            thermal.T_core_max = self.data_vec.other.T_init;
            thermal.T_core_avg = self.data_vec.other.T_init;
            thermal.T_winding_max = self.data_vec.other.T_init;
            thermal.T_winding_avg = self.data_vec.other.T_init;
            thermal.T_iso_max = self.data_vec.other.T_init;
            thermal.T_max = self.data_vec.other.T_init;
            
            operating.thermal = thermal;
            operating.is_valid_thermal = self.check_thermal_limit(thermal);;
        end
        
        function operating = get_thermal(self, operating)            
            % operating
            T_ambient = operating.excitation.T_ambient;
            P_core = operating.losses.P_core;
            P_winding = operating.losses.P_winding;
            
            % run
            excitation_tmp = struct('P_winding', P_winding, 'P_core', P_core);
            [is_valid_tmp, fom_tmp] = self.ann_fem_obj.get_ht(excitation_tmp);
            
            % max
            dT_mat = [fom_tmp.dT_core_max ; fom_tmp.dT_core_avg ; fom_tmp.dT_winding_max ; fom_tmp.dT_winding_avg ; fom_tmp.dT_iso_max];
            dT_max = max(dT_mat, [], 1);
            
            % assign
            thermal.T_core_max = T_ambient+fom_tmp.dT_core_max;
            thermal.T_core_avg = T_ambient+fom_tmp.dT_core_avg;
            thermal.T_winding_max = T_ambient+fom_tmp.dT_winding_max;
            thermal.T_winding_avg = T_ambient+fom_tmp.dT_winding_avg;
            thermal.T_iso_max = T_ambient+fom_tmp.dT_iso_max;
            thermal.T_max = T_ambient+dT_max;
            
            % check
            operating.thermal = thermal;
            operating.is_valid_thermal = is_valid_tmp&self.check_thermal_limit(thermal);
        end
        
        function [T_vec, is_valid] = get_thermal_vec(self, operating)
            T_vec = [...
                operating.thermal.T_core_max;...
                operating.thermal.T_core_avg;...
                operating.thermal.T_winding_max;...
                operating.thermal.T_winding_avg;...
                operating.thermal.T_iso_max;...
                operating.thermal.T_max;...
                ];
            is_valid = all(isfinite(T_vec), 1);
        end
        
        function [P_vec, is_valid] = get_losses_vec(self, operating)
            P_vec = [...
                operating.losses.P_core;...
                operating.losses.P_winding;...
                operating.losses.P_add;...
                operating.losses.P_tot;...
                ];
            is_valid = all(isfinite(P_vec), 1);
        end
        
        function operating = get_losses(self, operating)
            B_norm = self.fom.circuit.B_norm;
            J_norm = self.fom.circuit.J_norm;
            H_norm = self.fom.circuit.H_norm;
            
            I_dc = operating.excitation.I_dc;
            I_ac_peak = operating.excitation.I_ac_peak;
            T_core_avg = operating.thermal.T_core_avg;
            T_winding_avg = operating.thermal.T_winding_avg;
            f = operating.excitation.f;
            is_pwm = operating.excitation.is_pwm;
            d_c = operating.excitation.d_c;

            J_dc = J_norm.*I_dc;
            B_dc = B_norm.*I_dc;
            H_dc = H_norm.*I_dc;
            J_ac_peak = J_norm.*I_ac_peak;
            H_ac_peak = H_norm.*I_ac_peak;
            B_ac_peak = B_norm.*I_ac_peak;
            
            if is_pwm==true
                [is_valid_core, P_core] = self.core_obj.get_losses_tri(f, d_c, B_ac_peak, B_dc, T_core_avg);
                [is_valid_winding, P_winding, P_dc, P_ac_lf, P_ac_hf] = self.winding_obj.get_losses_tri(f, d_c, J_dc, J_ac_peak, H_ac_peak, T_winding_avg);
            else
                [is_valid_core, P_core] = self.core_obj.get_losses_sin(f, B_ac_peak, B_dc, T_core_avg);
                [is_valid_winding, P_winding, P_dc, P_ac_lf, P_ac_hf] = self.winding_obj.get_losses_sin(f, J_dc, J_ac_peak, H_ac_peak, T_winding_avg);
            end
            
            P_scale = self.data_vec.fom_data.P_scale;
            P_offset = self.data_vec.fom_data.P_offset;
            P_add = P_offset+(1-P_scale).*(P_core+P_winding);
            
            operating.losses.P_core = P_core;
            operating.losses.P_winding = P_winding;
            operating.losses.P_winding_dc = P_dc;
            operating.losses.P_winding_ac_lf = P_ac_lf;
            operating.losses.P_winding_ac_hf = P_ac_hf;
            operating.losses.P_add = P_add;
            operating.losses.P_tot = P_add+P_core+P_winding;

            operating.field.J_dc = J_dc;
            operating.field.B_dc = B_dc;
            operating.field.H_dc = H_dc;
            operating.field.J_ac_peak = J_ac_peak;
            operating.field.H_ac_peak = H_ac_peak;
            operating.field.B_ac_peak = B_ac_peak;
            
            operating.fact.fact_hf_winding = P_ac_hf./P_ac_lf;
            operating.fact.fact_core_winding = P_core./P_winding;
            operating.fact.fact_ac_dc = I_ac_peak./I_dc;
                        
            operating.is_valid_core = is_valid_core;
            operating.is_valid_winding = is_valid_winding;
        end
        
        function is_valid_thermal = check_thermal_limit(self, operating)
            % check
            T_core_max = self.core_obj.get_temperature();
            T_winding_max = self.winding_obj.get_temperature();
            T_iso_max = self.iso_obj.get_temperature();
            
            is_valid_core = (operating.T_core_max<=T_core_max)&(operating.T_core_avg<=T_core_max);
            is_valid_winding = (operating.T_winding_max<=T_winding_max)&(operating.T_winding_avg<=T_winding_max);
            is_valid_iso = operating.T_iso_max<=T_iso_max;
            
            % assign
            is_valid_thermal = is_valid_core&is_valid_winding&is_valid_iso;
        end
    end
end