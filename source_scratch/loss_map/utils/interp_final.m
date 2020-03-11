function fct = interp_final(data)

%% load
B_sat = data.B_sat;
P_max = data.P_max;
f = data.f;
B_peak = data.B_peak;
B_dc = data.B_dc;
T = data.T;
P_f_B_peak_B_dc_T = data.P_f_B_peak_B_dc_T;

%% interp
[f_mat, B_peak_mat, B_dc_mat, T_mat] = ndgrid(f, B_peak, B_dc, T);
interp = griddedInterpolant(log10(f_mat), log10(B_peak_mat), B_dc_mat, T_mat, log10(P_f_B_peak_B_dc_T), 'linear', 'linear');

%% range
range.f = [min(f(:)) max(f(:))];
range.B_peak = [min(B_peak(:)) max(B_peak(:))];
range.B_dc = [min(B_dc(:)) max(B_dc(:))];
range.T = [min(T(:)) max(T(:))];
range.B_sat = B_sat;
range.P_max = P_max;

%% interp
fct = @(f, B_peak, B_dc, T) get_interp(interp, range, f, B_peak, B_dc, T);

end

function [is_valid, P] = get_interp(interp, range, f, B_peak, B_dc, T)

is_valid = true;
[is_valid, f] = clamp(is_valid, f, range.f);
[is_valid, B_peak] = clamp(is_valid, B_peak, range.B_peak);
[is_valid, B_dc] = clamp(is_valid, B_dc, range.B_dc);
[is_valid, T] = clamp(is_valid, T, range.T);

P = 10.^interp(log10(f), log10(B_peak), B_dc, T);
is_valid = is_valid&(P<=range.P_max);
is_valid = is_valid&((B_peak+B_dc)<=range.B_sat);

end

function [is_valid, data] = clamp(is_valid, data, range)

v_max = max(range);
v_min = min(range);

is_valid = is_valid&(data>=v_min)&(data<=v_max);

data(data>v_max) = v_max;
data(data<v_min) = v_min;

end