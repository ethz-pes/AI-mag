classdef AnnFem < handle
    %% properties
    properties (SetAccess = immutable, GetAccess = public)
        ann_input
        ann_data
        model_type
        var_type
        const
        
        ann_manager_obj
    end
    
    %% init
    methods (Access = public)
        function self = AnnFem(data)
            % assign input
            self.ann_input = data.ann_input;
            self.ann_data = data.ann_data;
            self.model_type = data.model_type;
            self.var_type = data.var_type;
            self.const = data.const;

            % load
            self.ann_manager_obj = AnnManager(self.ann_input);
            self.ann_manager_obj.load(self.ann_data);
        end
                
        function [is_valid, inp] = run_inp(self, var_type, n_sol, inp)
            [is_valid, inp] = get_extend_inp(self.const, self.model_type, var_type, n_sol, inp);
        end
        
        function [is_valid, fom] = run_ann(self, var_type, n_sol, inp)
            [is_valid, inp] = get_extend_inp(self.const, self.model_type, var_type, n_sol, inp);
            [is_valid, fom] = get_fom(self.ann_manager_obj, self.model_type, n_sol, inp, is_valid, 'ann');
        end

        function [is_valid, inp, fom] = run_approx(self, var_type, n_sol, inp)
            [is_valid, inp] = get_extend_inp(self.const, self.model_type, var_type, n_sol, inp);
            [is_valid, fom] = get_fom(self.ann_manager_obj, self.model_type, n_sol, inp, is_valid, 'approx');
        end
    end
end
