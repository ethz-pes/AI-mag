classdef AnnFem < handle
    %% properties
    properties (SetAccess = immutable, GetAccess = public)
        const
        ann_mf
        ann_ht
        eval_type
    end
    properties (SetAccess = private, GetAccess = public)
        ann_manager_ht_obj
        ann_manager_mf_obj
        is_geom
        geom_type
        n_sol
        geom
    end
    
    %% init
    methods (Access = public)
        function self = AnnFem(const, ann_mf, ann_ht, eval_type)
            % assign input      
            self.const = const;
            self.ann_mf = ann_mf;
            self.ann_ht = ann_ht;
            self.eval_type = eval_type;
            
            % mf
            assert(strcmp(ann_mf.model_type, 'mf'), 'invalid type')
            self.ann_manager_mf_obj = AnnManager(ann_mf.ann_input);
            self.ann_manager_mf_obj.load(ann_mf.ann_data);

            % ht
            assert(strcmp(ann_ht.model_type, 'ht'), 'invalid type')
            self.ann_manager_ht_obj = AnnManager(ann_ht.ann_input);
            self.ann_manager_ht_obj.load(ann_ht.ann_data);
            
            % run
            self.is_geom = false;
        end
        
        function set_geom(self, geom_type, n_sol, geom)
            self.geom_type = geom_type;
            self.n_sol = n_sol;
            self.geom = geom;
            self.is_geom = true;
        end
        
        function [is_valid, geom] = get_geom(self)
            % check state
            assert(self.is_geom==true, 'invalid state')
            
            % set data
            model_type = 'none';
            var_type = struct('geom_type', self.geom_type, 'excitation_type', []);
            
            % get data
            [is_valid, geom] = get_extend_inp(self.const, model_type, var_type, self.n_sol, self.geom);
        end
        
        function [is_valid, fom] = get_mf(self, I_winding)
            % check state
            assert(self.is_geom==true, 'invalid state')
            
            % set data
            model_type = 'mf';
            var_type = struct('geom_type', self.geom_type, 'excitation_type', 'abs');
            
            % get data
            excitation = struct('I_winding', I_winding);
            inp = get_struct_merge(self.geom, excitation);
            [is_valid, inp] = get_extend_inp(self.const, model_type, var_type, self.n_sol, inp);
            [is_valid, fom] = get_fom(self.ann_manager_mf_obj, model_type, self.n_sol, inp, is_valid, self.eval_type);
        end
        
        function [is_valid, fom] = get_ht(self, P_winding, P_core)
            % check state
            assert(self.is_geom==true, 'invalid state')
            
            % set data
            model_type = 'ht';
            var_type = struct('geom_type', self.geom_type, 'excitation_type', 'abs');
            
            % get data
            excitation = struct('P_winding', P_winding, 'P_core', P_core);
            inp = get_struct_merge(self.geom, excitation);
            [is_valid, inp] = get_extend_inp(self.const, model_type, var_type, self.n_sol, inp);
            [is_valid, fom] = get_fom(self.ann_manager_ht_obj, model_type, self.n_sol, inp, is_valid, self.eval_type);
        end
    end
end
