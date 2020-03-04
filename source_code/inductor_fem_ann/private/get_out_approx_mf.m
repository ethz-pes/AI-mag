function out_approx = get_out_approx_mf(geom, material)

% extract geom
A_core = geom.A_core;
l_core = geom.l_core;
d_gap = geom.d_gap;
A_winding = geom.A_winding;
x_window = geom.x_window;
y_window = geom.y_window;

% extract material
mu_core = material.mu_core;

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
out_approx.L_norm = L_norm;
out_approx.B_norm = B_norm;
out_approx.J_norm = J_norm;
out_approx.H_norm = H_norm;

end