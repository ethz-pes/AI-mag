function P = get_interp(data, f, B_ac_peak, B_dc, T, is_clamp)
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

switch data.type
    case 'ac_dc_matrix'
        P = get_interp_ac_dc_matrix(data, f, B_ac_peak, B_dc, T, is_clamp);
    case 'ac_matrix'
        P = get_interp_ac_matrix(data, f, B_ac_peak, T, is_clamp);
    otherwise
        error('invalid loss map type')
end

end

function P = get_interp_ac_dc_matrix(data, f, B_ac_peak, B_dc, T, is_clamp)

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
if is_clamp==true
    f = get_clamp(f, f_vec);
    B_ac_peak = get_clamp(B_ac_peak, B_ac_peak_vec);
    B_dc = get_clamp(B_dc, B_dc_vec);
    T = get_clamp(T, T_vec);
end

% interpolate and compute the correction factor
P = 10.^interp(log10(f), log10(B_ac_peak), B_dc, T);

end

function P = get_interp_ac_matrix(data, f, B_ac_peak, T, is_clamp)

% get the grid
f_vec = data.f_vec;
B_ac_peak_vec = data.B_ac_peak_vec;
T_vec = data.T_vec;
P_mat = data.P_mat;
[f_mat, B_ac_peak_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, T_vec);

% interpolate in log scale
interp = griddedInterpolant(log10(f_mat), log10(B_ac_peak_mat), T_mat, log10(P_mat), 'linear', 'linear');

% clamp the variables to avoid extrapolation
if is_clamp==true
    f = get_clamp(f, f_vec);
    B_ac_peak = get_clamp(B_ac_peak, B_ac_peak_vec);
    T = get_clamp(T, T_vec);
end

% interpolate and compute the correction factor
P = 10.^interp(log10(f), log10(B_ac_peak), T);

end