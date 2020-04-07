function [fct_data, plot_param, text_param] = get_design_data_plot()

fct_data = @(fom, operating, n_sol) get_data(fom, operating, n_sol);

plot_param.weighted_losses = get_plot_param('V_box', 'P_tot', 'f', [50 500]);
plot_param.mass_correlation = get_plot_param('V_box', 'm_tot', 'f', [50 500]);
plot_param.cost_correlation = get_plot_param('V_box', 'c_tot', 'f', [50 500]);

text_param{1} = struct('title', 'fom', 'var', {{'V_box', 'A_box', 'm_tot', 'c_tot'}});
text_param{2} = struct('title', 'circuit', 'var', {{'L', 'f', 'I_sat', 'I_rms'}});
text_param{3} = struct('title', 'operating', 'var', {{'P_fl', 'P_hl', 'P_tot', 'T_max'}});
text_param{4} = struct('title', 'utilization', 'var', {{'I_peak_tot', 'I_rms_tot', 'r_peak_peak', 'fact_sat', 'fact_rms'}});

end

function plot_param = get_plot_param(x_var, y_var, c_var, c_lim)

plot_param.x_var = x_var;
plot_param.y_var = y_var;
plot_param.c_var = c_var;

plot_param.marker_pts_size = 20;
plot_param.marker_select_size = 10;
plot_param.marker_select_color = 'r';
plot_param.order = 'random';

plot_param.x_scale = 'lin';
plot_param.y_scale = 'lin';
plot_param.c_scale = 'lin';

plot_param.x_lim = [];
plot_param.y_lim = [];
plot_param.c_lim = c_lim;

end

function [is_plot, data_fom] = get_data(fom, operating, n_sol)

A_box = fom.area.A_box;
V_box = fom.volume.V_box;
m_tot = fom.mass.m_tot;
c_tot = fom.cost.c_tot;

L = fom.circuit.L;
I_sat = fom.circuit.I_sat;
I_rms = fom.circuit.I_rms;

I_peak_tot = fom.utilization.I_peak_tot;
I_rms_tot = fom.utilization.I_rms_tot;
r_peak_peak = fom.utilization.r_peak_peak;
fact_sat = fom.utilization.fact_sat;
fact_rms = fom.utilization.fact_rms;

is_valid_fom = fom.is_valid;

P_fl = operating.full_load.losses.P_tot;
f_fl = operating.full_load.excitation.f;
T_fl = operating.full_load.thermal.T_max;
is_valid_fl = operating.full_load.is_valid;

P_hl = operating.half_load.losses.P_tot;
f_hl = operating.half_load.excitation.f;
T_hl = operating.half_load.thermal.T_max;
is_valid_hl = operating.half_load.is_valid;

f = (f_fl+f_hl)./2;
P_tot = 0.5.*P_fl+0.5.*P_hl;
T_max = max(T_fl, T_hl);

data_fom.V_box = struct('value', V_box, 'name', 'V_box', 'scale', 1e6, 'unit', 'cm3');
data_fom.A_box = struct('value', A_box, 'name', 'A_box', 'scale', 1e4, 'unit', 'cm2');
data_fom.m_tot = struct('value', m_tot, 'name', 'm_tot', 'scale', 1e3, 'unit', 'g');
data_fom.c_tot = struct('value', c_tot, 'name', 'c_tot', 'scale', 1.0, 'unit', '$');

data_fom.L = struct('value', L, 'name', 'L', 'scale', 1e6, 'unit', 'uH');
data_fom.f = struct('value', f, 'name', 'f', 'scale', 1e-3, 'unit', 'kHz');
data_fom.I_sat = struct('value', I_sat, 'name', 'I_sat', 'scale', 1.0, 'unit', 'A');
data_fom.I_rms = struct('value', I_rms, 'name', 'I_rms', 'scale', 1.0, 'unit', 'A');

data_fom.I_peak_tot = struct('value', I_peak_tot, 'name', 'I_peak_tot', 'scale', 1.0, 'unit', 'A');
data_fom.I_rms_tot = struct('value', I_rms_tot, 'name', 'I_rms_tot', 'scale', 1.0, 'unit', 'A');
data_fom.r_peak_peak = struct('value', r_peak_peak, 'name', 'r_peak_peak', 'scale', 1e2, 'unit', '%');
data_fom.fact_sat = struct('value', fact_sat, 'name', 'fact_sat', 'scale', 1e2, 'unit', '%');
data_fom.fact_rms = struct('value', fact_rms, 'name', 'fact_rms', 'scale', 1e2, 'unit', '%');

data_fom.P_fl = struct('value', P_fl, 'name', 'P_fl', 'scale', 1.0, 'unit', 'W');
data_fom.P_hl = struct('value', P_hl, 'name', 'P_hl', 'scale', 1.0, 'unit', 'W');
data_fom.P_tot = struct('value', P_tot, 'name', 'P_tot', 'scale', 1.0, 'unit', 'W');
data_fom.T_max = struct('value', T_max, 'name', 'T_max', 'scale', 1.0, 'unit', 'C');

is_plot = true(1, n_sol);
is_plot = is_plot&is_valid_fom;
is_plot = is_plot&is_valid_fl;
is_plot = is_plot&is_valid_hl;

end