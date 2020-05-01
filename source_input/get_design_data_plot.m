function [fct_data, plot_param, text_param] = get_design_data_plot()
% Return the data required for the Pareto plots of the inductor designs.
%
%    Define the variables.
%    Define the plots.
%    Define the display format.
%
%    Returns:
%        fct_data (fct): function for getting the designs be plotted and getting the user defined custom figures of merit
%        plot_param (struct): definition of the different plots
%        text_param (struct): definition of variable to be shown in the text field
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% extract the data for the GUI:
%    - select which designs should be plotted
%    - extract variables for plotting and displaying (name, scaling, value, and unit)
fct_data = @get_data;

% select the different Pareto plots to be shown
%    - choice of the variable (x, y, and color) for the scatter plot
%    - the variable are chosen from the data created by the extraction function
%    - control of the format
plot_param.weighted_losses = get_plot_param('V_box', 'P_tot', 'f', [50e3 500e3]);
plot_param.mass_correlation = get_plot_param('V_box', 'm_tot', 'f', [50e3 500e3]);
plot_param.cost_correlation = get_plot_param('V_box', 'c_tot', 'f', [50e3 500e3]);

% format for displaying the figures of merit of the selected design
%    - title: title of the block in the text field
%    - var: cell of variables in the block, chosen from the data created by the extraction function
text_param{1} = struct('title', 'fom', 'var', {{'V_box', 'A_box', 'm_tot', 'c_tot'}});
text_param{2} = struct('title', 'circuit', 'var', {{'L', 'f', 'I_sat', 'I_rms'}});
text_param{3} = struct('title', 'operating', 'var', {{'P_fl', 'P_pl', 'P_mix', 'T_max'}});
text_param{4} = struct('title', 'utilization', 'var', {{'I_peak_tot', 'I_rms_tot', 'r_peak_peak', 'fact_sat', 'fact_rms'}});

end

function plot_param = get_plot_param(x_var, y_var, c_var, c_lim)
% Return the data for a single Pareto plot (scatter plot).
%
%    Parameters:
%        x_var (str): name of the x variable, chosen from the data created by the extraction function
%        y_var (str): name of the y variable, chosen from the data created by the extraction function
%        c_var (str): name of the x variable, chosen from the data created by the extraction function
%        c_lim (str): axis limit for the color axis
%
%    Returns:
%        plot_param (struct): definition of the scatter plot

% assign the variable names (names not the data)
plot_param.x_var = x_var;
plot_param.y_var = y_var;
plot_param.c_var = c_var;

% axis limit (empty for automatic)
plot_param.x_lim = [];
plot_param.y_lim = [];
plot_param.c_lim = c_lim;

% axis scale ('lin' or 'log')
plot_param.x_scale = 'lin';
plot_param.y_scale = 'lin';
plot_param.c_scale = 'lin';

% marker size for the scatter plot
plot_param.marker_pts_size = 20;

% marker size and color for the selected design
plot_param.marker_select_size = 10;
plot_param.marker_select_color = 'r';

% plot order for the scatter points
%    - 'none': original order
%    - 'ascend': ascending color value order
%    - 'descend': descending color value order
%    - 'random': random order
plot_param.order = 'random';

end

function [is_plot, data_fom] = get_data(n_sol, fom, operating)
% Functione extracting the data for the GUI from the provided simulation results.
%
%    Parameters:
%        n_sol (int): number of provided designs
%        fom (struct): computed inductor figures of merit (independent of any operating points)
%        operating (struct): struct containing the excitation, losses, and temperatures for the operating points
%
%    Returns:
%        is_plot (vector): indices of the valid designs for plotting
%        data_fom (struct): struct with user defined custom figures of merit (name, scaling, value, and unit)

% extract the figures of merit
A_box = fom.area.A_box;
V_box = fom.volume.V_box;
m_tot = fom.mass.m_tot;
c_tot = fom.cost.c_tot;
data_fom.V_box = struct('value', V_box, 'name', 'V_box', 'scale', 1e6, 'unit', 'cm3');
data_fom.A_box = struct('value', A_box, 'name', 'A_box', 'scale', 1e4, 'unit', 'cm2');
data_fom.m_tot = struct('value', m_tot, 'name', 'm_tot', 'scale', 1e3, 'unit', 'g');
data_fom.c_tot = struct('value', c_tot, 'name', 'c_tot', 'scale', 1.0, 'unit', '$');

% circuit data
L = fom.circuit.L;
I_sat = fom.circuit.I_sat;
I_rms = fom.circuit.I_rms;
f_fl = operating.full_load.excitation.f;
f_pl = operating.partial_load.excitation.f;
data_fom.L = struct('value', L, 'name', 'L', 'scale', 1e6, 'unit', 'uH');
data_fom.f = struct('value', (f_fl+f_pl)./2, 'name', 'f', 'scale', 1e-3, 'unit', 'kHz');
data_fom.I_sat = struct('value', I_sat, 'name', 'I_sat', 'scale', 1.0, 'unit', 'A');
data_fom.I_rms = struct('value', I_rms, 'name', 'I_rms', 'scale', 1.0, 'unit', 'A');

% utilization data
I_peak_tot = fom.utilization.I_peak_tot;
I_rms_tot = fom.utilization.I_rms_tot;
r_peak_peak = fom.utilization.r_peak_peak;
fact_sat = fom.utilization.fact_sat;
fact_rms = fom.utilization.fact_rms;
data_fom.I_peak_tot = struct('value', I_peak_tot, 'name', 'I_peak_tot', 'scale', 1.0, 'unit', 'A');
data_fom.I_rms_tot = struct('value', I_rms_tot, 'name', 'I_rms_tot', 'scale', 1.0, 'unit', 'A');
data_fom.r_peak_peak = struct('value', r_peak_peak, 'name', 'r_peak_peak', 'scale', 1e2, 'unit', '%');
data_fom.fact_sat = struct('value', fact_sat, 'name', 'fact_sat', 'scale', 1e2, 'unit', '%');
data_fom.fact_rms = struct('value', fact_rms, 'name', 'fact_rms', 'scale', 1e2, 'unit', '%');

% operating conditions
P_fl = operating.full_load.losses.P_tot;
T_fl = operating.full_load.thermal.T_max;
P_pl = operating.partial_load.losses.P_tot;
T_pl = operating.partial_load.thermal.T_max;
data_fom.P_fl = struct('value', P_fl, 'name', 'P_fl', 'scale', 1.0, 'unit', 'W');
data_fom.P_pl = struct('value', P_pl, 'name', 'P_pl', 'scale', 1.0, 'unit', 'W');
data_fom.P_mix = struct('value', (P_fl+P_pl)./2, 'name', 'P_tot', 'scale', 1.0, 'unit', 'W');
data_fom.T_max = struct('value', max(T_fl, T_pl), 'name', 'T_max', 'scale', 1.0, 'unit', 'C');

% extract the validity information
is_valid_fom = fom.is_valid;
is_valid_fl = operating.full_load.is_valid;
is_valid_pl = operating.partial_load.is_valid;

% only select the valid design for the plots
is_plot = true(1, n_sol);
is_plot = is_plot&is_valid_fom;
is_plot = is_plot&is_valid_fl;
is_plot = is_plot&is_valid_pl;

end