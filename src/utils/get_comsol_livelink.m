function is_ok = get_comsol_livelink()
% Get if the COMSOL Livelink is running or not.
%
%    Returns:
%        is_ok (logical): if the COMSOL Livelink is running or not
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

try
    mphversion();
    is_ok = true;
catch
    is_ok = false;
end

end