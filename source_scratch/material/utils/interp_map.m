function P = interp_map(data, f, B_ac_peak, T)

%% load
f_vec = data.f_vec;
B_ac_peak_vec = data.B_ac_peak_vec;
T_vec = data.T_vec;
P_mat = data.P_mat;

%% interp
[f_mat, B_ac_peak_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, T_vec);
interp = griddedInterpolant(log10(f_mat), log10(B_ac_peak_mat), T_mat, log10(P_mat), 'linear', 'linear');

%% interp
P = 10.^interp(log10(f), log10(B_ac_peak), T);

end
