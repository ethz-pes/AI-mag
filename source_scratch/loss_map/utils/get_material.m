function material = get_material(data_map, data_bias, material)

%% map
f_vec = material.interp.f_vec;
B_ac_peak_vec = material.interp.B_ac_peak_vec;
B_dc_vec = material.interp.B_dc_vec;
T_vec = material.interp.T_vec;
[f_mat, B_ac_peak_mat, B_dc_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, B_dc_vec, T_vec);

P_mat = interp_map(data_map, f_mat, B_ac_peak_mat, T_mat);
fact_mat = interp_bias(data_bias, f_mat, B_ac_peak_mat, B_dc_mat, T_mat);
P_mat = P_mat.*fact_mat;

%% assign
material.interp.P_mat = P_mat;

end