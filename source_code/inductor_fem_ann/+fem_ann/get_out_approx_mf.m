function out_approx = get_out_approx_mf(inp)

% extract geom
A_core = inp.A_core;
l_core = inp.l_core;
d_gap = inp.d_gap;
A_winding = inp.A_winding;
x_window = inp.x_window;
y_window = inp.y_window;
mu_core = inp.mu_core;
I_winding = inp.I_winding;

% L_norm
mu0 = 4.*pi.*1e-7;
F = 1+(d_gap./sqrt(A_core)).*log(2.*y_window./d_gap);
R_core = l_core./(mu0.*mu_core.*A_core);
R_gap = d_gap./(mu0.*F.*A_core);
L_norm = 1./(R_core+R_gap+R_gap);

% B_norm
B_tot = I_winding.*L_norm./A_core;
B_norm = B_tot./I_winding;

% J_norm
J_tot = I_winding./A_winding;
J_norm = J_tot./I_winding;

% H_norm
H_rms_x = I_winding./(2.*sqrt(3).*x_window);
H_rms_y = I_winding./(2.*sqrt(3).*y_window);
H_tot = sqrt(H_rms_x.^2+H_rms_y.^2);
H_norm = H_tot./I_winding;

% assign
out_approx.L_norm = L_norm;
out_approx.B_norm = B_norm;
out_approx.J_norm = J_norm;
out_approx.H_norm = H_norm;

end