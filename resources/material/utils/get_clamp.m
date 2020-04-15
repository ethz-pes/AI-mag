function data = get_clamp(data, range)
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
