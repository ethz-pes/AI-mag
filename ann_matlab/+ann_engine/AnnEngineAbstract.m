classdef AnnEngineAbstract < handle    
    %% init
    methods (Access = public)
        function self = AnnEngineAbstract()
            % pass
        end
    end
    
    %% public abstract api
    methods (Abstract, Access=public)
        [model, history] = train(self, inp, out, tag)
        clean(self)
        load(self, name, model, history)
        out = predict(self, name, inp)
    end
end