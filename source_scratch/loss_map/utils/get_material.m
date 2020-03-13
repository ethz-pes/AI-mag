function material = get_material(data_map, data_bias, material)

%% map
f = material.interp.f;
B_peak = material.interp.B_peak;
B_dc = material.interp.B_dc;
T = material.interp.T;
[f_mat, B_peak_mat, B_dc_mat, T_mat] = ndgrid(f, B_peak, B_dc, T);

P_mat = interp_map(data_map, f_mat, B_peak_mat, T_mat);
fact_mat = interp_bias(data_bias, f_mat, B_peak_mat, B_dc_mat, T_mat);
P_f_B_peak_B_dc_T = P_mat.*fact_mat;

%% assign
material.interp.P_f_B_peak_B_dc_T = P_f_B_peak_B_dc_T;

end