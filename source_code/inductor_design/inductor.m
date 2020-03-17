classdef inductor < handle
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
    end
    
    %% init
    methods (Access = public)
        function self = inductor(n_sol, data_vec, data_material, data_const, ann_fem_obj)
            % parse the data
            self.n_sol = n_sol;
            self.data_vec = data_vec;            
            self.data_material = data_material;            
            self.data_const = data_const;            
            self.ann_fem_obj = ann_fem_obj;
            

            self.core_obj = CoreData(self.data_material.core, self.data_vec.core_id);
            self.winding_obj = WindingData(self.data_material.winding, self.data_vec.winding_id);
            self.iso_obj = IsoData(self.data_material.iso, self.data_vec.iso_id);


            % init
            self.data_vec = get_struct_size(self.data_vec, self.n_sol);
            self.is_valid = true(1, self.n_sol);
            
            % set
            self.ann_fem_obj.set_geom(self.n_sol, self.data_vec.geom);
            [is_valid_tmp, geom] = self.ann_fem_obj.get_geom();
            self.is_valid = self.is_valid&is_valid_tmp;
            
            self.fom.geom.z_core = geom.z_core;
            self.fom.geom.t_core = geom.t_core;
            self.fom.geom.x_window = geom.x_window;
            self.fom.geom.y_window = geom.y_window;
            self.fom.geom.d_gap = geom.d_gap;
            self.fom.geom.d_iso = geom.d_iso;
            self.fom.geom.r_curve = geom.r_curve;
            
            self.fom.area.A_core = geom.A_core;
            self.fom.area.A_winding = geom.A_winding;
            self.fom.area.A_box = geom.A_box;
            
            self.fom.volume.V_iso = geom.V_iso;
            self.fom.volume.V_core = geom.V_core;
            self.fom.volume.V_winding = geom.V_winding;
            self.fom.volume.V_box = geom.V_box;
           
            self.fom.mass.m_iso = self.fom.volume.V_iso.*self.iso_obj.get_mass();
            self.fom.mass.m_core = self.fom.volume.V_core.*self.core_obj.get_mass();
            self.fom.mass.m_winding = self.fom.volume.V_winding.*self.winding_obj.get_mass();
            self.fom.mass.m_box = self.fom.mass.m_iso+self.fom.mass.m_core+self.fom.mass.m_winding;

            self.fom.cost.c_iso = self.fom.volume.V_iso.*self.iso_obj.get_cost();
            self.fom.cost.c_core = self.fom.volume.V_core.*self.core_obj.get_cost();
            self.fom.cost.c_winding = self.fom.volume.V_winding.*self.winding_obj.get_cost();
            self.fom.cost.c_box = self.fom.cost.c_iso+self.fom.cost.c_core+self.fom.cost.c_winding;
            
            self.fom.n_turn = self.data_vec.n_turn;

            I_winding = self.data_vec.n_turn.*self.data_vec.I_test;
            [is_valid_tmp, fom] = self.ann_fem_obj.get_mf(I_winding);
            self.is_valid = self.is_valid&is_valid_tmp;
            
            self.fom.circuit.L = self.data_vec.n_turn.^2.*fom.L_norm;
            self.fom.circuit.I_peak = self.core_obj.get_flux_density()./(self.data_vec.n_turn.*fom.B_norm);
            self.fom.circuit.I_rms = (self.winding_obj.get_current_density())./(self.data_vec.n_turn.*fom.J_norm);
            
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.volume.V_box, self.data_vec.fom_limit.V_box);
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.cost.c_box, self.data_vec.fom_limit.c_box);
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.mass.m_box, self.data_vec.fom_limit.m_box);
            
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.circuit.L, self.data_vec.fom_limit.L);
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.circuit.I_peak, self.data_vec.fom_limit.I_peak);
            self.is_valid = self.is_valid&self.init_is_valid_check(self.fom.circuit.I_rms, self.data_vec.fom_limit.I_rms);
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
            [operating, is_valid_iter] = self.iter_thermal_losses_obj.get_iter(excitation);
            operating.is_valid_iter = is_valid_iter;
            operating.is_valid = is_valid_iter&operating.is_valid_thermal&operating.is_valid_losses;
            
            % parse
            operating = utils.unfilter_struct(operating, self.is_valid);
            is_valid_tmp = utils.valid_struct(operating, self.n_sol);
            operating.is_valid = operating.is_valid&is_valid_tmp;
        end
    end
    
    %% private api / init
    methods (Access = private)
        function init_data(self)            
            % filter input
            geom_data = utils.input_struct(self.data.geom_data, self.n_sol);
            winding = utils.input_struct(self.data.winding, self.n_sol);
            iso = utils.input_struct(self.data.iso, self.n_sol);
            core = utils.input_struct(self.data.core, self.n_sol);
            fom_data = utils.input_struct(self.data.fom_data, self.n_sol);
            fom_limit = utils.input_struct(self.data.fom_limit, self.n_sol);
            thermal = utils.input_struct(self.data.thermal, self.n_sol);
            offset = self.data.offset;
            iter = self.data.iter;

            % is_valid
            is_valid_tmp = true(1, self.n_sol);
            
            % get the size
            obj = transformer_size(geom_data, winding, iso, core, is_valid_tmp);
            is_valid_tmp = is_valid_tmp&obj.get_is_valid();
            size = obj.get_size();
            
            % get the geom
            obj = transformer_geom(geom_data, winding, iso, core, size, is_valid_tmp);
            is_valid_tmp = is_valid_tmp&obj.get_is_valid();
            geom_tmp = obj.get_geom();
                        
            % get the fom and circuit
            obj = transformer_fom(geom_tmp, winding, iso, core, fom_data, fom_limit);
            is_valid_tmp = is_valid_tmp&obj.get_is_valid();
            fom_tmp = obj.get_fom();
            
            % check data
            is_valid_tmp = is_valid_tmp&utils.valid_struct(geom_tmp, self.n_sol);
            is_valid_tmp = is_valid_tmp&utils.valid_struct(winding, self.n_sol);
            is_valid_tmp = is_valid_tmp&utils.valid_struct(iso, self.n_sol);
            is_valid_tmp = is_valid_tmp&utils.valid_struct(core, self.n_sol);
            is_valid_tmp = is_valid_tmp&utils.valid_struct(thermal, self.n_sol);
            is_valid_tmp = is_valid_tmp&utils.valid_struct(fom_tmp, self.n_sol);
            is_valid_tmp = is_valid_tmp&utils.valid_struct(geom_tmp, self.n_sol);
            
            % filter data
            geom_tmp = utils.filter_struct(geom_tmp, is_valid_tmp);
            winding = utils.filter_struct(winding, is_valid_tmp);
            iso = utils.filter_struct(iso, is_valid_tmp);
            core = utils.filter_struct(core, is_valid_tmp);
            thermal = utils.filter_struct(thermal, is_valid_tmp);
            fom_tmp = utils.filter_struct(fom_tmp, is_valid_tmp);

            % create the object
            n_valid = nnz(is_valid_tmp);
            self.transformer_plot_obj = transformer_plot(n_valid, geom_tmp);
            self.transformer_losses_obj = transformer_losses(n_valid, geom_tmp, winding, iso, core, offset);
            self.transformer_thermal_obj = transformer_thermal(n_valid, geom_tmp, winding, iso, core, thermal);
            
            % iter
            fct.operating_init = self.transformer_thermal_obj.get_thermal_init();
            fct.get_thermal = @(operating, excitation) self.transformer_thermal_obj.get_thermal(operating, excitation);
            fct.get_losses = @(operating, excitation) self.transformer_losses_obj.get_losses(operating, excitation);
            fct.get_thermal_vec = @(operating) self.transformer_thermal_obj.get_thermal_vec(operating);
            fct.get_losses_vec = @(operating) self.transformer_losses_obj.get_losses_vec(operating);          
            self.iter_thermal_losses_obj = iter_thermal_losses(iter, fct);
            
            % assign
            self.is_valid = is_valid_tmp;
            self.fom = fom_tmp;
        end
        
        function is_valid_tmp = init_is_valid_check(self, vec, limit)
            % check the validity
            is_valid_min = vec>=limit.min;
            is_valid_max = vec<=limit.max;
            is_valid_tmp = is_valid_min&is_valid_max;
        end
        
    end
end