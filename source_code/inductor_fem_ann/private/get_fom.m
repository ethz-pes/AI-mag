function [is_valid, fom] = get_fom(model_type, const, ann_manager_obj, n_sol, inp)

% geometry
const = get_struct_size(const, n_sol);
param = get_struct_merge(inp, const);

% geom
[is_valid, param] = get_extend_param(model_type, param);

% approx
out_approx = get_out_approx(model_type, param);

% ann
[is_valid_fom, out_ann] = ann_manager_obj.predict(n_sol, inp, out_approx);

% data
param_shrink = get_shrink_param(param);
fom = get_struct_merge(param_shrink, out_ann);

end

function param_shrink = get_shrink_param(param)

% assign
param_shrink.S_box = param.S_box;
param_shrink.V_box = param.V_box;

param_shrink.t_core = param.t_core;
param_shrink.z_core = param.z_core;
param_shrink.d_gap = param.d_gap;
param_shrink.x_window = param.x_window;
param_shrink.y_window = param.y_window;
param_shrink.d_iso = param.d_iso;
param_shrink.r_curve = param.r_curve;

param_shrink.A_core = param.A_core;
param_shrink.A_winding = param.A_winding;

param_shrink.V_winding = param.V_winding;
param_shrink.V_core = param.V_core;

end
