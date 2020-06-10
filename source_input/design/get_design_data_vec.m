function data_vec = get_design_data_vec(geom, material, f)
% Function for getting the inductor data (struct of scalars).
%
%    Parameters:
%        geom (struct): inductor geometry information
%        material (struct): inductor material information
%        f (float): operating frequency
%
%    Returns:
%        data_vec (struct:) struct of scalars
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% inductor physical parameters
%    - T_winding_init: initial guess for the winding temperature
%    - T_core_init: initial guess for the core temperature
%    - I_test: test current for computing the magnetic circuit
other.T_winding_init = 80.0;
other.T_core_init = 80.0;
other.I_test = 10.0;

% inductor scaling factor for the figures of merit
%    - m_scale: scaling factor for the total mass
%    - m_offset: offset for the total mass
%    - V_scale: scaling factor for the box volume
%    - V_offset: offset for the box volume
%    - c_scale: scaling factor for the total cost
%    - c_offset: offset for the total cost
%    - P_scale: scaling factor for the total losses
%    - P_offset: offset for the total losses
fom_data.m_scale = 1.0;
fom_data.m_offset = 0.0;
fom_data.V_scale = 1.0;
fom_data.V_offset = 0.0;
fom_data.c_scale = 1.0;
fom_data.c_offset = 0.0;
fom_data.P_scale = 1.0;
fom_data.P_offset = 0.0;

% bounds for the geometry figures of merit
%    - c_tot: total cost
%    - m_tot: total mass
%    - V_box: box volume
fom_limit.c_tot = struct('min', 0.0, 'max', 20.0);
fom_limit.m_tot = struct('min', 0.0, 'max', 800e-3);
fom_limit.V_box = struct('min', 0.0, 'max', 200e-6);

% bounds for the circuit figures of merit
%    - L: inductance
%    - V_t_sat_sat: saturation voltage time product (complete hysteresis loop)
%    - I_sat: maximum saturation current
%    - I_rms: maximum RMS current
fom_limit.L = struct('min', 0.0, 'max', Inf);
fom_limit.V_t_sat_sat = struct('min', 200./(2.*f), 'max', Inf);
fom_limit.I_sat = struct('min', 10.0, 'max', Inf);
fom_limit.I_rms = struct('min', 10.0, 'max', Inf);

% assign the data
data_vec.other = other;
data_vec.material = material;
data_vec.geom = geom;
data_vec.fom_data = fom_data;
data_vec.fom_limit = fom_limit;

end