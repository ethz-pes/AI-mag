classdef InductorDesign < handle
    %% init
    properties (SetAccess = immutable, GetAccess = private)
        n_sol
        data_vec
        data_const
        data_material
        ann_fem_obj
    end
    properties (SetAccess = private, GetAccess = private)
        is_valid
        fom
        core_obj
        winding_obj
        iso_obj
        thermal_losses_obj
    end
    
    %% init
    methods (Access = public)
        function self = InductorDesign(n_sol, data_vec, data_material, data_const, ann_fem_obj)
            % parse the data
            self.n_sol = n_sol;
            self.data_vec = data_vec;            
            self.data_material = data_material;            
            self.data_const = data_const;            
            self.ann_fem_obj = ann_fem_obj;
            
            % init
            self.data_vec = get_struct_size(self.data_vec, self.n_sol);
            self.is_valid = true(1, self.n_sol);
            
            % set
            self.ann_fem_obj.set_geom(self.n_sol, self.data_vec.geom);
            [is_valid_tmp, geom] = self.ann_fem_obj.get_geom();
            self.is_valid = self.is_valid&is_valid_tmp;
            
            self.core_obj = CoreData(self.data_material.core, self.data_vec.material.core_id, geom.V_core);
            self.winding_obj = WindingData(self.data_material.winding, self.data_vec.material.winding_id, geom.V_winding);
            self.iso_obj = IsoData(self.data_material.iso, self.data_vec.material.iso_id, geom.V_iso);
            

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
            
            self.fom.volume.V_iso = geom.V_iso;
            self.fom.volume.V_core = geom.V_core;
            self.fom.volume.V_winding = geom.V_winding;
            self.fom.volume.V_box = self.data_vec.fom_data.V_offset+self.data_vec.fom_data.V_scale.*geom.V_box;
                        
            self.fom.mass.m_iso = self.iso_obj.get_mass();
            self.fom.mass.m_core = self.core_obj.get_mass();
            self.fom.mass.m_winding = self.winding_obj.get_mass();
            self.fom.mass.m_box = self.data_vec.fom_data.m_offset+self.data_vec.fom_data.m_scale.*(self.fom.mass.m_iso+self.fom.mass.m_core+self.fom.mass.m_winding);

            self.fom.cost.c_iso = self.iso_obj.get_cost();
            self.fom.cost.c_core = self.core_obj.get_cost();
            self.fom.cost.c_winding = self.winding_obj.get_cost();
            self.fom.cost.c_box = self.data_vec.fom_data.c_offset+self.data_vec.fom_data.c_scale.*(self.fom.cost.c_iso+self.fom.cost.c_core+self.fom.cost.c_winding);
            
            I_winding = self.fom.geom.n_turn.*self.data_vec.other.I_test;
            [is_valid_tmp, fom] = self.ann_fem_obj.get_mf(I_winding);
            self.is_valid = self.is_valid&is_valid_tmp;
            
            self.fom.circuit.B_norm = self.fom.geom.n_turn.*fom.B_norm;
            self.fom.circuit.J_norm = self.fom.geom.n_turn.*fom.J_norm;
            self.fom.circuit.H_norm = self.fom.geom.n_turn.*fom.H_norm;
            self.fom.circuit.L = self.fom.geom.n_turn.^2.*fom.L_norm;
            self.fom.circuit.I_peak = self.core_obj.get_flux_density()./(self.fom.geom.n_turn.*fom.B_norm);
            self.fom.circuit.I_rms = (self.winding_obj.get_current_density())./(self.fom.geom.n_turn.*fom.J_norm);
            
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.volume.V_box, self.data_vec.fom_limit.V_box);
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.cost.c_box, self.data_vec.fom_limit.c_box);
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.mass.m_box, self.data_vec.fom_limit.m_box);
            
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.circuit.L, self.data_vec.fom_limit.L);
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.circuit.I_peak, self.data_vec.fom_limit.I_peak);
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.circuit.I_rms, self.data_vec.fom_limit.I_rms);
            
            
            
            fct.operating_init = self.get_thermal_init();
            fct.get_thermal = @(operating, excitation) self.get_thermal(operating, excitation);
            fct.get_losses = @(operating, excitation) self.get_losses(operating, excitation);
            fct.get_thermal_vec = @(operating) self.get_thermal_vec(operating);
            fct.get_losses_vec = @(operating) self.get_losses_vec(operating);
            self.thermal_losses_obj = ThermalLoss(self.data_const.iter, fct);

        end
        
        function [is_valid, fom] = get_fom(self)
            fom = self.fom;
            is_valid = self.is_valid;
        end

        function fig = get_plot(self, name, idx)
            validateattributes(name, {'char'}, {'nonempty'})
            validateattributes(idx, {'double', 'logical'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            assert(any(idx==(1:self.n_sol)), 'invalid data')

            is_select = find(self.is_valid)==idx;
            fig = get_plot_inductor(name, self.fom.geom, is_select);
        end

        function operating = get_operating(self, excitation)
            % parse
            excitation = get_struct_size(excitation, self.n_sol);
            excitation = get_struct_filter(excitation, self.is_valid);
                                    
            % iter
            [operating, is_valid_iter] = self.thermal_losses_obj.get_iter(excitation);
            
            is_valid_thermal = operating.thermal.is_valid_thermal;
            is_valid_core = operating.losses.is_valid_core;
            is_valid_winding = operating.losses.is_valid_winding;
            
            operating.is_valid_iter = is_valid_iter;
            operating.is_valid = is_valid_iter&is_valid_thermal&is_valid_core&is_valid_winding;
                        
            % parse
            operating = get_struct_unfilter(operating, self.is_valid);            
        end
    end
    
    %% private api / init
    methods (Access = private)
        function operating = get_thermal_init(self)
            thermal.T_core_max = self.data_vec.other.T_init;
            thermal.T_core_avg = self.data_vec.other.T_init;
            thermal.T_winding_max = self.data_vec.other.T_init;
            thermal.T_winding_avg = self.data_vec.other.T_init;
            thermal.T_iso_max = self.data_vec.other.T_init;
            thermal.is_valid_thermal = self.check_thermal_limit(thermal);
            
            operating.thermal = thermal;
        end
        
        function operating = get_thermal(self, operating, excitation)
            % excitation
            T_ambient = excitation.T_ambient;
            
            % operating
            P_core = operating.losses.P_core;
            P_winding = operating.losses.P_winding;
            
            % run
            [is_valid_tmp, fom_tmp] = self.ann_fem_obj.get_ht(P_winding, P_core);
            
            % assign
            thermal.T_core_max = T_ambient+fom_tmp.dT_core_max;
            thermal.T_core_avg = T_ambient+fom_tmp.dT_core_avg;
            thermal.T_winding_max = T_ambient+fom_tmp.dT_winding_max;
            thermal.T_winding_avg = T_ambient+fom_tmp.dT_winding_avg;
            thermal.T_iso_max = T_ambient+fom_tmp.dT_iso_max;
            thermal.is_valid_thermal = is_valid_tmp&self.check_thermal_limit(thermal);
            
            operating.thermal = thermal;
        end
        
        function [T_vec, is_valid] = get_thermal_vec(self, operating)
            T_vec = [...
                operating.thermal.T_core_max;...
                operating.thermal.T_core_avg;...
                operating.thermal.T_winding_max;...
                operating.thermal.T_winding_avg;...
                operating.thermal.T_iso_max;...
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
        
        function operating = get_losses(self, operating, excitation)            
            I_dc = excitation.I_dc;
            I_ac_peak = excitation.I_ac_peak;
            B_norm = self.fom.circuit.B_norm;
            J_norm = self.fom.circuit.J_norm;
            H_norm = self.fom.circuit.H_norm;
            
            T_core_avg = operating.thermal.T_core_avg;
            T_winding_avg = operating.thermal.T_winding_avg;
            
            J_dc = J_norm.*I_dc;
            B_dc = B_norm.*I_dc;
            J_ac_peak = J_norm.*I_ac_peak;
            H_ac_peak = H_norm.*I_ac_peak;
            B_ac_peak = B_norm.*I_ac_peak;
            
            switch self.data_const.waveform_type
                case 'sin'
                    f = excitation.f;
                    
                    [is_valid_core, P_core] = self.core_obj.get_losses_sin(f, B_ac_peak, B_dc, T_core_avg);
                    [is_valid_winding, P_winding, P_dc, P_ac_lf, P_ac_hf] = self.winding_obj.get_losses_sin(f, J_dc, J_ac_peak, H_ac_peak, T_winding_avg);
                case 'tri'
                    f = excitation.f;
                    d_c = excitation.d_c;
                    
                    [is_valid_core, P_core] = self.core_obj.get_losses_tri(f, d_c, B_ac_peak, B_dc, T_core_avg);
                    [is_valid_winding, P_winding, P_dc, P_ac_lf, P_ac_hf] = self.winding_obj.get_losses_tri(f, d_c, J_dc, J_ac_peak, H_ac_peak, T_winding_avg);
                otherwise
                    error('invalid data')
            end
            
            P_fraction = self.data_vec.fom_data.P_fraction;
            P_offset = self.data_vec.fom_data.P_offset;
           P_add = P_offset+P_fraction.*(P_core+P_winding);
            
            operating.losses.is_valid_core = is_valid_core;
            operating.losses.is_valid_winding = is_valid_winding;
            operating.losses.P_core = P_core;
            operating.losses.P_winding = P_winding;
            operating.losses.P_winding_dc = P_dc;
            operating.losses.P_winding_ac_lf = P_ac_lf;
            operating.losses.P_winding_ac_hf = P_ac_hf;
            operating.losses.P_add = P_add;
            operating.losses.P_tot = P_add+P_core+P_winding;

            operating.field.J_dc = J_dc;
            operating.field.B_dc = B_dc;
            operating.field.J_ac_peak = J_ac_peak;
            operating.field.H_ac_peak = H_ac_peak;
            operating.field.B_ac_peak = B_ac_peak;
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
        
        
        function is_valid_tmp = init_is_valid_check(self, vec, limit)
            % check the validity
            is_valid_min = vec>=limit.min;
            is_valid_max = vec<=limit.max;
            is_valid_tmp = is_valid_min&is_valid_max;
        end
        
    end
end