function [is_valid, geom] = get_geom(inp, geom)

% merge
inp_tmp.volume_target = inp.volume_target;
inp_tmp.fact_core = inp.fact_core;
inp_tmp.fact_window = inp.fact_window;
inp_tmp.fact_core_window = inp.fact_core_window;
inp_tmp.fact_gap = inp.fact_gap;
geom = get_struct_merge(inp_tmp, geom);

geom = get_scale(geom);
geom = get_core(geom);
geom = get_winding(geom);
geom = get_box(geom);
is_valid = get_is_valid(geom);

end

function geom = get_scale(geom)

% compute geom
geom.A_core_window = get_area_product(geom);

geom.A_window = sqrt(geom.A_core_window./geom.fact_core_window);
geom.x_window = sqrt(geom.A_window./geom.fact_window);
geom.y_window = sqrt(geom.A_window.*geom.fact_window);

geom.A_core = sqrt(geom.A_core_window.*geom.fact_core_window);
geom.t_core = sqrt(geom.A_core./geom.fact_core);
geom.z_core = sqrt(geom.A_core.*geom.fact_core);

geom.d_gap = geom.fact_gap.*sqrt(geom.A_core);

% fillet
geom.r_fill = geom.r_fill_fact.*geom.d_gap;
geom.r_fill = min(geom.r_fill, geom.r_fill_max);
geom.r_fill = max(geom.r_fill, geom.r_fill_min);

% isolation
geom.d_iso = geom.d_iso_fact.*min(geom.x_window, geom.x_window);
geom.d_iso = min(geom.d_iso, geom.d_iso_max);
geom.d_iso = max(geom.d_iso, geom.d_iso_min);

% curvature
geom.r_curve = geom.fact_curve.*(geom.t_core./2);

end

function geom = get_core(geom)

geom.x_core = 2.*geom.x_window+2.*geom.t_core;
geom.y_core = geom.y_window+geom.t_core;
geom.l_core = 2.*(geom.x_window+geom.y_window-geom.d_gap)+2.*geom.t_core;
geom.V_core = geom.z_core.*(geom.x_core.*geom.y_core-2.*geom.x_window.*geom.y_window-2.*geom.t_core.*geom.d_gap);

end

function geom = get_winding(geom)

geom.x_winding = geom.x_window-2.*geom.d_iso;
geom.y_winding = geom.y_window-2.*geom.d_iso;
geom.A_winding = geom.x_winding.*geom.y_winding;
geom.l_winding = 2.*(geom.z_core+geom.t_core-2*geom.r_curve)+2.*pi.*(geom.r_curve+geom.d_iso+geom.x_winding./2);
geom.V_winding = geom.l_winding.*geom.A_winding;

end

function geom = get_box(geom)

% mesh
geom.x_box = 2.*geom.x_window+2.*geom.t_core;
geom.y_box = geom.y_window+geom.t_core;
geom.z_box = geom.z_core+2.*(geom.x_window+geom.fact_curve.*geom.t_core./2);
geom.S_box = 2.*(geom.x_box.*geom.y_box+geom.x_box.*geom.z_box+geom.y_box.*geom.z_box);
geom.V_box = geom.x_box.*geom.y_box.*geom.z_box;

end

function is_valid = get_is_valid(geom)

% check
is_valid = true;
is_valid = is_valid&isfinite(geom.A_core_window);
is_valid = is_valid&isreal(geom.A_core_window);
is_valid = is_valid&(geom.A_core_window>=0);
is_valid = is_valid&(geom.x_window>=(4.*geom.d_iso));
is_valid = is_valid&(geom.y_window>=(4.*geom.d_iso));
is_valid = is_valid&(geom.t_core>=(2.*geom.r_curve));
is_valid = is_valid&(geom.d_gap>=geom.d_gap_min);

end

function A_core_window = get_area_product(geom)

% extract
volume_target = geom.volume_target;
fact_core = geom.fact_core;
fact_window = geom.fact_window;
fact_core_window = geom.fact_core_window;
fact_curve = geom.fact_curve;

% solve
fact = 2.*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.*fact_core_window.^(1/2)).^(1/2)+(fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2).*fact_curve+2.*((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window).^(1/2));
x = (volume_target./fact).^(1./3);
A_core_window = x.^4;

end
