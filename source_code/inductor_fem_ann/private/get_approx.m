function out_approx = get_approx(n_sol, inp, const)

% geometry
geom = get_struct_size(const.geom, n_sol);
material = get_struct_size(const.material, n_sol);
model_type = const.model_type;

% geom
[is_valid, geom] = get_geom(inp, geom);
assert(all(is_valid==true), 'invalid data');

% approx
switch model_type
    case 'mf'
        out_approx = get_out_approx_mf(geom, material);
    case 'ht'
        P_tot = inp.ht_stress.*geom.S_box;
        P_core = sqrt(P_tot./inp.ht_sharing);
        P_winding = sqrt(P_tot.*inp.ht_sharing);
        out_approx = get_out_approx_ht(inp, geom, material, P_core, P_winding);
    otherwise
        error('invalid model')
end

end