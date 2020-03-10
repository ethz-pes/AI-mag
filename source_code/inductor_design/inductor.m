classdef inductor < handle
    %% init
    properties (SetAccess = immutable, GetAccess = private)
        n_sol
        data
        ann_fem_mf_obj
        ann_fem_ht_obj
    end
    properties (SetAccess = private, GetAccess = private)        
        is_valid        
        fom                
        transformer_plot_obj
        transformer_losses_obj
        transformer_thermal_obj
        iter_thermal_losses_obj
    end
    
    %% init
    methods (Access = public)
        function self = inductor(n_sol, data, ann_fem_mf_obj, ann_fem_ht_obj)
            % parse the data
            self.n_sol = n_sol;
            self.data = data;            
            self.ann_fem_mf_obj = ann_fem_mf_obj;            
            self.ann_fem_ht_obj = ann_fem_ht_obj;            
            
            
            keyboard
            
            var_type.geom = 'abs';
var_type.excitation = 'rel';

            
            [is_valid, fom] = ann_fem_mf_obj.run_inp(var_type, n_sol, self.data.geom);

            
            self.init_data();
        end
        
        function fom = get_fom(self)
            fom = utils.unfilter_struct(self.fom, self.is_valid);
            fom.is_valid = self.is_valid;
        end

        function fig = get_plot(self, name, idx)
            validateattributes(name, {'char'}, {'nonempty'})
            validateattributes(idx, {'double', 'logical'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            assert(any(idx==(1:self.n_sol)), 'invalid data')

            is_select = find(self.is_valid)==idx;
            fig = self.transformer_plot_obj.get_plot(name, is_select);
        end

        function operating = get_operating(self, excitation)     
            % parse
            excitation = utils.input_struct(excitation, self.n_sol);
            excitation = utils.filter_struct(excitation, self.is_valid);
            
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
    end
end