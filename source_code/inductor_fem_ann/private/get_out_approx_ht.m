function out_approx = get_out_approx_ht(param)

% add surface
param = get_surface(param);

% extract geom
V_core = param.V_core;
S_core = param.S_core;
S_core_exposed = param.S_core_exposed;
S_core_internal = param.S_core_internal;
S_core_winding = param.S_core_winding;
V_winding = param.V_winding;
S_winding = param.S_winding;
S_winding_exposed = param.S_winding_exposed;
S_winding_internal = param.S_winding_internal;
d_iso = param.d_iso;

% extract physics
k_core = param.k_core;
k_winding_n = param.k_winding_n;
k_iso = param.k_iso;
h_exposed = param.h_exposed;
h_internal = param.h_internal;
T_ambient = param.T_ambient;
P_core = param.P_core;
P_winding = param.P_winding;

% resistance
R_core = (V_core./(S_core.^2.*k_core));
R_winding = (V_winding./(S_winding.^2.*k_winding_n));

R_iso_core_winding = d_iso./(S_core_winding.*k_iso);
R_iso_winding_internal = d_iso./(S_winding_internal.*k_iso);
R_iso_winding_exposed = d_iso./(S_winding_exposed.*k_iso);

R_conv_core_exposed = 1./(h_exposed.*S_core_exposed);
R_conv_core_internal = 1./(h_internal.*S_core_internal);
R_extract_winding = 1./((1./R_conv_core_exposed)+(1./R_conv_core_internal));

R_conv_winding_exposed = 1./(h_exposed.*S_winding_exposed);
R_conv_winding_internal = 1./(h_internal.*S_winding_internal);
R_extract_core = 1./((1./(R_conv_winding_exposed+R_iso_winding_exposed))+(1./(R_conv_winding_internal+R_iso_winding_internal)));

% circuit
T_winding_min = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_winding.*R_iso_core_winding+(-1).*R_extract_core.*T_ambient+(-1).*R_extract_winding.*T_ambient+(-1).*R_iso_core_winding.*T_ambient);
T_core_min = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_core.*R_extract_core.*R_iso_core_winding+(-1).*R_extract_core.*T_ambient+(-1).*R_extract_winding.*T_ambient+(-1).*R_iso_core_winding.*T_ambient);
T_winding_max = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_winding.*R_iso_core_winding+(-1).*P_winding.*R_extract_core.*R_winding+(-1).*P_winding.*R_extract_winding.*R_winding+(-1).*P_winding.*R_iso_core_winding.*R_winding+(-1).*R_extract_core.*T_ambient+(-1).*R_extract_winding.*T_ambient+(-1).*R_iso_core_winding.*T_ambient);
T_core_max = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_core.*R_extract_core+(-1).*P_core.*R_core.*R_extract_winding+(-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_core.*R_core.*R_iso_core_winding+(-1).*P_core.*R_extract_core.*R_iso_core_winding+(-1).*R_extract_core.*T_ambient+(-1).*R_extract_winding.*T_ambient+(-1).*R_iso_core_winding.*T_ambient);

% assign
out_approx.T_core_max = T_core_max-T_ambient;
out_approx.T_core_avg = ((T_core_max-+T_core_min)./2)-T_ambient;
out_approx.T_winding_max = T_winding_max-T_ambient;
out_approx.T_winding_avg = ((T_winding_max+T_winding_min)./2)-T_ambient;

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
