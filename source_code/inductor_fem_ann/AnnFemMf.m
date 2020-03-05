classdef AnnFemMf < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        data_ann
        const
        ann_manager_obj
    end
    
    %% init
    methods (Access = public)
        function self = AnnFemMf(data_ann)
            % assign input
            self.data_ann = data_ann;
            
            % load
            self.const = self.data_ann.const;
            assert(strcmp(self.data_ann.model_type, 'mf'), 'invalid model_type')
            self.ann_manager_obj = AnnManager(self.data_ann.ann_input);
            self.ann_manager_obj.load(self.data_ann.ann_data);
        end
        
        function [is_valid, fom] = run(self, n_sol, geom, geom_type)
            % parse input
            geom = get_geom(geom, geom_type);

            % assign geom_rel
            inp.volume_target = geom.volume_target;
            inp.fact_core = geom.fact_core;
            inp.fact_window = geom.fact_window;
            inp.fact_core_window = geom.fact_core_window;
            inp.fact_gap = geom.fact_gap;
            inp.fact_gap2 = rand(1, n_sol);

            % fom
            [is_valid, fom] = get_fom('mf', self.const, self.ann_manager_obj, n_sol, inp);
        end
    end
end
