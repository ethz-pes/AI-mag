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

% map value
value_eval_tmp = interp1(idx, value, idx_eval, 'linear');

% round indices
value_eval = round(value_eval_tmp);

% check data
assert(all(abs(value_eval_tmp-value_eval)<eps), 'invalid data')
assert(all(isfinite(value_eval)), 'invalid data')

end
