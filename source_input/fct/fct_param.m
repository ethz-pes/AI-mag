function [is_valid, param] = fct_param(model_type, param)

param = get_scale(param);

param = get_core(param);
param = get_winding(param);
param = get_box(param);
param = get_surface(param);
param = get_fem(param);
param = get_model(model_type, param);

is_valid = get_is_valid(param);

end

function param = get_scale(param)

% compute geom
param.A_core_window = get_area_product(param);

param.A_window = sqrt(param.A_core_window./param.fact_core_window);
param.x_window = sqrt(param.A_window./param.fact_window);
param.y_window = sqrt(param.A_window.*param.fact_window);

param.A_core = sqrt(param.A_core_window.*param.fact_core_window);
param.t_core = sqrt(param.A_core./param.fact_core);
param.z_core = sqrt(param.A_core.*param.fact_core);

param.d_gap = param.fact_gap.*sqrt(param.A_core);

% fillet
param.r_fill = param.r_fill_fact.*param.d_gap;
param.r_fill = min(param.r_fill, param.r_fill_max);
param.r_fill = max(param.r_fill, param.r_fill_min);

% isolation
param.d_iso = param.d_iso_fact.*min(param.x_window, param.x_window);
param.d_iso = min(param.d_iso, param.d_iso_max);
param.d_iso = max(param.d_iso, param.d_iso_min);

% curvature
param.r_curve = param.fact_curve.*(param.t_core./2);

end

function param = get_core(param)

param.x_core = 2.*param.x_window+2.*param.t_core;
param.y_core = param.y_window+param.t_core;
param.l_core = 2.*(param.x_window+param.y_window-param.d_gap)+2.*param.t_core;
param.V_core = param.z_core.*(param.x_core.*param.y_core-2.*param.x_window.*param.y_window-2.*param.t_core.*param.d_gap);

end

function param = get_winding(param)

param.x_winding = param.x_window-2.*param.d_iso;
param.y_winding = param.y_window-2.*param.d_iso;
param.A_winding = param.x_winding.*param.y_winding;
param.l_winding = 2.*(param.z_core+param.t_core-2*param.r_curve)+2.*pi.*(param.r_curve+param.d_iso+param.x_winding./2);
param.V_winding = param.l_winding.*param.A_winding;

end

function param = get_surface(param)

% core
S_core_winding = 4.*param.x_window.*param.z_core+4.*param.y_window.*param.z_core;
S_core_top = 2.*param.x_core.*param.z_core;
S_core_side = 2.*param.y_core.*param.z_core;
S_core_front_exposed = 4.*param.y_window.*param.t_core./2+4.*param.x_core.*param.t_core./2;
S_core_front_internal = 2.*param.y_window.*param.t_core;

% head
S_head_inner = (2.*(param.t_core-2*param.r_curve)+2.*pi.*(param.r_curve+param.x_window)).*param.y_window;
S_head_top = 2.*(2.*(param.t_core-2*param.r_curve)+2.*pi.*(param.r_curve+param.x_window./2)).*param.x_window;
S_head_outer = (2.*(param.t_core-2*param.r_curve)+2.*pi.*(param.r_curve)).*param.y_window;

% assign
param.S_core = S_core_winding+S_core_top+S_core_side+S_core_front_exposed+S_core_front_internal;
param.S_core_winding = S_core_winding;
param.S_core_exposed = S_core_top+S_core_side+S_core_front_exposed;
param.S_core_internal = S_core_front_internal;
param.S_winding = S_core_winding+S_head_inner+S_head_top+S_head_outer;
param.S_winding_exposed = S_head_top+S_head_outer;
param.S_winding_internal = S_head_inner;

end

function param = get_box(param)

% mesh
param.x_box = 2.*param.x_window+2.*param.t_core;
param.y_box = param.y_window+param.t_core;
param.z_box = param.z_core+2.*(param.x_window+param.fact_curve.*param.t_core./2);
param.S_box = 2.*(param.x_box.*param.y_box+param.x_box.*param.z_box+param.y_box.*param.z_box);
param.V_box = param.x_box.*param.y_box.*param.z_box;

end

function param = get_fem(param)

% box
param.d_air = param.fact_air.*max([param.x_box param.y_box param.z_box]);

% mesh
d_char_core = min([param.t_core param.z_core]);
d_char_winding = min([param.x_window param.y_window param.z_core]);
d_char_min = min([param.d_gap param.d_iso param.r_fill]);
d_char_air = min([param.x_box param.y_box param.z_box]);
d_char_iso = min([d_char_core d_char_winding]);
param.d_mesh_core = d_char_core./param.n_mesh_max;
param.d_mesh_winding = d_char_winding./param.n_mesh_max;
param.d_mesh_air = d_char_air./param.n_mesh_max;
param.d_mesh_iso = d_char_iso./param.n_mesh_max;
param.d_mesh_min = d_char_min./param.n_mesh_min;

end

function param = get_model(model_type, param)

% model
switch model_type
    case 'mf'
        param.I_winding = 1.0;
    case 'ht'
        param.T_ambient = 0.0;
        param.P_tot = param.ht_stress.*param.S_box;
        param.P_core = sqrt(param.P_tot./param.ht_sharing);
        param.P_winding = sqrt(param.P_tot.*param.ht_sharing);
    otherwise
        error('invalid type')
end

end

function is_valid = get_is_valid(param)

% check
is_valid = true;
is_valid = is_valid&isfinite(param.A_core_window);
is_valid = is_valid&isreal(param.A_core_window);
is_valid = is_valid&(param.A_core_window>=0);
is_valid = is_valid&(param.x_window>=(4.*param.d_iso));
is_valid = is_valid&(param.y_window>=(4.*param.d_iso));
is_valid = is_valid&(param.t_core>=(2.*param.r_curve));
is_valid = is_valid&(param.d_gap>=param.d_gap_min);

end

function A_core_window = get_area_product(param)

% extract
volume_target = param.volume_target;
fact_core = param.fact_core;
fact_window = param.fact_window;
fact_core_window = param.fact_core_window;
fact_curve = param.fact_curve;

% solve
fact = 2.*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.*fact_core_window.^(1/2)).^(1/2)+(fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2).*fact_curve+2.*((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window).^(1/2));
x = (volume_target./fact).^(1./3);
A_core_window = x.^4;

end
