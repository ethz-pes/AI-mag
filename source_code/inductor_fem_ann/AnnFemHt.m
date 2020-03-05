classdef AnnFemHt < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        data_ann
        const
        ann_manager_obj
    end
    
    %% init
    methods (Access = public)
        function self = AnnFemHt(data_ann)
            % assign input
            self.data_ann = data_ann;
            
            % load
            self.const = self.data_ann.const;
            assert(strcmp(self.data_ann.model_type, 'ht'), 'invalid model_type')
            self.ann_manager_obj = AnnManager(self.data_ann.ann_input);
            self.ann_manager_obj.load(self.data_ann.ann_data);
        end
        
        function [is_valid, fom] = run(self, n_sol, geom, geom_type, P_winding, P_core)
            % parse input
            const = get_struct_size(self.const, n_sol);
            geom = get_struct_merge(geom, const);
            geom = get_geom(geom, geom_type);

            % assign geom_rel
            inp.volume_target = geom.volume_target;
            inp.fact_core = geom.fact_core;
            inp.fact_window = geom.fact_window;
            inp.fact_core_window = geom.fact_core_window;
            inp.fact_gap = geom.fact_gap;
            
            % assign power
            A_box = 6.*inp.volume_target.^(2./3);
            P_tot = P_winding+P_core;
            inp.ht_stress = P_tot./A_box;
            inp.ht_sharing = P_winding./P_core;

            % fom
            [is_valid, fom] = get_fom('ht', self.const, self.ann_manager_obj, n_sol, inp);
        end
    end
end
