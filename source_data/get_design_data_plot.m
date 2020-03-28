function [fct_data, plot_param, fom_param] = get_design_data_plot()

fct_data = @(fom, operating, n_sol) get_data(fom, operating, n_sol);

plot_param.weighted_losses = get_plot_param('V_box', 'P_tot', 'f');
plot_param.mass_correlation = get_plot_param('V_box', 'm_tot', 'f');
plot_param.cost_correlation = get_plot_param('V_box', 'c_tot', 'f');

fom_param{1} = struct('title', 'fom', 'var', {{'V_box', 'A_box', 'm_tot', 'c_tot'}});
fom_param{2} = struct('title', 'operating', 'var', {{'L', 'f'}});
fom_param{3} = struct('title', 'losses', 'var', {{'P_fl', 'P_hl', 'P_tot'}});

end

function plot_param = get_plot_param(x_var, y_var, c_var)

plot_param.x_var = x_var;
plot_param.y_var = y_var;
plot_param.c_var = c_var;

plot_param.marker_pts_size = 20;
plot_param.marker_select_size = 15;
plot_param.marker_select_color = 'r';
plot_param.order = 'random';

plot_param.x_scale = 'lin';
plot_param.y_scale = 'lin';
plot_param.c_scale = 'lin';

plot_param.x_lim = [];
plot_param.y_lim = [];
plot_param.c_lim = [];

end

function [is_valid, data_ctrl] = get_data(fom, operating, n_sol)

A_box = fom.area.A_box;
V_box = fom.volume.V_box;
m_tot = fom.mass.m_tot;
c_tot = fom.cost.c_tot;
L = fom.circuit.L;
is_valid_fom = fom.is_valid;

P_fl = operating.full_load.losses.P_tot;
f_fl = operating.full_load.excitation.f;
is_valid_fl = operating.full_load.is_valid;

P_hl = operating.half_load.losses.P_tot;
f_hl = operating.half_load.excitation.f;
is_valid_hl = operating.half_load.is_valid;

f = (f_fl+f_hl)./2;
P_tot = 0.5.*P_fl+0.5.*P_hl;

data_ctrl.V_box = struct('value', V_box, 'name', 'V_box', 'scale', 1e6, 'unit', 'cm3');
data_ctrl.A_box = struct('value', A_box, 'name', 'A_box', 'scale', 1e4, 'unit', 'cm2');
data_ctrl.m_tot = struct('value', m_tot, 'name', 'm_tot', 'scale', 1e3, 'unit', 'g');
data_ctrl.c_tot = struct('value', c_tot, 'name', 'c_tot', 'scale', 1.0, 'unit', '$');
data_ctrl.L = struct('value', L, 'name', 'L', 'scale', 1e6, 'unit', 'uH');
data_ctrl.f = struct('value', f, 'name', 'f', 'scale', 1e-3, 'unit', 'kHz');
data_ctrl.P_fl = struct('value', P_fl, 'name', 'P_fl', 'scale', 1.0, 'unit', 'W');
data_ctrl.P_hl = struct('value', P_hl, 'name', 'P_hl', 'scale', 1.0, 'unit', 'W');
data_ctrl.P_tot = struct('value', P_tot, 'name', 'P_tot', 'scale', 1.0, 'unit', 'W');

is_valid = true(1, n_sol);
is_valid = is_valid&is_valid_fom;
is_valid = is_valid&is_valid_fl;
is_valid = is_valid&is_valid_hl;

end