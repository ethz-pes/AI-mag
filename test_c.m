function test_c()

close('all');

rho = rand(1, 100);
eta = rand(1, 100);
f = rand(1, 100);

fig = figure();
dcm_obj = datacursormode(fig);

% scatter(rho, eta, [], f, 'filled')
scatter(rho, eta)
% colorbar();

sol.d1 = 'some text 1';
sol.d2 = 'some text 2';

% set(dcm_obj,'UpdateFcn',{@update_fct, sol})

end

function txt = update_fct(none, event_obj, sol)

idx = get(event_obj, 'DataIndex');

txt = {};
txt{end+1} = ['idx : ' num2str(idx)];
txt{end+1} = sol.d1;
txt{end+1} = sol.d2;

end
