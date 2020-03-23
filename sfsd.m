function sfsd()

close all;

figure();

dcm_obj = datacursormode(gcf);
dcm_obj.Enable = 'on';
dcm_obj.DisplayStyle = 'window';

set(dcm_obj,'UpdateFcn',{@update_fct, []})

% scatter([12 5 74 2], [44 22 11 11], 'ButtonDownFcn', @getPoint);
scatter([12 5 74 2], [44 22 11 11]);



end

function getPoint(varargin)
currentPoint = get(gca, 'CurrentPoint');
fprintf('Hit Point! Coordinates: %f, %f \n', ...
    currentPoint(1), currentPoint(3));

end


function txt = update_fct(none, event_obj, sol)

idx = get(event_obj, 'DataIndex');

txt = {};
txt{end+1} = 'test1';
txt{end+1} = 'test2';
txt{end+1} = 'test2';
txt{end+1} = 'test2';
txt{end+1} = 'test2';
txt{end+1} = 'test2';

end
