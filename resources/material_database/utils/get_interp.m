function P = get_interp(data, f, B_ac_peak, B_dc, T, extrap)
% Interpolate a loss map (with or without DC bias data).
%
%    Parameters:
%        data (struct): loss map
%        f (matrix): frequency matrix
%        B_ac_peak (matrix): AC flux density matrix
%        B_dc (matrix): DC flux density matrix
%        T (matrix): temperature matrix
%        extrap (struct): extrapolation data
%
%    Returns:
%        P (matrix): multi-dimensional matrix with the loss data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% clamp the data
f = get_clamp(f, extrap.f);
B_ac_peak = get_clamp(B_ac_peak, extrap.B_ac_peak);
B_dc = get_clamp(B_dc, extrap.B_dc);
T = get_clamp(T, extrap.T);

% interpolate
switch data.type
    case 'ac_dc_matrix'
        P = get_interp_ac_dc_matrix(data, f, B_ac_peak, B_dc, T);
    case 'ac_matrix'
        P = get_interp_ac_matrix(data, f, B_ac_peak, T);
    otherwise
        error('invalid loss map type')
end

end

function P = get_interp_ac_dc_matrix(data, f, B_ac_peak, B_dc, T)
% Interpolate the a loss map (with DC bias data).
%
%    Parameters:
%        data (struct): loss map
%        f (matrix): frequency matrix
%        B_ac_peak (matrix): AC flux density matrix
%        B_dc (matrix): DC flux density matrix
%        T (matrix): temperature matrix
%
%    Returns:
%        P (matrix): multi-dimensional matrix with the loss data

% get the grid
f_vec = data.f_vec;
B_ac_peak_vec = data.B_ac_peak_vec;
B_dc_vec = data.B_dc_vec;
T_vec = data.T_vec;
P_mat = data.P_mat;
[f_mat, B_ac_peak_mat, B_dc_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, B_dc_vec, T_vec);

% interpolate in log scale
interp = griddedInterpolant(log10(f_mat), log10(B_ac_peak_mat), B_dc_mat, T_mat, log10(P_mat), 'linear', 'linear');

% interpolate and compute the correction factor
P = 10.^interp(log10(f), log10(B_ac_peak), B_dc, T);

end

function P = get_interp_ac_matrix(data, f, B_ac_peak, T)
% Interpolate the a loss map (without DC bias data).
%
%    Parameters:
%        data (struct): loss map
%        f (matrix): frequency matrix
%        B_ac_peak (matrix): AC flux density matrix
%        T (matrix): temperature matrix
%
%    Returns:
%        P (matrix): multi-dimensional matrix with the loss data

% get the grid
f_vec = data.f_vec;
B_ac_peak_vec = data.B_ac_peak_vec;
T_vec = data.T_vec;
P_mat = data.P_mat;
[f_mat, B_ac_peak_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, T_vec);

% interpolate in log scale
interp = griddedInterpolant(log10(f_mat), log10(B_ac_peak_mat), T_mat, log10(P_mat), 'linear', 'linear');

% interpolate and compute the correction factor
P = 10.^interp(log10(f), log10(B_ac_peak), T);

end