function test_pareto()

close all;

plot_data.x_label = 'x';
plot_data.y_label = 'y';
plot_data.c_label = 'c';

plot_data.x_lim = [0 1];
plot_data.y_lim = [0.1 1];
plot_data.c_lim = [0.01 1];

plot_data.x_scale = 'lin';
plot_data.y_scale = 'log';
plot_data.c_scale = 'log';

plot_data.x_data = rand(1, 100);
plot_data.y_data = rand(1, 100);
plot_data.c_data = rand(1, 100);
plot_data.id_data = 1:100;

plot_data.marker_pts_size = 20;
plot_data.marker_select_size = 10;
plot_data.marker_select_color = 'r';
plot_data.order = 'random';

fig = figure();

callback = @(idx) fprintf('callback 1: %d\n', idx);
obj = gui.GuiScatter(fig, [0 0 1 1]);
obj.set_data(plot_data, callback);
obj.set_select(4);

end
