function value_eval = get_integer_map(idx, value, idx_eval)
% Map idx vector to values.
%
%    Parameters:
%        idx (vector): vector with the reference indices
%        value (vector): vector with the reference values
%        idx_eval (vector): vector with the indices to be mapped
%
%    Returns:
%        value_eval (vector): vector with the values to be mapped
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check that the mapping is possible
assert(length(idx)==length(value), 'invalid mapping')

%init
is_ok_eval = false(1, length(idx_eval));
value_eval = zeros(1, length(idx_eval));

% map
for i=1:length(idx)
    idx_tmp = idx_eval==idx(i);
    
    is_ok_eval(idx_tmp) = true;
    value_eval(idx_tmp) = value(i);
end

% check that the mapping is complete
assert(all(is_ok_eval==true), 'invalid mapping')

end
