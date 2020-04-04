function material = extract_map_ac_dc(data_ac, data_dc, material)
% Combine the AC and DC loss map and get the loss value of the specified points.
%
%    Parameters:
%        data_ac (struct): AC loss map
%        data_dc (struct): DC loss map
%        material (struct): material data (with losses)
%
%    Returns:
%        material (struct): material data (with losses)

% get the grid
f_vec = material.interp.f_vec;
B_ac_peak_vec = material.interp.B_ac_peak_vec;
B_dc_vec = material.interp.B_dc_vec;
T_vec = material.interp.T_vec;
[f_mat, B_ac_peak_mat, B_dc_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, B_dc_vec, T_vec);

% get combined ac/dc data (dc loss map is used as a correction factor)
P_mat = interp_ac(data_ac, f_mat, B_ac_peak_mat, T_mat);
fact_mat = interp_dc(data_dc, f_mat, B_ac_peak_mat, B_dc_mat, T_mat);
P_mat = P_mat.*fact_mat;

% assign result
material.interp.P_mat = P_mat;

end

function P = interp_ac(data, f, B_ac_peak, T)
% Interpolate the AC loss map (loss value).
%
%    Parameters:
%        data (struct): loss map
%        f (matrix): frequency matrix
%        B_ac_peak (matrix): AC flux density matrix
%        T (matrix): temperature matrix
%
%    Returns:
%        P (matrix): loss matrix

% get the grid
f_vec = data.f_vec;
B_ac_peak_vec = data.B_ac_peak_vec;
T_vec = data.T_vec;
P_mat = data.P_mat;
[f_mat, B_ac_peak_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, T_vec);

% interpolate in log scale
interp = griddedInterpolant(log10(f_mat), log10(B_ac_peak_mat), T_mat, log10(P_mat), 'linear', 'linear');
P = 10.^interp(log10(f), log10(B_ac_peak), T);

end

function fact = interp_dc(data, f, B_ac_peak, B_dc, T)
% Interpolate the DC loss map (correction factor).
%
%    Parameters:
%        data (struct): loss map
%        f (matrix): frequency matrix
%        B_ac_peak (matrix): AC flux density matrix
%        B_dc (matrix): DC flux density matrix
%        T (matrix): temperature matrix
%
%    Returns:
%        fact (matrix): correction factor matrix (DC over AC losses)

% get the grid
f_vec = data.f_vec;
B_ac_peak_vec = data.B_ac_peak_vec;
B_dc_vec = data.B_dc_vec;
T_vec = data.T_vec;
P_mat = data.P_mat;
[f_mat, B_ac_peak_mat, B_dc_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, B_dc_vec, T_vec);

% interpolate in log scale
interp = griddedInterpolant(log10(f_mat), log10(B_ac_peak_mat), B_dc_mat, T_mat, log10(P_mat), 'linear', 'linear');

% clamp the variables to avoid extrapolation
f = clamp(f, f_vec);
B_ac_peak = clamp(B_ac_peak, B_ac_peak_vec);
B_dc = clamp(B_dc, B_dc_vec);
T = clamp(T, T_vec);

% interpolate and compute the correction factor
P_bias = 10.^interp(log10(f), log10(B_ac_peak), 1.0.*B_dc, T);
P_ref = 10.^interp(log10(f), log10(B_ac_peak), 0.0.*B_dc, T);
fact = P_bias./P_ref;

end

function data = clamp(data, range)
% Clamp a matrix with respect to a given range.
%
%    Parameters:
%        data (matrix): data (unclamped)
%        range (vector): vector containing the range
%
%    Returns:
%        data (matrix): data (clamped)

% get range
v_max = max(range(:));
v_min = min(range(:));

% clamp
idx = data>v_max;
data(idx) = v_max;
idx = data<v_min;
data(idx) = v_min;

end

