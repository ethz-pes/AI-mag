function interp_map_bias(name, name_map, name_bias, f, B_peak, B_dc, T, B_sat, P_max)

%% load
data_tmp = load(['data/' name_map '_map.mat']);
data_map = data_tmp.data;

data_tmp = load(['data/' name_bias '_bias.mat']);
data_bias = data_tmp.data;

%% map
[f_mat, B_peak_mat, B_dc_mat, T_mat] = ndgrid(f, B_peak, B_dc, T);

P_mat = interp_map(data_map, f_mat, B_peak_mat, T_mat);
fact_mat = interp_bias(data_bias, f_mat, B_peak_mat, B_dc_mat, T_mat);

P_f_B_peak_B_dc_T = P_mat.*fact_mat;

%% assign
data.B_sat = B_sat;
data.P_max = P_max;
data.f = f;
data.B_peak = B_peak;
data.B_dc = B_dc;
data.T = T;
data.P_f_B_peak_B_dc_T = P_f_B_peak_B_dc_T;

%% save
save(['data/' name '_final.mat'], 'data');

end