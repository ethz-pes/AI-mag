function P_mat = get_loss_map(data_map, data_bias, param, interp)
% Combine the AC and DC loss map and get the loss value of the specified points.
%
%    Parameters:
%        data_map (struct): main loss map
%        data_bias (struct): loss map for DC bias correction (if required)
%        param (struct): parameters for the interpolation method
%        interp (struct): point to interpolate (frequency, AC flux density, DC bias, and temperature)
%
%    Returns:
%        P_mat (matrix): multi-dimensional matrix with the loss data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get the grid
f_vec = interp.f_vec;
B_ac_peak_vec = interp.B_ac_peak_vec;
B_dc_vec = interp.B_dc_vec;
T_vec = interp.T_vec;
[f_mat, B_ac_peak_mat, B_dc_mat, T_mat] = ndgrid(f_vec, B_ac_peak_vec, B_dc_vec, T_vec);

% extract the parameters for the interpolation method
use_bias = param.use_bias;
extrap_map = param.extrap_map;
extrap_bias = param.extrap_bias;

% use (or not) a second loss map to correct the losses for DC bias
if use_bias==true
    % use the first losses, without DC bias
    P_mat = get_interp_map(data_map, f_mat, B_ac_peak_mat, 0.*B_dc_mat, T_mat, extrap_map);
    
    % DC bias correction factor
    fact = get_interp_bias(data_bias, f_mat, B_ac_peak_mat, 1.*B_dc_mat, T_mat, extrap_bias);
        
    % apply DC bias correction factor
    P_mat = fact.*P_mat;
else
    % use only the first loss map
    P_mat = get_interp_map(data_map, f_mat, B_ac_peak_mat, B_dc_mat, T_mat, extrap_map);
end

% check data
P_vec = P_mat(:);
assert(all(P_vec>0), 'invalid loss data')

end

function P = get_interp_map(data, f, B_ac_peak, B_dc, T, extrap)
% Interpolate the main loss map (with or without DC bias data).
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

% interpolation
P = get_interp(data, f, B_ac_peak, B_dc, T, extrap);

% clamp result
P = get_clamp(P, extrap.P);

end

function fact = get_interp_bias(data, f, B_ac_peak, B_dc, T, extrap)
% Interpolate the correction factor for the DC bias.
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
%        fact (matrix): multi-dimensional matrix with the correction factor for the DC bias

% interpolation
P_ac = get_interp(data, f, B_ac_peak, 0.*B_dc, T, extrap);
P_dc = get_interp(data, f, B_ac_peak, 1.*B_dc, T, extrap);

% correction factor and clamp
fact = P_dc./P_ac;
fact = get_clamp(fact, extrap.fact);

end
