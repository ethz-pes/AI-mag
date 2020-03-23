classdef Test < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        pts
    end
    
    %% init
    methods (Access = public)
        function self = Test()
            close all;
            figure();
            fct = @(obj, event) self.getPoint(obj, event);
            scatter(rand(1, 10e3), rand(1, 10e3), 'ButtonDownFcn', fct);
            hold on
            self.pts = plot(0, 0, 'xr', 'Visible', 'off');
        
        end
        
        function getPoint(self, obj, event)
            currentPoint = get(gca, 'CurrentPoint');
            x = currentPoint(1,1);
            y = currentPoint(1,2);

            x_vec = obj.XData;
            y_vec = obj.YData;
            d = hypot(x-x_vec, y-y_vec);
            [v, idx] = min(d);
            
            set(self.pts, 'XData', x_vec(idx));
            set(self.pts, 'YData', y_vec(idx));
            set(self.pts, 'Visible', 'on');
            
            
        end
    end
end