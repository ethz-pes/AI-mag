function [is_valid, data] = get_clamp(is_valid, data, range)
% Clamp a vector with respect to a given range.
%
%    Parameters:
%        is_valid (vector): if the unclamped data are valid (or not)
%        data (vector): data (unclamped)
%        range (vector): vector containing the range
%
%    Returns:
%        is_valid (vector): if the clamped data are valid (or not)
%        data (vector): data (clamped)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get range
v_max = max(range);
v_min = min(range);

% clamp and check validity
is_valid = is_valid&(data>=v_min)&(data<=v_max);
data(data>v_max) = v_max;
data(data<v_min) = v_min;

end
