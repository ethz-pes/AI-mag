function fact = interp_bias(data, f, B_ac_peak, B_dc, T)

%% load
f_vec = data.f_vec;
B_ac_peak_vec = data.B_ac_peak_vec;
B_dc_vec = data.B_dc_vec;
T_vec = data.T_vec;
P_mat = data.P_mat;

%% interp
[f_mat, B_ac_peak_mat, B_dc_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, B_dc_vec, T_vec);
interp = griddedInterpolant(log10(f_mat), log10(B_ac_peak_mat), B_dc_mat, T_mat, log10(P_mat), 'linear', 'linear');

%% interp
f = clamp(f, f_vec);
B_ac_peak = clamp(B_ac_peak, B_ac_peak_vec);
B_dc = clamp(B_dc, B_dc_vec);
T = clamp(T, T_vec);

P_bias = 10.^interp(log10(f), log10(B_ac_peak), 1.0.*B_dc, T);
P_ref = 10.^interp(log10(f), log10(B_ac_peak), 0.0.*B_dc, T);
fact = P_bias./P_ref;

end

function data = clamp(data, range)

v_max = max(range(:));
v_min = min(range(:));

idx = data>v_max;
data(idx) = v_max;

idx = data<v_min;
data(idx) = v_min;

end