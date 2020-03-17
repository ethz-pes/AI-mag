classdef IsoData < handle
    %% properties
    properties (SetAccess = private, GetAccess = public)
        param
    end
    
    %% init
    methods (Access = public)
        function self = IsoData(material, id)
            assert(strcmp(material.type, 'iso'), 'invalid length')

            % assign input
            for i=1:length(material.data)
                ix_vec(i) = i;
                id_vec(i) = material.data{i}.id;
                
                param_tmp{i} = material.data{i}.material;
            end

            idx = get_integer_map(id_vec, ix_vec, id);
            param_tmp = [param_tmp{:}];
            param_tmp = get_struct_assemble(param_tmp);
            self.param = get_struct_filter(param_tmp, idx);
        end
        
        function m = get_mass(self)
            m = self.param.rho;
        end
        
        function cost = get_cost(self)
            cost = self.param.lambda;
        end
        
        function T_max = get_temperature(self)
            T_max = self.param.T_max;
        end
    end
end
