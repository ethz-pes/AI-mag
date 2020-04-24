function const = get_fem_ann_data_init()
% Return the constant data.
%
%    These data are constant (no part of the sweep combinations).
%    These data are used for both magnetic and thermal model.
%
%    Returns:
%        const (struct): const data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% magnetic simulation
const.mu_core = 2200; % permeability of the core for the FEM simulation
const.beta_core = 2.4; % beta (Steinmetz parameter) of the core for the FEM simulation

% thermal simulation
const.k_core = 5.0; % thermal conductivity of the core
const.k_iso = 0.5; % thermal conductivity of the insulation
const.k_winding_t = 20; % thermal conductivity of the winding (tangential direction)
const.k_winding_n = 0.3; % thermal conductivity of the winding (normal direction)
const.k_contact = 0.1; % thermal conductivity of the winding/core/insulation contact
const.d_contact = 100e-6; % physical gap for winding/core/insulation contact
const.h_convection = 20.0; % convection coefficient reference value
const.fact_exposed = 1.0; % convection scaling factor for the exposed area
const.fact_internal = 0.25; % convection scaling factor for the semi-exposed area
const.T_ambient = 0.0; % ambient temperature for the FEM simulation

% FEM mesh control
const.n_mesh_min = 4; % minimum mesh size (how many times smaller than the smaller feature)
const.n_mesh_max = 4; % maximum mesh size (how many times smaller than body dimension)
const.fact_air = 0.3; % size of the air box compared to the inductor box volume
const.mesh_growth = 1.6; % mesh growth rate
const.mesh_res = 0.1; % mesh resolution

% insulation distance, relative to the window size, with boundaries
const.d_iso_min = 0.5e-3; % minimum insulation distance
const.d_iso_max = 1.5e-3; % maximum insulation distance
const.d_iso_fact = 0.1; % insulation distance relative to the window size

% core corner fillet radius, relative relative to the air gap length, with boundaries
const.r_fill_min = 0.25e-3; % minimum fillet radius
const.r_fill_max = 2.5e-3; % maximum fillet radius
const.r_fill_fact = 0.05; % fillet radius relative relative to the air gap length

% winding head fillet radius, relative to the core limb size
const.fact_curve = 0.5;

% mimum air gap, too small air gaps cannot be practically realized
const.d_gap_min = 100e-6;

end