classdef AnnFemMf < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        ann_input
        ann_data
        const
        fct_param
        fct_out_approx
        ann_manager_obj
    end
    
    %% init
    methods (Access = public)
        function self = AnnFemMf(data_ann)
            % assign input
            self.ann_input = data_ann.ann_input;
            self.ann_data = data_ann.ann_data;
            self.const = data_ann.const;
            self.fct_param = data_ann.fct_param;
            self.fct_out_approx = data_ann.fct_out_approx;
            
            % load
            self.ann_manager_obj = AnnManager(self.ann_input);
            self.ann_manager_obj.load(self.ann_data)
        end
        
        function get_rel_geom()
            
            
            
        end
        
        function [is_valid, geom, fom] = run_rel_geom(self, n_sol, geom_rel)
            const_tmp = get_struct_size(self.const, n_sol);
            param = get_struct_merge(geom_rel, const_tmp);
            
            [is_valid_param, param] = self.fct_param(param);
            out_approx = self.fct_out_approx(param);
            [is_valid_fom, fom] = self.ann_manager_obj.predict(n_sol, geom_rel, out_approx);
            is_valid = is_valid_param&is_valid_fom;
            
            geom = self.get_geom(param);
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
