function get_scatter()


close all;

figure();

scatter([12 5 74 2], [44 22 11 11], 'ButtonDownFcn', @getPoint);



end

    function getPoint(varargin)
    keyboard
        currentPoint = get(gca, 'CurrentPoint');
        fprintf('Hit Point! Coordinates: %f, %f \n', ...
            currentPoint(1), currentPoint(3));
        
    end
