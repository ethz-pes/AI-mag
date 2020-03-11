function fig = get_plot_inductor(name, geom, is_select)

fig = [];

if nnz(is_select)==0
    fig(end+1) = get_fig_empty([name ' / front']);
    fig(end+1) = get_fig_empty([name ' / top']);
elseif nnz(is_select)==1
    plot_data = get_plot_data_front(geom, is_select);
    fig(end+1) = get_fig([name ' / front'], plot_data);
    
    plot_data = get_plot_data_top(geom, is_select);
    fig(end+1) = get_fig([name ' / top'], plot_data);
else
    error('invalid data')
end

end

function plot_data = get_plot_data_front(geom, is_select)

geom_tmp = get_struct_filter(geom, is_select);

x_window = geom_tmp.x_window;
y_window = geom_tmp.y_window;
t_core = geom_tmp.t_core;
d_gap = geom_tmp.d_gap;
d_iso = geom_tmp.d_iso;

x_core = 2.*x_window+2.*t_core;
y_core = y_window+t_core;
x_winding = x_window-2.*d_iso;
y_winding = y_window-2.*d_iso;
x_window_offset = t_core./2+x_window./2;

plot_data = {};
plot_data{end+1} = struct('type', 'core', 'pos', [0 0], 'size', [x_core y_core], 'r', 0);
plot_data{end+1} = struct('type', 'air', 'pos', [0 0], 'size', [x_core d_gap], 'r', 0);
plot_data{end+1} = struct('type', 'insulation', 'pos', [+x_window_offset 0], 'size', [x_window y_window], 'r', 0);
plot_data{end+1} = struct('type', 'insulation', 'pos', [-x_window_offset 0], 'size', [x_window y_window], 'r', 0);
plot_data{end+1} = struct('type', 'winding', 'pos', [+x_window_offset 0], 'size', [x_winding y_winding], 'r', 0);
plot_data{end+1} = struct('type', 'winding', 'pos', [-x_window_offset 0], 'size', [x_winding y_winding], 'r', 0);

end

function plot_data = get_plot_data_top(geom, is_select)

geom_tmp = get_struct_filter(geom, is_select);

x_window = geom_tmp.x_window;
t_core = geom_tmp.t_core;
z_core = geom_tmp.z_core;
d_iso = geom_tmp.d_iso;
r_curve = geom_tmp.r_curve;

x_core = 2.*x_window+2.*t_core;

r_curve_1 = r_curve;
r_curve_2 = r_curve+d_iso;
r_curve_3 = r_curve+x_window-d_iso;
r_curve_4 = r_curve+x_window;

z_1 = z_core+2.*r_curve;
z_2 = z_core+2.*r_curve+2.*d_iso;
z_3 = z_core+2.*r_curve+2.*x_window-2.*d_iso;
z_4 = z_core+2.*r_curve+2.*x_window;

x_1 = t_core;
x_2 = t_core+2.*d_iso;
x_3 = t_core+2.*x_window-2.*d_iso;
x_4 = t_core+2.*x_window;

plot_data = {};
plot_data{end+1} = struct('type', 'insulation', 'pos', [0 0], 'size', [z_4 x_4], 'r', r_curve_4);
plot_data{end+1} = struct('type', 'winding', 'pos', [0 0], 'size', [z_3 x_3], 'r', r_curve_3);
plot_data{end+1} = struct('type', 'insulation', 'pos', [0 0], 'size', [z_2 x_2], 'r', r_curve_2);
plot_data{end+1} = struct('type', 'air', 'pos', [0 0], 'size', [z_1 x_1], 'r', r_curve_1);
plot_data{end+1} = struct('type', 'core', 'pos', [0 0], 'size', [z_core x_core], 'r', 0);

end

function fig = get_fig_empty(type)

% set the the plot
fig = figure('name', type);
title(type, 'interpreter', 'none');
hold('on');
axis('off')
plot([-1 +1], [-1 +1], 'r')
plot([-1 +1], [+1 -1], 'r')

end

function fig = get_fig(type, plot_data)

% set the the plot
fig = figure('name', type);
title(type, 'interpreter', 'none');
hold('on');

xlabel('[mm]');
ylabel('[mm]');
axis('equal');
x_vec = [];
y_vec = [];

% plot the core element
for i=1:length(plot_data)
    tmp = plot_data{i};
    
    x_min = tmp.pos(1)-tmp.size(1)./2;
    x_max = tmp.pos(1)+tmp.size(1)./2;
    y_min = tmp.pos(2)-tmp.size(2)./2;
    y_max = tmp.pos(2)+tmp.size(2)./2;
    
    r = 2.*tmp.r./min(tmp.size);
    vec = [x_min y_min x_max-x_min y_max-y_min];
    x_vec = [x_vec x_min x_max];
    y_vec = [y_vec y_min y_max];
    
    switch tmp.type
        case 'core'
            rectangle('Position', 1e3.*vec, 'Curvature', r, 'FaceColor', [0.5 0.5 0.5], 'LineStyle','none')
        case 'air'
            rectangle('Position', 1e3.*vec, 'Curvature', r, 'FaceColor', [1.0 1.0 1.0], 'LineStyle','none')
        case 'winding'
            rectangle('Position', 1e3.*vec, 'Curvature', r,'FaceColor', [0.9 0.5 0.0], 'LineStyle','none')
        case 'insulation'
            rectangle('Position', 1e3.*vec, 'Curvature', r,'FaceColor', [0.5 0.5 0.0], 'LineStyle','none')
        otherwise
            error('invalid data')
    end
end

% set the axis
dx = max(x_vec)-min(x_vec);
dy = max(y_vec)-min(y_vec);
dt = 0.1.*max(dx, dy);
xlim(1e3.*[min(x_vec)-dt max(x_vec)+dt])
ylim(1e3.*[min(y_vec)-dt max(y_vec)+dt])

end