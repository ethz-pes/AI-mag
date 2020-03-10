function value_value = get_integer_map(idx, value, idx_eval)

value_value = interp1(idx, value, idx_eval, 'nearest');
assert(all(isfinite(value_value)), 'invalid data')

end
