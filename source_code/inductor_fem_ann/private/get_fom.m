function [is_valid, fom] = get_fom(ann_manager_obj, const, model_type, var_type, n_sol, inp, ann_type)

% inp
const = get_struct_size(const, n_sol);
inp = get_struct_merge(inp, const);
[is_valid_inp, inp] = get_extend_inp(model_type, var_type, inp);

% approx
out_approx = get_out_approx(model_type, inp);

% ann
switch ann_type
    case 'ann'
        [is_valid_fom, out_ann] = ann_manager_obj.predict_ann(n_sol, inp, out_approx);
    case 'approx'
        [is_valid_fom, out_ann] = ann_manager_obj.predict_scl(n_sol, inp, out_approx);
    otherwise
        error('invalid data')
end

% data
is_valid = is_valid_inp&is_valid_fom;
inp_shrink = get_shrink_inp(inp);
fom = get_struct_merge(inp_shrink, out_ann);

end

function inp_shrink = get_shrink_inp(inp)

% assign
inp_shrink.S_box = inp.S_box;
inp_shrink.V_box = inp.V_box;

inp_shrink.t_core = inp.t_core;
inp_shrink.z_core = inp.z_core;
inp_shrink.d_gap = inp.d_gap;
inp_shrink.x_window = inp.x_window;
inp_shrink.y_window = inp.y_window;
inp_shrink.d_iso = inp.d_iso;
inp_shrink.r_curve = inp.r_curve;

inp_shrink.A_core = inp.A_core;
inp_shrink.A_winding = inp.A_winding;

inp_shrink.V_winding = inp.V_winding;
inp_shrink.V_core = inp.V_core;

end
