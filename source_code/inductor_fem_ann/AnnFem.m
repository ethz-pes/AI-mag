classdef AnnFem < handle
    %% properties
    properties (SetAccess = immutable, GetAccess = public)
        data_fem_ann
        geom_type
        eval_type
    end
    properties (SetAccess = private, GetAccess = public)
        ann_manager_ht_obj
        ann_manager_mf_obj
        is_geom
        n_sol
        geom
    end
    
    %% init
    methods (Access = public)
        function self = AnnFem(data_fem_ann, geom_type, eval_type)
            % assign input
            self.data_fem_ann = data_fem_ann;
            self.geom_type = geom_type;
            self.eval_type = eval_type;
            
            % ann
            self.ann_manager_mf_obj = self.get_ann_manager(self.data_fem_ann.ann_mf, 'mf');
            self.ann_manager_ht_obj = self.get_ann_manager(self.data_fem_ann.ann_ht, 'ht');
            
            % run
            self.is_geom = false;
        end
        
        function set_geom(self, n_sol, geom)
            self.n_sol = n_sol;
            self.geom = geom;
            self.is_geom = true;
        end
        
        function [is_valid, geom] = get_geom(self)
            % check state
            assert(self.is_geom==true, 'invalid state')
            
            % set data
            [is_valid, geom] = self.get_extend_inp_wrapper('none', self.geom);
        end
        
        function [is_valid, fom] = get_mf(self, I_winding)
            % check state
            assert(self.is_geom==true, 'invalid state')
                        
            % get data
            excitation = struct('I_winding', I_winding);
            inp = get_struct_merge(self.geom, excitation);
            
            [is_valid, inp] = self.get_extend_inp_wrapper('mf', inp);
            [is_valid, fom] = self.get_fom_wapper('mf', is_valid, inp);
        end
        
        function [is_valid, fom] = get_ht(self, P_winding, P_core)
            % check state
            assert(self.is_geom==true, 'invalid state')
                        
            % get data
            excitation = struct('P_winding', P_winding, 'P_core', P_core);
            inp = get_struct_merge(self.geom, excitation);
            
            [is_valid, inp] = self.get_extend_inp_wrapper('ht', inp);
            [is_valid, fom] = self.get_fom_wapper('ht', is_valid, inp);
        end
    end
    
    methods (Access = private)
        function ann_manager_obj = get_ann_manager(self, data, model_type)
            assert(strcmp(data.model_type, model_type), 'invalid type')
            ann_manager_obj = AnnManager(data.ann_input);
            ann_manager_obj.load(data.ann_data);
        end
        
        function [is_valid, inp] = get_extend_inp_wrapper(self, model_type, inp)
            switch model_type
                case 'none'
                    excitation_type = [];
                case {'mf', 'ht'}
                    excitation_type = 'abs';
                otherwise
                    error('invalid type')
            end
            
            var_type = struct('geom_type', self.geom_type, 'excitation_type', excitation_type);
            [is_valid, inp] = get_extend_inp(self.data_fem_ann.const, model_type, var_type, self.n_sol, inp);
        end
        
        function [is_valid, fom] = get_fom_wapper(self, model_type, is_valid, inp)
            switch model_type
                case 'mf'
                    ann_manager_obj = self.ann_manager_mf_obj;
                case 'ht'
                    ann_manager_obj = self.ann_manager_ht_obj;
                otherwise
                    error('invalid type')
            end

            [is_valid, fom] = get_fom(ann_manager_obj, model_type, self.n_sol, is_valid, inp, self.eval_type);
        end
    end
end
