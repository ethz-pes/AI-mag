function fom_approx = fct_out_approx(model_type, param)

if strcmp(model_type, 'mf')
    fom_approx = get_mf(param);
end

if strcmp(model_type, 'ht')
    fom_approx = get_hf(param);
end
    
end

function fom_approx = get_hf(param)

% extract
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
k_core = param.k_core;
k_winding_n = param.k_winding_n;
k_iso = param.k_iso;
h_exposed = param.h_exposed;
h_internal = param.h_internal;
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
T_winding_min = R_extract_winding.*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*(P_core.*R_extract_core+P_winding.*R_extract_core+P_winding.*R_iso_core_winding);
T_core_min = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_core.*R_extract_core.*R_iso_core_winding);
T_winding_max = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_winding.*R_iso_core_winding+(-1).*P_winding.*R_extract_core.*R_winding+(-1).*P_winding.*R_extract_winding.*R_winding+(-1).*P_winding.*R_iso_core_winding.*R_winding);
T_core_max = (-1).*(R_extract_core+R_extract_winding+R_iso_core_winding).^(-1).*((-1).*P_core.*R_core.*R_extract_core+(-1).*P_core.*R_core.*R_extract_winding+(-1).*P_core.*R_extract_core.*R_extract_winding+(-1).*P_winding.*R_extract_core.*R_extract_winding+(-1).*P_core.*R_core.*R_iso_core_winding+(-1).*P_core.*R_extract_core.*R_iso_core_winding);

% assign
fom_approx.T_core_max = T_core_max;
fom_approx.T_core_avg = (T_core_max+T_core_min)./2;
fom_approx.T_winding_max = T_winding_max;
fom_approx.T_winding_avg = (T_winding_max+T_winding_min)./2;

end

function fom_approx = get_mf(param)

% extract
A_core = param.A_core;
l_core = param.l_core;
d_gap = param.d_gap;
A_winding = param.A_winding;
x_window = param.x_window;
y_window = param.y_window;
mu_core = param.mu_core;

% L_norm
mu0 = 4.*pi.*1e-7;
F = 1+(d_gap./sqrt(A_core)).*log(2.*y_window./d_gap);
R_core = l_core./(mu0.*mu_core.*A_core);
R_gap = d_gap./(mu0.*F.*A_core);
L_norm = 1./(R_core+R_gap+R_gap);

% B_norm
B_norm = L_norm./A_core;

% J_norm
J_norm = 1./A_winding;

% H_norm
H_rms_x = 1./(2.*sqrt(3).*x_window);
H_rms_y = 1./(2.*sqrt(3).*y_window);
H_norm = sqrt(H_rms_x.^2+H_rms_y.^2);

% assign
fom_approx.L_norm = L_norm;
fom_approx.B_norm = B_norm;
fom_approx.J_norm = J_norm;
fom_approx.H_norm = H_norm;

end