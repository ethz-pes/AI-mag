function [is_valid, physics] = get_physics(model_type, inp, physics)

switch model_type
    case 'mf'
        inp_tmp = struct();
    case 'ht'
        inp_tmp.P_tot = inp.ht_stress.*(6.*inp.volume_target.^(2./3));
        inp_tmp.P_core = sqrt(inp_tmp.P_tot./inp.ht_sharing);
        inp_tmp.P_winding = sqrt(inp_tmp.P_tot.*inp.ht_sharing);
    otherwise
        error('invalid type')
end

% merge
physics = get_struct_merge(inp_tmp, physics);
is_valid = get_is_valid(physics);

end

function is_valid = get_is_valid(physics)

% check
is_valid = true;

field = fieldnames(physics);
for i=1:length(field)
    is_valid = is_valid&isfinite(physics.(field{i}));
    is_valid = is_valid&(physics.(field{i})>=0);
end

end
