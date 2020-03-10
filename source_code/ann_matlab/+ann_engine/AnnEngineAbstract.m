classdef AnnEngineAbstract < handle    
    %% init
    methods (Access = public)
        function self = AnnEngineAbstract()
            % pass
        end
    end
    
    %% public abstract api
    methods (Abstract, Access=public)
        [model, history] = train(self, tag_train, inp, out)
        unload(self, name)
        load(self, name, model, history)
        out = predict(self, name, inp)
    end
end