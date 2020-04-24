function out_approx = get_out_approx_ht(inp)
% Get the analytical approximations for the thermal model.
%
%    Parameters:
%        inp (struct): struct of vectors with the parameters
%
%    Returns:
%        out_approx (struct): struct of vectors with the analytical results
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% compute different surface areas of the geometry
inp = get_surface(inp);

% extract required parameters
V_core = inp.V_core;
S_core = inp.S_core;
S_core_exposed = inp.S_core_exposed;
S_core_internal = inp.S_core_internal;
S_core_winding = inp.S_core_winding;
V_winding = inp.V_winding;
S_winding = inp.S_winding;
S_winding_exposed = inp.S_winding_exposed;
S_winding_internal = inp.S_winding_internal;
d_iso = inp.d_iso;
k_core = inp.k_core;
k_winding_n = inp.k_winding_n;
k_iso = inp.k_iso;
h_convection = inp.h_convection;
fact_exposed = inp.fact_exposed;
fact_internal = inp.fact_internal;
T_ambient = inp.T_ambient;
P_core = inp.P_core;
P_winding = inp.P_winding;

% heat conduction resistance of the core and winding
R_core = (V_core./(S_core.^2.*k_core));
R_winding = (V_winding./(S_winding.^2.*k_winding_n));

% heat conduction resistance of the insulation
R_iso_core_winding = d_iso./(S_core_winding.*k_iso);
R_iso_winding_internal = d_iso./(S_winding_internal.*k_iso);
R_iso_winding_exposed = d_iso./(S_winding_exposed.*k_iso);

% convection resistance of the core (exposed and semi-exposed area in parallel)
R_conv_core_exposed = 1./(fact_exposed.*h_convection.*S_core_exposed);
R_conv_core_internal = 1./(fact_internal.*h_convection.*S_core_internal);
R_extract_winding = 1./((1./R_conv_core_exposed)+(1./R_conv_core_internal));

% convection resistance of the winding (in insulation resistance, exposed and semi-exposed area in parallel)
R_conv_winding_exposed = 1./(fact_exposed.*h_convection.*S_winding_exposed);
R_conv_winding_internal = 1./(fact_internal.*h_convection.*S_winding_internal);
R_extract_core = 1./((1./(R_conv_winding_exposed+R_iso_winding_exposed))+(1./(R_conv_winding_internal+R_iso_winding_internal)));

% solve the linear thermal circuit
%    - this linear circuit is solved with Mathematica
%    - the solution is exported to MATLAB
%    - the Mathematica source file is 'resources/thermal_circuit.nb'
%    - details: R. Burkart, "Advanced Modeling and Multi-Objective Optimization of Power Electronic Converter Systems", 2016
T_winding_min = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_winding.*R_iso_core_winding+(-1).*R_extract_core.*T_ambient+(-1).*R_extract_winding.*T_ambient+(-1).*R_iso_core_winding.*T_ambient);
T_core_min = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_core.*R_extract_core.*R_iso_core_winding+(-1).*R_extract_core.*T_ambient+(-1).*R_extract_winding.*T_ambient+(-1).*R_iso_core_winding.*T_ambient);
T_winding_max = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_winding.*R_iso_core_winding+(-1).*P_winding.*R_extract_core.*R_winding+(-1).*P_winding.*R_extract_winding.*R_winding+(-1).*P_winding.*R_iso_core_winding.*R_winding+(-1).*R_extract_core.*T_ambient+(-1).*R_extract_winding.*T_ambient+(-1).*R_iso_core_winding.*T_ambient);
T_core_max = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_core.*R_extract_core+(-1).*P_core.*R_core.*R_extract_winding+(-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_core.*R_core.*R_iso_core_winding+(-1).*P_core.*R_extract_core.*R_iso_core_winding+(-1).*R_extract_core.*T_ambient+(-1).*R_extract_winding.*T_ambient+(-1).*R_iso_core_winding.*T_ambient);

% compute the temperature differences, assign the results
%    - maximum temperature elevation of the core, for the thermal limit
%    - average temperature elevation of the core, for the losses
%    - maximum temperature elevation of the winding, for the thermal limit
%    - average temperature elevation of the winding, for the losses
%    - maximum temperature elevation of the insulation, for the thermal limit
out_approx.dT_core_max = T_core_max-T_ambient;
out_approx.dT_core_avg = ((T_core_max+T_core_min)./2)-T_ambient;
out_approx.dT_winding_max = T_winding_max-T_ambient;
out_approx.dT_winding_avg = ((T_winding_max+T_winding_min)./2)-T_ambient;
out_approx.dT_iso_max = max(T_winding_min, T_core_min)-T_ambient;

end

function inp = get_surface(inp)
% Compute different surface areas of the geometry.
%
%    Parameters:
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        inp (struct): struct of vectors with the data

% core exposed area, internal area, contact area with the winding
S_core_winding = 4.*inp.x_window.*inp.z_core+4.*inp.y_window.*inp.z_core;
S_core_top = 2.*inp.x_core.*inp.z_core;
S_core_side = 2.*inp.y_core.*inp.z_core;
S_core_front_exposed = 4.*inp.y_window.*inp.t_core./2+4.*inp.x_core.*inp.t_core./2;
S_core_front_internal = 2.*inp.y_window.*inp.t_core;

% winding exposed area, internal area
S_head_inner = (2.*(inp.t_core-2*inp.r_curve)+2.*pi.*(inp.r_curve+inp.x_window)).*inp.y_window;
S_head_top = 2.*(2.*(inp.t_core-2*inp.r_curve)+2.*pi.*(inp.r_curve+inp.x_window./2)).*inp.x_window;
S_head_outer = (2.*(inp.t_core-2*inp.r_curve)+2.*pi.*(inp.r_curve)).*inp.y_window;

% total core area
inp.S_core = S_core_winding+S_core_top+S_core_side+S_core_front_exposed+S_core_front_internal;

% contact area between the core and the winding
inp.S_core_winding = S_core_winding;

% core area exposed to convective cooling
inp.S_core_exposed = S_core_top+S_core_side+S_core_front_exposed;

% core area semi-exposed to convective cooling
inp.S_core_internal = S_core_front_internal;

% total winding area
inp.S_winding = S_core_winding+S_head_inner+S_head_top+S_head_outer;

% winding area exposed to convective cooling
inp.S_winding_exposed = S_head_top+S_head_outer;

% winding area semi-exposed to convective cooling
inp.S_winding_internal = S_head_inner;

end
