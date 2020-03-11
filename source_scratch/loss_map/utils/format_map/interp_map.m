function P_vec = interp_map(data, f_vec, B_peak_vec, T_vec)

%% load
f = data.f;
B_peak = data.B_peak;
T = data.T;
P_f_B_peak_T = data.P_f_B_peak_T;

%% interp
[f_mat, B_peak_mat, T_mat] = ndgrid(f, B_peak, T);
interp = griddedInterpolant(log10(f_mat), log10(B_peak_mat), T_mat, log10(P_f_B_peak_T), 'linear', 'linear');

%% interp
P_vec = 10.^interp(log10(f_vec), log10(B_peak_vec), T_vec);

end
