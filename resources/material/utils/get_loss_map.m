function P_mat = get_loss_map(data_map, data_fact_dc, param, interp)
% Combine the AC and DC loss map and get the loss value of the specified points.
%
%    Parameters:
%        data_ac (struct): AC loss map
%        data_dc (struct): DC loss map
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

% param
fact_dc = param.fact_dc;
limit_dc = param.limit_dc;
clamp_dc = param.clamp_dc;

% use (or not) a second loss map to correct the losses for DC bias
if fact_dc==true
    % use the first losses, without DC bias
    P_mat = get_interp(data_map, f_mat, B_ac_peak_mat, 0.*B_dc_mat, T_mat, false);
    
    % DC bias correction factor
    P_mat_ac = get_interp(data_fact_dc, f_mat, B_ac_peak_mat, 0.*B_dc_mat, T_mat, clamp_dc);
    P_mat_dc = get_interp(data_fact_dc, f_mat, B_ac_peak_mat, 1.*B_dc_mat, T_mat, clamp_dc);
    fact = P_mat_dc./P_mat_ac;
    
    % limit the values of the correction factor
    fact = get_clamp(fact, limit_dc);
        
    % apply DC bias correction factor
    P_mat = fact.*P_mat;
else
    % use only the first loss map
    P_mat = get_interp(data_map, f_mat, B_ac_peak_mat, 1.*B_dc_mat, T_mat, false);
end

end
