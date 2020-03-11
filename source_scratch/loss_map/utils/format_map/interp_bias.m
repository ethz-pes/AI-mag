function fact_vec = interp_bias(data, f_vec, B_peak_vec, B_dc_vec, T_vec)

%% load
f = data.f;
B_peak = data.B_peak;
B_dc = data.B_dc;
T = data.T;
P_f_B_peak_B_dc_T = data.P_f_B_peak_B_dc_T;

%% interp
[f_mat, B_peak_mat, B_dc_mat, T_mat] = ndgrid(f, B_peak, B_dc, T);
interp = griddedInterpolant(log10(f_mat), log10(B_peak_mat), B_dc_mat, T_mat, log10(P_f_B_peak_B_dc_T), 'linear', 'linear');

%% interp
f_vec = clamp(f_vec, f);
B_peak_vec = clamp(B_peak_vec, B_peak);
B_dc_vec = clamp(B_dc_vec, B_dc);
T_vec = clamp(T_vec, T);

P_bias_vec = 10.^interp(log10(f_vec), log10(B_peak_vec), 1.0.*B_dc_vec, T_vec);
P_ref_vec = 10.^interp(log10(f_vec), log10(B_peak_vec), 0.0.*B_dc_vec, T_vec);
fact_vec = P_bias_vec./P_ref_vec;

end

function data = clamp(data, range)

v_max = max(range(:));
v_min = min(range(:));

idx = data>v_max;
data(idx) = v_max;

idx = data<v_min;
data(idx) = v_min;

end