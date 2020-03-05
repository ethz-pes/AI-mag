function const = get_data_const(model_type)

const.geom = get_geom();
const.fem = get_fem();
const.physics = get_physics(model_type);

end

function const = get_physics(model_type)

switch model_type
    case 'mf'
        const.mu_core = 2200;
        const.beta_core = 2.4;
        const.I_winding = 1.0;
    case 'ht'
        const.k_core = 5.0;
        const.k_iso = 0.5;
        const.k_winding_t = 20;
        const.k_winding_n = 0.3;
        const.k_contact = 0.1;
        const.d_contact = 100e-6;
        const.h_exposed = 20.0;
        const.h_internal = 5.0;
        const.T_ambient = 0.0;
    otherwise
        error('invalid model')
end

end

function const = get_fem()

const.n_mesh_min = 4;
const.n_mesh_max = 4;
const.mesh_growth = 1.6;
const.mesh_res = 0.1;
const.fact_air = 0.3;

end

function const = get_geom()

% iso
const.d_iso_min = 0.5e-3;
const.d_iso_max = 1.5e-3;
const.d_iso_fact = 0.1;

% fill
const.r_fill_min = 0.25e-3;
const.r_fill_max = 2.5e-3;
const.r_fill_fact = 0.05;

% geometry factor
const.fact_curve = 0.5;
const.d_gap_min = 100e-6;

end