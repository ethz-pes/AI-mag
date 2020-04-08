function out_approx = get_out_approx_mf(inp)
% Get the analytical approximations for the magnetic model.
%
%    Parameters:
%        inp (struct): struct of vectors with the parameters
%
%    Returns:
%        out_approx (struct): struct of vectors with the analytical results
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% extract required parameters
A_core = inp.A_core;
l_core = inp.l_core;
d_gap = inp.d_gap;
A_winding = inp.A_winding;
x_window = inp.x_window;
y_window = inp.y_window;
mu_core = inp.mu_core;
I_winding = inp.I_winding;

% get the inductance (for a single turn)
%    - using reluctance model
%    - correction factor for the air gap (by T. MyLyman )
%    - T. MyLyman, "Transformer and Inductor Design Handbook", 2016
mu0 = 4.*pi.*1e-7;
F = 1+(d_gap./sqrt(A_core)).*log(2.*y_window./d_gap);
R_core = l_core./(mu0.*mu_core.*A_core);
R_gap = d_gap./(mu0.*F.*A_core);
L_norm = 1./(R_core+R_gap+R_gap);

% get the magnetic flux density in the core (normalized for one turn and 1A), for the core losses
B_tot = I_winding.*L_norm./A_core;
B_norm = B_tot./I_winding;

% get the current density in the winding (normalized for one turn and 1A), for the LF winding losses
J_tot = I_winding./A_winding;
J_norm = J_tot./I_winding;

% get the magnetic field in the winding (normalized per current unit), for the HF winding losses
%    - no good simple analytical approximation exists
%    - due to the air gap fringing this is a complex problem
%    - use a simple estimation of the field (by M. Leibl) 
%    - details: M. Leibl, "Three-Phase PFC Rectifier and High-Voltage Generator", 2017
H_rms_x = I_winding./(2.*sqrt(3).*x_window);
H_rms_y = I_winding./(2.*sqrt(3).*y_window);
H_tot = sqrt(H_rms_x.^2+H_rms_y.^2);
H_norm = H_tot./I_winding;

% assign the results
out_approx.L_norm = L_norm;
out_approx.B_norm = B_norm;
out_approx.J_norm = J_norm;
out_approx.H_norm = H_norm;

end