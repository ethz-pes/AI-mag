classdef AnnFem < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        data_ann_mf
        data_ann_ht

        const_mf
        const_ht
        
        ann_manager_mf_obj
        ann_manager_ht_obj
    end
    
    %% init
    methods (Access = public)
        function self = AnnFem(data_ann_mf, data_ann_ht)
            % assign input
            self.data_ann_mf = data_ann_mf;
            self.data_ann_ht = data_ann_ht;
            
            % mf
            self.const_mf = self.data_ann_mf.const;
            assert(strcmp(self.data_ann_mf.model_type, 'mf'), 'invalid model_type')
            self.ann_manager_mf_obj = AnnManager(self.data_ann_mf.ann_input);
            self.ann_manager_mf_obj.load(self.data_ann_mf.ann_data);

            % ht
            self.const_ht = self.data_ann_ht.const;
            assert(strcmp(self.data_ann_ht.model_type, 'ht'), 'invalid model_type')
            self.ann_manager_ht_obj = AnnManager(self.data_ann_ht.ann_input);
            self.ann_manager_ht_obj.load(self.data_ann_ht.ann_data);
        end

        function [is_valid, geom, fom] = run_mf(self, n_sol, inp)
            
            self.run_sub('mf', self.const_mf, self.ann_manager_mf_obj, n_sol, inp);
            
        end
        
        function [is_valid, fom] = run_sub(self, model_type, const, ann_manager_obj, n_sol, inp)
            % geometry
            geom = get_struct_size(const.geom, n_sol);
            physics = get_struct_size(const.physics, n_sol);
            
            % geom
            [is_valid_geom, geom] = get_geom(inp, geom);
            [is_valid_physics, physics] = get_physics(model_type, inp, physics);

            % approx
            out_approx = get_out_approx(model_type, geom, physics);
            
            % ann
            [is_valid_fom, out_ann] = ann_manager_obj.predict(n_sol, inp, out_approx);

            % data
            is_valid = is_valid_geom&is_valid_physics&is_valid_fom;
            


        end
                
        function geom = get_geom(self, param)
            geom.fact_window = param.fact_window;
            geom.fact_core = param.fact_core;
            geom.fact_core_window = param.fact_core_window;
            geom.fact_gap = param.fact_gap;
            
            geom.S_box = param.S_box;
            geom.V_box = param.V_box;
            
            geom.t_core = param.t_core;
            geom.z_core = param.z_core;
            geom.d_gap = param.d_gap;
            geom.x_window = param.x_window;
            geom.y_window = param.y_window;
            geom.d_iso = param.d_iso;
            geom.r_curve = param.r_curve;
            
            geom.A_core = param.A_core;
            geom.A_winding = param.A_winding;
            
            geom.V_winding = param.V_winding;
            geom.V_core = param.V_core;
        end
    end
end
