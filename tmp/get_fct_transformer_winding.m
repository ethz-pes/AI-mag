function winding = get_fct_transformer_winding(winding_id)

%% fct
rho = 1.7241e-8;
alpha = 3.93e-3;
T_ref = 20;
T_vec = [20 150];
sigma_fct = @(T, id, n_sol) get_sub(rho, alpha, T_ref, T_vec, T, id, n_sol);

%% param
fill = get_integer_map([50 71 100], 0.7.*[0.47 0.49 0.51], winding_id);
d_strand = get_integer_map([50 71 100], [50e-6 71e-6 100e-6], winding_id);
kappa_copper = get_integer_map([50 71 100], [32.5 23.5 21.5], winding_id);

%% parameter
rho_copper = 8960;
rho_iso = 1500;
kappa_iso = 5.0;
J_rms_max = 20e6;
fact_freq_max = 50.0;
P_scale_lf = 1.3;
P_scale_hf = 1.4;
T_init = 80.0;
T_max = 140.0;

%% assign
winding.fill = fill;
winding.d_strand = d_strand;
winding.delta_min = d_strand;
winding.rho = rho_copper.*fill+rho_iso.*(1-fill);
winding.lambda = rho_copper.*fill.*kappa_copper+rho_iso.*(1-fill).*kappa_iso;
winding.sigma_fct = sigma_fct;
winding.winding_id = winding_id;
winding.J_rms_max = J_rms_max;
winding.fact_freq_max = fact_freq_max;
winding.P_scale_lf = P_scale_lf;
winding.P_scale_hf = P_scale_hf;
winding.T_init = T_init;
winding.T_max = T_max;

end

function [sigma, is_valid] = get_sub(rho, alpha, T_ref, T_vec, T, id, n_sol)

assert(length(T)==n_sol, 'invalid data')
assert(length(id)==n_sol, 'invalid data')

is_valid = (T>=min(T_vec))&(T<=max(T_vec));
T(T<=min(T_vec)) = min(T_vec);
T(T>=max(T_vec)) = max(T_vec);

sigma = 1./(rho.*(1+alpha.*(T-T_ref)));

end